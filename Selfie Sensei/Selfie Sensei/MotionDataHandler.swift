//
//  MotionDataHandler.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/19/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import CoreMotion

class MotionDataHandler: NSObject {
    
    var motionManager : CMMotionManager!
    var yaw : Double!
    var roll : Double!
    var pitch : Double!
    let queue : OperationQueue?
    let alpha = 0.15
    var inputData = Array(repeating: 0.0, count: 3)
    var outputData = Array(repeating: 0.0, count: 3)
    
    init(frequency : Double){
        self.motionManager = CMMotionManager()
        if self.motionManager.isDeviceMotionAvailable {
            self.motionManager.deviceMotionUpdateInterval = frequency
            self.queue = OperationQueue()
        } else {
            self.queue = nil
        }
    }
    
    func startUpdateMotionData(){
        if self.motionManager.isDeviceMotionAvailable {
            self.motionManager.startDeviceMotionUpdates(to: self.queue!, withHandler: {
                (deviceMotion, error) -> Void in
                if error == nil {
                    self.handleMotionUpdates(deviceMotion: deviceMotion!)
                } else {
//                    print(error.local)
                }
            })
        }
    }
    
    func handleMotionUpdates(deviceMotion : CMDeviceMotion){
        let attitude = deviceMotion.attitude
        self.roll = degrees(radians: attitude.roll)
        self.pitch = degrees(radians: attitude.pitch)
        self.yaw = degrees(radians: attitude.yaw)
//        print("Roll: \(self.roll as Double), Pitch: \(self.pitch as Double), Yaw: \(self.yaw as Double)")
        inputData[0] = self.yaw
        inputData[1] = self.pitch
        inputData[2] = self.roll
        outputData = self.lowPassFilter(rawData: inputData, output: outputData)
        
//        print("\(outputData)")
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
    }
    
    
    func lowPassFilter(rawData : [Double], output : [Double]) -> [Double] {
        let sum = output.reduce(0) { $0 + $1 }
        if sum == 0.0 {
            return rawData
        }
        var localOutput = output
        for i in 0 ..< rawData.count {
            localOutput[i] = output[i] + self.alpha * (rawData[i] - localOutput[i])
        }
        return localOutput
    }
    
    
}
