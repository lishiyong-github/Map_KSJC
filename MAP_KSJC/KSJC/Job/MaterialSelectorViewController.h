//
//  MaterialSelectorViewController.h
//  zzzf
//
//  Created by dist on 13-12-9.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "JobDetailView.h"

@protocol MaterialSelectorDelegate <NSObject>

-(void)materialSelected:(NSString *)projectId fileId:(NSString *)fileId extension:(NSString *)extension fileName:(NSString *)fileName;

@end

@class JobDetailView;

@interface MaterialSelectorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (retain,nonatomic) UITableView *materialTableView;
@property (retain,nonatomic) NSMutableArray *files;
@property (retain,nonatomic) NSString *projectId;
//@property (retain,nonatomic) JobDetailView *supView;
@property (retain,nonatomic) id<MaterialSelectorDelegate> delegate;

@end
