//
//  Aspect-ViewLayout.m
//  nbOneMap
//
//  Created by shiyong_li on 17/4/7.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <XAspect/XAspect.h>
#import "UIView+Layout.h"

#define AtAspect ViewPureLayout

#define AtAspectOfClass UIView
@classPatchField(UIView)

AspectPatch(-, void, updateConstraints) {
    
    if (!self.didSetupConstraints)
    {
        [self myUpdateConstraints];
        self.didSetupConstraints = YES;
    }
    XAMessageForward(updateConstraints);
}

AspectPatch(-, void, setFrame:(CGRect)frame){//fix screenshot crash in iOS 9.x
    if (CGRectIsNull(frame)) {
        frame = CGRectZero;
    }
    XAMessageForward(setFrame:frame);
}

/**
 *  myUpdateConstraints for constraints set with PureLayout once
 */
- (void)myUpdateConstraints{}

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
