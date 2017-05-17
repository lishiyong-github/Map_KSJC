//
//  GDMapView.h
//  KSJC
//
//  Created by shiyong_li on 2017/5/12.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserLocationModel;
@interface GDMapView : UIView

/**
 清除所有标注
 */
- (void)clearAnnotations;
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

/**
 显示线路
 */
- (void)showRoute;

/**
 展示项目位置

 @param userLocation 当前的项目点的具体定位
 */
- (void)showProjectLocation:(UserLocationModel *)userLocation;

/**
 获取当前位置

 @return return CLLocationCoordinate2D
 */
- (NSArray *)getLocation;
@end
