import SwiftUI
import AVFoundation

/// Connects SwiftUI to UIKit and is responsible for coordinating the scanner and food retrieval calls.
public struct ScannerView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = ScannerDelegate
    @Environment(\.presentationMode) var presentationMode
    @Binding var foodListModel: FoodListViewModel
    @State private var retrievedFoods: [Food] = []
    @State private var numFoodsToRetrieve = 0
    @State private var foodsNotFound: [Food] = []
    private let foodRetriever: RemoteFoodRetriever = OpenFoodFacts()
    private let controller = ScannerDelegate()

    public func makeUIViewController(context: Context) -> ScannerDelegate {
        controller.setCodesRetrievalCallback(onCodesRetrieval)
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: ScannerDelegate, context: Context) {}
        
    private func onCodesRetrieval(codes: Set<String>) {
        if codes.count > 0 {
            numFoodsToRetrieve = codes.count
            controller.displayWaitingSpinner()
            for code in codes {
                foodRetriever.fetchFood(barcode: code, completionHandler: onFoodRetrieval(food:error:))
            }
        } else {
            controller.displayErrorAndDismiss(error: IdentifiableError(localizedDescription: "Could not read barcodes."))
        }
    }
    
    private func onFoodRetrieval(food: Food?, error: RemoteFoodRetrievalError?) {
        if let food = food {
            retrievedFoods.append(food)
        } else if let error = error {
            switch error {
            case .network(localizedDescription: let description):
                controller.displayErrorAndDismiss(error: IdentifiableError(localizedDescription: description))
            case .httpFailure(localizedDescription: let description):
                controller.displayErrorAndDismiss(error: IdentifiableError(localizedDescription: description))
            case .foodNotFound(barcode: let barcode):
                foodsNotFound.append(Food(barcode: barcode))
            }
        }
        
        let retrieved = retrievedFoods.count + foodsNotFound.count
        if retrieved >= numFoodsToRetrieve {
            foodListModel.update(foods: retrievedFoods, notFound: foodsNotFound)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

/// Represents the UIKit graphical interface that overlaps the camera feed and forwards barcodes read by the scanner.
public class ScannerDelegate: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var scanner: BarcodeScanner?
    private var callback: (Set<String>) -> Void = { food in }
    
    private var itemReadLabel = UILabel()
    private var labelDisappearWorker: DispatchWorkItem?
    private var continueButton = UIButton(type: .system)
    private var blurView: UIVisualEffectView? = nil
    private var spinner: UIActivityIndicatorView? = nil
    private var errorAlert: UIAlertController? = nil
    
    private var scannedCodes = Set<String>()
    
    /// Sets the function to be called when all barcodes have been scanned.
    public func setCodesRetrievalCallback(_ callback: @escaping (Set<String>) -> Void) {
        self.callback = callback
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        // spinner is used to show loading to the user
        // if not nil, it means this is not the first time this view has appeared
        if spinner == nil {
            do {
                self.scanner = try BarcodeScanner(withDelegate: self)
                setFocusArea()
                addControls()
                scanner?.startScanning()
            } catch let e as IdentifiableError {
                displayErrorAndDismiss(error: e)
            } catch {
                let error = IdentifiableError(localizedDescription: "An error occurred while loading the scanner.")
                displayErrorAndDismiss(error: error)
            }
        }
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        
        guard let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let scannedValue = readableObject.stringValue else { return }
        scannedCodes.insert(scannedValue)
        notifyUserOfScan(withBarcode: scannedValue)
        
        if continueButton.isHidden {
            continueButton.isHidden = false
        }
    }
    
    public func displayWaitingSpinner() {
        if spinner == nil {
            spinner = UIActivityIndicatorView(style: .large)
        }
        
        view.subviews.forEach{ $0.removeFromSuperview() }
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        spinner!.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        spinner!.startAnimating()
        view.addSubview(spinner!)
    }
    
    public func onRuntimeAVError(error: AVError) {
        displayErrorAndDismiss(error: IdentifiableError(localizedDescription: error.localizedDescription))
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // update layout once the screen has finished rotating
        coordinator.animate(alongsideTransition: nil) {_ in
            if self.spinner == nil { // camera should only appear if the spinner is not on screen
                self.scanner?.updateVideoLayout()
                self.setFocusArea()
                let buttonVisible = self.continueButton.isHidden
                self.continueButton.removeFromSuperview()
                self.itemReadLabel.removeFromSuperview()
                self.addControls()
                self.continueButton.isHidden = buttonVisible
            } else { // adjust spinner
                self.displayWaitingSpinner()
            }
        }
    }
    
    /// Displays an error alert and dismisses the view in a thread-safe way.
    public func displayErrorAndDismiss(error: LocalizedError) {
        // Errors are displayed through UIKit, rather than SwiftUI, to avoid presentation warnings
        if Thread.isMainThread {
            unsafeDisplayErrorAndDismiss(error: error)
        } else { // run gui code on main thread
            DispatchQueue.main.sync {
                unsafeDisplayErrorAndDismiss(error: error)
            }
        }
    }
    
    private func unsafeDisplayErrorAndDismiss(error: LocalizedError) {
        if let alert = errorAlert {
            // do not attempt displaying a second alert if one is already being shown
            guard !alert.isBeingPresented else { return }
        }
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { _ in self.dismiss(animated: true, completion: nil) }
        errorAlert = UIAlertController(title: "Error",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        errorAlert!.addAction(defaultAction)
        
        // remove spinner if visible
        if let spinner = spinner {
            spinner.isHidden = true
        }
        
        self.present(errorAlert!, animated: true)
    }
    
    private func addControls() {
        itemReadLabel.textAlignment = .center
        itemReadLabel.isHidden = true
        view.addSubview(itemReadLabel)
        
        continueButton.setAttributedTitle(getStyledText(text: "Done"), for: .normal)
        continueButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        continueButton.titleLabel?.adjustsFontForContentSizeCategory = true
        continueButton.addTarget(self, action: #selector(self.onButtonTapped(sender:)), for: .touchUpInside)
        continueButton.sizeToFit()
        continueButton.center = CGPoint(x: view.bounds.maxX - (continueButton.frame.size.width / 2) - 10,
                                                   y: view.bounds.maxY - (continueButton.frame.size.height / 2) - 10 )
        continueButton.isHidden = true
        view.addSubview(continueButton)
    }
    
    @objc
    private func onButtonTapped(sender: UIButton) {
        scanner?.stopScanning()
        callback(scannedCodes)
    }
    
    private func notifyUserOfScan(withBarcode code: String) {
        if let labelDisappearWorker = labelDisappearWorker {
            // do not make the label invisible if we just got an update
            labelDisappearWorker.cancel()
            itemReadLabel.isHidden = false
        }
        itemReadLabel.attributedText = getStyledText(text: "✅ read " + code)
        itemReadLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        itemReadLabel.adjustsFontForContentSizeCategory = true
        itemReadLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        itemReadLabel.sizeToFit()
        labelDisappearWorker = DispatchWorkItem { self.itemReadLabel.isHidden = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: labelDisappearWorker!)
    }
    
    private func getStyledText(text: String) -> NSAttributedString {
        let textAttributes: [NSAttributedString.Key : Any] = [.strokeColor : UIColor.black,
                                                              .foregroundColor : UIColor.white,
                                                              .strokeWidth : -2.0]
        return NSAttributedString(string: text, attributes: textAttributes)
    }
    
    private func setFocusArea() {
        // create custom shape: the whole screen minus a square in the middle
        let bounds = view.bounds
        let shapeLayerPath = CAShapeLayer()
        let focusShapeSide = 0.7*min(bounds.height, bounds.width)
        let focusShape = CGRect(x: bounds.midX - focusShapeSide/2, y: bounds.midY - focusShapeSide/2,
                                width: focusShapeSide, height: focusShapeSide)
        let focusShapePath = UIBezierPath(rect: focusShape)
        let screenShapePath = UIBezierPath(rect: bounds)
        screenShapePath.usesEvenOddFillRule = true
        screenShapePath.append(focusShapePath)
        shapeLayerPath.path = screenShapePath.cgPath
        shapeLayerPath.fillRule = .evenOdd

        // blur camera feed following the custom shape created above (i.e. blur everything but the square)
        blurView?.removeFromSuperview()
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView?.layer.mask = shapeLayerPath
        blurView?.frame = bounds
        blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView?.alpha = 0.6
        
        // make scan possible only through focusShape and display everything
        scanner?.setScanArea(area: focusShape)
        view.addSubview(blurView!)
    }
}
