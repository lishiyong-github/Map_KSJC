//
//  DailyJob.m
//  zzzf
//  日常巡查主面板
//  Created by dist on 13-11-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "DailyJobView.h"
#import "Global.h"
#import "DataPostman.h"
#import "JobDetailView.h"
#import "MBProgressHUD+MJ.h"
#import "WaitingView.h"
static bool wvInWindow;


@interface DailyJobView ()<ASIHTTPRequestDelegate,JobDetailViewDelegate>

@property(nonatomic,strong) JobDetailView *jobDetailView;
@property (nonatomic,assign)BOOL isRevice;

@end

@implementation DailyJobView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


+(DailyJobView *)createView{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"DailyJobView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

-(void)initializeData{
    if (_initialized) {
        return;
    }
    _initialized = YES;
    _calendarServiceTag = 0;
    _calendarTimes = [[NSMutableArray alloc] initWithCapacity:10];
    
//    //新建巡查界面
//    _newDailyJobViewController =[[NewDailyJobViewController alloc] initWithNibName:@"NewDailyJobViewController" bundle:nil];
//    
//    //设置NewDailyJobDelegate代理
//    _newDailyJobViewController.delegate = self;
    //(初始化)当前巡查界面//DailyJobControlPanel
    [_jobControlPanel initialzePanel];
    
    _calenderCacheFlag = [NSMutableDictionary dictionaryWithCapacity:10];
    
    //先显示日历
    [self showCalendarView];
    
    //检查今天的工作状态:{"status":"true","result":[{"status":"1","time":"2016/7/27 10:48:08"}]}
    [self checkTodayJobStatus];
    //读取历史数据(用来判断是否重传)
//    [self readHistoryJob];
  
}

-(void)loadJob:(NSMutableDictionary *)data{
    NSDate *startTime = [[data objectForKey:@"times"] objectAtIndex:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年M月d日 HH:mm:ss"];
    [self showJobTime:[formatter stringFromDate:startTime]];
    //加载巡查数据
    [_jobControlPanel loadJob:data];
    
}

//显示正在巡查的界面(巡查详情)
-(void)showJobView
{
    if (nil==_jobControlPanel) {
        _jobControlPanel = [DailyJobControlPanel createView];
        _jobControlPanel.frame = CGRectMake(0, 52, 1024, 664);
        _jobControlPanel.delegate = self;
        [self addSubview:_jobControlPanel];
        [_jobControlPanel initialzePanel];
        //更新巡查job
        [self refershJob];
    }
    //详情选中
    self.btnInfo.selected = YES;
    //日期取消选中
    self.btnCalendar.selected = NO;
    //隐藏日历view
    _calendarView.hidden = YES;
    //显示巡查详情view
    _jobControlPanel.hidden = NO;
    //详情按钮
    self.InfomationBtn.hidden = NO;
}

//显示日历
-(void)showCalendarView{
    if (nil==_calendarView) {
        //NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(createCalendar) object:nil];
        //[thread start];
        //创建日历
        [self createCalendar];
        //self.calendarActivityIndicator.hidden = NO;
    }else{
        _calendarView.hidden = NO;
    }
    
    //设置详情按钮 取消选择
    self.btnInfo.selected = NO;
    //设置日历按钮选中
    self.btnCalendar.selected = YES;
    //详情按钮
    self.InfomationBtn.hidden = YES;
    
    //隐藏当前巡查view界面
    if (nil!=_jobControlPanel) {
        _jobControlPanel.hidden = YES;
    }
}

//创建日历
-(void)createCalendar{
    //设置日历大小和代理
    _calendarView = [[DistCalendarView alloc] initWithFrameAndDelegate:CGRectMake(0, 52, 1024,664) caldendarDelegate:self];
    
    [self addSubview:_calendarView];
    //如果显示详情按选中,则隐藏日历显示状态
    if (self.btnInfo.selected) {
        _calendarView.hidden = YES;
    }
}


//点击右上日历或者是详情按钮执行的方法
- (IBAction)onBtnViewTaggleTap:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag==0) {//显示正在巡查界面
        [self showJobView];
        
    }else{
        [self showCalendarView];
        //详情按钮
        self.InfomationBtn.hidden = YES;
    }
    
}

