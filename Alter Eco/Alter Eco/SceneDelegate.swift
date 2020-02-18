//
//  SceneDelegate.swift
//  tracker
//
//  Created by Maxime Redstone on 12/02/2020.
//  Copyright © 2020 Maxime Redstone. All rights reserved.
//

import UIKit
import SwiftUI
import CoreLocation
import MapKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {
    // define threshold to identify an automotive type of motion
    // 4.5m/s is roughly 16km/h
    let AUTOMOTIVE_SPEED_THRESHOLD:Double = 4.5
    // defines how many meters to request a gps update
    let GPS_UPDATE_DISTANCE_THRESHOLD:Double = 50
    // define tolerance value in meters for gps updates
    let GPS_UPDATE_DISTANCE_TOLERANCE:Double = 5
    // define minimum confidence for valid location updates
    let GPS_UPDATE_CONFIDENCE_THRESHOLD:Double = 50
    // define max number of measurements stored in array
    let MAX_MEASUREMENTS = 101
    
    let manager = CLLocationManager()
    // contains location from previous valid update
    var previousLoc: CLLocation? = nil
    // shared among views
    var trackingData = TrackingData()
    
    // CREATE ARRAY EVENT LIST
    var measurements = [MeasurementObject]()
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        // ensure location is accurate enough
        let location = locations.last!
        guard location.horizontalAccuracy <= GPS_UPDATE_CONFIDENCE_THRESHOLD else {return}
        
        
        
        if let previousLocUnwrapped = previousLoc {
            // ensure update happened after roughly GPS_UPDATE_THRESHOLD meters (within tolerance value)
            let distance = location.distance(from: previousLocUnwrapped).rounded()
            guard distance + GPS_UPDATE_DISTANCE_TOLERANCE >= GPS_UPDATE_DISTANCE_THRESHOLD else {return}
            // ensure we get no fake instantaneous movements
            let time = location.timestamp.timeIntervalSince(previousLocUnwrapped.timestamp).rounded()
            guard time > 0 else {return}
            
            // IF EVENT LIST NOT FULL AND EVENT NOT CHANGED:
                // Create measurement and add to Event list
                trackingData.time = time
                // ADD START
                // ADD TIME END
                trackingData.distance = distance
                trackingData.speed = trackingData.distance/trackingData.time
                trackingData.transportMode = trackingData.speed >= AUTOMOTIVE_SPEED_THRESHOLD ? "Automotive":"Not automotive"
                
                // check for underground station
                // TODO: A better approach perhaps would be the following, by monitoring regions around stations
                // https://stackoverflow.com/questions/52350209/see-if-the-user-is-near-a-location-swift-4
                // setUndergroundStation(aroundLocation: location)
            
            // ELSE IF EVENT CHANGED:
                // PUT LAST TWO MEASUREMENTS INTO NEW LIST THEN DISCARD THEM
                // COMPUTE DURATION OF EVENT, STORE IN DB, FLUSH ARRAY EVENT LIST
            
            // ELSE IF FULL:
                // COMPUTE DURATION OF EVENT, STORE IN DB, FLUSH ARRAY EVENT LIST

        }

        previousLoc = location
     }
    
    func isFull(measurements:[MeasurementObject]) -> Bool {
        return measurements.count >= MAX_MEASUREMENTS
    }
    
    func hasEventChanged(measurements:[MeasurementObject]) -> Bool {
        if measurements.count < 3 {return false}
        
        let rootType = measurements[0].motionType
        let lastType = measurements.last!.motionType
        let secondLastType = measurements[measurements.count-2].motionType
        
        return lastType == secondLastType && lastType != rootType
    }
    
    func setUndergroundStation(aroundLocation location:CLLocation){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "underground station"
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])
        
        MKLocalSearch(request: request).start { (response, error) in
            var station = "Not in a tube station"
            if let response = response {
                for result in response.mapItems {
                    // user is in a station if distance from current position is less or equal to threshold
                    let distance = location.distance(from: CLLocation(latitude: result.placemark.coordinate.latitude, longitude: result.placemark.coordinate.longitude))
                    if (distance <= self.GPS_UPDATE_CONFIDENCE_THRESHOLD){
                        station = result.name!
                    }
                }
            }
            self.trackingData.station = station
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            
            manager.requestAlwaysAuthorization()
            manager.delegate = self
            manager.distanceFilter = 50
            manager.desiredAccuracy = kCLLocationAccuracyBest
            
            window.rootViewController = UIHostingController(rootView: ContentView().environmentObject(trackingData))
            manager.startUpdatingLocation()
            
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

