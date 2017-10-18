//
//
//  Copyright © 2017 Kenan Atmaca. All rights reserved.
//  kenanatmaca.com
//
//

import UIKit
import AVFoundation
import Vision


@available(iOS 11.0, *)

class mainVC: UIViewController {
    
    var requests = [VNRequest]()
    
    var session:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!
    
    let handler = VNSequenceRequestHandler()
    var lastObservation: VNDetectedObjectObservation?
    
    lazy var highlightView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 3
        view.backgroundColor = .clear
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(highlightView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reader(to: self.view)
    }
    
    func reader(to view:UIView) {
        
        session = AVCaptureSession()
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
        } catch {
            print(error.localizedDescription)
        }
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.The-I-OS-Tests"))
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.zPosition = -1
        view.layer.addSublayer(previewLayer)
        
        session.addOutput(dataOutput)
        session.startRunning()
    }
    
    @objc func tapAction(recognizer: UITapGestureRecognizer) {
        
        highlightView.frame.size = CGSize(width: 120, height: 120)
        highlightView.center = recognizer.location(in: view)
        
        let originalRect = highlightView.frame
        var convertedRect = previewLayer.metadataOutputRectOfInterest(for: originalRect)
        convertedRect.origin.y = 1 - convertedRect.origin.y
        
        lastObservation = VNDetectedObjectObservation(boundingBox: convertedRect)
    }
    
    func handle(_ request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let newObservation = request.results?.first as? VNDetectedObjectObservation else {
                return
            }
            self.lastObservation = newObservation
            
            var transformedRect = newObservation.boundingBox
            transformedRect.origin.y = 1 - transformedRect.origin.y
            let convertedRect = self.previewLayer.rectForMetadataOutputRect(ofInterest: transformedRect)
            self.highlightView.frame = convertedRect
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}//

@available(iOS 11.0, *)
extension mainVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let observation = lastObservation else {
                return
        }
        
        let request = VNTrackObjectRequest(detectedObjectObservation: observation, completionHandler: self.handle)
        request.trackingLevel = .accurate
        
        do {
            try handler.perform([request], on: pixelBuffer)
        }
        catch {
            print(error)
        }
    }
}
