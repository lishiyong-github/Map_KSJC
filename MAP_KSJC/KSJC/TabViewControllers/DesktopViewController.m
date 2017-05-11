//
//  DesktopViewController.m
//  zf
//
//  Created by dist on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "DesktopViewController.h"
#import "Global.h"

@interface DesktopViewController ()

@end

@implementation DesktopViewController

@synthesize msg;

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
    if ([Global isOnline]) {
        ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
        [sp getData:@"zf" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"statistics",@"action",@"2014",@"year",nil]];
        ServiceProvider *sp2 = [ServiceProvider initWithDelegate:self];
        sp2.tag=2;
        [sp2 getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getuserdevice",@"action",[Global currentUser].userid,@"userid", nil]];
    }
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(storeViewTap)];
    [self.storeInfoView addGestureRecognizer:tap2];
    
    UILabel * circleChartLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 390, 200, 30)];
    circleChartLabel.text = @"各业务在全局中所占比例";
    circleChartLabel.textColor = [UIColor blackColor];
    circleChartLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0];
    circleChartLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:circleChartLabel];
    
    UILabel *lblC1 = [[UILabel alloc] initWithFrame:CGRectMake(106, 620, 120, 30)];
    lblC1.text = @"放验线";
    lblC1.textColor = PNFreshGreen;
    lblC1.font = [lblC1.font fontWithSize:16];
    [self.view addSubview:lblC1];
    
    UILabel *lblC2 = [[UILabel alloc] initWithFrame:CGRectMake(440, 620, 120, 30)];
    lblC2.text = @"批后跟踪";
    lblC2.textColor = PNTwitterColor;
    lblC2.font = [lblC1.font fontWithSize:16];
    [self.view addSubview:lblC2];
    
    UILabel *lblC3 = [[UILabel alloc] initWithFrame:CGRectMake(756, 620, 120, 30)];
    lblC3.text = @"违法案件";
    lblC3.textColor = PNMauve;
    lblC3.font = [lblC1.font fontWithSize:16];
    [self.view addSubview:lblC3];
    
    self.lblCount1.backgroundColor = PNBlue;
    self.lblCount1.layer.cornerRadius = 5;
    
    self.lblCount2.backgroundColor = PNGreen;
    self.lblCount2.layer.cornerRadius = 5;
    
    self.lblCount3.backgroundColor = PNTwitterColor;
    self.lblCount3.layer.cornerRadius = 5;
    
    self.lblCount4.backgroundColor = PNMauve;
    self.lblCount4.layer.cornerRadius = 5;
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
    for (UIView *u in self.view.subviews) {
        if (u.tag==21) {
            [u removeFromSuperview];
        }
    }
    [self createCircleChart:CGRectMake(30, 230, 150, 150) sum:[[dic objectForKey:@"fyxTotal"] intValue] current:[[dic objectForKey:@"fyx"] intValue] color:PNGreen];
    [self createCircleChart:CGRectMake(200, 230, 150, 150) sum:[[dic objectForKey:@"phgzTotal"] intValue] current:[[dic objectForKey:@"phgz"] intValue] color:PNTwitterColor];
    [self createCircleChart:CGRectMake(370, 230, 150, 150) sum:[[dic objectForKey:@"wfajTotal"] intValue] current:[[dic objectForKey:@"wfaj"] intValue] color:PNMauve];
    [self createLineChart];
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

-(void) onHtmlReady{
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.initDesktop('%@','%@')",[Global serviceUrl],[Global currentUser].userid]];
}

-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data
{
}
-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    if (provider.tag==2) {
        if ([[data objectForKey:@"success"] isEqualToString:@"true"]) {
            NSMutableDictionary *dc = [data objectForKey:@"result"];
            if (nil==dc) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有绑定到巡查设备，是否现在绑定？" delegate:self cancelButtonTitle:@"暂不绑定" otherButtonTitles:@"去绑定",nil];
                [alert show];
            }else{
                [Global currentUser].deviceName = [dc objectForKey:@"name"];
                [Global currentUser].deviceNumber = [dc objectForKey:@"code"];
            }
        }
    }else{
        dic= [[data objectForKey:@"data2"] objectAtIndex:0];
        arr=[data objectForKey:@"data1"];
        [self loadData];
    }
}
-(void) serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    UIAlertView *alert;
    if (provider.tag==2) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有获取到设备信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    }else{
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"统计数据获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    }
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [[Global currentUser].properties setObject:@"yes" forKey:@"toBindDevice"];
        self.tabBarController.selectedIndex=6;
    }
}
@end
