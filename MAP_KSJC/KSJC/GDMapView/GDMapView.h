//
//  GDMapView.h
//  KSJC
//
//  Created by shiyong_li on 2017/5/12.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDMapView : UIView

/**
 设置地图的展示位置

 @param view superView
 @param frame 定位按钮的位置
 */
- (void)setLocationInView:(UIView *)view frame:(CGRect)frame;

/**
 显示检查记录轨迹
 */
- (void)showRecord;
@end
