//
//  ViProgressHub.m
//  ViapiiOSSDKDemo
//
//  Created by wclin on 2021/5/24.
//

#import "ViProgressHub.h"

@implementation ViProgressHub

+(instancetype)shareInstance{
    
    static ViProgressHub *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ViProgressHub alloc] init];
    });
    
    return instance;
    
}

+(void)show:(NSString *)msg inView:(UIView *)view mode:(ViProgressMode )myMode{
    [self show:msg inView:view mode:myMode customImgView:nil];
}

+(void)show:(NSString *)msg inView:(UIView *)view mode:(ViProgressMode )myMode customImgView:(UIImageView *)customImgView{
    //如果已有弹框，先消失
    if ([ViProgressHub shareInstance].hud != nil) {
        [[ViProgressHub shareInstance].hud hideAnimated:YES];
        [ViProgressHub shareInstance].hud = nil;
    }
    
    //4\4s屏幕避免键盘存在时遮挡
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        [view endEditing:YES];
    }
    
    [ViProgressHub shareInstance].hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    //是否设置黑色背景，这两句配合使用
    [ViProgressHub shareInstance].hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [ViProgressHub shareInstance].hud.bezelView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.7];
    [ViProgressHub shareInstance].hud.contentColor = [UIColor whiteColor];
    
    [[ViProgressHub shareInstance].hud setMargin:10];
    [[ViProgressHub shareInstance].hud setRemoveFromSuperViewOnHide:YES];
    [ViProgressHub shareInstance].hud.detailsLabel.text = msg;

    [ViProgressHub shareInstance].hud.detailsLabel.font = [UIFont systemFontOfSize:14];
    switch ((NSInteger)myMode) {
        case ViProgressModeOnlyText:
            [ViProgressHub shareInstance].hud.mode = MBProgressHUDModeText;
            break;

        case ViProgressModeLoading:
            [ViProgressHub shareInstance].hud.mode = MBProgressHUDModeIndeterminate;
            break;

        case ViProgressModeCircle:{
            [ViProgressHub shareInstance].hud.mode = MBProgressHUDModeCustomView;
            UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading"]];
            CABasicAnimation *animation= [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            animation.toValue = [NSNumber numberWithFloat:M_PI*2];
            animation.duration = 1.0;
            animation.repeatCount = 100;
            [img.layer addAnimation:animation forKey:nil];
            [ViProgressHub shareInstance].hud.customView = img;
            
            
            break;
        }
        case ViProgressModeCustomerImage:
            [ViProgressHub shareInstance].hud.mode = MBProgressHUDModeCustomView;
            [ViProgressHub shareInstance].hud.customView = customImgView;
            break;

        case ViProgressModeCustomAnimation:
            //这里设置动画的背景色
            [ViProgressHub shareInstance].hud.bezelView.color = [UIColor yellowColor];
            
            
            [ViProgressHub shareInstance].hud.mode = MBProgressHUDModeCustomView;
            [ViProgressHub shareInstance].hud.customView = customImgView;
            
            break;

        case ViProgressModeSuccess:
            [ViProgressHub shareInstance].hud.mode = MBProgressHUDModeCustomView;
            [ViProgressHub shareInstance].hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success"]];
            break;

        default:
            break;
    }
    
    
    
}
    

+(void)hide{
    if ([ViProgressHub shareInstance].hud != nil) {
        [[ViProgressHub shareInstance].hud hideAnimated:YES];
    }
}


+(void)showMessage:(NSString *)msg inView:(UIView *)view{
    [self show:msg inView:view mode:ViProgressModeOnlyText];
    [[ViProgressHub shareInstance].hud hideAnimated:YES afterDelay:1.0];
}



+(void)showMessage:(NSString *)msg inView:(UIView *)view afterDelayTime:(NSInteger)delay{
    [self show:msg inView:view mode:ViProgressModeOnlyText];
    [[ViProgressHub shareInstance].hud hideAnimated:YES afterDelay:delay];
}

+(void)showSuccess:(NSString *)msg inview:(UIView *)view{
    [self show:msg inView:view mode:ViProgressModeSuccess];
    [[ViProgressHub shareInstance].hud hideAnimated:YES afterDelay:1.0];
    
}

+(void)showMsgWithImage:(NSString *)msg imageName:(NSString *)imageName inview:(UIView *)view{
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [self show:msg inView:view mode:ViProgressModeCustomerImage customImgView:img];
    [[ViProgressHub shareInstance].hud hideAnimated:YES afterDelay:1.0];
}


+(void)showProgress:(NSString *)msg inView:(UIView *)view{
    [self show:msg inView:view mode:ViProgressModeLoading];
}

+(MBProgressHUD *)showProgressCircle:(NSString *)msg inView:(UIView *)view{
    if (view == nil) view = (UIView*)[UIApplication sharedApplication].delegate.window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.detailsLabel.text = msg;
    return hud;
    
    
}

+(void)showProgressCircleNoValue:(NSString *)msg inView:(UIView *)view{
    [self show:msg inView:view mode:ViProgressModeCircle];
    
}


+(void)showMsgWithoutView:(NSString *)msg{
    UIWindow *view = [[UIApplication sharedApplication].windows lastObject];
    [self show:msg inView:view mode:ViProgressModeOnlyText];
    [[ViProgressHub shareInstance].hud hideAnimated:YES afterDelay:1.0];
    
}

+(void)showCustomAnimation:(NSString *)msg withImgArry:(NSArray *)imgArry inview:(UIView *)view{
    
    UIImageView *showImageView = [[UIImageView alloc] init];
    showImageView.animationImages = imgArry;
    [showImageView setAnimationRepeatCount:0];
    [showImageView setAnimationDuration:(imgArry.count + 1) * 0.075];
    [showImageView startAnimating];
    [self show:msg inView:view mode:ViProgressModeCustomAnimation customImgView:showImageView];
    

}
@end
