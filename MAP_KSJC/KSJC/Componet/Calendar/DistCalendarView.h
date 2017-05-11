//
//  DistCalendar.h
//  DistCalendar
//
//  Created by zhangliang on 13-12-10.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DistCalendarItem.h"
#import "SysButton.h"

@protocol DistCalendarDelegate <NSObject>

-(NSDictionary *)calendarDidHaveData:(NSDate *)day;
//点击某个日期
-(void)calendarDidTapOnDay:(NSDate *)day;
-(void)calendarTimeRangeChaned:(NSDate *)start end:(NSDate *)end;
-(void)calendarCreateCompleted;
@end

@interface DistCalendarView : UIView<UIScrollViewDelegate,DistCalendarItemDelegate>{
    DistCalendarItem *_calendar1;
    DistCalendarItem *_calendar2;
    DistCalendarItem *_calendar3;
    UIScrollView *_caleanderScrollViews;
    CGPoint _currentPoint;
    NSArray *_calendars;
    NSDate *_currentMonth;
    SysButton *_btnToday;
    NSTimer *_rangeChangeTimer;
    int _readyFlag;
    UIView *_maskView;
}

@property (nonatomic,retain) id<DistCalendarDelegate> delegate;

@property int calendarHeaderHeight;

-(void)reloadData;
-(void)setDay:(NSDate *)day;
-(void)showToday;
-(NSDate *)start;
-(NSDate *)end;

-(id)initWithFrameAndDelegate:(CGRect)frame caldendarDelegate:(id<DistCalendarDelegate>)calendarDelegate;

@end
