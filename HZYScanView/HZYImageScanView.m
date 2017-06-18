//
//  HZYImageScanView.m
//  CMM
//
//  Created by Michael-Nine on 2017/6/14.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import "HZYImageScanView.h"
#import "UIImageView+WebCache.h"
#import "HZYImageScanViewNavigationBar.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

@interface HZYImageScanView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *thumbArray;
@property (nonatomic, readonly) CGRect fromRect;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) HZYImageScanViewNavigationBar *navigationBar;
@property (nonatomic, weak) UIView *animateContainerView;
@property (nonatomic, weak) UIView *originMaskView;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) BOOL canDragToDismss;
@property (nonatomic, assign) BOOL panning;
@end

@interface hzy_CollectionViewCell : UICollectionViewCell<UIScrollViewDelegate>
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) NSString *thumbUrl;
@property (nonatomic, copy) void(^singleTapHandler)();
@end

@implementation HZYImageScanView
#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame deletable:(BOOL)deletable {
    if (self = [super initWithFrame:frame]) {
        _deletable = deletable;
        _enableNavigationBar = YES;
        _canDragToDismss = YES;
        [self configUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayout:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    
    return self;
}

#pragma mark - notification
- (void)relayout:(NSNotification *)noty {
    NSInteger orient = [noty.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    self.backgroundView.frame = self.bounds;
    self.animateContainerView.frame = self.bounds;
    CGRect frame = self.navigationBar.frame;
    frame.size.width = self.bounds.size.width;
    if (orient == 1) {
        // 水平方向
        frame.size.height -= 20;
    }else{
        frame.size.height += 20;
    }
    self.navigationBar.frame = frame;
    
    CGRect collectionViewFrame = self.bounds;
    collectionViewFrame.size.width += 16;
    NSInteger index = self.currentIndex;
    self.collectionView.frame = collectionViewFrame;
    ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize = collectionViewFrame.size;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - Public Method
+ (void)showWithImages:(NSArray *)imageArray beginIndex:(NSUInteger)index deletable:(BOOL)deletable delegate:(id<HZYImageScanViewDelegate>)delegate {
    HZYImageScanView *scanView = [[HZYImageScanView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds deletable:deletable];
    scanView.beginIndex = index;
    scanView.currentIndex = index;
    scanView.imageArray = [imageArray mutableCopy];
    scanView.delegate = delegate;
    [scanView showWithAnimation];
}

+ (void)showWithImages:(NSArray *)imageArray thumbs:(NSArray *)thumbsArray beginIndex:(NSUInteger)index deletable:(BOOL)deletable delegate:(id<HZYImageScanViewDelegate>)delegate {
    HZYImageScanView *scanView = [[HZYImageScanView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds deletable:deletable];
    scanView.beginIndex = index;
    scanView.currentIndex = index;
    scanView.imageArray = [imageArray mutableCopy];
    scanView.thumbArray = [thumbsArray mutableCopy];
    scanView.delegate = delegate;
    [scanView showWithAnimation];
}

+ (instancetype)scanViewWithImageArray:(NSArray *)imageArray {
    HZYImageScanView *scanView = [[HZYImageScanView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds deletable:NO];
    scanView.imageArray = [imageArray mutableCopy];
    return scanView;
}

#pragma mark - Private Method
- (void)configUI {
    [self configBackgroundView];
    [self configCollectionView];
    [self configNavigationBar];
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)]];
}

- (void)showWithAnimation {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.beginIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    UIImageView *imageView = [self imageViewWithIndex:self.beginIndex];
    imageView.frame = [self calculateImageViewSmallFrameForImage:imageView.image];
    [self.animateContainerView addSubview:imageView];
    CGRect fullScreenRect = [self calculateImageViewFullScreenFrameForImage:imageView.image];
    [self addMaskViewForOriginView];
    if (!self.enableNavigationBar) {
        [self switchBackgroundColor];
        self.backgroundView.backgroundColor = [self.backgroundView.backgroundColor colorWithAlphaComponent:0];
    }
    [UIView animateWithDuration:.25 animations:^{
        self.animateContainerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        imageView.frame = fullScreenRect;
        self.backgroundView.backgroundColor = [self.backgroundView.backgroundColor colorWithAlphaComponent:1];
    } completion:^(BOOL finished) {
        self.collectionView.hidden = NO;
        self.animateContainerView.hidden = YES;
        [imageView removeFromSuperview];
        [self switchNavigationBar];
        [self.originMaskView removeFromSuperview];
    }];
}

- (void)dismissWithAnimation {
    UIImageView *imageView = self.animateContainerView.subviews.firstObject;
    if (!self.navigationBar.hidden) {
        [self switchNavigationBar];
    }
    CGRect smallFrame = [self calculateImageViewSmallFrameForImage:imageView.image];
    [UIView animateWithDuration:0.25 animations:^{
        imageView.frame = smallFrame;
        self.animateContainerView.transform = CGAffineTransformIdentity;
        self.animateContainerView.frame = self.fromRect;
        self.backgroundView.backgroundColor = [self.backgroundView.backgroundColor colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)switchNavigationBar {
    if (self.navigationBar.isHidden) {
        self.navigationBar.hidden = !self.navigationBar.hidden;
        [UIView animateWithDuration:.25 animations:^{
            self.navigationBar.transform = CGAffineTransformMakeTranslation(0, 68);
        }];
    }else{
        [UIView animateWithDuration:.25 animations:^{
            self.navigationBar.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.navigationBar.hidden = !self.navigationBar.hidden;
        }];
    }
}
    
- (void)switchBackgroundColor {
    [UIView animateWithDuration:.25 animations:^{
        if ([self.backgroundView.backgroundColor isEqual:[UIColor blackColor]]) {
            self.backgroundView.backgroundColor = [UIColor whiteColor];
        }else{
            self.backgroundView.backgroundColor = [UIColor blackColor];
        }
    }];
}

- (void)showAnimateContainerView {
    [self showImageViewForAnimation];
    [self addMaskViewForOriginView];
}

- (void)addMaskViewForOriginView {
    UIView *view = [[UIView alloc] initWithFrame:self.fromRect];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    [self sendSubviewToBack:view];
    self.originMaskView = view;
}

- (void)showImageViewForAnimation {
    self.animateContainerView.hidden = NO;
    self.collectionView.hidden = YES;
    NSIndexPath *curIndex = [self.collectionView indexPathsForVisibleItems].firstObject;
    UIImageView *imageView = [self imageViewWithIndex:curIndex.item];
    imageView.frame = [self calculateImageViewFullScreenFrameForImage:imageView.image];
    [self.animateContainerView addSubview:imageView];
}

- (UIImageView *)imageViewWithIndex:(NSUInteger)index {
    UIImageView *imageView;
    if (self.thumbArray.count > 0) {
        if ([self.thumbArray[index] isKindOfClass:[UIImage class]]) {
            imageView = [[UIImageView alloc] initWithImage:self.thumbArray[index]];
        }else{
            imageView = [UIImageView new];
            [imageView sd_setImageWithURL:self.thumbArray[index] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                imageView.frame = [self calculateImageViewSmallFrameForImage:image];
            }];
        }
    }else{
        if ([self.imageArray[index] isKindOfClass:[UIImage class]]) {
            imageView = [[UIImageView alloc] initWithImage:self.imageArray[index]];
        }else{
            UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:self.imageArray[index]];
            if (!image) {
                image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:self.imageArray[index]];
            }
            imageView = [UIImageView new];
        }
    }
    return imageView;
}

- (CGRect)calculateImageViewFullScreenFrameForImage:(UIImage *)image {
    if (!image) {
        return CGRectZero;
    }
    CGFloat height;
    CGFloat width;
    CGSize size = image.size;
    if (size.width / size.height > kScreenWidth / kScreenHeight) {
        //宽超出，将宽缩放到屏幕宽度，高度自适应
        width = kScreenWidth;
        height = kScreenWidth / size.width * size.height;
    }else{
        height = kScreenHeight;
        width = kScreenHeight / size.height * size.width;
    }
    return CGRectMake((kScreenWidth - width) / 2, (kScreenHeight - height) / 2, width, height);
}

- (CGRect)calculateImageViewSmallFrameForImage:(UIImage *)image {
    if (!image) {
        return CGRectZero;
    }
    CGFloat height;
    CGFloat width;
    CGSize size = image.size;
    if (size.width > size.height) {
        height = self.fromRect.size.height;
        width = height / size.height * size.width;
    }else {
        width = self.fromRect.size.width;
        height = width / size.width * size.height;
    }
    return CGRectMake((self.fromRect.size.width - width) / 2, (self.fromRect.size.height - height) / 2, width, height);
}

- (void)configCollectionView {
    CGRect itemFrame = self.bounds;
    itemFrame.size.width += 16;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = itemFrame.size;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:itemFrame collectionViewLayout:layout];
    collectionView.bounces = NO;
    collectionView.pagingEnabled = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.hidden = YES;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[hzy_CollectionViewCell class] forCellWithReuseIdentifier:@"scan"];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)configNavigationBar {
    HZYImageScanViewNavigationBarOrientation orient;
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
        [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        orient = HZYImageScanViewNavigationHorizontal;
    }else{
        orient = HZYImageScanViewNavigationVertical;
    }
    HZYImageScanViewNavigationBar *navi = [HZYImageScanViewNavigationBar navigationBarForOrigentation:orient];
    __weak typeof(self)weakSelf = self;
    navi.deleteBtnAction = ^{
        [weakSelf deleteImage];
    };
    navi.backBtnAction = ^{
        [weakSelf backBtnTouched];
    };
    [self addSubview:navi];
    self.navigationBar = navi;
}

- (void)configBackgroundView {
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    [self addSubview:view];
    self.backgroundView = view;
}

#pragma mark - Action
- (void)deleteImage {
    NSIndexPath *curIndex = [self.collectionView indexPathsForVisibleItems].firstObject;
    [self.imageArray removeObjectAtIndex:curIndex.item];
    if ([self.delegate respondsToSelector:@selector(scanView:imageDidDelete:)]) {
        [self.delegate scanView:self imageDidDelete:curIndex.item];
    }
    if (self.imageArray.count == 0) {
        [self removeFromSuperview];
    }else{
        [self.collectionView reloadData];
        NSInteger index;
        if (curIndex.item == self.imageArray.count) {
            index = self.imageArray.count;
        }else{
            index = curIndex.item + 1;
        }
        self.navigationBar.title = [NSString stringWithFormat:@"%zd/%zd", index, self.imageArray.count];
    }
}
    
- (void)backBtnTouched {
    [self showAnimateContainerView];
    [self dismissWithAnimation];
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    if (!self.canDragToDismss) {
        return;
    }
    self.panning = YES;
    CGPoint point = [gesture translationInView:self.animateContainerView];
    CGPoint movedPoint = CGPointMake(self.animateContainerView.center.x+point.x / 2, self.animateContainerView.center.y + point.y / 2);
    CGFloat change = fabs(movedPoint.y - self.bounds.size.height / 2);//图片到屏幕中间的距离
    CGFloat scale = (self.bounds.size.height - change) / [UIApplication sharedApplication].keyWindow.bounds.size.height;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self showAnimateContainerView];
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        self.animateContainerView.center = movedPoint;
        self.animateContainerView.transform = CGAffineTransformMakeScale(scale, scale);
        self.backgroundView.backgroundColor = [self.backgroundView.backgroundColor colorWithAlphaComponent:scale];
        [gesture setTranslation:CGPointZero inView:self];
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (scale < .8 || [gesture velocityInView:self].y > 150) {
            [self dismissWithAnimation];
        }else{
            [self resumeDismissPanAnimation];
        }
        self.panning = NO;
    }
}

