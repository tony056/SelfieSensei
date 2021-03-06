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
    private let fixedNum = 30
    
    init(sourceURL : URL) {
        super.init()
        self.sourceURL = sourceURL
        self.videoSource = AVAsset(url: self.sourceURL)
        self.videoLength = self.videoSource.duration
        self.assetImgGenerator = AVAssetImageGenerator(asset: self.videoSource)
        self.setUpGenerator()
    }
    
    func extractFramesFromVideo() -> [UIImage]{
        return self.extractFramesFromVideo(requiredFrames: fixedNum)
    }
    
    func extractFramesFromVideo(requiredFrames : Int) -> [UIImage] {
        var frames : [UIImage] = []
        
        var value : Int64 = 0
        let requiredFramesCount = requiredFrames
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
    
    public func extractFramesFromVideoAndApplyFilters() -> [UIImage] {
        var results = [UIImage]()
        // extract less frames
        let sourceFrames = self.extractFramesFromVideo(requiredFrames: 5)
//        var imageFilter
        for image in sourceFrames {
            let imageFilter = SelfieSenseiImageFilter(image: image)
            let filteredImages = imageFilter.filterSourceImage()
            results.append(contentsOf: filteredImages)
        }
        return results
        // apply filter to generate more frames
        // return all frames
    }
    
    public func returnExtractFramesAndFilterNames(frames : [UIImage]) -> [(photo: UIImage, filter : String)] {
        var results = [(UIImage, String)]()
//        let sourceFrames = self.extractFramesFromVideo(requiredFrames: 5)
        let sourceFrames = frames
        print("source image count: \(sourceFrames.count)")
        for image in sourceFrames {
            let imageFilter = SelfieSenseiImageFilter(image: image)
            let filteredImagesWithType = imageFilter.filterSourceImageWithFilters()
//            results.append(filteredImagesWithType)
            for imageWithType in filteredImagesWithType {
                results.append(imageWithType)
            }
        }
        print("filtered image count: \(results.count)")
        return results
    }
    
    
}
