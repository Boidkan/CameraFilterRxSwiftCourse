//
//  FilterService.swift
//  CameraFilter
//
//  Created by Eric Collom on 5/10/20.
//  Copyright © 2020 Mohammad Azam. All rights reserved.
//

import UIKit
import CoreImage
import RxSwift

class FilterService {
    private var context: CIContext
    
    init() {
        self.context = CIContext()
    }
    
    func applyFilter(to inputImage: UIImage) -> Observable<UIImage> {
        return Observable<UIImage>.create { observer in
            self.applyFilter(to: inputImage) { filteredImage in
                observer.onNext(filteredImage)
            }
            
            return Disposables.create()
        }
    }
    
    private func applyFilter(to inputImage: UIImage, completon: @escaping ((UIImage) -> Void)) {
        
        guard let sourceImage = CIImage(image: inputImage),
            let filter = CIFilter(name: "CICMYKHalftone") else {
                return
        }
        
        filter.setValue(5, forKey: kCIInputWidthKey)
        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage,
            let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) else {
            return
        }
            
        let processedImage = UIImage(cgImage: cgImage, scale: inputImage.scale, orientation: inputImage.imageOrientation)
        
        completon(processedImage)
    }
}
