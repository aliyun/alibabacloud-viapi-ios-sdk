//
//  UIImage+Compression.h
//  ViapiiOSSDKDemo
//
//  Created by wclin on 2021/5/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Compression)
- (UIImage *)compressToImage;
- (NSData *)returnCompressSize;
@end

NS_ASSUME_NONNULL_END
