//
//  OMapViewController+SearchDaily.m
//  zzzf
//
//  Created by Aaron on 14-4-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController+SearchDaily.h"

@interface OMapViewController ()

@end

@implementation OMapViewController (SearchDaily)


-(void)initQueryTask{
    //set up query task against layer, specify the delegate
	self.queryTask = [AGSQueryTask queryTaskWithURL:[NSURL URLWithString:@""]];
	self.queryTask.delegate = self;
	
	//return all fields in query
	self.query = [AGSQuery query];
	self.query.outFields = [NSArray arrayWithObjects:@"*", nil];
}
//results are returned
- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {
	//get feature, and load in to table
	self.featureSet = featureSet;
}

//if there's an error with the query display it to the user
- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
														message:[error localizedDescription]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}


@end
