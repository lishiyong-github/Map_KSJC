//
//  DeviceBindViewController.m
//  zzzf
//
//  Created by dist on 14-4-2.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DeviceBindViewController.h"
#import "PDATableViewCell.h"
#import "MZFormSheetController.h"
#import "Global.h"
@interface DeviceBindViewController ()

@end

@implementation DeviceBindViewController

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
    self.btnBind.hidden = YES;
    ServiceProvider *padRequest = [ServiceProvider initWithDelegate:self];
    [padRequest getData:@"query" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"dailyjob-devicelist",@"cmd", nil]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _pdaList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier = @"PDACellIdentifier";
    PDATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (nil==cell) {
        UINib *nib = [UINib nibWithNibName:@"PDATableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    NSUInteger row = [indexPath row];
    [cell setPDAInfo:[_pdaList objectAtIndex:row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    _selectedDeviceId = [[_pdaList objectAtIndex:row] objectForKey:@"DEVICENUMBER"];
    _selectedDeviceName = [[_pdaList objectAtIndex:row] objectForKey:@"DEVICENAME"];
    self.btnBind.hidden = NO;
}


- (IBAction)onBtnBindClick:(id)sender {
    [self.delegate deviceDidBinded:_selectedDeviceId deviceName:_selectedDeviceName];
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

- (IBAction)onBtnCancelClick:(id)sender {
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    
    NSString *successfully = [data objectForKey:@"state"];
    if ([successfully isEqualToString:@"true"]) {
        _pdaList = [data objectForKey:@"DATA0"];
        [self.tableDevices reloadData];
    }
    self.waitView.hidden = YES;
    self.tableDevices.hidden = NO;
    
}
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    self.waitView.hidden = YES;
    self.tableDevices.hidden = NO;
}
@end
