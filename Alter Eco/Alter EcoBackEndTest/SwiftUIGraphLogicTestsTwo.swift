////
////  SwiftUIGraphLogicTests.swift
////  Alter EcoFullUITest
////
////  Created by e withnell on 31/03/2020.
////  Copyright © 2020 Imperial College London. All rights reserved.
////
//
//
//import XCTest
//import CoreLocation
//@testable import Alter_Eco
//
//class SwiftUIGraphLogicTestsTwo: XCTestCase {
//    
//    
//    func testGridLinesDisplayCorrectUnitsWhenUnder1000CarbonGrams() {
//        //run findCorrectUnits
//        let maxVal: Double
//        let carbonUnit: String
//        let decimalPlaces: String
//        
//        (maxVal, carbonUnit, decimalPlaces, _) = findCorrectUnits(currentMax: 900, value: 2)
//           
//        XCTAssert(maxVal == 900)
//        XCTAssert(carbonUnit == "Carbon grams")
//        XCTAssert(decimalPlaces == "%.0f")
//          }
//    
//    func testGridLinesDisplayCorrectUnitsWhenOver1000CarbonGrams() {
//        let maxVal: Double
//        let carbonUnit: String
//        let decimalPlaces: String
//        
//        (maxVal, carbonUnit, decimalPlaces, _) = findCorrectUnits(currentMax: 10001, value: 3)
//           
//        XCTAssert(maxVal == 10.001)
//        XCTAssert(carbonUnit == "  Carbon kgs")
//        XCTAssert(decimalPlaces == "%.0f")
//    }
//    
//    func testWalkingTransportModeDisplaysCorrectLabel() {
//       let savedOrEmitted: String
//        
//        (_,_,_, savedOrEmitted) = findCorrectUnits(currentMax: 10001, value: 2)
//        
//        print("SAVED OR EMMITED YIELDS: ", savedOrEmitted)
//        XCTAssert(savedOrEmitted == "   Saved")
//
//    }
//
//    func testGraphChangesToRedIfMoreThanTheAverageDailyUKAmount() {
//        
//        let date = Date()
//        let activity = MeasuredActivity(motionType: .car, distance: 1100000.0, start: date, end: Date(timeInterval: 10, since: date))
//        appendToDatabase(activity: activity)
//        
//        let colour = findGraphColour()
//        
//        XCTAssert(colour == "redGraphBar")
//        
//    }
//
//    func testPlaneCarbonConversion() {
//        let dateString = "2020-03-06 01:00:00 +0000"
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        let date = dateFormatter.date(from:dateString)!
//        
//        let dateStringTwo = "2020-03-06 02:00:00 +0000"
//        let dateTwo = dateFormatter.date(from:dateStringTwo)!
//        
//        var measuredActivities = [MeasuredActivity]()
//        let motionType = MeasuredActivity.MotionType.plane
//        let distance = 10.0
//        let start = date
//        let end = dateTwo
//        
//        measuredActivities.append(MeasuredActivity(motionType: motionType, distance: distance, start: start, end: end))
//        let value = computeCarbonUsage(measuredActivities: measuredActivities, type: MeasuredActivity.MotionType.plane)
//        var actualValue: Double
//        
//        //10 is the metres travelled (converted to kms) and 200 is the carbon constant
//        actualValue = (10*200)/1000
//        XCTAssert(value == actualValue)
//    }
//    
//    func testTrainCarbonConversion() {
//        let dateString = "2020-03-06 01:00:00 +0000"
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        let date = dateFormatter.date(from:dateString)!
//        
//        let dateStringTwo = "2020-03-06 02:00:00 +0000"
//        let dateTwo = dateFormatter.date(from:dateStringTwo)!
//        
//        var measuredActivities = [MeasuredActivity]()
//        let motionType = MeasuredActivity.MotionType.train
//        let distance = 10.0
//        let start = date
//        let end = dateTwo
//        
//        measuredActivities.append(MeasuredActivity(motionType: motionType, distance: distance, start: start, end: end))
//        let value = computeCarbonUsage(measuredActivities: measuredActivities, type: MeasuredActivity.MotionType.train)
//        var actualValue: Double
//        
//        //10 is the metres travelled (converted to kms) and 30 is the carbon constant
//        actualValue = (10*30)/1000
//        XCTAssert(value == actualValue)
//    }
//    
//    func testCarCarbonConversion() {
//        let dateString = "2020-03-06 01:00:00 +0000"
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        let date = dateFormatter.date(from:dateString)!
//        
//        let dateStringTwo = "2020-03-06 02:00:00 +0000"
//        let dateTwo = dateFormatter.date(from:dateStringTwo)!
//        
//        var measuredActivities = [MeasuredActivity]()
//        let motionType = MeasuredActivity.MotionType.car
//        let distance = 10.0
//        let start = date
//        let end = dateTwo
//        
//        measuredActivities.append(MeasuredActivity(motionType: motionType, distance: distance, start: start, end: end))
//        let value = computeCarbonUsage(measuredActivities: measuredActivities, type: MeasuredActivity.MotionType.car)
//        var actualValue: Double
//        
//        //10 is the metres travelled (converted to kms) and 175 is the carbon constant
//        actualValue = (10*175)/1000
//        XCTAssert(value == actualValue)
//    }
//    
//    func testWalkingCarbonConversion() {
//        let dateString = "2020-03-06 01:00:00 +0000"
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        let date = dateFormatter.date(from:dateString)!
//        
//        let dateStringTwo = "2020-03-06 02:00:00 +0000"
//        let dateTwo = dateFormatter.date(from:dateStringTwo)!
//        
//        var measuredActivities = [MeasuredActivity]()
//        let motionType = MeasuredActivity.MotionType.walking
//        let distance = 10.0
//        let start = date
//        let end = dateTwo
//        
//        measuredActivities.append(MeasuredActivity(motionType: motionType, distance: distance, start: start, end: end))
//        let value = computeCarbonUsage(measuredActivities: measuredActivities, type: MeasuredActivity.MotionType.walking)
//        var actualValue: Double
//        
//        //10 is the metres travelled (converted to kms) and 200 is the carbon constant
//        actualValue = (10*175)/1000
//        XCTAssert(value == actualValue)
//    }
//    
//    func testGetWeekDayToDisplay() {
//        let day = getWeekDayToDisplay(day: "Tuesday")
//        XCTAssert(day == 3)
//    }
//    
//    func testcombineTodayDateWithInterval() {
//        
//        let dateString = "2020-03-06 01:00:00 +0000"
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        let date = dateFormatter.date(from:dateString)!
//        
//        let hour = "02:00:00"
//        let combinedDate = combineTodayDateWithInterval(date: date, hour: hour)
//        
//        let dateStringCorrect = "2020-03-06 02:00:00 +0000"
//        let dateCorrect = dateFormatter.date(from:dateStringCorrect)!
//        XCTAssert(combinedDate == dateCorrect)
//        }
//    
//    func testGetWeekDayDate() {
//        
//        let weekday = getWeekDayDate(weekDayToDisplay: 2, dayToday: 4)
//        //want to display monday and it is currently wednesday
//        var dateToView = Date()
//        var dateToViewAM = Date()
//       
//        dateToView = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -2, to: dateToView)!
//        dateToViewAM = Calendar.autoupdatingCurrent.date(bySettingHour: 0, minute: 0, second: 0, of: dateToView)!
//        XCTAssert(weekday[0] == dateToViewAM)
//
//}
//    
//     //Need to test monthly queries and yearly queries
//    
//    func testDataIsCorrectlyNormalised() {
//        let date = Date()
//        let activity = MeasuredActivity(motionType: .car, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))
//        appendToDatabase(activity: activity)
//        let result = queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "00:00:00", hourEnd: "24:00:00")
//        
//        let monthNormalisation=normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)
//        
//        XCTAssert(monthNormalisation == result)
//    }
//
//    
//    func testDataisCorrectlyNormalisedWithMultipleValues() {
//        // TODO
//    }
//   
//
//}
//
//
//
