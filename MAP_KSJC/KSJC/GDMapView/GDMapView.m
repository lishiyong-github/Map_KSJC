//
//  mapView.m
//  KSJC
//
//  Created by shiyong_li on 2017/5/12.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "GDMapView.h"
#import "MAMutablePolyline.h"
#import "MAMutablePolylineRenderer.h"
#import "StatusView.h"
#import "TipView.h"
#import "AMapRouteRecord.h"
#import "FileHelper.h"
#import "SystemInfoView.h"
#import <MJExtension.h>
#import "SaveLocationHelper.h"

//record
#import "TracingPoint.h"
/******************* 高德地图 *******************/
#import <MAMapKit/MAMapKit.h>
@interface GDMapView ()<MAMapViewDelegate>
{
    NSMutableArray *_tracking;
    CFTimeInterval _duration;
}
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MATraceManager *traceManager;
@property (nonatomic, strong) StatusView *statusView;
@property (nonatomic, strong) TipView *tipView;
@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIImage *imageLocated;
@property (nonatomic, strong) UIImage *imageNotLocate;
@property (nonatomic, strong) SystemInfoView *systemInfoView;

@property (nonatomic, assign) BOOL isRecording;
@property (atomic, assign) BOOL isSaving;

@property (nonatomic, strong) MAMutablePolyline *mutablePolyline;

@property (nonatomic, strong) MAMutablePolylineRenderer *mutableView;

@property (nonatomic, strong) NSMutableArray *locationsArray;

@property (nonatomic, strong) AMapRouteRecord *currentRecord;

@property (nonatomic, strong) NSMutableArray *tracedPolylines;
@property (nonatomic, strong) NSMutableArray *tempTraceLocations;
@property (nonatomic, assign) double totalTraceLength;

@property (nonatomic, strong) NSMutableArray *recordArray;
@property (nonatomic, strong) AMapRouteRecord *record;
@end

/******************* 高德地图 *******************/
@implementation GDMapView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initmapView];
    }
    return self;
}

- (NSArray *)getLocation
{
    return @[@(self.mapView.centerCoordinate.latitude),@(self.mapView.centerCoordinate.longitude)];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    [_locationBtn setHidden:hidden];
}

- (void)showRecord
{
    NSArray *userLocationArray = [SaveLocationHelper getUserLocations];
    for (UserLocationModel *model in userLocationArray) {
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc]init];
        CLLocationCoordinate2D location ;
        location.latitude = [model.latitude doubleValue];
        location.longitude = [model.longitude doubleValue];
        annotation.coordinate = location;
        annotation.title = model.projectName;
        annotation.subtitle = model.company;
        [self.mapView addAnnotation:annotation];
    }
}

- (void)showRoute
{
    self.recordArray = [FileHelper recordsArray];
    if (self.recordArray.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
            
            [self addRoute];
            [self showRecord];
            
        });
    }
}

- (void)addRoute
{
    self.record = self.recordArray.firstObject;
    
    [self initDisplayRoutePolyline];
    //            [self initDisplayTrackingCoords];
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        NSLog(@"******************************************\n %@",annotation.title);
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        if([annotation.title isEqualToString:@"start"]){
            annotation.title = @"起点";
//            annotationView.imageView.image = [UIImage imageNamed:@"startPoint"];
        }else if ([annotation.title isEqualToString:@"end"]){
            annotation.title = @"终点";
//            annotationView.imageView.image = [UIImage imageNamed:@"endPoint"];
        }else{
            annotationView.imageView.image = [UIImage imageNamed:@"locationProject.png"];
            annotationView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        return annotationView;
    }
    return nil;
}

//显示已有路线
- (void)initDisplayRoutePolyline
{
    NSArray<MATracePoint *> *tracePoints = self.record.tracedLocations;
    
    if (tracePoints.count < 2)
    {
        return;
    }
    
    MAPointAnnotation *startPoint = [[MAPointAnnotation alloc] init];
    startPoint.coordinate = CLLocationCoordinate2DMake(tracePoints.firstObject.latitude, tracePoints.firstObject.longitude);
    startPoint.title = @"start";
    [self.mapView addAnnotation:startPoint];
    
    MAPointAnnotation *endPoint = [[MAPointAnnotation alloc] init];
    endPoint.coordinate = CLLocationCoordinate2DMake(tracePoints.lastObject.latitude, tracePoints.lastObject.longitude);
    endPoint.title = @"end";
    [self.mapView addAnnotation:endPoint];
    
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(tracePoints.count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < tracePoints.count; i++)
    {
        coords[i] = CLLocationCoordinate2DMake(tracePoints[i].latitude, tracePoints[i].longitude);
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:tracePoints.count];
    [self.mapView addOverlay:polyline];
    
    [self.mapView showOverlays:self.mapView.overlays edgePadding:UIEdgeInsetsMake(30, 50, 30, 50) animated:NO];
    
    if (coords)
    {
        free(coords);
    }
    
}

