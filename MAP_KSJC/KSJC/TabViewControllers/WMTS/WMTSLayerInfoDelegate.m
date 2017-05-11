//
//  WMTSLayerInfoDelegate.m
//  WMTSMap
//
//  Created by Aaron on 14-1-17.
//  Copyright (c) 2014年 Aaron. All rights reserved.
//

#import "WMTSLayerInfoDelegate.h"

#define SHT @"http://218.75.221.182:8082/TileServer/httile.ashx/SHT/tile"/*底图*/
#define GHDL @"http://218.75.221.182:8082/TileServer/httile.ashx/GHDL201404/tile"/*规划路线 3-11*/
#define YXT @"http://218.75.221.182:8082/TileServer/httile.ashx/YXT/tile"/*影像图 3-11*/
#define DM @"http://218.75.221.182:8082/TileServer/httile.ashx/DM/tile"/*地名 5-11*/
#define XZDL @"http://218.75.221.182:8082/TileServer/httile.ashx/YDHX/tile"/*现状路网 (无效)*/
#define KONGGUI @"http://218.75.221.182:8082/TileServer/httile.ashx/KONGGUI201404/tile"/*控规 3-11*/
#define XZQHBX  @"http://218.75.221.182:8082/TileServer/httile.ashx/XZQHBX/tile"/*行政区划边线 3-11*/
//#define SRID_MERCATOR 4326


#define X_MIN_MERCATOR 1000
#define Y_MIN_MERCATOR 2634013.25
#define X_MAX_MERCATOR 740491.26
#define Y_MAX_MERCATOR 3570640.13

#define _minZoomLevel 0
#define _maxZoomLevel 10
#define _tileWidth 256
#define _tileHeight 256
#define _dpi 96
#define _originX 0
#define _originY 3600000

@implementation WMTSLayerInfoDelegate
-(WMTSLayerInfo*)getLayerInfo:(layerTypes) type{
    //    AGSSpatialReference *spatialReference =[[AGSSpatialReference alloc] initWithWKID:SRID_MERCATOR];
    NSString *spatialReferenceStr = @"PROJCS[\"Xian_1980_3_Degree_GK_CM_113.08E\",GEOGCS[\"GCS_Xian_1980\",DATUM[\"D_Xian_1980\",SPHEROID[\"Xian_1980\",6378140.0,298.257]],PRIMEM[\"Greenwich\",0.0],UNIT[\"Degree\",0.0174532925199433]],PROJECTION[\"Gauss_Kruger\"],PARAMETER[\"False_Easting\",500000.0],PARAMETER[\"False_Northing\",0.0],PARAMETER[\"Central_Meridian\",113.1333333333333],PARAMETER[\"Scale_Factor\",1.0],PARAMETER[\"Latitude_Of_Origin\",0.0],UNIT[\"Meter\",1.0]]";
    AGSSpatialReference *spatialReference = [[AGSSpatialReference alloc]initWithWKT:
                                             spatialReferenceStr];
    WMTSLayerInfo *layerInfo = [[WMTSLayerInfo alloc]init];
    //normal parameters
    layerInfo.dpi = _dpi;
    layerInfo.tileHeight = _tileHeight;
    layerInfo.tileWidth = _tileWidth;
    layerInfo.minZoomLevel = _minZoomLevel;
    layerInfo.maxZoomLevel = _maxZoomLevel;
    layerInfo.spatialReference = spatialReference;
    //sr
    
    //    layerInfo.srid = SRID_MERCATOR;
    layerInfo.xMax = X_MAX_MERCATOR;
    layerInfo.xMin = X_MIN_MERCATOR;
    layerInfo.yMax = Y_MAX_MERCATOR;
    layerInfo.yMin = Y_MIN_MERCATOR;
    //        layerInfo.tileMatrixSet = kTILE_MATRIX_SET_MERCATOR;
    layerInfo.origin = [AGSPoint pointWithX:_originX y:_originY spatialReference:spatialReference];
    
    //wgs84:*(0.0254000508/96)/111194.872221777
    //mecator:*(0.0254000508/96)
    layerInfo.lods = [NSMutableArray arrayWithObjects:
                      [[AGSLOD alloc] initWithLevel:1 resolution:1222.99 scale: 4622333.68],
                      [[AGSLOD alloc] initWithLevel:2 resolution:305.75 scale: 1155583.42],
                      [[AGSLOD alloc] initWithLevel:3 resolution:76.44 scale: 288895.85],
                      [[AGSLOD alloc] initWithLevel:4 resolution:38.22 scale: 144447.93],
                      [[AGSLOD alloc] initWithLevel:5 resolution:19.11 scale: 72223.96],
                      [[AGSLOD alloc] initWithLevel:6 resolution:9.55 scale: 36111.98],
                      [[AGSLOD alloc] initWithLevel:7 resolution:4.78 scale: 18055.99],
                      [[AGSLOD alloc] initWithLevel:8 resolution:2.39 scale: 9028],
                      [[AGSLOD alloc] initWithLevel:9 resolution:1.19 scale: 4514],
                      [[AGSLOD alloc] initWithLevel:10 resolution:0.6 scale: 2257],
                      [[AGSLOD alloc] initWithLevel:11 resolution:0.2986 scale: 1128.5],
                      [[AGSLOD alloc] initWithLevel:12 resolution:0.1493 scale: 564.25],
                      nil ];
    //other parameters
    switch (type) {
        case 0:
            layerInfo.url = SHT;
            break;
        case 1:
            layerInfo.url = GHDL;
            break;
        case 2:
            layerInfo.url = YXT;
            break;
        case 3:
            layerInfo.url = DM;
            break;
        case 4:
            layerInfo.url = XZDL;
            break;
        case 5:
            layerInfo.url = KONGGUI;
            break;
        case 6:
            layerInfo.url = XZQHBX;
            break;
        default:
            break;
    }
    //加载wmts服务时post请求服务地址，解决时间长未访问地图，不出地图问题。
    NSURL *url = [NSURL URLWithString:layerInfo.url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    return layerInfo;
}
@end
