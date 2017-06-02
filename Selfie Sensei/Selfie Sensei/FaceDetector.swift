//
//  FaceDetector.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 6/1/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit

class FaceDetector: NSObject {
    
    private let accuracy = CIDetectorAccuracyHigh
    private var faceDetector : CIDetector!
    
    override init() {
        super.init()
        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: self.accuracy)
        
    }
    
    private func detectFace(photo : UIImage) -> CGRect {
        let faces = self.faceDetector.features(in: photo)
        
        let realImageSize = photo.ciImage?.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = CGAffineTransform(translationX: 0, y: -realImageSize?.height)
        
        
        for face in faces as CIFaceFeatures {
//            var faceCoords = 
        }
    }
    
}
