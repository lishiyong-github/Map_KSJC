//
//  DistCalendarDay.h
//  DistCalendar
//
//  Created by zhangliang on 13-12-10.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DistCalendarDayDelegate <NSObject>

-(void)onDayTap:(NSDate *)date;

@end

@interface DistCalendarOfDay : UIView{
    UIColor *_defaultBackground;
    BOOL _isToday;
//    BOOL _isMonth;
    UIImageView *_iconHaveData;
    UIImageView *_iconHavePhoto;
    UIImageView *_iconHaveForm;
}
@property(nonatomic,assign) BOOL isMonth;

@property (nonatomic,retain) NSDate *day;

@property (nonatomic,retain) id<DistCalendarDayDelegate> delegate;

@property (nonatomic,retain) UILabel *dayLabel;

@property (nonatomic) BOOL selected;

@property (nonatomic) BOOL haveData;

@property (nonatomic,retain) NSDictionary *data;

@end
