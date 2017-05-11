//
//  TouchableMapView.h
//  zzzf
//
//  Created by Aaron on 14-3-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@protocol MapViewTouchDelegate <NSObject>
@optional
-(void)stopped;

@end
@interface TouchableMapView : AGSMapView
@property (nonatomic,retain) id<MapViewTouchDelegate> mapTouchDelegate;
@end
