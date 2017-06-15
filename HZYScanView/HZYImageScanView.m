//
//  HZYImageScanView.m
//  CMM
//
//  Created by Michael-Nine on 2017/6/14.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import "HZYImageScanView.h"
#import "UIImageView+WebCache.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface HZYImageScanView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, assign) CGRect fromRect;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, assign) NSUInteger beginIndex;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *navigationBar;
@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIView *animateContainerView;
@property (nonatomic, assign) CGRect animateBeginFrame;
@property (nonatomic, weak) id<HZYImageScanViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *deleteIndexArray;
@property (nonatomic, assign) BOOL deletable;
@end

@interface hzy_CollectionViewCell : UICollectionViewCell<UIScrollViewDelegate>
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, copy) void(^singleTapHandler)();
@end

@implementation HZYImageScanView
#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame fromRect:(CGRect)rect deletable:(BOOL)deletable {
    if (self = [super initWithFrame:frame]) {
        _fromRect = rect;
        _deletable = deletable;
        [self configUI];
    }
    return self;
}

#pragma mark - Public Method
+ (void)showWithImages:(NSArray *)imageArray beginIndex:(NSUInteger)index fromRect:(CGRect)rect deletable:(BOOL)deletable delegate:(id<HZYImageScanViewDelegate>)delegate {
    HZYImageScanView *scanView = [[HZYImageScanView alloc] initWithFrame:[UIScreen mainScreen].bounds fromRect:rect deletable:deletable];
    scanView.beginIndex = index;
    scanView.imageArray = [imageArray mutableCopy];
    scanView.delegate = delegate;
    [scanView showWithAnimation];
}
    
#pragma mark - Private Method
- (void)configUI {
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    [self configCollectionView];
    [self configNavigationBar];
}
    
- (UIImageView *)imageViewWithIndex:(NSUInteger)index {
    UIImageView *imageView;
    if ([self.imageArray[index] isKindOfClass:[UIImage class]]) {
        imageView = [[UIImageView alloc] initWithImage:self.imageArray[index]];
    }else{
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.fromRect.size.width, self.fromRect.size.height)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[index]]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (cacheType == SDImageCacheTypeNone) {
                CGFloat height;
                CGFloat width;
                if (imageView.bounds.size.width / imageView.bounds.size.height > kScreenWidth / kScreenHeight) {
                    //宽超出，将宽缩放到屏幕宽度，高度自适应
                    width = kScreenWidth;
                    height = kScreenWidth / imageView.bounds.size.width * imageView.bounds.size.height;
                }else{
                    height = kScreenHeight;
                    width = kScreenHeight / imageView.bounds.size.height * imageView.bounds.size.width;
                }
                imageView.frame = CGRectMake(0, (kScreenHeight - height) / 2, width, height);
            }else{
                imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            }
        }];
    }
    return imageView;
}

- (void)showWithAnimation {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.beginIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    UIImageView *imageView = [self imageViewWithIndex:self.beginIndex];

    CGFloat height;
    CGFloat width;
    if (imageView.bounds.size.width > imageView.bounds.size.height) {
        height = self.fromRect.size.height;
        width = height / imageView.bounds.size.height * imageView.bounds.size.width;
    }else {
        width = self.fromRect.size.width;
        height = width / imageView.bounds.size.width * imageView.bounds.size.height;
    }
    imageView.frame = CGRectMake((self.animateContainerView.frame.size.width - width) / 2, (self.animateContainerView.frame.size.height - height) / 2, width, height);
    self.animateBeginFrame = imageView.frame;
    [self.animateContainerView addSubview:imageView];
    
    if (imageView.bounds.size.width / imageView.bounds.size.height > kScreenWidth / kScreenHeight) {
        //宽超出，将宽缩放到屏幕宽度，高度自适应
        height = kScreenWidth / width * height;
        width = kScreenWidth;
    }else{
        width = kScreenHeight / height * width;
        height = kScreenHeight;
    }
    
    [UIView animateWithDuration:.25 animations:^{
        self.animateContainerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        imageView.frame = CGRectMake(0, (kScreenHeight - height) / 2, width, height);
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
    } completion:^(BOOL finished) {
        self.collectionView.hidden = NO;
        self.animateContainerView.hidden = YES;
        [imageView removeFromSuperview];
        [self switchNavigationBar];
    }];
}

