# HZYScanView
图片全屏浏览，支持单张或多张图片，动画和交互效果完美

很多app都有全屏查看图片的需求，这个看似简单的功能却很少有app做得完善。我个人使用过的只有苹果原生的照片app，twitter和facebook令我满意。于是趁着最近公司项目需要做这个功能，撸了一个轮子，交互和动画都是高仿照片app，并且使用很简单。

我提供了一个UIImageVIew的分类，如果仅仅只要一个imageView的图片可以被全屏查看，那么只要入头文件说明，在imageView初始化的时候调用即可

```objective-c
@interface UIImageView (HZYImageScanView)
/// 初始化imageView时调用此方法使该view支持大图浏览
- (void)enableScan;
@end
```

如果像类似微博、微信朋友圈那种连续多张图片的情况，则需要使用HZYImageScanView的类方法

```objective-c
+ (void)showWithImages:(NSArray *)imageArray beginIndex:(NSUInteger)index deletable:(BOOL)deletable delegate:(id<HZYImageScanViewDelegate>)delegate;

```

如果区分缩略图和大图，则使用可以传入缩略图数组的类方法

```objective-c
+ (void)showWithImages:(NSArray *)imageArray thumbs:(NSArray *)thumbsArray beginIndex:(NSUInteger)index deletable:(BOOL)deletable delegate:(id<HZYImageScanViewDelegate>)delegate;
```

然后实现两个代理方法即可

```objective-c
/**
当scanView需要用到外部view的frame用于完成dismiss动画时，该方法会被调用

@param index 图片的索引
@return 返回你的图片对应小图view转换到window上的frame
*/
- (CGRect)imageViewFrameAtIndex:(NSUInteger)index forScanView:(HZYImageScanView *)scanView;
- (void)scanView:(HZYImageScanView *)scanView imageDidDelete:(NSInteger)index;
```

我做了几乎能想到的所有事情，如果发现bug或者有改进意见和建议，欢迎回复或去github提issue，谢谢。
