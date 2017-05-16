//
//  UIViewController+AutoLayout.h
//  AspectLayout
//
//  Created by shiyong_li on 17/4/7.
//  Copyright © 2017年 dist. All rights reserved.
//

#ifndef JBHope_UIViewController_AutoLayout_h
#define JBHope_UIViewController_AutoLayout_h

@interface UIViewController (AutoLayout)

@property (nonatomic, assign) BOOL didSetupConstraints;

- (void)myUpdateViewConstraints;

@end

#endif
