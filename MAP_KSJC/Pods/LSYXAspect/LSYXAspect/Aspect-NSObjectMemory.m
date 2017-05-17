//
//  Aspect-NSObjectMemory.m
//  nbOneMap
//
//  Created by shiyong_li on 17/3/28.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XAspect.h"

// A aspect namespace for the aspect implementation field (mandatory).
#define AtAspect ObjectLifetime

// Create an aspect patch field for the class you want to add the aspect patches to.
#define AtAspectOfClass UIViewController
@classPatchField(UIViewController)

// Intercept the target objc message.
AspectPatch(-, instancetype, init)
{
    // Add your custom implementation here.
    if([self isKindOfClass:[UIViewController class]]){
        NSLog(@"[Init]: %@", NSStringFromClass([self class]));
    }
    
    // Forward the message to the source implementation.
    return XAMessageForward(init);
}

AspectPatch(-, void, dealloc)
{
    // Add your custom implementation here.
    if([self isKindOfClass:[UIViewController class]]){
        NSLog(@"[dealloc ]: %@", NSStringFromClass([self class]));
    }
    
    XAMessageForwardDirectly(dealloc);
}

@end
#undef AtAspectOfClass
#undef AtAspect
