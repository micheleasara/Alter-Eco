import XCTest
@testable import AlterEcoBackend

class ChartDataModelTest: XCTestCase {
    var DBMS: DBManagerMock!
    var model: TransportBarChartViewModel!
    let limit = Date(timeIntervalSince1970: 0)
    let dateFormatter = DateFormatter()
    
    override func setUp() {
        super.setUp()
        DBMS = DBManagerMock()
        model = TransportBarChartViewModel(limit: limit, DBMS: DBMS)
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
    }
    
    func testRetrievesDailyDataWithSpecifiedGranularity() {
        // function is called during model initialization
        // so record an offset before recalling it
        let offset = DBMS.carbonWithinIntervalFroms.count
        _ = model.dailyDataUpTo(limit)
        
        let carbonByTransport = model.carbonBreakdown[.day]!
        let entriesInADay = 24/model.HOUR_GRANULARITY
        for motion in MeasuredActivity.MotionType.allCases {
            XCTAssert(carbonByTransport[motion]!.count == entriesInADay,
                      MeasuredActivity.motionTypeToString(type: motion) + " entries do not match")
        }
        
        let expectedInterval = Double(model.HOUR_GRANULARITY) * HOUR_IN_SECONDS
        var expectedFrom = limit.toLocalTime().setToSpecificHour(hour: "00:00:00")!.toGlobalTime()

        for i in 0..<entriesInADay {
            let interval = DBMS.carbonWithinIntervalIntervals[offset+i]
            XCTAssert(interval == expectedInterval,
                      String(format: "actual: %f, expected: %f", interval, expectedInterval))
            
            let from = DBMS.carbonWithinIntervalFroms[offset+i]
            XCTAssert(from == expectedFrom,
                      String(format: "actual: %@, expected: %@", dateFormatter.string(from: from), dateFormatter.string(from: expectedFrom)))
            expectedFrom = expectedFrom.addingTimeInterval(expectedInterval)
        }
    }
    
    func testRetrievesWeeklyDataWithSpecifiedMargins() {
        // function is called during model initialization
        // so record an offset before recalling it, so we can check that calls to DBMS.carbonWithinInterval
        // are passed the right parameters
        let offset = DBMS.carbonWithinIntervalFroms.count
        _ = model.weeklyDataUpTo(limit)
        
        let carbonByTransport = model.carbonBreakdown[.week]!
        let entriesCount = model.WEEKDAYS_SHOWN
        for motion in MeasuredActivity.MotionType.allCases {
            XCTAssert(carbonByTransport[motion]!.count == entriesCount,
                      MeasuredActivity.motionTypeToString(type: motion) + " entries do not match")
        }
        
        var expectedInterval = DAY_IN_SECONDS
        var expectedFrom = limit.toLocalTime().setToSpecificHour(hour: "00:00:00")!.toGlobalTime()
        expectedFrom = expectedFrom.addingTimeInterval(
            -Double(model.WEEKDAYS_SHOWN-1) * DAY_IN_SECONDS)

        for i in 0..<entriesCount {
            // intervals are always 24h with the exception of the last
            // as it is the difference between the current time (limit) and the previous day
            if (i == entriesCount - 1) {
                expectedInterval = limit.timeIntervalSince(expectedFrom)
            }
            let interval = DBMS.carbonWithinIntervalIntervals[offset+i]
            print(interval)
            XCTAssert(interval == expectedInterval,
                      String(format: "actual: %f, expected: %f", interval, expectedInterval))
            
            let from = DBMS.carbonWithinIntervalFroms[offset+i]
            print(from)
            XCTAssert(from == expectedFrom,
                      String(format: "actual: %@, expected: %@", dateFormatter.string(from: from), dateFormatter.string(from: expectedFrom)))
            expectedFrom = expectedFrom.addingTimeInterval(expectedInterval)
        }
    }
    
    func testRetrievesMonthlyDataWithSpecifiedMargins() {
        // function is called during model initialization
        // so record an offset before recalling it
        let offset = DBMS.carbonWithinIntervalFroms.count
        _ = model.monthlyDataUpTo(limit)
        
        let carbonByTransport = model.carbonBreakdown[.month]!
        let entriesCount = model.MONTHS_SHOWN
        for motion in MeasuredActivity.MotionType.allCases {
            XCTAssert(carbonByTransport[motion]!.count == entriesCount,
                      MeasuredActivity.motionTypeToString(type: motion) + " entries do not match")
        }
        
        var expectedFrom = limit.toLocalTime().setToSpecificHour(hour: "00:00:00")!.toGlobalTime()
        expectedFrom = expectedFrom.addMonths(numMonthsToAdd: -(model.MONTHS_SHOWN - 1))
        for i in 0..<entriesCount {
            let monthAfter = expectedFrom.addMonths(numMonthsToAdd: 1)
            let expectedInterval = (i == entriesCount - 1) ? limit.timeIntervalSince(expectedFrom) : monthAfter.timeIntervalSince(expectedFrom)
            
            let interval = DBMS.carbonWithinIntervalIntervals[offset+i]
            XCTAssert(interval == expectedInterval,
                      String(format: "actual: %f, expected: %f", interval, expectedInterval))
            
            let from = DBMS.carbonWithinIntervalFroms[offset+i]
            XCTAssert(from == expectedFrom,
                      String(format: "actual: %@, expected: %@", dateFormatter.string(from: from), dateFormatter.string(from: expectedFrom)))
            expectedFrom = monthAfter
        }
    }
    
    func testRetrievesYearlyDataWithSpecifiedMargins() {
        // function is called during model initialization
        // so record an offset before recalling it
        let offset = DBMS.carbonWithinIntervalFroms.count
        _ = model.yearlyDataUpTo(limit)
        
        let carbonByTransport = model.carbonBreakdown[.year]!
        let entriesCount = model.YEARS_SHOWN
        for motion in MeasuredActivity.MotionType.allCases {
            XCTAssert(carbonByTransport[motion]!.count == entriesCount,
                      MeasuredActivity.motionTypeToString(type: motion) + " entries do not match")
        }
        
        var expectedFrom = limit.setToSpecificHour(hour: "00:00:00")!
        expectedFrom = expectedFrom.addMonths(numMonthsToAdd: -12 * (model.YEARS_SHOWN - 1))
        
        for i in 0..<entriesCount {
            let yearAfter = expectedFrom.addMonths(numMonthsToAdd: 12)
            let expectedInterval = (i == entriesCount - 1) ? limit.timeIntervalSince(expectedFrom) : yearAfter.timeIntervalSince(expectedFrom)
            let interval = DBMS.carbonWithinIntervalIntervals[offset+i]
            XCTAssert(interval == expectedInterval,
                      String(format: "actual: %f, expected: %f", interval, expectedInterval))
            
            let from = DBMS.carbonWithinIntervalFroms[offset+i]
            XCTAssert(from == expectedFrom,
                      String(format: "actual: %@, expected: %@", dateFormatter.string(from: from), dateFormatter.string(from: expectedFrom)))
            expectedFrom = yearAfter
        }
    }
}
