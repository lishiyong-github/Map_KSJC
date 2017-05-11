//
//  DesktopViewController.h
//  zf
//
//  Created by dist on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchView.h"
#import "PNLineChart.h"
#import "PNLineChartData.h"
#import "PNLineChartDataItem.h"
#import "PNColor.h"
#import "PNCircleChart.h"
#import "ServiceProvider.h"

@interface DesktopViewController : UIViewController<ServiceCallbackDelegate,UIAlertViewDelegate>{
    NSDictionary *dic;
    NSArray *arr;
    int _year;
}
@property (weak, nonatomic) IBOutlet UILabel *lblCount4;
@property (weak, nonatomic) IBOutlet UILabel *lblCount3;
@property (weak, nonatomic) IBOutlet UILabel *lblCount1;
@property (weak, nonatomic) IBOutlet UILabel *lblCount2;
@property (retain,nonatomic) IBOutlet UIWebView *webView;
@property (retain,nonatomic) NSString *msg;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblDept;
@property (weak, nonatomic) IBOutlet TouchView *userInfoView;
@property (weak, nonatomic) IBOutlet TouchView *storeInfoView;
- (IBAction)onBtnPrevious:(id)sender;
- (IBAction)onBtnNext:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblYear;


@end
