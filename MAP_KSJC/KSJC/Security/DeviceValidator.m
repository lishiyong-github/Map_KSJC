//
//  DeviceValidator.m
//  oneMap
//
//  Created by dist on 14-3-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DeviceValidator.h"
#import "SvUDIDTools.h"

#import "Global.h"

@implementation DeviceValidator

-(void)beginValidate{
    NSString *udid = [SvUDIDTools UDID];
    _checkProvider = [ServiceProvider initWithDelegate:self];
    [_checkProvider getData:@"device" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"validate",@"action",udid,@"code", nil]];
    
    //NSLog(@"current identityForVendor %@", [UIDevice currentDevice].identifierForVendor);
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    NSString *successfully = [data objectForKey:@"success"];
    if ([successfully isEqualToString:@"true"]) {
        NSString *rs = [data objectForKey:@"result"];
        if (![rs isEqualToString:@"1"] && ![rs isEqualToString:@"2"]) {
            [self validateFaild:rs];
        }else{
            [Global unlock];
        }
        
    }else{
        [self validateFaild:@"0"];
    }
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    
}

-(void)validateFaild:(NSString *)code{
    [Global lock:code];
}

@end
