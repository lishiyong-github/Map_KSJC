//
//  OMapViewController+SearchDaily.h
//  zzzf
//
//  Created by Aaron on 14-4-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController.h"

@interface OMapViewController (SearchDaily)<AGSQueryTaskDelegate>

-(void)initQueryTask;
@end
