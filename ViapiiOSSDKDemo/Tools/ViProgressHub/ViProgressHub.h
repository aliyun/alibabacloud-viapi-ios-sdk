//
//  ViProgressHub.h
//  ViapiiOSSDKDemo
//
//  Created by wclin on 2021/5/24.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ViProgressMode){
    ViProgressModeOnlyText,           //文字
    ViProgressModeLoading,               //加载菊花
    ViProgressModeCircle,                //加载环形
    ViProgressModeCircleLoading,         //加载圆形-要处理进度值
    ViProgressModeCustomAnimation,       //自定义加载动画（序列帧实现）
    ViProgressModeSuccess,                //成功
    ViProgressModeCustomerImage           //自定义图片
    
};
@interface ViProgressHub : NSObject
/*===============================   属性   ================================================*/

@property (nonatomic,strong) MBProgressHUD  *hud;


/*=============================  本类自己调用 方法   =====================================*/

+(instancetype)shareInstance;

//显示
+(void)show:(NSString *)msg inView:(UIView *)view mode:(ViProgressMode )myMode;


/*=========================  自己可调用 方法   ================================*/

//显示提示（1秒后消失）
+(void)showMessage:(NSString *)msg inView:(UIView *)view;

//显示提示（N秒后消失）
+(void)showMessage:(NSString *)msg inView:(UIView *)view afterDelayTime:(NSInteger)delay;

//在最上层显示 - 不需要指定showview
+(void)showMsgWithoutView:(NSString *)msg;


///显示进度(菊花)
+(void)showProgress:(NSString *)msg inView:(UIView *)view;

///显示进度(环形)
+(void)showProgressCircleNoValue:(NSString *)msg inView:(UIView *)view ;

///显示进度(转圈-要处理数据加载进度)
+(MBProgressHUD *)showProgressCircle:(NSString *)msg inView:(UIView *)view;

///显示成功提示
+(void)showSuccess:(NSString *)msg inview:(UIView *)view;

///显示提示、带静态图片，比如失败，用失败图片即可，警告用警告图片等
+(void)showMsgWithImage:(NSString *)msg imageName:(NSString *)imageName inview:(UIView *)view;

///显示自定义动画(自定义动画序列帧  找UI做就可以了)
+(void)showCustomAnimation:(NSString *)msg withImgArry:(NSArray *)imgArry inview:(UIView *)view;

///隐藏
+(void)hide;

@end

NS_ASSUME_NONNULL_END
