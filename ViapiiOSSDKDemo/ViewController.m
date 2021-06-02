//
//  ViewController.m
//  ViapiiOSSDKDemo
//
//  Created by fcq on 2021/5/18.
//

#import "ViewController.h"

#import "ViapiiOSSDKDemo-Swift.h"

#import "PhotoSegmentViewController.h"
#import "LocalVideoSegmentViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    // Do any additional setup after loading the view.
}
- (void)setUI{
    self.view.backgroundColor =[UIColor whiteColor];
    UIImageView *BGimage =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_banner_2"]];
    BGimage.frame =CGRectMake(0, 0, kwidth, 200);
    [self.view addSubview:BGimage];
    
    UIView *line =[[UIView alloc]initWithFrame:CGRectMake(0, 210, kwidth, 2)];
    line.backgroundColor =[UIColor redColor];
    [self.view addSubview:line];
    
    NSArray *titleArr =@[@"视频分割",@"本地视频分割",@"图像分割",@"美颜",@"人脸关键点",@"人体关键点"];
    
    int columnCount=4;
    CGFloat btnW=90.0;
    CGFloat btnH=120.0;
    //计算间隙
    CGFloat btnMargin=(kwidth-columnCount*btnW)/(columnCount+1);
    
    for (int i=0; i <titleArr.count; i ++) {
        UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
        int colX=i%columnCount;
        int rowY=i/columnCount;
        //计算坐标
        CGFloat btnX=btnMargin+colX*(btnW +btnMargin);
        CGFloat btnY=220+rowY*(btnH -btnMargin);
        
        btn.frame =CGRectMake(btnX, btnY, btnW, btnH);
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font =[UIFont systemFontOfSize:14];
        [btn setImage:[UIImage imageNamed:@"ic_human_segment"] forState:UIControlStateNormal];
        CGSize imageSize = btn.imageView.frame.size;
        CGSize titleSize = btn.titleLabel.frame.size;
        btn.tag =100+i;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.height, -imageSize.width, 0);
        btn.imageEdgeInsets = UIEdgeInsetsMake(-titleSize.height, 0, 0, -titleSize.width);
        
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
}
- (void)btnAction:(UIButton *)sender{
    
    if(sender.tag ==100){
        
        SegmentationViewController *photovc = [[SegmentationViewController alloc]init];
        photovc.modalPresentationStyle =     UIModalPresentationFullScreen;
        [self presentViewController:photovc animated:NO completion:nil];

    }else if(sender.tag ==101){
        
        LocalVideoSegmentViewController *photovc = [[LocalVideoSegmentViewController alloc]init];
        photovc.modalPresentationStyle =     UIModalPresentationFullScreen;
        [self presentViewController:photovc animated:NO completion:nil];
    }else if(sender.tag ==102){
        
        PhotoSegmentViewController *photovc = [[PhotoSegmentViewController alloc]init];
        photovc.modalPresentationStyle =     UIModalPresentationFullScreen;
        [self presentViewController:photovc animated:NO completion:^{
            
        }];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂不支持" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:sure];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
}


@end
