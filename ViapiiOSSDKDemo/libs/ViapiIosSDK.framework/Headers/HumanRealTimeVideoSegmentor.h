//
//  HuManRealTimeVideoSegmentor.h
//  HumanSegment
//
//  Created by wclin on 2021/5/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    VISegmentRotation_0 = 0,
    VISegmentRotation_90 = 90,
    VISegmentRotation_180 = 180,
    VISegmentRotation_270 = 270,
} VISegmentRotation;

@interface HuManRealTimeVideoSegmentor : NSObject

/// 检查证书路径
/// @param licensePath 鉴权证书路径 .license
/// @param callBack block
-(void)checkVideoLicensePath:(NSString *)licensePath withCallBack:(void(^)(int errorCode))callBack;

/// 创建分割对象
/// @param callBack block
-(void)createVideoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;

/// 初始化分割对象
/// @param modelPath 模型路径 .nn
-(void)initVideoSegmentationModelPath:(NSString *)modelPath withCallBack:(void(^)(int errorCode))callBack;

///设置背景融合
/// @param oriBgImg 原图
/// @param w 宽
/// @param h 高
/// @param rotation 手机朝向
/// @param front 是否前置摄像头
- (BOOL)setBackBufferWithOriginalImg:(UIImage *)oriBgImg mixBufferW:(CGFloat)w mixBufferH:(CGFloat)h rotation:(VISegmentRotation)rotation isFront:(BOOL)front;

/// 视频分割方法
/// @param pixelBuffer 视频buffer
/// @param callBack block
/// @param rotation 手机朝向
/// @param front 是否前置摄像头
- (CVPixelBufferRef)segmentationVideoFromBuffer:(CVPixelBufferRef)pixelBuffer rotation:(VISegmentRotation)rotation isFront:(BOOL)front withCallBack:(void(^)(int errorCode))callBack;

/// 摧毁分割对象
/// @param callBack block
-(void)destroyVideoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;

/// 获取视频证书过期时间
/// @param callBack block
-(void)getVideoLicenseExpirTimeWithCallBack:(void(^)(NSString*expirTime))callBack;


@end

NS_ASSUME_NONNULL_END
