//
//  TrackingTest.swift
//  TrackingTest
//
//  Created by Maxime Redstone on 18/02/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import XCTest
@testable import Alter_Eco

class TrackingTest: XCTestCase {

    let scene = SceneDelegate()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFullReturnsTrueIfListIsFull(){
        var measurements = [MeasurementObject]()
        for _ in 1...101{
            measurements.append(MeasurementObject(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        XCTAssert(scene.isFull(measurements: measurements))
    }
    
    func testFullReturnsFalseIfListIsNotFull(){
        var measurements = [MeasurementObject]()
        for _ in 1...10{
            measurements.append(MeasurementObject(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        XCTAssertFalse(scene.isFull(measurements: measurements))
    }
    
    func testEventHasNotChangedIfLessThanThreeMeasurements(){
        var measurements = [MeasurementObject]()
        for _ in 1...2{
            measurements.append(MeasurementObject(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        XCTAssertFalse(scene.hasEventChanged(measurements: measurements))
    }
    
    func testEventHasNotChangedIfLastTwoMeasurementsAreDifferentType(){
        var measurements = [MeasurementObject]()
        for _ in 1...4{
            measurements.append(MeasurementObject(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        measurements.append(MeasurementObject(motionType: MotionType.walking, distance: 100, start: Date(), end: Date()))
        XCTAssertFalse(scene.hasEventChanged(measurements: measurements))
    }
    
    func testEventHasChangedIfLastTwoMeasurementsAreSameTypeAndDifferentFromRoot(){
        var measurements = [MeasurementObject]()
        for _ in 1...4{
            measurements.append(MeasurementObject(motionType: MotionType.car, distance: 100, start: Date(), end: Date()))
        }
        measurements.append(MeasurementObject(motionType: MotionType.walking, distance: 100, start: Date(), end: Date()))
        measurements.append(MeasurementObject(motionType: MotionType.walking, distance: 100, start: Date(), end: Date()))
        XCTAssert(scene.hasEventChanged(measurements: measurements))
    }
}
