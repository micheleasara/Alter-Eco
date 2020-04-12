////
////  AppDelegateTest.swift
////  TrackingTest
////
////  Created by Deli De leon de miguel on 06/03/2020.
////  Copyright © 2020 Imperial College London. All rights reserved.
////
//
//import XCTest
//import CoreLocation
//import MapKit
//@testable import Alter_Eco
//class AppDelegateTest: XCTestCase {
//
//    let app = AppDelegate()
//    
//    func testRequestNewStationsIfHasntBeenDoneBefore() {
//
//        let date = Date()
//
//        let oldLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49389, longitude: -0.20447),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
//
//        let newLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49187, longitude: -0.20209),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 5, since: date))
//
//        app.activityEstimator.processLocation(oldLoc)
//        app.locationManager(app.manager, didUpdateLocations: [newLoc])
//
//        XCTAssert(app.locationUponRequest != nil, "Stations have not been updated.")
//    }
//
//    func testRequestNewStationsWhenNewLocationIsFarEnough() {
//
//        let date = Date()
//
//        let oldLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49389, longitude: -0.20447),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
//
//        let newLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49187, longitude: -0.20209),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 5, since: date))
//
//        app.locationUponRequest = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14.49187, longitude: -0.20000),
//        altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 5, since: date))
//
//        app.activityEstimator.processLocation(oldLoc)
//        app.locationManager(app.manager, didUpdateLocations: [newLoc])
//
//        XCTAssert(app.locationUponRequest == newLoc, "Stations have not been updated.")
//    }
//    
//}
