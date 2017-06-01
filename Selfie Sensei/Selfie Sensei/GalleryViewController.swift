//
//  GalleryViewController.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/30/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import INSPhotoGallery

class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SelfieSenseiAnalyzerDelegate {
    func showWaitingView(show: Bool) {
        if show {
            self.waitingView.isHidden = false
            self.waitingView.startAnimating()
        } else {
            self.waitingView.isHidden = true
            self.waitingView.stopAnimating()
        }
    }

    
    @IBOutlet weak var selfiesCollectionView: UICollectionView!
    private var waitingView : WaitingView!
    private var imageExtractor : ImageExtractor!
    private var selfieSenseiAnalyzor : SelfieSenseiAnalyzer!
    var videoURL : URL!
    lazy var photos: [INSPhotoViewable] = { return
    
    [
        INSPhoto(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImageURL: URL(string:"http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg")!)
//            INSPhoto(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg"), thumbnailImage: UIImage(named: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg")!),
//            INSPhoto(image: UIImage(named: "http://inspace.io/assets/portfolio/thumb/13-3f15416ddd11d38619289335fafd498d.jpg")!, thumbnailImage: UIImage(named: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg")!),
//            INSPhoto(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg")),
//            INSPhoto(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg")),
//            INSPhoto(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"))
        
    ]}()
    
    var preprocessingPhotos : [INSPhotoViewable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start VC")
        self.selfiesCollectionView.delegate = self
        self.selfiesCollectionView.dataSource = self
        self.waitingView = WaitingView(frame: self.view.frame)
        self.view.addSubview(self.waitingView)
        self.waitingView.isHidden = true
        self.startImageExtraction()
        print("load attribute")
        for photo in photos {
            if let photo = photo as? INSPhoto {
                photo.attributedTitle = NSAttributedString(string: "Example caption text\ncaption text", attributes: [NSForegroundColorAttributeName: UIColor.white])
            }
        }
        print("done")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelfieCell", for: indexPath) as! SelfieCollectionViewCell
        cell.populateWithPhoto(photos[(indexPath as NSIndexPath).row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SelfieCollectionViewCell
        let currentPhoto = photos[(indexPath as NSIndexPath).row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photos.index(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                return collectionView.cellForItem(at: indexPath) as? SelfieCollectionViewCell
            }
            return nil
        }
        present(galleryPreview, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func startImageExtraction() {
        self.imageExtractor = ImageExtractor(sourceURL: self.videoURL)
        let photos = self.imageExtractor.extractFramesFromVideo()
        self.selfieSenseiAnalyzor = SelfieSenseiAnalyzer(delegate: self, with: photos)
        self.selfieSenseiAnalyzor.uploadImagesToServer()
        
    }

}
