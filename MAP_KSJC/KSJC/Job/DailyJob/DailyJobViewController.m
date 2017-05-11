//
//  DailyJobViewController.m
//  zzzf
//
//  Created by dist on 14-2-13.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DailyJobViewController.h"
#import "DailyJobReaderViewController.h"
#import "Global.h"

@interface DailyJobViewController ()

@end

@implementation DailyJobViewController

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
    self.title = @"监察记录";
    //
    _jobView = [DailyJobView createView];
    _jobView.frame = CGRectMake(0, 0,1024, 1100);
    _jobView.controller = self;
    [self.view addSubview:_jobView];
    
    //设置DailyJobViewDelegate代理
    _jobView.delegate = self;
    //初始化
    [_jobView initializeData];

    //监听新建巡查通知   +添加巡查 跳转通知巡查
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedNewJobView:) name:@"selectedNewJobView"object:nil];
}

//监听到跳转通知后执行的方法
-(void)selectedNewJobView:(NSNotification *)noty
{

       [self.navigationController popToRootViewControllerAnimated:YES];
    //让jobview (选中指定按钮)
    [_jobView changeSelectedButtonIndex:noty];
}

#pragma mark- ServiceCallbackDelegate 代理方法----ServiceProvider类
-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{

    //初始化
    [_jobView initializeData];
}

-(void) serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{

    //初始化
    [_jobView initializeData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DailyJobViewDelegate代理方法

-(void)openPhoto:(NSString *)name path:(NSString *)path fromLocal:(BOOL)fromLocal{
    [self.fileDelegate openFile:name path:path ext:@"jpg" isLocalFile:fromLocal];
}
-(void)openFiles:(NSArray *)files at:(int)index
{
    [self.fileDelegate allFiles:files at:index];
}
//点击某个日期执行的代理方法
-(void)openJob:(NSString *)jobTime{
    DailyJobReaderViewController *djvc = [[DailyJobReaderViewController alloc] initWithNibName:@"DailyJobReaderViewController" bundle:nil];
    djvc.fileDelegate = self.fileDelegate;
    [self.navigationController pushViewController:djvc animated:YES];
//    [djvc loadJob:jobTime];
}

//代理方法
- (void)openDayOfLog:(NSString *)logTime
{

    _dayLogVC =[[DayLogsVC alloc] init];
    _dayLogVC.dayTime = logTime;
    
    _dayLogVC.delegate = self;
    
    [self.navigationController pushViewController:_dayLogVC animated:YES];
    
    

}
#pragma mark - DayLogsVCDelegate
-(void)showLogsOfdayWithDayTime:(NSString *)logTime withDict:(NSDictionary *)dict
{
    DailyJobReaderViewController *djvc = [[DailyJobReaderViewController alloc] initWithNibName:@"DailyJobReaderViewController" bundle:nil];
        djvc.fileDelegate = self.fileDelegate;
    [djvc loadbaseProjectWithpid:[dict objectForKey:@"pid"] andTime:[dict objectForKey:@"jcsj"]];
        [self.navigationController pushViewController:djvc animated:YES];

    
    
//        [djvc loadJob:logTime withDict:dict];


}



-(void)mapShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext
{
    [self.fileDelegate openFile:name path:path ext:ext isLocalFile:[ext boolValue]];
}
-(void)mapShouldShowFiles:(NSArray *)files at:(int)index
{
    [self.fileDelegate allFiles:files at:index];
}

#pragma mark- UIAlertViewDelegate代理方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        UITabBarController *tabController = (UITabBarController *)self.parentViewController.parentViewController;
        tabController.selectedIndex = 5;
    }
}

@end
