//
//  DailyJobListener.h
//  zzzf
//
//  Created by dist on 14-3-10.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceProvider.h"

@protocol DailyJobListenerDelegate;

@interface DailyJobListener : NSObject<ServiceCallbackDelegate>{
    NSTimer *_listener;
    NSArray *_devices;
}

-(void)startListener;
-(void)stopListener;
-(void)startRouteListener;
-(void)beginLoadLastPosition:(NSArray *)devices;

@property (nonatomic,retain) id<DailyJobListenerDelegate> delegate;

@end

@protocol DailyJobListenerDelegate <NSObject>
@optional
-(void)dailyJobListener:(DailyJobListener *)listener didReciveJob:(NSMutableArray *)jobs;
@optional
-(void)dailyJobListener:(DailyJobListener *)listener didReciveRoute:(NSMutableArray *)routes;
@optional
-(void)dailyJobListener:(DailyJobListener *)listener didReciveCurrentJobLocation:(NSMutableArray *)locations;

@end
