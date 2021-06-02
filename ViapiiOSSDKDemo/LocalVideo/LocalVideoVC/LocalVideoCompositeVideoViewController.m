//
//  LocalVideoCompositeVideoViewController.m
//  ViapiiOSSDKDemo
//
//  Created by wclin on 2021/5/25.
//

#import "LocalVideoCompositeVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
@interface LocalVideoCompositeVideoViewController ()
@property (strong, nonatomic)AVPlayer *myPlayer;//播放器
@property (strong, nonatomic)AVPlayerLayer *playerLayer;//播放界面（layer）
///关闭
@property (nonatomic, strong) UIButton *closeBtn;

@property(nonatomic,strong)UIImageView*oneImageView;

@property(nonatomic,strong)UIImageView*twoImageView;

@end

@implementation LocalVideoCompositeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self createUI];
    [self seupLayout];
    [self addBlock];
}

-(void)seupLayout{
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
//    [self.oneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view.mas_top).offset(88);
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.width.mas_equalTo(241);
//        make.height.mas_equalTo(480);
//    }];
}

-(UIImageView *)oneImageView
{
    if (!_oneImageView) {
        _oneImageView = [UIImageView new];
        _oneImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_oneImageView];
    }
    return _oneImageView;
}
//- (void)playAnimationWithImagesArray:(NSArray *)imagesArray repeatCount:(int)count duration:(float)duration{
//    @autoreleasepool {
//        // 设置播放动画图片
//        self.oneImageView.animationImages = imagesArray;
//        // 设置播放次数 0就是不限次
//        self.oneImageView.animationRepeatCount = count;
//        // 播放时长
//        self.oneImageView.animationDuration = duration;
//        // 播放
//        [self.oneImageView startAnimating];
//    }
//}

-(void)addBlock{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.myPlayer.currentItem];
    viLog(@"%@",self.videoString);
//    [self playAnimationWithImagesArray:self.picArr repeatCount:0 duration:self.picArr.count/30];
//    for (UIImage*image2 in self.picArr) {
//        self.oneImageView.image = image2;
//    }
}
-(void)createUI{
    NSURL *videoURL = [NSURL fileURLWithPath:self.videoString];
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    self.myPlayer = player;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.view.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    self.playerLayer = playerLayer;
    [self.view.layer addSublayer:playerLayer];
    [player play];
    

}




-(void)playbackFinished:(NSNotification*)noti{
    [self.myPlayer seekToTime:kCMTimeZero];
    [self.myPlayer play];
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
        [self.view bringSubviewToFront:self.closeBtn];
        
    }
    return _closeBtn;
}
-(void)closeBtn:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.view.layer removeFromSuperlayer];
    }];
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
