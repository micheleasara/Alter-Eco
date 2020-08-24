import XCTest
@testable import AlterEcoBackend

class FoodPieChartViewModelTest: XCTestCase {

    var viewModel: FoodPieChartViewModel!
    let DBMS = DBManagerMock()
    
    override func setUp() {
        super.setUp()
        viewModel = FoodPieChartViewModel(DBMS: DBMS)
    }

    func testAllFoodCategoriesAreUsedToDisplayPie() {
        var categories: [String] = []
        for functionArguments in DBMS.carbonFromFoodsArgs {
            // get only categories used in queries
            for queryArg in functionArguments.args! {
                if let category = queryArg as? String {
                        categories.append(category)
                }
            }
        }
        
        for category in Food.Category.allCases {
            XCTAssert(categories.contains(category.rawValue), "\(category.rawValue) missing from \(categories)")
        }
    }
}
