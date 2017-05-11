//
//  DrawHelper.m
//  zzzf
//
//  Created by Aaron on 14-3-4.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DrawHelper.h"

@implementation DrawHelper


+ (void)drawPolyLine:(AGSMapView*)mapView AGSPointArray:(NSMutableArray*)pointArray AGSGraphicsLayer:(AGSGraphicsLayer*)graphicsLayer{
    if ([pointArray count]==0)
        return;
    
    AGSMutablePolyline *polyLine = [[AGSMutablePolyline alloc]initWithSpatialReference:mapView.spatialReference];
    [polyLine addPathToPolyline];
    for(AGSPoint *point in pointArray){
        [polyLine addPointToPath:point];
    }
    AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
    myOutlineSymbol.color = [UIColor redColor];
    myOutlineSymbol.width = 4;
    myOutlineSymbol.style = AGSSimpleLineSymbolStyleSolid;
    AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:polyLine symbol:myOutlineSymbol attributes:nil];
    [graphicsLayer addGraphic:graphic];
}
+ (void)drawPolyLine:(AGSMapView*)mapView AGSPointArray:(NSMutableArray*)pointArray AGSGraphicsLayer:(AGSGraphicsLayer*)graphicsLayer lineColor:(UIColor*)color Attributes:(NSDictionary*)attributes{
    if ([pointArray count]==0)
        return;
    
    AGSMutablePolyline *polyLine = [[AGSMutablePolyline alloc]initWithSpatialReference:mapView.spatialReference];
    [polyLine addPathToPolyline];
    for(AGSPoint *point in pointArray){
        [polyLine addPointToPath:point];
    }
    AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
    myOutlineSymbol.color = color;
    myOutlineSymbol.width = 4;
    myOutlineSymbol.style = AGSSimpleLineSymbolStyleSolid;
    AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:polyLine symbol:myOutlineSymbol attributes:attributes];
    [graphicsLayer addGraphic:graphic];
}
@end

