//
//  DistCalendarDay.m
//  DistCalendar
//
//  Created by zhangliang on 13-12-10.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "DistCalendarOfDay.h"

@implementation DistCalendarOfDay

@synthesize day = _day;
@synthesize dayLabel = _dayLabel;
@synthesize selected =_selected;
@synthesize data = _data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dayLabel = [[UILabel alloc] init];
        self.dayLabel.font = [self.dayLabel.font fontWithSize:13];
        self.dayLabel.frame = CGRectMake(self.frame.size.width-35, 8, 30, 25);
        [self addSubview:self.dayLabel];
        self.dayLabel.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tap];
        
//        _iconHaveData = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 32, 32)];
                _iconHaveData = [[UIImageView alloc] initWithFrame:CGRectMake(98, 60, 32, 32)];

        _iconHaveData.image= [UIImage imageNamed:@"icon_selected_green"];
        _iconHaveData.hidden = YES;
        
        _iconHavePhoto = [[UIImageView alloc] initWithFrame:CGRectMake(52, 60, 32, 32)];
        _iconHavePhoto.image= [UIImage imageNamed:@"icon_picture"];
        _iconHavePhoto.hidden = YES;
        
//        _iconHaveForm = [[UIImageView alloc] initWithFrame:CGRectMake(94, 60, 32, 32)];
                _iconHaveForm = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 32, 32)];

        _iconHaveForm.image= [UIImage imageNamed:@"icon_star"];
        _iconHaveForm.hidden = YES;
        
        [self addSubview:_iconHaveForm];
        [self addSubview:_iconHaveData];
        [self addSubview:_iconHavePhoto];
    }
    return self;
}

//单击日期
-(void)onTap{
    //设置背景色
    [self setBg];
    //如果有数据
    if (_haveData) {
        [self.delegate onDayTap:_day];
    }
    //0.3后移除背景颜色
    [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(clearBg) userInfo:nil repeats:NO];
}

//设置日期
-(void)setDay:(NSDate *)day{
    //_day具体日期时间
    _day=day;
//    NSLog(@"day = %@",_day);
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_day];
    self.dayLabel.text = [NSString stringWithFormat:@"%d",[components day]];
    
    NSDate *today = [NSDate date];
    NSDateComponents *componentsToday = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
    NSDateComponents *componentsMonth= [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_day];

    
    _isToday = [components day]==[componentsToday day] && [components month]==[componentsToday month] && [components year]==[componentsToday year];
    
//    self.dayLabel.textColor = _isToday ? [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1]:[UIColor blackColor];
    if (_isMonth)
    {
        self.dayLabel.textColor = _isToday ? [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1]:[UIColor blackColor];
    }
    else
    {
        self.dayLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    }
    int fontSize = _isToday?24:12;
    [self.dayLabel setFont:[self.dayLabel.font fontWithSize:fontSize]];
    
}

-(void)setHaveData:(BOOL)haveData{
    _haveData = haveData;
    /*
    if (_haveData) {
        self.backgroundColor = [UIColor colorWithRed:133.0/255.0 green:236.0/255.0 blue:205.0/255.0 alpha:1];
        self.dayLabel.textColor = _isToday ? [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1]:[UIColor whiteColor];
        int fontSize = _isToday?24:16;
        [self.dayLabel setFont:[self.dayLabel.font fontWithSize:fontSize]];
    }else{
        self.backgroundColor = [UIColor clearColor];
        self.dayLabel.textColor = _isToday ? [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1]:[UIColor blackColor];
        int fontSize = _isToday?24:12;
        [self.dayLabel setFont:[self.dayLabel.font fontWithSize:fontSize]];
    }
    _defaultBackground = self.backgroundColor;
     */
}

-(void)setData:(NSDictionary *)data{
    _data = data;
    _haveData = nil!=data;
    if (_haveData) {
        _iconHaveData.hidden = NO;
//        _iconHaveForm.hidden = [[data objectForKey:@"FORMS"] isEqualToString:@"0"];
//        _iconHavePhoto.hidden = [[data objectForKey:@"PHOTO"] isEqualToString:@"0"];
    }else{
        _iconHavePhoto.hidden = _iconHaveForm.hidden = _iconHaveData.hidden = YES;
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self setBg];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self clearBg];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self clearBg];
}

-(void)setBg{
    //[super touchesBegan:touches withEvent:event];
    //[UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:0.3];
    [self setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1]];
    //[UIView commitAnimations];
}

-(void)clearBg{
    
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:0.6];
    //动画的内容
    if (self.selected) {
        [self setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:100]];
    }else{
        [self setBackgroundColor:_defaultBackground];
    }
    //动画结束
    [UIView commitAnimations];
}

-(void)setSelected:(BOOL)selected{
    _selected = selected;
    if (selected) {
        [self setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:100]];
    }else{
        [self setBackgroundColor:_defaultBackground];
    }
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
