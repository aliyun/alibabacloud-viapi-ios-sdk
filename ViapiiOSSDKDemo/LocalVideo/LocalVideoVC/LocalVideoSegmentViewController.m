//
//  VideoSegmentViewController.m
//  SegmentDemo
//
//  Created by fcq on 2021/5/12.
//

#import "LocalVideoSegmentViewController.h"
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MetalKit/MetalKit.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Masonry/Masonry.h>
#import <TZImagePickerController.h>
#import <ViapiIosSDK/HumanLocalVideoSegmentor.h>
#import "UIView+YYAdd.h"
#import "UIImage+YYAdd.h"
#import "LocalVideoCompositeVideoViewController.h"

@interface LocalVideoSegmentViewController ()

@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
///视频阅读
@property(nonatomic,strong) AVAssetReader* avAssetReader;
///关闭
@property (nonatomic, strong) UIButton *closeBtn;
///选择视频
@property(nonatomic,strong)UIButton*selectVideoBtn;
///替换背景
@property (nonatomic, strong) UIButton *replaceBgViewBtn;
/// 合成视频
@property (nonatomic, strong) UIButton *compositeVideoBtn;

@property (nonatomic, strong) UIView *playerView;
@property(nonatomic,strong)HumanLocalVideoSegmentor*localVideoSegmentor;
@property(nonatomic,strong)UIImageView*bgImageView;
@property(nonatomic,strong)UIImageView*segmentImageView;

@property(nonatomic,strong)NSString*videoPathString;
@property (nonatomic, strong) UIImage *backgroundImage;
@property(nonatomic,strong)NSMutableArray*segmentArray;
/// 全局变量
@property(nonatomic,assign)CVPixelBufferRef pixelBuffer;
@end


@implementation LocalVideoSegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.segmentArray = [NSMutableArray array];
    self.backgroundImage = nil;
    [self createUI];
    [self initSegmentation];
}

-(void)initSegmentation{
#warning 默认运行注释这条。自己检查bundleID改bundle id
    //    NSString *licensePath= [[NSBundle mainBundle] pathForResource:@"damo-viapi.license" ofType:nil];
    
    NSString *licensePath= [[NSBundle mainBundle] pathForResource:@"wcl-damo-viapi.license" ofType:nil];
    
    NSString *modelPath= [[NSBundle mainBundle] pathForResource:@"segvHuman" ofType:@"nn"];
    self.localVideoSegmentor = [[HumanLocalVideoSegmentor alloc]init];
    [self.localVideoSegmentor checkLocalVideoLicensePath:licensePath withCallBack:^(int errorCode) {
        NSLog(@"check证书结果:%d",(errorCode));
    }];
    [self.localVideoSegmentor createLocalVideoSegmentationObjectWithCallBack:^(int errorCode) {
        NSLog(@"创建对象失败，错误码为%d",errorCode);
    }];
    [self.localVideoSegmentor initLocalVideoSegmentationModelPath:modelPath withCallBack:^(int errorCode) {
        NSLog(@"初始化对象失败，错误码为%d",errorCode);
    }];
    [self.localVideoSegmentor getLocalVideoLicenseExpirTimeWithCallBack:^(NSString * _Nonnull expirTime) {
        NSLog(@"本地视频证书过期时间:%@",expirTime);
    }];
    
}

- (void)createUI{
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    [self.selectVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.equalTo(self.closeBtn.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [self.replaceBgViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectVideoBtn.mas_bottom).mas_equalTo(15);
        make.centerX.equalTo(self.selectVideoBtn.mas_centerX);
        make.width.height.equalTo(self.selectVideoBtn);
    }];
    
    [self.compositeVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.replaceBgViewBtn.mas_bottom).mas_equalTo(15);
        make.centerX.equalTo(self.replaceBgViewBtn.mas_centerX);
        make.width.height.equalTo(self.replaceBgViewBtn);
    }];
    
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.closeBtn.mas_bottom).offset(10);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(-self.view.frame.size.height/2);
    }];
    self.bgImageView.frame = CGRectMake(0, self.view.frame.size.height/2+10, self.view.frame.size.width, self.view.frame.size.height/2-20);
    self.bgImageView.centerX = self.view.centerX;
    self.segmentImageView.frame = self.bgImageView.frame;
    self.segmentImageView.centerX = self.bgImageView.centerX;
    self.segmentImageView.width = self.bgImageView.width;
    self.segmentImageView.height = self.bgImageView.height;
    [self.playerView layoutIfNeeded];
    [self.bgImageView layoutIfNeeded];
    [self.segmentImageView layoutIfNeeded];
    
    
}

