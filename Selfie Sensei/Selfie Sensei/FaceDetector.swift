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
        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : accuracy])
        
    }
    
    private func detectFace(photo : UIImage) -> CIFaceFeature? {
        let faces = self.faceDetector.features(in: CIImage(image: photo)!)
        
//        let realImageSize = photo.ciImage?.extent.size
//        var transform = CGAffineTransform(scaleX: 1, y: -1)
//        transform = CGAffineTransform(translationX: 0, y: -(realImageSize?.height)!)
        var maxFace : CIFaceFeature!
        var maxSize : CGFloat! = 0.0
        
        for face in faces as! [CIFaceFeature] {
            let faceWidth = face.bounds.size.width
            let faceHeight = face.bounds.size.height
            let area = faceWidth * faceHeight
            if area > maxSize {
                maxSize = area
                maxFace = face
            }
            
        }
        
        return maxFace
    }
    
    private func ruleOfThirds(photo : UIImage, with face : CIFaceFeature?) -> Double {
        if face == nil {
            return -1.0
        }
        let image = CIImage(image: photo)!
        let xLines : [CGFloat] = [(image.extent.size.height) / 3, (image.extent.size.height) * 2 / 3]
        let yLines : [CGFloat] = [(image.extent.size.width) / 3, (image.extent.size.width) * 2 / 3]
//        var rulePoints : [CGPoint]!
        var score = 0.0
        var pointsOnFace = 0
        for i in 0 ..< xLines.count {
            for j in 0 ..< yLines.count {
//                rulePoints.append(CGPoint(x: xLines[i], y: yLines[j]))
                if face!.bounds.contains(CGPoint(x: xLines[i], y: yLines[j])) {
                    pointsOnFace += 1
                }
            }
        }
        
        if pointsOnFace == 2 {
            score += 0.5
        } else if pointsOnFace == 1 {
            score += 0.8
        }
                
        if face!.hasSmile {
            score += 1
        }
        
        if face!.hasFaceAngle {
            print("face angle: \(face!.faceAngle)")
        }
        
        return score
    }
    
    public func getScore(photo : UIImage) -> Double {
        let face = self.detectFace(photo: photo)
        return self.ruleOfThirds(photo: photo, with: face)
    }
    
}
