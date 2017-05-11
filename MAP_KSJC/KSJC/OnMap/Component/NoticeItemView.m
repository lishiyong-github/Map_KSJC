//
//  NoticeItemView.m
//  zhengzhou
//
//  Created by zhangliang on 14-1-13.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "NoticeItemView.h"

@implementation NoticeItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createChildren];
    }
    return self;
}

-(void)createChildren{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    _titleLabel.font =[_titleLabel.font fontWithSize:16];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.frame.size.width, 20)];
    _dateLabel.font = [_dateLabel.font fontWithSize:12];
    _dateLabel.textColor = [UIColor grayColor];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, 50)];
    _contentLabel.font = [_contentLabel.font fontWithSize:13];
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.numberOfLines=2;
    
    _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 115, self.frame.size.width, 1)];
    _bottomLine.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
    
    [self addSubview:_titleLabel];
    [self addSubview:_dateLabel];
    [self addSubview:_contentLabel];
    [self addSubview:_bottomLine];
}

-(void)setData:(NSMutableDictionary *)data{
    if (nil==_titleLabel) {
        [self createChildren];
    }
    _titleLabel.text = [data objectForKey:@"title"];
    _dateLabel.text= [data objectForKey:@"date"];
    _contentLabel.text = [data objectForKey:@"content"];
    _data=data;
}

-(void)layoutSubviews{
    _titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, 20);
    _dateLabel.frame = CGRectMake(0, 25, self.frame.size.width, 20);
    _contentLabel.frame = CGRectMake(0, 50, self.frame.size.width, 50);
    _bottomLine.frame = CGRectMake(0, 115, self.frame.size.width, 1);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
