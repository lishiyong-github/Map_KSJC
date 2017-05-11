//
//  MapControlPanel.m
//  zzOneMap
//
//  Created by zhangliang on 13-12-4.
//  Copyright (c) 2013年 dist. All rights reserved.
//


#import "ControlPanel.h"
#import "RNFrostedSidebar.h"

@implementation ControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createView];
    }
    return self;
}

-(void)createView{
    self.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(-origionRect.size.width , 0, origionRect.size.width, origionRect.size.height);
    self.hidden = YES;
    self.frame = newRect;
    
    self.headerPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, origionRect.size.width, 60)];
    self.headerPanel.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    [self addSubview:self.headerPanel];
    
    self.contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 50, origionRect.size.width, origionRect.size.height-50)];
    [self addSubview:self.contentView];
    
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_titleButton setTitle:@"   主菜单" forState:UIControlStateNormal];
    
    _titleButton.frame = CGRectMake(5, 8, self.headerPanel.frame.size.width-78, self.headerPanel.frame.size.height-16);
    [_titleButton setImage:[UIImage imageNamed:@"button-back"] forState:UIControlStateNormal];
    [_titleButton setTitleColor:[UIColor colorWithRed:0 green:125.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    _titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    _closeButton.frame = CGRectMake(self.headerPanel.frame.size.width-70, 8, 70, self.headerPanel.frame.size.height-16);
    [_closeButton setTitleColor:[UIColor colorWithRed:0 green:125.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    
    
    [self.headerPanel addSubview:_titleButton];
    [self.headerPanel addSubview:_closeButton];
    
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    [_titleButton addGestureRecognizer:backTap];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [_closeButton addGestureRecognizer:tap];
    
    UIView *rightLine =[[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-1,0,1,self.frame.size.height)];
    rightLine.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.8];
    [self addSubview:rightLine];
    //self.clipsToBounds = NO;
}


-(void)show{
    
    self.layer.opacity = 0;
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil) {
        controller = controller.presentedViewController;
    }
    if (nil==_maskView) {
        _maskView = [[UIView alloc]initWithFrame:controller.view.bounds];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_maskView addGestureRecognizer:tap];
    }
    //[controller.view addSubview:_maskView];
    [controller.view addSubview:self];
    //UIImage *blurImage = [controller.view rn_screenshot];
    //blurImage = [blurImage applyBlurWithRadius:5 tintColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.73] saturationDeltaFactor:1.8 maskImage:nil];
    //[self setBackgroundColor:[UIColor colorWithPatternImage:blurImage]];
    
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(0 , 0, origionRect.size.width, origionRect.size.height);
    self.hidden = NO;
    self.frame = newRect;
    
    [UIView animateWithDuration:0.5 delay:.5 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.layer.opacity =1;
    } completion:nil];
    
    
    
}


-(void)hide{
    [self moveToHide];
    [self.delegate controlPanelDidClose];
}

-(void)back{
    [self moveToHide];
    [self.delegate controlPanelDidBack];
}

-(void)moveToHide{
    CGRect origionRect = self.frame;
    CGRect newRect = CGRectMake(-origionRect.size.width , 0, origionRect.size.width, origionRect.size.height);
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = newRect;
                     }
                     completion:^(BOOL finished){
                         if (finished){
                             self.hidden = YES;
                             [self removeFromSuperview];
                             [_maskView removeFromSuperview];
                         }
                     }];
}

@end
