import UIKit
import SwiftUI
import CoreLocation
import MapKit
import Network

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {
    // graphical object, do not touch if not necessary
    var window: UIWindow?
    var screenMeasurements = ScreenMeasurements()
    
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    
    class WifiStatus: ObservableObject {
        @Published var isConnected: Bool = false
    }
    
    var wifistatus = WifiStatus()
    
    func registerWifiNotification() {
        // Make Content
        let content = UNMutableNotificationContent()
        content.title = "Detected Wifi"
        content.body = "Paused tracking, tap to resume."
        // Set up Trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (2), repeats: false)
        // Create UID
        let uuid = UUID().uuidString
        // Set up Request
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        // Register Request
        UNUserNotificationCenter.current().add(request)
    }
    
    func registerNoWifiNotification() {
        // Make Content
        let content = UNMutableNotificationContent()
        content.title = "Wifi Disconnected"
        content.body = "Tracking resumed, tap to pause."
        // Set up Trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (2), repeats: false)
        // Create UID
        let uuid = UUID().uuidString
        // Set up Request
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        // Register Request
        UNUserNotificationCenter.current().add(request)
    }
    
    func checkWifi(background_task: Bool = false) {
        print("In checkWifi")
        
        monitor.pathUpdateHandler = {path in
            if path.status == .satisfied {
                print("We're on WiFi")
                // Check if we're in background, and whether we've gone from no wifi to wifi:
                if !self.wifistatus.isConnected {
                    print("Previously mobile")
                    // Toggle the isConnected boolean to true:
                    DispatchQueue.main.async {
                        self.wifistatus.isConnected = true
                        print("Toggled status to true")
                    }
                    // Register the relevant notification
                    if background_task {
                        print("Sending wifi notification")
                        self.registerWifiNotification()
                    }
                }
            } else {
                print("We're on mobile.")
                // Check if we're in background, and whether we've gone from wifi to no wifi:
                if self.wifistatus.isConnected {
                    print("Previously WiFi")
                    // Toggle the isConnected boolean to false:
                    DispatchQueue.main.async {
                        self.wifistatus.isConnected = false
                        print("Toggled status to false")
                    }
                    // Register the relevant notification
                    if background_task {
                        print("Sending NO wifi notification")
                        self.registerNoWifiNotification()
                    }
                }
            }
        }
        
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Create the SwiftUI view that provides the window contents.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contentView = ContentView().environment(\.managedObjectContext, context)       
        _ = DetailView().environment(\.managedObjectContext, context)


        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            
            // Begin monitoring wifi status:
            checkWifi(background_task: false)
            
            // set trackingData as environment object to allow access within contentView
            let estimator = (UIApplication.shared.delegate as! AppDelegate).activityEstimator
            window.rootViewController = UIHostingController(rootView: contentView.environmentObject(estimator.trackingData))
            
            window.makeKeyAndVisible()
            
            self.screenMeasurements.broadcastedHeight =  Float(UIScreen.main.bounds.height)
            self.screenMeasurements.broadcastedWidth =  Float(UIScreen.main.bounds.width)
            window.rootViewController = UIHostingController(rootView: contentView.environmentObject(screenMeasurements))
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        // This method schedules the wifi background task:
        (UIApplication.shared.delegate as! AppDelegate).scheduleBGTwifi()
    }

}
