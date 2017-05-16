//
//  BusinessViewController.m
//  zzzf
//
//  Created by dist on 14-2-13.
//  Copyright (c) 2014年 dist. All rights reserved.
// 监察业务

#import "BusinessViewController.h"
#import "ProjectCell.h"
#import "NewWfProjectViewController.h"
#import "MZFormSheetController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Global.h"
#import "MJRefresh.h"

@interface BusinessViewController ()
{
    MZFormSheetController *_formSheet;
}
@property (nonatomic,strong)UIViewController *dailyJobViewController;
@property(nonatomic,assign) NSInteger selectedAddBtnIndex;
@property(nonatomic,assign)NewWfProjectViewController *nwpvc;
@property (nonatomic,assign)NSInteger selectedIndex;
@property (nonatomic,assign)NSInteger selIndex;
@property (nonatomic,strong)NSString *pagesize;
@property (nonatomic,strong) NSArray *leftSearchArray;
@end

@implementation BusinessViewController

static BOOL nibsRegistered = NO;


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
    _pagesize = @"100";
    if (_newDailyJobViewController == nil) {
        //新建巡查界面
        _newDailyJobViewController =[[NewDailyJobViewController alloc] initWithNibName:@"NewDailyJobViewController" bundle:nil];
        
        //设置NewDailyJobDelegate代理
        _newDailyJobViewController.delegate = self;
    }
    //..下拉刷新
    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [self loadAllData];
    }];
    //..上拉刷新
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _pagesize = [NSString stringWithFormat:@"%d",[_pagesize intValue] + 30];
        [self loadAllData];
    }];
    _tableView.rowHeight = 112;
//    [_jobControlPanel initialzePanel];

    //搜索对象
    _searchKeys = [NSArray arrayWithObjects:@"批后过程管理",@"审批业务", nil];

//                   @"验线",@"核实",@"工程", nil];
    self.dataSource = [[NSMutableArray alloc] initWithCapacity:20];
    
    //项目详情界面
    _jobDetailView = [JobDetailView createView];
    //初始化JobDetailView
    [_jobDetailView initializedView];
    _jobDetailView.delegate =self;
    _jobDetailView.frame = CGRectMake(0, 0, self.jobDetailContainer.frame.size.width, self.jobDetailContainer.frame.size.height);
    _jobDetailView.delegate = self;
    [self.jobDetailContainer addSubview:_jobDetailView];
    
    
    //新增违法事项
    _btnNewProject = [SysButton buttonWithType:UIButtonTypeCustom];
    _btnNewProject.frame = CGRectMake(0, 80, 300, 70);
    _btnNewProject.defaultBackground = [UIColor groupTableViewBackgroundColor];
    _btnNewProject.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_btnNewProject setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnNewProject.hidden = YES;
    [_btnNewProject setTitle:@"+ 新建" forState:UIControlStateNormal];
    [_btnNewProject addTarget:self action:@selector(newWfProject) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnNewProject];
    
    //放验线保存路径
    _cacheFyxSavePath = [NSString stringWithFormat:@"%@/fyx.plist",[[Global currentUser] userProjectPath]];
    //批后跟踪保存路径
    _cachePhgzSavePath = [NSString stringWithFormat:@"%@/phgz.archive",[[Global currentUser] userProjectPath]];
    
    //审批业务
    _cachSpywSavePath=[NSString stringWithFormat:@"%@/spyw.plist",[[Global currentUser] userProjectPath]];
    //核实
    _cacheHsSavePath=[NSString stringWithFormat:@"%@/hs.plist",[[Global currentUser] userProjectPath]];
    //工程
    _cacheGcSavePath=[NSString stringWithFormat:@"%@/gc.plist",[[Global currentUser] userProjectPath]];
    //违法案件保存路径
    _cacheWfajSavePath = [NSString stringWithFormat:@"%@/wfaj.archive",[[Global currentUser] userProjectPath]];
    
    
    //放验线列表
    _cacheFyxList = [NSMutableArray arrayWithContentsOfFile:_cacheFyxSavePath];
    //批后跟踪列表
    _cachePhgzList = [NSMutableDictionary dictionaryWithContentsOfFile:_cachePhgzSavePath];
    //审批业务
    _cacheSpywList = [NSMutableArray arrayWithContentsOfFile:_cachSpywSavePath];
    //核实
    _cacheHsList = [NSMutableArray arrayWithContentsOfFile:_cacheHsSavePath];
    //工程
    _cacheGcList = [NSMutableArray arrayWithContentsOfFile:_cacheGcSavePath];
    //违法案件列表
    _cacheWfajList = [NSMutableArray arrayWithContentsOfFile:_cacheWfajSavePath];
    
    
    
    //默认点击批后跟踪
    [self onBtnBuniessTap:self.btnPhgz];
    
    UIImageView *largeImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 800, 700)];
    [self.view addSubview:largeImg];
    self.leftSearchArray = @[@"所有项目",@"我的项目",@"我的双随机"];
    [self configPhgzButton];
}

