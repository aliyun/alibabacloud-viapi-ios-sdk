//
//  HumanSegmentor.h
//  HumanSegment
//
//  Created by wclin on 2021/5/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface HumanPhotoSegmentor : NSObject

/// 检查证书路径
/// @param licensePath 鉴权证书路径 .license
/// @param callBack block
-(void)checkPhotoLicensePath:(NSString *)licensePath withCallBack:(void(^)(int errorCode))callBack;

/// 创建分割对象
/// @param callBack block
-(void)createPhotoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;

/// 初始化分割对象
/// @param modelPath 模型路径 .nn
-(void)initPhotoSegmentationModelPath:(NSString *)modelPath withCallBack:(void(^)(int errorCode))callBack;

/// 处理图片方法
/// @param originalImage 原图
/// @param callBack block
-(void)segmentationPhotoFromOriginalImage:(UIImage*)originalImage withCallBack:(void(^)(UIImage*outImage,int errorCode))callBack;

/// 摧毁分割对象
/// @param callBack block
-(void)destroyPhotoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;

/// 获取图片证书过期时间
/// @param callBack block
-(void)getPhotoLicenseExpirTimeWithCallBack:(void(^)(NSString*expirTime))callBack;

@end

NS_ASSUME_NONNULL_END
