//
//  VideoCapture.h
//  SegmentDemo
//
//  Created by fcq on 2021/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCapture : NSObject

//@property (nonatomic, copy) void(^videoCaptureBlock)(CMSampleBuffer didCaptureFrame);
- (void)startCaptureSession;
- (void)adjustVideoStabilization;
- (void)startPreview;
- (void)stopPreview;
@end

NS_ASSUME_NONNULL_END