/******************* 昆山需求更改 2017/5/8 *******************/
- (void)configPhgzButton
{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(110, 3, 20, 30)];
    [button setImage:[UIImage imageNamed:@"xiasanjiao"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(filterByPhgz) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPhgz setTitle:self.leftSearchArray.firstObject forState:UIControlStateNormal];
    [self.btnPhgz addSubview:button];
}

/******************* 筛选批后跟踪 *******************/
- (void)filterByPhgz
{
    [self showPhgzList];
    
    NSArray *array =@[@"所有项目",@"我的项目",@"我的双随机"];
    SifterViewController *siftVC = [[SifterViewController alloc] initWithFilterArray:array];
    siftVC.siftBlock = ^(NSString *title) {
        [self.btnPhgz setTitle:title forState:UIControlStateNormal];
        _searchKeys = [NSArray arrayWithObjects:@"批后跟踪",title, nil];
        //        [self showFyxList];
        [self onBtnBuniessTap:self.btnPhgz];
    };
    
    [self presentViewController:siftVC animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击放验线/批后跟踪/违法案件按钮[会加载数据]
- (IBAction)onBtnBuniessTap:(id)sender {
    UIButton *btn = (UIButton *)sender;
    _selectedIndex = 0;
//    if (btn.selected) {
//        return;
//    }
    //点击按钮设置为选中
    btn.selected = YES;
    //保存 @"fyx",@"phgz",@"wf"(搜索key)
    _currentSearchKey = [_searchKeys objectAtIndex:btn.tag];
    //默认搜索内容为空
    self.searchBar.text = @"";
    _selIndex = btn.tag;
    if (btn.tag==0) {//批后跟踪
        //设置按钮状态(_phFlowState)
        [self showPhgzList];
        _type=@"Wfxm";

    }else if(btn.tag==1){//验线
       
        //设置按钮状态(_phFlowState)//_phFlowState为(@"基础", @"转换", @"标准", @"封顶", @"外立面"选中那个)
        [self showFyxList];
        _type=@"Fyx";
    }else if(btn.tag==2){//核实
        
        //设置按钮状态(_phFlowState)
        [self showHshixmList];
        _btnNewProject.hidden = YES;
        _type=@"Phxm";
    }
    else if(btn.tag==3){//工程
         [self showProjectxmList];
        _btnNewProject.hidden = YES;
        _type=@"Phxm";
        
           }
    _wfDefaultID = nil;
    _phFilterControl.hidden = YES;
    [self loadAllData];
    
}

//显示放验线选中状态
-(void)showFyxList{
    _phFlowState = -1;
//    self.btnFyx.selected = YES;
    self.ghywBtn.selected = YES;
    //取消批后和违法的选中
    self.btnHshi.selected = self.btnPhgz.selected =self.btnProject.selected= NO;
}
//核实选中状态
-(void)showHshixmList{
    _phFlowState = -1;
    self.btnHshi.selected = YES;
    //取消放验线和违法的选中
    self.btnFyx.selected = self.btnPhgz.selected =self.btnProject.selected= NO;
//    _jobDetailView.formWebView.frame = CGRectMake(0, 100, 493, 450);

}

//显示批后跟踪选中状态
-(void)showProjectxmList{
    _phFlowState = -1;
    self.btnProject.selected = YES;
    //取消放验线和违法的选中
    self.btnFyx.selected = self.btnPhgz.selected =self.btnHshi.selected= NO;
//    _jobDetailView.formWebView.frame = CGRectMake(0, 50, 1024, 300);
    
}

//违法案件选中状态
-(void)showPhgzList{
    _phFlowState = -1;
    self.btnPhgz.selected = YES;
    self.ghywBtn.selected = NO;
    //取消放验线和批后的选中
    self.btnFyx.selected = self.btnHshi.selected =self.btnProject.selected= NO;
}

//显示批后跟踪状态栏,需要将tableView下移
-(void)showPhFilter{

    _phFlowState = -1;
     self.btnHshi.selected = YES;
    //取消放验线和批后的选中
    self.btnPhgz.selected = self.btnHshi.selected=self.btnProject.selected = NO;
    
}

//隐藏批跟踪状态,需要将tableView上移
-(void)hidePhFilter{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        _phFilterControl.alpha = 0;
    } completion:^(BOOL finished){
         _phFilterControl.hidden = YES;
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
           self.tableView.frame = CGRectMake(0, 79, 300, 630);
        } completion:nil];
    }];
}


//显示新建违法案件需要将tableView下移
-(void)showNewProjectButton{
    if (!_btnNewProject.hidden) {
        return;
    }
    _btnNewProject.alpha = 0;
    _btnNewProject.hidden = NO;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.tableView.frame = CGRectMake(0, 150, 300, 555);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            _btnNewProject.alpha = 1;
        } completion:nil];
    }];
}
//隐藏新建违法按钮就要将tableview上移
-(void)hideNewProjectButton{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        _btnNewProject.alpha = 0;
    } completion:^(BOOL finished){
        _btnNewProject.hidden = YES;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            self.tableView.frame = CGRectMake(0, 79, 300, 630);
        } completion:nil];
    }];
}