- (void)switchNavigationBar {
    [UIView animateWithDuration:.25 animations:^{
        if (self.navigationBarHidden) {
            self.navigationBar.transform = CGAffineTransformIdentity;
        }else{
            self.navigationBar.transform = CGAffineTransformMakeTranslation(0, 68);
        }
    }];
    self.navigationBarHidden = !self.navigationBarHidden;
}
    
- (void)switchBackgroundColor {
    [UIView animateWithDuration:.25 animations:^{
        if ([self.backgroundColor isEqual:[UIColor blackColor]]) {
            self.backgroundColor = [UIColor whiteColor];
        }else{
            self.backgroundColor = [UIColor blackColor];
        }
    }];
}

- (void)showAnimateContainerView {
    CGFloat height;
    CGFloat width;
    NSIndexPath *curIndex = [self.collectionView indexPathsForVisibleItems].firstObject;
    self.animateContainerView.hidden = NO;
    self.collectionView.hidden = YES;
    UIImageView *imageView = [self imageViewWithIndex:curIndex.item];
    if (imageView.bounds.size.width / imageView.bounds.size.height > kScreenWidth / kScreenHeight) {
        //宽超出，将宽缩放到屏幕宽度，高度自适应
        width = kScreenWidth;
        height = kScreenWidth / imageView.bounds.size.width * imageView.bounds.size.height;
    }else{
        height = kScreenHeight;
        width = kScreenHeight / imageView.bounds.size.height * imageView.bounds.size.width;
    }
    imageView.frame = CGRectMake(0, (kScreenHeight - height) / 2, width, height);
    [self.animateContainerView addSubview:imageView];
    if ([self.delegate respondsToSelector:@selector(scanView:willDismissAtIndex:)]) {
        [self.delegate scanView:self willDismissAtIndex:curIndex.item];
    }
}

- (void)dismissWithAnimation {
    CGFloat height;
    CGFloat width;
    NSIndexPath *curIndex = [self.collectionView indexPathsForVisibleItems].firstObject;
    UIImageView *imageView = self.animateContainerView.subviews.firstObject;
    if ([self.delegate respondsToSelector:@selector(imageViewFrameAtIndex:forScanView:)]) {
        self.fromRect = [self.delegate imageViewFrameAtIndex:curIndex.item forScanView:self];
    }
    if (imageView.bounds.size.width > imageView.bounds.size.height) {
        height = self.fromRect.size.height;
        width = height / imageView.bounds.size.height * imageView.bounds.size.width;
    }else {
        width = self.fromRect.size.width;
        height = width / imageView.bounds.size.width * imageView.bounds.size.height;
    }
    if (self.navigationBarHidden) {
        [self switchNavigationBar];
    }
    [UIView animateWithDuration:0.25 animations:^{
        imageView.frame = CGRectMake((self.fromRect.size.width - width) / 2, (self.fromRect.size.height - height) / 2, width, height);
        self.animateContainerView.transform = CGAffineTransformIdentity;
        self.animateContainerView.frame = self.fromRect;
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(scanView:didEndDismissAnimationWithIndex:)]) {
            [self.delegate scanView:self didEndDismissAnimationWithIndex:curIndex.item];
        }
        [self removeFromSuperview];
    }];
 //   if ([self.delegate respondsToSelector:@selector(scanView:scanDidCompleteWithDelete:)]) {
   //     [self.delegate scanView:self scanDidCompleteWithDelete:self.deleteIndexArray];
    //}
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = self.bounds.size;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
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
    UIView *naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, -68, self.bounds.size.width, 64)];
    naviBar.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    naviBar.layer.shadowOpacity = .3;
    naviBar.layer.shadowOffset = CGSizeMake(0, 2);
    naviBar.layer.shadowRadius = 2;
    naviBar.backgroundColor = [UIColor whiteColor];
    [self addSubview:naviBar];
    self.navigationBar = naviBar;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width - 100) / 2, 20, 100, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [naviBar addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    if (_deletable) {
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 44, 20, 44, 44)];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
        [naviBar addSubview:deleteBtn];
    }
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backBtn setImage:[UIImage imageNamed:@"navgationBackImg"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnTouched) forControlEvents:UIControlEventTouchUpInside];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
    [naviBar addSubview:backBtn];
    
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)]];
}
    