- (void)resumeDismissPanAnimation {
    [UIView animateWithDuration:.25 animations:^{
        self.animateContainerView.center = self.center;
        self.animateContainerView.transform = CGAffineTransformIdentity;
        self.backgroundView.backgroundColor = [self.backgroundView.backgroundColor colorWithAlphaComponent:1];
    } completion:^(BOOL finished) {
        self.animateContainerView.hidden = YES;
        self.collectionView.hidden = NO;
        [self.animateContainerView.subviews.firstObject removeFromSuperview];
        [self.originMaskView removeFromSuperview];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    hzy_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"scan" forIndexPath:indexPath];
    if ([self.imageArray[indexPath.item] isKindOfClass:[UIImage class]]) {
        cell.image = self.imageArray[indexPath.item];
    }else{
        if (self.thumbArray.count > 0) {
            if ([self.thumbArray[indexPath.item] isKindOfClass:[UIImage class]]) {
                cell.thumbImage = self.thumbArray[indexPath.item];
            }else{
                cell.thumbUrl = self.thumbArray[indexPath.item];
            }
        }
        cell.url = self.imageArray[indexPath.item];
    }
    __weak typeof(self)weakSelf = self;
    cell.singleTapHandler = ^{
        if (weakSelf.enableNavigationBar) {
            [weakSelf switchNavigationBar];
            [weakSelf switchBackgroundColor];            
        }
        if (weakSelf.tapToDismiss) {
            [weakSelf backBtnTouched];
        }
    };
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentIndex = scrollView.contentOffset.x / self.bounds.size.width;
    self.navigationBar.title = [NSString stringWithFormat:@"%zd/%zd", self.currentIndex + 1, self.imageArray.count];
}

#pragma mark - Getter & Setter
- (void)setImageArray:(NSMutableArray *)imageArray {
    if (![imageArray isKindOfClass:[NSMutableArray class]]) {
        _imageArray = [imageArray mutableCopy];
    }else{
        _imageArray = imageArray;
    }
    for (NSInteger i=0; i<imageArray.count; i++) {
        id image = imageArray[i];
        if ([image isKindOfClass:[NSURL class]]) {
            imageArray[i] = [(NSURL *)image absoluteString];
        }
        NSAssert([image isKindOfClass:[NSString class]] || [image isKindOfClass:[UIImage class]], @"imageArray must only contain NSURL or NSString or UIImage object");
    }
    self.navigationBar.title = [NSString stringWithFormat:@"%zd/%zd", self.beginIndex + 1, imageArray.count];
    [self.collectionView reloadData];
}

- (UIView *)animateContainerView {
    if (!_animateContainerView) {
        UIView *containerView = [[UIView alloc] initWithFrame:self.fromRect];
        containerView.clipsToBounds = YES;
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        _animateContainerView = containerView;
        [self bringSubviewToFront:self.navigationBar];
    }
    return _animateContainerView;
}

- (UIColor *)fromBackgroundColor {
    if (!_fromBackgroundColor) {
        _fromBackgroundColor = [UIColor whiteColor];
    }
    return _fromBackgroundColor;
}

- (CGRect)fromRect {
    NSUInteger curIndex = self.currentIndex;
    if ([self.delegate respondsToSelector:@selector(imageViewFrameAtIndex:forScanView:)]) {
        return [self.delegate imageViewFrameAtIndex:curIndex forScanView:self];
    }
    return CGRectMake(kScreenWidth / 2, kScreenHeight / 2, 0, 0);
}

- (void)setEnableNavigationBar:(BOOL)enableNavigationBar {
    _enableNavigationBar = enableNavigationBar;
    [self.navigationBar removeFromSuperview];
}
@end

@implementation hzy_CollectionViewCell{
    UIImageView *_imageView;
    UIActivityIndicatorView *_loadIndicator;
    UIScrollView *_scrollView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    _imageView.frame = [self calculateImageViewFullScreenFrameForImage:_imageView.image];
}

- (void)configUI {
    _scrollView = [[UIScrollView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    _scrollView.maximumZoomScale = 2;
    _scrollView.delegate = self;
    _scrollView.contentInset = UIEdgeInsetsZero;
    [self.contentView addSubview:_scrollView];
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)]];
}

