//
//  LayerManager.h
//  zzOneMap
//
//  Created by zhangliang on 13-12-4.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlPanel.h"
#import "LayerCell.h"
#import "WMTSLayer.h"
#import "MapConfig.h"

typedef enum : NSUInteger {
    XZQHMAP=0,
    IMGMAP=1,
    DXTMAP=2
} BaseMapType;

@protocol LayerManagerDelegate <NSObject>

-(void)LayerVisibleChanged:(NSString *)layerURL LayerType:(NSString*)layerType visible:(BOOL)visible;
@end

@interface LayerManager : ControlPanel<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_layerTableView;
    NSMutableArray *_layerSource;
}

@property (nonatomic,retain) id<LayerManagerDelegate> layerDelegate;

+(void) addAGSLayer:(AGSMapView*)mapView LayerName:(layerTypes)layerName getLayerType:(NSString *)serverType layerVisible:(BOOL)visible;
+(void) insertAGSLayer:(AGSMapView*)mapView LayerName:(layerTypes)layerName setLayerIndex:(int) index getLayerType:(NSString *)serverType layerVisible:(BOOL)visible;
+(AGSDynamicMapServiceLayer*)addAGSDynamicMapServiceLayer:(AGSMapView*)mapView;
+(NSString*)mapServiceUrl:(NSInteger)layerIndex;

//modify by leoyang 20161109
+(void) loadBaseMap:(AGSMapView *)mapView;
+(void) setBaseMap:(AGSMapView *)mapView mapType:(BaseMapType)type;
+(void) loadDynamicMap:(AGSMapView *)mapView withUrl:(NSString *)url;
+(void) setDynamicLayer:(AGSMapView *)mapView withLayerName:(NSString *)name ids:(NSArray *)ids isVisible:(BOOL)visible;
@end
