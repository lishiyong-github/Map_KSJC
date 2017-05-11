//
//  BusinessViewController.h
//  zzzf
//
//  Created by dist on 14-2-13.
//  Copyright (c) 2014年 dist. All rights reserved.
//监察业务

#import <UIKit/UIKit.h>
#import "SysButton.h"
#import "JobDetailView.h"
#import "ServiceProvider.h"
#import "SEFilterControl.h"
#import "NewWfProjectViewController.h"
#import "NewDailyJobViewController.h"
#import "DailyJobControlPanel.h"
#import "DailyJobNavigatorController.h"
#import "SifterViewController.h"


@interface BusinessViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ServiceCallbackDelegate,UISearchBarDelegate,JobDetailViewDelegate,NewProjectDelegate,NewDailyJobDelegate,DailyJobControlPanelDelegate,UIAlertViewDelegate,JobDetailViewDelegate>{
    JobDetailView *_jobDetailView;
    BOOL _loading;
    BOOL _loadAllFlag;
    NSArray *_searchKeys;
    NSString *_currentSearchKey;
    
    NSArray *_filesArray;//新添加
    
    NSString *_toOpenFileName;
    NSString *_toOpenFilePath;
    NSString *_toOpenFileExt;
    BOOL _materialFromLocal;
    NSString *_type;
    NSString *_currentIndex;
    SEFilterControl *_phFilterControl;
    int _phFlowState;
    
    SysButton *_btnNewProject;
    
    NSMutableArray *_cacheFyxList;
    NSMutableArray *_cacheHsList;
    NSMutableArray *_cacheGcList;
    NSMutableArray *_cacheSpywList;

    NSMutableDictionary *_cachePhgzList;
    NSMutableArray *_cacheWfajList;
    
    NSString *_cachSpywSavePath;
    NSString *_cacheFyxSavePath;
    NSString *_cacheHsSavePath;
    NSString *_cacheGcSavePath;

    NSString *_cachePhgzSavePath;
    NSString *_cacheWfajSavePath;
    
    ServiceProvider *_listProvider;
    NSString *_wfDefaultID;
    int _wfDefaultSelectIndex;
    
    NewDailyJobViewController *_newDailyJobViewController;
    DailyJobControlPanel *_jobControlPanel;
    
}
@property (nonatomic,strong)DailyJobNavigatorController *dailNav;
@property (nonatomic, retain) NSMutableArray *dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *dataActivityIndicator;
- (IBAction)categoryBtnClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *jobDetailContainer;
@property (weak, nonatomic) IBOutlet UIButton *categoryBtn;
//规划业务
@property (weak, nonatomic) IBOutlet SysButton *ghywBtn;
//验线
@property (weak, nonatomic) IBOutlet SysButton *btnFyx;
// 核实---  批后
@property (weak, nonatomic) IBOutlet SysButton *btnHshi;
//批后跟踪  -- 违法
@property (weak, nonatomic) IBOutlet SysButton *btnPhgz;
//工程
@property (weak, nonatomic) IBOutlet SysButton *btnProject;

//点击点击/放验线/批后/违法按钮执行的方法
- (IBAction)onBtnBuniessTap:(id)sender;

@end
