  //
//  UserInfo.m
//  zzzf
//
//  Created by dist on 13-11-19.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

-(void)save{
    
}

-(void)removeFromDisk{
    
}

-(void)inititalizUser{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    _userPath = [NSString stringWithFormat:@"%@/users/%@",[paths objectAtIndex:0],_userid];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //初始化用户目录
    _userWorkTempPath = [NSString stringWithFormat:@"%@/temp",_userPath];
    _userResourcePath = [NSString stringWithFormat:@"%@/resources",_userPath];
    
    _userWorkPath = [NSString stringWithFormat:@"%@/work",_userPath];
    _dailyJobInfoPath = [_userWorkPath stringByAppendingString:@"/dailyjob"];
    _userProjectPath=[_userWorkPath stringByAppendingString:@"/project"];
    _dailyJobCurrentPlistPath = [_dailyJobInfoPath stringByAppendingString:@"/currentDailyjob.archive"];
    _dailyJoblistSavePath = [_userWorkPath stringByAppendingString:@"/jobs.plist"];
    _properties = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSString  *onemapPath = [_userPath stringByAppendingString:@"/map"];
    _mapFavoriteSavePath = [onemapPath stringByAppendingString:@"/favorite.archive"];
    
    BOOL isDir;
    if (![fm fileExistsAtPath:_userWorkTempPath isDirectory:&isDir]) {
        [fm createDirectoryAtPath:_userWorkTempPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![fm fileExistsAtPath:_userResourcePath isDirectory:&isDir]) {
        [fm createDirectoryAtPath:_userResourcePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![fm fileExistsAtPath:_dailyJobInfoPath isDirectory:&isDir]) {
        [fm createDirectoryAtPath:_dailyJobInfoPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![fm fileExistsAtPath:_userProjectPath isDirectory:&isDir]) {
        [fm createDirectoryAtPath:_userProjectPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![fm fileExistsAtPath:onemapPath isDirectory:&isDir]) {
        [fm createDirectoryAtPath:onemapPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //日常巡查数据
    [self initializeDailyJobData];
    
    
    _mapFavorites = [NSMutableDictionary dictionaryWithContentsOfFile:_mapFavoriteSavePath];
    if (nil==_mapFavorites) {
        _mapFavorites = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
}

-(void) initializeDailyJobData{
    _dailyJobCurrentInfo = [NSMutableDictionary dictionaryWithContentsOfFile:_dailyJobCurrentPlistPath];
    if (nil==_dailyJobCurrentInfo) {
//        _dailyJobCurrentInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"stoped",@"status",[NSMutableArray arrayWithCapacity:3],@"times",[NSMutableArray arrayWithCapacity:3],@"points",[NSMutableArray arrayWithCapacity:1],@"stopwork",[[NSMutableDictionary alloc]init],@"report",[NSMutableArray arrayWithCapacity:3],@"photos",@"",@"device",@"",@"deviceId",nil];
//        _theprojectInfo= [jobInfo objectForKey:@"theProjectInfo"];
//        //项目
//        _theProjectMaterialA=[jobInfo objectForKey:@"theMatrialInfo"];

        _dailyJobCurrentInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"stoped",@"status",[NSMutableArray arrayWithCapacity:3],@"photos",[NSMutableArray arrayWithCapacity:3],@"times",[NSMutableDictionary dictionaryWithCapacity:100],@"theProjectInfo",[NSMutableArray arrayWithCapacity:100],@"theMatrialInfo",nil];

        
    }
    
    _dailyJobList = [NSMutableDictionary dictionaryWithContentsOfFile:_dailyJoblistSavePath];
    if (nil==_dailyJobList) {
        _dailyJobList = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
}

-(NSString *)userPath{
    return _userPath;
}

-(NSString *)userWorkTempPath{
    return _userWorkTempPath;
}

-(NSString *)userResourcePath{
    return _userResourcePath;
}

-(NSString *)userProjectPath{
    return _userProjectPath;
}

-(NSString *)userWorkPath{
    return _userWorkPath;
}

-(NSString *)userDailyJobPath{
    return _dailyJobInfoPath;
}

-(NSMutableDictionary *)dailyJobCurrentInfo{
    return _dailyJobCurrentInfo;
}

-(NSMutableDictionary *)dailyJobList{
    return _dailyJobList;
}

-(NSMutableDictionary *)mapFavorites{
    return _mapFavorites;
}

-(void)saveMapFavoriteToDisk{
    [_mapFavorites writeToFile:_mapFavoriteSavePath atomically:YES];
}

-(void)saveCurrentDailyJobToDisk{
    [_dailyJobCurrentInfo writeToFile:_dailyJobCurrentPlistPath atomically:YES];
}

-(void)saveDailJobListToDisk{
    [_dailyJobList writeToFile:_dailyJoblistSavePath atomically:YES];
}

-(void)clearCurrentDailyJob{
//    NSString *deviceId = [_dailyJobCurrentInfo objectForKey:@"deviceId"];
//    NSString *deviceName = [_dailyJobCurrentInfo objectForKey:@"device"];
//    _dailyJobCurrentInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"stoped",@"status",[NSMutableArray arrayWithCapacity:3],@"photos",[NSMutableArray arrayWithCapacity:3],@"times",nil];
    
      _dailyJobCurrentInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"stoped",@"status",[NSMutableArray arrayWithCapacity:3],@"photos",[NSMutableArray arrayWithCapacity:3],@"times",[NSMutableDictionary dictionaryWithCapacity:100],@"theProjectInfo",[NSMutableArray arrayWithCapacity:100],@"theMatrialInfo",nil];
    [self saveCurrentDailyJobToDisk];
}

+(UserInfo *)userWithNameAndId:(NSString *)userName userId:(NSString *)userId{
    UserInfo *u = [[UserInfo alloc] init];
    u.username = userName;
    u.userid = userId;
    [u inititalizUser];
    return  u;
}

//-(NSString *)USER_DAILYJOB_STATUS_CHANGED{
//    return [NSString stringWithFormat:@"USER_DAILYJOB_NEW_%@",self.userid];
//}

@end
