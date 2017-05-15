//
//  SaveLocationHelper.m
//  KSJC
//
//  Created by shiyong_li on 2017/5/15.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "SaveLocationHelper.h"
#import <MJExtension.h>
static NSString *locationKey = @"location";
@implementation SaveLocationHelper
+ (void)saveUserLocation:(UserLocationModel *)location
{
    //存储位置
    NSString *locationString = [location mj_JSONString];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefaults objectForKey:locationKey];
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:array];
    [mArray addObject:locationString];
    [userDefaults setObject:mArray forKey:locationKey];
    [userDefaults synchronize];
}

+ (NSArray *)getUserLocations
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefaults objectForKey:locationKey];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSString *value in array) {
        UserLocationModel *model = [UserLocationModel mj_objectWithKeyValues:value];
        [resultArray addObject:model];
    }
    return resultArray;
}
@end