//显示实时轨迹
- (void)initDisplayTrackingCoords
{
    NSArray<MATracePoint *> *points = self.record.tracedLocations;
    
    if (points.count < 2)
    {
        return;
    }
    
    _tracking = [NSMutableArray array];
    for (int i = 0; i < points.count - 1; i++)
    {
        TracingPoint * tp = [[TracingPoint alloc] init];
        tp.coordinate = CLLocationCoordinate2DMake(points[i].latitude, points[i].longitude);
        //        tp.course = [Util calculateCourseFromCoordinate:CLLocationCoordinate2DMake(points[i].latitude, points[i].longitude) to:CLLocationCoordinate2DMake(points[i+1].latitude, points[i+1].longitude)];
        
        NSLog(@"tp.course :%f", tp.course);
        [_tracking addObject:tp];
    }
    
    TracingPoint *lastTp = [[TracingPoint alloc] init];
    lastTp.coordinate = CLLocationCoordinate2DMake(points.lastObject.latitude, points.lastObject.longitude);
    lastTp.course = ((TracingPoint *)[_tracking lastObject]).course;
    [_tracking addObject:lastTp];
}

/******************* 高德地图 *******************/
- (void)initmapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.bounds];
    self.mapView.zoomLevel = 16.0;
    self.mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    self.mapView.showsIndoorMap = NO;
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
//    self.mapView.logoCenter = CGPointMake(-30, -30);
//    self.mapView.logoSize = CGSizeZero;
    
    [self addSubview:self.mapView];
    self.traceManager = [[MATraceManager alloc] init];
    //开始记录
    [self startRecording];
}

- (void)setLocationInView:(UIView *)view frame:(CGRect)frame
{
    self.imageLocated = [UIImage imageNamed:@"location_yes.png"];
    self.imageNotLocate = [UIImage imageNamed:@"location_no.png"];
    
    //mapView frame (0 0; 764 720
    //    CGRect frame = CGRectMake(934, CGRectGetHeight(self.mapView.frame) - 90, 40, 40);
    self.locationBtn = [[UIButton alloc] initWithFrame:frame];
    self.locationBtn.backgroundColor = [UIColor whiteColor];
    self.locationBtn.layer.cornerRadius = 3;
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    
    [view addSubview:self.locationBtn];

}

- (void)actionLocation
{
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollow)
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone];
    }
    else
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollow];
    }
}

- (void)startRecording
{
    if (self.currentRecord == nil)
    {
        self.currentRecord = [[AMapRouteRecord alloc] init];
    }
    
    [self setBackgroundModeEnable:YES];
}

#pragma mark - Utility

- (void)setBackgroundModeEnable:(BOOL)enable
{
    self.mapView.pausesLocationUpdatesAutomatically = !enable;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
    {
        self.mapView.allowsBackgroundLocationUpdates = enable;
    }
}

- (void)queryTraceWithLocations:(NSArray<CLLocation *> *)locations withSaving:(BOOL)saving
{
    NSMutableArray *mArr = [NSMutableArray array];
    for(CLLocation *loc in locations)
    {
        MATraceLocation *tLoc = [[MATraceLocation alloc] init];
        tLoc.loc = loc.coordinate;
        
        tLoc.speed = loc.speed * 3.6; //m/s  转 km/h
        tLoc.time = [loc.timestamp timeIntervalSince1970] * 1000;
        tLoc.angle = loc.course;
        [mArr addObject:tLoc];
    }
    
    __weak typeof(self) weakSelf = self;
    __unused NSOperation *op = [self.traceManager queryProcessedTraceWith:mArr type:-1 processingCallback:nil  finishCallback:^(NSArray<MATracePoint *> *points, double distance) {
        
        NSLog(@"trace query done!");
        
        if (saving) {
            weakSelf.totalTraceLength = 0.0;
            [weakSelf.currentRecord updateTracedLocations:points];
            weakSelf.isSaving = NO;
            
            if ([weakSelf saveRoute])
            {
                [weakSelf.tipView showTip:@"recording save succeeded"];
            }
            else
            {
                [weakSelf.tipView showTip:@"recording save failed"];
            }
        }
        
        [weakSelf updateUserlocationTitleWithDistance:distance];
        [weakSelf addFullTrace:points];
        
    } failedCallback:^(int errorCode, NSString *errorDesc) {
        
        NSLog(@"query trace point failed :%@", errorDesc);
        if (saving) {
            weakSelf.isSaving = NO;
        }
    }];
    
}

