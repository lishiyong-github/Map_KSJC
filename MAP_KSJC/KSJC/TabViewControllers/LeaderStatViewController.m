//
//  LeaderStatViewController.m
//  zzzf
//
//  Created by dist on 14-4-13.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "LeaderStatViewController.h"

@interface LeaderStatViewController ()

@end

@implementation LeaderStatViewController

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
    _year=2014;
    _lblYear.text=[NSString stringWithFormat:@"(%d)",_year];
    
    ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
    [sp getData:@"zf" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"statistics",@"action",@"2014",@"year",nil]];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(storeViewTap)];
    [self.storeInfoView addGestureRecognizer:tap2];
    
    UILabel * circleChartLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 390, 200, 30)];
    circleChartLabel.text = @"各大队业务办理情况";
    circleChartLabel.textColor = [UIColor blackColor];
    circleChartLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0];
    circleChartLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:circleChartLabel];
    
    
    self.lblCount1.backgroundColor = PNBlue;
    self.lblCount1.layer.cornerRadius = 5;
    
    self.lblCount2.backgroundColor = PNGreen;
    self.lblCount2.layer.cornerRadius = 5;
    
    self.lblCount3.backgroundColor = PNTwitterColor;
    self.lblCount3.layer.cornerRadius = 5;
    
    self.lblCount4.backgroundColor = PNMauve;
    self.lblCount4.layer.cornerRadius = 5;
    
    self.btnNext.layer.cornerRadius = 21;
    self.btnPrevious.layer.cornerRadius = 21;
    
    [self.chartDailyJob setDataSource:self];
    [self.chartDailyJob setPieCenter:CGPointMake(120, 120)];
    [self.chartDailyJob setShowPercentage:NO];
    [self.chartDailyJob setLabelColor:[UIColor blackColor]];
    [self.chartDailyJob setLabelFont:[self.chartDailyJob.labelFont fontWithSize:14]];
    
    [self.chartFyx setDataSource:self];
    [self.chartFyx setPieCenter:CGPointMake(120, 120)];
    [self.chartFyx setShowPercentage:NO];
    [self.chartFyx setLabelColor:[UIColor blackColor]];
    [self.chartFyx setLabelFont:[self.chartDailyJob.labelFont fontWithSize:14]];
    
    [self.chartPhgz setDataSource:self];
    [self.chartPhgz setPieCenter:CGPointMake(120, 120)];
    [self.chartPhgz setShowPercentage:NO];
    [self.chartPhgz setLabelColor:[UIColor blackColor]];
    [self.chartPhgz setLabelFont:[self.chartPhgz.labelFont fontWithSize:14]];
    
    [self.chartWfaj setDataSource:self];
    [self.chartWfaj setPieCenter:CGPointMake(120, 120)];
    [self.chartWfaj setShowPercentage:NO];
    [self.chartWfaj setLabelColor:[UIColor blackColor]];
    [self.chartWfaj setLabelFont:[self.chartWfaj.labelFont fontWithSize:14]];
    
    for (int i=0; i<self.orgInfo.count; i++) {
        NSDictionary *orgInfo = [self.orgInfo objectAtIndex:i];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(i*80, 720, 80, 20)];
        lbl.backgroundColor = [self colorWithOrg:[orgInfo objectForKey:@"id"]];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = [orgInfo objectForKey:@"name"];
        [lbl setFont:[lbl.font fontWithSize:14]];
        [self.view addSubview:lbl];
    }
    
}


-(NSMutableArray *)getMonthArray:(NSDictionary *)d{
    if (d==nil) {
        return nil;
    }
    NSMutableArray *monArr=[[NSMutableArray alloc] init];
    for (int i=1;i<13;i++) {
        NSString *str=[d objectForKey:[NSString stringWithFormat:@"total_%d",i]];
        [monArr addObject:str];
    }
    return monArr;
}