// -- 更新巡查状态
-(void)showJobTime:(NSString *)timeString
{
    self.lblJobStatus.hidden = NO;
    self.operater.hidden = NO;
//    if (_btnInfo.selected == YES)
//    {
        //详情按钮
        self.InfomationBtn.hidden = NO;
//    }
   
    self.lblJobStatus.text = [NSString stringWithFormat:@"巡查开始于：%@",timeString];
    //设置操作者
    self.operater.text =[ NSString stringWithFormat:@"操作者 : %@",[Global currentUser].username];
}

// 更新巡查job/和显示文字
-(void)refershJob{
    //如果已开始巡查
    NSString *dailyStatus = [[[Global currentUser] dailyJobCurrentInfo] objectForKey:@"status"];
    if ([dailyStatus isEqualToString:@"started"]) {
        
        NSMutableDictionary *jobInfo = [[Global currentUser] dailyJobCurrentInfo];
      NSString *startTime=[[jobInfo objectForKey:@"times"]objectAtIndex:0];
        //读取开始时间
//        NSDate *startTime = [[jobInfo objectForKey:@"times"] objectAtIndex:0];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        [formatter setDateFormat:@"yyyy年M月d日 HH:mm:ss"];
//        [self showJobTime:[formatter stringFromDate:startTime]];
        [self showJobTime:startTime];

        self.lblJobStatus.hidden = NO;
        self.operater.hidden = NO;
        //详情按钮
        //self.InfomationBtn.hidden = NO;
    }else{
        
        self.lblJobStatus.hidden = YES;
        self.operater.hidden = YES;
        //详情按钮
        self.InfomationBtn.hidden = YES;
    }
    if (_jobControlPanel != nil) {
        [_jobControlPanel refersh];
    }
}

-(void)readHistoryJob
{
    _historyJobSavePath = [[[Global currentUser] userWorkPath] stringByAppendingString:@"/historyDailyjob"];
    _historyJobListFilePath = [_historyJobSavePath stringByAppendingString:@"/jobs.archive"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fm fileExistsAtPath:_historyJobSavePath isDirectory:&isDir]) {
        [fm createDirectoryAtPath:_historyJobSavePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    _historyJobs = [NSMutableArray arrayWithContentsOfFile:_historyJobListFilePath];
    if (nil==_historyJobs) {
        _historyJobs = [NSMutableArray arrayWithCapacity:2];
    }
    
    self.btnReUpload.hidden = _historyJobs.count==0;
    [self.btnReUpload setTitle:[NSString stringWithFormat:@"补传（%d）",_historyJobs.count] forState:UIControlStateNormal];
}


#pragma  mark-DailyJobControlPanelDelegate代理方法


- (void)showcalader
{
    [self showCalendarView];

}

//  完成巡查
-(void)dailyJobCompleted
{
    [MBProgressHUD hideHUD];
//    [MBProgressHUD showSuccess:@"照片上传成功" toView:[[[UIApplication sharedApplication] delegate] window]];
    [Global wait:@"照片上传成功"];
//    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
//    while (controller.presentedViewController != nil) {
//        controller = controller.presentedViewController;
//    }
//    WaitingView *wv = [[WaitingView alloc] initWithFrame:CGRectMake(0, 0, 1024,768)];
//    //设置显示内容
//    wv.msg = @"照片上传成功";
//    if (!wvInWindow) {
//        [controller.view addSubview:wv];
//    }
//    wvInWindow = YES;
    
    [defaults setObject:@"NO" forKey:@"isHaveNewJob"];
    [defaults setObject:@"" forKey:@"groupid"];
    [defaults setBool:NO forKey:@"isfinishCreated"];
    
    

    //清除数据
   [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(clearDate) userInfo:nil repeats:NO];
    
    //清除当前巡查信息
    [[Global currentUser] clearCurrentDailyJob];
    _jobControlPanel.yxTrue.selected=_jobControlPanel.yxFalse.selected=_jobControlPanel.gczTrue.selected=_jobControlPanel.gczFalse.selected = NO;
    _jobControlPanel.ConStructcdTextView.text = @"请输入建设情况...";
    _jobControlPanel.ConStructcdTextView.textColor = [UIColor lightGrayColor];
    _jobControlPanel.isfinishCreated = NO;
    [_jobControlPanel refersh];
    [self showCalendarView];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reloadCalendar) userInfo:nil repeats:NO];
    [self checkTodayJobStatus];
  
}
- (void)clearDate
{
    [Global waitclear];
}


