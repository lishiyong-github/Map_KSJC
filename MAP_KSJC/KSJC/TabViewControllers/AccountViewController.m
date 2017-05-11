//
//  AccountViewController.m
//  zf
//
//  Created by dist on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "AccountViewController.h"
#import "Global.h"
#import "MZFormSheetController.h"
#import "ModifyPwdViewController.h"


@interface AccountViewController ()
{
    MZFormSheetController *formSheet;
}
@end

@implementation AccountViewController

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
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.lblVersion.text = [NSString stringWithFormat:@"当前版本:%@",currentVersion];
    self.lblUserName.text =[Global currentUser].username;
    self.lblDept.text = [Global currentUser].org;
    self.btnModifyPassword.layer.cornerRadius = 5;
    self.btnExit.layer.cornerRadius = 5;
    
    if(nil!=[Global currentUser].deviceName){
        [self.btnBindDevice setTitle:[NSString stringWithFormat:@"设备：%@",[Global currentUser].deviceName ] forState:UIControlStateNormal];
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    NSString *mayBind = [[Global currentUser].properties objectForKey:@"toBindDevice"];
    if (nil!=mayBind && [mayBind isEqualToString:@"yes"]) {
        [self showBindDeviceView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLogoutTap:(id)sender {
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


- (IBAction)btnModifyPwdTap:(id)sender {
    
    NSString *oldPwd=self.txtOldPassword.text;
    NSString *newPwd=self.txtNewPassword.text;
    NSString *newPwd2=self.txtNewPassword2.text;
    if (![newPwd isEqualToString:newPwd2]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"两次密码输入不一致" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
//    else if([newPwd isEqualToString:@""]){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"新密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//        return;
//    }
    self.btnModifyPassword.enabled = NO;
    [Global wait:@"正在修改密码"];
    ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
    NSString *type=@"smartplan";
//   type=smartplan&action=modifypwd&userID=181&sourPwd=111111&newPwd= 
    NSMutableDictionary *mutableDic=[NSMutableDictionary dictionaryWithCapacity:1];
    [mutableDic setObject:@"modifypwd" forKey:@"action"];
    [mutableDic setObject:[Global currentUser].userid forKey:@"userID"];
    [mutableDic setObject:oldPwd forKey:@"sourPwd"];
    [mutableDic setObject:newPwd forKey:@"newPwd"];
    
    [sp getString:type parameters:mutableDic];
    
    /*
    ModifyPwdViewController *mpvController = [[ModifyPwdViewController alloc] initWithNibName:@"ModifyPwdViewController" bundle:nil];
    mpvController.delegate=self;
    formSheet = [[MZFormSheetController alloc] initWithViewController:mpvController];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    //formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 8.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 80;
    formSheet.presentedFormSheetSize = CGSizeMake(310, 400);
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
     */
}

- (IBAction)onBtnCheckUpdateTap:(id)sender {
    
    self.btnCheckUpdate.hidden = YES;
    self.actCheckUpdate.hidden = NO;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@version.txt?r=%d",[Global serviceUrl],arc4random()]]];
    request.timeoutInterval = 10;
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    request = nil;
}

-(void)checkUpdateFail{
    self.btnCheckUpdate.hidden = NO;
    self.actCheckUpdate.hidden = YES;
    self.btnCheckUpdate.enabled = NO;
    
    [self.btnCheckUpdate setTitle:@"已经是最新" forState:UIControlStateNormal];
}

-(void)close{
    [formSheet dismissAnimated:NO completionHandler:nil];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self checkUpdateFail];
    //if ([response expectedContentLength]==0) {
    //    [self networkError];
    //}else{
    //    [self networkOk];
    //}
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self checkUpdateFail];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self checkUpdateFail];
    return;
    NSString *newVersion = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    if (![newVersion isEqualToString:currentVersion]) {
        UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新版本可更新，是否更新到最新版本？" delegate:nil cancelButtonTitle:@"不更新" otherButtonTitles:@"更新", nil];
        [updateAlert show];
    }
}

-(void) showBindDeviceView{
    [[Global currentUser].properties setObject:@"no" forKey:@"toBindDevice"];
    DeviceBindViewController *dbv=[[DeviceBindViewController alloc] initWithNibName:@"DeviceBindViewController" bundle:nil];
    MZFormSheetController *fs =[[MZFormSheetController alloc] initWithViewController:dbv];
    fs.shouldDismissOnBackgroundViewTap = YES;
    fs.cornerRadius = 8.0;
    fs.portraitTopInset = 6.0;
    fs.landscapeTopInset = 80;
    fs.presentedFormSheetSize = CGSizeMake(280, 315);
    dbv.delegate = self;
    [fs presentAnimated:YES completionHandler:nil];
    
}

NSString *_mayBindDeviceId;
NSString *_mayBindDeviceName;
-(void)deviceDidBinded:(NSString *)deviceId deviceName:(NSString *)name{
    _mayBindDeviceId = deviceId;
    _mayBindDeviceName = name;
    [Global wait:@"正在绑定..."];
    ServiceProvider *bindService = [ServiceProvider initWithDelegate:self];
    bindService.tag=1;
    [bindService getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"binddevice",@"action",[Global currentUser].userid,@"userid",deviceId,@"device",nil]];
}

- (IBAction)onBtnBindDeviceClick:(id)sender {
    [self showBindDeviceView];
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    
        
        if([[data objectForKey:@"status"] isEqualToString:@"true"]){
            [Global currentUser].deviceNumber = _mayBindDeviceId;
            [Global currentUser].deviceName = _mayBindDeviceName;
            [self.btnBindDevice setTitle:[NSString stringWithFormat:@"设备：%@",_mayBindDeviceName] forState:UIControlStateNormal];
        }else{
            [self serviceCallback:nil requestFaild:nil];
        }
        
    
    [Global wait:nil];
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    [Global wait:nil];
    if (provider.tag==1) {
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"提示" message:@"绑定失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [msg show];
    }else{
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码修改失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [msg show];
        self.btnModifyPassword.enabled = YES;
    }
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    [Global wait:nil];
    self.btnModifyPassword.enabled = YES;
    if ([[data lowercaseString] isEqualToString:@"true"]) {
        NSLog(@"ok");
        UIAlertView *successMessage = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码修改成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [successMessage show];
        self.txtNewPassword.text=@"";
        self.txtNewPassword2.text=@"";
        self.txtOldPassword.text=@"";
    }else{
        NSLog(@"error");
        UIAlertView *errorMessageBox = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"密码修改失败"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [errorMessageBox show];
    }
}

@end
