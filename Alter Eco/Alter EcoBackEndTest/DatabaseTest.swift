//
//  DatabaseTest.swift
//  Alter EcoBackEndTest
//
//  Created by Virtual Machine on 26/03/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import XCTest
import CoreLocation
import CoreData
@testable import Alter_Eco

class DatabaseTest: XCTestCase {
    
    var DBMS: CoreDataManager!

    override func setUp() {
        super.setUp()
        DBMS = CoreDataManager(persistentContainer: (UIApplication.shared.delegate as! AppDelegate).mockPersistentContainer())
    }
    
    func testDatabaseIOIsConsistent(){
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        let activity = MeasuredActivity(motionType: .plane, distance: 10000, start: longTimeAgo, end: someTimeAgo)
        try! DBMS.append(activity: activity)
        let retrieved = try! DBMS.queryActivities(query: NSPredicate(format: "start == %@ AND end == %@", longTimeAgo as NSDate, someTimeAgo as NSDate))
        XCTAssert(retrieved.count == 1)
        XCTAssert(activity == retrieved[0])
    }
    
    func testDatabaseCannotFindNonExistantData(){
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        let retrieved = try! DBMS.queryActivities(query: NSPredicate(format: "start == %@ AND end == %@", longTimeAgo as NSDate, someTimeAgo as NSDate))
        XCTAssert(retrieved.count == 0)
    }
    
    func testScoreIsInitializedWhenRetrievingTheFirstTime(){
        let initial = try! DBMS.retrieveLatestScore() // initializes the first time
        let retrieved = try! DBMS.retrieveLatestScore() // retrieves initialized score
        XCTAssert(retrieved == initial)
    }
    
    func testUpdatedScoreIsRetrieved(){
        let activity1 = MeasuredActivity(motionType: .car, distance: 100000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
        let activity2 = MeasuredActivity(motionType: .train, distance: 1000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 1000))
        let score1 = UserScore(activity: activity1, league: "", date: "")
        let score2 = UserScore(activity: activity2, league: "", date: "")
        
        _ = try! DBMS.retrieveLatestScore() // initialize score row
        try! DBMS.updateScore(activity: activity1)
        try! DBMS.updateScore(activity: activity2)
        let retrieved = try! DBMS.retrieveLatestScore()
        print("retrieved ", retrieved.totalPoints!)
        print("score1 ", score1.totalPoints!)
        print("score2 ", score2.totalPoints!)
        XCTAssert(retrieved.totalPoints == score1.totalPoints + score2.totalPoints)
    }
}

//
//public protocol DBWriter {
//    // Appends new score to Score table
//    func append(score: UserScore) throws
//}
//
//public protocol DBManager : AnyObject, DBReader, DBWriter {
//    func distanceWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double
//    func distanceWithinIntervalAll(from: Date, interval: TimeInterval) throws -> Double
//
//    // Make use of general execute query function to query daily carbon for any motionType
//    func carbonWithinInterval(motionType: MeasuredActivity.MotionType, from:Date, interval:TimeInterval) throws -> Double
//    // Make use of general execute query function to query daily carbon for all motionType
//    func carbonWithinIntervalAll(from:Date, interval:TimeInterval) throws -> Double
//
//    func updateScore(activity: MeasuredActivity) throws
//    func updateLeague(newLeague: String) throws
//    func retrieveLatestScore() throws -> UserScore
//    func getFirstDate() throws -> Date
//
//    func queryHourlyCarbon(motionType: MeasuredActivity.MotionType, hourStart: String, hourEnd: String) throws -> Double
//    func queryHourlyCarbonAll(hourStart: String, hourEnd: String) throws -> Double
//    func queryDailyCarbon(motionType: MeasuredActivity.MotionType, weekDayToDisplay: String) throws -> Double
//    func queryDailyCarbonAll(weekDayToDisplay: String) throws -> Double
//    func queryMonthlyCarbon(motionType:MeasuredActivity.MotionType, month: String) throws -> Double
//    func queryMonthlyCarbonAll(month: String) throws -> Double
//    func queryYearlyCarbon(motionType: MeasuredActivity.MotionType, year: String) throws -> Double
//    func queryYearlyCarbonAll(year: String) throws -> Double
//}