//DailyJobControlPanelDelegate代理方法
-(void)openPhoto:(NSString *)name path:(NSString *)path fromLocal:(BOOL)fromLocal
{
    [self.delegate openPhoto:name path:path fromLocal:fromLocal];
    
}


//DailyJobControlPanelDelegate代理方法
#pragma -mark 最新添加
-(void)allFiles:(NSArray *)files at:(int)index
{
    [self.delegate openFiles:files at:index];
    
}

#pragma mark-ASIHTTPRequestDelegate代理方法
-(void)requestFailed:(ASIHTTPRequest *)request{
    [Global wait:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法完成巡查" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
//ASIHTTPRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.responseStatusCode==200) {
        NSError *parseError = nil;
        NSString *responseString = request.responseString;
        NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&parseError];
        if(nil!=parseError){
            [self requestFailed:nil];
        }else if([[rs objectForKey:@"status"] isEqualToString:@"false"]){
            NSLog(@"error:%@",[rs objectForKey:@"message"]);
            [self requestFailed:nil];
        }else{
            self.lblJobStatus.hidden = YES;
            self.operater.hidden = YES;
            //详情按钮
            self.InfomationBtn.hidden = YES;
            //请求返回成功
            [defaults setBool:NO forKey:@"isHaveNewJob"];
            [defaults synchronize];
            
            //清除数据
            [Global wait:nil];
            
            //清除当前巡查信息
            [[Global currentUser] clearCurrentDailyJob];
            [_jobControlPanel refersh];
            //
            [self refershJob];
            [self showCalendarView];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reloadCalendar) userInfo:nil repeats:NO];
            [self checkTodayJobStatus];
        }
    }else{
        [self requestFailed:nil];
    }
}

-(void)reloadCalendar
{
    _beRemoveTodayCalendarCache = YES;
    //显示当前月
    [_calendarView showToday];
    //请求当月数据
    [self calendarTimeRangeChaned:_calendarView.start end:_calendarView.end];
}



-(void)checkTodayJobStatus
{
    BOOL isHaveNewJob = [[defaults objectForKey:@"isHaveNewJob"] boolValue];
if(isHaveNewJob)
{
    NSMutableDictionary *jobInfo = [[Global currentUser] dailyJobCurrentInfo];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy年M月d日 HH:mm:ss"];
    NSString *startTime=[[jobInfo objectForKey:@"times"] objectAtIndex:0];
    
    self.lblJobStatus.text = [NSString stringWithFormat:@"今日巡查已于：%@开始",startTime];
//    self.lblJobStatus.text = @"今日巡查已于：000000开始";

    //设置操作者
    self.operater.text =[ NSString stringWithFormat:@"操作者 : %@",[Global currentUser].username ];
    self.lblJobStatus.hidden = NO;
    self.operater.hidden= NO;

}
    else
    {
        self.InfomationBtn.hidden = YES;
        self.lblJobStatus.hidden = YES;
        self.operater.hidden = YES;
    
    }
    
  
}
//获取当前巡查状态失败
-(void)checkTodayJobStatusFault
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取巡查状态失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}


#pragma  mark- DistCalendarDelegate

//移除蒙版  创建好日历
-(void)calendarCreateCompleted{
    UIView *maskView = [self.controller.tabBarController.view.subviews objectAtIndex:self.controller.tabBarController.view.subviews.count-1];
    [maskView removeFromSuperview];
    //[self showCalendarView];
}



