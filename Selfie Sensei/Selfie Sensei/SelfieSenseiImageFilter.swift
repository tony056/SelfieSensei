//
//  SelfieSenseiImageFilter.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 6/3/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import CoreImage

class SelfieSenseiImageFilter: NSObject {
    private var targetImage : CIImage!
    private let openGLContext = EAGLContext(api: .openGLES2)
    private var context : CIContext!
    private let filters = ["CIPhotoEffectInstant", "CIPhotoEffectChrome", "CIPhotoEffectTransfer", "CIVignette", "CIColorClamp", "CISpeiaTone"]
    
    init(image: UIImage){
        super.init()
        self.targetImage = CIImage(image: image)!
        self.context = CIContext(eaglContext: self.openGLContext!)
    }
    
    public func setImage(image : UIImage) -> Bool {
        if let photo = CIImage(image: image) {
            self.targetImage = photo
            return true
        }
        return false
    }
    
//    private func boostSetup() {
//        
//    }
    public func filterSourceImage() -> [UIImage] {
        var results = [UIImage]()
        for i in 0 ..< self.filters.count {
            let filter = CIFilter(name: self.filters[i])
            filter?.setDefaults()
            filter?.setValue(self.targetImage, forKey: kCIInputImageKey)
            if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let cgiResult = self.context.createCGImage(output, from: output.extent)
                let filteredImage = UIImage(cgImage: cgiResult!)
                results.append(filteredImage)
            }
        }
        return results
    }
    
    public func filterSourceImageWithFilters() -> [(photo: UIImage, filter: String)] {
        var results = [(photo : UIImage, filter : String)]()
        let photos = self.filterSourceImage()
        for i in 0 ..< photos.count {
            results.append((photos[i], self.filters[i % self.filters.count]))
        }
        return results
    }
}
