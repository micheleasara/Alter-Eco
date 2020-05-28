import UIKit
import CoreLocation
import MapKit
import CoreData

/// Database handler shared across the application
let DBMS : DBManager = (UIApplication.shared.delegate as! AppDelegate).DBMS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    // requests gps updates
    internal let manager = CLLocationManager()
    // interfaces with the database
    public var DBMS : DBManager!
    // estimates activities based on given information (such as location updates)
    internal var activityEstimator : ActivityEstimator<WeightedActivityList>!
    // location of last request for stations nearby, to be used with station request radius
    internal var locationUponRequest: CLLocation? = nil
    internal let notificationUUID = UUID().uuidString
    internal var userPausedTracking: Bool = false
    
    #if NO_BACKEND_TESTING
    // called when something is written to the database, used to update the graph
    func activityWasWrittenToDB(activity: MeasuredActivity) {
        print("activity \(activity.motionType) of distance \(activity.distance)m",
            " was written with start \(activity.start) and end \(activity.end)")
        graphModel.getDataUpTo(Date())
    }
    
    /// Contains data for the graph of GraphView.
    internal var graphModel : GraphDataModel!
    
    var scene = SceneDelegate()
    #endif
    
    override init() {
        super.init()
        self.DBMS = CoreDataManager(persistentContainer: persistentContainer)
        
        #if NO_BACKEND_TESTING
        self.DBMS.setActivityWrittenCallback(callback: activityWasWrittenToDB(activity:))
        graphModel = GraphDataModel(limit: Date(), DBMS: self.DBMS)
        #endif
                
        let activityList = WeightedActivityList(activityWeights: ACTIVITY_WEIGHTS_DICT)
        activityEstimator = ActivityEstimator<WeightedActivityList>(activityList: activityList, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, timers: MultiTimer(), DBMS: DBMS)
    }
    
    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerForPushNotifications()
                
        // following code is to find path to coredata sqlite file
        // let container = NSPersistentContainer(name: "Database2.0")
        // print(container.persistentStoreDescriptions.first!.url)
                
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.distanceFilter = GPS_UPDATE_DISTANCE_THRESHOLD
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .automotiveNavigation
        manager.startUpdatingLocation()
                
        return true
    }
      
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        let content = UNMutableNotificationContent()
        content.title = "Looks like you have not moved in a while"
        content.body = "We care about your battery life. Open Alter Eco to resume tracking."
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (1), repeats: false)
        let request = UNNotificationRequest(identifier: notificationUUID, content: content, trigger: trigger)

        // Register Request
        UNUserNotificationCenter.current().add(request)
    }
      
    // MARK: - Notifications
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound, .badge]) {
            [weak self] granted, error in
      
            guard granted else { return }
            self?.getNotificationSettings()
        }
      }
      
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        }
    }
    
    // MARK:- Location tracking and MapKit requests
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        
        if (locationUponRequest == nil || locationUponRequest!.distance(from: location).rounded() >= STATION_REQUEST_RADIUS) {
               
               let requestStations = MKLocalSearch.Request()
               requestStations.naturalLanguageQuery = QUERY_TRAIN_STATIONS
               requestStations.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: STATION_REQUEST_RADIUS, longitudinalMeters: STATION_REQUEST_RADIUS)
               requestStations.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])
            
               // inception: closure at the end of first query executes a second query
               MKLocalSearch(request: requestStations).start { (response, error) in
                   if let response = response {
                       self.activityEstimator.stations = response.mapItems
                       self.activityEstimator.processLocation(location)
                   }
                    
                    // second query for airports
                    let requestAirports = MKLocalSearch.Request()
                    requestAirports.naturalLanguageQuery = QUERY_AIRPORTS
                    requestAirports.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: AIRPORTS_REQUEST_RADIUS, longitudinalMeters: AIRPORTS_REQUEST_RADIUS)
                    requestAirports.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport])

                    MKLocalSearch(request: requestAirports).start { (response, error) in
                        if let response = response {
                            self.activityEstimator.airports = response.mapItems
                            self.activityEstimator.processLocation(location)
                        }
                    }
               }
               
               locationUponRequest = location
           }
           
           else {
               activityEstimator.processLocation(location)
           }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while retrieving location: ", error.localizedDescription)
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
                fatalError("An error occurred: \(error)")
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