#pragma  mark-DistCalendarDelegate代理(已经初始化好 设置上一周)
-(NSDictionary *)calendarDidHaveData:(NSDate *)day{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dayKey = [formatter stringFromDate:day];
    NSMutableDictionary *dj = [[Global currentUser] dailyJobList];
    NSArray *d = [dj objectForKey:dayKey];
    if (nil!=d && d.count>0) {
        return [d objectAtIndex:0];
    }
    return nil;
}

  //滑动后日期始末改变调用的代理方法/请求结束后
-(void)calendarTimeRangeChaned:(NSDate *)start end:(NSDate *)end
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strD1 = [formatter stringFromDate:start];
    NSString *strD2 = [formatter stringFromDate:end];
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@--%@",strD1,strD2];
    //if ([_calenderCacheFlag objectForKey:cacheKey]) {
    //    return;
    //}
    
    //如果在线,并且没有刷新记录则下载日常巡查数据列表
    //if ([Global isOnline]) {
        ServiceProvider *onLineJobListProvider = [[ServiceProvider alloc ]init];
        onLineJobListProvider.tag = _calendarServiceTag;
        [_calendarTimes addObject:[NSMutableArray arrayWithObjects:start,end, nil]];
        _calendarServiceTag ++;
        onLineJobListProvider.delegate = self;
    //请求当月数据
//    2.168.2.239/KSYDService/ServiceProvider.ashx?type=smartplan&action=getphgldata&pid=76723
//    startDate：开始时间，格式yyyy-mm-dd hh24:mi:ss
//    endData：结束时间，格式yyyy-mm-dd hh24:mi:ss
//        [onLineJobListProvider getData:@"query" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"D001",@"cmd",[NSString stringWithFormat:@"%@",[Global currentUser].userid],@"userid",strD1,@"d1",strD2,@"d2", nil]];
    [onLineJobListProvider getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getphgldata",@"action",strD1,@"startDate",strD2,@"endDate",@"-1",@"pid", nil]];
    
    http://58.246.138.178:8040/KSYDService/ServiceProvider.ashx?type=smartplan&action=getphgldata&startDate=2016-10-30%2000:00:00&endDate=2016-12-10%2000:00:00&pid=-1
        [_calenderCacheFlag setObject:@"yes" forKey:cacheKey];
    NSLog(@"_calenderCacheFlag=%@",_calenderCacheFlag);
    //}
}

//

#pragma  mark- DistCalendarDelegate代理方法

-(void)calendarDidTapOnDay:(NSDate *)day
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
//        [self .delegate openJob:[df stringFromDate:day]];
    [self.delegate openDayOfLog:[df stringFromDate:day]];
    

}



#pragma mark-ServiceCallbackDelegate代理方法

//完成巡查请求成功的回调代理
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    

        NSMutableDictionary *userDailyJobList = [[Global currentUser] dailyJobList];
        NSDate *d1 = [[_calendarTimes objectAtIndex:provider.tag] objectAtIndex:0];
        NSDate *d2 = [[_calendarTimes objectAtIndex:provider.tag] objectAtIndex:1];
        
        
