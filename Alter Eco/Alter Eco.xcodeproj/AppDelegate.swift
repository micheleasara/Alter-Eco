import UIKit
import CoreLocation
import MapKit
import CoreData

// defines the average speed of the tube in London in kmph
public let AVERAGE_TUBE_SPEED:Double = 33
// define radius of search for stations
public let STATION_REQUEST_RADIUS:Double = 150
// define max number of measurements stored in memory at a time before trying to estimate an activity
public let MAX_MEASUREMENTS = 1000
// define how many measurements in a row must be different from the root measurement before an activity is estimated
public let CHANGE_ACTIVITY_THRESHOLD:Int = 2
// idle time (in seconds) after which the activity estimator should forget the user was in a station
public let STATION_TIMEOUT:Double = 90*60
// natural language query for train and tube stations nearby
public let QUERY_TRAIN_STATIONS:String = "underground tube station train subway"
// defines how many meters to request a gps update
public let GPS_UPDATE_DISTANCE_THRESHOLD:Double = 50
// define tolerance value in meters for gps updates
public let GPS_UPDATE_DISTANCE_TOLERANCE:Double = 5
// define minimum confidence for valid location updates
public let GPS_UPDATE_CONFIDENCE_THRESHOLD:Double = 50

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    // requests gps updates
    internal let manager = CLLocationManager()
    // estimates activities based on given information (such as location updates)
    internal let activityEstimator = ActivityEstimator(numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, maxMeasurements: MAX_MEASUREMENTS, inStationRadius: GPS_UPDATE_CONFIDENCE_THRESHOLD, stationTimeout: STATION_TIMEOUT)
    // location of last request for stations nearby, to be used with station request radius
    internal var locationUponRequest: CLLocation? = nil
    
    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // following code is to find path to coredata sqlite file
        // let container = NSPersistentContainer(name: "Database")
        // print(container.persistentStoreDescriptions.first!.url)
                
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.distanceFilter = GPS_UPDATE_DISTANCE_THRESHOLD
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.startUpdatingLocation()
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        
        if (locationUponRequest == nil || locationUponRequest!.distance(from: location).rounded() >= STATION_REQUEST_RADIUS) {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = QUERY_TRAIN_STATIONS
            request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: STATION_REQUEST_RADIUS, longitudinalMeters: STATION_REQUEST_RADIUS)
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])
            
            MKLocalSearch(request: request).start { (response, error) in
                if let response = response {
                    self.activityEstimator.stations = response.mapItems
                    self.activityEstimator.processLocation(location)
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

}
