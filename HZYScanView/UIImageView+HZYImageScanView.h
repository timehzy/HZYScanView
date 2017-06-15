//
//  UIImageView+HZYImageScanView.h
//  CMM
//
//  Created by Michael-Nine on 2017/6/14.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (HZYImageScanView)
/// 初始化imageView时调用此方法使该view支持大图浏览
- (void)enableScan;
@end
