//
//  DayLogsVC.m
//  KSJC
//
//  Created by 叶松丹 on 2016/11/21.
//  Copyright © 2016年 dist. All rights reserved.
//

#import "DayLogsVC.h"
#import "LogDetailCell.h"
#import "DistCalendarView.h"
#import "DailyJobView.h"
#import "AFHTTPRequestOperationManager.h"
#import "Global.h"
#import "MBProgressHUD+MJ.h"
#import "DailyJobReaderViewController.h"
#import "MapJobViewController.h"
#import "PickerView.h"

@interface DayLogsVC ()<UITableViewDelegate,UITableViewDataSource,MapJobViewControllerDelegate>
@property (nonatomic,strong)UIView *topView;
@property (nonatomic,strong)NSString *projectID;
@property (nonatomic,strong)NSDictionary *project;
@property (nonatomic,strong)NSMutableArray *theProjectMaterialA;
//选中某条巡查记录的的字典数据
@property (nonatomic,strong)NSDictionary *selectdict;
@end

@implementation DayLogsVC

-(NSMutableArray *)theProjectMaterialA
{
    if(_theProjectMaterialA == nil)
    {
        _theProjectMaterialA =[NSMutableArray array];
    
    }
    return  _theProjectMaterialA;
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.frame = CGRectMake(0, 0, MainR.size.width, 44);
//    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _project = [NSDictionary dictionary];
    _selectdict = [NSDictionary dictionary];
    self.view.frame =CGRectMake(0, 64, MainR.size.width, MainR.size.height-44-64);
    self.view.backgroundColor =[UIColor whiteColor];
    [self createLogTableView];
    [self  loadData];
    [self createBtn];
}

- (void)createBtn
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainR.size.width, 64)];
    [self.view addSubview:topView];
    UIView *line =[[UIView alloc] initWithFrame:CGRectMake(0, 63, MainR.size.width,1)];
    line.backgroundColor =[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    [topView addSubview:line];
    _topView = topView;
    
    
    UILabel *label =[[UILabel alloc] init];
    label.frame =CGRectMake((MainR.size.width - 100)*0.5, 20, 100, 44);
    [label setText:@"监察记录"];
    [label setFont:[UIFont systemFontOfSize:18]];
    [label setTextColor:[UIColor blackColor]];
    [_topView addSubview:label];
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 20, 100, 44);
    [btn setImage:[UIImage imageNamed:@"fhjt@2x.png"] forState:UIControlStateNormal];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(30, 0, 30,10)];
//    [btn setBackgroundColor:[UIColor blueColor]];
    [self.topView addSubview:btn];
    [btn addTarget:self action:@selector(popToForvc) forControlEvents:UIControlEventTouchUpInside];
    

}

-(void)popToForvc
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

-(void)loadData
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameters;

    [MBProgressHUD showMessage:@"正在加载" toView:self.view];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *endTime = [NSString stringWithFormat:@"%@ 23:59:59",_dayTime];

        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *temDay= [dateFormatter dateFromString:endTime];
    NSTimeInterval time =24 * 60 * 60;
    NSDate * starDate = [temDay dateByAddingTimeInterval:-time];
  NSString *starTime = [dateFormatter stringFromDate:starDate];

//    NSString *starTime = [NSString stringWithFormat:@"%@ 00:00:00",_dayTime];
    
    parameters = @{@"type":@"smartplan",@"action":@"getphgldata",@"startDate":starTime,@"endDate":endTime,@"pid":@"-1"};
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    
    NSLog(@"日常记录%@",requestAddress);
    
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view];
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            _logArray= [rs objectForKey:@"result"];
            [self.logTableView reloadData];
           
        }
      
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
 
    }];
}



-(void)createLogTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, MainR.size.width, MainR.size.height-49-44-20) style:UITableViewStylePlain];
    [tableView registerNib:[UINib nibWithNibName:@"LogDetailCell" bundle:nil] forCellReuseIdentifier:@"LogDetailCell"];
    //tableView.tableFooterView = [[UIView alloc] init];
    //tableView.backgroundColor = [UIColor orangeColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.estimatedRowHeight = 70;
    _logTableView = tableView;
    
    
    [self.view addSubview:tableView];
}

