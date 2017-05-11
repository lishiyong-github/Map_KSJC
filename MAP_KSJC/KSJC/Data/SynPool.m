//
//  SynPool.m
//  zzzf
//  数据提交到服务的“池”，不要直接使用。通过[Global addDataToSyn]访问
//  Created by dist on 14-1-5.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "SynPool.h"
#import "ASIFormDataRequest.h"

#import "Global.h"

@interface SynPool ()<ASIHTTPRequestDelegate>

@end

@implementation SynPool

@synthesize pool = _collection;

-(id)init{
    self = [super init];
    if (self) {
        [self initPool];
    }
    return self;
}

-(void)initPool{
    _collection = [NSMutableDictionary dictionaryWithCapacity:10];
    _keyList = [NSMutableArray arrayWithCapacity:10];
    //......
}

//提交数据到缓冲池（数据的提交是顺序进行的）。
-(void)add:(NSString *)name data:(NSMutableDictionary *)data{
    [_collection setObject:data forKey:name];
    [_keyList addObject:name];
}

-(void)start{
    if (nil==_runer) {
        _runer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    }else{
        [_runer fire];
    }
}

-(void)stop{
    [_runer invalidate];
}

//tick,tick,tick....还有没有要去服务器的？3秒钟一班。
-(void)tick{
    if (!_uploading && _collection.count>0) {
        _currentUploadKey = [_keyList objectAtIndex:0];
        [self submit:[_collection objectForKey:_currentUploadKey]];
    }
}

//提交数据
-(void)submit:(NSMutableDictionary *)data{
    //不允许重复提交数据
    _uploading = YES;
    NSString *url = [data objectForKey:@"posturl"];
    if (nil==url) {
        _postToOtherSystem = NO;
        url = [Global serviceUrl];
    }else{
        _postToOtherSystem = YES;
    }
    DataPostman *postman = [[DataPostman alloc] init];
    [postman postDataWithUrl:url data:data delegate:self];
    
    NSLog(@"start request:%@",_currentUploadKey);
    //[request setDidFinishSelector:@selector(requestedSuccessfully)];
    //[request setDidFailSelector:@selector(requestedFail)];
}


//数据提交成功后，把数据移除出队列
-(void)success{
    [_keyList removeObjectAtIndex:0];
    [_collection removeObjectForKey:_currentUploadKey];
    _currentUploadKey = nil;
    _uploading = NO;
    NSLog(@"successfully");
}

//如果提交失败，则放置到队列的末尾(如果有那么几个数据一直提交失败，然后就一直往死里提交数据，耗流量，以后再考虑重试的问题)
-(void)fail{
    NSString *theKey = _currentUploadKey;
    _currentUploadKey =nil;
    
    [_keyList removeObjectAtIndex:0];
    [_keyList addObject:theKey];
    _uploading = NO;
    NSLog(@"failed");
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"error:%@",request.responseString);
    [self fail];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    if (request.responseStatusCode==200) {
        if (_postToOtherSystem) {
            [self success];
            return;
        }
        NSError *parseError = nil;
        NSString *responseString = request.responseString;
        NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&parseError];
        if(nil!=parseError){
            [self success];
        }else if([[rs objectForKey:@"status"] isEqualToString:@"false"]){
            NSLog(@"error:%@",[rs objectForKey:@"message"]);
            [self fail];
        }else{
            [self success];
        }
    }else{
        [self fail];
    }
}

+(NSString *) DATAIDENTITY_DAILYJOB_NEW:(NSString *)uuid{
    return [NSString stringWithFormat:@"DATA_DAILYJOB_NEW_%@",uuid];
}

@end
