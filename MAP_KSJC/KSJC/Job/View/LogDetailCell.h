//
//  MeetingDetailCell.h
//  HAYD
//
//  Created by 叶松丹 on 16/8/30.
//  Copyright © 2016年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MeetingModel.h"

@interface LogDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UILabel *xcPerson;
@property (weak, nonatomic) IBOutlet UILabel *gczTFlabel;
@property (weak, nonatomic) IBOutlet UILabel *logTime;
@property (weak, nonatomic) IBOutlet UILabel *yxTFlabel;
@property (weak, nonatomic) IBOutlet UILabel *jcqk;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

//-(void)setMeetingDetailCell:(MeetingModel *)model;


@end
