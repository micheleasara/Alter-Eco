//
//  WeightedActivityListTest.swift
//  Alter EcoBackEndTest
//
//  Created by Deli De leon de miguel on 14/04/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import XCTest
//@testable import Alter_Eco
@testable import AlterEcoBackend

class WeightedActivityListTest: XCTestCase {

    var measurements: WeightedActivityList!
    
    override func setUp() {
        super.setUp()
        measurements = WeightedActivityList(activityWeights: ACTIVITY_WEIGHTS_DICT)
    }
    
    func testListIsOrderlyAndIterable() {
        let activities = [MeasuredActivity(motionType: .car, distance: 1, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100)), MeasuredActivity(motionType: .walking, distance: 1000, start: Date(timeIntervalSince1970: 200), end: Date(timeIntervalSince1970: 1000))]
        
        for activity in activities {
            measurements.add(activity)
        }
        XCTAssert(activities.count == measurements.count)
        
        // using for each to test iterator functionality of list
        var i : Int = 0
        for item in measurements {
            XCTAssert(activities[i] == item)
            i += 1
        }
    }
    
    func testListIsMutableWithSetter() {
        let activity = MeasuredActivity(motionType: .car, distance: 1, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
        measurements.add(activity)
        XCTAssert(measurements[0] == activity)
        let activity2 = MeasuredActivity(motionType: .walking, distance: 30, start: Date(timeIntervalSince1970: 110), end: Date(timeIntervalSince1970: 200))
        measurements[0] = activity2
        XCTAssert(measurements[0] == activity2)
    }
    
    func testRemovingAnIndexRemovesFromTheList() {
        let activities = [MeasuredActivity(motionType: .car, distance: 1, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100)), MeasuredActivity(motionType: .walking, distance: 1000, start: Date(timeIntervalSince1970: 200), end: Date(timeIntervalSince1970: 1000))]
        
        for activity in activities {
            measurements.add(activity)
        }
        XCTAssert(activities.count == measurements.count)
        measurements.remove(at: 0)
        XCTAssert(measurements.count == 1 && measurements[0] == activities[1])
    }
    
    func testRemovingAllClearsTheList() {
        let activities = [MeasuredActivity(motionType: .car, distance: 1, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100)), MeasuredActivity(motionType: .walking, distance: 1000, start: Date(timeIntervalSince1970: 200), end: Date(timeIntervalSince1970: 1000))]
        
        for activity in activities {
            measurements.add(activity)
        }
        XCTAssert(activities.count > 0)
        measurements.removeAll()
        XCTAssert(measurements.count == 0)
    }
    
    func testAverageActivityFromListResultsIdenticalToSampleProvided() {
        var date = Date(timeIntervalSince1970: 0)

        for _ in 1...10 {
            measurements.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        measurements.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        let answer = measurements.getAverage(from: 0, to: measurements.count-1)
        
        // sample answer has sum of distances as distance and start and end date of first and last measurement, respectively
        let sampleAnswer = MeasuredActivity(motionType: .walking, distance:1100, start: measurements[0].start, end: measurements[measurements.count-1].end )

        XCTAssert(answer == sampleAnswer, "Average activity was not computed correctly")
    }

    func testAverageOfEquipartitionedMotionTypesResultsInMotionTypeWithHighestWeight() {
        let date = Date(timeIntervalSince1970: 0)
        measurements.add(MeasuredActivity(motionType: MeasuredActivity.MotionType.car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
        measurements.add(MeasuredActivity(motionType: MeasuredActivity.MotionType.walking, distance: 100, start: Date(timeInterval: 20, since: date), end: Date(timeInterval: 30, since: date)))
            

        let motionType = measurements.getAverageMotionType(from: 0, to: measurements.count-1)

        XCTAssert(motionType == MeasuredActivity.MotionType.car, "Expected car, got " + MeasuredActivity.motionTypeToString(type: motionType))
    }

    func testAverageMotionTypeWithSufficientlyMoreWalkingResultsInWalking() {
        var date = Date(timeIntervalSince1970: 0)
        for _ in 1...100 {
            measurements.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        measurements.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
        
        let motionType = measurements.getAverageMotionType(from: 0, to: measurements.count-1)
        XCTAssert(motionType == .walking, "Expected walking, got " + MeasuredActivity.motionTypeToString(type: .walking))
    }

    func testAverageMotionTypeWithSufficientlyMoreCarResultsInCar() {
        var date = Date(timeIntervalSince1970: 0)
        for _ in 1...10 {
            measurements.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        measurements.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))

        let motionType = measurements.getAverageMotionType(from: 0, to: measurements.count-1)
        XCTAssert(motionType == .car, "Expected car, got " + MeasuredActivity.motionTypeToString(type: motionType))
    }
    
}