#pragma mark - - tableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _logArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogDetailCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = _logArray[indexPath.row];
    cell.projectName.text = [dict objectForKey:@"xmmc"];
    cell.xcPerson.text = [dict objectForKey:@"jcry"];
    cell.jcqk.text  = [dict objectForKey:@"jsqk"];
    cell.logTime.text = [dict objectForKey:@"jcsj"];
    [cell.editBtn addTarget:self action:@selector(editBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[dict objectForKey:@"xyjl"]isEqualToString:@"已验线"]||[[dict objectForKey:@"xyjl"]isEqualToString:@"true"]) {
        cell.yxTFlabel.text =@"已验线";
        [cell.yxTFlabel setTextColor:[UIColor colorWithRed:17.0/255.0 green:160/255.0 blue:91.0/255.0 alpha:1]];
        
    }else if([[dict objectForKey:@"xyjl"]isEqualToString:@""])
    {
        cell.yxTFlabel.text =@"";
    }

    else
    {
        cell.yxTFlabel.text =@"未验线";
        [cell.yxTFlabel setTextColor:[UIColor redColor]];
        
    }
    if ([[dict objectForKey:@"gczjl"]isEqualToString:@"已取得"]||[[dict objectForKey:@"gczjl"]isEqualToString:@"true"]) {
        cell.gczTFlabel.text =@"已取得工程证";
        [cell.gczTFlabel setTextColor:[UIColor colorWithRed:17.0/255.0 green:160/255.0 blue:91.0/255.0 alpha:1]];
        
    }
    else if([[dict objectForKey:@"gczjl"]isEqualToString:@""])
    {
        cell.gczTFlabel.text =@"";
    }

    else
    {
        cell.gczTFlabel.text =@"未取得工程证";
        [cell.gczTFlabel setTextColor:[UIColor redColor]];
        
    }
//    cell.meetingTitle.text =;
    //    _meetingHoster.text = model.HostUserName;
    //    _meetingAddress.text = model.meetingAddress;
    //    NSString *time = [model.meetingTime substringWithRange:NSMakeRange(11,5)];
    //    _meetingTime.text = time;
    
    
    return cell;
}

- (void)editBtn:(UIButton *)btn
{
 NSIndexPath *indexPathAll= [self SelectRow:btn];
NSDictionary *selectdict = _logArray[indexPathAll.row];
//    PickerView *pickView = [[PickerView alloc]initWithFrame:MainR withDictModel:dict];
//    pickView.selectedBlock=^{
//        [self loadData];
//    
//    };
//    [pickView showInView:self.view.window animated:YES];
    _selectdict = [NSDictionary dictionaryWithDictionary:selectdict];
    [self loadbaseProjectWithpid:[selectdict objectForKey:@"pid"] andTime:[selectdict objectForKey:@"jcsj"] withDict:selectdict];
    
    
    

}

//获取项目信息
- (void)loadbaseProjectWithpid:(NSString *)pid andTime:(NSString *)time withDict:(NSDictionary *)dict
{
    
    //根据记录获取基本信息
    //58.246.138.178:8040/KSYDService/ServiceProvider.ashx?type=smartplan&action=projectbaseinfo&projectId=87668
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *date =[formatter dateFromString:time];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //        _xcLogTime = [formatter stringFromDate:date];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"type"] = @"smartplan";
    parameters[@"action"]=@"projectbaseinfo";
    parameters[@"projectId"]=pid;
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    NSLog(@"加载项目信息%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            
            [MBProgressHUD showSuccess:@"项目基本信息获取成功" toView:self.view];
            NSArray *arr= [rs objectForKey:@"result"];
            if(arr.count>0)
            {
                NSDictionary *dicts =[rs objectForKey:@"result"][0];
                _project = dicts;
                NSMutableDictionary *muldic = [NSMutableDictionary dictionaryWithDictionary:dicts];
                _projectID = [dicts objectForKey:@"projectId"];
                [self loadMoterial];
                
            }
            //                [self loadData];
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"无法获取项目信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                
            }
        }
        else
        {
            [MBProgressHUD showError:@"项目基本信息获取成功" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"项目基本信息获取成功" toView:self.view];
    }];
    
    
    
}

