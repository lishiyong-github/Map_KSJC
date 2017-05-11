//
//  MapViewController+BusinessSearch.h
//  zzzf
//
//  Created by zhangliang on 14-4-20.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapViewController.h"


@interface MapViewController (BusinessSearch)<ServiceCallbackDelegate>
-(void)c_queryData:(NSString *)orgId dataType:(int)dataType dateLevel:(int)dataLevel;
-(void)c_updateBusinessData;
-(void)c_initDataQueryList;
@end
