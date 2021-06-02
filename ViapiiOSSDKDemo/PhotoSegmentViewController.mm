//
//  PhotoSegmentViewController.m
//  SegmentDemo
//
//  Created by fcq on 2021/5/12.
//

#import "PhotoSegmentViewController.h"
#import <ViapiIosSDK/HumanPhotoSegmentor.h>
#import <TZImagePickerController.h>

#define kwidth     self.view.frame.size.width
#define kheight   self.view.frame.size.height


@interface PhotoSegmentViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong)UIButton *selectBtn;
@property (nonatomic, strong)UIButton *segmentBtn;
@property (nonatomic, strong)UIImageView *selectImageView;
@property (nonatomic, strong)UIImageView *segmentImageView;
@property (nonatomic, strong)UIButton *closeBtn;
@property (nonatomic, strong)UIImagePickerController *imagePickerController;
@property(nonatomic,strong)HumanPhotoSegmentor*photoSegmentor;
@property(nonatomic,strong)UIImage*selectImage;
@end

@implementation PhotoSegmentViewController
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.photoSegmentor destroyPhotoSegmentationObjectWithCallBack:^(int errorCode) {
        NSLog(@"摧毁失败：%d",errorCode);
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    [self setUI];
    [self initSegmentation];
    
    
}
-(void)initSegmentation{
    self.photoSegmentor = [[HumanPhotoSegmentor alloc]init];
    NSString *licensePath= [[NSBundle mainBundle] pathForResource:@"damo-viapi.license" ofType:nil];
    NSString *nnModelPath= [[NSBundle mainBundle]resourcePath];
    NSLog(@"licensePath:%@\n bundleID:%@",licensePath,[NSBundle mainBundle].bundleIdentifier);
    [self.photoSegmentor checkPhotoLicensePath:licensePath withCallBack:^(int errorCode) {
        NSLog(@"check证书结果:%d",errorCode);
    }];
    [self.photoSegmentor createPhotoSegmentationObjectWithCallBack:^(int errorCode) {
        NSLog(@"创建对象失败，错误码为%d",errorCode);
    }];
    [self.photoSegmentor initPhotoSegmentationModelPath:nnModelPath withCallBack:^(int errorCode) {
        NSLog(@"初始化对象失败，错误码为%d",errorCode);
    }];
    [self.photoSegmentor getPhotoLicenseExpirTimeWithCallBack:^(NSString * _Nonnull expirTime) {
        NSLog(@"照片证书过期时间:%@",expirTime);
    }];
}
- (void)setUI{
    [self.view addSubview:self.selectImageView];
    [self.view addSubview:self.segmentImageView];
    [self.view addSubview:self.segmentBtn];
    [self.view addSubview:self.selectBtn];
    [self.view addSubview:self.segmentBtn];
    [self.view addSubview:self.closeBtn];
    
}
// 从相册中选择
- (void)selectPhotoLibrary{
    TZImagePickerController* imagePickerVc = [[TZImagePickerController alloc]init];
    imagePickerVc.allowPickingImage = true;
    imagePickerVc.allowPickingVideo = false;
    imagePickerVc.allowTakeVideo = false;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        UIImage*image = photos.firstObject;
        self.selectImageView.image =image;
        self.selectImage = image;
    }];
    
}

#pragma mark----------action----------
- (void)selectBtnAction{
    [self selectPhotoLibrary];
}

- (void)segmentBtnAction
{
    [self.photoSegmentor segmentationPhotoFromOriginalImage:self.selectImageView.image withCallBack:^(UIImage * _Nonnull outImage, int errorCode) {
        self.segmentImageView.image = outImage;
        NSLog(@"%d",errorCode);
    }];
    
}
- (void)closeAction{
    [self dismissViewControllerAnimated:NO completion:^{

    }];
}
- (UIButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setTitle:@"选择图片" forState:UIControlStateNormal];
        [_selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _selectBtn.backgroundColor =[UIColor lightGrayColor];
        _selectBtn.layer.cornerRadius =5;
        _selectBtn.layer.masksToBounds =YES;
        _selectBtn.frame =CGRectMake(10, self.view.frame.size.height-80, 160, 45);
        [_selectBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}
- (UIButton *)segmentBtn{
    if (!_segmentBtn) {
        _segmentBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [_segmentBtn setTitle:@"抠图" forState:UIControlStateNormal];
        [_segmentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _segmentBtn.backgroundColor =[UIColor lightGrayColor];
        _segmentBtn.layer.cornerRadius =5;
        _segmentBtn.layer.masksToBounds =YES;
        _segmentBtn.frame =CGRectMake(self.view.frame.size.width-170, self.view.frame.size.height-80, 160, 45);
        [_segmentBtn addTarget:self action:@selector(segmentBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _segmentBtn;
}
- (UIImageView *)selectImageView
{
    if (!_selectImageView) {
        _selectImageView =[[UIImageView alloc]init];
        _selectImageView.frame =CGRectMake(0, 10, kwidth, (kheight-80)/2);
    }
    return _selectImageView;
}
- (UIImageView *)segmentImageView
{
    if (!_segmentImageView) {
        _segmentImageView =[[UIImageView alloc]init];
        _segmentImageView.frame =CGRectMake(0, (kheight-80)/2 +10, kwidth, (kheight-80)/2-10);
    }
    return _segmentImageView;
}
- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        _closeBtn.titleLabel.font =[UIFont systemFontOfSize:16];
        _closeBtn.backgroundColor = UIColor.orangeColor;
        _closeBtn.layer.cornerRadius = 5;
        [_closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.frame =CGRectMake(15, 44, 60, 30);
    }
    return _closeBtn;
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