#pragma mark -手动清空 handle
-(void)pushNextPage{
    [self.playerItem cancelPendingSeeks];
    [self.playerItem.asset cancelLoading];
    [self.avAssetReader cancelReading];
    [self.segmentArray removeAllObjects];
    self.backgroundImage = [UIImage imageWithColor:UIColor.blackColor size:self.bgImageView.size];
    self.bgImageView.image = self.backgroundImage;
    self.avAssetReader = nil;
    self.player = nil;
    self.playerItem = nil;
}
/// 视频结束
/// @param videoTime 视频时长
-(void)videoPlayEndWithTime:(CGFloat)videoTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        //        self.compositeVideoBtn.hidden = NO;
        [self.localVideoSegmentor resetLocalVideoRamWithCallBack:^(int errorCode) {
            NSLog(@"释放内存失败,错误吗:%d",errorCode);
        }];
    });
}

#pragma mark-写成视频
-(void)writePicToVideo{
    //设置mp4路径
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *moviePath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"test"]];
    self.videoPathString=moviePath;
    //定义视频的大小320 480 倍数
    CGSize size = CGSizeMake(320, 480);//self.bgImageView.size;
    NSError *error =nil;
    //    转成UTF-8编码
    unlink([moviePath UTF8String]);
    NSLog(@"path->%@",moviePath);
    //     iphone提供了AVFoundation库来方便的操作多媒体设备，AVAssetWriter这个类可以方便的将图像和音频写成一个完整的视频文件
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:moviePath] fileType:AVFileTypeMPEG4 error:&error];
    
    NSParameterAssert(videoWriter);
    if(error)viLog(@"error =%@", [error localizedDescription]);
    //mov的格式设置 编码格式 宽度 高度
    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    
    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    //    AVAssetWriterInputPixelBufferAdaptor提供CVPixelBufferPool实例,
    //    可以使用分配像素缓冲区写入输出文件。使用提供的像素为缓冲池分配通常
    //    是更有效的比添加像素缓冲区分配使用一个单独的池
    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput])
    {
        [videoWriter addInput:writerInput];
        [videoWriter startWriting];
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
    }
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame =0;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        //写入时的逻辑：将数组中的每一张图片多次写入到buffer中，
        while([writerInput isReadyForMoreMediaData])
        {
            if(++frame >=self.segmentArray.count)
            {
                [writerInput markAsFinished];
                [videoWriter finishWritingWithCompletionHandler:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ViProgressHub hide];
                        LocalVideoCompositeVideoViewController*lvc = [LocalVideoCompositeVideoViewController new];
                        lvc.videoString = self.videoPathString;
                        lvc.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:lvc animated:YES completion:^{
                            [self pushNextPage];
                        }];
                    });
                }];
                break;
                
            }
            int idx =frame;
            //将图片转成buffer
            CVPixelBufferRef buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[self.segmentArray[idx]CGImage] size:size];
            if (buffer)
            {
                //添加buffer并设置每个buffer出现的时间，每个buffer的出现时间为第n张除以30（30是一秒30张图片，帧率，也可以自己设置其他值）所以为frame/30，即CMTimeMake(frame,30)为每一个buffer出现的时间点
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,30)])//设置每秒钟播放图片的个数
                {
                    NSLog(@"FAIL");
                }
                else
                {
                    NSLog(@"OK");
                }
                CVPixelBufferRelease(buffer);
                buffer = nil;
            }
        }
    }];
}


static OSType inputPixelFormat(){
    return kCVPixelFormatType_32BGRA;
}

static uint32_t bitmapInfoWithPixelFormatType(OSType inputPixelFormat, bool hasAlpha){
    
    if (inputPixelFormat == kCVPixelFormatType_32BGRA) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        return bitmapInfo;
    }else if (inputPixelFormat == kCVPixelFormatType_32ARGB) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big;
        return bitmapInfo;
    }else{
        NSLog(@"不支持此格式");
        return 0;
    }
}

