//
//  UserScoreTest.swift
//  Alter EcoBackEndTest
//
//  Created by Virtual Machine on 17/04/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import XCTest
import CoreData
@testable import AlterEcoBackend

class UserScoreTest: XCTestCase {

    var DBMS: CoreDataManager!

    override func setUp() {
        super.setUp()
        DBMS = CoreDataManager(persistentContainer: (UIApplication.shared.delegate as! AppDelegate).mockPersistentContainer())
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPrintsNextLeagueFromScore() {
        
        let initialUserScore = UserScore.getInitialScore()
        let userScoreAtLeague2 = UserScore.getInitialScore()
        userScoreAtLeague2.league = "🌿"
        let userScoreAtLeague3 = UserScore.getInitialScore()
        userScoreAtLeague3.league = "🌳"
        
        let currentLeagues = ["🌱", "🌿", "🌳"]
        
        let currentScores = [initialUserScore, userScoreAtLeague2]
        
        let nextLeagueFromInitialScore = UserScore.getNewLeague(userLeague: initialUserScore.league)
        let nextLeagueFromScoreAtLeague2 = UserScore.getNewLeague(userLeague: userScoreAtLeague2.league)
        let nextLeagueFromScoreAtLeague3 = UserScore.getNewLeague(userLeague: userScoreAtLeague3.league)
        
        XCTAssert(nextLeagueFromInitialScore == currentLeagues[currentScores.count-1], "Can not retrieve next league from initial score.")
        XCTAssert(nextLeagueFromScoreAtLeague2 == currentLeagues[currentScores.count], "Can not retrieve next league from user at league 2.")
        XCTAssert(nextLeagueFromScoreAtLeague3 == currentLeagues[currentScores.count-2], "Can not retrieve next league from user at league 3.")
        
    }
    
    func testDoesNotUpdateLeagueIfNotEnougPointsAccumulated() {
    
        _ = try! DBMS.retrieveLatestScore()
        let currentLeagues = ["🌱", "🌿", "🌳"]
        
        try! DBMS.getLeagueProgress(dbms: DBMS)
        
        let updatedScore = try! DBMS.retrieveLatestScore()
        
        XCTAssert(updatedScore.league == currentLeagues[0], "Does not upgrade league if not enough points. ")
    }
    
    func testCanUpdateLeagueWhenEnoughPointsAccumulated() {
    
        _ = try! DBMS.retrieveLatestScore()
        let currentLeagues = ["🌱", "🌿", "🌳"]
        
        try! DBMS.updateScore(activity: MeasuredActivity(motionType: .walking, distance: 400000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 60*60*24)))
        
        try! DBMS.getLeagueProgress(dbms: DBMS)
        let updatedScore = try! DBMS.retrieveLatestScore()
        
        XCTAssert(updatedScore.league == currentLeagues[1], "Should upgrade user league in database from league 1 to league 2.")
        XCTAssert(updatedScore.totalPoints == 0.0, "Updating league should reset user score.")
    }
        
    func testCanUpdateCounterWhenMaxLeagueIsReached() {
        
        _ = try! DBMS.retrieveLatestScore()
        let currentLeagues = ["🌱", "🌿", "🌳"]
        
        // ~3000 points for each activity
        for _ in stride(from: 0, to: 3, by: 1) {
            try! DBMS.updateScore(activity: MeasuredActivity(motionType: .car, distance: 1001000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 60*60)))
            try! DBMS.getLeagueProgress(dbms: DBMS)
        }

        let updatedScore = try! DBMS.retrieveLatestScore()
        
        XCTAssert(updatedScore.league == currentLeagues[0], "Should go back to league 1.")
        XCTAssert(updatedScore.totalPoints == 0.0, "Updating league should reset user score.")
        XCTAssert(updatedScore.counter == 1, "After completing the 3 leagues should go back to league one and counter should increase by 1.")
    }
}
