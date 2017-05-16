//
//  Aspect-ViewControllerPureLayout.m
//  AspectLayout
//
//  Created by shiyong_li on 17/4/7.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import <XAspect/XAspect.h>
#import "UIViewController+AutoLayout.h"

#define AtAspect ViewControllerPureLayout

#define AtAspectOfClass UIViewController
@classPatchField(UIViewController)
AspectPatch(-, void, updateViewConstraints) {
    //do update View constraints here
    if (!self.didSetupConstraints){
        [self myUpdateViewConstraints];
        self.didSetupConstraints = YES;
    }
    XAMessageForward(updateViewConstraints);
}

//#warning uncomment this will cause crash when using baidu keyboard
//AspectPatch(-, void, viewDidLoad) {
//    [self.view setNeedsUpdateConstraints];
//    XAMessageForwardDirectly(viewDidLoad);
//}

AspectPatch(-, void, viewWillAppear:(BOOL)animated){
    [self.view setNeedsUpdateConstraints];
    XAMessageForward(viewWillAppear:animated);
}

/**
 * mbUpdateViewConstraints for constraints set with PureLayout once
 */
- (void)myUpdateViewConstraints{}

- (BOOL)didSetupConstraints
{
    NSNumber *setupConstrains = objc_getAssociatedObject(self, @selector(didSetupConstraints));
    return setupConstrains.boolValue;
}

- (void)setDidSetupConstraints:(BOOL)setupConstraints
{
    objc_setAssociatedObject(self, @selector(didSetupConstraints), [NSNumber numberWithBool:setupConstraints], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
#undef AtAspectOfClass

#undef AtAspect

