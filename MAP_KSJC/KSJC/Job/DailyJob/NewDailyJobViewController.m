//
//  NewDailyJobViewController.m
//  zzzf
//
//  Created by dist on 13-12-10.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "NewDailyJobViewController.h"
#import "Global.h"
#import "MZFormSheetController.h"
#import "PDATableViewCell.h"

@interface NewDailyJobViewController ()

@end

static BOOL nibsRegistered = NO;

@implementation NewDailyJobViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    self.lblCurrentTime.text = [formatter stringFromDate:[NSDate date]];
    self.lblUserName.text = [Global currentUser].username;
    
    self.lblPadName.text = [Global currentUser].deviceName;
    
    /*
    _historyDevice = [[[Global currentUser] dailyJobCurrentInfo] objectForKey:@"device"];
    if ([_historyDevice isEqualToString:@""]) {
        self.lblPadName.text = @"N/A";
        self.btnStartup.backgroundColor = [UIColor grayColor];
        self.btnStartup.enabled = NO;
    }else{
        self.lblPadName.text = _historyDevice;
        _selectedDeviceId = [[[Global currentUser] dailyJobCurrentInfo] objectForKey:@"deviceId"];
        self.btnStartup.enabled = YES;
    }
     */
}

- (IBAction)onBtnSelectDeviceTap:(id)sender
{
    [UIView animateWithDuration:0.5 delay:.5 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.view1.frame= CGRectMake(-self.view1.frame.size.width, self.view1.frame.origin.y, self.view1.frame.size.width, self.view1.frame.size.height);
        self.view2.frame= CGRectMake(0, self.view2.frame.origin.y, self.view2.frame.size.width, self.view2.frame.size.height);
    } completion:nil];
    [self loadDeviceList];
}

/**
 *  看不懂
 */
-(void)loadDeviceList{
    return;
    ServiceProvider *padRequest = [ServiceProvider initWithDelegate:self];
    [padRequest getData:@"query" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"dailyjob-devicelist",@"cmd", nil]];
}

-(void)showPDATable{
    self.deviceLoadingView.hidden = YES;
    self.devicesTableView.hidden = NO;
    self.devicesTableView.delegate = self;
    self.devicesTableView.dataSource = self;
    [self.devicesTableView reloadData];
}

//开始巡查事件
- (IBAction)onBtnStartTap:(id)sender {
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
//    [self.delegate newDailyJob:[Global currentUser].deviceName deviceId:[Global currentUser].deviceNumber];
    
//把当前信息传出去
    [self.delegate newDailyJobwithDict:self.theProject andwithMaterialA:self.theMatrialA];
    
//    [self.delegate newDailyJob];
}

- (IBAction)cancelTap:(id)sender {
    
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
 
    
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _pdaList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier = @"PDACellIdentifier";
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"PDATableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
    }
    PDATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    NSUInteger row = [indexPath row];
    [cell setPDAInfo:[_pdaList objectAtIndex:row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    self.lblPadName.text = [[_pdaList objectAtIndex:row] objectForKey:@"DEVICENUMBER"];
    _selectedDeviceId = [[_pdaList objectAtIndex:row] objectForKey:@"DEVICENUMBER"];
    self.btnStartup.enabled = YES;
    self.btnStartup.backgroundColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1];
    [self backToFirstPanel];
}

-(void)backToFirstPanel{
    [UIView animateWithDuration:0.5 delay:.5 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.view1.frame= CGRectMake(0, self.view1.frame.origin.y, self.view1.frame.size.width, self.view1.frame.size.height);
        self.view2.frame= CGRectMake(self.view.frame.size.width, self.view2.frame.origin.y, self.view2.frame.size.width, self.view2.frame.size.height);
    } completion:nil];
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    self.btnShowPadList.hidden = NO;
    NSString *successfully = [data objectForKey:@"state"];
    if ([successfully isEqualToString:@"true"]) {
        _pdaList = [data objectForKey:@"DATA0"];
    }
    [self showPDATable];
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    [self showPDATable];
}

- (IBAction)onBtnRefreshTap:(id)sender {
    self.deviceLoadingView.hidden = NO;
    self.devicesTableView.hidden = YES;
    [self loadDeviceList];
}

- (IBAction)onBtnDeviceCancelTap:(id)sender {
    [self backToFirstPanel];
}

@end
