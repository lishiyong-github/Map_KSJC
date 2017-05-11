//
//  WMTSTileOperation.h
//  WMTSMap
//
//  Created by Aaron on 14-1-17.
//  Copyright (c) 2014年 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "WMTSLayerInfo.h"

@interface WMTSTileOperation : NSOperation
@property (nonatomic,retain) AGSTileKey* tileKey;
@property (nonatomic,retain) id target;
@property (nonatomic,assign) SEL action;
@property (nonatomic,retain) NSData* imageData;
@property (nonatomic,retain) WMTSLayerInfo* layerInfo;

- (id)initWithTileKey:(AGSTileKey *)tileKey TiledLayerInfo:(WMTSLayerInfo *)layerInfo target:(id)target action:(SEL)action;
@end
