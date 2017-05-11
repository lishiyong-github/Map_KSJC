//
//  LockViewController.h
//  oneMap
//
//  Created by dist on 14-3-19.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysButton.h"
#import "ServiceProvider.h"

@interface LockViewController : UIViewController<ServiceCallbackDelegate,UITextFieldDelegate>

@property (nonatomic,retain) NSString *code;
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UITextField *registerTextBox;
@property (weak, nonatomic) IBOutlet SysButton *registerButton;
@property (weak, nonatomic) IBOutlet UIView *waitView;
@property (weak, nonatomic) IBOutlet UIView *lockView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *registerAcitvityView;
- (IBAction)onBtnRegisterTap:(id)sender;

@end
