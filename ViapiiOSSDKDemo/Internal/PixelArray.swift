//
//  PixelArray.swift
//  DaMoLab
//
//  Created by 薛林 on 2020/10/13.
//  Copyright © 2020 AlibabaGroup. All rights reserved.
//

import UIKit

@objc extension UIImage {
    @objc func getPixelColor(pos: CGPoint) -> NSArray? {
        guard let cgImage = self.cgImage else { return nil }
        guard let provider = cgImage.dataProvider else { return nil }
        let pixelData = provider.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        return [r, g, b, a]
    }
}
