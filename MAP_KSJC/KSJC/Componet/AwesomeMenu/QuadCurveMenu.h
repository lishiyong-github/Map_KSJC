//
//  QuadCurveMenu.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuadCurveMenuItem.h"

@protocol QuadCurveMenuDelegate;

@interface QuadCurveMenu : UIView <QuadCurveMenuItemDelegate>
{
    NSArray *_menusArray;
    int _flag;
    NSTimer *_timer;
    QuadCurveMenuItem *_addButton;
    float NEARRADIUS;
    float ENDRADIUS ;
    float FARRADIUS ;
    CGPoint STARTPOINT;
    float TIMEOFFSET;
    float ANGLE;
    NSMutableArray *_menuItems;
    //id<QuadCurveMenuDelegate> _delegate;
    
}


@property (nonatomic, copy) NSArray *menusArray;
@property (nonatomic, getter = isExpanding)     BOOL expanding;
@property (nonatomic, retain) id<QuadCurveMenuDelegate> delegate;
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray;
-(QuadCurveMenuItem *)menuAt:(int)index;
-(id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray nearRadius:(float)nearRadius endRadius:(float)endRadius farRadius:(float)farRadius startPoint:(CGPoint)startPoint timeOffset:(float)timeOffset angle:(float)angle;
-(void)setCenterButtonVisible:(BOOL)visible;
@end

@protocol QuadCurveMenuDelegate <NSObject>
- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx;
@end