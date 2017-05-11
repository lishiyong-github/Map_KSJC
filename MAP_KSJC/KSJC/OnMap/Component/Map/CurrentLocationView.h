//
//  CurrentLocationView.h
//  zzzf
//
//  Created by zhangliang on 14-4-19.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface CurrentLocationView : UIView{
    NSTimer *_timer;
    UIImageView *_centerCircle;
}

@property (nonatomic,retain) AGSPoint *point;
@property (nonatomic,retain) NSString *device;
@property (nonatomic,retain) UIColor *color;

-(void)startAnimate;
-(void)stopAnimate;

@end