#pragma mark- tableView 代理方法

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier = @"ProjectCellIdentifier";
    
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"ProjectCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
    }
    
    ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    NSUInteger row = [indexPath row];
    if (self.dataSource==nil || row>=self.dataSource.count) {
        return cell;
    }
    
    NSMutableDictionary *project=[self.dataSource objectAtIndex:row];
    cell.project = project;
    if([_currentSearchKey isEqualToString:@"审批业务"])
    {
    cell.lblDateTime.text = [project objectForKey:@"business"];
    }
    // 新建续传事件
    cell.btnNewJob.tag = indexPath.row+100;
    
    [cell.btnNewJob addTarget:self action:@selector(onBtnCreateNewJobTap:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource.count) {
        NSMutableDictionary *project=[self.dataSource objectAtIndex:indexPath.row];
        if ([[project objectForKey:@"isDoubleRamdom"] isEqualToString:@"是"]) {
            return 112;
        }
    }
    return 80;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_loading) {
        return 0;
    }
    return self.dataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_loading || nil==self.dataSource || self.dataSource.count<=indexPath.row)
        return;
    
    NSMutableDictionary *p = [self.dataSource objectAtIndex:indexPath.row];
    
    //NSLog(@"----%@",p.name);
    //点击cell,获取加载cell对应的数据,显示在_jobDetailView上

    _selectedIndex = indexPath.row;
    if(_selIndex ==1)
    {
    _jobDetailView.isSP = YES;
    [_jobDetailView setReadonly:YES];
        _jobDetailView.btnBackToMap.hidden = YES;

    }
    else
    {
    
        _jobDetailView.isSP = NO;
        [_jobDetailView setReadonly:NO];


    }
    _jobDetailView.btnBackToMap.hidden =YES;

    //当前选中的type
    [_jobDetailView loadProject:p typeName:_type];
    _jobDetailView.hidden=NO;
}


//点击cell 新建巡查
- (void)onBtnCreateNewJobTap:(SysButton *)btn
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否新建批后跟踪?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"新建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // 续办
//        [self continueDeliver:btn.tag];
        [self continueDeliver:btn.tag withBussinessType:@"Wfxm"];

        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 续传
-(void)continueDeliver:(NSInteger)tag withBussinessType:(NSString *)type
{
    _type = type;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *infoDic = _dataSource[tag-100];
//8.2.239/KSYDService/ServiceProvider.ashx?type=smartplan&action=CreateProject&userid=&businessId=&preProjectId=&preProjectName=&preBusinessId=&preBuildArea=&preBuildAddress=
//    preProjectId：续办项目的pid
//    preProjectName：续办项目的名称
//    preBusinessId：续办项目的业务ID
//    preBuildArea：续办项目的区域
//    preBuildAddress：续办项目的地址

    NSDictionary *parameters = @{@"type":@"smartplan",@"action":@"CreateProject",@"userid":[[Global currentUser] userid],@"businessId":@"563",@"preProjectId":[infoDic objectForKey:@"projectId"],@"preProjectName":[infoDic objectForKey:@"projectName"],@"preBusinessId":@"",@"preBuildArea":[infoDic objectForKey:@"xzqy"],@"preBuildAddress":[infoDic objectForKey:@"address"]};
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    
    NSLog(@"续办巡查%@",requestAddress);
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = (NSDictionary *)responseObject;
        if ([[dic objectForKey:@"success"] isEqualToString:@"true"]) {
            _currentSearchKey = @"批后过程管理";
            [self showPhgzList];
            [self loadAllData];
        }
        else
        {
        
        
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error::%@",error);
    }];
    
}

//#pragma  mark- NewDailyJobDelegate 代理方法
//// /////点击弹出框(开始巡查)
-(void)creatDailyJobwithDict:(NSMutableDictionary *)theproject andwithMaterialA:(NSMutableArray *)materialA {
    
    //记录是否新建巡查的状态 & 是哪个项目的巡查
    [defaults setBool:YES forKey:@"isHaveNewJob"];
    [defaults setInteger:_selectedAddBtnIndex forKey:@"selectedAddBtnIndex"];
    [defaults synchronize];
    
    NSDictionary *deviceDic = @{@"projectDict":theproject,@"projectMaterialA":materialA};
    
    
    /////////////////////////////////////
    //从在建到日常巡查   通过通知调整
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedNewJobView" object:deviceDic];

    self.tabBarController.selectedIndex = 0;

    //显示巡查详情界面
   // [self showJobView];
    
    

}

#pragma mark -- alertView代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //巡查已建提示
    if (alertView.tag == 100)
    {
        
    }
    //用户未绑定提示
    else if (alertView.tag == 9)
    {
        
    }
}

