//
//  MapLocationView.h
//  zzzf
//
//  Created by Aaron on 14-9-15.
//  Copyright (c) 2014年 dist. All rights reserved.
//地图定位

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@protocol MapLocationDelegate <NSObject>
-(void)back;
-(void)saveProjectLocation;

@end

@interface MapLocationView : AGSMapView<AGSMapViewTouchDelegate,AGSPopupsContainerDelegate>

@property (strong,nonatomic) AGSGraphicsLayer *pictureGraphicsLayer;

@property (strong,nonatomic) AGSGraphicsLayer *geomeryGraphicsLayer;

@property (strong,nonatomic) AGSPoint * agsPoint;

@property (strong,nonatomic) UIImageView * imageView;

@property (nonatomic,retain) id<MapLocationDelegate> delegate;

@property (nonatomic,strong) AGSIdentifyTask        *identifyTask;
@property (nonatomic,strong) AGSIdentifyParameters  *identifyParameters;
@property (nonatomic,strong) NSMutableArray         *identifyFullResult;
@property (nonatomic,strong) AGSPoint               *mapPoint;
@property (nonatomic,strong) AGSPopupsContainerViewController *popContainerViewController;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;

-(NSString*)getProjectLocation;
-(void)clearGraphic;
-(void)activeSaveBtn:(BOOL)flag;
-(void)projectLocationForGPS:(NSString*)mapPointXY;
-(void)zoomfull;
@end
