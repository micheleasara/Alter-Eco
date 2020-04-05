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

class SwiftUIGraphLogicTestsTwo: XCTestCase {
    
    
    func testDataisCorrectlyNormalised() {
        let date = Date()
        let activity = MeasuredActivity(motionType: .car, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))
        appendToDatabase(activity: activity)
        let result = queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "00:00:00", hourEnd: "24:00:00")
        
        let monthNormalisation=normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)
        //print (result)
        //print (monthNormalisation)
        
        XCTAssert(monthNormalisation == result)
    }
    
    func testGridLinesDisplayCorrectUnitsWhenUnder1000CarbonGrams() {
        //run findCorrectUnits
        let maxVal: Double
        let carbonUnit: String
        let decimalPlaces: String
        let savedOrEmitted: String
        
        (maxVal, carbonUnit, decimalPlaces, savedOrEmitted) = findCorrectUnits(currentMax: 900, value: 2)
           
        XCTAssert(maxVal == 900)
        XCTAssert(carbonUnit == "Carbon grams")
        XCTAssert(decimalPlaces == "%.0f")
          }
    
    func testGridLinesDisplayCorrectUnitsWhenOver1000CarbonGrams() {
        let maxVal: Double
        let carbonUnit: String
        let decimalPlaces: String
        let savedOrEmitted: String
        
        (maxVal, carbonUnit, decimalPlaces, savedOrEmitted) = findCorrectUnits(currentMax: 10001, value: 3)
           
        XCTAssert(maxVal == 10.001)
        XCTAssert(carbonUnit == "  Carbon kgs")
        XCTAssert(decimalPlaces == "%.0f")
    }
    
    func testWalkingTransportModeDisplaysCorrectLabel() {
        
       let maxVal: Double
       let carbonUnit: String
       let decimalPlaces: String
       let savedOrEmitted: String
        
        (maxVal, carbonUnit, decimalPlaces, savedOrEmitted) = findCorrectUnits(currentMax: 10001, value: 3)
           
        XCTAssert(savedOrEmitted == "   Saved")

    }

    func testGraphChangesToRedIfMoreThanTheAverageDailyUKAmount() {
        
        let date = Date()
        let activity = MeasuredActivity(motionType: .car, distance: 1100000.0, start: date, end: Date(timeInterval: 10, since: date))
        appendToDatabase(activity: activity)
        let result = queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "00:00:00", hourEnd: "24:00:00")
        
        let colour = findGraphColour()
        
        XCTAssert(colour == "redGraphBar")
        
    }
    
}






