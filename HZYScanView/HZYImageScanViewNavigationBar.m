//
//  HZYImageScanViewNavigationBar.m
//  HZYScanView
//
//  Created by 郝振壹 on 2017/6/18.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import "HZYImageScanViewNavigationBar.h"

@interface HZYImageScanViewNavigationBar ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *deleteButton;
@property (nonatomic, weak) UIButton *backButton;

@end
@implementation HZYImageScanViewNavigationBar
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configNavigationBar];
        self.hidden = YES;
    }
    return self;
}

+ (instancetype)navigationBarForOrigentation:(HZYImageScanViewNavigationBarOrientation)orientation {
    HZYImageScanViewNavigationBar *view;
    switch (orientation) {
        case HZYImageScanViewNavigationVertical:
            return view = [[HZYImageScanViewNavigationBar alloc] initWithFrame:CGRectMake(0, -68, [UIApplication sharedApplication].keyWindow.bounds.size.width, 64)];
        case HZYImageScanViewNavigationHorizontal:
            return view = [[HZYImageScanViewNavigationBar alloc] initWithFrame:CGRectMake(0, -68, [UIApplication sharedApplication].keyWindow.bounds.size.width, 44)];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake((self.bounds.size.width - 100) / 2, CGRectGetHeight(self.frame) - 44, 100, 44);
    self.deleteButton.frame = CGRectMake(self.bounds.size.width - 44, CGRectGetHeight(self.frame) - 44, 44, 44);
    self.backButton.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 44, 44, 44);
}

- (void)configNavigationBar {
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOpacity = .3;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 2;
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;

    UIButton *deleteBtn = [UIButton new];
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
    [self addSubview:deleteBtn];
    self.deleteButton = deleteBtn;
    
    UIButton *backBtn = [UIButton new];
    [backBtn setImage:[UIImage imageNamed:@"navgationBackImg"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnTouched) forControlEvents:UIControlEventTouchUpInside];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
    [self addSubview:backBtn];
    self.backButton = backBtn;
}

- (void)deleteAction {
    if (self.deleteBtnAction) {
        self.deleteBtnAction();
    }
}

- (void)backBtnTouched {
    if (self.backBtnAction) {
        self.backBtnAction();
    }
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setShowDeleteBtn:(BOOL)showDeleteBtn {
    self.deleteButton.hidden = !showDeleteBtn;
}
@end
