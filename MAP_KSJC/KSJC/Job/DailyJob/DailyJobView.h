//
//  DailyJob.h
//  zzzf
//
//  Created by dist on 13-11-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewDailyJobViewController.h"
#import "DistCalendarView.h"
#import "DailyJobControlPanel.h"
#import "ServiceProvider.h"
#import "MZFormSheetController.h"
#import "DailyJobReplenish.h"

@protocol DailyJobViewDelegate <NSObject>

-(void)openPhoto:(NSString *)name path:(NSString *)path fromLocal:(BOOL)fromLocal;

-(void)openFiles:(NSArray *)files at:(int)index;

-(void)openJob:(NSString *)jobTime;
- (void)openDayOfLog:(NSString *)logTime;



@end

@interface DailyJobView : UIView<DistCalendarDelegate,ServiceCallbackDelegate,DailyJobControlPanelDelegate,UIAlertViewDelegate,DailyJobReplenishDelegate>{
    BOOL _initialized;
    NewDailyJobViewController *_newDailyJobViewController;
    DistCalendarView *_calendarView;
    DailyJobControlPanel *_jobControlPanel;
    int _calendarServiceTag;
    NSMutableArray *_calendarTimes;
    NSMutableDictionary *_calenderCacheFlag;
    NSMutableArray *_toSelectJobs;
    MZFormSheetController *_jobDaySelector;
    BOOL _beRemoveTodayCalendarCache;
    
    NSString *_historyJobSavePath;
    NSString *_historyJobListFilePath;
    NSMutableArray *_historyJobs;
    
    DailyJobReplenish *_djr;
}

- (IBAction)onBtnReUploadTouchUp:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnReUpload;
+(DailyJobView *)createView;
-(void) initializeData;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *calendarActivityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *btnCalendar;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
//巡查状态 -- 巡查开始于今天几点几分
@property (weak, nonatomic) IBOutlet UILabel *lblJobStatus;

@property (weak, nonatomic) IBOutlet UILabel *operater;
@property (weak, nonatomic) IBOutlet UIButton *InfomationBtn;


@property (nonatomic,retain) id<DailyJobViewDelegate> delegate;
@property (nonatomic,retain) UIViewController *controller;

- (IBAction)onBtnViewTaggleTap:(id)sender;
- (IBAction)onBtnNewJobTap:(id)sender;

// 接收新建巡查通知后 -- 执行的方法
-(void)changeSelectedButtonIndex:(NSNotification *)noty;

@end
