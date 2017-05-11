//
//  FormSendViewController.m
//  zzzf
//
//  Created by dist on 14-7-16.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "FormSendViewController.h"
#import "ServiceProvider.h"
#import "MZFormSheetController.h"
#import "Global.h"

@interface FormSendViewController (){
    NSMutableDictionary *_activitySource;
    NSString *_selectedUserId;
    NSString *_selectedActivity;
}

@end

@implementation FormSendViewController

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
    
    ServiceProvider *activityService = [ServiceProvider initWithDelegate:self];
    activityService.tag = 0;
    [activityService getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"sendlist",@"action",self.projectId,@"project",@"send",@"sendType",[Global currentUser].userid,@"user", nil]];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnSendTap:(id)sender {
    ServiceProvider *sendService = [ServiceProvider initWithDelegate:self];
    sendService.tag = 1;
    [sendService getString:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"send",@"action",self.projectId,@"project",[Global currentUser].userid,@"fromUser",_selectedUserId,@"toUser",_selectedActivity,@"activityID",@"send",@"sendType", nil]];
    self.btnCancel.enabled = NO;
    self.loadingView.hidden = NO;
    self.lblWaitInfo.text = @"正在发送";
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
        if ([@"true" isEqualToString:[data objectForKey:@"success"]]) {
            NSArray *rs = [data objectForKey:@"result"];
            _activitySource = [NSMutableDictionary dictionaryWithCapacity:10];
            for(NSDictionary *item in rs){
                NSString *name = [item objectForKey:@"activityName"];
                NSMutableArray *category = [_activitySource objectForKey:name];
                if (nil==category) {
                    category = [NSMutableArray arrayWithCapacity:10];
                    [_activitySource setObject:category forKey:name];
                }
                NSDictionary *val = [NSDictionary dictionaryWithObjectsAndKeys:[item objectForKey:@"activityID"],@"activityID",[item objectForKey:@"userName"],@"userName",[item objectForKey:@"userId"],@"userId", nil];
                [category addObject:val];
            }
            self.activityTable.dataSource = self;
            self.activityTable.delegate = self;
            [self.activityTable reloadData];
            self.loadingView.hidden = YES;
        }else{
            [self showError:1];
        }
    
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    if ([data isEqual:@"1"]) {
        [self.delegate formSendCompleted];
        [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
    }else{
        
        self.btnCancel.enabled = YES;
        [self showError:2];
    }
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    if (provider.tag==0) {
        [self showError:1];
    }else{
        [self showError:2];
    }
}

-(void)showError:(int)t{
    self.loadingView.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:t==1?@"环节加载失败":@"发送失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSArray *allKeys = [_activitySource allKeys];
    NSArray *d = [_activitySource objectForKey:[allKeys objectAtIndex:indexPath.section]];
    NSDictionary *item = [d objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"userName"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *allKeys = [_activitySource allKeys];
    NSArray *d = [_activitySource objectForKey:[allKeys objectAtIndex:section]];
    return [d count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_activitySource count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[_activitySource allKeys] objectAtIndex:section];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.btnSend.enabled = YES;
    [self.btnSend setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    NSArray *allKeys = [_activitySource allKeys];
    NSArray *d = [_activitySource objectForKey:[allKeys objectAtIndex:indexPath.section]];
    NSDictionary *item = [d objectAtIndex:indexPath.row];
    _selectedUserId = [item objectForKey:@"userId"];
    _selectedActivity = [item objectForKey:@"activityID"];
}

- (IBAction)onBtnCancelTap:(id)sender {
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

@end
