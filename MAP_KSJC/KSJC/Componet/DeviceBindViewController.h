//
//  DeviceBindViewController.h
//  zzzf
//
//  Created by dist on 14-4-2.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"
#import "SysButton.h"

@protocol DeviceBindViewDelegate <NSObject>

-(void)deviceDidBinded:(NSString *)deviceId deviceName:(NSString *)name;

@end

@interface DeviceBindViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ServiceCallbackDelegate>{
    NSArray *_pdaList;
    NSString *_selectedDeviceId;
    NSString *_selectedDeviceName;
    
}
- (IBAction)onBtnBindClick:(id)sender;
- (IBAction)onBtnCancelClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableDevices;
@property (weak, nonatomic) IBOutlet UIView *waitView;
@property (weak, nonatomic) IBOutlet SysButton *btnBind;
@property (weak, nonatomic) IBOutlet SysButton *btnCancel;
@property (nonatomic,retain) id<DeviceBindViewDelegate> delegate;

@end
