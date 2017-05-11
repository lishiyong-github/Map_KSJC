//
//  JobSelectorViewController.h
//  zzzf
//
//  Created by dist on 14-1-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JobSelectorDelegate <NSObject>

-(void)jobSelected:(int)index;

@end

@interface JobSelectorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *_jobs;
    NSString *_winTitle;
}

@property (weak, nonatomic) IBOutlet UITableView *jobListControl;
@property (nonatomic,retain) id<JobSelectorDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
-(void)setJobs:(NSMutableArray *)jobs;
-(void)setTitleText:(NSString *)title;
@end
