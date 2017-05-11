//
//  CurrentLocationView.m
//  zzzf
//
//  Created by zhangliang on 14-4-19.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "CurrentLocationView.h"

@implementation CurrentLocationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _centerCircle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        _centerCircle.image = [UIImage imageNamed:@"point-green-s"];
        [self addSubview:_centerCircle];
    }
    return self;
}

-(void)createCircle{
    
    CALayer *circle = [CALayer layer];
    circle.frame = CGRectMake(12, 12, 24, 24);
    circle.cornerRadius = 12;
    UIColor *defaultColor = self.color;
    if (nil==defaultColor) {
        defaultColor = [UIColor colorWithRed:48.0/255.0 green:185.0/255.0 blue:0 alpha:1];
    }
    circle.borderColor = defaultColor.CGColor;
    circle.borderWidth = 1;
    circle.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:204.0/255.0 blue:0 alpha:.4].CGColor;
    circle.speed = .1;
    [self.layer addSublayer:circle];
    [self performSelector:@selector(play:) withObject:circle afterDelay:.1];
}

-(void)startAnimate{
    if (nil==_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(createCircle) userInfo:nil repeats:YES];
    }
}

-(void)stopAnimate{
    if (nil!=_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)play:(CALayer *)lay{
    lay.frame = CGRectMake(0, 0, 48, 48);
    lay.cornerRadius = 24;
    lay.borderColor = [UIColor colorWithWhite:0 alpha:0].CGColor;
    lay.backgroundColor = [UIColor colorWithWhite:0 alpha:0].CGColor;
    [self performSelector:@selector(removeLayer:) withObject:lay afterDelay:1.5];
}

-(void)removeLayer:(CALayer *)lay{
    [lay removeFromSuperlayer];
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
