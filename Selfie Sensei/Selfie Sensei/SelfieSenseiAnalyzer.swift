//
//  SelfieSenseiAnalyzer.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/31/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import FirebaseStorage


protocol SelfieSenseiAnalyzerDelegate : class {
    func showWaitingView(show: Bool)
}

class SelfieSenseiAnalyzer: NSObject {
    private var images : [UIImage]!
    private var imageCount : Int!
    private var uploadedCount = 0
    private var delegate : SelfieSenseiAnalyzerDelegate?
    
    // testing usage
    var storageRef : FIRStorageReference!
//    var selfieRef : FIRStorageReference!
    
    // delegate to control waiting UI
    
    
    init(delegate : SelfieSenseiAnalyzerDelegate, with images : [UIImage]) {
        self.delegate = delegate
        self.images = images
        self.imageCount = self.images.count
        self.storageRef = FIRStorage.storage().reference()
//        self.selfieRef = self.storageRef.child("images/")
        
    }
    
    func uploadImagesToServer(){
        self.delegate?.showWaitingView(show: true)
        for i in 0 ..< self.imageCount {
            let date = Date().ticks
            let selfieRef = self.storageRef.child("images/\(date).png")
            let data = UIImagePNGRepresentation(self.images[i])!
            selfieRef.put(data, metadata: nil, completion: {
                (metadata, error) in
                if let error = error {
                    // error occurred
                    print("error")
                    return
                }
                self.updateProgress()
            })
        }
    }
    
    func updateProgress(){
        self.uploadedCount += 1
        print("iamge ---- \(self.uploadedCount)")
        if self.uploadedCount == self.imageCount {
            // progress done
            self.delegate?.showWaitingView(show: false)
            self.uploadedCount = 0
        }
    }
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
