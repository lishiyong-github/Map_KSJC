//
//  Global.m
//  YDZF
//
//  Created by zhangliang on 13-10-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "Global.h"
#import "Reachability.h"
#import "LockViewController.h"
#import "WaitingView.h"

@implementation Global

static UserInfo *_currentUser;
static NSString *_userlistSavePath;
//static NSMutableDictionary *_userlist;
static BOOL _isOnline = NO;
static SynPool *_pool;
static BOOL _locked = NO;
static NSString *_lockInfoSavePath;
static bool _sysInitialized;

+(void)addDataToSyn:(NSString *)name data:(NSMutableDictionary *)data{
    [_pool add:name data:data];
}

/*
 *  http://58.246.138.178:8040/KSYDService/ServiceProvider.ashx  公司测试地址
 *  http://61.155.216.5:89/KSYDService/ServiceProvider.ashx   客户的实际地址
 *
 */
+(NSString *)serviceUrl{
//    return [NSString stringWithFormat:@"%@/ServiceProvider.ashx",[Global serverAddress]];
    
        return @"http://58.246.138.178:8040/KSYDService/ServiceProvider.ashx";
//    return @"http://61.155.216.5:89/KSYDService/ServiceProvider.ashx";
//    return  @"http://58.246.138.178:8040/KSYDService/ServiceProvider.ashx";
//    return  @"http://58.246.138.178:8040/KSYDService/ServiceProvider.ashx";
//return  @"http://61.155.216.5:89/KSYDService/ServiceProvider.ashx";
    //周金满个人电脑
//  return  @"http://192.168.2.196/ksyd/ServiceProvider.ashx";

// return @"http://112.1.17.7:9000/WebApp/ServiceProvider.ashx";
}

+(NSString *)tempUrl
{

return [NSString stringWithFormat:@"%@/ServiceProvider.ashx",[Global serverAddress]];


}

+(NSString *)serverAddress{
    //return @"http://192.168.2.239/zzzfServices";
    return @"http://58.246.138.178:8040/ZZZFServices";
//    return @"http://218.75.221.182:801/zzzfservices";
        //return @"http://192.168.23.1/ZZZFServices";
//    return @"http://192.168.2.210/ZZZFServices";
}

+(void)initializeUserInfo:(NSString *)name userId:(NSString *)userId org:(NSString *)org orgID:(NSString *)orgID{
    _currentUser = [UserInfo userWithNameAndId:name userId:userId];
    _currentUser.org = org;
    _currentUser.orgID = orgID;
}

+(void)logout{
    _currentUser = nil;
}

+(UserInfo *)currentUser{
    return _currentUser;
}

+(BOOL)isOnline{
    /*
    BOOL isReachable = NO;
    Reachability *reachability = [Reachability reachabilityWithHostName:[Global serviceUrl]];
    switch ([reachability currentReachabilityStatus]) {
        case NotReachable:{
            isReachable = NO;
        }
            break;
        case ReachableViaWWAN:{
            isReachable = YES;
        }
            break;
        case ReachableViaWiFi:{
            isReachable = YES;
        }
            break;
        default:
            isReachable = NO;
            break;
    }
    return isReachable;
     */
    return _isOnline;
}

+(void)isOnline:(BOOL)online{

    _isOnline = online;
}

+(void)initSystem{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    _lockInfoSavePath = [[paths objectAtIndex:0] stringByAppendingString:@"/lock.txt"];
    
    NSString *lockInfo = [NSString stringWithContentsOfFile:_lockInfoSavePath encoding:NSUTF8StringEncoding error:nil];
    
    if (!_locked && nil!=lockInfo && ![lockInfo isEqualToString:@""]) {
        [self lock:lockInfo];
    }else if(!_sysInitialized){
        _pool = [[SynPool alloc] init];
        [_pool start];
        _sysInitialized = YES;
    }
}

//生成唯一字符串
+(NSString *)newUuid{
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    return cfuuidString;
}

+(void)showMessage:(NSString *)msg{
    
}


static LockViewController *_lockView;
static UIViewController *_workView;

+(void)lock:(NSString *)code{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (nil==_lockView) {
        _lockView = [[LockViewController alloc] initWithNibName:@"LockViewController" bundle:nil];
    }
    if (![window.rootViewController isKindOfClass:[LockViewController class]]) {
        _workView = window.rootViewController;
    }
    window.rootViewController = _lockView;
    [code writeToFile:_lockInfoSavePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    _locked = YES;
    _lockView.code = code;
}

+(void)unlock{
    if (nil!=_workView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.rootViewController = _workView;
    }
    [@"" writeToFile:_lockInfoSavePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    _locked = NO;
    if (!_sysInitialized) {
        [Global initSystem];
    }
}

+(BOOL)locked{
    return _locked;
}

static WaitingView *wv;
static bool wvInWindow;
+(void)wait:(NSString *)msg{
    if (nil==msg && nil!=wv) {
        [wv removeFromSuperview];
        wvInWindow = NO;
    }else{
        UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (controller.presentedViewController != nil) {
            controller = controller.presentedViewController;
        }
        if (nil==wv) {
            wv = [[WaitingView alloc] initWithFrame:CGRectMake(0, 0, 1024,768)];
        }
        //设置显示内容
        wv.msg = msg;
        if (!wvInWindow) {
            [controller.view addSubview:wv];
        }
        wvInWindow = YES;
    }
}


+(void)waitclear{
    if(wv!=nil)
    {
        [wv removeFromSuperview];
    }
        wvInWindow = NO;
}

@end
