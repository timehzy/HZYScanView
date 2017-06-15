//
//  SecondViewController.m
//  HZYScanView
//
//  Created by Michael-Nine on 2017/6/15.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import "SecondViewController.h"
#import "UIImageView+HZYImageScanView.h"
@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SecondViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imageView enableScan];
}

@end
