//
//  Global.h
//  YDZF
//
//  Created by zhangliang on 13-10-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "SynPool.h"

@interface Global : NSObject

//初始化系统数据
+(void)initSystem;

//初始化用户信息
+(void)initializeUserInfo:(NSString *)name userId:(NSString *)userId org:(NSString *)org orgID:(NSString *)orgID;

//退出登录
+(void)logout;

//当前用户
+(UserInfo *)currentUser;

//服务地址
+(NSString *) serviceUrl;

+(NSString *)tempUrl;


//网络状态
+(BOOL)isOnline;
+(void)isOnline:(BOOL)online;


//提交数据到服务器（图片也可以）
+(void)addDataToSyn:(NSString *)name data:(NSMutableDictionary *)data;

+(NSString *)newUuid;

+(void)showMessage:(NSString *)msg;

+(void)lock:(NSString *)code;
+(void)unlock;

+(BOOL)locked;

+(void)wait:(NSString *)msg;
+(void)waitclear;

+(NSString *)serverAddress;

@end
