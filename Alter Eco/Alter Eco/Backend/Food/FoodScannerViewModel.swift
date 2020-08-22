import SwiftUI
import AVFoundation

// NOTE: - the point of the scanner delegate protocol is mainly to allow for mocking
// the view model can instantiate a delegate when necessary (so as not to keep it memory)

/// Responsible for coordinating the barcode scanning process using a camera feed.
public protocol ScannerDelegate: AVCaptureMetadataOutputObjectsDelegate where Self: UIViewController {
    /// Sets the function to be called when all barcodes have been scanned.
    func setCodesRetrievalCallback(_ callback: @escaping (Set<String>) -> Void)
    /// Displays a spinner to signify work in progress.
    func displayWaitingSpinner()
    /// To be called when a runtime AVError occurs.
    func onRuntimeAVError(error: AVError)
    /// Displays an error alert and dismisses the view.
    func displayErrorAndDismiss(withMessage: String)
    /// Initializes a new instance of the delegate.
    init()
}

/**
 View model for the food scanning process. Responsible for retrieving all food information from the scanned barcodes.
 Generic parameter corresponds to a scanner delegate which is instantiated when necessary.
 */
public class FoodScannerViewModel<T: ScannerDelegate>: ObservableObject {
    /// The list of retrieved food items which have been retrieved so far.
    public private(set) var retrievedFoods: [Food] = []
    /// The list of food items which could not be retrieved as not present in the database.
    public private(set) var foodsNotFound: [Food] = []
    // Using internal(set) to allow for Binding
    /// Determines if the retrieval process has been completed.
    @Published public internal(set) var retrievalCompleted = false
    
    private var numFoodsToRetrieve = 0
    private let foodRetriever: RemoteFoodRetriever
    private var scannerDelegate: ScannerDelegate?
    
    /**
     Initializes a new instance the view model for the food scanner.
     - Parameter foodRetriever: the object which will be used to retrieve food information from a barcode.
     - Parameter scannerDelegate: the controller associated with the barcode scanning process. If nil, the controller will be instantiated when needed.
     */
    public init(foodRetriever: RemoteFoodRetriever, scannerDelegate: T? = nil) {
        self.foodRetriever = foodRetriever
        self.scannerDelegate = scannerDelegate
        self.scannerDelegate?.setCodesRetrievalCallback(onCodesRetrieval)
    }
    
    /**
     Resets the state of this view model.
     - Parameter scannerDelegate: the new controller associated with the barcode scanning process. If nil, the controller will be instantiated when needed.
     */
    public func reset(scannerDelegate: T? = nil) {
        self.scannerDelegate = scannerDelegate
        retrievedFoods.removeAll()
        foodsNotFound.removeAll()
        retrievalCompleted = false
    }
    
    /// Returns the current controller associated with the barcode scanning process. If no controller exists, it is instantiated.
    public func getScannerDelegate() -> ScannerDelegate {
        if scannerDelegate == nil {
            scannerDelegate = T()
            scannerDelegate?.setCodesRetrievalCallback(onCodesRetrieval)
        }
        return scannerDelegate ?? T()
    }
    
    private func onCodesRetrieval(codes: Set<String>) {
        if !codes.isEmpty {
            numFoodsToRetrieve = codes.count
            scannerDelegate?.displayWaitingSpinner()
            for code in codes {
                foodRetriever.fetchFood(barcode: code, completionHandler: { [weak self] food, error in
                    if Thread.isMainThread {
                        self?.onFoodRetrieval(food: food, error: error)
                    } else {
                        DispatchQueue.main.sync {
                            self?.onFoodRetrieval(food: food, error: error)
                        }
                    }
                })
            }
        } else {
            scannerDelegate?.displayErrorAndDismiss(withMessage: "Could not read barcodes.")
        }
    }
    
    private func onFoodRetrieval(food: Food?, error: RemoteFoodRetrievalError?) {
        if let food = food {
            retrievedFoods.append(food)
        } else if let error = error {
            switch error {
            case .network(localizedDescription: let description):
                scannerDelegate?.displayErrorAndDismiss(withMessage: description)
            case .httpFailure(localizedDescription: let description):
                scannerDelegate?.displayErrorAndDismiss(withMessage: description)
            case .foodNotFound(barcode: let barcode):
                foodsNotFound.append(Food(barcode: barcode))
            }
        }
        
        let retrieved = retrievedFoods.count + foodsNotFound.count
        if retrieved >= numFoodsToRetrieve {
            retrievalCompleted = true
        }
    }
}
