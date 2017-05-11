//
//  LSYShowMsg.m
//  TestPod
//
//  Created by shiyong_li on 2017/5/11.
//  Copyright © 2017年 shiyong_li. All rights reserved.
//

#import "LSYShowMsg.h"
#import "ZAActivityBar.h"
#import <UIKit/UIKit.h>
@implementation LSYShowMsg
+ (void)showNotificationWithTitle:(NSString *)message
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [ZAActivityBar setLocationTabBar];
    });
    //compute duration automaticly
    if (message.length==0) {
        return;
    }
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSTimeInterval duration = MAX(((double)data.length/30.0),1.0);
    [ZAActivityBar showImage:nil status:message duration:duration];
}
@end
