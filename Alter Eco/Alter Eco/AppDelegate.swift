import UIKit
import CoreLocation
import MapKit
import CoreData

/// Database handler shared across the application
let DBMS : DBManager = (UIApplication.shared.delegate as! AppDelegate).DBMS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    /// Request s gps updates.
    internal let manager = CLLocationManager()
    /// Interfaces with the database.
    public var DBMS: DBManager!
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
    /// Observable representation of whether this is the first time the app is launched.
    internal var isFirstLaunch: Observable<Bool>!
    /// Defines radius of search for airports in meters.
    internal var airportRequestRadius: Double = MAX_AIRPORT_REQUEST_RADIUS
    /// Defines whether the system account for cycling.
    internal var cycleEnabled: Observable<Bool>!
    /// The cycling speed inputted by the user.
    internal var cycleSpeed: Observable<Double>!
    /// Defines whether location tracking can be paused by iOS.
    internal var autoPauseEnabled: Observable<Bool>!
    /// Contains data for the chart of ChartView.
    internal var transportBarChartModel : ChartDataModel!
    
    var scene = SceneDelegate()
    
    override init() {
        super.init()
        self.DBMS = CoreDataManager()
        
        self.DBMS.addActivityWrittenCallback(callback: activityWasWrittenToDB(activity:))
        transportBarChartModel = ChartDataModel(limit: Date().toLocalTime(), DBMS: self.DBMS)
                
        let activityList = WeightedActivityList(activityWeights: ACTIVITY_WEIGHTS_DICT)
        activityEstimator = ActivityEstimator<WeightedActivityList>(activityList: activityList, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, timers: MultiTimer(), DBMS: DBMS)
        activityEstimator.setInAirportCallback(callback: userIsInAnAirport(airport:))
        
        loadUserSettings()
        autoPauseEnabled.setValueChangeCallback {(newValue) in
            self.manager.pausesLocationUpdatesAutomatically = newValue}
    }
    
    // called when something is written to the database, used to update the graph
    func activityWasWrittenToDB(activity: MeasuredActivity) {
        print("activity \(activity.motionType) of distance \(activity.distance)m",
            " was written with start \(activity.start) and end \(activity.end)")
        transportBarChartModel.updateUpTo(Date().toLocalTime())
    }
    
    func loadUserSettings() {
        let query = try? DBMS.executeQuery(entity: "UserPreference",
                                      predicate: nil, args: nil) as? [NSManagedObject]
        if query != nil && query!.count > 0 {
            isFirstLaunch = Observable(rawValue: (query![0].value(forKey: "firstLaunch") as? Bool) ?? true)
            cycleEnabled = Observable(rawValue: (query![0].value(forKey: "cycleEnabled") as? Bool) ?? false)
            cycleSpeed = Observable(rawValue: (query![0].value(forKey: "cycleRelaxation") as? Double) ?? DEFAULT_CYCLE_SPEED)
            autoPauseEnabled = Observable(rawValue: (query![0].value(forKey: "autoPauseEnabled") as? Bool) ?? true)
            // needed for backward compatibility
            if cycleSpeed.rawValue < AUTOMOTIVE_SPEED_THRESHOLD {
                cycleSpeed.rawValue = DEFAULT_CYCLE_SPEED
            }
        } else {
            // if nothing is in the database, this is the first launch
            isFirstLaunch = Observable(rawValue: true)
            cycleEnabled = Observable(rawValue: false)
            cycleSpeed = Observable(rawValue: DEFAULT_CYCLE_SPEED)
            autoPauseEnabled = Observable(rawValue: true)
        }
    }
    
    // MARK:- Location tracking and MapKit requests
    func startLocationTracking() {
        manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.distanceFilter = GPS_DISTANCE_THRESHOLD
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.pausesLocationUpdatesAutomatically = autoPauseEnabled.rawValue
        manager.activityType = .automotiveNavigation
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        let content = UNMutableNotificationContent()
        content.title = "Looks like you have not moved in a while"
        content.body = "Tracking paused: we care about your battery life. Open Alter Eco to resume."
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

