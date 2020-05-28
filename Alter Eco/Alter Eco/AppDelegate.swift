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
    // monitors the wifi network status to pause and resume tracking
    internal var wifiMonitor = WifiStatusMonitor()
    internal var showWifiNotification: Bool!
    
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
        registerForBackgroundTasks()
                
        // following code is to find path to coredata sqlite file
        // let container = NSPersistentContainer(name: "Database2.0")
        // print(container.persistentStoreDescriptions.first!.url)
                
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.distanceFilter = GPS_UPDATE_DISTANCE_THRESHOLD
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.startUpdatingLocation()
        
        self.wifiMonitor.monitor.pathUpdateHandler = respondToWifiChange(path:)
        wifiMonitor.startMonitoring()
        scheduleBGTwifi()
        
        return true
    }
    
    
      // MARK: - Functions to register Background Tasks
      func registerForBackgroundTasks() {
          BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.altereco.wifi",
                                          using: DispatchQueue.global()) { task in
              self.handleBGTwifi(task: task as! BGAppRefreshTask)
          }
      }
      
      func scheduleBGTwifi() {
        // cancel previous wifi requests to avoid error code 2
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "com.altereco.wifi")
        let request = BGAppRefreshTaskRequest(identifier: "com.altereco.wifi")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1)
          
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Successfully scheduled wifi app refresh")
        } catch {
            print("Could not schedule wifi app refresh: \(error)")
        }
      }
      
      func handleBGTwifi(task: BGAppRefreshTask) {
          let queue = OperationQueue()
          queue.maxConcurrentOperationCount = 1
          queue.addOperation {self.wifiMonitor.startMonitoring()}
          task.expirationHandler = {
              self.wifiMonitor.stopMonitoring()
              queue.cancelAllOperations()
          }
        
          // set the task as completed when the operation queue is empty
          let lastOperation = queue.operations.last
          lastOperation?.completionBlock = {
              task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
          }
        
          // schedule another background task:
          scheduleBGTwifi()
      }

    // MARK: - Functions to respond to a changes in network status
    /// Responds to a change in wifi connection by turning on/off location tracking and notifies the user appropriately
    func respondToWifiChange(path: NWPath) {
        if path.status == .satisfied {
              // no wifi to wifi:
              if !self.wifiMonitor.isConnected {
                  self.manager.stopUpdatingLocation()
                  self.registerWifiNotification()
              }
              self.wifiMonitor.isConnected = true
          } else {
              // wifi to no wifi:
              if self.wifiMonitor.isConnected {
                  self.manager.startUpdatingLocation()
              }
              self.wifiMonitor.isConnected = false
          }
      }
      
      /// Registers a notification that tells the user that device has connected to WiFi and tracking has been paused
      private func registerWifiNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Detected WiFi - Tracking paused"
        content.body = "We care about your battery life. Tracking will resume once you disconnect."
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (1), repeats: false)
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        // Register Request
        UNUserNotificationCenter.current().add(request)
      }
      
    // MARK: - Notifications
    func isWifiNotificationEnabled() -> Bool {
        let queryResult = (try! DBMS.executeQuery(entity: "Notification", predicate: nil, args: nil)) as! [NSManagedObject]

        if queryResult.count > 0 {
            return queryResult[0].value(forKey: "showWifi") as! Bool
        } else {
            
        }
        
        return true
    }
    
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
