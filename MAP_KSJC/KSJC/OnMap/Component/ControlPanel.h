//
//  MapControlPanel.h
//  zzOneMap
//
//  Created by zhangliang on 13-12-4.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysButton.h"

@protocol ControlPanelDelegate <NSObject>

-(void)controlPanelDidBack;
-(void)controlPanelDidClose;

@end

@interface ControlPanel : UIView{
    UIView *_parentView;
    NSTimer *_displayWaitTimer;
    UIView *_maskView;
    UIButton *_titleButton;
    UIButton *_closeButton;
}

@property (nonatomic,retain) UIScrollView *contentView;
@property (nonatomic,retain) UIView *headerPanel;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) id<ControlPanelDelegate> delegate;

-(void)show;
-(void)hide;

-(void)moveToHide;
@end
