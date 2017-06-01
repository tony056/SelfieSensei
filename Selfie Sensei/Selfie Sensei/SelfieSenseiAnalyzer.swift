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

protocol SelfieSenseiAnalyzerDelegate : class {
    func showWaitingView(show: Bool)
    func showImagesToView(images: [UIImage])
}

class SelfieSenseiAnalyzer: NSObject {
    private var images : [UIImage]!
    private var imageCount : Int!
    private var uploadedCount = 0
    private var delegate : SelfieSenseiAnalyzerDelegate?
    private var imageExtractor : ImageExtractor!

    // testing usage
    var storageRef : FIRStorageReference!
    private let uploadURL = "http://35.184.163.253:5000/rank"
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
    
    init(delegate : SelfieSenseiAnalyzerDelegate, with videoURL : URL){
        super.init()
        self.delegate = delegate
        self.imageExtractor = ImageExtractor(sourceURL: videoURL)
//        self.delegate?.showWaitingView(show: true)
//        self.images = self.imageExtractor.extractFramesFromVideo()
        dispatchToBackground()
        
//        self.imageCount = self.images.count
    }
    
    func dispatchToBackground() {
        self.delegate?.showWaitingView(show: true)
        self.storageRef = FIRStorage.storage().reference()
        DispatchQueue.global(qos: .background).async {
            self.images = self.imageExtractor.extractFramesFromVideo()
            self.imageCount = self.images.count
            DispatchQueue.main.async {
                self.uploadImagesToServer()
            }
            
        }
    }
    
    func uploadImagesToServer(){
//        self.delegate?.showWaitingView(show: true)
        var filePaths : [URL] = []
        for i in 0 ..< self.imageCount {
            let date = Date().ticks
//            let selfieRef = self.storageRef.child("images/\(date).png")
            let data = UIImagePNGRepresentation(self.images[i])!
            let filePath = getDocumentDirectory().appendingPathComponent("\(date).png")
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
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
        
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
    
//    func updateDone(){
//        
//    }
    
//    private func uploadImagesTo
    private func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = path[0]
        return documentDirectory
    }
    
    
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
