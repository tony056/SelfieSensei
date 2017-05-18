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

class CameraViewController: UIViewController{
    
    let captureSession = AVCaptureSession()
    var previewLayer : CALayer!
    var captureDevice : AVCaptureDevice!
    
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
        prepareMotionData()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareMotionData(){
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
                (deviceMotion, error) -> Void in
                if(error == nil){
                    self.handleMotionUpdates(deviceMotion: deviceMotion!)
                } else {
                    print("fucking error")
                }
            })
        }
    }
    
    func handleMotionUpdates(deviceMotion : CMDeviceMotion){
        let attitude = deviceMotion.attitude
        let roll = degrees(radians: attitude.roll)
        let pitch = degrees(radians: attitude.pitch)
        let yaw = degrees(radians: attitude.yaw)
        print("Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
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
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.view.layer.frame
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
