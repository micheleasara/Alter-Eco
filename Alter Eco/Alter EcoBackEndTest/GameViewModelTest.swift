import XCTest
@testable import AlterEcoBackend

class GameViewModelTest: XCTestCase {

    var viewModel: GameViewModel!
    let DBMS = DBManagerMock()
    
    override func setUp() {
        super.setUp()
        viewModel = GameViewModel(DBMS: DBMS)
    }

    func testGameIsOffOnInitialization() {
        XCTAssertFalse(viewModel.isGameOn)
    }
    
    func testPointsAreReadFromDBOnInitialization() {
        XCTAssert(DBMS.retrieveLatestScoreCalls == 1)
        XCTAssert(viewModel.currentPoints == 0)
    }
    
    func testSmogStateIsRefreshedWhenGameIsTurnedOn() {
        XCTAssert(DBMS.carbonWithinIntervalTotalArgs.isEmpty)
        viewModel.isGameOn = true
        XCTAssertFalse(DBMS.carbonWithinIntervalTotalArgs.isEmpty)
        XCTAssert(DBMS.carbonWithinIntervalTotalArgs.first!.addingInterval == DAY_IN_SECONDS)
    }
}
