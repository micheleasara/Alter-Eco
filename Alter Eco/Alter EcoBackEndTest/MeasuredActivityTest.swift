import XCTest
import CoreLocation
//@testable import Alter_Eco
@testable import AlterEcoBackend

class MeasuredActivityTest: XCTestCase {
    func testTwoEqualActivitiesResultEqual() {
        let date = Date()
        let activityOne = MeasuredActivity(motionType: .car, distance: 11, start: date, end: Date(timeInterval: 10, since: date))
        let activityTwo = MeasuredActivity(motionType: .car, distance: 11, start: date, end: activityOne.end)
        
        XCTAssert(activityTwo == activityOne, "Expected equality between two activities")
    }
    
    func testTwoDifferentActivitiesResultDifferent() {
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
