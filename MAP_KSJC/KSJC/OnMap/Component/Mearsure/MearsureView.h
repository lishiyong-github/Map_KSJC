//
//  MearsureView.h
//  zzzf
//
//  Created by Aaron on 14-2-15.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface MearsureView : UIView
{
    double distance;
    AGSSRUnit distanceUnit;
    AGSAreaUnits areaUnit;
    double area;
    UIView *mearsureView;
    UILabel *lblResult;
    UISegmentedControl* mearsureSegmentedControl;
    AGSSpatialReference *spatialReference;
}

// 草图编辑图层
@property (strong, nonatomic) IBOutlet AGSSketchGraphicsLayer *sketchLayer;
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (nonatomic, weak) id<AGSMapViewTouchDelegate> mapTouchDelegate;

- (void)showAction:(NSString *)animationType : (UIView *)actionView;
- (IBAction)showMearsureToolBar;
- (void)CreatMearsureAGSSketchGraphicsLayer;
@end
