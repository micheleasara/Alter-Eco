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
    var list: WeightedActivityList!
    
    override func setUp() {
        super.setUp()
        DBMS = CoreDataManager(persistentContainer: (UIApplication.shared.delegate as! AppDelegate).mockPersistentContainer())
        list = WeightedActivityList(activityWeights: ACTIVITY_WEIGHTS_DICT, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, DBMS: DBMS)
    }
    
    func testListIsOrderlyAndIterable() {
        let activities = [MeasuredActivity(motionType: .car, distance: 1, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100)), MeasuredActivity(motionType: .walking, distance: 1000, start: Date(timeIntervalSince1970: 200), end: Date(timeIntervalSince1970: 1000))]
        
        for activity in activities {
            list.add(activity)
        }
        XCTAssert(activities.count == list.count)
        
        for i in stride(from: 0, to: activities.count, by: 1) {
            XCTAssert(activities[i] == list[i])
        }
    }
    
    func testAddingPlanePutsIntoDatabaseAndDiscardsTheRest() {
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 100)
        let activities = [MeasuredActivity(motionType: .car, distance: 1, start: start, end: end),
        MeasuredActivity(motionType: .walking, distance: 1000, start: start, end: end),
        MeasuredActivity(motionType: .plane, distance: 1000, start: start, end: end)]
        
        // ensure list is empty after adding plane
        for activity in activities {
            list.add(activity)
        }
        XCTAssert(list.count == 0)
        
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
        
        // ensure list is empty after adding plane
        for activity in activities {
            list.add(activity)
        }
        XCTAssert(list.count == 0)
        
        // ensure only plane activity was put in the database
        let retrieved = try! DBMS.queryActivities(predicate: "start == %@ AND end == %@", args: [start as NSDate, end as NSDate])
        XCTAssert(retrieved.count == 1)
        XCTAssert(retrieved[0] == activities[2])
    }
}
//func add(_ activity:MeasuredActivity)
//func remove(at:Index)
//func removeAll()
//func dumpToDatabase(from:Int, to:Int)