-(void)createLineChart{
    for (UIView *u in self.view.subviews) {
        if (u.tag==22) {
            [u removeFromSuperview];
        }
    }
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(260, 135.0, 800, 180)];
    lineChart.tag=22;
    lineChart.backgroundColor = [UIColor clearColor];
    [lineChart setXLabels:@[@"一月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月",@"八月",@"九月",@"十月",@"十一月",@"十二月"]];
    NSArray *data01Array=nil;
    NSArray *data02Array=nil;
    NSArray *data03Array=nil;
    NSArray *data04Array=nil;
    for (NSDictionary *d in arr) {
        if ([[d objectForKey:@"projecttype"] isEqualToString:@"0"]) {
            data01Array=[self getMonthArray:d];
        }else if([[d objectForKey:@"projecttype"] isEqualToString:@"1"]){
            data02Array=[self getMonthArray:d];
        }else if([[d objectForKey:@"projecttype"] isEqualToString:@"2"]){
            data03Array=[self getMonthArray:d];
        }else if([[d objectForKey:@"projecttype"] isEqualToString:@"3"]){
            data04Array=[self getMonthArray:d];
        }
    }
    
    if (data01Array==nil) {
        data01Array = @[@0, @0, @0, @0, @0, @0, @0,@0,@0,@0,@0,@0];
    }
    if (data02Array==nil) {
        data02Array = @[@0, @0, @0, @0, @0, @0, @0,@0,@0,@0,@0,@0];
    }
    if (data03Array==nil) {
        data03Array = @[@0, @0, @0, @0, @0, @0, @0,@0,@0,@0,@0,@0];
    }
    if (data04Array==nil) {
        data04Array = @[@0, @0, @0, @0, @0, @0, @0,@0,@0,@0,@0,@0];
    }
    
    //data01Array=[self getMonthArray:[arr objectAtIndex:0]];
    int count01=0;
    for (NSString *str in data01Array) {
        count01 = count01+[str intValue];
    }
    _lblCount1.text=[NSString stringWithFormat:@"完成%d次日常巡查",count01];
    // Line Chart Nr.1
    //NSArray * data01Array = @[@60.1, @160.1, @126.4, @262.2, @186.2, @127.2, @176.2,@32,@10,@8,@10,@10];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = PNBlue;
    data01.itemCount = lineChart.xLabels.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [[data01Array objectAtIndex:index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    // Line Chart Nr.2
    //NSArray *data02Array=[self getMonthArray:[arr objectAtIndex:1]];
    int count02=0;
    for (NSString *str in data02Array) {
        count02 = count02+[str intValue];
    }
    _lblCount2.text=[NSString stringWithFormat:@"办理%d个放验线",count02];
    //NSArray * data02Array = @[@20.1, @180.1, @26.4, @202.2, @126.2, @167.2, @276.2,@110,@89,@100,@89,@100];
    PNLineChartData *data02 = [PNLineChartData new];
    data02.color = PNGreen;
    data02.itemCount = lineChart.xLabels.count;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [[data02Array objectAtIndex:index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    // Line Chart Nr.3
    //NSArray *data03Array=[self getMonthArray:[arr objectAtIndex:2]];
    int count03=0;
    for (NSString *str in data03Array) {
        count03 = count03+[str intValue];
    }
    _lblCount3.text=[NSString stringWithFormat:@"办理%d个批后跟踪",count03];
    //NSArray * data03Array = @[@10.1, @80.1, @6.4, @302.2, @146.2, @167.2, @176.2,@10,@89,@100,@89,@100];
    PNLineChartData *data03 = [PNLineChartData new];
    data03.color = PNTwitterColor;
    data03.itemCount = lineChart.xLabels.count;
    data03.getData = ^(NSUInteger index) {
        CGFloat yValue = [[data03Array objectAtIndex:index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    // Line Chart Nr.4
    //NSArray *data04Array=[self getMonthArray:[arr objectAtIndex:3]];
    int count04=0;
    for (NSString *str in data04Array) {
        count04 = count04+[str intValue];
    }
    _lblCount4.text=[NSString stringWithFormat:@"办理%d个违法案件",count04];
    //NSArray * data04Array = @[@10.1, @80.1, @6.4, @302.2, @146.2, @167.2, @176.2,@10,@89,@100,@89,@100];
    PNLineChartData *data04 = [PNLineChartData new];
    data04.color = PNMauve;
    data04.itemCount = lineChart.xLabels.count;
    data04.getData = ^(NSUInteger index) {
        CGFloat yValue = [[data04Array objectAtIndex:index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    lineChart.chartData = @[data01, data02,data03,data04];
    [lineChart strokeChart];
    
    [self.view addSubview:lineChart];
}

-(void)createCircleChart:(CGRect)chartFrame sum:(int)sum current:(int)current color:(UIColor *)color{
    
    
    PNCircleChart * circleChart = [[PNCircleChart alloc] initWithFrame:chartFrame andTotal:[NSNumber numberWithInt:sum] andCurrent:[NSNumber numberWithInt:current]];
    circleChart.tag=21;
    [circleChart setStrokeColor:color];
    [circleChart strokeChart];
    
    
    [self.view addSubview:circleChart];
}

-(void)loadData{
    [self createLineChart];
    [self.chartDailyJob reloadData];
    [self.chartFyx reloadData];
    [self.chartPhgz reloadData];
    [self.chartWfaj reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)userViewTap{
    UITabBarController *tabController = (UITabBarController *)self.parentViewController;
    tabController.selectedIndex = 6;
}

-(void)storeViewTap{
    UITabBarController *tabController = (UITabBarController *)self.parentViewController;
    tabController.selectedIndex = 5;
}

-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data
{
}

-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    _circleDatasource = [data objectForKey:@"data2"];
    arr=[data objectForKey:@"data1"];
    
    for (NSMutableDictionary *d in _circleDatasource) {
        NSMutableArray *orginfo = [d objectForKey:@"orginfo"];
        for (int i=orginfo.count-1; i>=0; i--) {
            NSMutableDictionary *sumDict = [orginfo objectAtIndex:i];
            NSString *p1 = [sumDict objectForKey:@"org"];
            BOOL haveOrg = NO;
            for (NSDictionary *orgConfig  in self.orgInfo) {
                NSString *p2 = [orgConfig objectForKey:@"id"];
                if ([p1 isEqualToString:p2]) {
                    haveOrg = YES;
                    break;
                }
            }
            if (!haveOrg) {
                [orginfo removeObjectAtIndex:i];
            }
        }
    }
    
    [self loadData];
    
}
-(void) serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    UIAlertView *alert;
    
    alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"统计数据获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    
    [alert show];
}

- (IBAction)onBtnPrevious:(id)sender {
    _year=_year-1;
    _lblYear.text=[NSString stringWithFormat:@"(%d)",_year];
    ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
    [sp getData:@"zf" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"statistics",@"action",[NSString stringWithFormat:@"%d",_year],@"year",nil]];
}

- (IBAction)onBtnNext:(id)sender {
    _year=_year+1;
    _lblYear.text=[NSString stringWithFormat:@"(%d)",_year];
    ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
    [sp getData:@"zf" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"statistics",@"action",[NSString stringWithFormat:@"%d",_year],@"year",nil]];
}


- (IBAction)onBtnGoBackTap:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - XYPieChart Data Source


-(UIColor *)colorWithOrg:(NSString *)org{
    NSString *orgColorStr;
    for (int i=0; i<self.orgInfo.count; i++) {
        NSDictionary *orgInfo = [self.orgInfo objectAtIndex:i];
        if ([org isEqualToString: [orgInfo objectForKey:@"id"]]) {
            orgColorStr = [orgInfo objectForKey:@"color"];
            break;
        }
    }
    UIColor *defaultColor = [UIColor colorWithRed:23.0/255.0 green:158.0/255.0 blue:17.0/255.0 alpha:.6];
    if (nil==orgColorStr) {
        return [UIColor clearColor];
    }else{
        NSArray *rgb = [orgColorStr componentsSeparatedByString:@","];
        if (rgb.count!=3) {
            return defaultColor;
        }
        return [UIColor colorWithRed:[[rgb objectAtIndex:0] doubleValue]/255.0 green:[[rgb objectAtIndex:1] doubleValue]/255.0 blue:[[rgb objectAtIndex:2] doubleValue]/255.0 alpha:.6];
    }
}

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    NSString *pt = [NSString stringWithFormat:@"%d",pieChart.tag];
    for(NSDictionary *d in _circleDatasource){
        if ([[d objectForKey:@"projecttype"] isEqualToString:pt]) {
            NSArray *orgs = [d objectForKey:@"orginfo"];
            return orgs.count;
        }
    }
    return 0;
}



- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    if (nil==_circleDatasource) {
        return 0;
    }
    //NSString *orgId = [[self.orgInfo objectAtIndex:index] objectForKey:@"id"];
    NSString *pt = [NSString stringWithFormat:@"%d",pieChart.tag];
    for(NSDictionary *d in _circleDatasource){
        if ([[d objectForKey:@"projecttype"] isEqualToString:pt]) {
            NSArray *orgs = [d objectForKey:@"orginfo"];
            return [[[orgs objectAtIndex:index] objectForKey:@"value"] floatValue];
            /*for (NSDictionary *orgData in orgs) {
                if ([[orgData objectForKey:@"org"] isEqualToString:orgId]) {
                    return [[orgData objectForKey:@"value"] floatValue];
                }
            }*/
        }
    }
    return 0;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    NSString *pt = [NSString stringWithFormat:@"%d",pieChart.tag];
    for(NSDictionary *d in _circleDatasource){
        if ([[d objectForKey:@"projecttype"] isEqualToString:pt]) {
            NSArray *orgs = [d objectForKey:@"orginfo"];
            NSString *orgId =  [[orgs objectAtIndex:index] objectForKey:@"org"];
            return [self colorWithOrg:orgId];
        }
    }
    return [UIColor clearColor];
}

@end
