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
    
    var imageView = UIImageView()
    
    var requests = [VNRequest]()
    
    var session:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageView.frame = self.view.bounds
        imageView.backgroundColor = UIColor.clear
        view.addSubview(imageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reader(to: self.view)
        startFaceReq()
    }
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
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
    
    func startFaceReq() {
        
        let faceReq = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceFeatures)
        self.requests = [faceReq]
    }
    
    func handleFaceFeatures(request: VNRequest, errror: Error?) {
        
        guard let observations = request.results as? [VNFaceObservation] else {
            fatalError("@Unexpected result type!")
        }
        
        DispatchQueue.main.async {
            self.imageView.layer.sublayers?.removeSubrange(0...)
            for face in observations {
                self.addFaceLandmarksToImage(face)
            }
        }
    }
    
    func addFaceLandmarksToImage(_ face: VNFaceObservation) {
        
        let scaledHight = view.frame.width / imageView.frame.size.width * imageView.frame.size.height
        
        let w = face.boundingBox.size.width * imageView.frame.size.width
        let h = scaledHight * face.boundingBox.height
        let x = face.boundingBox.origin.x * imageView.frame.size.width
        let y = scaledHight * (1 - face.boundingBox.origin.y) - h
        
        let faceRect = CGRect(x: x, y: y, width: w, height: h)
        
        let outline = CALayer()
        outline.frame = faceRect
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.green.cgColor
        
        imageView.layer.addSublayer(outline)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}//

@available(iOS 11.0, *)
extension mainVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error.localizedDescription)
        }
    }
}

