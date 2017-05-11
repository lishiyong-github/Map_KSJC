//
//  DistDateSelector.m
//  zzzf
//
//  Created by zhangliang on 14-2-23.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DistDateSelector.h"

@implementation DistDateSelector

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createSubViews];
    }
    return self;
}

-(void)createSubViews{
    _btnPrevious = [self appendBtn:0 text:@"<"];
    _btnYear = [self appendBtn:3 text:@"年"];
    _btnYear.tag=2;
    _btnMonth = [self appendBtn:2 text:@"月"];
    _btnMonth.tag = 1;
    _btnWeek = [self appendBtn:1 text:@"周"];
    _btnWeek.tag = 0;
    _btnNext = [self appendBtn:4 text:@">"];
    _btnWeek.selected = YES;
    //默认为0
    _duration = 0;
    _btnNext.enabled = NO;
    _currentSelectedBtn = _btnWeek;
    [_btnYear addTarget:self action:@selector(onBtnDateTypeTap:) forControlEvents:UIControlEventTouchUpInside];
    [_btnMonth addTarget:self action:@selector(onBtnDateTypeTap:) forControlEvents:UIControlEventTouchUpInside];
    [_btnWeek addTarget:self action:@selector(onBtnDateTypeTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnNext addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [_btnPrevious addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
    [_btnNext setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    //默认为为当前日期
    _date = [NSDate date];
    [self dispetchEvent];
}
//设置按钮位置加按钮标题
-(SysButton *)appendBtn:(int)index text:(NSString *)text{
    int w = self.frame.size.width/5;
    int h = self.frame.size.height;
    SysButton *btn = [SysButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(w*index,0, w,h);
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:0 green:122.0/255 blue:1 alpha:1] forState:UIControlStateNormal];
    btn.titleLabel.font = [btn.titleLabel.font fontWithSize:13];
    [self addSubview:btn ];
    return btn;
}


//派遣事件
-(void)dispetchEvent{
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    if (_duration==0) {
        
//        -(BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate *)datep interval:(NSTimeInterval )tip forDate:(NSDate *)date;

        //  若datep和 tip 可计算，则方法返回YES，否则返回NO。当返回YES时，可从datep里得到date所在的 unit单位的第一天。unit可以为 NSMonthCalendarUnit NSWeekCalendarUnit等
        //返回bool值
        [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:_date];
    }else if(_duration==1){
        [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&beginDate interval:&interval forDate:_date];
    }else if(_duration==2){
        [calendar rangeOfUnit:NSYearCalendarUnit startDate:&beginDate interval:&interval forDate:_date];
    }
    
    endDate = [beginDate dateByAddingTimeInterval:interval-1];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    //按日期格式获取日期字符串
    if (_duration==0) {
        [df setDateFormat:@"yyyy年MM月dd"];
        _dateString = [NSString stringWithFormat:@"%@-%@",[df stringFromDate:beginDate],[df stringFromDate:endDate]];
    }else if(_duration==1){
        [df setDateFormat:@"yyyy年MM月"];
        _dateString = [df stringFromDate:beginDate];
    }else if(_duration==2){
        [df setDateFormat:@"yyyy年"];
        _dateString = [df stringFromDate:beginDate];
    }
    _start = beginDate;
    _end = endDate;
    [self.delegate distDateSelector:self dateDisChanged:beginDate endDate:endDate];
}

-(NSString *)dateString{
    return _dateString;
}

-(void)previous{
    [self appendDate:-1];
}

-(void)next{
    [self appendDate:1];
}

//点击回退和前进(给年月日相应的加减1)
-(void)appendDate:(int)v{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    if (_duration==2) {
        [adcomps setYear:v];
    }else if(_duration==1){
        [adcomps setMonth:v];
    }else if(_duration ==0){
        [adcomps setWeek:v];
    }
    
//    把_date的时间加入(adcomps)到Components得到另外一个时间
    _date = [calendar dateByAddingComponents:adcomps toDate:_date options:0];
    
    int cp = [DistDateSelector compareDate:_date date:[NSDate date]];
    //前小后大正常情况下
    _btnNext.enabled = cp==-1;
    
    [self dispetchEvent];
}
//点击日期年/周/月
-(void)onBtnDateTypeTap:(SysButton *)sender{
    if (sender.selected) {
        return;
    }
    _currentSelectedBtn.selected = NO;
    sender.selected = YES;
    _currentSelectedBtn = sender;
    _duration = sender.tag;
    //派遣事件
    [self dispetchEvent];
}

//对比日期
+(int)compareDate:(NSDate *)date1 date:(NSDate *)date2
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //比较准确度为“日”，如果提高比较准确度，可以在此修改时间格式
    NSString *stringDate1 = [dateFormatter stringFromDate:date1];
    NSString *stringDate2 = [dateFormatter stringFromDate:date2];
    NSDate *dateA = [dateFormatter dateFromString:stringDate1];
    NSDate *dateB = [dateFormatter dateFromString:stringDate2];
    NSComparisonResult result = [dateA compare:dateB];
    if (result == NSOrderedDescending) {
        return 1;  //date1 比 date2 晚
    } else if (result == NSOrderedAscending){
        return -1; //date1 比 date2 早
    }
    return 0; //在当前准确度下，两个时间一致
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
