//
//  PreviewViewController.m
//  DaMoLab
//
//  Created by 薛林 on 2020/10/14.
//  Copyright © 2020 AlibabaGroup. All rights reserved.
//

#import "WriteImageController.h"
//#import "UIImage+ByteProcess.h"
#import <Masonry.h>
@interface WriteImageController ()
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation WriteImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    _queue = dispatch_queue_create("com.cde", DISPATCH_QUEUE_SERIAL);
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.frame];
    label.textAlignment = NSTextAlignmentCenter;
    if (self.inputImages.count == 0) {
        label.text = @"请先进行分割操作";
    } else {
        label.text = @"图像数据写入中...";
    }
    label.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:label];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  //  indicatorView.frame = CGRectMake((self.view.frame.size.width - 30) * 0.5, (self.view.frame.size.height - 120) * 0.5, 30, 30);
    [self.view addSubview:indicatorView];
    [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo((self.view.frame.size.width - 30) * 0.5);
        make.top.mas_equalTo((self.view.frame.size.height - 120) * 0.5);
        make.width.height.mas_equalTo(30);
    }];
    [indicatorView startAnimating];
    
    dispatch_async(self.queue, ^{
        for(int i = 0; i < self.inputImages.count; i++) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"写入第%d帧...", i]];
//            });
//            UIImage *inputImage = self.inputImages[i];
//            [inputImage writeImageToTxt:inputImage index:i];
//            
//            UIImage *outputImage = self.outputImages[i];
//            CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
//            unsigned char *bytes = [outputImage bytesFromImage];
//            [UIImage writeBytesToTxt:bytes size:outputImage.size index:i tag:@"output"];
//            CFAbsoluteTime link = CFAbsoluteTimeGetCurrent() - start;
//            NSLog(@"😝用时：%f", link);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            label.text = @"写入完成";
            [indicatorView stopAnimating];
        });
    });
}

@end
