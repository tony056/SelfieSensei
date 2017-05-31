//
//  SelfieCollectionViewCell.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/30/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import INSPhotoGallery

class SelfieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    func populateWithPhoto(_ photo: INSPhotoViewable) {
        photo.loadThumbnailImageWithCompletionHandler { [weak photo] (image, error) in
            if let image = image {
                if let photo = photo as? INSPhoto {
                    photo.thumbnailImage = image
                }
                
                self.thumbnailImageView.image = image
                print("loaded image")
            }
        }
    }
}
