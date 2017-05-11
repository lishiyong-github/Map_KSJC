//
//  DataPostman.m
//  zzzf
//
//  Created by dist on 14-3-26.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DataPostman.h"


@implementation DataPostman


-(void)postDataWithUrl:(NSString *)url data:(NSMutableDictionary *)data delegate:(id<ASIHTTPRequestDelegate>)delegate{
    ASIFormDataRequest * request = [self getASIHTTPFormDataRequestWithURL:url params:data];
    request.tag = self.tag;
    request.delegate = delegate;
    [request startAsynchronous];
}

-(ASIFormDataRequest *)getASIHTTPFormDataRequestWithURL:(NSString *)urlString
                                                 params:(NSDictionary *)params
{
    ASIFormDataRequest * request = nil;
    NSURL * url = [[NSURL alloc] initWithString:urlString];
    request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    NSString *requestAddress=@"";
    
    for (NSString * key in params)
    {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSString class]]
            || [value isKindOfClass:[NSNumber class]])
        {
            [request addPostValue:value forKey:key];
        }
        else if ([value isKindOfClass:[NSData class]])
        {
            [request addData:value forKey:key];
        }
        else if ([value isKindOfClass:[UIImage class]])
        {
            NSData * imageData = UIImageJPEGRepresentation(value, 1);
            [request addData:imageData forKey:key];
        }
        
        
        
      requestAddress=[requestAddress stringByAppendingFormat:@"&%@=%@",key,value];
        
        
    }
    [request setTimeOutSeconds:60.f];
    
    
    
    
    NSLog(@"post====+++++++%@?%@",url,requestAddress);
    
    
    
    return request;
}


@end
