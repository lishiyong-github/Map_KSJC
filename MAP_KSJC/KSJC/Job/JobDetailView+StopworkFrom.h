//
//  JobDetailView+StopworkFrom.h
//  zzzf
//
//  Created by dist on 14-4-3.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "JobDetailView.h"
#import "StopWorkFormView2.h"

@interface JobDetailView (StopworkFrom)<StopWorkFormDelegate2>

-(void)showStopworkForm;
-(void)clearStopworkForm;
-(void)hideStopworkForm;
-(void)hideMapForm;

-(void)stopworkfromRequestFailed:(ASIHTTPRequest *)request;
-(void)stopworkfromRequestFinished:(ASIHTTPRequest *)request;

@end