// alpha的判断
BOOL CGImageRefContainsAlpha(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

// 此方法能还原真实的图片
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)imageRef size:(CGSize)size
{
    BOOL hasAlpha = CGImageRefContainsAlpha(imageRef);
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             empty, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, inputPixelFormat(), (__bridge CFDictionaryRef) options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferRetain(pxbuffer);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    //
    uint32_t bitmapInfo = bitmapInfoWithPixelFormatType(inputPixelFormat(), (bool)hasAlpha);
    //
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, bitmapInfo);
    NSParameterAssert(context);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
    self.pixelBuffer = pxbuffer;
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    CVPixelBufferRelease(pxbuffer);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    return self.pixelBuffer;
    
}


- (UIImage*)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //Generate image to edit
    CVImageBufferRef pixelBuffer = [self.localVideoSegmentor segmentationLocalVideoFromBuffer:imageBuffer withCallBack:^(int errorCode) {
        viLog(@"%d",errorCode);
    }];
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    unsigned char* pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    //unlock the base address of the pixel buffer
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context=CGBitmapContextCreate(pixel, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    CGImageRef image = CGBitmapContextCreateImage(context);
    UIImage *uiImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return uiImage;
    
}
//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize

{
    //    新创建的位图上下文 newSize为其大小
    UIGraphicsBeginImageContext(newSize);
    //    对图片进行尺寸的改变
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    //    从当前上下文中获取一个UIImage对象  即获取新的图片对象
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}
#pragma mark -压缩0.5倍图片到数组
-(void)setupImage:(UIImage*)uiImage{
    dispatch_async(dispatch_get_main_queue(), ^{
        //            self.compositeVideoBtn.hidden = YES;
        self.bgImageView.image = uiImage;
//        NSData*imageData = UIImageJPEGRepresentation(uiImage, 0.5);
        UIImage*images = uiImage;//[UIImage imageWithData:imageData]
        //设置image的尺寸
        CGSize imgeSize = CGSizeMake(320, 480);
        //对图片大小进行压缩--
        images = [self imageWithImage:uiImage scaledToSize:imgeSize];
        [self.segmentArray addObject:images==nil?[UIImage imageWithColor:UIColor.blackColor size:self.bgImageView.size]:images];
    });
    
}


#pragma mark-2+到1图片上
-(UIImage *)addTwoImageToOne:(UIImage *)oneImg twoImage:(UIImage *)twoImg topleft:(CGPoint)tlPos
{
    //            UIGraphicsBeginImageContextWithOptions(self.bgImageView.size, NO, 0);
    //            [oneImg drawInRect:CGRectMake(0, 0, self.bgImageView.size.width, self.bgImageView.size.height)];
    //            [twoImg drawInRect:CGRectMake(0, 0, self.bgImageView.size.width, self.bgImageView.size.height)];
    //            UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    //            UIGraphicsEndImageContext();
    //            return resultImg;
    
    UIGraphicsImageRenderer*renderer = [[UIGraphicsImageRenderer alloc]initWithSize:self.bgImageView.size];
    UIImage*resultImg = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [oneImg drawInRect:CGRectMake(0, 0, self.bgImageView.size.width, self.bgImageView.size.height)];
        [twoImg drawInRect:CGRectMake(0, 0, self.bgImageView.size.width/2, self.bgImageView.size.height/2)];
    }];
    return resultImg;
}



