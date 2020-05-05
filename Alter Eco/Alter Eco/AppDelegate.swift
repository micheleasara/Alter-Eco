import UIKit
import CoreLocation
import MapKit
import CoreData
import BackgroundTasks
import Network

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
    // monitors changes to wifi status
    internal let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    
    class WifiStatus: ObservableObject {
        @Published var isConnected: Bool = false
    }
    
    internal var wifiStatus = WifiStatus()
    
    #if NO_BACKEND_TESTING
    // called when something is written to the database, used to update the graph
    func activityWasWrittenToDB(activity: MeasuredActivity) {
        print("activity \(activity.motionType) of distance \(activity.distance)m",
            " was written with start \(activity.start) and end \(activity.end)")
        dataGraph.update()
    }
    
    var scene = SceneDelegate()
    #endif
    
    override init() {
        super.init()
        self.DBMS = CoreDataManager(persistentContainer: persistentContainer)
        
        #if NO_BACKEND_TESTING
        self.DBMS.setActivityWrittenCallback(callback: activityWasWrittenToDB(activity:))
        #endif
        
        let activityList = WeightedActivityList(activityWeights: ACTIVITY_WEIGHTS_DICT, DBMS: DBMS)
        activityEstimator = ActivityEstimator<WeightedActivityList>(activityList: activityList, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, timers: MultiTimer())
    }
    
    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Register for push notifications:
        registerForPushNotifications()
        
        // following code is to find path to coredata sqlite file
        // let container = NSPersistentContainer(name: "Database")
        // print(container.persistentStoreDescriptions.first!.url)
                
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.distanceFilter = GPS_UPDATE_DISTANCE_THRESHOLD
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.startUpdatingLocation()
        // REDUNDENT PLACEDHOLDER COMMENT:
        // Following code is to check whether we should run the replaceScore()
        // function to calculate the user score of the day before, i.e. if we open
        // the app before the background task was called to do this for us.
        // The scheduleBSTscore() functon reschedules the BGTscore task for tomorrow.
        BGTaskScheduler.shared.cancelAllTaskRequests()
        
        self.monitor.pathUpdateHandler = {path in
            self.respondToWifiChange(wifi: path.status == .satisfied)
        }

        // Begin monitoring wifi:
        self.monitor.start(queue: DispatchQueue.global(qos: .background))
        
        
        return true
    }
    
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
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Database2.0")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    // MARK: - Functions to respond to a changes in network status
    /// Responds to a change in wifi connection by turning on/off location tracking and notifies the user appropriately
    func respondToWifiChange(wifi: Bool) {
        if wifi {
            // Check if we're in background, and whether we've gone from no wifi to wifi:
            if !self.wifiStatus.isConnected {
                // Toggle the isConnected boolean to true:
                self.wifiStatus.isConnected = true
                // Stop updating the location
                self.manager.stopUpdatingLocation()
                // Send wifi notification to user:
                self.registerWifiNotification()
                
            }
        } else {
            // Check if we're in background, and whether we've gone from wifi to no wifi:
            if self.wifiStatus.isConnected {
                // Toggle the isConnected boolean to false:
                self.wifiStatus.isConnected = false
                // Resume updating the location
                self.manager.startUpdatingLocation()
                // Send no wifi notification to user:
                self.registerNoWifiNotification()
            }
        }
    }
    
    /// Registers a notification that tells the user that device has connected to WiFi and tracking has been paused
    private func registerWifiNotification() {
        // Make Content
        let content = UNMutableNotificationContent()
        content.title = "Detected Wifi"
        content.body = "Tracking paused - We care about your battery life."
        // Set up Trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (1), repeats: false)
        // Create UID
        let uuid = UUID().uuidString
        // Set up Request
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        // Register Request
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Registers a notification that tells the user that WifFi has connected to WiFi and tracking has resumed
    private func registerNoWifiNotification() {
        // Make Content
        let content = UNMutableNotificationContent()
        content.title = "Wifi Disconnected"
        content.body = "Tracking resumed - Let's hit the road!"
        // Set up Trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (1), repeats: false)
        // Create UID
        let uuid = UUID().uuidString
        // Set up Request
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        // Register Request
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Functions to register for notifications
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
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }

}
