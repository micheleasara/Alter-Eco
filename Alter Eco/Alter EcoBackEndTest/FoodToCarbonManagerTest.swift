import XCTest
import NaturalLanguage
@testable import AlterEcoBackend

class FoodToCarbonManagerTest: XCTestCase {
    
    let manager = FoodToCarbonManager()
    let types = FoodToCarbonManager.getAvailableTypes()
    
    func testCarbonComputationIsConsistentForDifferentUnits() {
        let foodsKg = [
            Food(barcode: "123", quantity: Food.Quantity(value: 1, unit: UnitMass.kilograms), types: types),
            Food(barcode: "321", quantity: Food.Quantity(value: 3, unit: UnitMass.kilograms), types: types)
        ]
        let foodsGrams =  [
            Food(barcode: "456", quantity: Food.Quantity(value: 1000, unit: UnitMass.grams), types: types),
            Food(barcode: "654", quantity: Food.Quantity(value: 3000, unit: UnitMass.grams), types: types)
        ]
        
        XCTAssert(manager.getCarbon(fromFoods: foodsKg) == manager.getCarbon(fromFoods: foodsGrams))
    }

    func testCarbonIsComputedInKg() {
        // using 1000g = 1kg as carbon density is kgCo2/kg
        let food = Food(barcode: "123", quantity: Food.Quantity(value: 1000, unit: UnitMass.grams), types: types)
        let expected = FoodToCarbonManager.getTypeInfo(types.first!)!
        let result = manager.getCarbon(fromFood: food)!
        XCTAssert(expected.carbonDensity == result.value)
        XCTAssert(result.unit == UnitMass.kilograms)
    }
    
    func testUsingATypeAsKeywordReturnsSameTypeAsMostLikely() {
        // this test is by far the slowest, so faster alternatives would be an improvement
        for type in FoodToCarbonManager.getAvailableTypes() {
            let results = manager.keywordsToTypes(type.components(separatedBy: " "))
            let result = results.first!
            XCTAssert(result == type, "result = \(result)\nfirst = \(type)")
        }
    }
    
    func testCarbonOfBeveragesIsComputedUsingDensities() {
        let food = Food(barcode: "123", quantity: Food.Quantity(value: 1000, unit: UnitVolume.milliliters), types: ["water"])
        let density = manager.liquidsDensities["water"]!
        let expected = FoodToCarbonManager.getTypeInfo("water")!.carbonDensity * density
        let result = manager.getCarbon(fromFood: food)!
        XCTAssert(expected == result.value)
        XCTAssert(result.unit == UnitMass.kilograms)
    }
    
    func testCarbonIsNilIfInsufficientInfo() {
        let food = Food(barcode: "123")
        XCTAssertNil(manager.getCarbon(fromFood: food))
        food.setAsMostLikelyType(types.first!)
        XCTAssertNil(manager.getCarbon(fromFood: food))
        food.quantity = Food.Quantity(value: 300, unit: UnitMass.grams)
        food.setAsMostLikelyType("non existant type")
        XCTAssertNil(manager.getCarbon(fromFood: food))
    }
    
    func testURLModelInBundleIsValid() {
        XCTAssertNoThrow(try NLEmbedding(contentsOf: FoodToCarbonManager.urlOfModelInThisBundle))
    }
}
