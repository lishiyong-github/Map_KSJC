//
//  ResourcesView.h
//  zzzf
//
//  Created by mark on 13-11-27.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"

@class OnLineResourceView;

@interface ResourcesView : UIScrollView<ServiceCallbackDelegate,UITableViewDataSource,UITableViewDelegate>

@property OnLineResourceView *owner;
-(void) load:(NSString *)path andFileName:(NSString *)fileName;
-(void) openFile:(NSString *)path;
-(void) showThumbnails;
-(void) showDetails;

@property UITableView *tableViewFile;
@property (strong,nonatomic) NSMutableArray *wfajModels;
@property (strong,nonatomic) NSMutableArray *fileModels;
@property (strong,nonatomic) NSDictionary *fileDic;
@property UIScrollView *view1;
@property UIScrollView *view2;
@property int viewType;
@end
