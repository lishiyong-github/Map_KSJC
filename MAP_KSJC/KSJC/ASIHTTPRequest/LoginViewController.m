//
//  LoginViewController.m
//  zzzf
//
//  Created by zhangliang on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "LoginViewController.h"
#import "Global.h"

@interface LoginViewController ()<UIAlertViewDelegate>

@end

@implementation LoginViewController
@synthesize btnLogin,txtPassword,txtUsername;


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
//    //使用.swift
//    Testf *testf =[[Testf alloc] init];
//    [testf lLog];
//    
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(delayLoad) userInfo:nil repeats:NO];
    
    /*
    self.txtPassword.borderStyle = UITextBorderStyleLine;
    self.txtPassword.layer.borderWidth = 1;
    self.txtPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.txtPassword.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.txtUsername.borderStyle = UITextBorderStyleLine;
    self.txtUsername.layer.borderWidth = 1;
    self.txtUsername.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.txtUsername.layer.borderColor = [[UIColor grayColor] CGColor];
    */
    
	// Do any additional setup after loading the view.
    
    
    
    [self checkVersion];
}

- (void)checkVersion
{
    
    NSError *error;
    NSString *newVersion = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://58.246.138.178/AppStore/product/ksjc/version.txt"] encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"newVersion=%@",newVersion);
    if (newVersion!=nil||[newVersion isEqualToString:@""]) {
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSLog(@"currentVersion=%@",currentVersion);
        
        
        if(![newVersion isEqualToString:currentVersion])
        {
            if (![newVersion isEqualToString:currentVersion]) {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"新版本已发布" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"去更新", nil];
                
                [alert show];
            }
        }
    }
    
}


-(void)delayLoad{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path=[paths objectAtIndex:0];
    _loginInfoPath = [path stringByAppendingString:@"/login.plist"];
    NSMutableDictionary *loginInfo = [NSMutableDictionary dictionaryWithContentsOfFile:_loginInfoPath];
    if (nil!=loginInfo) {
        [Global initializeUserInfo:[loginInfo objectForKey:@"name"] userId:[loginInfo objectForKey:@"id"] org:[loginInfo objectForKey:@"org"] orgID:[loginInfo objectForKey:@"orgid"]];
        [self loginSuccessfully];
        return;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _usernamePath = [path stringByAppendingString:@"/username.txt"];
    NSString *localUn=[NSString stringWithContentsOfFile:_usernamePath encoding:NSUTF8StringEncoding error:nil];
    if (nil!=localUn) {
        self.txtUsername.text = localUn;
    }else{
        self.txtUsername.text = @"";
    }
    self.btnLogin.layer.cornerRadius = 8;
    self.loginView.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

-(void)dismissKeyboard {
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}


- (IBAction)onBtnoginTouchUp:(id)sender {
    //[self loginSuccessfully];
    //UIStoryboard *board=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
   
    NSString *un = txtUsername.text;
    
    if (un==nil || [un isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入用户名" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [message show];
        btnLogin.backgroundColor = [UIColor blueColor];
    }else{
        NSString *pwd = txtPassword.text;
        btnLogin.backgroundColor = [UIColor grayColor];
        if (nil==pwd) {
            pwd=@"";
        }
        btnLogin.enabled = NO;
        txtUsername.enabled = NO;
        txtPassword.enabled = NO;
        [un writeToFile:_usernamePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [btnLogin setTitle:@"正在登录..." forState:UIControlStateDisabled];
        ServiceProvider *service = [ServiceProvider initWithDelegate:self];
        service.tag=1;
//  68.2.239/KSYDService/ServiceProvider.ashx?type=smartplan&action=login&name=banyq&pwd=112233
        
        [service getData:@"smartplan" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"login",@"action",un,@"name",pwd,@"pwd", nil]];
    }
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1)
    {
        NSURL *url=[NSURL URLWithString:@"http://58.246.138.178/AppStore/product/ksjc"];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self onBtnoginTouchUp:textField];
    return YES;
}

-(void)loginSuccessfully{
//    if ([[Global currentUser].org isEqualToString:@"局领导"]) {
//        [self performSegueWithIdentifier:@"leaderSys" sender:self];
//    }else{
        [self performSegueWithIdentifier:@"manSegues" sender:self];
//    }
    btnLogin.enabled=txtPassword.enabled=txtUsername.enabled = YES;
    //写入日志
    
    /*
    ServiceProvider *logService=[ServiceProvider initWithDelegate:self];
    NSMutableDictionary *dicPara=[[NSMutableDictionary alloc] init];
    [dicPara setObject:@"newlog" forKey:@"action"];
    [dicPara setObject:@"L" forKey:@"LogType"];
    [dicPara setObject:txtUsername.text  forKey:@"UserName"];
    [dicPara setObject:@"Y" forKey:@"LoginStatus"];
    [logService getData:@"zf" parameters:dicPara];
     */
}

-(void)loginFault{
    btnLogin.enabled=txtPassword.enabled=txtUsername.enabled = YES;
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [message show];
    btnLogin.backgroundColor = [UIColor blueColor];
    self.btnLogin.enabled = YES;
    [self.btnLogin setTitle:@"登录" forState:UIControlStateNormal];
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
//    {
//        "success": "true",
//        "result": {
//            "id": 129,
//            "name": "王伟",
//            "org": "用地科",
//            "orgid": 126
//        }
//    }
    NSString *success = [data objectForKey:@"success"];
    NSDictionary *resultData =[data objectForKey:@"result"];

    if (provider.tag==1) {
        if ([success isEqualToString:@"true"]) {
            
            [Global initializeUserInfo:[resultData objectForKey:@"name"] userId:[[resultData objectForKey:@"id"] stringValue] org:[resultData objectForKey:@"org"] orgID:[resultData objectForKey:@"orgid"]];
            NSMutableDictionary *loginInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[resultData objectForKey:@"id"] stringValue],@"id",[resultData objectForKey:@"name"],@"name",[resultData objectForKey:@"org"],@"org",[resultData objectForKey:@"orgid"],@"orgid", nil];
            [loginInfo writeToFile:_loginInfoPath atomically:YES];
            [self loginSuccessfully];
        }else
            [self loginFault];
    }
}


-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    [self loginFault];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString *msg=@"hi";
    UIViewController *target = segue.destinationViewController;
    
    if ([target respondsToSelector:@selector(setData:)]) {
        [target setValue:msg forKey:@"data"];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView beginAnimations: nil context: nil];
    self.loginView.frame = CGRectMake(0, -100, 1024, 768);
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView beginAnimations: nil context: nil];
    self.loginView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

@end
