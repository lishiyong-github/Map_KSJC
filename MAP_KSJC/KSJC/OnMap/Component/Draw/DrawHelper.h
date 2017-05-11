//
//  DrawHelper.h
//  zzzf
//
//  Created by Aaron on 14-3-4.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface DrawHelper : NSObject
+ (void)drawPolyLine:(AGSMapView*)mapView AGSPointArray:(NSMutableArray*)pointArray AGSGraphicsLayer:(AGSGraphicsLayer*)graphicsLayer;
+ (void)drawPolyLine:(AGSMapView*)mapView AGSPointArray:(NSMutableArray*)pointArray AGSGraphicsLayer:(AGSGraphicsLayer*)graphicsLayer lineColor:(UIColor*)color Attributes:(NSDictionary*)attributes;
@end
