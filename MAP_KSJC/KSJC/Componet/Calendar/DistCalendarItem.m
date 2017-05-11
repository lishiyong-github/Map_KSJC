
//
//  DistCalendarItem.m
//  DistCalendar
//
//  Created by zhangliang on 13-12-10.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "DistCalendarItem.h"
#import "DistCalendarView.h"

@implementation DistCalendarItem

@synthesize calendarHeaderHeight = _calendarHeaderHeight;
@synthesize date = _date;
@synthesize weekNames = _weekNames;
@synthesize titleLabel = _titleLabel;

//
//当前月份的天数
- (NSInteger)totaldaysInMonth:(NSDate *)date{
    
    NSRange daysInOfMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInOfMonth.length;
}
- (NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}
- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [components setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:components];
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}
- (NSInteger)day:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}
- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}
//
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.calendarHeaderHeight = 80;
        _weekNames = [[NSArray alloc] initWithObjects:@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六", nil];
        self.backgroundColor = [UIColor whiteColor];
        [self createWeekLabel];
        [self createCalendarTitle];
        _daysView = [[UIView alloc] initWithFrame:CGRectMake(0,self.calendarHeaderHeight,self.frame.size.width,self.frame.size.height-self.calendarHeaderHeight)];
        [self addSubview:_daysView];
    }
    return self;
}

-(void)createWeekLabel{
    int rowWidth = self.frame.size.width/7;
    for (int i=0; i<7; i++) {
        UILabel *weekLabel = [[UILabel alloc] init];
        weekLabel.font = [weekLabel.font fontWithSize:13];
        if (i==0 || i==6) {
            weekLabel.textColor = [UIColor grayColor];
        }else{
            weekLabel.textColor = [UIColor blackColor];
        }
        weekLabel.text = [self.weekNames objectAtIndex:i];
        weekLabel.frame = CGRectMake((i+1)*rowWidth-30, self.calendarHeaderHeight-30, 30, 30);
        [self addSubview:weekLabel];
    }
}

-(void)createCalendarTitle{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake(self.frame.size.width/2-50, 8, 100, 30);
    [self addSubview:_titleLabel];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGPoint point = CGPointMake((self.bounds.size.width), self.bounds.size.height - 0.5f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1].CGColor);
    CGContextSetLineWidth(ctx, 1);
    
    int rowHeight = (rect.size.height-self.calendarHeaderHeight)/6;
    
    for (int i=0; i<7; i++) {
        int lineY = self.calendarHeaderHeight+(rowHeight*i);
        CGContextMoveToPoint(ctx, 0, lineY);
        CGContextAddLineToPoint(ctx, rect.size.width, lineY);
    }
    
    int rowWidth = rect.size.width/7;
    for (int i=1; i<7; i++) {
        int lineX = (i) * rowWidth;
        CGContextMoveToPoint(ctx, lineX, self.calendarHeaderHeight);
        CGContextAddLineToPoint(ctx, lineX, rect.size.height);
    }
    
    CGContextMoveToPoint(ctx, 0, self.calendarHeaderHeight);
    CGContextAddLineToPoint(ctx, 0, rect.size.height);
    
    CGContextMoveToPoint(ctx, self.frame.size.width, self.calendarHeaderHeight);
    CGContextAddLineToPoint(ctx, self.frame.size.width, rect.size.height);
    
    CGContextStrokePath(ctx);
}

-(void)setDate:(NSDate *)date{
    
    _date = date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年M月"];
    _titleLabel.text = [formatter stringFromDate:_date];
    
    if (nil!=_refreshThread && !_refreshThread.isFinished) {
        [_refreshThread cancel];
        _refreshThread = nil;
    }
    /*
     if (nil!=_delayRefreshTimer) {
     [_delayRefreshTimer invalidate];
     _delayRefreshTimer = nil;
     }
     _delayRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(delayRefresh) userInfo:nil repeats:NO];
     */
    _refreshThread = nil;
    _refreshThread = [[NSThread alloc] initWithTarget:self selector:@selector(doRefresh) object:nil];
    [_refreshThread start];
}

-(void)delayRefresh{
    
}

