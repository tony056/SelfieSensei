//
//  RecordingArrowView.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/29/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import CoreMotion

class RecordingArrowView: UIView {
    
    let motionViewRotationThreshold : Double = 0.1
    let motionGyroUpdateInterval : TimeInterval = 1 / 100
    let motionViewRotationFactor : CGFloat = 0.9
    
    private var motionManager = CMMotionManager()
    private var motionEnabled = true
    
    // manage motion
    private var motionRate : CGFloat!
    private var minXOffset : CGFloat!
    private var maxXOffset : CGFloat!
    private var minYOffset : CGFloat!
    private var maxYOffset : CGFloat!
    
    
    // manage arrow image view
    private var viewFrame : CGRect!
    private var arrowImageView : UIImageView!
    private var trackImageView : UIImageView!
    
    private var context : CGContext!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initImageView(windowSize: frame)
        print("init arrow view")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initImageView(windowSize : CGRect) {
        
        self.viewFrame = CGRect(x: 0.0, y: 0.0, width: windowSize.width, height: windowSize.height)
        
        self.arrowImageView = UIImageView(image: #imageLiteral(resourceName: "iphone"))
        self.arrowImageView.position = CGPoint(x: 0.0, y: windowSize.height / 2 - self.arrowImageView.height / 2)
        
        self.minXOffset = 0
        self.maxXOffset = windowSize.width - self.arrowImageView.width
        self.minYOffset = windowSize.height / 2 - self.arrowImageView.height
        self.maxYOffset = windowSize.height / 2
        
        self.trackImageView = UIImageView(frame: CGRect(x: 0.0, y: windowSize.height / 2 - self.arrowImageView.height, width: windowSize.width, height: 2 * self.arrowImageView.height))
//        self.trackImageView.backgroundColor = UIColor.clear
        self.trackImageView.borderColor = UIColor(red: 128.0, green: 128.0, blue: 128.0, alpha: 0.5)
        self.trackImageView.borderWidth = 0.5
        self.trackImageView.alpha = 0.5
        
        self.addSubview(trackImageView)
        self.addSubview(arrowImageView)
        
        self.motionRate = windowSize.width / 180 * self.motionViewRotationFactor
        
        
        self.setUpContext()
        self.startMonitoring()
        
    }
    
    func startMonitoring() {
        self.motionManager.gyroUpdateInterval = motionGyroUpdateInterval
        if !self.motionManager.isGyroActive && self.motionManager.isGyroAvailable {
            self.motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler:{
                (gyroData, error) -> Void in
                // rotate the arrow according to the device motion rotation rate
                self.rotateByRotationRate(gyroData: gyroData!)
            })
        } else {
            print("No Gyro Available")
        }
    }
    
    func stopMonitoring() {
        if self.motionEnabled == true {
            self.motionEnabled = false
            self.motionManager.stopGyroUpdates()
        }
    }
    
    func rotateByRotationRate(gyroData : CMGyroData) {
        let rotationRate = gyroData.rotationRate.y
        let rotationRateY = gyroData.rotationRate.x
        var offset = self.arrowImageView.x
        var offsetY = self.arrowImageView.y
        
        if abs(rotationRate) >= self.motionViewRotationThreshold {
            offset = offset - CGFloat(rotationRate) * self.motionRate
            if offset > maxXOffset {
                offset = maxXOffset
            } else if offset < minXOffset {
                offset = minXOffset
            }
            
            
        }
        if abs(rotationRateY) >= self.motionViewRotationThreshold {
            offsetY -= CGFloat(rotationRateY) * self.motionRate
            offsetY = offsetY > maxYOffset ? maxYOffset : offsetY
            offsetY = offsetY < minYOffset ? minYOffset : offsetY
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            () -> Void in
            self.arrowImageView.x = offset
            self.arrowImageView.y = offsetY
        })
        
        drawOnTrack()
        
        
    }
    
    func drawOnTrack() {
        
        
        self.context = UIGraphicsGetCurrentContext()
        

        let rect = CGRect(x: self.arrowImageView.x, y: self.arrowImageView.y - self.trackImageView.y, width: self.arrowImageView.width, height: self.arrowImageView.height)
//        let xf:CGFloat = (self.arrowImageView.width  - rect.width)  / 2
//        let yf:CGFloat = (self.arrowImageView.height - rect.height) / 2
        let roundedRect = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 5.0, height: 5.0)).cgPath
        
        context.addPath(roundedRect)
//        context?.addRect(rect)
        
        let fillColor = UIColor(red: 255, green: 128, blue: 128, alpha: 0.3).cgColor
//        let fillColor = UIColor.clear.cgColor
        context?.setFillColor(fillColor)
        context?.setStrokeColor(fillColor)
        context?.setLineWidth(CGFloat(self.arrowImageView.width / 2))
        context?.drawPath(using: CGPathDrawingMode.fillStroke)
        self.trackImageView.image = UIGraphicsGetImageFromCurrentImageContext()
//        self.trackImageView.alpha = 0.5
//        UIGraphicsEndImageContext()
    }
    
    func setUpContext() {
        UIGraphicsBeginImageContext(self.trackImageView.frame.size)
//        self.context = UIGraphicsGetCurrentContext()
        
    }
}
