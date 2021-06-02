//
//  AppDelegate.h
//  ViapiiOSSDKDemo
//
//  Created by fcq on 2021/5/18.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic,assign)BOOL isForceLandscape;
@property(nonatomic,assign)BOOL isForcePortrait;
@property(nonatomic,assign)BOOL isForceAllDerictions;//支持所有方向
@property(nonatomic,strong)UIWindow*window;

@end