-(void)playerURL:(AVURLAsset*)asset{
    [self.playerItem cancelPendingSeeks];
    [self.playerItem.asset cancelLoading];
    [self.playerLayer removeFromSuperlayer];
    [self.avAssetReader cancelReading];
    self.avAssetReader = nil;
    NSError*error;
    self.avAssetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    NSArray* videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count == 0) {
        viLog(@"视频获取失败");
        return;
    }
    AVAssetTrack* videoTrack = [videoTracks objectAtIndex:0];
    int m_pixelFormatType = kCVPixelFormatType_32BGRA;
    NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt: (int)m_pixelFormatType] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput* videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:options];
    [self.avAssetReader addOutput:videoReaderOutput];
    [self.avAssetReader startReading];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [ViProgressHub showProgress:@"视频分割处理中" inView:self.view];
    }];
    // 读取视频每一个buffer转换成CGImageRef
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CMSampleBufferRef audioSampleBuffer = NULL;
        
        while ([self.avAssetReader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
            CMSampleBufferRef sampleBuffer = [videoReaderOutput copyNextSampleBuffer];
            UIImage *uiImage = [self imageFromSampleBuffer:sampleBuffer];
            //            viLog(@"w:%f--h:%f",uiImage.size.width,uiImage.size.height);
            [self setupImage:uiImage];
            if(sampleBuffer) {
                if(audioSampleBuffer) { // release old buffer.
                    CFRelease(audioSampleBuffer);
                    audioSampleBuffer = nil;
                }
                audioSampleBuffer = sampleBuffer;
            } else {
                break;
            }
            // 休眠的间隙刚好是每一帧的间隔
            //            [NSThread sleepForTimeInterval:CMTimeGetSeconds(videoTrack.minFrameDuration)];
        }
        // decode finish
        CGFloat durationInSeconds = CMTimeGetSeconds(asset.duration);
        NSLog(@"%f",durationInSeconds);
        [self videoPlayEndWithTime:durationInSeconds];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [ViProgressHub hide];
            viLog(@"%@",self.segmentArray);
        }];
        [self.avAssetReader cancelReading];
        
    });
    
    // playerItem
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    //    self.playerItem.videoComposition = self.videoComposition;
    // player
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    // playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.playerView.bounds;
    //    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.playerView.layer addSublayer:self.playerLayer];
    [self.player play];
}

#pragma mark-合成视频handle
-(void)compositeVideoBtnHandle:(UIButton*)sender{
//    if (self.segmentArray.count>0) {
        [self compositeVideo];
//    }
//    else{
//        [ViProgressHub showMessage:@"请选择视频" inView:self.view afterDelayTime:2];
//    }
//    LocalVideoCompositeVideoViewController*lvc = [LocalVideoCompositeVideoViewController new];
//    lvc.videoString = self.videoPathString;
//    lvc.bgImage = self.backgroundImage;
//    lvc.picArr = self.segmentArray;
//    lvc.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:lvc animated:YES completion:^{
//        [self pushNextPage];
//    }];
}

#pragma mark-选择视频
-(void)selectVideoBtnHandle:(UIButton*)sender{
    TZImagePickerController* imagePickerVc = [[TZImagePickerController alloc]init];
    imagePickerVc.allowPickingImage = false;
    imagePickerVc.allowPickingVideo = true;
    imagePickerVc.allowTakeVideo = false;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        
        CGFloat realheight = self.view.frame.size.height/2-20;
        self.bgImageView.width = realheight/coverImage.size.height*coverImage.size.width;
        self.bgImageView.height = realheight;
        self.bgImageView.centerX = self.view.centerX;
        self.segmentImageView.width = self.bgImageView.width;
        self.segmentImageView.height = self.bgImageView.height;
        self.segmentImageView.centerX = self.bgImageView.centerX;
        if (asset.mediaType != PHAssetMediaTypeVideo) {
            return;
        }
        [[PHCachingImageManager defaultManager]requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            NSLog(@"%@",asset);
            if (asset == nil) {
                return;
            }
            [self.segmentArray removeAllObjects];
            AVURLAsset*realAsset = (AVURLAsset*)asset;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playerURL:realAsset];
            });
        }];
        
    }];
    
}
-(void)compositeVideo{
    
    [ViProgressHub showProgress:@"视频合成中" inView:self.view];
//    if (self.backgroundImage == nil) {
//        self.backgroundImage = [UIImage imageWithColor:UIColor.blackColor size:self.bgImageView.size];
//        NSMutableArray*realArray = [NSMutableArray array];
//        for (int i=0; i<self.segmentArray.count; i++) {
//            UIImage*image = self.segmentArray[i];
//            UIImage*realImage = [self addTwoImageToOne:self.backgroundImage twoImage:image==nil?[UIImage imageWithColor:UIColor.blackColor size:self.bgImageView.size]:image topleft:CGPointZero];
//            [realArray addObject:realImage];
//        }
//        [self.segmentArray removeAllObjects];
//        [self.segmentArray addObjectsFromArray:realArray];
//        [self writePicToVideo];
//    }else
//    {
        [self writePicToVideo];
//    }
}

