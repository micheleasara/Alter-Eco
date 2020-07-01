import Foundation
import AVFoundation
import SwiftUI

/// Represents a live camera scanner to detect a list of barcodes.
public class BarcodeScanner: NSObject {
    private var captureSession : AVCaptureSession?
    private var delegate: ScannerDelegate!
    private let sessionQueue = DispatchQueue(label: "com.altereco.sessionqueue")
    private var previewLayer: AVCaptureVideoPreviewLayer? = nil
    private var metadataOut: AVCaptureMetadataOutput? = nil

    /// Initializes a new instance with the delegate provided. The delegate is responsible for event handling.
    public init(withDelegate delegate: ScannerDelegate) throws
    {
        super.init()
        self.delegate = delegate
        try scannerSetup()
        // handler for runtime errors
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: captureSession)
    }
    
    public func startScanning() {
        // starting and stopping operations are asynchronous as recommended in the official apple docs
        if let captureSession = self.captureSession, !captureSession.isRunning {
            sessionQueue.async {
                captureSession.startRunning()
            }
        }
    }
    
    public func stopScanning() {
        if let captureSession = self.captureSession, captureSession.isRunning {
            sessionQueue.async {
                captureSession.stopRunning()
            }
        }
    }
    
    public func updateVideoLayout() {
        if let previewLayer = previewLayer {
            let cameraView = delegate.view!
            
            previewLayer.frame = cameraView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation?.rawValue ?? 0) ?? .portrait
            cameraView.layer.addSublayer(previewLayer)
        }
    }
    
    /// Sets the area available for scanning in the camera feed. By default, the whole available area can be used for scanning.
    public func setScanArea(area: CGRect) {
        if let metadataOut = metadataOut, let previewLayer = previewLayer {
            metadataOut.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect:
                area)
        }
    }
    
    private func scannerSetup() throws {
        metadataOut = AVCaptureMetadataOutput()
        self.captureSession = try self.makeCaptureSession(withMetadata: metadataOut!)
        metadataOut!.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        metadataOut!.metadataObjectTypes = self.metaObjectTypes()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        updateVideoLayout()
    }
    
    private func makeCaptureSession(withMetadata metadataOut: AVCaptureMetadataOutput) throws -> AVCaptureSession {
        let captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            throw IdentifiableError(localizedDescription: "Could not find default video device.")
        }
        
        let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        guard captureSession.canAddInput(deviceInput) && captureSession.canAddOutput(metadataOut) else {
            throw IdentifiableError(localizedDescription: "Error while setting up code scanning.")
        }
        captureSession.addInput(deviceInput)
        captureSession.addOutput(metadataOut)
            
        return captureSession
    }
    
    private func metaObjectTypes() -> [AVMetadataObject.ObjectType] {
        return [.code128,
                .code39,
                .code39Mod43,
                .code93,
                .ean13,
                .ean8,
                .interleaved2of5,
                .itf14,
                .pdf417,
                .upce]
    }
    
    @objc
    private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        DispatchQueue.main.async { self.delegate.onRuntimeAVError(error: error) }
    }
}
