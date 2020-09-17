import UIKit
import CoreLocation
import MapKit
import CoreData
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    /// Request s gps updates.
    internal let manager = CLLocationManager()
    /// Interfaces with the database.
    public let DBMS: DBManager
    /// Estimates activities based on given information (such as location updates).
    internal var activityEstimator: ActivityEstimator<WeightedActivityList>!
    /// Location of last request for stations nearby. Used to avoid too many requests.
    internal var locationLastStationRequest: CLLocation? = nil
    /// Location of last request for airports nearby. Used to avoid too many requests.
    internal var locationLastAirportRequest: CLLocation? = nil
    /// UUID for repeating notifications.
    internal let notificationUUID = UUID().uuidString
    /// Observable state of location tracking.
    internal var isTrackingPaused: Observable<Bool> = Observable(rawValue: false)
    /// Defines radius of search for airports in meters.
    internal var airportRequestRadius: Double = MAX_AIRPORT_REQUEST_RADIUS
    
    internal var scene = SceneDelegate()
    internal let databaseCleanUpId = "com.altereco.database.cleanup"
    
    override init() {
        self.DBMS = CoreDataManager()
        super.init()
        
        // if this is the first launch, make sure settings are initialised correctly
        if !UserDefaults.standard.bool(forKey: "skipIntroduction") {
            UserDefaults.standard.set(DEFAULT_CYCLE_SPEED, forKey: "cycleSpeed")
            UserDefaults.standard.set(true, forKey: "autoPauseEnabled")
        }
        
        // configure estimator of motion activities
        let activityList = WeightedActivityList(activityWeights: ACTIVITY_WEIGHTS_DICT)
        activityEstimator = ActivityEstimator<WeightedActivityList>(activityList: activityList, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, timers: MultiTimer(), DBMS: DBMS)
        activityEstimator.setInAirportCallback(callback: userIsInAnAirport(airport:))
    }
    
    /// Schedules an app refresh in the background to perform database cleanup.
    func scheduleAppRefresh() {
        print("Scheduling app refresh")
        let request = BGAppRefreshTaskRequest(identifier: databaseCleanUpId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: HOUR_IN_SECONDS)
            
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        print("App refresh method was called")
        var workItem: DispatchWorkItem?
        workItem = DispatchWorkItem() { [weak self] in
            for type in MeasuredActivity.MotionType.allCases {
                if workItem?.isCancelled ?? true { break }
                self?.cleanUpDatabase(forType: type)
            }
            if let workItem = workItem, !workItem.isCancelled {
                task.setTaskCompleted(success: true)
            }
            workItem = nil // resolve reference cycle
        }
        
        task.expirationHandler = {
            workItem?.cancel()
            task.setTaskCompleted(success: false)
        }
        
        DispatchQueue.main.async(execute: workItem!)
    }
    
    private func cleanUpDatabase(forType type: MeasuredActivity.MotionType) {
        let oneMonthAgo = Date().toLocalTime().addMonths(numMonthsToAdd: -1).toGlobalTime()
        guard let monthStart = oneMonthAgo.toLocalTime().getStartOfMonth()?.toGlobalTime() else { return }
        guard oneMonthAgo.timeIntervalSince(monthStart) > DAY_IN_SECONDS else { return }

        if let results = try? DBMS.queryActivities(predicate: "start >= %@ AND end <= %@ AND motionType == %@",
                                              args: [monthStart, oneMonthAgo, MeasuredActivity.motionTypeToString(type: type)]),
            !results.isEmpty {

        var totalDistance = 0.0
        var earliest = Date()
        var latest = Date(timeIntervalSince1970: 0)
        for activity in results {
            if activity.start < earliest {
                earliest = activity.start
            }
            if activity.end > latest {
                latest = activity.end
            }
            totalDistance += activity.distance
        }

        try? DBMS.delete(entity: "Event", predicate: "start >= %@ AND end <= %@ AND motionType == %@",
                         args: [monthStart, oneMonthAgo, MeasuredActivity.motionTypeToString(type: type)])
        try? DBMS.append(activity: MeasuredActivity(motionType: type, distance: totalDistance, start: earliest, end: latest))
    }
}
    
    // MARK:- UISceneSession Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: databaseCleanUpId, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK:- Location tracking and MapKit requests
    func startLocationTracking() {
        manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.distanceFilter = GPS_DISTANCE_THRESHOLD
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.pausesLocationUpdatesAutomatically = UserDefaults.standard.bool(forKey: "autoPauseEnabled")
        manager.activityType = .automotiveNavigation
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        let content = UNMutableNotificationContent()
        content.title = "Tracking paused: we care about your battery life"
        content.body = "Looks like you have not moved in a while (or there's no signal). Open Alter Eco to resume."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
        isTrackingPaused.rawValue = true
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        
        if locationLastStationRequest == nil ||
            locationLastStationRequest!.distance(from: location).rounded() >= STATION_REQUEST_RADIUS {
            requestStationsAround(location)
        } else {
            activityEstimator.processLocation(location)
        }
    }
    
    func requestStationsAround(_ location: CLLocation) {
        let requestStations = MKLocalSearch.Request()
        requestStations.naturalLanguageQuery = QUERY_TRAIN_STATIONS
        requestStations.region = MKCoordinateRegion(center: location.coordinate,
                                                    latitudinalMeters: STATION_REQUEST_RADIUS,
                                                    longitudinalMeters: STATION_REQUEST_RADIUS)
        requestStations.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])
        
        locationLastStationRequest = location
        MKLocalSearch(request: requestStations).start(completionHandler: onTrainRequestCompletion(response:error:))
    }
    
    func onTrainRequestCompletion(response: MKLocalSearch.Response?, error: Error?) {
        if let location = locationLastStationRequest {
            print("stations requested and received")
            if let response = response {
                activityEstimator.stations = ActivityEstimator.ROIs(response.mapItems)
            }
            
            if (locationLastAirportRequest == nil ||
                locationLastAirportRequest!.distance(from: location).rounded() >= airportRequestRadius) {
                locationLastAirportRequest = location
                requestAirportsAround(location)
            } else {
                activityEstimator.processLocation(location)
            }
        }
    }
    
    func requestAirportsAround(_ location: CLLocation) {
        let requestAirports = MKLocalSearch.Request()
        requestAirports.naturalLanguageQuery = QUERY_AIRPORTS
        requestAirports.region = MKCoordinateRegion(center: location.coordinate,
                                                    latitudinalMeters: airportRequestRadius,
                                                    longitudinalMeters: airportRequestRadius)
        requestAirports.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport])

        MKLocalSearch(request: requestAirports).start { (response, error) in
            print("airports requested and received")
            if let response = response {
                self.activityEstimator.airports = ActivityEstimator.ROIs(response.mapItems)
            }
           // once all requests are completed, process the current location
           self.activityEstimator.processLocation(location)
        }
    }
    
    func userIsInAnAirport(airport: CLLocation) {
        // make airport requests happen more often since user has visited airport
        airportRequestRadius = MIN_AIRPORT_REQUEST_RADIUS
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while retrieving location: ", error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            print("Location tracking not authorised")
        }
    }
    
    //MARK:- Notifications
    func inactivityAndPausedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Heads up!"
        content.body = "Tracking is paused. Open Alter Eco if you wish to resume."
        content.sound = UNNotificationSound.default
        
        let oneTime = UNTimeIntervalNotificationTrigger(timeInterval: 2*HOUR_IN_SECONDS, repeats: false)
        let shortRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: oneTime)
        UNUserNotificationCenter.current().add(shortRequest)
        
        let repeating = UNTimeIntervalNotificationTrigger(timeInterval: DAY_IN_SECONDS, repeats: true)
        let repeatingRequest = UNNotificationRequest(identifier: notificationUUID, content: content, trigger: repeating)
        UNUserNotificationCenter.current().add(repeatingRequest)
    }
    
    func requestNotificationsPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            { granted, error in
                if let error = error { print("Error in registering notifications. Description: \(error.localizedDescription)")}
            }
        
      }
}

