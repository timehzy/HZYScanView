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
    [HZYImageScanView showWithImages:@[self.image] beginIndex:0 deletable:NO delegate:self];
}
@end
