//
//  WMTSLayer.h
//  WMTSMap
//
//  Created by Aaron on 14-1-17.
//  Copyright (c) 2014年 Aaron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "WMTSLayerInfo.h"

typedef enum {
    SHT =0,      /*底图*/
    GHDL = 1,    /*规划路线*/
    YXT = 2,     /*影像图*/
    DM = 3,      /*地名 5-11*/
    XZDL = 4,    /*现状路网 (无效)*/
    KONGGUI = 5, /*控规*/
    XZQHBX = 6,  /*行政区划边线*/
    XZLX = 7,    /*选址蓝线*/
    YDHX = 8,     /*用地红线*/
    RCXC = 9,     /*日常巡查*/
} layerTypes;

@interface WMTSLayer : AGSTiledServiceLayer
{
@protected
	AGSTileInfo* _tileInfo;
	AGSEnvelope* _fullEnvelope;
	AGSUnits _units;
    WMTSLayerInfo* layerInfo;
    NSOperationQueue* requestQueue;
}
-(id)initWithLayerType:(layerTypes) type LocalServiceURL:(NSString *)url error:(NSError**) outError;
@end
