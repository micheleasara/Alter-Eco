import XCTest
@testable import AlterEcoBackend

class FoodListViewModelTest: XCTestCase {
    
    let uploaderMock = RemoteFoodUploaderMock()
    let converterMock = FoodToCarbonConverterMock()
    let DBMS = DBManagerMock()
    var viewModel: FoodListViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = FoodListViewModel(converter: converterMock, uploader: uploaderMock, DBMS: DBMS)
    }

    func testUpdatingWithNewFoodsPutsThemInRightCategory() {
        let foods = [Food(barcode: "123", types: ["steak"]),
        Food(barcode: "456", name: "Chips!!")]
        let notFound = [Food(barcode: "789")]
        viewModel.update(foods: foods, notFound: notFound)
        XCTAssert(viewModel.productsNotInDB == notFound)
        XCTAssert(viewModel.productsWithTypes == [foods.first!])
        XCTAssert(viewModel.typelessProducts == [foods.last!])
    }
    
    func testUpdatingPutsFoodsAlreadyPresentInRightCategory() {
        let foods = [Food(barcode: "123", types: ["steak"]),
               Food(barcode: "456", name: "Chips!!")]
        let notFound = [Food(barcode: "789")]
        viewModel.update(foods: foods, notFound: notFound)
        
        foods.last!.setAsMostLikelyType("broccoli")
        notFound.last!.setAsMostLikelyType("cabbage")
        viewModel.update()
        XCTAssert(viewModel.productsNotInDB.isEmpty)
        XCTAssert(viewModel.typelessProducts.isEmpty)
        XCTAssert(viewModel.productsWithTypes.count == foods.count + notFound.count)
    }
    
    func testFoodsWithSameBarcodeCanBeRemoved() {
        let foods = [Food(barcode: "123", types: ["steak"]),
        Food(barcode: "123", name: "Chips!!")]
        let notFound = [Food(barcode: "123")]
        viewModel.update(foods: foods, notFound: notFound)
        viewModel.removeFood(withBarcode: "123")
        XCTAssert(viewModel.productsNotInDB.isEmpty)
        XCTAssert(viewModel.productsWithTypes.isEmpty)
        XCTAssert(viewModel.typelessProducts.isEmpty)
    }
    
    func testFoodsCanBeRemovedBasedOnIndex() {
        let foods = [Food(barcode: "123", types: ["steak"]),
                     Food(barcode: "456", types: ["chicken"]),
        Food(barcode: "1516", name: "typeless1"),
        Food(barcode: "1517", name: "typeless2")]
        let notFound = [Food(barcode: "789"), Food(barcode: "1011")]
        viewModel.update(foods: foods, notFound: notFound)
        
        viewModel.removeTypeless(at: 1)
        XCTAssert(viewModel.typelessProducts == [foods[2]])
        
        viewModel.removeProductNotInDB(at: 1)
        XCTAssert(viewModel.productsNotInDB == [notFound[0]])
        
        viewModel.removeProductWithType(at: 0)
        XCTAssert(viewModel.productsWithTypes == [foods[1]])
    }
    
    func testModelUsesConverterForCarbon() {
        let food = Food(barcode: "123")
        _ = viewModel.getCarbon(forFood: food)
        XCTAssert(converterMock.getCarbonArgs == [food])
    }
    
    func testModelUsesUploaderToUploadInfo() {
        let food = Food(barcode: "123")
        viewModel.uploadProductInfo(food: food)
        XCTAssert(uploaderMock.uploadArgs.count == 1)
        XCTAssert(uploaderMock.uploadArgs.first?.food == food)
    }
    
    func testOnlyProductsWithTypesAreSaved() {
        let foods = [Food(barcode: "123", quantity: Food.Quantity(value: 150, unit: UnitMass.grams), types: ["steak"]),
                     Food(barcode: "456", quantity: Food.Quantity(value: 250, unit: UnitMass.grams), types: ["chicken"]),
        Food(barcode: "1516", name: "typeless1"),
        Food(barcode: "1517", name: "typeless2")]
        let notFound = [Food(barcode: "789"), Food(barcode: "1011")]
        viewModel.update(foods: foods, notFound: notFound)
        let withTypes = viewModel.productsWithTypes
        viewModel.save()
        XCTAssert(DBMS.appendFoodsArgs.count == 1)
        XCTAssert(DBMS.appendFoodsArgs.first!.foods == withTypes)
    }
    
    func testFoodsWithNoQuantityAreSavedWithDefaultQuantity() {
        let foods = [Food(barcode: "123", types: ["steak"]),
                     Food(barcode: "456", types: ["chicken"])]
        viewModel.update(foods: foods, notFound: [])
        viewModel.save()
        XCTAssertFalse(DBMS.appendFoodsArgs.first!.foods == foods)
        foods.forEach { $0.quantity = viewModel.defaultQuantity }
        XCTAssert(DBMS.appendFoodsArgs.first!.foods == foods)
    }
}
