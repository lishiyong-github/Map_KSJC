//
//  UserInfo.h
//  zzzf
//
//  Created by dist on 13-11-19.
//  Copyright (c) 2013年 dist. All rights reserved.
//  用户信息

#import <Foundation/Foundation.h>
#import "JobInfo.h"

@interface UserInfo : NSObject{
    //存储位置
    NSString *_userPath;
    NSString *_userWorkTempPath;
    NSString *_userResourcePath;
    NSString *_userProjectPath;
    NSString *_userWorkPath;
    NSString *_dailyJobInfoPath;
    
    //当前日常巡查数据存储位置
    NSString *_dailyJobCurrentPlistPath;
    //所有的日常巡查记录存储位置
    NSString *_dailyJoblistSavePath;
    
    NSString *_mapFavoriteSavePath;
    
    NSMutableDictionary *_dailyJobCurrentInfo;
    NSMutableDictionary *_dailyJobList;
    
    NSMutableDictionary *_mapFavorites;
}

@property (nonatomic,retain) NSMutableDictionary *properties;

//用户名
@property (nonatomic, retain) NSString *username;

//用户ID
@property (nonatomic, retain) NSString *userid;

@property (nonatomic,retain) NSString *deviceNumber;

@property (nonatomic,retain) NSString *deviceName;

@property (nonatomic,retain) NSString *org;

@property (nonatomic,retain) NSString *orgID;

//密码（加密后的）
@property (nonatomic, retain) NSString *password;

//下载的文件
@property (nonatomic, retain) NSMutableDictionary *saveFiles;

//本地目录信息
@property (nonatomic, retain) NSMutableDictionary *directoryInfo;

//办理的作业
@property (nonatomic, retain) NSMutableDictionary *jobs;

//当前作业代码
@property NSString *currentJobCode;


-(void) save;
-(void) removeFromDisk;
-(void) inititalizUser;
-(NSString *)userPath;
-(NSString *)userWorkTempPath;
-(NSString *)userResourcePath;
-(NSString *)userProjectPath;
-(NSString *)userWorkPath;
-(NSString *)userDailyJobPath;


-(void)saveCurrentDailyJobToDisk;
-(void)saveDailJobListToDisk;
-(void)saveMapFavoriteToDisk;
-(void)clearCurrentDailyJob;

-(NSMutableDictionary *)dailyJobCurrentInfo;
-(NSMutableDictionary *)dailyJobList;
-(NSMutableDictionary *)mapFavorites;

+(UserInfo *) userWithNameAndId:(NSString *)userName userId:(NSString *)userId;

//-(NSString *)USER_DAILYJOB_STATUS_CHANGED;

@end
