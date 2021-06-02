//
//  VideoCapture.m
//  SegmentDemo
//
//  Created by fcq on 2021/5/13.
//

#import "VideoCapture.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@interface VideoCapture ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) AVCaptureVideoDataOutput *video_output;
@property (nonatomic,strong) AVCaptureSession  *m_session;

//@property (weak, nonatomic) IBOutlet UIView *m_displayView;

@end

@implementation VideoCapture

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self startCaptureSession];
        
    }
    return self;
}
- (void)startCaptureSession
{
    NSError *error = nil;
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        session.sessionPreset = AVCaptureSessionPreset1920x1080;
    }else{
        session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error || !input) {
        NSLog(@"get input device error...");
        return;
    }
    [session addInput:input];
    
    _video_output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:_video_output];
    
    // Specify the pixel format
    _video_output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                              forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    _video_output.alwaysDiscardsLateVideoFrames = NO;
    dispatch_queue_t video_queue = dispatch_queue_create("MIVideoQueue", NULL);
    [_video_output setSampleBufferDelegate:self queue:video_queue];
    
    CMTime frameDuration = CMTimeMake(1, 30);
    BOOL frameRateSupported = NO;
    
    for (AVFrameRateRange *range in [device.activeFormat videoSupportedFrameRateRanges]) {
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
            CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupported = YES;
        }
    }
    
    if (frameRateSupported && [device lockForConfiguration:&error]) {
        [device setActiveVideoMaxFrameDuration:frameDuration];
        [device setActiveVideoMinFrameDuration:frameDuration];
        [device unlockForConfiguration];
    }
    
    [self adjustVideoStabilization];
    _m_session = session;
    
    
//    CALayer *previewViewLayer = [self.m_displayView layer];
//    previewViewLayer.backgroundColor = [[UIColor blackColor] CGColor];
//
//    AVCaptureVideoPreviewLayer *newPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_m_session];
//
//    [newPreviewLayer setFrame:[UIApplication sharedApplication].keyWindow.bounds];
//
//    [newPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
//    //    [previewViewLayer insertSublayer:newPreviewLayer atIndex:2];
//    [previewViewLayer insertSublayer:newPreviewLayer atIndex:0];
}
- (void)adjustVideoStabilization
{
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeAuto]) {
                for (AVCaptureConnection *connection in _video_output.connections) {
                    for (AVCaptureInputPort *port in [connection inputPorts]) {
                        if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                            if (connection.supportsVideoStabilization) {
                                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeStandard;
                                NSLog(@"now videoStabilizationMode = %ld",(long)connection.activeVideoStabilizationMode);
                            }else{
                                NSLog(@"connection does not support video stablization");
                            }
                        }
                    }
                }
            }else{
                NSLog(@"device does not support video stablization");
            }
        }
    }
}
- (void)startPreview
{
    if (![_m_session isRunning]) {
        [_m_session startRunning];
    }
}

- (void)stopPreview
{
    if ([_m_session isRunning]) {
        [_m_session stopRunning];
    }
}
#pragma mark -AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"%s",__func__);
}

// 有丢帧时，此代理方法会触发
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"MediaIOS: 丢帧...");
}

@end