- (void)addFullTrace:(NSArray<MATracePoint*> *)tracePoints
{
    MAPolyline *polyline = [self makePolylineWith:tracePoints];
    if(!polyline)
    {
        return;
    }
    
    [self.tracedPolylines addObject:polyline];
    [self.mapView addOverlay:polyline];
}

- (MAPolyline *)makePolylineWith:(NSArray<MATracePoint*> *)tracePoints
{
    if(tracePoints.count < 2)
    {
        return nil;
    }
    
    CLLocationCoordinate2D *pCoords = malloc(sizeof(CLLocationCoordinate2D) * tracePoints.count);
    if(!pCoords) {
        return nil;
    }
    
    for(int i = 0; i < tracePoints.count; ++i) {
        MATracePoint *p = [tracePoints objectAtIndex:i];
        CLLocationCoordinate2D *pCur = pCoords + i;
        pCur->latitude = p.latitude;
        pCur->longitude = p.longitude;
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:pCoords count:tracePoints.count];
    
    if(pCoords)
    {
        free(pCoords);
    }
    
    return polyline;
}

- (void)updateUserlocationTitleWithDistance:(double)distance
{
    self.totalTraceLength += distance;
    self.mapView.userLocation.title = [NSString stringWithFormat:@"距离：%.0f 米", self.totalTraceLength];
}

- (BOOL)saveRoute
{
    if (self.currentRecord == nil || self.currentRecord.numOfLocations < 2)
    {
        return NO;
    }
    
    NSString *name = self.currentRecord.title;
    NSString *path = [FileHelper filePathWithName:name];
    
    BOOL result = [NSKeyedArchiver archiveRootObject:self.currentRecord toFile:path];
    
    return result;
}


#pragma mark - MapView Delegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation)
    {
        return;
    }
    
//    if (!self.isRecording)
//    {
//        return;
//    }
    
    if (userLocation.location.horizontalAccuracy < 100 && userLocation.location.horizontalAccuracy > 0)
    {
        double lastDis = [userLocation.location distanceFromLocation:self.currentRecord.endLocation];
        
        if (lastDis < 0.0 || lastDis > 10)
        {
            [self.locationsArray addObject:userLocation.location];
            
            //            NSLog(@"date: %@,now :%@",userLocation.location.timestamp, [NSDate date]);
//            [self.tipView showTip:[NSString stringWithFormat:@"has got %ld locations",self.locationsArray.count]];
            
            [self.currentRecord addLocation:userLocation.location];
            
            
            [self.mutablePolyline appendPoint: MAMapPointForCoordinate(userLocation.location.coordinate)];
            [self.mutableView referenceDidChange];
            [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
            
            
            // trace
            [self.tempTraceLocations addObject:userLocation.location];
            if (self.tempTraceLocations.count >= 30)
            {
                [self queryTraceWithLocations:self.tempTraceLocations withSaving:NO];
                [self.tempTraceLocations removeAllObjects];
                
                // 把最后一个再add一遍，否则会有缝隙
                [self.tempTraceLocations addObject:userLocation.location];
            }
        }
    }
    
    [self.statusView showStatusWith:userLocation.location];
}

- (void)mapView:(MAMapView *)mapView  didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MAUserTrackingModeNone)
    {
        [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    }
    else
    {
        [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
    }
}
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAMutablePolyline class]])
    {
        MAMutablePolylineRenderer *view = [[MAMutablePolylineRenderer alloc] initWithMutablePolyline:overlay];
        view.lineWidth = 5.0;
        view.strokeColor = [UIColor redColor];
        _mutableView = view;
        return view;
    }
    
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *view = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        view.lineWidth = 5.0;
        view.strokeColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        view.strokeColor = [UIColor redColor];
        return view;
    }
    
    return nil;
}


@end
