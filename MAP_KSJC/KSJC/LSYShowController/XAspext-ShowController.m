//
//  XAspext-ShowController.m
//  TestPod
//
//  Created by shiyong_li on 2017/5/11.
//  Copyright © 2017年 shiyong_li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XAspect.h"
#import <UIKit/UIKit.h>
#import "LSYShowMsg.h"

// A aspect namespace for the aspect implementation field (mandatory).
#define AtAspect UIViewController

// Create an aspect patch field for the class you want to add the aspect patches to.
#define AtAspectOfClass UIViewController
@classPatchField(UIViewController)

// Intercept the target objc message.
AspectPatch(-, void, viewDidAppear:(BOOL)animated)
{
    // Add your custom implementation here.
    if([self isKindOfClass:[UIViewController class]]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"%@",NSStringFromClass([self class]));
            [LSYShowMsg showNotificationWithTitle:NSStringFromClass([self class])];
        });
    }
    
    // Forward the message to the source implementation.
    return XAMessageForward(viewDidAppear:animated);
}

AspectPatch(-, void, viewWillAppear:(BOOL)animated)
{
    // Add your custom implementation here.
    if([self isKindOfClass:[UIViewController class]]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [LSYShowMsg showNotificationWithTitle:NSStringFromClass([self class])];
        });
    }
    
    // Forward the message to the source implementation.
    return XAMessageForward(viewWillAppear:animated);
}

@end
#undef AtAspectOfClass
#undef AtAspect
