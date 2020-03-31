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
        //add fake data to database for two specific days
        
        
       let date = Date()
           let activity = MeasuredActivity(motionType: .car, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))

           appendToDatabase(activity: activity)

           let activityRetrieved = executeQuery(query: NSPredicate(format: "start == %@", date as NSDate))[0]

           XCTAssert(activity == activityRetrieved, "Expected same activity")
       }

     //     appendToDatabase(activity: activity)
    }

        
        
        

      //  let result = queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "01:00:00", hourEnd: "02:00:00")
      
        
                
      //  let monthNormalisation=normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthcar)
        

        //fake query for that specific day
      //   XCTAssert(monthNormalisation == result, "Expected car, got " )
        
        //normalise data for that day

       
//    func testGridLinesDisplayCorrectUnits() {
//
//          }
//    func testGridLinesDisplayCorrectIntervals() {
//
//    }
//    func testGraphChangesColourDependingOnComparisonToAverageDailyUKAmount() {
//
//    }





