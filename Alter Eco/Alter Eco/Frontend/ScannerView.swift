import SwiftUI
import AVFoundation

/// Connects SwiftUI to UIKit and represents the interface for the barcode scanning of food products.
public struct FoodScannerView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = ScannerViewController
    @Environment(\.presentationMode) public var presentationMode
    @ObservedObject public var viewModel: FoodScannerViewModel<ScannerViewController>
    // binding required to ensure updateUIViewController is called once a published value is set
    @Binding public var retrievalCompleted: Bool
    
    public func makeUIViewController(context: Context) -> ScannerViewController {
        if let scannerDelegate = viewModel.getScannerDelegate() as? ScannerViewController {
            return scannerDelegate
        } else {
            // only other alternative I could think of to allow
            // for testing like we do here with a protocol, was making
            // an abstract class that was then implemented by the controller class
            fatalError("Could not cast into controller for food scanning.")
        }
    }
    
    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        if retrievalCompleted {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

/// Controller for the UIKit graphical interface and the camera feed. Responsible forwarding barcodes read by the scanner.
public class ScannerViewController: UIViewController, ScannerDelegate {
    private var scanner: BarcodeScanner?
    private var callback: ((Set<String>) -> Void)?
    
    private var itemReadLabel = UILabel()
    private var labelDisappearWorker: DispatchWorkItem?
    private var continueButton = UIButton(type: .system)
    private var blurView: UIVisualEffectView? = nil
    private var spinner: UIActivityIndicatorView? = nil
    private var errorAlert: UIAlertController? = nil
    
    private var scannedCodes = Set<String>()
    
    public func setCodesRetrievalCallback(_ callback: @escaping (Set<String>) -> Void) {
        self.callback = callback
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        // spinner is used to show loading to the user
        // if not nil, it means this is not the first time this view has appeared
        if spinner == nil {
            do {
                self.scanner = try BarcodeScanner(withController: self)
                setFocusArea()
                addControls()
                scanner?.startScanning()
            } catch let e as LocalizedError {
                displayErrorAndDismiss(withMessage: e.localizedDescription)
            } catch {
                displayErrorAndDismiss(withMessage: "An error occurred while loading the scanner.")
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
        displayErrorAndDismiss(withMessage: error.localizedDescription)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // update layout once the screen has finished rotating
        coordinator.animate(alongsideTransition: nil) {[weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.spinner == nil { // camera should only appear if the spinner is not on screen
                strongSelf.scanner?.updateVideoLayout()
                strongSelf.setFocusArea()
                let buttonVisible = strongSelf.continueButton.isHidden
                strongSelf.continueButton.removeFromSuperview()
                strongSelf.itemReadLabel.removeFromSuperview()
                strongSelf.addControls()
                strongSelf.continueButton.isHidden = buttonVisible
            } else { // adjust spinner
                strongSelf.displayWaitingSpinner()
            }
        }
    }
    
    /// Displays an error alert and dismisses the view in a thread-safe way.
    public func displayErrorAndDismiss(withMessage message: String) {
        // Errors are displayed through UIKit, rather than SwiftUI, to avoid presentation warnings
        if Thread.isMainThread {
            unsafeDisplayErrorAndDismiss(message: message)
        } else { // run gui code on main thread
            DispatchQueue.main.sync {
                unsafeDisplayErrorAndDismiss(message: message)
            }
        }
    }
    
    // caution: this method is not thread safe
    private func unsafeDisplayErrorAndDismiss(message: String) {
        if let alert = errorAlert {
            // do not attempt displaying a second alert if one is already being shown
            guard !alert.isBeingPresented else { return }
        }
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in self?.dismiss(animated: true, completion: nil) }
        errorAlert = UIAlertController(title: "Error",
                                      message: message,
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
        callback?(scannedCodes)
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
        labelDisappearWorker = DispatchWorkItem { [weak self] in
            self?.itemReadLabel.isHidden = true }
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
