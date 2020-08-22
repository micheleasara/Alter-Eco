import UIKit
import SwiftUI
import CoreLocation
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    var screenMeasurements = ScreenMeasurements()
    /// The timestamp of the last chart/data refresh. Used to avoid unnecessary queries.
    var lastRefresh = Date()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let DBMS = appDelegate.DBMS as! CoreDataManager
        let context = DBMS.persistentContainer.viewContext
        let contentView = ContentView().environment(\.managedObjectContext, context)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            // update charts and set smog effect
            let transportBarChartModel = TransportBarChartViewModel(limit: Date(), DBMS: DBMS)
            let transportPieChartModel = TransportPieChartViewModel(DBMS: DBMS)
            let foodPieChartModel = FoodPieChartViewModel(DBMS: DBMS)
            let gameViewModel = GameViewModel(DBMS: DBMS)
            DBMS.addNewPollutingItemCallback { type in
                let now = Date()

                if type == .transportActivity {
                    transportBarChartModel.updateUpTo(now)
                    transportPieChartModel.updateUpTo(now)
                } else {
                    foodPieChartModel.updateUpTo(now)
                }
                gameViewModel.refreshSmogState()
                
                self.lastRefresh = now.toLocalTime()
            }
            
            // set environment objects and hosting controller
            window.rootViewController = UIHostingController(rootView: contentView
                .environmentObject(screenMeasurements)
                .environmentObject(transportBarChartModel)
                .environmentObject(TransportAwardsManager(DBMS: DBMS))
                .environmentObject(FoodAwardsManager(DBMS: DBMS))
                .environmentObject(transportPieChartModel)
                .environmentObject(foodPieChartModel)
                .environmentObject(FoodListViewModel(converter: FoodToCarbonManager(), uploader: OpenFoodFacts(), DBMS: DBMS))
                .environmentObject(gameViewModel))
            
            self.window = window
            window.makeKeyAndVisible()
            
            setupDailyRefresh(usingBlock: {
                let now = Date()
                let nowLocalTime = now.toLocalTime()
                // avoid unnecessary refreshes
                if self.lastRefresh.getDayName() != nowLocalTime.getDayName() {
                    transportBarChartModel.updateUpTo(now)
                    transportPieChartModel.updateUpTo(now)
                    foodPieChartModel.updateUpTo(now)
                    gameViewModel.refreshSmogState()
                    self.lastRefresh = nowLocalTime
                }
            })
        }
    }
    
    func setupDailyRefresh(usingBlock refreshBlock: @escaping () -> Void) {
        // get interval from now to tomorrow at its first hour
        let calendar = Calendar(identifier: .gregorian)
        let now = Date().toLocalTime()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(DAY_IN_SECONDS)
        let tomorrowStart = calendar.startOfDay(for: tomorrow)
        let interval = tomorrowStart.timeIntervalSince(now)
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            self.setupDailyRefresh(usingBlock: refreshBlock)
            refreshBlock()
        })
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
