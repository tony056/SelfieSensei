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
import NVActivityIndicatorView


class CameraViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate{
    var flipCameraButton : UIButton!
    var flashButton : UIButton!
    var captureButton : SelfieSenseiRecordButton!
    var notificationLabel : UILabel!
    var progressView : NVActivityIndicatorView!
    @IBOutlet weak var guideView: UIView!
    
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
    var guideLayer : CALayer!
    var storageRef : FIRStorageReference!
    var recordingArrowView : RecordingArrowView!
    
//    let motionManager = CMMotionManager()
    var motionDataHandler : MotionDataHandler!
    
    var timer = Timer()
    
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
        maximumVideoDuration = 3.0
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
        captureButton = SelfieSenseiRecordButton(frame: CGRect(x: view.frame.midX - 40.0, y: view.frame.height - 90.0, width: 80.0, height: 80.0))
//        captureButton.setImage(#imageLiteral(resourceName: "CameraButton"), for: UIControlState())
        self.captureButton.addTarget(self, action: #selector(CameraViewController.btnPressed), for: .touchUpInside)
        self.view.addSubview(captureButton)
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
    
    func btnPressed() {
//        print("hi")
        if !isVideoRecording {
            startVideoRecording()
        } else {
            stopVideoRecording()
        }
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        // Called when takePhoto() is called
        print("\(photo.width), \(photo.height)")
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
//        print("point: \(point.x), \(point.y)")
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // start recording
        print("start recording")
        self.captureButton.growButton()
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        self.recordingArrowView.startMonitoring()
        self.recordingArrowView.initCountDown(from: Int(maximumVideoDuration))
        // enable motion track
        // render covered area
        // count down init
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // finish recording
        print("finish recording")
        self.captureButton.shrinkButton()
        self.recordingArrowView.stopMonitoring()
        self.timer.invalidate()
        // upload to firebase
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // video url
        // extract frames out
        print("start extracting")
        self.recordingArrowView.updateTextInCountDown()
        self.recordingArrowView.hideCountDownLabel()
//        let frames = self.extractFramesFromVideo(videoURL: url)
        // go to next view controller
        toGalleryController(url: url)
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
            self.notificationLabel = UILabel(frame: CGRect(x: view.frame.midX - 100.0, y: view.frame.height - 110.0, width: 200.0, height: 60.0))
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
    
    func toGalleryController(url : URL) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let galleryViewController = storyBoard.instantiateViewController(withIdentifier: "galleryVC") as! GalleryViewController
        galleryViewController.videoURL = url
        self.present(galleryViewController, animated:true, completion:nil)
    }

    
    func extractFramesFromVideo(videoURL : URL) -> [UIImage]{
        let asset = AVAsset(url: videoURL)
        let assetImgGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerator.appliesPreferredTrackTransform = true
        assetImgGenerator.requestedTimeToleranceAfter = kCMTimeZero
        assetImgGenerator.requestedTimeToleranceBefore = kCMTimeZero
        var frames : [UIImage] = []
        
        var value : Int64 = 0
        let requiredFramesCount = Int(CMTimeGetSeconds(asset.duration) * 10)
        let step : Int64 = asset.duration.value / Int64(requiredFramesCount)
        
        for _ in 0 ..< requiredFramesCount {
            let time = CMTime(value: CMTimeValue(value), timescale: asset.duration.timescale)
            do {
                let imageRef = try assetImgGenerator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: imageRef)
//                frames.append(image)
                let name = String(value)
                let selfieRef = self.storageRef.child("images/\(name).png")
                selfieRef.put(UIImagePNGRepresentation(image)!, metadata: nil) {
                    (metadata, error) in
                    if let error = error {
                        //error occurred!
                        print("upload error \(error.localizedDescription)")
                    }
                    let downloadURL = metadata?.downloadURL
                    print("uploaded: \(String(describing: downloadURL))")
                }
                value += step
            } catch {
                print(error.localizedDescription)
            }
            
            
        }
        return frames
    }
    
    
    func waitingViewInit(){
        let rect = CGRect(x: self.view.frame.width * (0.5 - 0.4) , y: self.view.frame.height * (0.5 - 0.15), width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.3)
        self.progressView = NVActivityIndicatorView(frame: rect, type: NVActivityIndicatorType.ballClipRotatePulse, color: UIColor.purple, padding: 0)
        self.view.addSubview(self.progressView)
        self.progressView.startAnimating()
    }
    
    func stopWaitingView(){
        self.progressView.stopAnimating()
    }
    
    func updateTime() {
//        print("hi")
        let status = self.recordingArrowView.updateTextInCountDown()
        if !status {
            stopVideoRecording()
        }
    }

}