//显示正在巡查的界面(巡查详情)
-(void)showJobView{
    if (nil==_jobControlPanel) {
        _jobControlPanel = [DailyJobControlPanel createView];
        _jobControlPanel.frame = CGRectMake(0, 52, 1024, 664);
        _jobControlPanel.delegate = self;

        [self.view addSubview:_jobControlPanel];
        [_jobControlPanel initialzePanel];
        //更新巡查job
        [self refershJob];
                    }
//    _dailNav = [[DailyJobNavigatorController alloc] init];
//    [self.navigationController pushViewController:_dailNav animated:YES];

//    //详情选中
//    self.btnInfo.selected = YES;
//    //日期取消选中
//    self.btnCalendar.selected = NO;
//
//    //隐藏日历view
//    _calendarView.hidden = YES;
//    //显示详情view
//    _jobControlPanel.hidden = NO;
}



//收到数据后执行的方法
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    [_tableView.header endRefreshing];
    [_tableView.footer endRefreshing];
    //显示tableView
    self.tableView.hidden = NO;
    //隐藏菊花
    self.dataActivityIndicator.hidden = YES;
    //加载状态取消 请求返回设置为no
    _loading = NO;
    //默认选中第一个并加载第一个
    _wfDefaultSelectIndex = 0;
    if ([[data objectForKey:@"success"] isEqualToString:@"true"]) {
        //int dataCount = [[data objectForKey:@"count"] intValue];
        //[_pageInfo calcPageInfo:dataCount];
        
        NSMutableArray *rs = [data objectForKey:@"result"];
        int i=0;
        for (NSDictionary *item in rs) {
            
            //ProjectInfo *project = [[ProjectInfo alloc] initWithProject:[item objectForKey:@"name"] theId:[item objectForKey:@"id"] theCode:[item objectForKey:@"code"] theAddress:[item objectForKey:@"address"] theTime:[item objectForKey:@"time"]];
            //[self.dataSource addObject:project];
            //已经加载过某行数据后,更新选中行
            if (nil!=_wfDefaultID) {
                NSString *pid = [item objectForKey:@"id"];
                if ([pid isEqualToString:_wfDefaultID]) {
                    _wfDefaultSelectIndex = i;
                }
            }
            [self.dataSource addObject:[NSMutableDictionary dictionaryWithDictionary:item]];
            i++;
        }
        _wfDefaultSelectIndex = _selectedIndex;
        
        //加载数据
        [self.tableView reloadData];
    }

    //显示某行详情数据(加载表单+照片)----刚请求数据回来,默认加载第一行数据
    if(_dataSource.count>0)
    {
        [self showProjectAt:0];

//    [self showProjectAt:_wfDefaultSelectIndex];
    }
    //保存到缓存中
    [self saveListCache];
    
    //判断当前选中哪个按钮
    if (self.btnHshi.selected) {
//        //显示批后跟踪条
//        [self showPhFilter];
        [self showHshixmList];
        [self hideNewProjectButton];

    }else if(self.btnPhgz.selected  ){
        //显示违法案件条
        [self showNewProjectButton];
        //[self hidePhFilter];
        _phFilterControl.hidden = YES;
    }else if(self.btnProject.selected)
    {
        [self  showProjectxmList];
        [self hideNewProjectButton];

    }else
        
    {
        //隐藏批后跟踪和添加违法按钮按钮
        [self hidePhFilter];
        [self hideNewProjectButton];
    }
    
}

//显示cell某行详情数据
-(void)showProjectAt:(int)i{
    //有数据
    if (nil!=self.dataSource && self.dataSource.count>0) {
        NSIndexPath *ip=[NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionBottom];
        NSMutableDictionary *p = [self.dataSource objectAtIndex:i];
        if(_selIndex == 1)
        {
        _jobDetailView.isSP = YES;
            [_jobDetailView setReadonly:YES];
            _jobDetailView.btnBackToMap.hidden = YES;


        }else
        {
        
            _jobDetailView.isSP = NO;
            [_jobDetailView setReadonly:NO];


        }
//        _type=@"Fyx";放验线/ph etc
        //JobDetailView的方法---加载数据
        [_jobDetailView loadProject:p typeName:_type];
        _jobDetailView.hidden=NO;
    }else
        //无cell数据
        _jobDetailView.hidden = YES;
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
}


