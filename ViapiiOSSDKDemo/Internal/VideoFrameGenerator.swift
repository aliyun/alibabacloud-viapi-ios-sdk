//
//  VideoFrameGenerator.swift
//  DaMoLab
//
//  Created by 薛林 on 2020/10/12.
//  Copyright © 2020 AlibabaGroup. All rights reserved.
//

import UIKit
import AVFoundation

/// 用来管理和处理帧图片
class VideoFrameGenerator: NSObject {
    
    /// 获取视频第一帧图片
    /// - Parameter url: 视频地址
    /// - Returns: 帧图片
    @objc class public func videoFirstFrame(url: URL) -> UIImage? {
        return videoFrame(url: url, fromTime: 0)
    }
    
    /// 获取任意时间的帧图片
    /// - Parameters:
    ///   - url: 视频地址
    ///   - fromTime: 需要获取的时间
    @objc class public func videoFrame(url: URL, fromTime: Float64) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        let time: CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale: 600)
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("\(error)")
            return nil
        }
    }
    
    /// 按照秒获取所有帧图
    /// - Parameter url: 视频地址
    /// - Returns: 帧图片数组
    @objc class public func getAllFrames(url: URL) -> [UIImage]? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        let duration = CMTimeGetSeconds(asset.duration)
        generator.appliesPreferredTrackTransform = true
        var frames: [UIImage] = []
        
        for index in 0..<Int(duration) {
            let time: CMTime = CMTimeMakeWithSeconds(Float64(index), preferredTimescale: 600)
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                frames.append(UIImage(cgImage: cgImage))
            } catch {
                print("\(error)")
            }
        }
        return frames
    }
    
    /// 获取视频总帧数
    /// - Parameter url: 视频地址
    /// - Returns: 总帧数
    @objc public class func videoTotalFrames(url: URL?) -> Int {
        guard let targetUrl = url else { return 0 }
        let asset = AVAsset(url: targetUrl)
        let assetTrack = asset.tracks(withMediaType: .video).first!
        let assetReader = try! AVAssetReader(asset: asset)
        let assetReaderOutputSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        let assetReaderOutput = AVAssetReaderTrackOutput(track: assetTrack, outputSettings: assetReaderOutputSettings)
        assetReaderOutput.alwaysCopiesSampleData = false
        assetReader.add(assetReaderOutput)
        assetReader.startReading()

        var frameCount = 0
        var sample: CMSampleBuffer? = assetReaderOutput.copyNextSampleBuffer()

        while (sample != nil) {
            frameCount += 1
            sample = assetReaderOutput.copyNextSampleBuffer()
        }
        return frameCount
    }
}
