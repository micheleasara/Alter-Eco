import XCTest
@testable import AlterEcoBackend

class FoodRetrievalErrorsTest: XCTestCase {

    func testErrorDescriptionIsConsistent() {
        XCTAssert(RemoteFoodRetrievalError.foodNotFound(barcode: "test").localizedDescription == "test")
        XCTAssert(RemoteFoodRetrievalError.httpFailure(localizedDescription: "test2").localizedDescription == "test2")
        XCTAssert(RemoteFoodRetrievalError.network(localizedDescription: "test3").localizedDescription == "test3")
    }

}
