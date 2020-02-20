//
//  TrackingTest.swift
//  TrackingTest
//
//  Created by Maxime Redstone on 18/02/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Alter_Eco

class TrackingTest: XCTestCase {

    let scene = SceneDelegate()
    
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func testFullReturnsTrueIfListIsFull(){
        var measurements = [MeasuredActivity]()
        for _ in 1...scene.MAX_MEASUREMENTS {
            measurements.append(MeasuredActivity(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        XCTAssert(scene.isFull(measurements: measurements))
    }
    
    func testFullReturnsFalseIfListIsNotFull(){
        var measurements = [MeasuredActivity]()
        for _ in 1...10{
            measurements.append(MeasuredActivity(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        XCTAssertFalse(scene.isFull(measurements: measurements))
    }
    
    func testEventHasNotChangedIfLessThanThreeMeasurements(){
        var measurements = [MeasuredActivity]()
        for _ in 1...2{
            measurements.append(MeasuredActivity(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        XCTAssertFalse(scene.hasEventChanged(measurements: measurements))
    }
    
    func testEventHasNotChangedIfLastTwoMeasurementsAreDifferentType(){
        var measurements = [MeasuredActivity]()
        for _ in 1...4{
            measurements.append(MeasuredActivity(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        measurements.append(MeasuredActivity(motionType: MotionType.walking, distance: 100, start: Date(), end: Date()))
        XCTAssertFalse(scene.hasEventChanged(measurements: measurements))
    }
    
    func testEventHasChangedIfLastTwoMeasurementsAreSameTypeAndDifferentFromRoot(){
        var measurements = [MeasuredActivity]()
        for _ in 1...4{
            measurements.append(MeasuredActivity(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        measurements.append(MeasuredActivity(motionType: MotionType.walking, distance: 100, start: Date(), end: Date()))
        measurements.append(MeasuredActivity(motionType: MotionType.walking, distance: 100, start: Date(), end: Date()))
        XCTAssert(scene.hasEventChanged(measurements: measurements))
    }
    
    func testValidMovementIsAppendedToMeasurementsList() {
        let accuracy = scene.GPS_UPDATE_CONFIDENCE_THRESHOLD
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date())
        
        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 10, since: previousLocation.timestamp))
        
        scene.previousLoc = previousLocation
        
        scene.locationManager(scene.manager, didUpdateLocations: [currentLocation])

        XCTAssert(scene.measurements.count == 1, "Expected only one item in the measurements list, but got " + String(scene.measurements.count))
    }
    
    func testEventDistanceIsTheSumOfAllMeasuredDistances() {
        var measurements = [MeasuredActivity]()
        for _ in 1...10{
            measurements.append(MeasuredActivity(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        
        let duration = scene.computeEventDistance(measurements: measurements)
        
        XCTAssert(duration == 1000, "Total event distance should be the sum of all measured distances")
    }
    
    func testAverageOfEquipartitionedMotionTypesResultsInMotionTypeWithHighestWeight() {
            var measurements = [MeasuredActivity]()
            var date = Date()
            for _ in 1...10 {
                measurements.append(MeasuredActivity(motionType: MotionType.car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
                date = Date(timeInterval: 10, since: date)
            }
        
            for _ in 1...10 {
                measurements.append(MeasuredActivity(motionType: MotionType.walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
                date = Date(timeInterval: 10, since: date)
            }

            let motionType = scene.computeEventMotionType(measurements: measurements)
            
        XCTAssert(motionType == MotionType.car, "Expected car, got "+motionTypeToString(type: MotionType.car))
    }
    
    func testAverageMotionTypeWithSufficientlyMoreWalkingResultsInWalking() {
        var measurements = [MeasuredActivity]()
        var date = Date()
        for _ in 1...3 {
            measurements.append(MeasuredActivity(motionType: MotionType.car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
    
        for _ in 1...10 {
            measurements.append(MeasuredActivity(motionType: MotionType.walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }

        let motionType = scene.computeEventMotionType(measurements: measurements)
        
        XCTAssert(motionType == MotionType.walking, "Expected walking, got "+motionTypeToString(type: MotionType.walking))
    }

    func testAverageMotionTypeWithSufficientlyMoreCarResultsInCar() {
        var measurements = [MeasuredActivity]()
        var date = Date()
        for _ in 1...10 {
            measurements.append(MeasuredActivity(motionType: MotionType.car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
    
        for _ in 1...5 {
            measurements.append(MeasuredActivity(motionType: MotionType.walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }

        let motionType = scene.computeEventMotionType(measurements: measurements)
        
        XCTAssert(motionType == MotionType.car, "Expected car, got "+motionTypeToString(type: MotionType.car))
    }
    
    func testTwoEqualEventsResultEqual() {
        let date = Date()
        let eventOne = MeasuredActivity(motionType: .car, distance: 11, start: date, end: Date(timeInterval: 10, since: date))
        
        let eventTwo = MeasuredActivity(motionType: .car, distance: 11, start: date, end: eventOne.end)
        
        XCTAssert(eventTwo == eventOne, "Expected equality between two events")
    }
    
    func testTwoUnequalEventsResultDifferent() {
        let date = Date()
        let eventOne = MeasuredActivity(motionType: .car, distance: 11, start: date, end: Date(timeInterval: 10, since: date))
        
        let eventTwo = MeasuredActivity(motionType: .car, distance: 11, start: Date(timeInterval: 1000, since: date), end: eventOne.end)
        
        XCTAssertFalse(eventTwo == eventOne, "Expected inequality between two events")
    }
    
    func testDatabaseIOIsConsistent() {
        let date = Date()
        let event = MeasuredActivity(motionType: .car, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))
        
        createDatabase()
        
        appendToDatabase(event: event)
        
        let eventRetrieved = retrieveFromDatabase(queryDate: date)!

        XCTAssert(event == eventRetrieved, "Expected same event")
    }
}
