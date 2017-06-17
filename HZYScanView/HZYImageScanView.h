//
//  HZYImageScanView.h
//  CMM
//
//  Created by Michael-Nine on 2017/6/14.
//  Copyright © 2017年 郝振壹. All rights reserved.
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
@end

@interface HZYImageScanView : UIView

/**
 弹出全屏图片浏览视图，无缩略图和大图之分的情况下使用

 @param imageArray 可以是url也可以是image，也可以二者混合
 @param index 首次展示的是第几张图片
 @param deletable 是否支持删除操作（导航栏显示删除按钮）
 @param delegate 代理
 */
+ (void)showWithImages:(NSArray *)imageArray beginIndex:(NSUInteger)index deletable:(BOOL)deletable delegate:(id<HZYImageScanViewDelegate>)delegate;

/// 接受缩略图数组参数，可以传入url或image
+ (void)showWithImages:(NSArray *)imageArray thumbs:(NSArray *)thumbsArray beginIndex:(NSUInteger)index deletable:(BOOL)deletable delegate:(id<HZYImageScanViewDelegate>)delegate;

/// 详细设置模式
+ (instancetype)scanViewWithImageArray:(NSArray *)imageArray;
@property (nonatomic, weak) id<HZYImageScanViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger beginIndex;
/// 触发全屏浏览的imageView的周边的背景色
@property (nonatomic, strong) UIColor *fromBackgroundColor;
/// 导航栏是否显示删除按钮
@property (nonatomic, assign) BOOL deletable;
/// 是否显示导航栏
@property (nonatomic, assign) BOOL enableNavigationBar;
/// 点按退出，默认NO
@property (nonatomic, assign) BOOL tapToDismiss;

- (void)showWithAnimation;
@end
