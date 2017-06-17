//
//  ViewController.m
//  HZYScanView
//
//  Created by Michael-Nine on 2017/6/15.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import "ViewController.h"
#import "HZYImageScanView.h"
#import "SDWebImageManager.h"

@interface ViewController ()<HZYImageScanViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iamgeView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (nonatomic, copy) NSArray *imageArray;
@property (nonatomic, copy) NSArray *thumArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SDWebImageManager sharedManager].imageCache clearDisk];
    self.imageArray = @[[UIImage imageNamed:@"1"], @"http://www.bz55.com/uploads/allimg/150803/140-150P3150136.jpg", [UIImage imageNamed:@"3"]];
    self.thumArray = @[[UIImage imageNamed:@"1"], @"http://www.bz55.com/uploads/allimg/150803/140-150P3150136.jpg", [UIImage imageNamed:@"3"]];
}

#pragma mark - action
- (IBAction)firstImageTouched:(UITapGestureRecognizer *)sender {
    [self showScanViewForView:sender.view atIndex:0];
}

- (IBAction)secondImageTouched:(UITapGestureRecognizer *)sender {
    [self showScanViewForView:sender.view atIndex:1];
}

- (IBAction)thirdImageTouched:(UITapGestureRecognizer *)sender {
    [self showScanViewForView:sender.view atIndex:2];
}

#pragma mark - HZYImageScanViewDelegate
- (CGRect)imageViewFrameAtIndex:(NSUInteger)index forScanView:(HZYImageScanView *)scanView {
    if (index == 0) {
        return [self.view convertRect:self.iamgeView1.frame toView:[UIApplication sharedApplication].keyWindow];
    }else if (index == 1) {
        return [self.view convertRect:self.imageView2.frame toView:[UIApplication sharedApplication].keyWindow];
    }else{
        return [self.view convertRect:self.imageView3.frame toView:[UIApplication sharedApplication].keyWindow];
    }
}

#pragma mark - private
- (void)showScanViewForView:(UIView *)view atIndex:(NSUInteger)index {
    view.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        view.hidden = NO;
    });
    [HZYImageScanView showWithImages:self.imageArray thumbs:self.thumArray beginIndex:index deletable:NO delegate:self];
}

- (void)setImageViewHidden:(BOOL)hidden atIndex:(NSUInteger)index {
    if (index == 0) {
        self.iamgeView1.hidden = hidden;
    }else if (index == 1) {
        self.imageView2.hidden = hidden;
    }else{
        self.imageView3.hidden = hidden;
    }
}
@end