//保存列表缓存(根据当前是放验线/批后跟踪/违法案件)
-(void)saveListCache{
    NSMutableArray *toSaveData = [NSMutableArray arrayWithArray:self.dataSource];
//    if (self.btnFyx.selected) {//放验线
//        //_cacheFyxList = self.dataSource;
//        _cacheFyxList = [NSMutableArray arrayWithArray:toSaveData];
//        [_cacheFyxList writeToFile:_cacheFyxSavePath atomically:YES];
//    }else if(self.btnHshi.selected){//批后跟踪
//        if (nil==_cachePhgzList) {
//            _cachePhgzList = [NSMutableDictionary dictionaryWithCapacity:5];
//        }
//        int phIndex = _phFilterControl.SelectedIndex;
//        [_cachePhgzList setValue:toSaveData forKey:[NSString stringWithFormat:@"%d",phIndex]];
//        [_cachePhgzList writeToFile:_cachePhgzSavePath atomically:YES];
//    }else if(self.btnPhgz.selected){//违法案件
//        _cacheWfajList = toSaveData;
//        [_cacheWfajList writeToFile:_cacheWfajSavePath atomically:YES];
//    }
    if ([[_searchKeys objectAtIndex:1]isEqualToString:@"验线"]) {//放验线
        //_cacheFyxList = self.dataSource;
        _cacheFyxList = [NSMutableArray arrayWithArray:toSaveData];
        [_cacheFyxList writeToFile:_cacheFyxSavePath atomically:YES];
    }
//        else if([[_searchKeys objectAtIndex:1]isEqualToString:@"核实"]){//批后跟踪
//        if (nil==_cachePhgzList) {
//            _cachePhgzList = [NSMutableDictionary dictionaryWithCapacity:5];
//        }
//        int phIndex = _phFilterControl.SelectedIndex;
//        [_cachePhgzList setValue:toSaveData forKey:[NSString stringWithFormat:@"%d",phIndex]];
//        [_cachePhgzList writeToFile:_cachePhgzSavePath atomically:YES];
//    }
    else if([[_searchKeys objectAtIndex:1]isEqualToString:@"批后跟踪"]){//违法案件
        _cacheWfajList = toSaveData;
        [_cacheWfajList writeToFile:_cachePhgzSavePath atomically:YES];
    }
}

//
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    [_tableView.header endRefreshing];
    [_tableView.footer endRefreshing];
}
//服务器请求失败时的代理方法
-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    [_tableView.header endRefreshing];
    [_tableView.footer endRefreshing];
    self.tableView.hidden = NO;
    self.dataActivityIndicator.hidden = YES;
    //请求返回失败也设置为no
    _loading = NO;
    [self.tableView reloadData];
    //请求失败也要根据当前按钮选中情况,显示或者隐藏对应的条
    if (self.btnHshi.selected) {
        [self showPhFilter];
    }else if(self.btnPhgz.selected){
        _phFilterControl.hidden = YES;
        [self showNewProjectButton];
    }else{
        [self hidePhFilter];
        [self hideNewProjectButton];
    }
}

//点击搜索按钮
-(void)searchBarSearchButtonClicked:(UISearchBar *)sb{
    [sb resignFirstResponder];
    if (_loading) {
        return;
    }
    self.tableView.hidden = YES;
    self.dataActivityIndicator.hidden = NO;
    
    /*
    if (nil!=_pageInfo) {
        _pageInfo.pageIndex = 0;
        _pageInfo.pageCount = 1;
        _pageInfo.dataCount = 0;
    }
     */
    [self.dataSource removeAllObjects];
    //设置请求代理
    ServiceProvider *dataProvider = [ServiceProvider initWithDelegate:self];
    _loading = YES;
    //只有点击搜索按钮,_loadAllFlag才为yes
    _loadAllFlag = YES;
//    [dataProvider getData:@"smartplan" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"getphgllist",@"action",_currentSearchKey,@"zftype",self.searchBar.text,@"querystring",[NSString stringWithFormat:@"%@",[Global currentUser].userid],@"user",nil]];
    NSLog(@"当前搜索域%@",_currentSearchKey);
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"getphgllist",@"action",
                                       @"0",@"pageIndex",
                                       @"100",@"pageSize",
                                       self.searchBar.text,@"querystring"
                                       ,@"0",@"businessType", nil];
    if([_currentSearchKey isEqualToString:@"审批业务"])
    {
        [parameters setObject:@"" forKey:@"businessName"];
    }
    else
    {
        [parameters setObject:_currentSearchKey forKey:@"businessName"];
    }
    
    [dataProvider getData:@"smartplan" parameters:parameters];
}

#pragma  mark-JobDetailViewDelegate代理方法
//表格发送结束执行代理方法(重新加载数据)
-(void)shouldReLoadList{
    [self loadAllData];
}

//根据选中的按钮加载数据
-(void)loadAllData{
    //离线
    if (![Global isOnline]) {
        [self loadDataFromCache];
        return;
    }
    

    if (_loading) {
        [_listProvider kill];
    }
    _jobDetailView.hidden = YES;
    self.tableView.hidden = YES;
    //菊花
    self.dataActivityIndicator.hidden = NO;
    //self.dataSource = nil;
    //清空数据
    [self.dataSource removeAllObjects];
    //设置请求代理
    _listProvider = [ServiceProvider initWithDelegate:self];
    //加载数据的时候设置为yes
    _loading = YES;
    _loadAllFlag = NO;
//    http://58.246.138.178:8040/ZZZFServices/ServiceProvider.ashx?type=smartplan&action=zflist&user=122&zftype=fyx&phflowstate=-1
//168.2.239/KSYDService/ServiceProvider.ashx?type=smartplan&action=getphgllist&xmbh=&slbh=&prjName=&businessName=&businessId=&prjState=&pageIndex=&pageSize=
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"getphgllist",@"action",
                                       _currentSearchKey,@"businessName",
                                       @"0",@"pageIndex",
                                       _pagesize,@"pageSize",
                                       @"",@"querystring", nil];
    if([_currentSearchKey isEqualToString:@"审批业务"])
    {
        [parameters setObject:@"0" forKey:@"businessType"];
        [parameters setObject:_currentSearchKey forKey:@"businessName"];
    }else if (self.btnPhgz.selected){//选择批后跟踪 业务分类按钮
        [parameters setObject:[Global currentUser].userid forKey:@"useriId"];
        [parameters setObject:@"批后过程管理" forKey:@"businessName"];
        NSInteger type = [self.leftSearchArray indexOfObject:self.btnPhgz.titleLabel.text];
        [parameters setObject:@(type) forKey:@"pojectType"];
    }
    [_listProvider getData:@"smartplan" parameters:parameters];
}

