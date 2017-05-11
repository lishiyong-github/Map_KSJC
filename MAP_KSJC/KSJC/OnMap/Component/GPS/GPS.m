//
//  GPS.m
//  zzzf
//
//  Created by Aaron on 14-2-21.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "GPS.h"

@implementation GPS

@synthesize delegate = _delegate;

+ (void)startMapGPS:(NSInteger)gpsModel AGSMapView:(AGSMapView*)mapView{
    //Start the map's gps if it isn't enabled already
    if(!mapView.locationDisplay.dataSourceStarted)
        [mapView.locationDisplay startDataSource];
    
    //Set the appropriate AutoPan mode
    switch (gpsModel) {
        case 0:
            mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
            //Set a wander extent equal to 75% of the map's envelope
            //The map will re-center on the location symbol only when
            //the symbol moves out of the wander extent
			mapView.locationDisplay.wanderExtentFactor = 0.75;
            break;
        case 1:
            mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeNavigation;
            //Position the location symbol near the bottom of the map
            //A value of 1 positions it at the top edge, and 0 at bottom edge
			mapView.locationDisplay.navigationPointHeightFactor = 0.15;
            break;
        case 2:
            mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeCompassNavigation;
            //Position the location symbol in the center of the map
			mapView.locationDisplay.navigationPointHeightFactor = 0.5;
            break;
            
        default:
            break;
    }
}

- (AGSPoint*)locationMapPoint{
    AGSPoint *gpsLocationPoint = self.mapView.locationDisplay.location.point;
    return gpsLocationPoint;
}
- (void)startGPS{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        // 越精确，越耗电
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    // 开始
    [_locationManager startUpdatingLocation];
}
- (CLLocationCoordinate2D)locationGPSPoint{

    return _gpsLocationPoint;
}

#pragma mark -CLLocationManagerDelegate系统自带 定位代理方法
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{   
    NSTimeInterval interval = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
    NSLog(@"%lf", interval);
    
    // 取到精确GPS位置后停止更新
    if (interval < 3) {
        // 停止更新
        [_locationManager stopUpdatingLocation];
    }
    _gpsLocationPoint = newLocation.coordinate;
    [self.delegate gpsDidReaded:_gpsLocationPoint];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    switch (error.code) {
        case kCLErrorLocationUnknown:
            NSLog(@"The location manager was unable to obtain a location value right now.");
            break;
        case kCLErrorDenied:
            NSLog(@"Access to the location service was denied by the user.");
            break;
        case kCLErrorNetwork:
            NSLog(@"The network was unavailable or a network error occurred.");
            break;
        default:
            NSLog(@"未定义错误");
            break;
    }
}
@end
