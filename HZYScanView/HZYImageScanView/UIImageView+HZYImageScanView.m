//
//  UIImageView+HZYImageScanView.m
//  CMM
//
//  Created by Michael-Nine on 2017/6/14.
//  Copyright © 2017年 chemanman. All rights reserved.
//

#import "UIImageView+HZYImageScanView.h"
#import "HZYImageScanView.h"

@interface UIImageView ()<HZYImageScanViewDelegate>

@end
@implementation UIImageView (HZYImageScanView)
- (void)enableScan {
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showScanView)]];
}
    
- (void)showScanView {
    HZYImageScanView *view = [HZYImageScanView scanViewWithImageArray:@[self.image]];
    view.delegate = self;
    view.enableNavigationBar = NO;
    view.tapToDismiss = YES;
    [view showWithAnimation];
}

- (CGRect)imageViewFrameAtIndex:(NSUInteger)index forScanView:(HZYImageScanView *)scanView {
    return [self.superview convertRect:self.frame toView:[UIApplication sharedApplication].keyWindow];
}
@end
