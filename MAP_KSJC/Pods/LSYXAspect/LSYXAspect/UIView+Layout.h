//
//  UIView+Layout.h
//  nbOneMap
//
//  Created by shiyong_li on 17/4/7.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Layout)
@property (nonatomic, assign) BOOL didSetupConstraints;
- (void)myUpdateConstraints;
@end
