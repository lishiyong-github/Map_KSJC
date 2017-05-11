//
//  WaitingView.m
//  zzzf
//
//  Created by dist on 14-3-26.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "WaitingView.h"

@implementation WaitingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIView *maskView = [[UIView alloc] initWithFrame:frame];
        maskView.alpha = .6;
        maskView.backgroundColor = [UIColor whiteColor];
        [self addSubview:maskView];
        
        int w = 250;
        int h = 50;
        
        UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2-w/2, frame.size.height/2-h/2, w, h)];
        centerView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
        centerView.alpha=1;
        centerView.layer.shadowColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1].CGColor;
        centerView.layer.shadowOpacity = .6;
        centerView.layer.shadowOffset = CGSizeMake(0,1);
        centerView.layer.cornerRadius = 5;
        
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        aiv.color = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1];
        [aiv startAnimating];
        aiv.frame = CGRectMake(30,10, 32, 32);
        [centerView addSubview:aiv];
        
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 180, 30)];
        //[_msgLabel setTextAlignment:NSTextAlignmentCenter];
        _msgLabel.text = self.msg;
        //_msgLabel.backgroundColor = [UIColor redColor];
        [centerView addSubview:_msgLabel];
        
        [self addSubview:centerView];
        
        
    }
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
//    if (orientation == UIInterfaceOrientationLandscapeLeft) {
//        CGAffineTransform rotation = CGAffineTransformMakeRotation(3*M_PI/2);
//        [self setTransform:rotation];
//    }
//    
//    if (orientation == UIInterfaceOrientationLandscapeRight) {
//        CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI/2);
//        [self setTransform:rotation];
//    }
    return self;
}

-(void)setMsg:(NSString *)msg{
    _msg = msg;
    if (_msgLabel) {
        _msgLabel.text = msg;
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
