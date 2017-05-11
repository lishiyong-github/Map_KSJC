//
//  OMServiceLayer.h
//  KSJC
//
//  Created by liuxb on 2017/1/5.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMBaseServiceInfo : NSObject

@property (nonatomic, strong) NSString *name, *type, *alpha,*url;
@property (assign, nonatomic) BOOL visible;

- (OMBaseServiceInfo *)initWithDict:(NSDictionary*)dict;
+ (OMBaseServiceInfo *)serviceWithDict:(NSDictionary*)dict;

@end
