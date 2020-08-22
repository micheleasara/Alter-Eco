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
    
    func simulateScanning(withBarcodes barcodes: Set<String>) {
        let callback = delegateMock.setCodesRetrievalCallbackArgs.last!
        // simulate barcode scanning
        callback(barcodes)
    }
    
    func testAllBarcodesAreFetched() {
        // simulate barcode scanning
        let barcodes = Set(["123", "456", "789"])
        simulateScanning(withBarcodes: barcodes)
        XCTAssert(retrieverMock.fetchFoodArgs.count == barcodes.count)
        
        for arg in retrieverMock.fetchFoodArgs {
            XCTAssert(barcodes.contains(arg.barcode))
        }
    }
    
    func testErrorOccursIfNoBarcodes() {
        XCTAssert(delegateMock.displayErrorAndDismissArgs.isEmpty)
        simulateScanning(withBarcodes: Set<String>())
        XCTAssert(delegateMock.displayErrorAndDismissArgs.count == 1)
    }
    
    func testFoodsAreStoredWhenRetrieved() {
        simulateScanning(withBarcodes: Set(["123"]))
        
        let foodCallback = retrieverMock.fetchFoodArgs.first!.completionHandler
        let food = Food(barcode: "123")
        foodCallback(food, nil)
        XCTAssert(viewModel.retrievedFoods.count == 1)
        XCTAssert(viewModel.retrievedFoods.first == food)
    }
    
    func testFoodsAreStoredWhenNotFoundInDB() {
        simulateScanning(withBarcodes: Set(["123"]))
        
        let foodCallback = retrieverMock.fetchFoodArgs.first!.completionHandler
        foodCallback(nil, .foodNotFound(barcode: "123"))
        XCTAssert(viewModel.foodsNotFound.count == 1)
        XCTAssert(viewModel.foodsNotFound.first?.barcode == "123")
    }
    
    func testCriticalRetrievalErrorsAreReported() {
        simulateScanning(withBarcodes: Set(["123"]))

        let foodCallback = retrieverMock.fetchFoodArgs.first!.completionHandler
        foodCallback(nil, .httpFailure(localizedDescription: "http failure test"))
        foodCallback(nil, .network(localizedDescription: "network failure test"))
        
        XCTAssert(delegateMock.displayErrorAndDismissArgs.count == 2)
        XCTAssert(delegateMock.displayErrorAndDismissArgs[0] == "http failure test")
        XCTAssert(delegateMock.displayErrorAndDismissArgs[1] == "network failure test")
    }
    
    func testCompletionFlagIsSetWhenAllBarcodesHaveBeenLookedUp() {
        let barcodes = Set(["123", "456", "789"])
        simulateScanning(withBarcodes: barcodes)
        
        let foodCallback = retrieverMock.fetchFoodArgs.first!.completionHandler
        for barcode in barcodes {
            XCTAssertFalse(viewModel.retrievalCompleted)
            foodCallback(Food(barcode: barcode), nil)
        }
        XCTAssert(viewModel.retrievalCompleted)
    }
    
    func testStateCanBeReset() {
        let barcodes = Set(["123", "456", "789"])
        simulateScanning(withBarcodes: barcodes)
        
        let foodCallback = retrieverMock.fetchFoodArgs.first!.completionHandler
        barcodes.forEach { foodCallback(Food(barcode: $0), nil) }
        
        viewModel.reset()
        
        XCTAssertFalse(viewModel.retrievalCompleted)
        XCTAssert(viewModel.retrievedFoods.isEmpty)
        XCTAssert(viewModel.foodsNotFound.isEmpty)
        XCTAssert((viewModel.getScannerDelegate() as? ScannerDelegateMock) != delegateMock)
        
    }
}
