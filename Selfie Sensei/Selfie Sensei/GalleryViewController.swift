//
//  GalleryViewController.swift
//  Selfie Sensei
//
//  Created by Tony Tung on 5/30/17.
//  Copyright © 2017 Tony Tung. All rights reserved.
//

import UIKit
import INSPhotoGallery
import Photos

class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SelfieSenseiAnalyzerDelegate {
    private var filterMode : Bool = false
    
    
    @IBAction func modeSwitchBtn(_ sender: UIBarButtonItem) {
        self.filterMode = !self.filterMode
        self.startImageExtraction(mode: self.filterMode)
    }
    
    func showWaitingView(show: Bool) {
        if show {
            self.waitingView.isHidden = false
            self.waitingView.startAnimating()
        } else {
            self.waitingView.isHidden = true
            self.waitingView.stopAnimating()
        }
    }
    
    func showImagesToView(images: [UIImage]) {
        self.photos.removeAll()
        for image in images {
            let photoViewable : INSPhotoViewable = INSPhoto(image: image, thumbnailImage: image)
            photos.append(photoViewable)
        }
        DispatchQueue.main.async {
            self.selfiesCollectionView.reloadData()
        }
    }

    func showImagesToViewWithScores(results: [(photo: UIImage, score: Double)]) {
        self.photos.removeAll()
        for result in results {
            let photoViewable : INSPhotoViewable = INSPhoto(image: result.photo, thumbnailImage: result.photo)
            if let photo = photoViewable as? INSPhoto {
                photo.attributedTitle = NSAttributedString(string: "The score is \(String(result.score))", attributes: [NSForegroundColorAttributeName: UIColor.white])
                print("score: \(result.score)")
                photos.append(photo)
            }
            
        }
        DispatchQueue.main.async {
            self.selfiesCollectionView.reloadData()
        }
    }
    
    @IBOutlet weak var selfiesCollectionView: UICollectionView!
    private var waitingView : WaitingView!
    private var imageExtractor : ImageExtractor!
    private var selfieSenseiAnalyzor : SelfieSenseiAnalyzer?
    var videoURL : URL!
    var photos = [INSPhotoViewable]()
    
    var preprocessingPhotos : [INSPhotoViewable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start VC")
        self.selfiesCollectionView.delegate = self
        self.selfiesCollectionView.dataSource = self
        self.waitingView = WaitingView(frame: self.view.frame)
        self.view.addSubview(self.waitingView)
        self.waitingView.isHidden = true
//        self.startImageExtraction()
        self.saveVideoToAlbum(videoURL: self.videoURL)
        print("load attribute")
        print("done")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startImageExtraction(mode: self.filterMode)
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
    
    func startImageExtraction(mode : Bool) {
        if let analyzer = self.selfieSenseiAnalyzor {
            analyzer.getResult(mode: mode)
            
        } else {
//            var images = [UIImage]()
            self.selfieSenseiAnalyzor = SelfieSenseiAnalyzer(delegate: self, with: self.videoURL, and: mode)
            
        }
        
    }

    private func saveVideoToAlbum(videoURL : URL) {
        PHPhotoLibrary.shared().performChanges({
            print("start saving")
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }, completionHandler: {
            saved, error in
            if saved {
                print("saved the video")
            }
            
        })
    }
}
