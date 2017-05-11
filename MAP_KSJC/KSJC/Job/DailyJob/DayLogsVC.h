//
//  DayLogsVC.h
//  KSJC
//
//  Created by 叶松丹 on 2016/11/21.
//  Copyright © 2016年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyJobView.h"
@protocol DayLogsVCDelegate <NSObject>

@optional
- (void)showLogsOfdayWithDayTime:(NSString *)logTime withDict:(NSDictionary *)dict;

-(void)mapShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext;
-(void)mapShouldShowFiles:(NSArray *)files at:(int)index;




@end
@interface DayLogsVC : UIViewController
@property(nonatomic,strong) UITableView *logTableView;
@property(nonatomic,strong) NSArray *logArray;
@property (nonatomic,weak)id<DayLogsVCDelegate> delegate;
@property (nonatomic,strong) DailyJobView *jobView;
@property (nonatomic,strong)NSString *dayTime;


@end
