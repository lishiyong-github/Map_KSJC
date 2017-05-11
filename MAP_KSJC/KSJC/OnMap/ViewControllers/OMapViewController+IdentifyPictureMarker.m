//
//  OMapViewController+IdentifyPictureMarker.m
//  zzzf
//
//  Created by Aaron on 14-3-9.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController+IdentifyPictureMarker.h"

typedef enum {
    EmbeddedMapView = 0,
    EmbeddedWebView,
    CustomInfoView,
    SimpleView
} GraphicType;

@implementation OMapViewController (IdentifyPictureMarker)

-(void)creatPictureMarkGraphics:(NSInteger)selectIndex pictureMarkPointsDataSource:(NSMutableArray*)pictureMarkPoints{
    [self removeImageViews];
    _graphicsArray = [[NSMutableArray alloc]init];
    _imageViewsArray = [[NSMutableArray alloc]init];
    AGSMutablePolygon* zoomPolygon = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
    //添加环
    [zoomPolygon addRingToPolygon];
    for (NSDictionary *dic in pictureMarkPoints)
    {
        NSString *type = [dic objectForKey:@"type"];
        NSString *orgId = [dic objectForKey:@"orgId"];
//        NSString *time = [dic objectForKey:@"time"];
        NSString *x = [dic objectForKey:@"x"];
        NSString *y = [dic objectForKey:@"y"];
        NSMutableDictionary *graphicAttributes = [NSMutableDictionary dictionaryWithDictionary:dic];
        if (x.length == 0 || y.length==0)
            continue;
        AGSPoint *graphicPoint = [AGSPoint pointWithX:[x doubleValue] y:[y doubleValue] spatialReference:self.mapView.spatialReference];
        //添加点
        [zoomPolygon addPointToRing:graphicPoint];
        NSString *bussinessICOName = [self themeICOName:[orgId intValue] type:type];
        AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:bussinessICOName];
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:graphicPoint symbol:graphicSymbol attributes:graphicAttributes];
        if ([self.mapView.visibleArea.envelope containsPoint: graphicPoint])
        {
            CGPoint screenPnt = [self.mapView toScreenPoint:graphicPoint];
            UIImageView * imageView = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:bussinessICOName]];
            
            [_graphicsArray addObject:graphic];
            [_imageViewsArray addObject:imageView];
            
            CGRect endFrame = CGRectMake(screenPnt.x-18, screenPnt.y-18, 36, 36);
            imageView.frame = CGRectMake(endFrame.origin.x, endFrame.origin.y-20, 36, 36);
            imageView.alpha = 0;
            [self.mapView addSubview:imageView];
            
            [UIView animateWithDuration:1 animations:^{
                [imageView setFrame:endFrame];
                imageView.alpha = 1;
            }
                             completion:^(BOOL finished){
                                 if (finished){
                                     //[self.pictureGraphicsLayer addGraphic:graphic];
                                     //[imageView removeFromSuperview];
                                 }
                             }];
        }
        else{
            [self.pictureGraphicsLayer addGraphic:graphic];
            [self.mapView zoomToGeometry:zoomPolygon withPadding:5.0 animated:YES];
            [self stopped];
        }
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)stopped{
    if (nil != _graphicsArray && [_graphicsArray count]>0) {
        [self.pictureGraphicsLayer addGraphics:_graphicsArray];
        [_graphicsArray removeAllObjects];
    }
    [self removeImageViews];
}
-(void)removeImageViews{
    if (nil != _imageViewsArray && [_imageViewsArray count]>0) {
        for (int i = 0; i< [_imageViewsArray count]; i++) {
            UIImageView * imageView = [_imageViewsArray objectAtIndex:i];
            [imageView removeFromSuperview];
        }
        [_imageViewsArray removeAllObjects];
    }
}
#pragma clang diagnostic pop


-(NSString*)themeICOName:(NSInteger)orgID type:(NSString*)type{
    NSString *themeICOName = [[self imageNameColor:orgID] objectForKey:type];
    return themeICOName;
}
-(NSMutableDictionary*)imageNameColor:(NSInteger)orgID
{
    NSMutableDictionary *imageNames = [[NSMutableDictionary alloc]init];
    NSString *imageNameColor = nil;
    switch (orgID) {
        case 1:
            imageNameColor = @"red";
            break;
        case 2:
            imageNameColor = @"green";
            break;
        case 3:
            imageNameColor = @"orange";
            break;
        case 4:
            imageNameColor = @"blue";
            break;
        default:
            imageNameColor = @"red";
            break;
    }
    NSString *home = [NSString stringWithFormat:@"home_%@.png",imageNameColor];
    NSString *camera = [NSString stringWithFormat:@"Camera_%@.png",imageNameColor];
    NSString *wei = [NSString stringWithFormat:@"wei_%@.png",imageNameColor];
    NSString *stop = [NSString stringWithFormat:@"stop_%@.png",imageNameColor];
    NSString *ji = [NSString stringWithFormat:@"ji_%@.png",imageNameColor];
    NSString *gai = [NSString stringWithFormat:@"gai_%@.png",imageNameColor];
    NSString *zhuan = [NSString stringWithFormat:@"zhuan_%@.png",imageNameColor];
    NSString *zhu = [NSString stringWithFormat:@"zhu_%@.png",imageNameColor];
    NSString *ding = [NSString stringWithFormat:@"ding_%@.png",imageNameColor];
    NSString *wai = [NSString stringWithFormat:@"wai_%@.png",imageNameColor];
    [imageNames setValue:home forKey:@"home"];
    [imageNames setValue:camera forKey:@"photos"];
    [imageNames setValue:wei forKey:@"wei"];
    [imageNames setValue:stop forKey:@"stopworkforms"];
    [imageNames setValue:ji forKey:@"ji"];
    [imageNames setValue:gai forKey:@"gai"];
    [imageNames setValue:zhuan forKey:@"zhuan"];
    [imageNames setValue:zhu forKey:@"zhu"];
    [imageNames setValue:ding forKey:@"ding"];
    [imageNames setValue:wai forKey:@"wai"];
    return imageNames;
}

-(BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint{
    self.mapView.callout.customView = nil;
    AGSGraphic* graphic = (AGSGraphic*)feature;
    NSDictionary *d = [graphic allAttributes];
    if ([layer.name isEqualToString:@"CurrentDailyGraphicsLayer"]) {
        NSString *t = [NSString stringWithFormat:@"%@-%@-%@",[d objectForKey:@"dept"],[d objectForKey:@"user"],[d objectForKey:@"lasttime"]];
        self.mapView.callout.title = t;
    }
    else if([layer.name isEqualToString:@"PictureGraphicsLayer"]){
        self.mapView.callout.title = [d objectForKey:@"name"];
        self.mapView.callout.detail = [d objectForKey:@"time"];
        self.mapView.callout.accessoryButtonHidden = YES;
        NSString *t = [d objectForKey:@"type"];
        if ([t isEqualToString:@"stopworkforms"]) {
            [self showDetailPanelAt:[[d objectForKey:@"fatherId"] intValue] photoCode:nil];
        }else if([t isEqualToString:@"photos"]){
            [self showDetailPanelAt:[[d objectForKey:@"fatherId"] intValue] photoCode:[d objectForKey:@"code"]];
        }
        
    }
    return YES;
}
@end
