//
//  PDATableViewCell.m
//  zzzf
//
//  Created by dist on 13-12-31.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "PDATableViewCell.h"

@implementation PDATableViewCell

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
    if (selected) {
        self.contentView.backgroundColor=[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
    }else{
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    // Configure the view for the selected state
}

-(void)setPDAInfo:(NSMutableDictionary *)data{
    
    if ([[data objectForKey:@"STATUS"] isEqualToString:@"1"]) {
        self.iconStatus.backgroundColor = [UIColor greenColor];
    }else{
        self.iconStatus.backgroundColor = [UIColor grayColor];
    }
    self.lblLastPosition.text = [data objectForKey:@"DEVICENUMBER"];
    self.lblPDAName.text = [data objectForKey:@"DEVICENAME"];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.contentView.backgroundColor=[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
    [UIView commitAnimations];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self clearBg];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self clearBg];
}

-(void)clearBg{
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:0.6];
    //动画的内容
    self.contentView.backgroundColor=[UIColor whiteColor];
    //动画结束
    [UIView commitAnimations];
}


@end
