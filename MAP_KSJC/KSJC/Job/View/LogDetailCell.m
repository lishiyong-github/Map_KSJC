//
//  MeetingDetailCell.m
//  HAYD
//
//  Created by 吴定如 on 16/8/30.
//  Copyright © 2016年 dist. All rights reserved.
//

#import "LogDetailCell.h"

@implementation LogDetailCell

//-(void)setMeetingDetailCell:(MeetingModel *)model
//{
//    _meetingTitle.text = model.meetingName;
//    _meetingHoster.text = model.HostUserName;
//    _meetingAddress.text = model.meetingAddress;
//    NSString *time = [model.meetingTime substringWithRange:NSMakeRange(11,5)];
//    _meetingTime.text = time;
//}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
