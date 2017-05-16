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
#import "MessageLabel.h"

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
        [MessageLabel showMessage:NSStringFromClass([self class])];
    }
    
    // Forward the message to the source implementation.
    return XAMessageForward(viewDidAppear:animated);
}

@end
#undef AtAspectOfClass
#undef AtAspect
