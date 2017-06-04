//
//  SelfieSenseiScoreSystem.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 6/4/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit

class SelfieSenseiScoreSystem: NSObject {
    private var images : [UIImage]!
    private var selfieScores = [Double]()
    private var blurScores = [Double]()
    private var stateOfArtsScores = [Double]()
    
    init(images : [UIImage]){
        super.init()
        self.images = images
    }
    
    
    public func setUpOnlineScores(scores: [[Double]]) {
        for i in 0 ..< self.images.count {
            self.selfieScores.append(scores[i][0])
            self.blurScores.append(scores[i][1])
        }
    }
    
    public func setUpLocalScores(scores: [Double]){
        for i in 0 ..< self.images.count {
            self.stateOfArtsScores.append(scores[i])
        }
    }
    
    public func getTheFinalScores() -> [(UIImage, Double)]{
        var results = [(photo : UIImage, score : Double)]()
        for i in 0 ..< self.images.count {
            let score = self.calculateScoresWithWeight(index: i)
            results.append((self.images[i], score))
        }
        return results
    }
    
    private func calculateScoresWithWeight(index : Int) -> Double {
        let score : Double = self.selfieScores[index] * Utils.weightOfSelfie + self.blurScores[index] * Utils.weightOfBlur + self.stateOfArtsScores[index] * Utils.weightOfStateOfArts
        return (score * 100).rounded() / 100
    }
}
