//
//  OMapViewController+BusinessDataQuery.h
//  zzzf
//
//  Created by zhangliang on 14-4-16.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController.h"

@interface OMapViewController (BusinessDataQuery)<ServiceCallbackDelegate>

-(void)queryData:(NSString *)orgId dataType:(int)dataType dateType:(int)dateType dateLevel:(int)dataLevel;
-(void)updateBusinessData;
-(void)initDataQueryList;
@end
