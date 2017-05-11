//
//  ServiceProvider.h
//  YDZF
//
//  Created by dist on 13-10-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServiceCallbackDelegate;

@interface ServiceProvider : NSObject{
    NSThread *thread;
    BOOL runing;
    NSMutableDictionary *requestParameters;
    NSString *requestType;
    int dataType;
}

@property(nonatomic,assign) id<ServiceCallbackDelegate> delegate;
@property int tag;

+(ServiceProvider *) initWithDelegate:(id)delegate;

-(void) getString:(NSString *)type parameters:(NSMutableDictionary *) params;

-(void) getData:(NSString *) type parameters:(NSMutableDictionary *) params;

-(void) kill;

@end

@protocol ServiceCallbackDelegate <NSObject>

@optional
-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data;
@optional
-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data;
@optional
-(void) serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error;

@end
