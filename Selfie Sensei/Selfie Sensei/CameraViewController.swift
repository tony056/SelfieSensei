//
//  CameraViewController.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/17/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//
import Material
import UIKit
import AVFoundation
import CoreMotion
import SwiftyCam
import Firebase
import FirebaseStorage

class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate{
    var flipCameraButton : UIButton!
    var flashButton : UIButton!
    var captureButton : SwiftyCamButton!
    var notificationLabel : UILabel!
    
    @IBOutlet weak var guideView: UIView!
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
    var guideLayer : CALayer!
    var storageRef : FIRStorageReference!
    var recordingArrowView : RecordingArrowView!
    
//    let motionManager = CMMotionManager()
    var motionDataHandler : MotionDataHandler!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.previewLayer.frame = self.view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldUseDeviceOrientation = false
        guideLayer = self.guideView.layer
        defaultCamera = .front
//        self.registerForNotification()
        
//        addGuideAndEffects()
//        prepareMotionData()
        self.storageRef = FIRStorage.storage().reference()
        addRecordingArrowView()
        addButtons()
    }
    
    func prepareMotionData(){
        self.motionDataHandler = MotionDataHandler(frequency: 0.05)
        self.motionDataHandler.startUpdateMotionData()
    }
    
    func addGuideAndEffects(){
        let blurEffectView = UIVisualEffectView(effect:UIBlurEffect(style: .light))
        blurEffectView.frame = self.view.bounds
        self.view.addSubview(blurEffectView)
        let guideDisplayView = UIImageView(frame: self.view.bounds)
        guideDisplayView.image = UIImage(named: "Guide_Display_60_top")
        self.view.addSubview(guideDisplayView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .front).devices {
            captureDevice = availableDevices.first
            beginSession()
        }
    }
    
    func beginSession(){
        
        //try to get the camera device
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            self.previewLayer = previewLayer
//            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
            self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
//            self.previewUIView.layer.addSublayer(self.previewLayer)
//            self.previewLayer.frame = self.view.layer.frame
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
        }
        
        
    }
    
    @objc private func cameraSwitchAction(_ sender: Any) {
        switchCamera()
    }
    
    @objc private func toggleFlashAction(_ sender: Any) {
        flashEnabled = !flashEnabled
        
        if flashEnabled == true {
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControlState())
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        }
    }
    
    private func addButtons() {
        
        
        captureButton = SwiftyCamButton(frame: CGRect(x: view.frame.midX - 30.0, y: view.frame.height - 90.0, width: 60.0, height: 60.0))
        captureButton.setImage(#imageLiteral(resourceName: "CameraButton"), for: UIControlState())
        captureButton.delegate = self
        self.view.addSubview(captureButton)
        
        
        flipCameraButton = UIButton(frame: CGRect(x: (((view.frame.width / 2 - 37.5) / 2) - 15.0), y: view.frame.height - 74.0, width: 30.0, height: 23.0))
//        flipCameraButton.setImage(, for: UIControlState())
//        flipCameraButton.setImage(, for: <#T##UIControlState#>)
        flipCameraButton.addTarget(self, action: #selector(cameraSwitchAction(_:)), for: .touchUpInside)
        self.view.addSubview(flipCameraButton)
        
        let test = CGFloat((view.frame.width - (view.frame.width / 2 + 37.5)) + ((view.frame.width / 2) - 37.5) - 9.0)
        
        flashButton = UIButton(frame: CGRect(x: test, y: view.frame.height - 77.5, width: 18.0, height: 30.0))
//        flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        flashButton.addTarget(self, action: #selector(toggleFlashAction(_:)), for: .touchUpInside)
        self.view.addSubview(flashButton)
//        guideLayer.borderWidth = 100.0
//        guideLayer.borderColor = UIColor.purple.cgColor
//        guideLayer.frame = self.view.bounds
//        self.view.layer.addSublayer(guideLayer)
        cameraDelegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        // Called when takePhoto() is called
        print("\(photo.width), \(photo.height)")
        toGalleryController()
        // Save the file and push to cloud server
        
//        let data = UIImagePNGRepresentation(photo)
//        let selfieRef = self.storageRef.child("images/test.png")
//        selfieRef.put(data!, metadata: nil) {
//            (metadata, error) in
//            if let error = error {
//                //error occurred!
//                print("upload error \(error.localizedDescription)")
//            }
////            let downloadURL = metadata.downloadURL
//            print("uploaded")
//        }
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        print("point: \(point.x), \(point.y)")
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // start recording
        // enable motion track
        // render covered area
        // count down init
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // finish recording
        // upload to firebase
        // 
    }
    
    func registerForNotification() {
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(CameraViewController.showCaptureButton), name: NSNotification.Name(rawValue: "switchToCaptureButton"), object: nil)
        defaultCenter.addObserver(self, selector: #selector(CameraViewController.showMovementText), name: NSNotification.Name(rawValue: "showMovingText"), object: nil)
    }
    
    func showMovementText(){
        if self.captureButton.isHidden == false {
            self.captureButton.isHidden = true
        }
        if self.notificationLabel != nil {
            // have text
        } else {
            self.notificationLabel = UILabel(frame: CGRect(x: view.frame.midX - 100.0, y: view.frame.height - 90.0, width: 200.0, height: 60.0))
            self.notificationLabel.textColor = UIColor.white
            self.notificationLabel.text = "Please move to the targeted area in 3 seconds"
            self.notificationLabel.adjustsFontSizeToFitWidth = true
            self.view.addSubview(notificationLabel)
        }
        
    }
    
    func showCaptureButton(){
        print("moved to the position we want")
    }
    
    func addRecordingArrowView(){
        self.recordingArrowView = RecordingArrowView(frame: self.view.frame)
        self.view.addSubview(self.recordingArrowView)
    }
    
    func toGalleryController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let galleryViewController = storyBoard.instantiateViewController(withIdentifier: "galleryVC") as! GalleryViewController
        self.present(galleryViewController, animated:true, completion:nil)
    }

}
