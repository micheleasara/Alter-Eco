import XCTest
@testable import AlterEcoBackend

class TransportPieChartViewModelTest: XCTestCase {

    var viewModel: TransportPieChartViewModel!
    let DBMS = DBManagerMock()
    
    override func setUp() {
        super.setUp()
        viewModel = TransportPieChartViewModel(DBMS: DBMS)
    }

    func testAllPollutingInDBIsUsedToDisplayPie() {
        XCTAssert(DBMS.getFirstDateCalls > 0)
        for motion in DBMS.carbonWithinIntervalMotionTypes {
            XCTAssert(motion.isPolluting())
        }
        XCTAssert(MeasuredActivity.MotionType.allCases.filter{$0.isPolluting()}.count == DBMS.carbonWithinIntervalMotionTypes.count)
    }
}