- (void)loadMoterial
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"type"] = @"smartplan";
        parameters[@"action"]=@"materials";
        parameters[@"slbh"]=[_project objectForKey:@"slbh"];
        
        NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
        [requestAddress appendString:@"?"];
        
        if (nil!=parameters) {
            for (NSString *key in parameters.keyEnumerator) {
                NSString *val = [parameters objectForKey:key];
                [requestAddress appendFormat:@"&%@=%@",key,val];
            }
        }
        NSLog(@"请求材料%@",requestAddress);
        
        [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rs = (NSDictionary *)responseObject;
            if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
                [MBProgressHUD showSuccess:@"材料请求成功" toView:self.view];
                NSArray *arr =[rs objectForKey:@"result"];

                
                _theProjectMaterialA = [NSMutableArray arrayWithArray:arr];

                [self starEditJC];
            }
            else
            {
                [MBProgressHUD showError:@"材料请求失败" toView:self.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [MBProgressHUD showError:@"材料请求失败" toView:self.view];
        }];
        
    }



- (void)starEditJC
{
        BOOL isHaveNewJob = [[defaults objectForKey:@"isHaveNewJob"] boolValue];
        //已经有巡查
        if (isHaveNewJob)
        {
    
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已有新建的巡查,您需要结束正在巡查再来添加新建!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertView.tag = 100;
            [alertView show];
        }
        else
        {
//            记录是否新建巡查的状态 & 是哪个项目的巡查
            [defaults setBool:YES forKey:@"isHaveNewJob"];
//            [defaults setInteger:_selectedAddBtnIndex forKey:@"selectedAddBtnIndex"];
            [defaults synchronize];
    
            NSDictionary *deviceDic = @{@"projectDict":_project,@"projectMaterialA":_theProjectMaterialA,@"isRevice":@"true",@"selectedDict":_selectdict};
    //  @{@"projectDict":theproject,@"projectMaterialA":materialA};
    
    
            /////////////////////////////////////
            //从在建到日常巡查   通过通知调整
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedNewJobView" object:deviceDic];
            
            self.tabBarController.selectedIndex = 0;
     
            
        }
    

}


//选中某行数据
-(NSIndexPath *)SelectRow:(UIButton *)btn
{
    LogDetailCell *cell;
    
    cell=(LogDetailCell *)[[btn superview] superview];
    NSIndexPath *indexPathAll = [self.logTableView indexPathForCell:cell];//获取cell对应的index
    return indexPathAll;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"yyyy-MM-dd"];
//    [self.delegate openJob:[df stringFromDate:day]];
  NSDictionary *dict=  [_logArray objectAtIndex:indexPath.row];
  NSString *jobTime=[dict objectForKey:@"jcsj"];
//    //打开具体某天的记录
//    [self.delegate showLogsOfdayWithDayTime:jobTime withDict:dict];
//
    MapJobViewController *mapj=[[MapJobViewController alloc] init];
    [mapj loadbaseProjectWithpid:[dict objectForKey:@"pid"] andTime:[dict objectForKey:@"jcsj"]withDict:dict];
    mapj.xclog = YES;
    mapj.delegate = self;
    mapj.type = @"Wfxm";
    //mapj.jobDelegate = self.jobDelegate;
    [self.navigationController pushViewController:mapj animated:YES];
   
}

-(void)mapJobViewShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext{
    
    [self.delegate mapShouldShowFile:name path:path ext:ext];
}

-(void)mapJobViewShouldShowFiles:(NSArray *)materials at:(int)index{
    [self.delegate mapShouldShowFiles:materials at:index];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
