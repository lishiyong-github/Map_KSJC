//
//  MapLocationView.m
//  zzzf
//
//  Created by Aaron on 14-9-15.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapLocationView.h"
#import "LayerManager.h"
#import "GPS.h"

@implementation MapLocationView

SysButton *saveBtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createMapToolBar];
        self.touchDelegate = self;
        // register for pan notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:)
                                                     name:AGSMapViewDidEndPanningNotification object:nil];
        // register for zoom notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:)
                                                     name:AGSMapViewDidEndZoomingNotification object:nil];
        // Initialization code
        //初始化地图
        [self initMapViewStyle];
        //加载底图
        [LayerManager loadBaseMap:self];
        [LayerManager setBaseMap:self mapType:0];
        [LayerManager loadDynamicMap:self withUrl:KSJZHX];
        
        self.geomeryGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        [self addMapLayer:self.geomeryGraphicsLayer withName:@"GeometryGraphicsLayer"];
        //图形图层
        self.pictureGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        [self addMapLayer:self.pictureGraphicsLayer withName:@"PictureGraphicsLayer"];
    }
    return self;
}
-(void)initMapViewStyle{
    //修改地图背景
    self.gridLineWidth = 0;
    self.backgroundColor = [UIColor whiteColor];
}

//创建地图
-(void)createMapToolBar{
    UIView *toolView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 50)];
    toolView.backgroundColor = [UIColor whiteColor];
    UIView *splitView = [[UIView alloc]initWithFrame:CGRectMake(0, 2, toolView.frame.size.width, 1)];
    splitView.backgroundColor = [UIColor lightGrayColor];
    
    SysButton *backBtn = [[SysButton alloc]initWithFrame:CGRectMake(self.frame.size.width-110, 5, 100, 32)];
    [backBtn setImage:[UIImage imageNamed:@"ht.png"] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(mapBack) forControlEvents:UIControlEventTouchUpInside];
    
    saveBtn = [[SysButton alloc]initWithFrame:CGRectMake(self.frame.size.width-220, 5, 100, 32)];
    [saveBtn setImage:[UIImage imageNamed:@"button-allright.png"] forState:UIControlStateNormal];
    [saveBtn setTitle:@"确定" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(mapSaveProjectLocation) forControlEvents:UIControlEventTouchUpInside];
    
    
    [toolView addSubview:backBtn];
    //[toolView addSubview:saveBtn];
    [toolView addSubview:splitView];
    [self addSubview:toolView];
}
//地图返回按钮
-(void)mapBack{
    [self.delegate back];
}
-(void)mapSaveProjectLocation{
    [self.delegate saveProjectLocation];
}
-(void)activeSaveBtn:(BOOL)flag{
    saveBtn.enabled = flag;
}

//全图
-(void)zoomfull{
//    AGSEnvelope *defaultEnvelope=[[AGSEnvelope alloc] initWithXmin:479252.2100000001 ymin:3062138.3599999994 xmax:531460.7300000001 ymax:3087631.0999999996 spatialReference:self.spatialReference];
//    [self zoomToEnvelope:defaultEnvelope animated:YES];
    
    AGSEnvelope *defaultEnvelope=[[AGSEnvelope alloc] initWithXmin:DEFAULT_X_MIN ymin:DEFAULT_Y_MIN xmax:DEFAULT_X_MAX ymax:DEFAULT_Y_MAX spatialReference:self.spatialReference];
    [self zoomToEnvelope:defaultEnvelope animated:YES];
    
}
-(void)projectLocationForGPS:(NSString*)mapPointXY{
    
    if ([mapPointXY isEqualToString: @"0,0"]) {
        [GPS startMapGPS:0 AGSMapView:self];
    }
    else{
        [self zoomfull];
        [self creatProjectLocation:mapPointXY];
    }
}
-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features{
    
    NSArray *geomGraphics = [features objectForKey:@"GeometryGraphicsLayer"];
    NSArray *picGraphics = [features objectForKey:@"PictureGraphicsLayer"];
    
    if (geomGraphics || picGraphics) {
        
        AGSGraphic *graphic = nil;
        
        if (geomGraphics.count > 0) {
            graphic = [geomGraphics objectAtIndex:0];
        }
        
        if (picGraphics.count > 0) {
            graphic = [picGraphics objectAtIndex:0];
        }
        
        if (graphic) {
            [self showPopupForGraphic:graphic mapPoint:mappoint];
        }
    }
    
    /* 自定义标注
    [self creatProjectLocation:[NSString stringWithFormat:@"%f,%f",mappoint.x,mappoint.y]];
    [self activeSaveBtn:YES];
     */
}
-(void)creatProjectLocation:(NSString *)mapPointXY{
    [self clearGraphic];
    
    NSArray * pointXY = [mapPointXY componentsSeparatedByString:@","];
    double pointX = [[pointXY objectAtIndex:0]doubleValue];
    double pointY = [[pointXY objectAtIndex:1]doubleValue];
    AGSPoint *point = [[AGSPoint alloc]initWithX:pointX  y:pointY spatialReference:self.spatialReference];
    _agsPoint = point;
    CGPoint screenPoint = [self toScreenPoint:point];
    
    _imageView = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:@"home_red.png"]];
    CGRect endFrame = CGRectMake(screenPoint.x-18, screenPoint.y-18, 36, 36);
    _imageView.frame = CGRectMake(endFrame.origin.x, endFrame.origin.y-20, 36, 36);
    _imageView.alpha = 0;
    [self addSubview:_imageView];
    
    [UIView animateWithDuration:1 animations:^{
        [_imageView setFrame:endFrame];
        _imageView.alpha = 1;
    }
                     completion:^(BOOL finished){
                         if (finished){
                         }
                     }];
}

