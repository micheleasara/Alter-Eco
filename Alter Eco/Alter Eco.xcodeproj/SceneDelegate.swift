import UIKit
import SwiftUI
import CoreLocation
import MapKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {
    // graphical object, do not touch if not necessary
    var window: UIWindow?
    var screenMeasurements = ScreenMeasurements()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Create the SwiftUI view that provides the window contents.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contentView = ContentView().environment(\.managedObjectContext, context)       
        let detailView = DetailView().environment(\.managedObjectContext, context)


        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            
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
    }

}
