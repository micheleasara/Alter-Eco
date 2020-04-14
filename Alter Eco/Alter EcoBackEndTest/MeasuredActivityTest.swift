import XCTest
import CoreLocation
@testable import Alter_Eco

class MeasuredActivityTest: XCTestCase {
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
    
    func testTwoEqualActivitiesResultEqual() {
        let date = Date()
        let activityOne = MeasuredActivity(motionType: .car, distance: 11, start: date, end: Date(timeInterval: 10, since: date))
        let activityTwo = MeasuredActivity(motionType: .car, distance: 11, start: date, end: activityOne.end)
        
        XCTAssert(activityTwo == activityOne, "Expected equality between two activities")
    }
    
    func testTwoUnequalActivitiesResultDifferent() {
        let date = Date()
        let activityOne = MeasuredActivity(motionType: .car, distance: 11, start: date, end: Date(timeInterval: 10, since: date))
        let activityTwo = MeasuredActivity(motionType: .car, distance: 11, start: Date(timeInterval: 1000, since: date), end: activityOne.end)
        
        XCTAssertFalse(activityTwo == activityOne, "Expected inequality between two activities")
    }

    func testStringToMotionTypeIsBiunivocal() {
        for type in MeasuredActivity.MotionType.allCases {
            let str = MeasuredActivity.motionTypeToString(type: type)
            XCTAssert(type == MeasuredActivity.stringToMotionType(type: str))
        }
    }
}
