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
    
    #if NO_BACKEND_TESTING
    // called when something is written to the database, used to update the graph
    func activityWasWrittenToDB(activity: MeasuredActivity) {
        print("activity \(activity.motionType) of distance \(activity.distance)m",
            " was written with start \(activity.start) and end \(activity.end)")
        chartModel.updateUpTo(Date().toLocalTime())
    }
    
    /// Contains data for the chart of ChartView.
    internal var chartModel : ChartDataModel!
    
    var scene = SceneDelegate()
    #endif
    
    override init() {
        super.init()
        self.DBMS = CoreDataManager(persistentContainer: persistentContainer)
        
        #if NO_BACKEND_TESTING
        self.DBMS.setActivityWrittenCallback(callback: activityWasWrittenToDB(activity:))
        chartModel = ChartDataModel(limit: Date().toLocalTime(), DBMS: self.DBMS)
        #endif
                
        let activityList = WeightedActivityList(activityWeights: ACTIVITY_WEIGHTS_DICT)
        activityEstimator = ActivityEstimator<WeightedActivityList>(activityList: activityList, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, timers: MultiTimer(), DBMS: DBMS)
        activityEstimator.setInAirportCallback(callback: userIsInAnAirport(airport:))
        
        isFirstLaunch = Observable<Bool>(rawValue: queryDBForFirstLaunch())
    }
    
    func queryDBForFirstLaunch() -> Bool {
        let query = try! DBMS.executeQuery(entity: "UserPreference",
                                      predicate: nil, args: nil) as! [NSManagedObject]
        if query.count > 0 {
            return (query[0].value(forKey: "firstLaunch") as! Bool)
        }
        // if nothing is in the database, this is the first launch
        return true
    }
    
    // MARK:- Location tracking and MapKit requests
    func startLocationTracking() {
        manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.distanceFilter = GPS_DISTANCE_THRESHOLD
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.pausesLocationUpdatesAutomatically = true
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
        print("User is in an airport")
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
    
    // MARK: - Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Database2.0")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()

    func mockPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Database2.0", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
                                        
            // Check if creating container wrong
            if let error = error {
                print("An error occurred: \(error)")
            }
        }
        return container
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
}

