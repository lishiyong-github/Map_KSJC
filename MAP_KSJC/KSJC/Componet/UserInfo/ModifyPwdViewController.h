//
//  ModifyPwdViewController.h
//  zzzf
//
//  Created by dist on 13-12-31.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"

@protocol ModifyPwdDelegate  <NSObject>

-(void)close;

@end


@interface ModifyPwdViewController : UIViewController<ServiceCallbackDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPassword2;
@property (weak, nonatomic) IBOutlet UIButton *btnModifyPwd;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (retain,nonatomic) id<ModifyPwdDelegate> delegate;
- (IBAction)onBtnModifyPwdTap:(id)sender;

@end
