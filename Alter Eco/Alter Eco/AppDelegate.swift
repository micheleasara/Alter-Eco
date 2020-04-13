import UIKit
import CoreLocation
import MapKit
import CoreData
import BackgroundTasks

// define the average speed of the tube in London as 33 kmph converted to 9.16667 m/s
public let AVERAGE_TUBE_SPEED:Double = 33
// define average plane speed as (740 - 930) kmph converted to 222 m/s
public let AVERAGE_PLANE_SPEED:Double = 222
// define radius of search for stations
public let STATION_REQUEST_RADIUS:Double = 150
// define radius of search for airports
public let AIRPORTS_REQUEST_RADIUS:Double = 2500
// define average radius of airport m
public let MAX_DISTANCE_WITHIN_AIRPORT:Double = 1000
// define how many measurements in a row must be different from the root measurement before an activity is estimated
public let CHANGE_ACTIVITY_THRESHOLD:Int = 2
// used for plane motion type, determines how many measurements of type car needed before resetting airport flag
public let CAR_NUM_FOR_PLANE_FLAG_OFF:Int = 10
// used for tube motion type, determines how many measurements of type walking needed before resetting train flag
public let WALK_NUM_FOR_TRAIN_FLAG_OFF:Int = 3
// idle time (in seconds) after which the activity estimator should forget the user was in a station
public let STATION_TIMEOUT:Double = 90*60
// idle time (in seconds) after which the activity estimator should forget the user was in an airport
public let AIRPORT_TIMEOUT:Double = 60*60*24
// natural language query for train and tube stations nearby
public let QUERY_TRAIN_STATIONS:String = "underground train subway tube station"
// natural language query for airports nearby
public let QUERY_AIRPORTS: String = "airport"
// defines how many meters to request a gps update
public let GPS_UPDATE_DISTANCE_THRESHOLD:Double = 50
// define tolerance value in meters for gps updates
public let GPS_UPDATE_DISTANCE_TOLERANCE:Double = 5
// define minimum confidence for valid location updates
public let GPS_UPDATE_CONFIDENCE_THRESHOLD:Double = 50
// define area near airport still considered as an airport location - Paris airport 5kmx3km
// tradeoff between wanting to detect all the airport and the time of take off (2h assumed here).
public let GPS_UPDATE_AIRPORT_THRESHOLD:Double = 4000
public let ACTIVITY_WEIGHTS_DICT: [MeasuredActivity.MotionType: Int] = [.car: 2, .walking: 1]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    // Instantiate the scene
    let scene = SceneDelegate()
    // requests gps updates
    internal let manager = CLLocationManager()
    // interfaces with the database
    internal var DBMS : DBManager!
    // estimates activities based on given information (such as location updates)
    internal var activityEstimator : ActivityEstimator<WeightedActivityList>!
    
    override init() {
        super.init()
        DBMS = CoreDataManager(persistentContainer: persistentContainer)
        let activityList = WeightedActivityList(activityWeights: ACTIVITY_WEIGHTS_DICT, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, DBMS: DBMS)
        
        activityEstimator = ActivityEstimator<WeightedActivityList>(activityList: activityList, inStationRadius: GPS_UPDATE_CONFIDENCE_THRESHOLD, stationTimeout: STATION_TIMEOUT, airportTimeout: AIRPORT_TIMEOUT)
    }
    // location of last request for stations nearby, to be used with station request radius
    internal var locationUponRequest: CLLocation? = nil
    
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

    
    
    // MARK: - Core Data Saving support
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