//手势操作执行代码
- (void)respondToEnvChange: (NSNotification*) notification {
    if(_imageView!=nil && !_imageView.hidden){
        //用给定的图片来
        AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"home_red.png"];
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:_agsPoint symbol:graphicSymbol attributes:nil];
        [self.pictureGraphicsLayer addGraphic:graphic];
        _imageView.hidden = YES;
    }
}
-(void)clearGraphic{
    [self.pictureGraphicsLayer removeAllGraphics];
    [self.geomeryGraphicsLayer removeAllGraphics];
    [_imageView removeFromSuperview];
}
-(NSString*)getProjectLocation{
    NSString *pointXY;
    if (_agsPoint!=nil) {
        pointXY = [NSString stringWithFormat:@"%f,%f",_agsPoint.x,_agsPoint.y];
    }
    return pointXY;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



// 气泡属性
-(void)showPopupForGraphic:(AGSGraphic *)picGraphic mapPoint:(AGSPoint *)location {
    self.mapPoint = location;
    AGSGraphic *filterGraphic = [self filterGraphic:picGraphic];
    AGSPopupInfo *popInfo = [AGSPopupInfo popupInfoForGraphic:filterGraphic];

    AGSPopup *pop = [AGSPopup popupWithGraphic:filterGraphic popupInfo:popInfo];
    [self displayResultsWithPopupVC:[NSArray arrayWithObject:pop]];
}


- (void) displayResultsWithPopupVC:(NSArray *)popups {
    [self setupPopupVC:popups];
    [self showCallout:IdentifyStateTypeHasResult location:self.mapPoint];
}

- (void) setupPopupVC: (NSArray *)popups {
    self.popContainerViewController = [[AGSPopupsContainerViewController alloc] initWithPopups:popups usingNavigationControllerStack:false];
    self.popContainerViewController.style = AGSPopupsContainerStyleCustomColor;
    self.popContainerViewController.delegate = self;
    self.popContainerViewController.pagingStyle = AGSPopupsContainerPagingStylePageControl;
    self.popContainerViewController.view.frame = CGRectMake(0, 0, 250, 300);
    
    UIColor *customColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
    self.popContainerViewController.attributeTitleColor = customColor;
    self.popContainerViewController.attributeTitleFont = [UIFont systemFontOfSize:14];
    self.popContainerViewController.attributeDetailFont = [UIFont systemFontOfSize:15];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    closeBtn.frame = CGRectMake(0, 0, 50, 40);
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:customColor forState:UIControlStateNormal];
    [closeBtn addTarget:self action: @selector(closePopup)  forControlEvents:UIControlEventTouchUpInside];
    self.popContainerViewController.actionButton = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    
    self.popContainerViewController.doneButton = [[UIBarButtonItem alloc] init];
}


-(void) showCallout:(IdentifyStateType) state location:(AGSPoint *)mappoint {
    switch (state) {
        case IdentifyStateTypeIdentifying:
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.activityIndicator.color = [UIColor blueColor];
            [self.activityIndicator startAnimating];
            
            self.callout.customView = self.activityIndicator;
            self.callout.margin = CGSizeMake(5, 5);
            
            break;
        case IdentifyStateTypeHasResult:
            self.callout.customView = self.popContainerViewController.view;
            self.callout.cornerRadius = 20;
            self.callout.customView.layer.cornerRadius = 20;
            self.callout.customView.clipsToBounds = YES;
            self.callout.margin = CGSizeZero;
            break;
        case IdentifyStateTypeNoResult:
            self.callout.tintColor = [UIColor redColor];
            self.callout.accessoryButtonHidden = YES;
            self.callout.title = @"无查询结果";
            self.callout.detail = @"";
            break;
        default:
            self.callout.tintColor = [UIColor redColor];
            self.callout.accessoryButtonHidden = YES;
            self.callout.title = @"查询失败";
            self.callout.detail = @"";
            break;
    }
    
    [self.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
}


// 过滤grahpic属性
-(AGSGraphic *)filterGraphic:(AGSGraphic *)graphic {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[graphic allAttributes]];
    NSArray *keys = [attributes allKeys];
    for (NSString *key in keys) {
        //移除系统字段
        if ([IDENTIFY_SYS_FIELDS containsObject:key]) {
            [attributes removeObjectForKey:key];
            continue;
        }
        
        //移除空字段
        NSString *graphicValue = nil;
        id value = [attributes objectForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            graphicValue = [(NSNumber *)value stringValue];
        } else if ([value isKindOfClass:[NSString class]]) {
            graphicValue = value;
        } else {
            graphicValue = @"";
        }
        
        if ([graphicValue.uppercaseString isEqualToString:@"NULL"]||[graphicValue.uppercaseString isEqualToString:@""]) {
            [attributes removeObjectForKey:key];
        }
    }
    
    AGSGraphic *newGraphic = [AGSGraphic graphicWithGeometry:graphic.geometry symbol:graphic.symbol attributes:attributes];
    return newGraphic;
}

// 关闭弹出窗
-(void)closePopup {
    [self.callout dismiss];
}

#pragma mark -  AGSPopupsContainerDelegate

-(void)popupsContainer:(id<AGSPopupsContainer>)popupsContainer didChangeToCurrentPopup:(AGSPopup *)popup{
    AGSGraphic* graphic = nil;
    if (popup.feature) {
        graphic = [AGSGraphic graphicWithFeature:popup.feature];
    }
    
    self.popContainerViewController.title = @"wokao";
    [self.callout moveCalloutTo:graphic.geometry.envelope.center screenOffset:CGPointZero animated:true];
    
}



































































@end
