//
//  WMTSLayerInfoDelegate.h
//  WMTSMap
//
//  Created by Aaron on 14-1-17.
//  Copyright (c) 2014年 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMTSLayerInfo.h"
#import "WMTSLayer.h"

@interface WMTSLayerInfoDelegate : NSObject
-(WMTSLayerInfo*)getLayerInfo:(layerTypes) type;
@end
