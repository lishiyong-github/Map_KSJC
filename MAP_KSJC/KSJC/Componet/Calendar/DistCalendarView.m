//
//  DistCalendar.m
//  DistCalendar
//
//  Created by zhangliang on 13-12-10.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "DistCalendarView.h"


@implementation DistCalendarView

@synthesize calendarHeaderHeight = _calendarHeaderHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createCalendar];
    }
    return self;
}

-(id)initWithFrameAndDelegate:(CGRect)frame caldendarDelegate:(id<DistCalendarDelegate>)calendarDelegate{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = calendarDelegate;
        //创建日历
        [self createCalendar];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //创建日历
        [self createCalendar];
    }
    return self;
}

//设置月份(包含日期时间)
-(NSDate *)addMonth:(NSDate *)date value:(int)value{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:value];
    [adcomps setDay:0];
    return [calendar dateByAddingComponents:adcomps toDate:date options:0];
}

//创建日历
-(void)createCalendar{
    //设置日历的高
    self.calendarHeaderHeight = 80;
    self.backgroundColor = [UIColor whiteColor];
    //创建底部scrollView
    _caleanderScrollViews = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //复用月历
    _calendar1 = [[DistCalendarItem alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _calendar2 = [[DistCalendarItem alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    _calendar3 = [[DistCalendarItem alloc] initWithFrame:CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height)];
   //设置DistCalendarItem的代理为DistCalendarView.h
    _calendar1.owner = self;
    _calendar2.owner = self;
    _calendar3.owner = self;
    
    _caleanderScrollViews.pagingEnabled = YES;
    _caleanderScrollViews.showsHorizontalScrollIndicator = NO;
    _caleanderScrollViews.showsVerticalScrollIndicator = NO;
    _caleanderScrollViews.delegate = self;
    _caleanderScrollViews.contentSize = CGSizeMake(self.frame.size.width*3, self.frame.size.height);
    _caleanderScrollViews.bounces = YES;
   
    [_caleanderScrollViews addSubview:_calendar1];
    [_caleanderScrollViews addSubview:_calendar2];
    [_caleanderScrollViews addSubview:_calendar3];
    _calendar1.tag = 1;
    _calendar2.tag = 2;
    _calendar1.tag = 3;
    
    
  //  DistCalendarItemDelegate为DistCalendarView
    _calendar1.delegate = self;
    _calendar2.delegate = self;
    _calendar3.delegate = self;
    
    [self addSubview:_caleanderScrollViews];
    
    //默认偏移到中间的月历
    _caleanderScrollViews.contentOffset = CGPointMake(self.frame.size.width, 0);
    //记录当前位置point
    _currentPoint = _caleanderScrollViews.contentOffset;
    _calendars = [[NSArray alloc] initWithObjects:_calendar1,_calendar2,_calendar3, nil];
    
    //今天按钮
    _btnToday = [SysButton buttonWithType:UIButtonTypeCustom];
    _btnToday.frame = CGRectMake(self.frame.size.width-100,10, 80, 30);
    [_btnToday setTitle:@"今天" forState:UIControlStateNormal];
    _btnToday.titleLabel.font = [_btnToday.titleLabel.font fontWithSize:13];
    //_btnToday.font = [_btnToday.font fontWithSize:13];
    
    [_btnToday setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    
    [_btnToday addTarget:self action:@selector(onBtnTodayTap) forControlEvents:UIControlEventTouchUpInside];
    //当前界面添加今天按钮
    [self addSubview:_btnToday];
    
    
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _maskView.backgroundColor = [UIColor whiteColor];
    _maskView.alpha = .7;
    
    [self addSubview:_maskView];
    _readyFlag = 0;
    //获取当前日期(年月日小时)
    _currentMonth = [NSDate date];
    [self initCalendarViewOneByOne];
    
}

//一个一个初始化
-(void)initCalendarViewOneByOne{
    [self calendarItemReady:nil];
}

-(void)setDay:(NSDate *)day{
    _currentMonth = day;
    NSDate *nextMonth = [self addMonth:_currentMonth value:1];
    NSDate *previousMonth = [self addMonth:_currentMonth value:-1];
    DistCalendarItem *c1 = [_calendars objectAtIndex:0];
    DistCalendarItem *c2 = [_calendars objectAtIndex:1];
    DistCalendarItem *c3 = [_calendars objectAtIndex:2];
    
    //设置月份
    c1.date = previousMonth;
    c2.date = _currentMonth;
    c3.date = nextMonth;
    
}

#pragma mark- DistCalendarItemDelegate(3个DistCalendarItem)
//初始化时item为nil
-(void)calendarItemReady:(DistCalendarItem *)item{
    _readyFlag++;
    if (_readyFlag==1) {
        //根据当前日期时间,让月份-1
        NSDate *previousMonth = [self addMonth:_currentMonth value:-1];
        DistCalendarItem *c1 = [_calendars objectAtIndex:0];
        //设置日期--doRefresh--ready--执行代理方法
        c1.date = previousMonth;
    }else if(_readyFlag==2){
        DistCalendarItem *c2 = [_calendars objectAtIndex:1];
        c2.date = _currentMonth;
    }else if(_readyFlag==3){
        DistCalendarItem *c3 = [_calendars objectAtIndex:2];
        NSDate *nextMonth = [self addMonth:_currentMonth value:1];
        c3.date = nextMonth;
    }else if (_readyFlag==4) {
        _maskView.hidden = YES;
        //日历创建完成
        [self.delegate calendarCreateCompleted];
        [self desTimeRangeChanged];
    }
}




//点击今天按钮
-(void)onBtnTodayTap{
    [self showToday];
}
//显示到当前天的月份
-(void)showToday{
    [self setDay:[NSDate date]];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
//减速停止后执行日期计算
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint nowPoint = _caleanderScrollViews.contentOffset;
    if (nowPoint.x == _currentPoint.x ) {
        return;
    }
    
    if (nowPoint.x>_currentPoint.x) {
        DistCalendarItem *currentCalendar = [_calendars objectAtIndex:2];
        _currentMonth =currentCalendar.date;
        _calendars = [[NSArray alloc] initWithObjects:[_calendars objectAtIndex:1],[_calendars objectAtIndex:2],[_calendars objectAtIndex:0],nil];
        NSDate *nextMonth = [self addMonth:_currentMonth value:1];
        DistCalendarItem *theLastCalendar = [_calendars objectAtIndex:2];
        theLastCalendar.date = nextMonth;
    }else{
        DistCalendarItem *currentCalendar = [_calendars objectAtIndex:0];
        _currentMonth =currentCalendar.date;
        _calendars = [[NSArray alloc] initWithObjects:[_calendars objectAtIndex:2],[_calendars objectAtIndex:0],[_calendars objectAtIndex:1],nil];
        NSDate *previousMonth = [self addMonth:_currentMonth value:-1];
        DistCalendarItem *theFirstCalendar = [_calendars objectAtIndex:0];
        theFirstCalendar.date = previousMonth;
    }

    for (int i=0; i<3; i++) {
        DistCalendarItem *theCalendar = [_calendars objectAtIndex:i];
        theCalendar.frame = CGRectMake(self.frame.size.width*i, 0, self.frame.size.width, self.frame.size.height);
    }
    _caleanderScrollViews.contentOffset = CGPointMake(self.frame.size.width, 0);
    _currentPoint = _caleanderScrollViews.contentOffset;
    
    //发布时间区域更换的消息
    [self desTimeRangeChanged];
}

//发布时间区域更换的消息
-(void)desTimeRangeChanged{
    if (nil!=_rangeChangeTimer) {
        [_rangeChangeTimer invalidate];
        _rangeChangeTimer = nil;
    }
    _rangeChangeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dispactTimeRangeChangeEvent) userInfo:nil repeats:NO];
}
//日期范围改变
-(void)dispactTimeRangeChangeEvent{
    //DistCalendarItem *d0 = [_calendars objectAtIndex:0];
    DistCalendarItem *d1 = [_calendars objectAtIndex:1];
    [self.delegate calendarTimeRangeChaned:d1.start end:d1.end];
}

-(NSDate *)start{
    DistCalendarItem *d1 = [_calendars objectAtIndex:0];
    return d1.start;
}

-(NSDate *)end{
    DistCalendarItem *d1 = [_calendars objectAtIndex:0];
    return d1.end;
}


-(void)reloadData{
    for (int i=0; i<3; i++) {
        DistCalendarItem *theCalendar = [_calendars objectAtIndex:1];
        [theCalendar refersh];
    }
}




@end