-(void)doRefresh{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/1/yyyy"];
    //_date保存了日期时间
    //获取当前月份的第一天
    NSDate *firstDayOfMonth = [formatter dateFromString:[formatter stringFromDate:_date]];
    
    NSDateComponents *weekDayComps = [calendar components:(NSWeekdayCalendarUnit) fromDate:firstDayOfMonth];
    NSInteger weekday = [weekDayComps weekday];
    
    NSTimeInterval  startInterval =24*60*60*(weekday-1);
    NSDate *startDay = [firstDayOfMonth initWithTimeInterval:-startInterval sinceDate:firstDayOfMonth];
    
    int rowHeight = (self.frame.size.height-self.calendarHeaderHeight)/6;
    int rowWidth = self.frame.size.width/7;
    
    NSTimeInterval dayInterial = 24*60*60;
    int dayControlCount = _daysView.subviews.count;
    
    int k=0;
    BOOL subViewCreated = dayControlCount!=0;
    //    for (int i=0; i<35; i++) {
    //        for (int j=0; j<7; j++) {
    //            if ([NSThread currentThread].isCancelled) {
    //                return;
    //            }
    for (int i=0; i<42; i++) {
        
        CGFloat x = (i % 7) * rowWidth+1;
        CGFloat y = (i / 7) * rowHeight+1;
        if ([NSThread currentThread].isCancelled) {
            return;
        }
        __block DistCalendarOfDay *dayCell = nil;
        if (subViewCreated) {
            dayCell = [_daysView.subviews objectAtIndex:i];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                dayCell = [[DistCalendarOfDay alloc] initWithFrame:CGRectMake(x, y , rowWidth-2, rowHeight-2)];
                [_daysView addSubview:dayCell];
                dayCell.delegate = self;
            });
        }
        //
        //设置每天cell
        
        //            DistCalendarOfDay *dayCell = nil;
        //
        //            if (subViewCreated) {
        //                dayCell = [_daysView.subviews objectAtIndex:k];
        //            }else{
        //                dayCell = [[DistCalendarOfDay alloc] initWithFrame:CGRectMake(rowWidth*j+1, rowHeight*i+1 , rowWidth-2, rowHeight-2)];
        //                [_daysView addSubview:dayCell];
        //                dayCell.delegate = self;
        //            }
        //
        NSInteger daysInLastMonth = [self totaldaysInMonth:[self lastMonth:_date]];
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        NSInteger firstWeekday    = [self firstWeekdayInThisMonth:_date];
        
        
        // 本月
        if ([self month:_date] == [self month:[NSDate date]] && [self year:_date] == [self year:[NSDate date]]) {
            
            dayCell.isMonth = YES;
            
        }
        //不是当月取消选中
        else
        {
            dayCell.isMonth = NO;
        }
        //判断是当月还是其他月份
        if (i < firstWeekday) {
            dayCell.isMonth = NO;
            
            
        }else if (i > firstWeekday + daysInThisMonth - 1){
            dayCell.isMonth = NO;
            
        }else{
            
            dayCell.isMonth = YES;
        }
        
        
        
        dayCell.day = startDay;
        //            if (i==0 && j==0) {
        //                _start = startDay;
        //            }else if(i==34 && j==6){
        //
        //                _end = startDay;
        //            }
        if (i==0) {
            _start = startDay;
        }else if(i==41){
            _end = startDay;
        }
        if(_ready){
            //执行代理方法(取到日期对应的数据 第1个)
            NSDictionary *cellData = [self.owner.delegate calendarDidHaveData:startDay];
            //设置数据
            dayCell.data = cellData;
        }else{
            dayCell.data = nil;
        }
        k++;
        startDay = [startDay initWithTimeInterval:dayInterial sinceDate:startDay];
    }

    [self performSelectorOnMainThread:@selector(ready) withObject:self waitUntilDone:YES];
}

-(void)ready{
    if (_ready) {
        return;
    }
    _ready = YES;
    //DistCalendarView执行 代理方法
    [self.delegate calendarItemReady:self];
}

-(NSDate *)start{
    return _start;
}

-(NSDate *)end{
    return _end;
}

-(void)refersh{
    [self setDate:_date];
}

#pragma -mark DistCalendarDelegate代理方法
-(void)onDayTap:(NSDate *)date{
    //让DistCalendarView的代理DailyJobView来执行代理方法
    [self.owner.delegate calendarDidTapOnDay:date];
}


@end
