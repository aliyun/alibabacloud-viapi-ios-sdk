//
//  PreviewViewController.h
//  DaMoLab
//
//  Created by 薛林 on 2020/10/14.
//  Copyright © 2020 AlibabaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 写入图像数据使用的类 将图像数据如 [113, 234, 132, 255] 写入.txt文件中
@interface WriteImageController : UIViewController

@property (nonatomic, strong) NSArray<UIImage *> *inputImages;
@property (nonatomic, strong) NSArray<UIImage *> *outputImages;

@end

NS_ASSUME_NONNULL_END
