//
//  ViewController.swift
//  vision-ml
//
//  Created by Cody Lee on 10/6/17.
//  Copyright © 2017 CJLeeApps. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class CameraVC: UIViewController {
    
    @IBOutlet weak var roundedLblView: RoundedShadowView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    
    var flashState: FlashState = .off
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    // Audio / Video Components
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var photoData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func flashBtnTapped(_ sender: Any) {
        flashState.toggle()
        
        switch flashState {
        case .off:
            flashBtn.setImage(UIImage(named: "offBtn")!, for: .normal)
            flashBtn.setTitle("FLASH OFF", for: .normal)
            flashBtn.setTitleColor(UIColor.darkGray, for: .normal)
        case .on:
            flashBtn.setImage(UIImage(named: "onBtn")!, for: .normal)
            flashBtn.setTitle("FLASH ON", for: .normal)
            flashBtn.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer.frame = cameraView.bounds
        speechSynthesizer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        
        // capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // input
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            // output
            cameraOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
            
        } catch {
            debugPrint(error)
        }
        
    }
    
    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        
        if flashState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func resultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        for classification in results {
            
            //print("Item: \(classification.identifier): \(classification.confidence)")
            
            if classification.confidence < 0.5 {
                let unknownObjectMessage = "Unsure what object is, try again."
                self.identificationLbl.text = unknownObjectMessage
                synthesizeSpeech(fromString: unknownObjectMessage)
                self.confidenceLbl.text = ""
                break
            } else {
                let identification = classification.identifier
                let confidence = Int(classification.confidence * 100)
                
                let resultSentence = "I'm \(confidence) percent sure that this is a \(identification)"
                synthesizeSpeech(fromString: resultSentence)
                self.identificationLbl.text = identification
                self.confidenceLbl.text = "CONFIDENCE: \(Int(classification.confidence * 100))%"
                break
            }
            
        }
    }
    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
    }
    
}

extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            do {
                //let mlModel = try VNCoreMLModel(for: MobileNet().model)
                let mlModel = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: mlModel, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
            
            let image = UIImage(data: photoData!)
            self.captureImageView.image = image
        }
    }
}

extension CameraVC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
    }
}
