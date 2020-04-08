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
    
    func testReplaceUserScoreToDatabase(){
        
        let retrievedScore = retrieveLatestScore()
        
        print("User Score: ", retrievedScore.totalPoints, " at date: ", retrievedScore.date)
        
        XCTAssert(retrievedScore.totalPoints == 10, "Scores don't match")
    }

}
