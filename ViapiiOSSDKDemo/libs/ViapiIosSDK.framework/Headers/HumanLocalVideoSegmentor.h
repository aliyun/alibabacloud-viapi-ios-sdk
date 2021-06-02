//
//  HuManLocalVideoSegmentor.h
//  HumanSegment
//
//  Created by wclin on 2021/5/12.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HumanLocalVideoSegmentor : NSObject

///设置本地视频分割授权的证书路径
/// @param licensePath 证书路径
/// @param callBack 回调信息
-(void)checkLocalVideoLicensePath:(NSString *)licensePath withCallBack:(void(^)(int errorCode))callBack;

/// 创建分割对象
/// @param callBack block
-(void)createLocalVideoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;

/// 初始化对象
/// @param modelPath .nn
/// @param callBack block
-(void)initLocalVideoSegmentationModelPath:(NSString *)modelPath withCallBack:(void(^)(int errorCode))callBack;

/// 分割方法
/// @param pixelBuffer 视频流
/// @param callBack block
-(CVPixelBufferRef)segmentationLocalVideoFromBuffer:(CVPixelBufferRef)pixelBuffer withCallBack:(void(^)(int errorCode))callBack;

/// 重置共享内存，在一条视频结束的时候调用
/// @param callBack block
-(void)resetLocalVideoRamWithCallBack:(void(^)(int errorCode))callBack;

/// 摧毁分割对象
/// @param callBack block
-(void)destroyLocalVideoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;

/// 获取本地视频证书过期时间
/// @param callBack block
-(void)getLocalVideoLicenseExpirTimeWithCallBack:(void(^)(NSString*expirTime))callBack;

@end

NS_ASSUME_NONNULL_END
