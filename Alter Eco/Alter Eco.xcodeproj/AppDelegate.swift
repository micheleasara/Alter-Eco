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
// define radius of search for station
public let AIRPORTS_REQUEST_RADIUS:Double = 2500
// define average radius of airport m
public let MAX_DISTANCE_WITHIN_AIRPORT:Double = 1000
// define max number of measurements stored in memory at a time before trying to estimate an activity
public let MAX_MEASUREMENTS = 1000
// define how many measurements in a row must be different from the root measurement before an activity is estimated
public let CHANGE_ACTIVITY_THRESHOLD:Int = 2
// used for plane motion type, scales how many measurements of type car needed before resetting airport flag
public let CAR_SCALING:Int = 10
// used for tube motion type, scales how many measurements of type walking needed before resetting tube flag
public let WALK_SCALING:Int = 1
// idle time (in seconds) after which the activity estimator should forget the user was in a station
public let STATION_TIMEOUT:Double = 90*60
// idle time (in seconds) after which the activity estimator should forget the user was in an airport
public let AIRPORT_TIMEOUT:Double = 60*60*24
// natural language query for train and tube stations nearby
public let QUERY_TRAIN_STATIONS:String = "underground tube station train subway"
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
// define two hours waiting time at airport not to be considered as flying time (i.e. better distance estimation)
public let TWO_HOURS_AIRPORT_WAITING_TIME: Double = 60*60*2

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    // Time at which the background task will be scheduled MAKE THIS 1 minute past 00:00!!!!!!!!
    var showtime: Date {
        return Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: self)!
    }
    // Time at which to check whether it's time to calculate (NOT USED)
    var checktime: Date {
        return Calendar.current.date(bySettingHour: 11, minute: 30, second: 0, of: self)!
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    // Instantiate the scene
    let scene = SceneDelegate()
    // requests gps updates
    internal let manager = CLLocationManager()
    // estimates activities based on given information (such as location updates)
    internal let activityEstimator = ActivityEstimator(numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, maxMeasurements: MAX_MEASUREMENTS, inStationRadius: GPS_UPDATE_CONFIDENCE_THRESHOLD, stationTimeout: STATION_TIMEOUT, airportTimeout: AIRPORT_TIMEOUT)
    
    // location of last request for stations nearby, to be used with station request radius
    internal var locationUponRequest: CLLocation? = nil
    
    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Register for push notifications:
        registerForPushNotifications()
        // Register for background tasks:
        registerForBackgroundTasks()
        
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
               
               MKLocalSearch(request: requestStations).start { (response, error) in
                   if let response = response {
                       self.activityEstimator.stations = response.mapItems
                       self.activityEstimator.processLocation(location)
                   }
                   //print("Stations near me: ", self.activityEstimator.stations)
               }
               
               let requestAirports = MKLocalSearch.Request()
               requestAirports.naturalLanguageQuery = QUERY_AIRPORTS
               requestAirports.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: AIRPORTS_REQUEST_RADIUS, longitudinalMeters: AIRPORTS_REQUEST_RADIUS)
               requestAirports.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport])
               
               MKLocalSearch(request: requestAirports).start { (response, error) in
                   if let response = response {
                       self.activityEstimator.airports = response.mapItems
                       self.activityEstimator.processLocation(location)
                   }
                   //print("Airports near me: ", self.activityEstimator.airports)
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
    
    /*   ---------- START OF BACKGROUND TASK SHIT ----------   */
    
    func registerForBackgroundTasks() {
        //     Register the wifi task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.altereco.wifi",
                                        using: nil)
        { task in
            //This task is cast with processing request (BGAppRefreshTask)
            self.handleBGTwifi(task: task as! BGAppRefreshTask)
        }
        
//        //     Register the score task
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.altereco.score",
//                                        using: nil)
//        { task in
//            //This task is cast with processing request (BGAppRefreshTask)
//            self.handleBGTscore(task: task as! BGProcessingTask)
//        }
        print("Registered the BGTs")

    }
    
    /*----- START OF BACKGROUND WIFI STUFF -------*/
    func scheduleBGTwifi() {
        // Cancel previous wifi requests:
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.altereco.wifi")
        // Set up new wifi request:
        let request = BGAppRefreshTaskRequest(identifier: "com.altereco.wifi")
        // Schedule no earlier than 10 minutes from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1*60)
        
        do {
           try BGTaskScheduler.shared.submit(request)
            print("Successfully scheduled wifi app refresh")
        } catch {
           print("Could not schedule wifi app refresh: \(error)")
        }
    }
    
    func handleBGTwifi(task: BGAppRefreshTask) {
        print("Handling the wifi task")
        // Set up OperationQueue
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        // Establish task
        let appRefreshOperation = scene.checkWifi(background_task: true)
        // Add operation to queue
        queue.addOperation {appRefreshOperation}
        // Set up task expiration handler
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        // Set the task as completed when the operation queue empty:
        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }

        // Schedule another background task:
        scheduleBGTwifi()
    }

    /*----- END OF BACKGROUND WIFI STUFF -------*/
    
    /*----- START OF BACKGROUND SCORE STUFF -------*/
//    func scheduleBGTscore(schedule_date: Date) {
//        // Cancel previous requests score request:
//        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.altereco.score")
//        // Set up new score request:
//        let request = BGAppRefreshTaskRequest(identifier: "com.altereco.score")
//        // Schedule no earlier than schedule_date input supplied
//        request.earliestBeginDate = schedule_date
//
//        do {
//           try BGTaskScheduler.shared.submit(request)
//        } catch {
//           print("Could not schedule score app refresh: \(error)")
//        }
//
//        print("Ended schedule score app refresh")
//    }
//
//    func handleBGTscore(task: BGAppRefreshTask) {
//        print("Handling the score task")
//        let dateString = retrieveLatestScore().date
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        dateFormatter.locale = Locale(identifier: "en-UK")
//        let dateFromString = dateFormatter.date(from: dateString)
//        // Check to see if the last time we calculated the score wasn't today:
//        if !Calendar.current.isDate(dateFromString!, inSameDayAs: Date().dayBefore){
//            // Evaluate score for yesterday:
//            let appRefreshOperation = replaceScore(queryDate: Date().dayBefore)
//            // Set up OperationQueue
//            let queue = OperationQueue()
//            queue.maxConcurrentOperationCount = 1
//            // Add operation to queue
//            queue.addOperation {appRefreshOperation}
//            // Set up task expiration handler
//            task.expirationHandler = {
//                queue.cancelAllOperations()
//            }
//            // Set the task as completed when the operation queue empty:
//            let lastOperation = queue.operations.last
//            lastOperation?.completionBlock = {
//                task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
//            }
//        }
//        // Schedule another background task:
//        scheduleBGTscore(schedule_date: Date().dayAfter.showtime)
//    }
//
    /*----- END OF BACKGROUND SCORE STUFF -------*/
    
    /*   ---------- END OF BACKGROUND TASK SHIT ----------   */
    
    /*----- START OF NOTIFICATION SHIT -------*/
    // Function to register for notifications:
    func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) {
          [weak self] granted, error in
            
          print("Permission granted: \(granted)")
          guard granted else { return }
          self?.getNotificationSettings()
      }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    /*----- END OF NOTIFICATION SHIT -------*/

}
