//
//  DataPostman.h
//  zzzf
//
//  Created by dist on 14-3-26.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@protocol DataPostmanDelegate <NSObject>

-(void)dataPostmanDidCompleted;
-(void)dataPostmanDidError;

@end

@interface DataPostman : NSObject

-(void)postDataWithUrl:(NSString *)url data:(NSMutableDictionary *)data delegate:(id<ASIHTTPRequestDelegate>)delegate;
@property int tag;
@end
