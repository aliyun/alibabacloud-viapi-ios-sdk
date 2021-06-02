//
//  ImageRender.swift
//  DaMoLab
//
//  Created by 薛林 on 2020/10/12.
//  Copyright © 2020 AlibabaGroup. All rights reserved.
//

import UIKit

class ImageRender: NSObject {
    
    private var context: CIContext?
    
    @objc override init() {
        super.init()
        context = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)
    }
    
    // MARK: - render CIImage to CVPixelBuffer
    @objc public func render(from image: CIImage) -> CVPixelBuffer? {
        let pixelBuffer = convert(from: image)
        guard let pix = pixelBuffer else { return nil }
        // 将图像渲染到buffer上
        context?.render(image, to: pix)
        return pix
    }
    
    // MARK: - convert CIImage to CVPixelBuffer
    private func convert(from image: CIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.extent.width), Int(image.extent.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)

        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        return pixelBuffer
    }
    
    // MARK: - convert CIImage to UIImage
    @objc public func convertCIImageToUIImage(_ ciImage: CIImage) -> UIImage? {
        let cgImage = context?.createCGImage(ciImage, from: ciImage.extent)
        guard let cg = cgImage else { return nil }
        let image: UIImage = UIImage.init(cgImage: cg)
        return image
    }
}
