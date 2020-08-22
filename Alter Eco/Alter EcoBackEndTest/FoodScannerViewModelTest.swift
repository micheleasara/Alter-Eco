import XCTest
@testable import AlterEcoBackend

class FoodScannerViewModelTest: XCTestCase {

    let retrieverMock = RemoteFoodRetrieverMock()
    let delegateMock = ScannerDelegateMock()
    var viewModel: FoodScannerViewModel<ScannerDelegateMock>!
    
    override func setUp() {
        super.setUp()
        viewModel = FoodScannerViewModel(foodRetriever: retrieverMock, scannerDelegate: delegateMock)
    }

    func testCallbackIsSetOnInitialization() {
        XCTAssert(delegateMock.setCodesRetrievalCallbackArgs.count == 1)
    }
    
    func testDelegateIsConfiguredIfNotPresentWhenRetrieved() {
        viewModel = FoodScannerViewModel(foodRetriever: retrieverMock, scannerDelegate: nil)
        let retrievedDelegate = viewModel.getScannerDelegate() as! ScannerDelegateMock
        XCTAssert(retrievedDelegate != delegateMock)
        XCTAssert(retrievedDelegate.setCodesRetrievalCallbackArgs.count == 1)
    }
    
    func testAllBarcodesAreFetched() {
        let callback = delegateMock.setCodesRetrievalCallbackArgs.first!
        // simulate barcode scanning
        let barcodes = Set(["123", "456", "789"])
        callback(barcodes)
        XCTAssert(retrieverMock.fetchFoodArgs.count == barcodes.count)
        
        for arg in retrieverMock.fetchFoodArgs {
            XCTAssert(barcodes.contains(arg.barcode))
        }
    }
    
    func testFoodsAreSavedWhenRetrieved() {
        let barcodeCallback = delegateMock.setCodesRetrievalCallbackArgs.first!
        barcodeCallback(Set(["123"]))
        
        let foodCallback = retrieverMock.fetchFoodArgs.first!.completionHandler
        let food = Food(barcode: "123")
        foodCallback(food, nil)
        XCTAssert(viewModel.retrievedFoods.count == 1)
        XCTAssert(viewModel.retrievedFoods.first! == food)
    }
}
