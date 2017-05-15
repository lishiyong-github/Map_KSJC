//
//  SaveLocationHelper.h
//  KSJC
//
//  Created by shiyong_li on 2017/5/15.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserLocationModel.h"
@interface SaveLocationHelper : NSObject

/**
 存储 location

 @param location 新建的检查点的位置
 */
+ (void)saveUserLocation:(UserLocationModel *)location;

/**
 获取存储的项目检查点

 @return @[UserLocationModel];
 */
+ (NSArray *)getUserLocations;
@end