//        "id": "21",
//        "pid": "76723",
//        "xmmc": "测试批后管理增加1",
//        "gczjl": "是",
//        "xyjl": "是",
//        "jsqk": "建设情况",
//        "jcry": "监察人员",
//        "jcsj": "2016/11/8 10:00:00"
        
        //用来保存日期:字典 字典结构
        NSMutableDictionary *times = [NSMutableDictionary dictionaryWithCapacity:50];
        NSMutableDictionary *times1 = [NSMutableDictionary dictionaryWithCapacity:50];
        NSMutableArray *totalArr =[NSMutableArray array];

        if([[data objectForKey:@"success"] isEqualToString:@"true"])
        {
        NSArray *dataList = [data objectForKey:@"result"];
//            for (NSDictionary *dataItem in dataList) {
//                NSString *dayStr1 = [dataItem objectForKey:@"jcsj"];
//                NSArray *arr =[dayStr1 componentsSeparatedByString:@" "];
//                NSString *dayStr =arr[0];
//                NSString *tv = [times1 objectForKey:dayStr];
//                if (nil==tv) {
//                    tv = [NSMutableArray arrayWithCapacity:2];
//                    [times1 setObject:tv forKey:dayStr];
//                }
//
//            }
//            NSMutableDictionary *totalDict =[NSMutableDictionary dictionary];
//            NSMutableArray *mulA1=[NSMutableArray array];
//            for (NSString *dayStr in times1) {
//                NSMutableArray *mulA=[NSMutableArray array];
//
//                for (NSDictionary *dict in dataList) {
//                   NSString *day=[dict objectForKey:@"jcsj"];
//                    if ([day containsString:dayStr]) {
//                        [mulA addObject:dict];
//                    }
//                    
//                }
//                [totalDict setObject:mulA forKey:dayStr];
//
//                [mulA1 addObject:totalDict];
//            }
//            totalArr = mulA1;
        for (int i=0; i<dataList.count; i++) {
            NSDictionary *dataItem = [dataList objectAtIndex:i];
            NSString *dayStr1 = [dataItem objectForKey:@"jcsj"];
            NSArray *arr =[dayStr1 componentsSeparatedByString:@" "];
//            NSArray *arrr =[dayStr1 componentsSeparatedByString:@"/"];
////            NSString *ri=arr[2];
            NSString *dayStr =arr[0];
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            //实例化一个NSDateFormatter对象
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            //设定时间格式,要注意跟下面的dateString匹配，否则日起将无效
            
            NSDate *date =[dateFormat dateFromString:dayStr];
            NSString *ddd =[dateFormat stringFromDate:date];
            NSMutableArray *tv = [times objectForKey:ddd];
            if (nil==tv) {
                tv = [NSMutableArray arrayWithCapacity:10];
                [times setObject:tv forKey:ddd];
            }
            //[tv addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[dataItem objectForKey:@"CODE"],@"code",[dataItem objectForKey:@"PATROLTIME"],@"patrolltime", nil]];
            [tv addObject:dataItem];
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSComparisonResult crs = [d1 compare:d2];
        NSTimeInterval dayInterial = 24*60*60;
        while (crs == NSOrderedAscending) {
            NSString *toCheckDayString = [formatter stringFromDate:d1];
            NSMutableArray *vals = [times objectForKey:toCheckDayString];
            if (nil==vals) {
                [userDailyJobList removeObjectForKey:toCheckDayString];
            }else{
                [userDailyJobList setObject:vals forKey:toCheckDayString];
            }
            d1 = [d1 initWithTimeInterval:dayInterial sinceDate:d1];
            crs = [d1 compare:d2];
        }
        
        [_calendarView reloadData];
        //更新日期范围数据到本地
        [[Global currentUser] saveDailJobListToDisk];
        }
//    }
}

//ServiceCallbackDelegate代理方法
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    
}
//ServiceCallbackDelegate代理方法
-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    if (provider.tag==4) {
//        [self checkTodayJobStatusFault];
    }
}

