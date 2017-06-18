//
//  HZYImageScanViewNavigationBar.h
//  HZYScanView
//
//  Created by 郝振壹 on 2017/6/18.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HZYImageScanViewNavigationBarOrientation) {
    HZYImageScanViewNavigationHorizontal,
    HZYImageScanViewNavigationVertical,
};

@interface HZYImageScanViewNavigationBar : UIView
+ (instancetype)navigationBarForOrigentation:(HZYImageScanViewNavigationBarOrientation)orientation;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL showDeleteBtn;
@property (nonatomic, copy) void(^backBtnAction)();
@property (nonatomic, copy) void(^deleteBtnAction)();

@end
