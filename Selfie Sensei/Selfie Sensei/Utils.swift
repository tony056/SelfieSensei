//
//  Utils.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/23/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit

class Utils: NSObject {

    
    let guideDisplayImages = ["Guide_Display_60_top"]
    static let errorRanges = 2.5
    public static let windowSize = 15
    public static let guideYPRRanges = [[100.0, 55.0, -179.0], [160.0, 85.0, -155.0]]
    public static let axises = 3
    
    public static let weightOfSelfie = 0.8
    public static let weightOfStateOfArts = 0.1
    public static let weightOfBlur = 1 - weightOfSelfie - weightOfStateOfArts
    public static let blurThreshold  = 35.0
}
