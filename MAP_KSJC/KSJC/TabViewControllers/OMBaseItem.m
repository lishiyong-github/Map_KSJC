//
//  OMBaseItem.m
//  KSJC
//
//  Created by liuxb on 2017/1/4.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "OMBaseItem.h"

@implementation OMBaseItem

- (OMBaseItem *)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (OMBaseItem *)itemWithDict:(NSDictionary *)dict {
    return [[OMBaseItem alloc] initWithDict:dict];
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.itemId = (NSString*)value;
    } else if ([key isEqualToString:@"visible"]) {
        if (value) {
            self.visible = [(NSString*)value isEqualToString:@"true"] ? YES:NO;
        }
    } else if ([key isEqualToString:@"type"]){
        NSString* typeStr = (NSString*)value;
        if ([typeStr isEqualToString:@"catalog"]) {
            self.type = Catalog;
        } else if ([typeStr isEqualToString:@"group"]) {
            self.type = Group;
        } else if ([typeStr isEqualToString:@"layer"]) {
            self.type = Layer;
        }
    } else {
        [super setValue:value forKey:key];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,%@", self.itemId,self.name];
}

@end






























































