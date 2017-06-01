//
//  ImageExtractor.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/31/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import AVFoundation

class ImageExtractor: NSObject {

    // extract frames from video source
    var sourceURL : URL!
    var videoSource : AVAsset!
    var assetImgGenerator : AVAssetImageGenerator!
    var videoLength : CMTime!
    
    init(sourceURL : URL) {
        super.init()
        self.sourceURL = sourceURL
        self.videoSource = AVAsset(url: self.sourceURL)
        self.videoLength = self.videoSource.duration
        self.assetImgGenerator = AVAssetImageGenerator(asset: self.videoSource)
        self.setUpGenerator()
    }
    
    func extractFramesFromVideo() -> [UIImage]{
        
        var frames : [UIImage] = []
        
        var value : Int64 = 0
        let requiredFramesCount = Int(CMTimeGetSeconds(self.videoLength) * 10)
        let step : Int64 = self.videoLength.value / Int64(requiredFramesCount)
        
        for _ in 0 ..< requiredFramesCount {
            let time = CMTime(value: CMTimeValue(value), timescale: self.videoLength.timescale)
            do {
                let imageRef = try self.assetImgGenerator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: imageRef)
                //                frames.append(image)
                let name = String(value)
                frames.append(image)
                value += step
            } catch {
                print(error.localizedDescription)
            }
            
        }
        return frames
    }
    
    func setUpGenerator() {
        self.assetImgGenerator.appliesPreferredTrackTransform = true
        self.assetImgGenerator.requestedTimeToleranceAfter = kCMTimeZero
        self.assetImgGenerator.requestedTimeToleranceBefore = kCMTimeZero
    }
    
    
    
}
