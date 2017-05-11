//
//  DistCalendarItem.h
//  DistCalendar
//
//  Created by zhangliang on 13-12-10.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DistCalendarOfDay.h"

@protocol DistCalendarItemDelegate;

@class DistCalendarView;

@interface DistCalendarItem : UIView<DistCalendarDayDelegate>{
    UIView *_daysView;
    NSDate *_start;
    NSDate *_end;
    NSThread *_refreshThread;
    NSTimer *_delayRefreshTimer;
    BOOL _ready;
}

@property int calendarHeaderHeight;

@property (nonatomic,retain) DistCalendarView *owner;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,retain) NSArray *weekNames;
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,retain) id<DistCalendarItemDelegate> delegate;

-(NSDate *)start;
-(NSDate *)end;
-(void)refersh;


@end


@protocol DistCalendarItemDelegate <NSObject>

-(void)calendarItemReady:(DistCalendarItem *)item;

@end