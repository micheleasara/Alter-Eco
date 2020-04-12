//import XCTest
//import CoreLocation
//@testable import Alter_Eco
//
//class MeasuredActivityTest: XCTestCase {
//
//    func testAverageOfEquipartitionedMotionTypesResultsInMotionTypeWithHighestWeight() {
//            var measurements = [MeasuredActivity]()
//            var date = Date()
//            for _ in 1...10 {
//                measurements.append(MeasuredActivity(motionType: MeasuredActivity.MotionType.car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
//                date = Date(timeInterval: 10, since: date)
//            }
//        
//            for _ in 1...10 {
//                measurements.append(MeasuredActivity(motionType: MeasuredActivity.MotionType.walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
//                date = Date(timeInterval: 10, since: date)
//            }
//
//            let motionType = MeasuredActivity.getAverageActivityMotionType(measurements: measurements)
//            
//        XCTAssert(motionType == MeasuredActivity.MotionType.car, "Expected car, got " + MeasuredActivity.motionTypeToString(type: .car))
//    }
//    
//    func testAverageMotionTypeWithSufficientlyMoreWalkingResultsInWalking() {
//        var measurements = [MeasuredActivity]()
//        var date = Date()
//        for _ in 1...3 {
//            measurements.append(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
//            date = Date(timeInterval: 10, since: date)
//        }
//    
//        for _ in 1...10 {
//            measurements.append(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
//            date = Date(timeInterval: 10, since: date)
//        }
//
//        let motionType = MeasuredActivity.getAverageActivityMotionType(measurements: measurements)
//        
//        XCTAssert(motionType == .walking, "Expected walking, got " + MeasuredActivity.motionTypeToString(type: .walking))
//    }
//
//    func testAverageMotionTypeWithSufficientlyMoreCarResultsInCar() {
//        var measurements = [MeasuredActivity]()
//        var date = Date()
//        for _ in 1...10 {
//            measurements.append(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
//            date = Date(timeInterval: 10, since: date)
//        }
//    
//        for _ in 1...5 {
//            measurements.append(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
//            date = Date(timeInterval: 10, since: date)
//        }
//
//        let motionType = MeasuredActivity.getAverageActivityMotionType(measurements: measurements)
//        
//        XCTAssert(motionType == .car, "Expected car, got " + MeasuredActivity.motionTypeToString(type: .car))
//    }
//    
//    func testTwoEqualActivitiesResultEqual() {
//        let date = Date()
//        let activityOne = MeasuredActivity(motionType: .car, distance: 11, start: date, end: Date(timeInterval: 10, since: date))
//        let activityTwo = MeasuredActivity(motionType: .car, distance: 11, start: date, end: activityOne.end)
//        
//        XCTAssert(activityTwo == activityOne, "Expected equality between two activities")
//    }
//    
//    func testTwoUnequalActivitiesResultDifferent() {
//        let date = Date()
//        let activityOne = MeasuredActivity(motionType: .car, distance: 11, start: date, end: Date(timeInterval: 10, since: date))
//        let activityTwo = MeasuredActivity(motionType: .car, distance: 11, start: Date(timeInterval: 1000, since: date), end: activityOne.end)
//        
//        XCTAssertFalse(activityTwo == activityOne, "Expected inequality between two activities")
//    }
//    
//    func testAverageActivityFromListResultsIdenticalToSampleProvided() {
//        var measurements = [MeasuredActivity]()
//        var date = Date()
//
//        for _ in 1...3 {
//            measurements.append(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
//            date = Date(timeInterval: 10, since: date)
//        }
//        for _ in 1...10 {
//            measurements.append(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
//            date = Date(timeInterval: 10, since: date)
//        }
//
//        let answer = MeasuredActivity.getAverageActivity(measurements: measurements)
//        // sample answer has sum of distances as distance and start and end date of first and last measurement, respectively
//        let sampleAnswer = MeasuredActivity(motionType: .walking, distance: 1300, start: measurements[0].start, end: measurements.last!.end )
//
//        XCTAssert(answer == sampleAnswer, "Average activity was not computed correctly")
//    }
//    
//    func testDatabaseIOIsConsistent() {
//        let date = Date()
//        let activity = MeasuredActivity(motionType: .car, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))
//
//        appendToDatabase(activity: activity)
//
//        let activityRetrieved = executeQuery(query: NSPredicate(format: "start == %@", date as NSDate))[0]
//
//        XCTAssert(activity == activityRetrieved, "Expected same activity")
//    }
//    
////    func testDailyCarbonValue() {
////
////        let dateString = "2020-03-09 01:00:00 +0000"
////        let dateFormatter = DateFormatter()
////        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
////        let date = dateFormatter.date(from:dateString)!
////
////        let event = MeasuredActivity(motionType: .train, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))
////
////        appendToDatabase(activity: event)
////
////        let result = queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "00:00:00", hourEnd: "02:00:00")
////
////        XCTAssert(result == 110, "No motion in database")
////
////    }
//    
////    func addValuesToDatabase() {
////        
////        let dateString = "2020-03-06 01:00:00 +0000"
////        let dateFormatter = DateFormatter()
////        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
////        let date = dateFormatter.date(from:dateString)!
////        
////        let event = MeasuredActivity(motionType: .car, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))
////                
////        appendToDatabase(activity: event)
////        let eventTwo = MeasuredActivity(motionType: .train, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))
////        appendToDatabase(activity: eventTwo)
////
////        let eventThree = MeasuredActivity(motionType: .walking, distance: 11.0, start: date, end: Date(timeInterval: 10, since: date))
////        appendToDatabase(activity: eventThree)
////        
////        let dateStringTwo = "2020-02-06 01:00:00 +0000"
////        let dateFormatterTwo = DateFormatter()
////        dateFormatterTwo.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
////        let dateTwo = dateFormatterTwo.date(from:dateString)!
////        
////        let eventFour = MeasuredActivity(motionType: .car, distance: 11.0, start: dateTwo, end: Date(timeInterval: 10, since: date))
////
////        appendToDatabase(activity: eventFour)
////        
////        let result = queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "00:00:00", hourEnd: "02:00:00")
////        
////        let dateStringThree = "2018-11-06 01:00:00 +0000"
////        let dateFormatterThree = DateFormatter()
////        dateFormatterThree.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
////        let dateThree = dateFormatterThree.date(from:dateString)!
////        
////        let eventFive = MeasuredActivity(motionType: .car, distance: 11.0, start: dateThree, end: Date(timeInterval: 10, since: date))
////        let eventSix = MeasuredActivity(motionType: .train, distance: 11.0, start: dateThree, end: Date(timeInterval: 10, since: date))
////        let eventSeven = MeasuredActivity(motionType: .train, distance: 11.0, start: dateThree, end: Date(timeInterval: 10, since: date))
////
////        appendToDatabase(activity: eventFive)
////        appendToDatabase(activity: eventSix)
////        appendToDatabase(activity: eventSeven)
////        
////        
//////        XCTAssert(result == 110, "No motion in database")
////        
////    }
//}
