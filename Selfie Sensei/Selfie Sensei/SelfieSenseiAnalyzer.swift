//
//  SelfieSenseiAnalyzer.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/31/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import FirebaseStorage
import SwiftHTTP
import SwiftyJSON

protocol SelfieSenseiAnalyzerDelegate : class {
    func showWaitingView(show: Bool)
    func showImagesToView(images: [UIImage])
    func showImagesToViewWithScores(results : [(photo: UIImage, score: Double)])
}

class SelfieSenseiAnalyzer: NSObject {
    private var images : [UIImage]!
    private var imageCount : Int!
    private var uploadedCount = 0
    private var delegate : SelfieSenseiAnalyzerDelegate?
    private var imageExtractor : ImageExtractor!
    private var scoreSystem : SelfieSenseiScoreSystem!

    // testing usage
    var storageRef : FIRStorageReference!
//    private let uploadURL = "http://35.184.163.253:5000/rank"
    private let uploadURL = "http://35.184.163.253:5000/all"
//    private var filePaths : [URL] = []
//    var selfieRef : FIRStorageReference!
    
    // delegate to control waiting UI
    
    
    init(delegate : SelfieSenseiAnalyzerDelegate, with images : [UIImage]) {
        self.delegate = delegate
        self.images = images
        self.imageCount = self.images.count
        self.storageRef = FIRStorage.storage().reference()
//        self.selfieRef = self.storageRef.child("images/")
        
    }
    
    init(delegate : SelfieSenseiAnalyzerDelegate, with videoURL : URL, and mode : Bool){
        super.init()
        self.delegate = delegate
        self.imageExtractor = ImageExtractor(sourceURL: videoURL)
//        self.delegate?.showWaitingView(show: true)
//        self.images = self.imageExtractor.extractFramesFromVideo()
        dispatchToBackground(mode: mode)
        
//        self.imageCount = self.images.count
    }
    
    func dispatchToBackground(mode : Bool) {
        self.delegate?.showWaitingView(show: true)
        self.storageRef = FIRStorage.storage().reference()
        DispatchQueue.global(qos: .background).async {
//            self.images = self.imageExtractor.extractFramesFromVideo()
//            self.images = self.imageExtractor.extractFramesFromVideoAndApplyFilters()
            if !mode {
                // angle mode
                self.images = self.imageExtractor.extractFramesFromVideo()
            } else {
                // filter mode
                let resultsWithType = self.imageExtractor.returnExtractFramesAndFilterNames(frames: self.images)
                self.images = self.getImagesFromTuples(resultsWithType: resultsWithType)
            }
            self.imageCount = self.images.count
            self.scoreSystem = SelfieSenseiScoreSystem(images: self.images)
            
            DispatchQueue.main.async {
                self.uploadImagesToServer()
            }
        }
    }
    
    public func getResult(mode : Bool) {
        self.dispatchToBackground(mode: mode)
    }
    
    func uploadImagesToServer(){
//        self.delegate?.showWaitingView(show: true)
        var filePaths : [URL] = []
        for i in 0 ..< self.imageCount {
            let date = Date().ticks
//            let selfieRef = self.storageRef.child("images/\(date).png")
            let data = UIImageJPEGRepresentation(self.images[i], 0.8)!
            let filePath = getDocumentDirectory().appendingPathComponent("\(date).jpg")
            try? data.write(to: filePath)
            filePaths.append(filePath)
        }
        self.uploadTask(paths: filePaths)
    }
    
    private func uploadTask(paths: [URL]) {
        print("uploading --- \(paths.count)")
        var params = [String : NSObject]()
        for i in 0 ..< paths.count {
            params["image_\(i)"] = Upload(fileUrl: paths[i])
        }
        do {
//            let opt = try HTTP.POST(uploadURL, parameters: ["file": Upload(fileUrl: paths[0])], headers: [], requestSerializer: nil)
            let opt = try HTTP.POST(uploadURL, parameters: params, headers: ["header": "value"], requestSerializer: HTTPParameterSerializer())
            opt.start {
                response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                print("opt finished: \(response.description)")
//                response.text
                self.uploadDone(response: response.text!)
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
        
    }
    
    private func uploadDone(response : String) {
        let resultsFromOnline = self.parseResponse(text: response)
        self.uploadedCount = 0
        self.scoreSystem.setUpOnlineScores(scores: resultsFromOnline)
        self.scoreSystem.setUpLocalScores(scores: self.getRuleBaseScore())
        let results = self.scoreSystem.getTheFinalScores()
        let sortedResults = self.sortTopResults(bound: 5, source: results)
        print("sorted results: \(sortedResults)")
        self.updateImages(source: sortedResults)
        self.delegate?.showWaitingView(show: false)
        self.delegate?.showImagesToViewWithScores(results: sortedResults)
    }
    
    private func uploadDone(scores : [Double]) {
        self.uploadedCount = 0
        self.delegate?.showWaitingView(show: false)
        var results = [(UIImage, Double)]()
        for i in 0 ..< self.imageCount {
            results.append((self.images[i], scores[i]))
        }
        results = self.sortTopResults(bound: 5, source: results)
        self.delegate?.showImagesToViewWithScores(results: results)
    }
    
    func updateProgress(){
        self.uploadedCount += 1
        print("image ---- \(self.uploadedCount)")
        if self.uploadedCount == self.imageCount {
            // progress done
            self.delegate?.showWaitingView(show: false)
            self.uploadedCount = 0
            self.delegate?.showImagesToView(images: self.images)
        }
    }
    
    private func getRuleBaseScore() -> [Double] {
        let faceDetector = FaceDetector()
        var scores = [Double]()
        for image in self.images {
            let score = faceDetector.getScore(photo: image)
            scores.append(score)
        }
        return scores
    }
    
    private func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = path[0]
        return documentDirectory
    }
    
    private func parseResponse(text: String) -> [[Double]] {
        if let dataFromString = text.data(using: .utf8, allowLossyConversion: false){
            let json = JSON(data: dataFromString)
            var results = [[Double]]()
            for i in 0 ..< self.imageCount {
                let scores = json[i]
                let array = [scores[0].double, scores[1].double]
//                results[self.images[i]] = array as! [Double]
                results.append(array as! [Double])
            }
            
            return results
        }
        print("Error json parsing")
        return []
    }
    
    private func sortTheResult(results : [UIImage : Double]) -> [(UIImage, Double)] {
        var sortedResults = [(photo: UIImage, score: Double)]()
        for (key, value) in (Array(results).sorted {$0.1 < $1.1}) {
            sortedResults.append((key, value))
        }
        return sortedResults
    }
    
    private func sortTopResults(bound : Int, source : [(UIImage, Double)]) -> [(UIImage, Double)] {
//        var results = [(photo: UIImage, score: Double)]()
        var item = 0
        let sortedSource = source.sorted(by: {$0.1 > $1.1})
        let results = sortedSource.prefix(upTo: bound)
        return Array(results)
    }
    
    private func getImagesFromTuples(resultsWithType : [(photo : UIImage, filter : String)]) -> [UIImage] {
        var photos = [UIImage]()
        for result in resultsWithType {
            photos.append(result.photo)
        }
        return photos
    }
    
    private func updateImages(source: [(photo : UIImage, scores: Double)]){
        var newImages = [UIImage]()
        for s in source {
            newImages.append(s.photo)
        }
        self.images = newImages
    }
    
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

