//
//  WaitingView.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/31/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class WaitingView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var progressView : NVActivityIndicatorView!
    private var blurEffect : UIBlurEffect!
    private var blurEffectView : UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        self.blurEffectView = UIVisualEffectView(effect: self.blurEffect)
        self.blurEffectView.frame = self.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(self.blurEffectView)
        
        self.initProgressView()
        self.addSubview(self.progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initProgressView() {
        self.progressView = NVActivityIndicatorView(frame: self.frame, type: NVActivityIndicatorType.ballClipRotatePulse, color: UIColor(red: 50, green: 0, blue: 111, alpha: 1), padding: 0)
    }
    
    func startAnimating() {
        self.progressView.startAnimating()
    }
    
    func stopAnimating() {
        self.progressView.stopAnimating()
    }
    
    

}