//保存当前数据(保存数据)
-(void)saveCurrentJobToHistory{
    NSMutableDictionary *currentJobInfo = [[Global currentUser] dailyJobCurrentInfo];
    NSMutableArray *photos = [currentJobInfo objectForKey:@"photos"];
    //保存未上传照片字典数组
    NSMutableArray *historyPhotos = [NSMutableArray arrayWithCapacity:10];
    for (NSMutableDictionary *photo in photos) {
        NSString *uploaded = [photo objectForKey:@"uploaded"];
        if ([uploaded isEqualToString:@"no"]) {
            NSMutableDictionary *clonePhoto = [NSMutableDictionary dictionaryWithDictionary:photo];
            [historyPhotos addObject:clonePhoto];
        }
    }
    if (historyPhotos.count!=0) {
        NSString *jobCode = [currentJobInfo objectForKey:@"jobid"];
        //拼接jobsavePath 路径
        NSString *jobSavePath = [_historyJobSavePath stringByAppendingFormat:@"/%@",jobCode];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        [fm createDirectoryAtPath:jobSavePath withIntermediateDirectories:YES attributes:nil error:nil];
        //拷贝照片
        NSMutableDictionary *cloneJc = [NSMutableDictionary dictionaryWithDictionary:currentJobInfo];
        
        //未同步的照片
        for (NSMutableDictionary *movePhoto in historyPhotos) {
            NSString *sourcePath = [movePhoto objectForKey:@"path"];
            NSString *targetPath = [jobSavePath stringByAppendingFormat:@"/%@.jpg",[movePhoto objectForKey:@"code"]];
        
            [fm copyItemAtPath:sourcePath toPath:targetPath error:nil];
            [movePhoto setObject:targetPath forKey:@"path"];
            [movePhoto setObject:jobCode forKey:@"jobid"];
        }
        [cloneJc setObject:historyPhotos forKey:@"photos"];
        [_historyJobs addObject:cloneJc];
        [_historyJobs writeToFile:_historyJobListFilePath atomically:YES];
        //清除当前巡查信息
        [[Global currentUser] clearCurrentDailyJob];
        [_jobControlPanel refersh];
    }
    
    //读取历史数据
    [self readHistoryJob];
}

// 查看(巡查项目)的详细信息
- (IBAction)showNewJobInfomation:(id)sender
{
//    //项目详情界面
//    _jobDetailView = [JobDetailView createView];
//    //初始化JobDetailView
//    [_jobDetailView initializedView];
//    _jobDetailView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    _jobDetailView.delegate = self;
//    [self addSubview:_jobDetailView];
    
    self.controller.tabBarController.selectedIndex = 1;
}

//重传
- (IBAction)onBtnReUploadTouchUp:(id)sender {
    [self readHistoryJob];
    _djr = nil;
    _djr = [[DailyJobReplenish alloc] init];
    _djr.delegate = self;
    [_djr upload:_historyJobs savePath:_historyJobListFilePath];
}



#pragma mark-DailyJobReplenishDelegate代理方法
-(void)dailyjobDidReplenishCompleted{
    [self readHistoryJob];
}


// -------------------------------------------------

// 接收新建巡查通知后 -- 执行的方法
-(void)changeSelectedButtonIndex:(NSNotification *)noty
{
    
    //显示正在巡查界面
    [self showJobView];
    //新建巡查
    //开始巡查保存相关内容
    NSDictionary *informationDic = noty.object;
//    _isRevice = [[informationDic objectForKey:@"isRevice"] boolValue];
//    NSLog(@"是否是修改正在巡查界面%hhd",_isRevice);
    [self saveNewDailyJob:informationDic];
    //详情选中
    self.btnInfo.selected = YES;
    //日期取消选中
    self.btnCalendar.selected = NO;
    //隐藏日历view
    _calendarView.hidden = YES;
    //显示详情view
    _jobControlPanel.hidden = NO;
    
}



//保存新建巡查的一些基本信息(项目信息/材料信息)
-(void)saveNewDailyJob:(NSDictionary *)information
{
    NSMutableDictionary *dict  = [information objectForKey:@"projectDict"];
    NSMutableArray *materialAr =[information objectForKey:@"projectMaterialA"];
    if([information objectForKey:@"isRevice"]!=nil)
    {
        _jobControlPanel.isRevice = YES;
    
    }else
    {
    
        _jobControlPanel.isRevice = NO;
    }
    //开始巡查保存(项目信息/材料信息)
    [_jobControlPanel startNewDailyJobwithProjectInfo:information andMatrial:materialAr];
    
    //新建的已经保存了dailyJobCurrentInfo
    NSMutableDictionary *jobInfo = [[Global currentUser] dailyJobCurrentInfo];
    NSString *startTime =[[jobInfo objectForKey:@"times"] objectAtIndex:0];
        [self showJobTime:startTime];

//    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    

}

@end
