//
//  UserInfoControlPanel.m
//  wenjiang
//
//  Created by zhangliang on 13-12-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "UserInfoControlPanel.h"
#import "Global.h"


@implementation UserInfoControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
    }
    return self;
}

-(void)createSubViews{
    
    UIView *unView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.frame.size.width,90)];
    unView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
    [self addSubview:unView];
    
    UIImageView *userLogo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 62, 62)];
    userLogo.image = [UIImage imageNamed:@"user_logo.png"];
    [unView addSubview:userLogo];
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 25, 200, 30)];
    userNameLabel.textColor = [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1];
    userNameLabel.text = [[Global currentUser] username];
    userNameLabel.backgroundColor = [UIColor clearColor];
    [userNameLabel setFont:[userNameLabel.font fontWithSize:20]];
    
    [unView addSubview:userNameLabel];
    
    
    UIView *pwdPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.frame.size.width-1,300)];
    pwdPanel.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    pwd1 = [[UITextField alloc] initWithFrame:CGRectMake(40, 30, self.frame.size.width-90, 40)];
    [pwd1 setSecureTextEntry:YES];
    pwd1.borderStyle = UITextBorderStyleNone;
    pwd1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    pwd1.placeholder = @"原始密码";
    UIView *line1 = [[UIView alloc ]initWithFrame:CGRectMake(40, pwd1.frame.origin.y+41, pwd1.frame.size.width, 1)];
    line1.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:220.0/255.0];
    
    [pwdPanel addSubview:pwd1];
    [pwdPanel addSubview:line1];
    
    pwd2 = [[UITextField alloc] initWithFrame:CGRectMake(40, 100, self.frame.size.width-80, 40)];
    [pwd2 setSecureTextEntry:YES];
    pwd2.borderStyle = UITextBorderStyleNone;
    pwd2.placeholder = @"新密码";
    pwd2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    UIView *line2 = [[UIView alloc ]initWithFrame:CGRectMake(40, pwd2.frame.origin.y+41, pwd2.frame.size.width, 1)];
    line2.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:220.0/255.0];
    
    [pwdPanel addSubview:pwd2];
    [pwdPanel addSubview:line2];
    
    pwd3 = [[UITextField alloc] initWithFrame:CGRectMake(40, 170, self.frame.size.width-80, 40)];
    [pwd3 setSecureTextEntry:YES];
    pwd3.borderStyle = UITextBorderStyleNone;
    pwd3.placeholder = @"再输入一次新密码";
    pwd3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    UIView *line3 = [[UIView alloc ]initWithFrame:CGRectMake(40, pwd3.frame.origin.y+41, pwd3.frame.size.width, 1)];
    line3.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:220.0/255.0];
    
    [pwdPanel addSubview:pwd3];
    [pwdPanel addSubview:line3];
    
    modifyPwdButton = [SysButton buttonWithType:UIButtonTypeCustom];
    [modifyPwdButton setBackgroundColor:[UIColor colorWithRed:61.0/255.0 green:136.0/255.0 blue:243.0/255.0 alpha:1]];
    modifyPwdButton.defaultBackground =[UIColor colorWithRed:61.0/255.0 green:136.0/255.0 blue:243.0/255.0 alpha:1];
    [modifyPwdButton setTitle:@"修改密码" forState:UIControlStateNormal];
    [modifyPwdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    modifyPwdButton.layer.cornerRadius = 5;
    modifyPwdButton.frame = CGRectMake(20, 240, 120, 40);
    [pwdPanel addSubview:modifyPwdButton];
    [modifyPwdButton addTarget:self action:@selector(modifyPwd) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:pwdPanel];
    
    SysButton *logoutButton = [SysButton buttonWithType:UIButtonTypeCustom];
    [logoutButton setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:142.0/255.0 blue:95.0/255.0 alpha:1]];
    logoutButton.defaultBackground = logoutButton.backgroundColor;
    
    [logoutButton setTitle:@"退出当前登录" forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutButton.layer.cornerRadius = 5;
    logoutButton.frame = CGRectMake(20, 700, 140, 40);
    
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:logoutButton];
}

-(void)logout{
    UIAlertView *confirmExit = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要退出系统吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出系统", nil];
    [confirmExit show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *loginInfoPath = [[paths objectAtIndex:0] stringByAppendingString:@"/login.plist"];
        [[NSFileManager defaultManager] removeItemAtPath:loginInfoPath error:nil];
        exit(0);
    }
}

-(void)modifyPwd{
    NSString *msg;
    if ([pwd1.text isEqualToString:@""]) {
        msg = @"请输入原始密码";
    }else if([pwd2.text isEqualToString:@""]){
        msg = @"请输入新密码";
    }else if(![pwd2.text isEqualToString:pwd3.text]){
        msg = @"两次密码不匹配";
    }
    if (msg==nil) {
        pwd1.enabled = pwd2.enabled = pwd3.enabled = modifyPwdButton.enabled = NO;
        
        [Global wait:@"正在修改密码"];
        ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
        NSString *type=@"smartplan";
        
        NSMutableDictionary *mutableDic=[NSMutableDictionary dictionaryWithCapacity:1];
        [mutableDic setObject:@"updatepwd" forKey:@"action"];
        [mutableDic setObject:[Global currentUser].username forKey:@"un"];
        [mutableDic setObject:pwd1.text forKey:@"oldPwd"];
        [mutableDic setObject:pwd2.text forKey:@"newPwd"];
        
        [sp getString:type parameters:mutableDic];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)modifyCompleted:(NSString *)msg{
    pwd1.enabled = pwd2.enabled = pwd3.enabled = modifyPwdButton.enabled = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    [self modifyCompleted:@"密码修改失败"];
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    [Global wait:nil];
    modifyPwdButton.enabled = YES;
    if ([[data lowercaseString] isEqualToString:@"true"]) {
        [self modifyCompleted:@"密码修改完成"];
        pwd1.text = @"";
        pwd2.text = @"";
        pwd3.text = @"";
    }else{
        UIAlertView *errorMessageBox = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"密码修改失败"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [errorMessageBox show];
    }
}

/*
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    NSString *successfully = [data objectForKey:@"success"];
    if ([successfully isEqualToString:@"true"]) {
        NSString *result = [data objectForKey:@"result"];
        if ([result isEqualToString:@"2"]) {
            [self modifyCompleted:@"密码错误"];
        }else if([result isEqualToString:@"0"]){
            [self modifyCompleted:@"系统检查到您的账户已经被移除，将在10后退出程序。"];
            [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(logout) userInfo:nil repeats:NO];
        }else if([result isEqualToString:@"1"]){
            [self modifyCompleted:@"密码修改完成"];
            pwd1.text = @"";
            pwd2.text = @"";
            pwd3.text = @"";
        }
    }else{
        [self modifyCompleted:@"修改密码失败"];
    }
}*/
@end
