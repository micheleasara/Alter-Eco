//
//  WeightedActivityListTest.swift
//  Alter EcoBackEndTest
//
//  Created by Deli De leon de miguel on 14/04/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import XCTest
@testable import Alter_Eco

class WeightedActivityListTest: XCTestCase {

    var DBMS: CoreDataManager!
    var measurements: WeightedActivityList!
    
    override func setUp() {
        super.setUp()
        DBMS = CoreDataManager(persistentContainer: (UIApplication.shared.delegate as! AppDelegate).mockPersistentContainer())
        measurements = WeightedActivityList(activityWeights: ACTIVITY_WEIGHTS_DICT, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, DBMS: DBMS)
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
        measurements.add(MeasuredActivity(motionType: .car, distance: 1, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100)))
        XCTAssert(measurements[0].distance == 1)
        measurements[0].distance = 2
        XCTAssert(measurements[0].distance == 2)
    }
    
    func testAddingPlanePutsIntoDatabaseAndDiscardsTheRest() {
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 100)
        let activities = [MeasuredActivity(motionType: .car, distance: 1, start: start, end: end),
        MeasuredActivity(motionType: .walking, distance: 1000, start: start, end: end),
        MeasuredActivity(motionType: .plane, distance: 1000, start: start, end: end)]
        
        // ensure list is empty after adding plane
        for activity in activities {
            measurements.add(activity)
        }
        XCTAssert(measurements.count == 0)
        
        // ensure only plane activity was put in the database
        let retrieved = try! DBMS.queryActivities(predicate: "start == %@ AND end == %@", args: [start as NSDate, end as NSDate])
        XCTAssert(retrieved.count == 1)
        XCTAssert(retrieved[0] == activities[2])
    }
    
    func testAddingTrainPutsIntoDatabaseAndDiscardsTheRest() {
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 100)
        let activities = [MeasuredActivity(motionType: .car, distance: 1, start: start, end: end),
        MeasuredActivity(motionType: .walking, distance: 1000, start: start, end: end),
        MeasuredActivity(motionType: .train, distance: 1000, start: start, end: end)]
        
        // ensure list is empty after adding train
        for activity in activities {
            measurements.add(activity)
        }
        XCTAssert(measurements.count == 0)
        
        // ensure only plane activity was put in the database
        let retrieved = try! DBMS.queryActivities(predicate: "start == %@ AND end == %@", args: [start as NSDate, end as NSDate])
        XCTAssert(retrieved.count == 1)
        XCTAssert(retrieved[0] == activities[2])
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
        let answer = measurements.getAverage(from: 0, to: measurements.count)
        
        // sample answer has sum of distances as distance and start and end date of first and last measurement, respectively
        let sampleAnswer = MeasuredActivity(motionType: .walking, distance: 1300, start: measurements[0].start, end: measurements[measurements.count-1].end )

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
    
    func testDumpingToDatabaseWritesAverageAndClears() {
        let activities = [MeasuredActivity(motionType: .car, distance: 1, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100)), MeasuredActivity(motionType: .car, distance: 1000, start: Date(timeIntervalSince1970: 200), end: Date(timeIntervalSince1970: 1000))]
        for activity in activities {
            measurements.add(activity)
        }
        let average = measurements.getAverage(from: 0, to: measurements.count-1)
        measurements.dumpToDatabase(from: 0, to: measurements.count-1)
        XCTAssert(measurements.count == 0)
        let retrieved = try! DBMS.queryActivities(predicate: "motionType == %@", args: [MeasuredActivity.motionTypeToString(type: activities[0].motionType)])
        XCTAssert(retrieved.count == 1)
        XCTAssert(retrieved[0] == average)
    }
    
    func testListDumpsToDatabaseIfActivityChangesSignificantly() {
        var date = Date(timeIntervalSince1970: 0)
        for _ in 1...CHANGE_ACTIVITY_THRESHOLD {
            measurements.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        XCTAssert(measurements.count == CHANGE_ACTIVITY_THRESHOLD)
        for _ in 1...CHANGE_ACTIVITY_THRESHOLD + 1 {
            measurements.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
        }
        let retrieved = try! DBMS.queryActivities(predicate: "start == %@", args: [Date(timeIntervalSince1970: 0) as NSDate])
        XCTAssert(retrieved.count == 1)
        XCTAssert(retrieved[0].motionType == .car)
    }
}