#pragma mark -更新bgImagePic
-(void)reUpdatePicArray{
    [ViProgressHub showProgress:@"背景图片更换中" inView:self.view];
    if (self.backgroundImage != nil) {
        NSMutableArray*realArray = [NSMutableArray array];
        for (int i=0; i<self.segmentArray.count; i++) {
            UIImage*image = self.segmentArray[i];
            UIImage*twoImage = image==nil?[UIImage imageWithColor:UIColor.blackColor size:self.bgImageView.size]:image;
            UIImage*realImage = [self addTwoImageToOne:self.backgroundImage twoImage:twoImage topleft:CGPointZero];
            [realArray addObject:realImage];
        }
        [self.segmentArray removeAllObjects];
        [self.segmentArray addObjectsFromArray:realArray];
        [ViProgressHub hide];
    }
}

#pragma mark -背景选择
-(void)replaceBgViewBtnHandle:(UIButton*)sender{
    if (self.segmentArray.count==0) {
        [ViProgressHub showMessage:@"请先选择视频" inView:self.view];
        return;
    }
    TZImagePickerController* imagePickerVc = [[TZImagePickerController alloc]init];
    imagePickerVc.allowPickingImage = true;
    imagePickerVc.allowPickingVideo = false;
    imagePickerVc.allowTakeVideo = false;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        UIImage*image = photos.firstObject;
        image = [self imageWithImage:image scaledToSize:CGSizeMake(320, 480)];
        self.backgroundImage = image;
        self.bgImageView.image = self.backgroundImage;
        [self reUpdatePicArray];
    }];
}
-(void)closeBtn:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.localVideoSegmentor destroyLocalVideoSegmentationObjectWithCallBack:^(int errorCode) {
            NSLog(@"%d",errorCode);
        }];
    }];
}

#pragma mark -懒加载
-(UIView *)playerView
{
    if (!_playerView) {
        _playerView = [UIView new];
        _playerView.userInteractionEnabled = YES;
        [self.view insertSubview:_playerView atIndex:0];
    }
    return _playerView;
}
- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeBtn.backgroundColor = [UIColor orangeColor];
        _closeBtn.clipsToBounds = YES;
        _closeBtn.layer.cornerRadius = 5;
        [_closeBtn addTarget:self action:@selector(closeBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.closeBtn];
        
    }
    return _closeBtn;
}

- (UIButton *)replaceBgViewBtn
{
    if (!_replaceBgViewBtn) {
        _replaceBgViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replaceBgViewBtn setTitle:@"背景选择" forState:UIControlStateNormal];
        [_replaceBgViewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _replaceBgViewBtn.backgroundColor = [UIColor orangeColor];
        _replaceBgViewBtn.clipsToBounds = YES;
        _replaceBgViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _replaceBgViewBtn.layer.cornerRadius = 15;
        [_replaceBgViewBtn addTarget:self action:@selector(replaceBgViewBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.replaceBgViewBtn];
        [self.view bringSubviewToFront:self.replaceBgViewBtn];
    }
    return _replaceBgViewBtn;
}

- (UIButton *)compositeVideoBtn
{
    if (!_compositeVideoBtn) {
        _compositeVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_compositeVideoBtn setTitle:@"合成视频" forState:UIControlStateNormal];
        [_compositeVideoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _compositeVideoBtn.backgroundColor = [UIColor orangeColor];
        _compositeVideoBtn.clipsToBounds = YES;
        _compositeVideoBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _compositeVideoBtn.layer.cornerRadius = 15;
        [_compositeVideoBtn addTarget:self action:@selector(compositeVideoBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.compositeVideoBtn];
        [self.view bringSubviewToFront:self.compositeVideoBtn];
        
    }
    return _compositeVideoBtn;
}

- (UIButton *)selectVideoBtn
{
    if (!_selectVideoBtn) {
        _selectVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectVideoBtn setTitle:@"视频选择" forState:UIControlStateNormal];
        [_selectVideoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectVideoBtn.backgroundColor = [UIColor orangeColor];
        _selectVideoBtn.clipsToBounds = YES;
        _selectVideoBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _selectVideoBtn.layer.cornerRadius = 15;
        [_selectVideoBtn addTarget:self action:@selector(selectVideoBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.selectVideoBtn];
        
    }
    return _selectVideoBtn;
}

-(UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.backgroundColor = UIColor.blackColor;
        _bgImageView.clipsToBounds = YES;
        [self.view addSubview:_bgImageView];
    }
    return _bgImageView;
}
-(UIImageView *)segmentImageView{
    if (!_segmentImageView) {
        _segmentImageView = [UIImageView new];
        _segmentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_segmentImageView];
        [self.view bringSubviewToFront:_segmentImageView];
    }
    return _segmentImageView;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
