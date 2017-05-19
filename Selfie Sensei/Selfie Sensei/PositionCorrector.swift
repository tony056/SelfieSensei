//
//  PositionCorrector.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/19/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit

class PositionCorrector: NSObject {
    // order: yaw, pitch, roll
    let testTarget = [0.0, 70.0, 0.0]
    var range = 2.5
    
    
    init(range : Double){
        self.range = range
    }
//    func
    func diffYaw(targetYaw : Double, currentYaw : Double){
        if targetYaw > 0 {
            //left side
        } else if targetYaw == 0 {
            //center side
        } else {
            //right side
        }
    }
    
    func diffPitch(targetPitch : Double, currentPitch : Double) {
        if targetPitch > 0{
            // face to you
        } else if targetPitch == 0 {
            // face to ceil
        } else {
            // face outside
        }
    }
    
    func diffRoll(targetRoll : Double, currentRoll : Double) {
        // face to you, turn right > 0
        // face to you, turn left < 0
        let targetDiffToCenter = abs(targetRoll)
        let currentDiffToCenter = abs(currentRoll)
        
        if targetRoll > 0 && currentRoll > 0 {
            if targetDiffToCenter + range < currentDiffToCenter {
                print("turn left")
            } else if targetDiffToCenter + range >= currentDiffToCenter && targetDiffToCenter - range <= currentDiffToCenter {
                print("Stop")
            } else {
                print("turn phone right more")
            }
            
        } else if targetRoll <= 0 && currentRoll <= 0 {
            if targetDiffToCenter + range < currentDiffToCenter {
                print("turn right")
            } else if targetDiffToCenter + range >= currentDiffToCenter && targetDiffToCenter - range <= currentDiffToCenter {
                print("Stop")
            } else {
                print("turn phone left more")
            }
        } else {
            if targetRoll > 0 {
                print("turn right")
            } else {
                print("turn left")
            }
        }
    }
    
    func returnCurrentInstruction(targets : [Double], currentVals : [Double]){
        diffRoll(targetRoll: targets[2], currentRoll: currentVals[2])
    }
    
}
