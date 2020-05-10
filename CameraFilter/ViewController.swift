//
//  ViewController.swift
//  CameraFilter
//
//  Created by Mohammad Azam on 2/13/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var filterButton: UIButton!
    
    private let disposeBage = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController,
            let photosVC = nav.viewControllers.first as? PhotosCollectionViewController else {
                fatalError("Did not find navigation controller or photos vc")
        }
        
        photosVC.selectedPhoto.subscribe(onNext: { [weak self] image in
            DispatchQueue.main.async {
                self?.updateUI(with: image)
            }
            }).disposed(by: disposeBage)
        
    }
    
    private func updateUI(with image: UIImage) {
        self.imageView?.image = image
        self.filterButton.isHidden = false
    }

    @IBAction func applyFilterPressed(_ sender: Any) {
        guard let sourceImage = self.imageView?.image else { return }
        FilterService().applyFilter(to: sourceImage)
            .subscribe(onNext: { filteredImage in
                DispatchQueue.main.async {
                    self.imageView?.image = filteredImage
                }
        }).disposed(by: disposeBage)        
    }
}