#pragma mark - Action
- (void)deleteImage {
    NSIndexPath *curIndex = [self.collectionView indexPathsForVisibleItems].firstObject;
    [self.imageArray removeObjectAtIndex:curIndex.item];
    [self.deleteIndexArray addObject:[NSNumber numberWithInteger:curIndex.item]];
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
        self.titleLabel.text = [NSString stringWithFormat:@"%zd/%zd", index, self.imageArray.count];
    }
}
    
- (void)backBtnTouched {
    [self showAnimateContainerView];
    [self dismissWithAnimation];
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture translationInView:self.animateContainerView];
    CGPoint movedPoint = CGPointMake(self.animateContainerView.center.x+point.x, self.animateContainerView.center.y + point.y);
    CGFloat change = fabs(movedPoint.y - self.bounds.size.height / 2);//图片到屏幕中间的距离
    CGFloat scale = (self.bounds.size.height - change) / [UIScreen mainScreen].bounds.size.height;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self showAnimateContainerView];
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        self.animateContainerView.center = movedPoint;
        self.animateContainerView.transform = CGAffineTransformMakeScale(scale, scale);
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:scale];
        [gesture setTranslation:CGPointZero inView:self];
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"%@", NSStringFromCGPoint([gesture velocityInView:self]));
        if (scale < .8 || [gesture velocityInView:self].y > 150) {
            [self dismissWithAnimation];
        }else{
            [self resumeDismissPanAnimation];
        }
    }
}

- (void)resumeDismissPanAnimation {
    [UIView animateWithDuration:.25 animations:^{
        self.animateContainerView.center = self.center;
        self.animateContainerView.transform = CGAffineTransformIdentity;
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
    } completion:^(BOOL finished) {
        self.animateContainerView.hidden = YES;
        self.collectionView.hidden = NO;
        [self.animateContainerView.subviews.firstObject removeFromSuperview];
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
        cell.url = self.imageArray[indexPath.item];
    }
    __weak typeof(self)weakSelf = self;
    cell.singleTapHandler = ^{
        [weakSelf switchNavigationBar];
        [weakSelf switchBackgroundColor];
    };
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.titleLabel.text = [NSString stringWithFormat:@"%zd/%zd", [self.collectionView indexPathsForVisibleItems].firstObject.item + 1, self.imageArray.count];
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
    self.titleLabel.text = [NSString stringWithFormat:@"%zd/%zd", self.beginIndex + 1, imageArray.count];
    [self.collectionView reloadData];
}

- (NSMutableArray *)deleteIndexArray {
    if (!_deleteIndexArray) {
        _deleteIndexArray = [NSMutableArray array];
    }
    return _deleteIndexArray;
}

- (UIView *)animateContainerView {
    if (!_animateContainerView) {
        UIView *containerView = [[UIView alloc] initWithFrame:self.fromRect];
        containerView.clipsToBounds = YES;
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        _animateContainerView = containerView;
    }
    return _animateContainerView;
}
@end

@implementation hzy_CollectionViewCell{
    UIImageView *_imageView;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    scrollView.zoomScale = 2;
    scrollView.maximumZoomScale = 2;
    scrollView.delegate = self;
    [self.contentView addSubview:scrollView];
    _imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:_imageView];
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
}

#pragma mark - getter & setter
- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}
    
- (void)setUrl:(NSString *)url {
    [_imageView sd_setImageWithURL:[NSURL URLWithString:url]];
}

- (UIImage *)image {
    return _imageView.image;
}
@end