#pragma mark - action
- (void)singleTapAction {
    if (self.singleTapHandler) {
        self.singleTapHandler();
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

#pragma mark - getter & setter
- (void)setUrl:(NSString *)url {
    NSURL *imageUrl;
    if ([url isKindOfClass:[NSURL class]]) {
        imageUrl = (NSURL *)url;
    }else{
        imageUrl = [NSURL URLWithString:url];
    }
    
    _loadIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadIndicator.hidesWhenStopped = YES;
    _loadIndicator.center = self.contentView.center;
    [_loadIndicator startAnimating];
    [self.contentView addSubview:_loadIndicator];
    if (self.thumbImage) {
        _imageView.frame = [self calculateImageViewFullScreenFrameForImage:self.thumbImage];
    }
    [_imageView sd_setImageWithURL:imageUrl placeholderImage:self.thumbImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [_loadIndicator stopAnimating];
        _imageView.frame = [self calculateImageViewFullScreenFrameForImage:image];
    }];
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
    _imageView.frame = [self calculateImageViewFullScreenFrameForImage:image];
}

- (void)setThumbUrl:(NSString *)thumbUrl {
    self.thumbImage = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:thumbUrl];
    if (!self.thumbImage) {
        self.thumbImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:thumbUrl];
    }
}

- (CGRect)calculateImageViewFullScreenFrameForImage:(UIImage *)image {
    if (!image) {
        return CGRectZero;
    }
    CGFloat height;
    CGFloat width;
    CGSize size = image.size;
    if (size.width / size.height > kScreenWidth / kScreenHeight) {
        //宽超出，将宽缩放到屏幕宽度，高度自适应
        width = kScreenWidth;
        height = kScreenWidth / size.width * size.height;
    }else{
        height = kScreenHeight;
        width = kScreenHeight / size.height * size.width;
    }
    _scrollView.contentSize = CGSizeMake(width, height);
    return CGRectMake((kScreenWidth - width) / 2, (kScreenHeight - height) / 2, width, height);
}
@end
