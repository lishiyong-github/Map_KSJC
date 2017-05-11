//
//  NewWfProjectViewController.h
//  zzzf
//
//  Created by dist on 14/9/17.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"

@protocol NewProjectDelegate <NSObject>

-(void)projectCreateSuccfully:(NSString *)projectId;

@end

@interface NewWfProjectViewController : UIViewController<ServiceCallbackDelegate>
@property (weak, nonatomic) IBOutlet UILabel *topTitle;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITextField *txtAy;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtProjectName;
@property (weak, nonatomic) IBOutlet UIView *waitVIew;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;

@property (nonatomic,retain) id<NewProjectDelegate> projectDelegate;

- (IBAction)onBtnCancelTap:(id)sender;
- (IBAction)onBtnCreateTap:(id)sender;


- (void)setTOpTitleWithStr:(NSString *)str tipLabeWithStr:(NSString *)str1 BtnTitleWithStr:(NSString *)title;

@end
