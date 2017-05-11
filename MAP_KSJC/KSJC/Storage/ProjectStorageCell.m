//
//  ProjectStorageCell.m
//  zzzf
//
//  Created by mark on 14-2-19.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "ProjectStorageCell.h"

@implementation ProjectStorageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
//    if (selected) {
//        self.backgroundColor=[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
//        [self.lblDateTime setTextColor:[UIColor whiteColor]];
//        [self.lblProjectName setTextColor:[UIColor whiteColor]];
//    }else{
//        self.backgroundColor=[UIColor whiteColor];
//        [self.lblDateTime setTextColor:[UIColor colorWithRed:86.0/255.0 green:151.0/255.0 blue:170.0/255.0 alpha:1]];
//        [self.lblProjectName setTextColor:[UIColor blackColor]];
//    }
}

-(void)setProject:(ProjectInfo *)value{
    _project=value;
    self.lblProjectName.text = _project.name;
    self.lblCompany.text = _project.address;
    self.lblDateTime.text = _project.time;
    self.lblProjectSize.text=@"";
}
-(ProjectInfo *)project{
    return _project;
}

@end
