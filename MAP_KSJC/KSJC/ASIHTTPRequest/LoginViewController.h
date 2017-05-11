//
//  LoginViewController.h
//  zzzf
//
//  Created by zhangliang on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"

@interface LoginViewController : UIViewController<ServiceCallbackDelegate,UITextFieldDelegate>{
    NSString *_usernamePath;
    NSString *_loginInfoPath;
}

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIView *loginView;

- (IBAction)onBtnoginTouchUp:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@end
