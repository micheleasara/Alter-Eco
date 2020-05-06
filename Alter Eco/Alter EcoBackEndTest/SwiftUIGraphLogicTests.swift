//
//  SwiftUIGraphLogicTests.swift
//  Alter EcoFullUITest
//
//  Created by e withnell on 31/03/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//


import XCTest
import CoreLocation
@testable import Alter_Eco

class SwiftUIGraphLogicTests: XCTestCase {
    
    
    func testDataisCorrectlyNormalised() {
        let date = Date()
        let activity = MeasuredActivity(motionType: .car, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))
        appendToDatabase(activity: activity)
        let result = queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "00:00:00", hourEnd: "24:00:00")
        
        let monthNormalisation=normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)        
        //print (result)
        //print (monthNormalisation)
        
        XCTAssert(monthNormalisation == result)
    }
    
    func testForCorrectCarbonConversions() {
             }

    func testGridLinesDisplayCorrectUnitsWhenUnder1000CarbonGrams() {
          }
    
    func testGridLinesDisplayCorrectUnitsWhenOver1000CarbonGrams() {
    }
    
    func testGridLinesDisplayCorrectIntervals() {
    }

    func testGraphChangesColourDependingOnComparisonToAverageDailyUKAmount() {
    }
}





