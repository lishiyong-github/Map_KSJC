//
//  DailyJobViewController.h
//  zzzf
//
//  Created by dist on 14-2-13.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyJobView.h"
#import "OpenFileDelegate.h"
#import "ServiceProvider.h"
#import "DayLogsVC.h"

@interface DailyJobViewController : UIViewController<DailyJobViewDelegate,ServiceCallbackDelegate,UIAlertViewDelegate,DayLogsVCDelegate>{
}
@property (nonatomic,strong) DailyJobView *jobView;

@property (nonatomic,strong)DayLogsVC *dayLogVC;

@property (nonatomic,retain) id<OpenFileDelegate> fileDelegate;

@end
