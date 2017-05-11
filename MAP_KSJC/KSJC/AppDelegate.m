//
//  AppDelegate.m
//  KSJC
//
//  Created by 叶松丹 on 16/9/18.
//  Copyright © 2016年 dist. All rights reserved.
//

#import "AppDelegate.h"
#import "Global.h"
#import <CoreLocation/CoreLocation.h>
@interface AppDelegate ()
@property (strong,nonatomic) CLLocationManager *locationManager;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //移除水印
    NSError *error;
    NSString *clientID = @"8KlIL7B2KP9eb3Xd";
    [AGSRuntimeEnvironment setClientID:clientID error:&error];
    if (error) {
        NSLog(@"Error using client ID : %@",[error localizedDescription]);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
    [Global initSystem];
    
    //地图定位
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = (id)self;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self.locationManager startUpdatingLocation];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication *app=[UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask=[app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask!=UIBackgroundTaskInvalid) {
                bgTask=UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask!=UIBackgroundTaskInvalid) {
                bgTask=UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    [Global isOnline:status !=NotReachable];
    
    if (status == NotReachable) {
        [Global isOnline:NO];
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AppName""
         message:@"NotReachable"
         delegate:nil
         cancelButtonTitle:@"YES" otherButtonTitles:nil];
         [alert show];
         [alert release];*/
    }else{
        [Global isOnline:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"持续使用授权");
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"使用中授权");
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"授权被拒绝");
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"等待用户授权");
            break;
        default:
            break;
    }
}

@end
