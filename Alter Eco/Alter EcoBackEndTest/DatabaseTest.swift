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
//@testable import Alter_Eco
@testable import AlterEcoBackend

class DatabaseTest: XCTestCase {
    
    var DBMS: CoreDataManager!

    override func setUp() {
        super.setUp()
        DBMS = CoreDataManager(persistentContainer: (UIApplication.shared.delegate as! AppDelegate).mockPersistentContainer())
    }
    
    func testDatabaseIOIsConsistent() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        let activity = MeasuredActivity(motionType: .plane, distance: 10000, start: longTimeAgo, end: someTimeAgo)
        try! DBMS.append(activity: activity)
        let retrieved = try! DBMS.queryActivities(predicate: "start == %@ AND end == %@", args: [longTimeAgo as NSDate, someTimeAgo as NSDate])
        XCTAssert(retrieved.count == 1)
        XCTAssert(activity == retrieved[0])
    }
    
    func testDatabaseCannotFindNonExistantData() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        let retrieved = try! DBMS.queryActivities(predicate: "start == %@ AND end == %@", args: [longTimeAgo as NSDate, someTimeAgo as NSDate])
        XCTAssert(retrieved.count == 0)
    }
    
    func testCallbackIsCalledWhenActivityIsWritten() {
        let expectation = self.expectation(description: "callback")
        let testActivity = MeasuredActivity(motionType: .car, distance: 10000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
        
        DBMS.setActivityWrittenCallback(callback: {activity in expectation.fulfill()})
        try! DBMS.append(activity: testActivity)

        // wait for the expectation to be fullfilled, or time out after 5 seconds
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testScoreIsInitializedWhenRetrievingTheFirstTime() {
        let initial = try! DBMS.retrieveLatestScore() // initializes the first time
        let retrieved = try! DBMS.retrieveLatestScore() // retrieves initialized score
        XCTAssert(retrieved == initial)
    }
    
    func testUpdatedUserScoreIsRetrieved() {
        let activity1 = MeasuredActivity(motionType: .car, distance: 10000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
        let activity2 = MeasuredActivity(motionType: .train, distance: 1000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 1000))
        let score1 = UserScore(activity: activity1, league: "", date: "", counter: 0)
        let score2 = UserScore(activity: activity2, league: "", date: "", counter: 0)
        
        _ = try! DBMS.retrieveLatestScore() // initialize score row
        try! DBMS.updateScore(activity: activity1)
        try! DBMS.updateScore(activity: activity2)
        try! DBMS.updateLeague(newLeague: "abc")
        let retrieved = try! DBMS.retrieveLatestScore()
        XCTAssert(retrieved.totalPoints == score1.totalPoints + score2.totalPoints)
        XCTAssert(retrieved.league == "abc")
    }
    
    func testDatabaseCanGetFirstActivity() {
        let recently = Date.init(timeIntervalSince1970: 1000)
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        
        let old = MeasuredActivity(motionType: .plane, distance: 10000, start: longTimeAgo, end: someTimeAgo)
        try! DBMS.append(activity: old)
        let new = MeasuredActivity(motionType: .car, distance: 100, start: someTimeAgo, end: recently)
        try! DBMS.append(activity: new)
        print(try! DBMS.getFirstDate())
        XCTAssert(try! DBMS.getFirstDate() == old.start)
    }
    
    func testQueryForDistanceRetrieval() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        
        for motion in MeasuredActivity.MotionType.allCases {
            let old = MeasuredActivity(motionType: motion, distance: 1, start: longTimeAgo, end: someTimeAgo)
            try! DBMS.append(activity: old)
        }
        let distance = try! DBMS.distanceWithinIntervalAll(from: longTimeAgo, interval: someTimeAgo.timeIntervalSince(longTimeAgo))
        XCTAssert(distance == Double(MeasuredActivity.MotionType.allCases.count))
    }
    
    func testQueryForCarbonRetrieval() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        var carbonExpected = 0.0
        
        for motion in MeasuredActivity.MotionType.allCases {
            let old = MeasuredActivity(motionType: motion, distance: 1, start: longTimeAgo, end: someTimeAgo)
            carbonExpected += DBMS.computeCarbonUsage(distance: 1, type: motion)
            try! DBMS.append(activity: old)
        }
        let retrievedCarbon = try! DBMS.carbonWithinIntervalAll(from: longTimeAgo, interval: someTimeAgo.timeIntervalSince(longTimeAgo))
        XCTAssert(retrievedCarbon == carbonExpected)
    }
    
    func testHourlyCarbonRetrievalForAllMotionTypes() {
        let today = Date()
        let oneToFour = MeasuredActivity(motionType: .plane, distance: 9000, start: Date.setToSpecificHour(date: today, hour: "01:00:00")!, end: Date.setToSpecificHour(date: today, hour: "04:00:00")!)
        let oneToTwoHalf = MeasuredActivity(motionType: .car, distance: 18000, start: Date.setToSpecificHour(date: today, hour: "01:00:00")!, end: Date.setToSpecificHour(date: today, hour: "02:30:00")!)
        let twoHalfToFour = MeasuredActivity(motionType: .car, distance: 27000, start: Date.setToSpecificHour(date: today, hour: "02:30:00")!, end: Date.setToSpecificHour(date: today, hour: "04:00:00")!)
        let twoToThree = MeasuredActivity(motionType: .walking, distance: 3000, start: Date.setToSpecificHour(date: today, hour: "02:00:00")!, end: Date.setToSpecificHour(date: today, hour: "03:00:00")!)
        
        // activities only sharing a portion of time with the query
        let activities = [oneToFour, oneToTwoHalf, twoHalfToFour, twoToThree]
        let coeff = [1.0/3, 1.0/3, 1.0/3, 1]
        var expectedCarbon = 0.0
        for i in stride(from: 1, to: coeff.count, by: 1) {
            try! DBMS.append(activity: activities[i])
            expectedCarbon += DBMS.computeCarbonUsage(distance: coeff[i]*activities[i].distance, type: activities[i].motionType)
        }
        
        // be wary of rounding errors!
        let carbonRetrieved = try! DBMS.queryHourlyCarbonAll(hourStart: "02:00:00", hourEnd: "03:00:00")
        let tolerance = 0.1
        XCTAssert(abs(carbonRetrieved - expectedCarbon) < tolerance, "carbonRetrieved was " + String(carbonRetrieved) + " expectedCarbon was " + String(expectedCarbon))
    }
    
    func testHourlyCarbonRetrievalForASpecificMotionType() {
        let today = Date()
        let oneToFour = MeasuredActivity(motionType: .car, distance: 9000, start: Date.setToSpecificHour(date: today, hour: "01:00:00")!, end: Date.setToSpecificHour(date: today, hour: "04:00:00")!)
        let oneToTwoHalf = MeasuredActivity(motionType: .car, distance: 18000, start: Date.setToSpecificHour(date: today, hour: "01:00:00")!, end: Date.setToSpecificHour(date: today, hour: "02:30:00")!)
        let twoHalfToFour = MeasuredActivity(motionType: .car, distance: 27000, start: Date.setToSpecificHour(date: today, hour: "02:30:00")!, end: Date.setToSpecificHour(date: today, hour: "04:00:00")!)
        let twoToThree = MeasuredActivity(motionType: .car, distance: 3000, start: Date.setToSpecificHour(date: today, hour: "02:00:00")!, end: Date.setToSpecificHour(date: today, hour: "03:00:00")!)
        
        // activities only sharing a portion of time with the query
        let activities = [oneToFour, oneToTwoHalf, twoHalfToFour, twoToThree]
        let coeff = [1.0/3, 1.0/3, 1.0/3, 1]
        var expectedCarbon = 0.0
        for i in stride(from: 1, to: coeff.count, by: 1) {
            try! DBMS.append(activity: activities[i])
            expectedCarbon += DBMS.computeCarbonUsage(distance: coeff[i]*activities[i].distance, type: activities[i].motionType)
        }
        
        // be wary of rounding errors!
        let carbonRetrieved = try! DBMS.queryHourlyCarbon(motionType: .car, hourStart: "02:00:00", hourEnd: "03:00:00")
        let tolerance = 0.1
        XCTAssert(abs(carbonRetrieved - expectedCarbon) < tolerance, "carbonRetrieved was " + String(carbonRetrieved) + " expectedCarbon was " + String(expectedCarbon))
    }
    
    func testDailyCarbonRetrievalForAllMotionTypes() {
        let now = Date()
        let yesterdayToTomorrow = MeasuredActivity(motionType: .plane, distance: 9000, start: Date(timeInterval: -24*60*60, since: now), end: Date(timeInterval: 24*60*60, since: now))
        let nowToTomorrow = MeasuredActivity(motionType: .car, distance: 18000, start: now, end: Date(timeInterval: 24*60*60, since: now))
        let yesterdayToNow = MeasuredActivity(motionType: .car, distance: 27000, start: Date(timeInterval: -24*60*60, since: now), end: now)
        let exactlyToday = MeasuredActivity(motionType: .walking, distance: 3000, start: Date.setToSpecificHour(date: now, hour: "00:00:00")!, end: Date.setToSpecificHour(date: now, hour: "23:59:59")!)
        
        // activities only sharing a portion of time with the query
        let activities = [yesterdayToNow, nowToTomorrow, yesterdayToTomorrow, exactlyToday]
        let totalExaminedTime : Double = 24*60*60
        let timeSinceMidnight = now.timeIntervalSince(Date.setToSpecificHour(date: now, hour: "00:00:00")!)
        let coeff = [timeSinceMidnight/totalExaminedTime, (totalExaminedTime - timeSinceMidnight) / totalExaminedTime, 0.5, 1.0]
        
        var expectedCarbon = 0.0
        for i in stride(from: 0, to: coeff.count, by: 1) {
            try! DBMS.append(activity: activities[i])
            expectedCarbon += DBMS.computeCarbonUsage(distance: coeff[i]*activities[i].distance, type: activities[i].motionType)
        }
        
        let carbonRetrieved = try! DBMS.queryDailyCarbonAll(weekDayToDisplay: Date.getDayName(now))
        let tolerance = 0.1
        XCTAssert(abs(carbonRetrieved - expectedCarbon) < tolerance, "carbonRetrieved was " + String(carbonRetrieved) + " expectedCarbon was " + String(expectedCarbon))
    }
    
    func testDailyCarbonRetrievalForASpecificMotionType() {
        let now = Date()
        let yesterdayToTomorrow = MeasuredActivity(motionType: .car, distance: 9000, start: Date(timeInterval: -24*60*60, since: now), end: Date(timeInterval: 24*60*60, since: now))
        let nowToTomorrow = MeasuredActivity(motionType: .car, distance: 18000, start: now, end: Date(timeInterval: 24*60*60, since: now))
        let yesterdayToNow = MeasuredActivity(motionType: .car, distance: 27000, start: Date(timeInterval: -24*60*60, since: now), end: now)
        let exactlyToday = MeasuredActivity(motionType: .car, distance: 3000, start: Date.setToSpecificHour(date: now, hour: "00:00:00")!, end: Date.setToSpecificHour(date: now, hour: "23:59:59")!)
        
        // activities only sharing a portion of time with the query
        let activities = [yesterdayToNow, nowToTomorrow, yesterdayToTomorrow, exactlyToday]
        let totalExaminedTime : Double = 24*60*60
        let timeSinceMidnight = now.timeIntervalSince(Date.setToSpecificHour(date: now, hour: "00:00:00")!)
        let coeff = [timeSinceMidnight/totalExaminedTime, (totalExaminedTime - timeSinceMidnight) / totalExaminedTime, 0.5, 1.0]
        
        var expectedCarbon = 0.0
        for i in stride(from: 0, to: coeff.count, by: 1) {
            try! DBMS.append(activity: activities[i])
            expectedCarbon += DBMS.computeCarbonUsage(distance: coeff[i]*activities[i].distance, type: activities[i].motionType)
        }
        
        let carbonRetrieved = try! DBMS.queryDailyCarbon(motionType: .car, weekDayToDisplay: Date.getDayName(now))
        let tolerance = 0.1
        XCTAssert(abs(carbonRetrieved - expectedCarbon) < tolerance, "carbonRetrieved was " + String(carbonRetrieved) + " expectedCarbon was " + String(expectedCarbon))
    }
    
    func testMonthlyCarbonRetrieval() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentYear = Calendar(identifier: .gregorian).component(.year, from: now)
        let janFirst = formatter.date(from: "\(currentYear)-01-01")!
        let janThird = formatter.date(from: "\(currentYear)-01-03")!
        let activity = MeasuredActivity(motionType: .car, distance: 1000, start: janFirst, end: janThird)
        try! DBMS.append(activity: activity)
        let expectedCarbon = DBMS.computeCarbonUsage(distance: activity.distance, type: activity.motionType)
        let carbonRetrieved = try! DBMS.queryMonthlyCarbonAll(month: "January")
        let tolerance = 0.1
        XCTAssert(abs(carbonRetrieved - expectedCarbon) < tolerance, "carbonRetrieved was " + String(carbonRetrieved) + " expectedCarbon was " + String(expectedCarbon))
    }
    
    func testYearlyCarbonRetrieval() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let activity = MeasuredActivity(motionType: .car, distance: 1000, start: formatter.date(from: "1995-07-09")!, end: formatter.date(from: "1995-07-11")!)
        try! DBMS.append(activity: activity)
        let expectedCarbon = DBMS.computeCarbonUsage(distance: activity.distance, type: activity.motionType)
        let carbonRetrieved = try! DBMS.queryYearlyCarbonAll(year: "1995")
        let tolerance = 0.1
        XCTAssert(abs(carbonRetrieved - expectedCarbon) < tolerance, "carbonRetrieved was " + String(carbonRetrieved) + " expectedCarbon was " + String(expectedCarbon))
    }
    
    func testSelectOnlyYearFromDate() {
        
        let thisYear = Date()
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: thisYear)
        let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: thisYear)
        
        let listOfDates = [oneYearAgo, nextYear]
        
        let listOfYearsStr = Date.toYearString(years: listOfDates as! [Date])
        
        let oneYearAgoStr = Calendar.current.component(.year, from: oneYearAgo!)
        let nextYearStr = Calendar.current.component(.year, from: nextYear!)
        
        XCTAssert(listOfYearsStr[0] == String(oneYearAgoStr) && listOfYearsStr[1] == String(nextYearStr), "Cannot convert year from date to string.")
    }
    
    func testTwoDatesAreNotInSameDay() {
    
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let inSameDay = Date.inSameDay(date1: today, date2: yesterday)
        
        XCTAssert(inSameDay == false, "Dates are in same day but should not.")
    }
    
}
