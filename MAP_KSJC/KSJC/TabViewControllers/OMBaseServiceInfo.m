//
//  OMServiceLayer.m
//  KSJC
//
//  Created by liuxb on 2017/1/5.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "OMBaseServiceInfo.h"

@implementation OMBaseServiceInfo

- (OMBaseServiceInfo *)initWithDict:(NSDictionary*)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+ (OMBaseServiceInfo *)serviceWithDict:(NSDictionary*)dict{
    return [[OMBaseServiceInfo alloc] initWithDict:dict];
}


- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqual:@"visible"]) {
        NSString* strBool = (NSString*)value;
        self.visible = [strBool isEqual:@"true"] ? YES:NO;
    } else {
        [super setValue:value forKey:key];
    }
}

@end























































