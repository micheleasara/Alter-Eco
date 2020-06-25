import UIKit
import SwiftUI
import CoreLocation
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    var screenMeasurements = ScreenMeasurements()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = (DBMS as! CoreDataManager).persistentContainer.viewContext
            //appDelegate.persistentContainer.viewContext
        let contentView = ContentView().environment(\.managedObjectContext, context)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            
            window.rootViewController = UIHostingController(rootView: contentView
                .environmentObject(screenMeasurements)
                .environmentObject(appDelegate.chartModel)
                .environmentObject(TransportAwardsManager(DBMS: DBMS))
                .environmentObject(FoodAwardsManager(DBMS: DBMS))
                .environmentObject(TransportPieChartModel(DBMS: DBMS)))
            
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // remove reminders for paused tracking
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // resume tracking unless user does not want to or it is first launch
            if !appDelegate.isFirstLaunch.rawValue && !appDelegate.isTrackingPaused.rawValue {
                appDelegate.startLocationTracking()
            }
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.isTrackingPaused.rawValue {
                appDelegate.inactivityAndPausedNotification()
            }
        }
    }
}
