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
    // Order : yaw: (clockwise < 0), pitch: phone stand up (close to 90), roll: horizontal rotation
    var motionManager : CMMotionManager!
    var yaw : Double!
    var roll : Double!
    var pitch : Double!
    let queue : OperationQueue?
    let alpha = 0.15
    var inputData = Array(repeating: 0.0, count: 3)
    var outputData = Array(repeating: 0.0, count: 3)
    let testTarget = [0.0, 70.0, 10.0]
    let range = 2.5
    var windowValues = [[Double]](repeating: [Double] (repeating: 0.0, count: 1), count: 3)
    var windowStates = [Bool] (repeating: false, count: Utils.windowSize)
    var positionCorrector : PositionCorrector!
    var guideOrAdjustMode = false //false is guide mode, true is adjust mode
    
    init(frequency : Double){
        self.motionManager = CMMotionManager()
        if self.motionManager.isDeviceMotionAvailable {
            self.motionManager.deviceMotionUpdateInterval = frequency
            self.queue = OperationQueue()
        } else {
            self.queue = nil
        }
        self.positionCorrector = PositionCorrector(range: range)
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
        windowValues = self.updateWindowValues(windowValues: windowValues, with: outputData)
        var state = self.positionCorrector.isInGuideArea(currentVals: outputData, targetArea: 0)
        if guideOrAdjustMode {
            // get state from another function
            state = self.positionCorrector.isAdjusting(currentVals: outputData, targetVals: [0, 0, 0])
        }
        windowStates = self.updateWindowStates(windows: windowStates, with: state)
        print("\(outputData)")
//        positionCorrector.returnCurrentInstruction(targets: testTarget, currentVals: outputData)
        let status = self.positionCorrector.returnInAreaOrMovingNotification(vals: self.windowStates)
        notifyUIUpdate(status: status)
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
    
    func updateWindowValues(windowValues : [[Double]], with newValues : [Double]) -> [[Double]]{
        var localValues = windowValues
        for i in 0 ..< localValues.count {
            localValues[i].append(newValues[i])
        }
        if localValues[0].count > Utils.windowSize {
            for i in 0 ..< localValues.count {
                localValues[i].remove(at: 0)
            }
        }
        
        return localValues
    }
    
    func updateWindowStates(windows : [Bool], with newState : Bool) -> [Bool] {
        var localStates = windows
        localStates.append(newState)
        
        if localStates.count > Utils.windowSize {
            localStates.remove(at: 0)
        }
        
        return localStates
    }
    
    func isPositionHoldCorrect(windowsVals : [[Double]], with target : [Double], and range : Double) -> Bool {
        let l = windowsVals[0].count
        
        for i in 0 ..< l {
            var status = true
            for j in 0 ..< target.count {
                status = status && self.isInRange(target: target[j], range: range, val: windowsVals[j][i])
            }
            if !status {
                return false
            }
        }
        return true
    }
    
    func isInRange(target : Double, range : Double, val : Double) -> Bool {
        if val >= target - range && val <= target + range {
            return true
        }
        return false
    }
    
    func notifyUIUpdate(status : Bool){
        let defaultCenter = NotificationCenter.default
        if status {
            // change the text view to capture button
            defaultCenter.post(name: NSNotification.Name(rawValue: "switchToCaptureButton"), object: nil)
        } else {
            // keep showing the text view
            defaultCenter.post(name: NSNotification.Name(rawValue: "showMovingText"), object: nil)
        }
    }
    
}