//加载缓存数据
-(void)loadDataFromCache{
    
//    if (self.btnFyx.selected && nil!=_cacheFyxList) {//选中放验线,打开缓存数据
//        self.dataSource = [NSMutableArray arrayWithArray:_cacheFyxList];
//    }else if(self.btnHshi.selected && nil!=_cachePhgzList){//选中放批后跟踪,打开缓存数据
//        NSMutableArray *phCacheArray = [_cachePhgzList objectForKey:[NSString stringWithFormat:@"%d",_phFilterControl.SelectedIndex]];
//        self.dataSource = [NSMutableArray arrayWithArray:phCacheArray];
//    }else if(self.btnPhgz.selected && nil!=_cacheWfajList){
//        //选中违法案件,打开缓存数据
//        self.dataSource = [NSMutableArray arrayWithArray:_cacheWfajList];
//    }
//    //选中批后跟踪,显示批后跟踪状态条
//    if (self.btnHshi.selected) {
//        [self showPhFilter];
//    }else{
//        [self hidePhFilter];
//    }
    if ([_currentSearchKey isEqualToString:@"审批业务"] && nil!=_cacheSpywList) {//选审批业务,打开缓存数据
      self.dataSource = [NSMutableArray arrayWithArray:_cacheSpywList];
    }else if( [_currentSearchKey isEqualToString:@"核实"]&& nil !=_cacheHsList){//选中核实,打开缓存数据
        self.dataSource = [NSMutableArray arrayWithArray:_cacheHsList];
    }else if([_currentSearchKey isEqualToString:@"批后跟踪"]&& nil!=_cachePhgzList){
        //选中违法案件,打开缓存数据
        self.dataSource = [NSMutableArray arrayWithArray:_cachePhgzList];
    }
    //选中批后跟踪,显示批后跟踪状态条
    if (self.btnHshi.selected) {
        [self showPhFilter];
    }else{
        [self hidePhFilter];
    }

    //tableView 加载数据
    [self.tableView reloadData];
   
    //加缓存就要默认加载第一行cell的数据到_jobDetailView上
    [self showProjectAt:0];
}

//搜索栏完成编辑时的代理方法[加载所有数据]
-(void)searchBarTextDidEndEditing:(UISearchBar *)sb{
    [sb resignFirstResponder];
    //搜索内容为空时,即加载所有数据
    if (_loadAllFlag && [self.searchBar.text isEqualToString:@""]) {
        [self loadAllData];
    }
}


-(void)openPhoto:(NSString *)name path:(NSString *)path fromLocal:(BOOL)fromLocal{
    _toOpenFileName = name;
    _toOpenFilePath = path;
    _toOpenFileExt = @"jpg";
    _materialFromLocal = fromLocal;
    _filesArray = nil;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}


#pragma mark-JobDetailViewDelegate代理方法
-(void)openMaterial:(NSString *)materialName path:(NSString *)path ext:(NSString *)ext fromLocal:(BOOL)fromLocal{
    _toOpenFileName = materialName;
    _toOpenFilePath = path;
    _toOpenFileExt = ext;
    _materialFromLocal = fromLocal;
    _filesArray = nil;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}
#pragma -mark 打开文件
-(void)openMaterial:(NSArray *)materials at:(int)index
{
    NSDictionary *itemDic=[materials objectAtIndex:index];
    _currentIndex=[NSString stringWithFormat:@"%d",index];
    _filesArray=materials;
    _toOpenFileName=[itemDic objectForKey:@"name"];
    _toOpenFilePath=[itemDic objectForKey:@"path"];
    _toOpenFileExt=@"jpg";
    if ([[itemDic objectForKey:@"uploaded"] isEqualToString:@"YES"]||[[itemDic objectForKey:@"uploaded"] isEqualToString:@"yes"]) {
        _materialFromLocal=NO;
    }
    else
        _materialFromLocal=YES;
    [self performSegueWithIdentifier:@"fileView" sender:self];
    
}
-(void)jobInfoDidLoadFromNetwork{
    if (self.btnFyx.selected) {
        [_cacheFyxList writeToFile:_cacheFyxSavePath atomically:YES];
    }else if(self.btnHshi.selected){
        [_cachePhgzList writeToFile:_cachePhgzSavePath atomically:YES];
    }else if(self.btnPhgz.selected){
        [_cacheWfajList writeToFile:_cacheWfajSavePath atomically:YES];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *target = segue.destinationViewController;
    [target setValue:_currentIndex forKey:@"currentIndex"];
    [target setValue:_filesArray forKeyPath:@"files"];
    [target setValue:_toOpenFileName forKey:@"fileName"];
    [target setValue:_toOpenFilePath forKey:@"filePath"];
    [target setValue:_toOpenFileExt forKey:@"fileExt"];
    [target setValue:_materialFromLocal?@"NO":@"YES" forKey:@"isFromNetwork"];
}


//新增违法案件执行的方法
-(void)newWfProject{
    NewWfProjectViewController *nwpvc = [[NewWfProjectViewController alloc] initWithNibName:@"NewWfProjectViewController" bundle:nil];
    nwpvc.projectDelegate = self;
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:nwpvc];
    formSheet.cornerRadius = 8.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 150;
    formSheet.presentedFormSheetSize = CGSizeMake(467, 330);
    [formSheet presentAnimated:YES completionHandler:nil];
}

