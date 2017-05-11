//
//  ProjectStorageViewController.h
//  zzzf
//
//  Created by mark on 14-2-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "SysButton.h"

@interface ProjectStorageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    NSString *_userProjectPath;
    NSArray *_searchKeys;
    NSString *_type;
}
- (IBAction)onBtnGoBackTap:(id)sender;

@property (retain,nonatomic) NSMutableArray *dataSource;
@property (retain,nonatomic) NSMutableDictionary *deleteDic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)onBtnEdit:(id)sender;
- (IBAction)onBtnConfirm:(id)sender;
- (IBAction)onBtnDelete:(id)sender;
@property (weak, nonatomic) IBOutlet SysButton *btnEdit;
@property (weak, nonatomic) IBOutlet SysButton *btnConfirm;
@property (weak, nonatomic) IBOutlet SysButton *btnDelete;
- (IBAction)onBtnBuniessTap:(id)sender;
@property (weak, nonatomic) IBOutlet SysButton *btnFyx;
@property (weak, nonatomic) IBOutlet SysButton *btnPhxm;
@property (weak, nonatomic) IBOutlet SysButton *btnWfxm;

@end
