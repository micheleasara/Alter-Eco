import XCTest
@testable import AlterEcoBackend

class FoodQuantityTest: XCTestCase {
    
    func testFoodQuantityIsCorrectlyParsedFromString() {
        for unit in Food.Quantity.SUPPORTED_UNITS {
            let qtyStr = "150 " + unit.key
            let quantity = Food.Quantity(quantity: qtyStr)
            XCTAssert(quantity?.value == 150)
            XCTAssert(quantity?.unit == unit.value)
        }
        
        for unit in Food.Quantity.SUPPORTED_UNITS {
            let qtyStr = "15.2" + unit.key
            let quantity = Food.Quantity(quantity: qtyStr)
            XCTAssert(quantity?.value == 15.2)
            XCTAssert(quantity?.unit == unit.value)
        }
    }

    func testFoodQuantityIsNilForInvalidUnits() {
        XCTAssertNil(Food.Quantity(value: 30, unit: "fakeunit"))
    }
    
    func testFoodQuantityIsNilForInvalidNumericValues() {
        XCTAssertNil(Food.Quantity(quantity: "? kg"))
        XCTAssertNil(Food.Quantity(quantity: "*kg"))
    }
}