-(void)projectCreateSuccfully:(NSString *)projectId{
    _wfDefaultID = projectId;
    [self loadAllData];
}

//完成巡查
-(void)dailyJobCompleted{
    NSMutableDictionary *currentJobInfo = [[Global currentUser] dailyJobCurrentInfo];

    
//    
////    self.btnNewJob.hidden = NO;
////    self.lblJobStatus.hidden = YES;
//    
//    NSString *jobId = [currentJobInfo objectForKey:@"jobid"];
//    
//    //NSFileManager *fm = [NSFileManager defaultManager];
//    //NSString *cachePath = [[[Global currentUser] userDailyJobPath] stringByAppendingFormat:@"/%@",jobId];
//    //[fm createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    //NSString *cachePhotoPath = [cachePath stringByAppendingString:@"/photos"];
//    //[fm createDirectoryAtPath:cachePhotoPath withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    //组织好数据并提交到服务器
//    NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithCapacity:11];
//    //NSMutableDictionary *cacheData = [NSMutableDictionary dictionaryWithDictionary:currentJobInfo];
//    
//    NSError *error = nil;
//    NSData *jsonReportData = [NSJSONSerialization dataWithJSONObject:[currentJobInfo objectForKey:@"report"] options:NSJSONWritingPrettyPrinted error:&error];
//    if (nil==error && ![jsonReportData isEqual:@""]) {
//        [postData setObject:[[NSString alloc] initWithData:jsonReportData encoding:NSUTF8StringEncoding] forKey:@"report"];
//    }
//    
//    NSMutableArray *times = [currentJobInfo objectForKey:@"times"];
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
//    
//    NSMutableString *timeStr=[NSMutableString stringWithCapacity:10];
//    for (int i=0; i<times.count; i++) {
//        [timeStr appendString:[formatter stringFromDate:[times objectAtIndex:i]]];
//        [timeStr appendString:@","];
//    }
//    NSString *finishTime  = [formatter stringFromDate:[NSDate date]];
//    [timeStr appendString:finishTime];
//    
//    [postData setObject:timeStr forKey:@"timestr"];
//    [postData setObject:finishTime forKey:@"finishtime"];
//    [postData setObject:jobId forKey:@"jobid"];
//    [postData setObject:@"savejob" forKey:@"action"];
//    [postData setObject:@"zf" forKey:@"type"];
//    [postData setObject:times forKey:@"times"];
//    [postData setObject:[Global currentUser].userid forKey:@"userid"];
//    
//    [Global wait:@"正在完成巡查"];
//    DataPostman *postman = [[DataPostman alloc] init];
//    [postman postDataWithUrl:[Global serviceUrl] data:postData delegate:self];
//    
//    
//    //[Global addDataToSyn:[NSString stringWithFormat:@"DATAIDENTITY_DAILYJOB_COMPLETED%@",jobId] data:postData];
//    
//    //[cacheData writeToFile:[cachePath stringByAppendingString:@"/job.archive"] atomically:YES];
//    
//    
//    
//    /*
//     //NSMutableArray *photos = [currentJobInfo objectForKey:@"photos"];
//     //NSMutableDictionary *cachePhotoPathList = [NSMutableDictionary dictionaryWithCapacity:photos.count];
//     
//     //NSArray *allPhotoNames = [photos allKeys];
//     //NSMutableDictionary *photoDatas = [NSMutableDictionary dictionaryWithCapacity:photoPaths.count];
//     
//     不在此处提交照片，因为照片一起提交，数据包太大
//     for (NSMutableDictionary *photoInfo in photos) {
//     if ([[photoInfo objectForKey:@"uploaded"] isEqualToString:@"yes"]) {
//     continue;
//     }
//     NSString *photoName = [photoInfo objectForKey:@"name"];
//     NSString *thePath = [photoInfo objectForKey:@"path"];
//     
//     NSString *newPath = [cachePhotoPath stringByAppendingFormat:@"/%@.jpg",photoName];
//     
//     [cachePhotoPathList setObject:newPath forKey:photoName];
//     [fm copyItemAtPath:thePath toPath:newPath error:nil];
//     
//     UIImage *thePhoto = [UIImage imageWithContentsOfFile:newPath];
//     [postData setObject:thePhoto forKey:photoName];
//     
//     }
//     [cacheData setObject:cachePhotoPathList forKey:@"photos"];
//     NSData *jsonPhotoInfo = [NSJSONSerialization dataWithJSONObject:photos options:NSJSONWritingPrettyPrinted error:&error];
//     if (nil==error && ![jsonPhotoInfo isEqual:@""]) {
//     [postData setObject:[[NSString alloc] initWithData:jsonPhotoInfo encoding:NSUTF8StringEncoding] forKey:@"photos"];
//     }
//     */
//    /*  停工单是即时保存的，不要一起提交
//     //停工单
//     NSMutableArray *stopworkforms = [currentJobInfo objectForKey:@"stopwork"];
//     int canUseForm = 0;
//     for (int i=0; i<stopworkforms.count; i++) {
//     NSMutableDictionary *theForm = [stopworkforms objectAtIndex:i];
//     NSData *formJson = [NSJSONSerialization dataWithJSONObject:theForm options:NSJSONWritingPrettyPrinted error:&error];
//     if (nil!=error) {
//     continue;
//     }
//     canUseForm++;
//     [postData setObject:[[NSString alloc] initWithData:formJson encoding:NSUTF8StringEncoding] forKey:[NSString stringWithFormat:@"stopwork%d",i]];
//     }
//     //[postData setObject:[NSString stringWithFormat:@"%d",canUseForm] forKey:@"stopworkformcount"];
//     */
    
}

