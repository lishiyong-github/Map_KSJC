//
//  NewDailyJobViewController.h
//  zzzf
//
//  Created by dist on 13-12-10.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"
#import "SysButton.h"

@protocol NewDailyJobDelegate;

@interface NewDailyJobViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ServiceCallbackDelegate>{
    NSArray *_pdaList;
    NSString *_historyDevice;
    NSString *_selectedDeviceId;
}
- (IBAction)onBtnRefreshTap:(id)sender;
- (IBAction)onBtnDeviceCancelTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnShowPadList;
@property (weak, nonatomic) IBOutlet SysButton *btnStartup;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblPadName;
@property (nonatomic,retain) id<NewDailyJobDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *deviceLoadingView;
@property (weak, nonatomic) IBOutlet UITableView *devicesTableView;
@property (weak, nonatomic) IBOutlet UILabel *nOrCtitleLabe;
@property (weak, nonatomic) IBOutlet UILabel *tipMessageLabl;


//用来接收点击某条的信息
@property (nonatomic,strong)NSMutableDictionary *theProject;
//装材料的数组
@property (nonatomic,strong)NSMutableArray *theMatrialA;
- (IBAction)onBtnSelectDeviceTap:(id)sender;

- (IBAction)onBtnStartTap:(id)sender;
//取消
- (IBAction)cancelTap:(id)sender;

@end


@protocol NewDailyJobDelegate <NSObject>

-(void)newDailyJobwithDict:(NSMutableDictionary *)dict andwithMaterialA:(NSMutableArray *)matrialA;

//- (void)newDailyJob;

@end