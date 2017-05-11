//
//  OMBaseItem.h
//  KSJC
//
//  Created by liuxb on 2017/1/4.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ItemType)
{
    Catalog = 0,
    Group,
    Layer
};

@interface OMBaseItem : NSObject

@property (readwrite, nonatomic, strong) NSString *itemId, *name, *parentLayerId, *serviceUid, *layerId;
@property (assign, nonatomic) BOOL visible, expanded;
@property (assign, nonatomic) ItemType type;
@property (strong, nonatomic) NSArray<NSString *> *subLayerIds;

@property (assign, nonatomic) NSInteger retainNum, level;

- (OMBaseItem *)initWithDict:(NSDictionary*)dict;
+ (OMBaseItem *)itemWithDict:(NSDictionary*)dict;

@end
