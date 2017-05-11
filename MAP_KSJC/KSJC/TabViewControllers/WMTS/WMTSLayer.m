//
//  WMTSLayer.m
//  WMTSMap
//
//  Created by Aaron on 14-1-17.
//  Copyright (c) 2014年 Aaron. All rights reserved.
//

#import "WMTSLayer.h"
#import "WMTSTileOperation.h"
#import "WMTSLayerInfo.h"
#import "WMTSLayerInfoDelegate.h"

@implementation WMTSLayer
-(AGSUnits)units{
	return _units;
}

-(AGSSpatialReference *)spatialReference{
	return _fullEnvelope.spatialReference;
}

-(AGSEnvelope *)fullEnvelope{
	return _fullEnvelope;
}

-(AGSEnvelope *)initialEnvelope{
	//Assuming our initial extent is the same as the full extent
	return _fullEnvelope;
}

-(AGSTileInfo*) tileInfo{
	return _tileInfo;
}

#pragma mark -
-(id)initWithLayerType:(layerTypes) type LocalServiceURL:(NSString *)url error:(NSError**) outError{
    if (self = [super init]) {
        
        requestQueue = [[NSOperationQueue alloc] init];
        [requestQueue setMaxConcurrentOperationCount:11];
        /*get the currect layer info
         */
        
        //layerInfo为 WMTSLayerInfo模型(类似模型中的属性和方法)---根据类型
//        SHT =0,      /*底图*/
//        GHDL = 1,    /*规划路线*/
//        YXT = 2,     /*影像图*/
//        DM = 3,      /*地名 5-11*/
//        XZDL = 4,    /*现状路网 (无效)*/
//        KONGGUI = 5, /*控规*/
//        XZQHBX = 6,  /*行政区划边线*/
//        XZLX = 7,    /*选址蓝线*/
//        YDHX = 8,     /*用地红线*/
//        RCXC = 9,     /*日常巡查*/
        //生成对应的图层信息
        layerInfo = [[WMTSLayerInfoDelegate alloc] getLayerInfo:type];
        if ([url isEqual:[NSNull null]]) {
            layerInfo.url = url;
        }
        AGSSpatialReference* sr = layerInfo.spatialReference;
        _fullEnvelope = [[AGSEnvelope alloc] initWithXmin:layerInfo.xMin
                                                     ymin:layerInfo.yMin
                                                     xmax:layerInfo.xMax
                                                     ymax:layerInfo.yMax
                                         spatialReference:sr];
        
        _tileInfo = [[AGSTileInfo alloc]
                     initWithDpi:layerInfo.dpi
                     format :@"PNG8"
                     lods:layerInfo.lods
                     origin:layerInfo.origin
                     spatialReference :sr
                     tileSize:CGSizeMake(layerInfo.tileWidth,layerInfo.tileHeight)
                     ];
        [_tileInfo computeTileBounds:self.fullEnvelope];
        [super layerDidLoad];
    }
    return self;
}

#pragma mark -
#pragma AGSTiledLayer (ForSubclassEyesOnly)
- (void)requestTileForKey:(AGSTileKey *)key{
    NSLog(@"%@",key);
    //Create an operation to fetch tile from local cache
	WMTSTileOperation *operation =
    [[WMTSTileOperation alloc] initWithTileKey:key
                                TiledLayerInfo:layerInfo
                                        target:self
                                        action:@selector(didFinishOperation:)];
    
    
	//Add the operation to the queue for execution
    //[ [AGSRequestOperation sharedOperationQueue] addOperation:operation]; //you do bad things
    [requestQueue addOperation:operation];
}

- (void)cancelRequestForKey:(AGSTileKey *)key{
    //Find the OfflineTileOperation object for this key and cancel it
    for(NSOperation* op in [AGSRequestOperation sharedOperationQueue].operations){
        if( [op isKindOfClass:[WMTSTileOperation class]]){
            WMTSTileOperation* offOp = (WMTSTileOperation*)op;
            if([offOp.tileKey isEqualToTileKey:key]){
                [offOp cancel];
            }
        }
    }
}

- (void) didFinishOperation:(WMTSTileOperation*)op {
    //... pass the tile's data to the super class
    [super setTileData: op.imageData  forKey:op.tileKey];
}
@end
