//
//  LocalVideoAvPlayerView.m
//  ViapiiOSSDKDemo
//
//  Created by wclin on 2021/5/21.
//

#import "LocalVideoAvPlayerView.h"
#import <TZImagePickerController.h>

@interface LocalVideoAvPlayerView()
@property (nonatomic, strong) UIView *playerView;

@end

@implementation LocalVideoAvPlayerView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        
    }
    return self;
}

-(void)tapClick:(UITapGestureRecognizer*)tap{
    TZImagePickerController* imagePickerVc = [[TZImagePickerController alloc]init];
    imagePickerVc.allowPickingImage = false;
    imagePickerVc.allowPickingVideo = true;
    imagePickerVc.allowTakeVideo = false;
    imagePickerVc.videoMaximumDuration = 60;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.parentVC presentViewController:imagePickerVc animated:YES completion:nil];
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        
        CGFloat realheight = self.frame.size.height/2-20;
//        [self.bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(realheight/coverImage.size.height*coverImage.size.width);
//            make.height.mas_equalTo(realheight);
//        }];
        if (asset.duration > 60) {
            NSLog(@"时间超过60秒时，请重新选择");
            return;
        }
        
        if (asset.mediaType != PHAssetMediaTypeVideo) {
            return;
        }
        [[PHCachingImageManager defaultManager]requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            NSLog(@"%@",asset);
            if (asset == nil) {
                return;
            }
            AVURLAsset*realAsset = (AVURLAsset*)asset;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self playerURL:realAsset];
//            });
        }];
        
    }];
    
}

#pragma mark - 懒加载
-(UIView *)playerView
{
    if (!_playerView) {
        _playerView = [UIView new];
        _playerView.backgroundColor = UIColor.cyanColor;
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        [_playerView addGestureRecognizer:tap];
        [self addSubview:_playerView];
    }
    return _playerView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
