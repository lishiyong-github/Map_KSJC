//
//  SynPool.h
//  zzzf
//
//  Created by dist on 14-1-5.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataPostman.h"

@interface SynPool : NSObject

{
    NSMutableDictionary *_collection;
    NSMutableArray *_keyList;
    BOOL _uploading;
    NSTimer *_runer;
    NSString *_currentUploadKey;
    BOOL _postToOtherSystem;
}

-(void)add:(NSString *)name data:(NSMutableDictionary *)data;
-(void)start;
-(void)stop;

+(NSString *) DATAIDENTITY_DAILYJOB_NEW:(NSString *) uuid;

@property(nonatomic,retain,readonly) NSMutableDictionary *pool;

@end
