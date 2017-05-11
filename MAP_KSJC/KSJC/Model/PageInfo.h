//
//  PageInfo.h
//  zzzf
//
//  Created by dist on 13-11-26.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageInfo : NSObject

@property int pageIndex;
@property int pageSize;
@property int dataCount;
@property int pageCount;

-(id) initWithDataCount:(int)count;
-(void)calcPageInfo:(int)count;
@end
