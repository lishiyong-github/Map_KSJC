//
//  SysButton.m
//  zzzf
//
//  Created by zhangliang on 13-11-28.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "SysButton.h"

@implementation SysButton

@synthesize defaultBackground=_defaultBackground;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _defaultBackground=self.backgroundColor;
        [self clearBg];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _defaultBackground = self.backgroundColor;
        [self clearBg];
    }
    return self;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    [self setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1]];
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
    if (self.selected) {
        [self setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:100]];
    }else{
        [self setBackgroundColor:_defaultBackground];
    }
    //动画结束
    [UIView commitAnimations];
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        [self setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:100]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }else{
        [self setBackgroundColor:_defaultBackground];
    }
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
