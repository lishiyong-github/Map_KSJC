//
//  SifterViewController.m
//  KSYD
//
//  Created by 吴定如 on 16/10/19.
//  Copyright © 2016年 dist. All rights reserved.
//

#import "SifterViewController.h"
//#import "SiftTableCell.h"

@interface SifterViewController () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIView *naviView;

@property(nonatomic,strong) NSArray *dataArray;
@property(nonatomic,strong) UILabel *naviTitle;

@end

@implementation SifterViewController
- (instancetype)initWithFilterArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.dataArray = array;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (!self.dataArray) {
        NSArray *dataArray = [NSArray array];
        if (_selectedIndex == 0)
        {
            dataArray = @[@"审批业务",@"验线",@"核实",@"工程"];
        }
        else if (_selectedIndex == 1)
        {
            dataArray = @[@"未完成",@"已完成"];
        }
        _dataArray = dataArray;
    }
    
    [self initWithTableViewAndNavigationView];
    
    //监听屏幕旋转的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}
//屏幕旋转改变视图的Frame
-(void)screenRotation:(NSNotification *)noti
{
    _naviTitle.center = CGPointMake(MainR.size.width/2.0, 42);
    _tableView.frame = CGRectMake(0, 0, MainR.size.width, MainR.size.height-64);
    [_tableView reloadData];
}

#pragma mark -- 创建 tableView && SearchBar
-(void)initWithTableViewAndNavigationView
{
    //
    UIView *naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainR.size.width, 64)];
    naviView.backgroundColor =[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1] ;
    _naviView = naviView;
    [self.view addSubview:naviView];
    //返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 22, 40, 40)];
    [backBtn setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(Back) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:backBtn];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    lab.textColor = [UIColor whiteColor];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"请选择";
    lab.center = CGPointMake(naviView.frame.size.width/2.0, 42);
    _naviTitle = lab;
    [naviView addSubview:lab];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, MainR.size.width, MainR.size.height-64-64) style:UITableViewStylePlain];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView = tableView;
    [self.view addSubview:tableView];
    
}

- (void)Back
{

    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma -mark  UITableViewDataSource,UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SiftTableCell"];
    }
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(30, 9, 100, 30)];
    label.text= _dataArray[indexPath.row];
    label.font=[UIFont systemFontOfSize:17];
    label.textColor=[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+marw, 10, 30, 30)];
//    imageView.image =[UIImage imageNamed:@"iconfont-dianzixieyi@2x"];
    UIView *line =[[UIView alloc] initWithFrame:CGRectMake(0, 43, MainR.size.width, 1)];
    line.backgroundColor =[UIColor colorWithRed:238.0/255 green:238.0/255 blue:238.0/255 alpha:1];
    [cell.contentView addSubview:line];
    [cell.contentView addSubview:label];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SiftTableCell"];
//    cell.textLabel.text = _dataArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.siftBlock) {
        self.siftBlock (_dataArray[indexPath.row]);
    }
    

[self dismissViewControllerAnimated:YES completion:^{
    
}];

    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end