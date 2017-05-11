//
//  PageInfo.m
//  zzzf
//
//  Created by dist on 13-11-26.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "PageInfo.h"

@implementation PageInfo

@synthesize dataCount=_dataCount;
@synthesize pageCount=_pageCount;
@synthesize pageIndex=_pageIndex;
@synthesize pageSize=_pageSize;

-(id) initWithDataCount:(int)count{
    self = [super init];
    if(self){
        self.dataCount = count;
        self.pageSize = 999999;
        [self calcPageInfo:count];
    }
    return self;
}

-(id)init{
    self=[super init];
    if (self) {
        self.dataCount = 0;
        self.pageSize=999999;
    }
    return self;
}

-(void)calcPageInfo:(int)count{
    int c = count/self.pageSize;
    if (self.dataCount % self.pageSize !=0) {
        c++;
    }
    self.pageCount = c;
}

@end
