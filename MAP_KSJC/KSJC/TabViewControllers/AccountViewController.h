//
//  AccountViewController.h
//  zf
//
//  Created by dist on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModifyPwdViewController.h"
#import "SysButton.h"
#import "DeviceBindViewController.h"
#import "ServiceProvider.h"

@interface AccountViewController : UIViewController<NSURLConnectionDelegate,ModifyPwdDelegate,DeviceBindViewDelegate,ServiceCallbackDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblDept;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckUpdate;
@property (weak, nonatomic) IBOutlet SysButton *btnBindDevice;
@property (weak, nonatomic) IBOutlet SysButton *btnModifyPassword;
@property (weak, nonatomic) IBOutlet SysButton *btnExit;
- (IBAction)onBtnBindDeviceClick:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actCheckUpdate;
@property (strong, nonatomic) IBOutlet UITextField *txtOldPassword;
- (IBAction)btnLogoutTap:(id)sender;
- (IBAction)btnModifyPwdTap:(id)sender;
- (IBAction)onBtnCheckUpdateTap:(id)sender;

@end
