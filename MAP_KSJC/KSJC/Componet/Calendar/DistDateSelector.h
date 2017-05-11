//
//  DistDateSelector.h
//  zzzf
//
//  Created by zhangliang on 14-2-23.
//  Copyright (c) 2014年 dist. All rights reserved.
//日期选择器


#import <UIKit/UIKit.h>
#import "SysButton.h"

@protocol DistDateSelectorDelegate;

@interface DistDateSelector : UIView{
    SysButton *_btnPrevious;
    SysButton *_btnYear;
    SysButton *_btnMonth;
    SysButton *_btnWeek;
    SysButton *_btnNext;
    SysButton *_currentSelectedBtn;
    NSDate *_date;
    int _duration;
    NSString *_dateString;
}

@property (nonatomic,retain) id<DistDateSelectorDelegate> delegate;
@property (nonatomic,retain) NSDate *start;
@property (nonatomic,retain) NSDate *end;


-(NSString *)dateString;

@end

@protocol DistDateSelectorDelegate <NSObject>

-(void)distDateSelector:(DistDateSelector *)selector dateDisChanged:(NSDate *)start endDate:(NSDate *)end;

@end
