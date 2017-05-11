//
//  DailyJobReaderViewController.h
//  zzzf
//
//  Created by dist on 14-2-25.
//  Copyright (c) 2014年 dist. All rights reserved.
//
//日常巡查报告

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"
#import "SysButton.h"
#import "PhotoCollection.h"
#import "OpenFileDelegate.h"

@interface DailyJobReaderViewController : UIViewController<ServiceCallbackDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,PhotoCollectionDelegate,UIWebViewDelegate>{
    BOOL poped;
    NSArray *_dataSource;
    NSDictionary *_currentJobInfo;
    NSArray *_photots;
    NSString *_day;
    NSArray *_stopworkforms;
    PhotoCollection *_photoViewer;
    UITableViewCell *_currentSelectedTableViewCell;
    BOOL _photoInitlized;
    BOOL _webLoadTag;
    BOOL _dataReaded;
}
- (IBAction)onBtnReportTap:(id)sender;
- (IBAction)onBtnPhotoTap:(id)sender;
@property (nonatomic,retain) id<OpenFileDelegate> fileDelegate;
//照片
@property (weak, nonatomic) IBOutlet SysButton *btnPhotos;
//停工单
@property (weak, nonatomic) IBOutlet UILabel *lblStopworkforms;
//巡查报告
@property (weak, nonatomic) IBOutlet SysButton *btnReport;
//
@property (weak, nonatomic) IBOutlet UIView *watingView;

@property (weak, nonatomic) IBOutlet UIView *jobInfoView;
//标题
@property (weak, nonatomic) IBOutlet UILabel *lblDateTitle;
//停工单tableview
@property (weak, nonatomic) IBOutlet UITableView *tableStopworkforms;
//操作人
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
//pda
@property (weak, nonatomic) IBOutlet UILabel *lblPda;
//
@property (weak, nonatomic) IBOutlet UILabel *lblOrg;
//开始时间
@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
//结束时间
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
//结果报告
@property (weak, nonatomic) IBOutlet UIWebView *webReport;
//停工单表格
@property (weak, nonatomic) IBOutlet UIWebView *webStopworkform;
//菊花标签
@property (weak, nonatomic) IBOutlet UILabel *lblWating;
//菊花
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityForData;

//
@property BOOL defaultDisplayStopworkfrom;



//基本信息TableView
@property (weak, nonatomic) IBOutlet UITableView *baseTabelView;
@property(nonatomic,strong) NSMutableArray *infoArray;
@property(nonatomic,strong) NSMutableArray *markArray;//标记数组(分组收放)
@property(nonatomic,strong) NSMutableArray *groupImgArray;//分组图标
@property(nonatomic,strong) NSMutableArray *detailArray_in;//详细信息
@property(nonatomic,strong) NSMutableArray *detailArray_out;//基本信息


-(IBAction)onBtnGobackTap:(id)sender;
-(void) loadJob:(NSString *)day withDict:(NSDictionary *)dict;

- (void)loadbaseProjectWithpid:(NSString *)pid andTime:(NSString *)time;


-(void)loadJobFromData:(NSDictionary *)data;

@end
