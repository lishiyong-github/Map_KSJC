//
//  GPS.h
//  zzzf
//
//  Created by Aaron on 14-2-21.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@protocol GPSDelegate <NSObject>

-(void)gpsDidReaded:(CLLocationCoordinate2D)location;

@end

@interface GPS : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _gpsLocationPoint;
}

@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (nonatomic,retain) id<GPSDelegate> delegate;

+ (void)startMapGPS:(NSInteger)gpsModel AGSMapView:(AGSMapView*)mapView;
- (AGSPoint*)locationMapPoint;

- (void)startGPS;
- (CLLocationCoordinate2D)locationGPSPoint;
@end
