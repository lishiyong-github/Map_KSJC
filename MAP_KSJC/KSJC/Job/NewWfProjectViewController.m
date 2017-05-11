//
//  NewWfProjectViewController.m
//  zzzf
//
//  Created by dist on 14/9/17.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "NewWfProjectViewController.h"
#import "MZFormSheetController.h"
#import "Global.h"

@interface NewWfProjectViewController (){
    ServiceProvider *_dataService;
}

@end

@implementation NewWfProjectViewController

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
    // Do any additional setup after loading the view from its nib.

}


- (void)setTOpTitleWithStr:(NSString *)str tipLabeWithStr:(NSString *)str1 BtnTitleWithStr:(NSString *)title;
{
   
    [self.tipLabel setText:str1];
        [self.tipLabel setTextColor:[UIColor greenColor]];
        self.topTitle.text = title;
        [self.createBtn setTitle:str forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnCancelTap:(id)sender {
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

- (IBAction)onBtnCreateTap:(id)sender {
//    NSString *ay = self.txtAy.text;
//    NSString *name = self.txtProjectName.text;
//    NSString *address = self.txtAddress.text;
//    if ([ay isEqualToString:@""]) {
//        [self showMessage:@"请输入案由"];
//    }else if([name isEqualToString:@""]){
//        [self showMessage:@"请输入建设项目名称"];
//    }else if([address isEqualToString:@""]){
//        [self showMessage:@"请输入建设地址"];
//    }else{
    
//   KSYDService/ServiceProvider.ashx?type=smartplan&action=CreateProject&userid=&businessId=&preProjectId=&preProjectName=&preBusinessId=&preBuildArea=&preBuildAddress=
    
        _dataService = [ServiceProvider initWithDelegate:self];
        self.waitVIew.hidden = NO;
        [_dataService getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"CreateProject",@"action",[Global currentUser].userid,@"userid",@"563",@"businessId",@"",@"preProjectId",@"",@"preProjectName", @"",@"preBusinessId",@"",@"preBuildArea",@"",@"preBuildAddress",nil]];
        
//    }
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    NSString *successfully = [data objectForKey:@"success"];
    if ([successfully isEqualToString:@"true"]) {
        NSString *newProjectId = [data objectForKey:@"result"];
        [self.projectDelegate projectCreateSuccfully:newProjectId];
        [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
    }else{
        [self serviceCallback:provider requestFaild:nil];
    }
    
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    self.waitVIew.hidden = YES;
    [self showMessage:@"创建失败"];
}

-(void)showMessage:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

@end
