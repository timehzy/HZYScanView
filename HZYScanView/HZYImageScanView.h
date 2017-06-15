//
//  HZYImageScanView.h
//  CMM
//
//  Created by Michael-Nine on 2017/6/14.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HZYImageScanView;
@protocol HZYImageScanViewDelegate <NSObject>
@optional;

/**
 当scanView需要用到外部view的frame用于完成dismiss动画时，该方法会被调用

 @param index 图片的索引
 @return 返回你的图片对应小图view转换到window上的frame
 */
- (CGRect)imageViewFrameAtIndex:(NSUInteger)index forScanView:(HZYImageScanView *)scanView;
- (void)scanView:(HZYImageScanView *)scanView imageDidDelete:(NSInteger)index;
- (void)scanView:(HZYImageScanView *)scanView didEndDismissAnimationWithIndex:(NSUInteger)index;
- (void)scanView:(HZYImageScanView *)scanView willDismissAtIndex:(NSInteger)index;
@end

@interface HZYImageScanView : UIView

/**
 弹出全屏图片浏览视图

 @param imageArray 可以是url也可以是image，也可以二者混合
 @param index 默认展示的是数组的第几个
 @param rect 触发全屏浏览的view在window上的frame
 @param deletable 是否支持删除操作
 @param delegate 代理
 */
+ (void)showWithImages:(NSArray *)imageArray beginIndex:(NSUInteger)index fromRect:(CGRect)rect deletable:(BOOL)deletable delegate:(id<HZYImageScanViewDelegate>)delegate;
@end
