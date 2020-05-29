import UIKit
import SwiftUI
import CoreLocation
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    var screenMeasurements = ScreenMeasurements()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let contentView = ContentView().environment(\.managedObjectContext, context)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            
            window.rootViewController = UIHostingController(rootView: contentView
                .environmentObject(screenMeasurements)
                .environmentObject(appDelegate.graphModel))
            
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // remove reminders for paused tracking
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // resume tracking unless user does not want to or it is first launch
            if !appDelegate.isFirstLaunch && !appDelegate.userPausedTracking {
                appDelegate.startLocationTracking()
            }
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.userPausedTracking {
                appDelegate.inactivityAndPausedNotification()
            }
        }
    }
}
