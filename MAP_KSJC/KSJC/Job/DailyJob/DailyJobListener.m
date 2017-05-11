//
//  DailyJobListener.m
//  zzzf
//
//  Created by dist on 14-3-10.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DailyJobListener.h"

@implementation DailyJobListener

-(void)startListener{
    [self stopListener];
    if (nil==_listener) {
        _listener = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(tickForJobStatus) userInfo:nil repeats:YES];
    }
}

-(void)stopListener{
    if (nil!=_listener) {
        [_listener invalidate];
        _listener = nil;
    }
}

-(void)beginLoadLastPosition:(NSArray *)devices{
    [self stopListener];
    _devices = devices;
    _listener = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(tickForCurrentPosition) userInfo:nil repeats:YES];
}

-(void)tickForJobStatus{
    ServiceProvider *p = [ServiceProvider initWithDelegate:self];
    p.tag = 1;
    [p getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getcurrentjob",@"action", nil]];
}

-(void)tickForCurrentPosition{
    ServiceProvider *p = [ServiceProvider initWithDelegate:self];
    p.tag = 3;
    NSString *split = @"";
    NSMutableString *ids = [NSMutableString stringWithCapacity:10];
    for (int i=0; i<_devices.count; i++) {
        [ids appendString:split];
        [ids appendString:[_devices objectAtIndex:i]];
        split=@",";
    }
    [p getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getlastpositionlist",@"action",ids,@"devices", nil]];
}

-(void)startRouteListener{
    [self stopListener];
    ServiceProvider *p = [ServiceProvider initWithDelegate:self];
    p.tag=2;
    [p getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getcurrentjobroute",@"action", nil]];
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    NSString *successfully = [data objectForKey:@"status"];
    if ([successfully isEqualToString:@"true"]) {
        if (provider.tag==1) {
            [self.delegate dailyJobListener:self didReciveJob:[data objectForKey:@"result"]];
        }else if(provider.tag==2){
            [self.delegate dailyJobListener:self didReciveRoute:[data objectForKey:@"result"]];
        }else if(provider.tag==3){
            [self.delegate dailyJobListener:self didReciveCurrentJobLocation:[data objectForKey:@"result"]];
        }
    }else{
        [self serviceError:provider];
    }
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    [self serviceError:provider];
}

-(void)serviceError:(ServiceProvider *)provider{
    if (provider.tag==1) {
        [self.delegate dailyJobListener:self didReciveJob:nil];
    }else if(provider.tag==2){
        [self.delegate dailyJobListener:self didReciveRoute:nil];
    }else if(provider.tag==3){
        [self.delegate dailyJobListener:self didReciveCurrentJobLocation:nil];
    }
}

@end
