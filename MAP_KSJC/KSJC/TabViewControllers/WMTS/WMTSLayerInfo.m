//
//  WMTSLayerInfo.m
//  WMTSMap
//
//  Created by Aaron on 14-1-17.
//  Copyright (c) 2014年 Aaron. All rights reserved.
//

#import "WMTSLayerInfo.h"

@implementation WMTSLayerInfo

@synthesize url = _url;
@synthesize layerName = _layerName;
@synthesize minZoomLevel = _minZoomLevel;
@synthesize maxZoomLevel = _maxZoomLevel;
@synthesize xMin = _xMin;
@synthesize yMin = _yMin;
@synthesize xMax = _xMax;
@synthesize yMax = _yMax;
@synthesize tileWidth = _tileWidth;
@synthesize tileHeight = _tileHeight;
@synthesize lods = _lods;
@synthesize dpi = _dpi;
@synthesize srid = _srid;
@synthesize origin = _origin;
@synthesize tileMatrixSet = _tileMatrixSet;
@synthesize spatialReference = _spatialReference;
@end
