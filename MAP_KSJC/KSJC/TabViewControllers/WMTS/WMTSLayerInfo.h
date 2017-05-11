//
//  WMTSLayerInfo.h
//  WMTSMap
//
//  Created by Aaron on 14-1-17.
//  Copyright (c) 2014年 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
@class AGSPoint;


@interface WMTSLayerInfo : NSObject
{
@private
    __unsafe_unretained NSString *_url;
    __unsafe_unretained NSString *_layerName;
    int _minZoomLevel;
    int _maxZoomLevel;
    double _xMin;
    double _yMin;
    double _xMax;
    double _yMax;
    int _tileWidth;
    int _tileHeight;
    __unsafe_unretained NSMutableArray *_lods;
    int _dpi;
    int _srid;
    __unsafe_unretained AGSPoint *_origin;
    __unsafe_unretained NSString *_tileMatrixSet;
    __unsafe_unretained AGSSpatialReference *_spatialReference;
}
@property (nonatomic,assign) NSString *url;
@property (nonatomic,assign) NSString *layerName;
@property (nonatomic,assign) int minZoomLevel;
@property (nonatomic,assign) int maxZoomLevel;
@property (nonatomic,assign) double xMin;
@property (nonatomic,assign) double yMin;
@property (nonatomic,assign) double xMax;
@property (nonatomic,assign) double yMax;
@property (nonatomic,assign) int tileWidth;
@property (nonatomic,assign) int tileHeight;
@property (nonatomic,assign) NSMutableArray *lods;
@property (nonatomic,assign) int dpi;
@property (nonatomic,assign) int srid;
@property (nonatomic,assign) AGSPoint *origin;
@property (nonatomic,assign) NSString *tileMatrixSet;
@property (nonatomic,assign) AGSSpatialReference *spatialReference;

@end
