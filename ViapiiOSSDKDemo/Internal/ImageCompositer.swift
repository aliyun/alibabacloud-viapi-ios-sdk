//
//  LEPSManager.swift
//  LEPS
//
//  Created by 薛林 on 2020/7/24.
//  Copyright © 2020 Alibaba Group. All rights reserved.
//

import UIKit

/// 人像分割管理
public class ImageCompositer: NSObject {

    var imageRender: ImageRender!
    public override init() {
        super.init()
        imageRender = ImageRender()
    }
    
    /// 合成图像
    /// - Parameters:
    ///   - originalImage: 需要被分割的人像
    ///   - backgroundImage: 需要替换上的背景 如果为空，则不替换
    /// - Returns: 替换好背景图像的图像，如果backgroundImage为nil，那得到的图像背景为透明
    public func compositegraph(with originalImage: UIImage?, backgroundImage: UIImage?) -> UIImage? {
        guard let oriImg = originalImage, let bgImg = backgroundImage else {
            print("original image is nil")
            return nil
        }
        // 需要替换背景
        let backImg = CIImage(cgImage: bgImg.cgImage!)
        let input = CIImage(cgImage: oriImg.cgImage!).composited(over: backImg)
        return imageRender.convertCIImageToUIImage(input)
    }
    
    /// 将两张图像合成一张
//    private func compositegraph(_ a: UIImage?, _ b: UIImage?) -> UIImage? {
//        guard let image = a, let backgroundImg = b else {
//            print("compositegrash is unvalidate")
//            return nil
//        }
//        let backImg = CIImage(cgImage: backgroundImg.cgImage!)
//        let input = CIImage(cgImage: image.cgImage!).composited(over: backImg)
//        let result = UIImage(ciImage: input)
//        return result
//        let startTime = CFAbsoluteTimeGetCurrent()
        // 将b 图片处理成和目标图片相同尺寸的图片
//        let heightSacle = Float(backgroundImg.size.height) / Float(image.size.height)
//        let widthScale = Float(backgroundImg.size.width) / Float(image.size.width)
        
//        let scaleRatio = max(heightSacle, widthScale)
//        let imageWidth = Float(backgroundImg.size.width) / scaleRatio
//        let imageHeight = Float(backgroundImg.size.height) / scaleRatio
        
        // C

//        let linkTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
//        print("use time(ms): \(linkTime)")
        
//        let aRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
//        let bRect = CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: CGFloat(imageHeight))
//        let logoImage = UIImage(named: "ai_video_logo")
        
//        if #available(iOS 10.0, *) {
//            let render = UIGraphicsImageRenderer(bounds: aRect)
//            let ommd = render.image { renderContext in
//                backgroundImg.draw(in: aRect)
//                image.draw(in: aRect)
//                if let logo =  logoImage {
//                    let logoRect = CGRect(x: 16, y: 16, width: logo.size.width * 0.6, height: logo.size.height * 0.6)
//                    logo.draw(in: logoRect)
//                }
//            }
//            let linkTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
//            print("use time(ms): \(linkTime)")
//            return ommd
//        } else {
//            UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
//            backgroundImg.draw(in: aRect)
//            image.draw(in: aRect)
//            if let logo =  logoImage {
//                let logoRect = CGRect(x: 16, y: 16, width: logo.size.width * 0.6, height: logo.size.height * 0.6)
//                logo.draw(in: logoRect)
//            }
//            let resultImg = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            return resultImg
//        }
//    }
    
}
