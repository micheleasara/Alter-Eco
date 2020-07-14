import UIKit
import SwiftUI
import CoreLocation
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    var screenMeasurements = ScreenMeasurements()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let DBMS = appDelegate.DBMS as! CoreDataManager
        let context = DBMS.persistentContainer.viewContext
        let contentView = ContentView().environment(\.managedObjectContext, context)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let transportBarChartModel = TransportBarChartModel(limit: Date().toLocalTime(), DBMS: DBMS)
            let transportPieChartModel = TransportPieChartModel(DBMS: DBMS)
            let foodPieChartModel = FoodPieChartModel(DBMS: DBMS)
            DBMS.addActivityWrittenCallback { _ in
                let now = Date().toLocalTime()
                transportBarChartModel.updateUpTo(now)
                transportPieChartModel.updateUpTo(now)
            }
            DBMS.addFoodsWrittenCallback { _ in
                print("Added foods to the database")
                foodPieChartModel.updateUpTo(Date().toLocalTime())
            }
            
            window.rootViewController = UIHostingController(rootView: contentView
                .environmentObject(screenMeasurements)
                .environmentObject(transportBarChartModel)
                .environmentObject(TransportAwardsManager(DBMS: DBMS))
                .environmentObject(FoodAwardsManager(DBMS: DBMS))
                .environmentObject(transportPieChartModel)
                .environmentObject(foodPieChartModel)
                .environmentObject(FoodListViewModel(DBMS: DBMS)))
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    // called when something is written to the database, used to update the graph
    func activityWasWrittenToDB(activity: MeasuredActivity) {
        print("activity \(activity.motionType) of distance \(activity.distance)m",
            " was written with start \(activity.start) and end \(activity.end)")
        
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
