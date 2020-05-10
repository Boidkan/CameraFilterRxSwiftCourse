//
//  PhotosCollectionViewController.swift
//  CameraFilter
//
//  Created by Mohammad Azam on 2/13/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift

class PhotosCollectionViewController: UICollectionViewController {
    
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    
    var selectedPhoto: Observable<UIImage> {
        return selectedPhotoSubject.asObserver()
    }
    
    private var assets: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populatePhotos()
    }
    
    func populatePhotos() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                let assets = PHAsset.fetchAssets(with: .image, options: nil)
                
                assets.enumerateObjects { asset, _, _ in
                    self?.assets.append(asset)
                }
                
                self?.assets.reverse()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                
            case .denied,
                 .notDetermined,
                 .restricted:
                break
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAsset = self.assets[indexPath.row]
        
        let size = CGSize(width: 300, height: 300)
        PHImageManager.default().requestImage(for: selectedAsset,
                                              targetSize: size,
                                              contentMode: .aspectFit,
                                              options: nil)
        { [weak self] image, info in
            guard let info = info else { return }
            
            guard let isDegradedImage = info["PHImageResultIsDegradedKey"] as? Bool else {
                return
            }
            
            if !isDegradedImage {
                if let image = image {
                    self?.selectedPhotoSubject.onNext(image)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.assets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let asset = assets[indexPath.row]
        let manager = PHImageManager.default()
        
        let size = CGSize(width: 100, height: 100)
        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .aspectFit,
                             options: nil)
        { image, _ in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        return cell
    }
}
