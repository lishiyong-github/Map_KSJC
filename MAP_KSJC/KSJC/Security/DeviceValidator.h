//
//  DeviceValidator.h
//  oneMap
//
//  Created by dist on 14-3-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceProvider.h"

@interface DeviceValidator : NSObject<ServiceCallbackDelegate>{
    ServiceProvider *_checkProvider;
}

-(void)beginValidate;

@end
