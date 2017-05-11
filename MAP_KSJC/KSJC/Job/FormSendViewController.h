//
//  FormSendViewController.h
//  zzzf
//
//  Created by dist on 14-7-16.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysButton.h"
#import "ServiceProvider.h"

@protocol FormSendCompletedDelegate <NSObject>

-(void)formSendCompleted;

@end

@interface FormSendViewController : UIViewController<ServiceCallbackDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
- (IBAction)onBtnCancelTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *lblWaitInfo;
@property (weak, nonatomic) IBOutlet UITableView *activityTable;
@property (weak, nonatomic) IBOutlet SysButton *btnSend;
@property (nonatomic,retain) NSString *projectId;
@property (nonatomic,retain) id<FormSendCompletedDelegate> delegate;
- (IBAction)onBtnSendTap:(id)sender;

@end
