//
//  ModifyPwdViewController.m
//  zzzf
//
//  Created by dist on 13-12-31.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ModifyPwdViewController.h"

@interface ModifyPwdViewController ()

@end

@implementation ModifyPwdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtOldPassword.borderStyle = UITextBorderStyleLine;
    self.txtOldPassword.layer.borderWidth = 2;
    self.txtOldPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.txtOldPassword.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.txtNewPassword.borderStyle = UITextBorderStyleLine;
    self.txtNewPassword.layer.borderWidth = 2;
    self.txtNewPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.txtNewPassword.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.txtNewPassword2.borderStyle = UITextBorderStyleLine;
    self.txtNewPassword2.layer.borderWidth = 2;
    self.txtNewPassword2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.txtNewPassword2.layer.borderColor = [[UIColor grayColor] CGColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnModifyPwdTap:(id)sender {
    NSString *oldPwd=_txtOldPassword.text==nil?@"":_txtOldPassword.text;
    NSString *newPwd=_txtNewPassword.text==nil?@"":_txtNewPassword.text;
    NSString *newPwd2=_txtNewPassword2.text==nil?@"":_txtNewPassword2.text;
    if ([newPwd isEqualToString:newPwd2]) {
        _lblMessage.hidden=YES;
    }else{
        _lblMessage.hidden=NO;
        return;
    }
    
    ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
    NSString *type=@"smartplan";
    
    NSMutableDictionary *mutableDic=[NSMutableDictionary dictionaryWithCapacity:1];
    [mutableDic setObject:@"updatepwd" forKey:@"action"];
    [mutableDic setObject:@"肖冰" forKey:@"un"];
    [mutableDic setObject:oldPwd forKey:@"oldPwd"];
    [mutableDic setObject:newPwd forKey:@"newPwd"];
    
    [sp getString:type parameters:mutableDic];
}



-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    NSLog(@"0");
}
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    if ([[data lowercaseString] isEqualToString:@"true"]) {
        NSLog(@"ok");
        UIAlertView *successMessage = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码修改成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [successMessage show];
        [self.delegate close];
    }else{
        NSLog(@"error");
        UIAlertView *errorMessageBox = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"密码修改失败"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [errorMessageBox show];
    }
}
-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    NSLog(@"2");
}
@end
