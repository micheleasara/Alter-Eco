import UIKit
import SwiftUI
import CoreLocation
import MapKit
import Network

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {
    // graphical object, do not touch if not necessary
    var window: UIWindow?
    var screenMeasurements = ScreenMeasurements()
    
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
        
            self.screenMeasurements.broadcastedHeight =  Float(UIScreen.main.bounds.height)
            self.screenMeasurements.broadcastedWidth =  Float(UIScreen.main.bounds.width)
            window.rootViewController = UIHostingController(rootView: contentView.environmentObject(screenMeasurements).environmentObject(dataGraph))
            
            window.makeKeyAndVisible()
        
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.manager.startUpdatingLocation()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}
