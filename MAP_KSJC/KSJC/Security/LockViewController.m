//
//  LockViewController.m
//  oneMap
//
//  Created by dist on 14-3-19.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "LockViewController.h"
#import "SvUDIDTools.h"
#import "Global.h"

@interface LockViewController ()

@end

@implementation LockViewController

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
    self.registerTextBox.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCode:(NSString *)code{
    _code = code;
    self.registerView.hidden = YES;
    self.lockView.hidden = YES;
    self.waitView.hidden = YES;
    if ([_code isEqualToString:@"0"]) {
        self.registerView.hidden = NO;
    }else if([_code isEqualToString:@"3"]){
        self.lockView.hidden = NO;
    }else if([_code isEqualToString:@"5"]){
        self.waitView.hidden = NO;
    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [ textField.text stringByReplacingCharactersInRange: range withString:string];
    if( [newText length]<= 35 ){
        return YES;
    }
    textField.text = [ newText substringToIndex:35 ];
    return NO;
    
}

- (IBAction)onBtnRegisterTap:(id)sender {
    self.registerButton.enabled = NO;
    self.registerTextBox.enabled = NO;
    self.registerButton.hidden = YES;
    self.registerAcitvityView.hidden = NO;
    NSString *deviceName = [UIDevice currentDevice].name;
    NSString *postDeviceName;
    if (deviceName.length>20) {
        postDeviceName = [deviceName substringToIndex:20];
    }else{
        postDeviceName = deviceName;
    }
    NSString *udid = [SvUDIDTools UDID];
    NSString *deviceType = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?@"1":@"2";
    
    ServiceProvider *registerProvider = [ServiceProvider initWithDelegate:self];
    [registerProvider getData:@"device" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys: @"register",@"action",postDeviceName,@"name",udid,@"code",self.registerTextBox.text,@"msg",deviceType,@"deviceType", nil]];
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    NSString *successfully = [data objectForKey:@"success"];
    if ([successfully isEqualToString:@"true"]) {
        [Global lock:@"5"];
    }else{
        NSString *msg = [data objectForKey:@"result"];
        if ([msg isEqualToString:@""]) {
            msg = @"注册失败";
        }
        [self registerFault:msg];
    }
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    [self registerFault:[NSString stringWithFormat:@"%@",error.localizedDescription]];
}

-(void)registerFault:(NSString *)msg{
    UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"注册失败" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [errorMsg show];
    self.registerTextBox.enabled = YES;
    self.registerButton.enabled = YES;
    self.registerAcitvityView.hidden = YES;
    self.registerButton.hidden = NO;
}
@end
