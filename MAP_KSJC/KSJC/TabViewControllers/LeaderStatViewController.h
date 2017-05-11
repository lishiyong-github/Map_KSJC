//
//  LeaderStatViewController.h
//  zzzf
//
//  Created by dist on 14-4-13.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNLineChart.h"
#import "PNLineChartData.h"
#import "PNLineChartDataItem.h"
#import "PNColor.h"
#import "PNCircleChart.h"
#import "ServiceProvider.h"
#import "SysButton.h"
#import "XYPieChart.h"

@interface LeaderStatViewController : UIViewController<ServiceCallbackDelegate,UIAlertViewDelegate,XYPieChartDataSource>{
    NSArray *_circleDatasource;
    NSArray *arr;
    
    int _year;
}
- (IBAction)onBtnGoBackTap:(id)sender;
@property (weak, nonatomic) IBOutlet SysButton *btnNext;
@property (weak, nonatomic) IBOutlet XYPieChart *chartFyx;
@property (weak, nonatomic) IBOutlet XYPieChart *chartPhgz;
@property (weak, nonatomic) IBOutlet XYPieChart *chartWfaj;

@property (weak, nonatomic) IBOutlet XYPieChart *chartDailyJob;
@property (weak, nonatomic) IBOutlet SysButton *btnPrevious;
@property (weak, nonatomic) IBOutlet UILabel *lblCount4;
@property (weak, nonatomic) IBOutlet UILabel *lblCount3;
@property (weak, nonatomic) IBOutlet UILabel *lblCount1;
@property (weak, nonatomic) IBOutlet UILabel *lblCount2;
@property (retain,nonatomic) IBOutlet UIWebView *webView;
@property (retain,nonatomic) NSString *msg;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblDept;
@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UIView *storeInfoView;
- (IBAction)onBtnPrevious:(id)sender;
- (IBAction)onBtnNext:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblYear;

@property (nonatomic,retain) NSArray *orgInfo;

@end
