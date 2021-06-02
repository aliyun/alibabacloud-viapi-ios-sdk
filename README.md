# 1 概述
ViapiIosSDK 是阿里达摩院推出的一款适用于 iOS 平台的实时视频 SDK，提供了包括人像抠图、美颜、人像关键点检测等多种功能。

# 2 功能列表
+ 视频流实时人像分割
+  本地图片人像分割
+ ~~美颜功能（瘦脸、大眼、美白、磨皮等）~~
+ ~~人脸关键点检测~~

# 3 SDK开发包适配及包含内容说明
## 3.1 支持的系统和硬件版本
+ 硬件要求：要求设备上有相机模块
+ 系统：最低支持9.0

## 3.2 开发包资源说明
+ ViapiIosSDK——具体版本以获取到的最终版本为准
+ damo-viapi.license ——sdk全局license文件，对所有能力生效，名字固定不允许修改
+ damo-viapi-xxx.license ——sdk单个能力license文件，只对单个能力生效，名字路径可以自定义
+ xxx.nn ——以.nn为结尾的是SDK使用到的模型文件

# 4 SDK集成步骤
## 4.1 将算法能力相关的文件包导入到工程
把sdk的framework，模型文件xxx.nn文件以及damo-viapi.license拷贝到主工程的目录下。如下图：


<img src="https://viapi-test.oss-cn-shanghai.aliyuncs.com/hanbing/ios/viapi-ios-sdk-4.1.png" width = "606" height = "740" />




# 5 SDK调用步骤
## 5.1 分割处理
### 5.1.1视频流实时分割算法处理
#### 接口描述：
```
/// 检查证书路径
/// @param  licensePath 鉴权证书路径 .license 
/// @param  callBack block 
-(void)checkVideoLicensePath:(NSString *)licensePath withCallBack:(void(^)(int errorCode))callBack;
/// 创建分割对象
/// @param  callBack block 
-(void)createVideoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;
/// 初始化分割对象
/// @param  modelPath 模型路径 .nn 
-(void)initVideoSegmentationModelPath:(NSString *)modelPath withCallBack:(void(^)(int errorCode))callBack;
///设置背景融合
/// @param  oriBgImg 原图 
/// @param  w 宽 
/// @param  h 高 
/// @param  rotation 手机朝向 
/// @param  front 是否前置摄像头 
-(BOOL)setBackBufferWithOriginalImg:(UIImage *)oriBgImg mixBufferW:(CGFloat)w mixBufferH:(CGFloat)h rotation:(VISegmentRotation)rotation isFront:(BOOL)front;
/// 视频分割方法
/// @param  pixelBuffer 视频buffer 
/// @param  callBack block 
/// @param  rotation 手机朝向 
/// @param  front 是否前置摄像头 
-(CVPixelBufferRef)segmentationVideoFromBuffer:(CVPixelBufferRef)pixelBuffer rotation:(VISegmentRotation)rotation isFront:(BOOL)front withCallBack:(void(^)(int errorCode))callBack;
/// 摧毁分割对象
/// @param  callBack block 
-(void)destroyVideoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;
/// 获取视频证书过期时间
/// @param  callBack block 
-(void)getVideoLicenseExpirTimeWithCallBack:(void(^)(NSString*expirTime))callBack;
```

#### 具体代码示例如下：
引入头文件
#import <ViapiIosSDK/HuManRealTimeVideoSegmentor.h> 

调用代码如下：
```
let licPath = Bundle.main.path(forResource: "damo-viapi", ofType: "license")
let modelPath = Bundle.main.path(forResource: "segvHuman", ofType:"nn")
segmentator = HuManRealTimeVideoSegmentor()
segmentator?.checkVideoLicensePath(licPath!, withCallBack: { errorCode in
    print("check证书结果:\(errorCode)")
})
self.segmentator?.createVideoSegmentationObject(callBack: { errorCode in
    print("创建对象失败，错误码为\(errorCode)")
});
self.segmentator?.initVideoSegmentationModelPath(modelPath!,withCallBack: { errorCode in
    print("初始化对象失败，错误码为\(errorCode)")
});
self.segmentator?.getVideoLicenseExpirTime(callBack: {expireString in
    print("视频证书过期时间:\(expireString)")
})
segmentator?.setBackBufferWithOriginalImg(backgroundImage!, mixBufferW: self.backgroundImage!.size.width, mixBufferH: self.backgroundImage!.size.height, rotation: getPhoneRotation(), isFront: true);
```
## 注意
离开当前页面，请手动调用-(void)destroyVideoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack 摧毁视频分割对象。
```
dismiss(animated: false) {
    self.segmentator?.destroyVideoSegmentationObject(callBack: { errorCode in
        print("摧毁对象失败,错误码:\(errorCode)")
    })
};

```
### 5.1.2图片分割算法处理
#### 接口描述：
```
/// 检查证书路径
/// @param licensePath 鉴权证书路径 .license
/// @param callBack block
-(void)checkPhotoLicensePath:(NSString *)licensePath withCallBack:(void(^)(int errorCode))callBack;

/// 创建分割对象
/// @param callBack block
-(void)createPhotoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;

/// 初始化分割对象
/// @param modelPath 模型路径 .nn
-(void)initPhotoSegmentationModelPath:(NSString *)modelPath withCallBack:(void(^)(int errorCode))callBack;


/// 处理图片方法
/// @param originalImage 原图
/// @param callBack block
-(void)segmentationPhotoFromOriginalImage:(UIImage*)originalImage withCallBack:(void(^)(UIImage*outImage,int errorCode))callBack;

/// 摧毁分割对象
/// @param callBack block
-(void)destroyPhotoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack;

/// 获取图片证书过期时间
/// @param callBack block
-(void)getPhotoLicenseExpirTimeWithCallBack:(void(^)(NSString*expirTime))callBack;

```

#### 具体代码示例如下：
引入头文件
#import <ViapiIosSDK/HumanPhotoSegmentor.h>

调用代码如下：
```
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
```
## 注意
离开当前页面，请手动调用-(void)destroyPhotoSegmentationObjectWithCallBack:(void(^)(int errorCode))callBack 摧毁图片分割对象。
```
dismiss(animated: false) {
    self.segmentator?.destroyPhotoSegmentationObjectWithCallBack(callBack: { errorCode in
        print("摧毁对象失败,错误码:\(errorCode)")
    })
};

```
## 5.2 返回值
#### 返回值 ：
int类型，返回0为图像分割算法处理成功，其它返回为图像分割算法处理失败。
```
errorCode
UnknowError                               = -1  ,
离线鉴权错误码：
LicenseNotInitError                       = -211 ,
LicenseNotBindBundleIdError               = -212 ,
LicenseInvalidError                       = -213 ,
LicenseExpireError                        = -214 ,
LicenseNotSupport                         = -215 ,
LicenseGetCallBundleIdError               = -216

```
