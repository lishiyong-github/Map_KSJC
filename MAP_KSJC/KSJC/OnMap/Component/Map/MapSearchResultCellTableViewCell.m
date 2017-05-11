//
//  MapSearchResultCellTableViewCell.m
//  zzzf
//
//  Created by zhangliang on 14-4-16.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapSearchResultCellTableViewCell.h"

@implementation MapSearchResultCellTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTitle:(NSString *)title{
    self.lblName.text = title;
}

@end
