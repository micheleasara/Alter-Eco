//
//  DatabaseTest.swift
//  Alter EcoBackEndTest
//
//  Created by Virtual Machine on 26/03/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Alter_Eco

class DatabaseTest: XCTestCase {

    func testReplaceYesterdayScoreWithTodayScoreInDatabase(){
        
        let dateToday = Date()

        let dateYesterday = Calendar.current.date(byAdding: .day, value: -1, to: dateToday)
        let dayYesterdayStr = stringFromDate(dateYesterday!)
        
        //print("DateYesterday is: " , dateYesterday!, " and day is: ", dayYesterdayStr)
        
        let firstScore = UserScore(totalPoints: 100, date: dayYesterdayStr)
        
        appendScoreToDatabase(score: firstScore)
        
        replaceScore()
        
        printUserScoreDatabase()
        
        let dateTodayStr = stringFromDate(dateToday)
        
        let retrievedScore = retrieveScore(query: NSPredicate(format: "dateStr == %@", dateTodayStr))
        
        //print("User Score: ", retrievedScore.totalPoints, " at date: ", retrievedScore.date)
        
        XCTAssert(retrievedScore.totalPoints == 100, "Score does not match")
    }
    
    func testReplaceUserScoreToDatabase(){
        
        let dateToday = Date()
        let dateTodayStr = stringFromDate(dateToday)
        
        let firstScore = UserScore(totalPoints: 100, date: dateTodayStr)
        
        appendScoreToDatabase(score: firstScore)
        
        let retrievedScore = retrieveScore(query: NSPredicate(format: "dateStr == %@", dateTodayStr))
        
        print("User Score: ", retrievedScore.totalPoints, " at date: ", retrievedScore.date)
        
        XCTAssert(retrievedScore.totalPoints == firstScore.totalPoints, "Scores don't match")
    }

}
