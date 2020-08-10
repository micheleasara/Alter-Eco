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

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            let transportBarChartModel = TransportBarChartViewModel(limit: Date(), DBMS: DBMS)
            let transportPieChartModel = TransportPieChartViewModel(DBMS: DBMS)
            let foodPieChartModel = FoodPieChartViewModel(DBMS: DBMS)
            let gameViewModel = GameViewModel(DBMS: DBMS)
            // update charts and set smog effect
            DBMS.addNewPollutingItemCallback { type in
                let now = Date()

                if type == .transportActivity {
                    transportBarChartModel.updateUpTo(now)
                    transportPieChartModel.updateUpTo(now)
                } else {
                    foodPieChartModel.updateUpTo(now)
                }
                gameViewModel.refreshSmogState()
            }
            
            window.rootViewController = UIHostingController(rootView: contentView
                .environmentObject(screenMeasurements)
                .environmentObject(transportBarChartModel)
                .environmentObject(TransportAwardsManager(DBMS: DBMS))
                .environmentObject(FoodAwardsManager(DBMS: DBMS))
                .environmentObject(transportPieChartModel)
                .environmentObject(foodPieChartModel)
                .environmentObject(FoodListViewModel(DBMS: DBMS))
                .environmentObject(gameViewModel))
            
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
            if UserDefaults.standard.bool(forKey: "skipIntroduction") && !appDelegate.isTrackingPaused.rawValue {
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