//- (void) loadDataWithparameters:(NSDictionary *)params
//{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    
//    
//        [manager POST:[Global serviceUrl] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        NSDictionary *data = (NSDictionary *)responseObject;
//
//            //显示tableView
//            self.tableView.hidden = NO;
//            //隐藏菊花
//            self.dataActivityIndicator.hidden = YES;
//            //加载状态取消 请求返回设置为no
//            _loading = NO;
//            //默认选中第一个并加载第一个
//            _wfDefaultSelectIndex = 0;
//            if ([[data objectForKey:@"success"] isEqualToString:@"true"]) {
//                //int dataCount = [[data objectForKey:@"count"] intValue];
//                //[_pageInfo calcPageInfo:dataCount];
//                
//                NSMutableArray *rs = [data objectForKey:@"result"];
//                int i=0;
//                for (NSDictionary *item in rs) {
//                    
//                    //ProjectInfo *project = [[ProjectInfo alloc] initWithProject:[item objectForKey:@"name"] theId:[item objectForKey:@"id"] theCode:[item objectForKey:@"code"] theAddress:[item objectForKey:@"address"] theTime:[item objectForKey:@"time"]];
//                    //[self.dataSource addObject:project];
//                    //已经加载过某行数据后,更新选中行
//                    if (nil!=_wfDefaultID) {
//                        NSString *pid = [item objectForKey:@"id"];
//                        if ([pid isEqualToString:_wfDefaultID]) {
//                            _wfDefaultSelectIndex = i;
//                        }
//                    }
//                    [self.dataSource addObject:[NSMutableDictionary dictionaryWithDictionary:item]];
//                    i++;
//                }
//                
//                //加载数据
//                [self.tableView reloadData];
//            }
//            
//            //显示某行详情数据
//            [self showProjectAt:_wfDefaultSelectIndex];
//            
//            
//            [self saveListCache];
//            if (self.btnHshi.selected) {
//                //显示批后跟踪条
//                [self showPhFilter];
//            }else if(self.btnPhgz.selected  ){
//                //显示违法案件条
//                [self showNewProjectButton];
//                //[self hidePhFilter];
//                _phFilterControl.hidden = YES;
//            }else{
//                //隐藏批后跟踪和添加违法按钮按钮
//                [self hidePhFilter];
//                [self hideNewProjectButton];
//            }
//
////            //NSLog(@"数据::%@",rs);
////            if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
////            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//          
//        }];
//
//
//}


- (void)popXCJMwith:(NSMutableDictionary *)dict andwithMaterialA:(NSMutableArray *)theMatrialA
{
    //通过通知进行跳转和传值
    [self creatDailyJobwithDict:dict andwithMaterialA:theMatrialA];

}

//点击审批业务获取下拉款
- (IBAction)categoryBtnClick:(id)sender {
    SifterViewController *siftVC = [[SifterViewController alloc] init];
//    siftVC.selectedIndex = btn.tag - 100;
    siftVC.selectedIndex = 0;
    siftVC.siftBlock = ^(NSString *title) {
        [_ghywBtn setTitle:title forState:UIControlStateNormal];
      _searchKeys = [NSArray arrayWithObjects:@"批后过程管理",title, nil];
//        [self showFyxList];
        [self onBtnBuniessTap:self.ghywBtn];
        
    };
    
    [self presentViewController:siftVC animated:YES completion:nil];
    
}
@end
