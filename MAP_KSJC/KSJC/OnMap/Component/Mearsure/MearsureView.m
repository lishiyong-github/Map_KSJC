//
//  MearsureView.m
//  zzzf
//
//  Created by Aaron on 14-2-15.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MearsureView.h"

@implementation MearsureView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    UIColor *titleColor = [UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
    //创建测长和测面按钮
    mearsureSegmentedControl = [[UISegmentedControl alloc]initWithItems:nil];
    mearsureSegmentedControl.frame = CGRectMake(5, 6, 120, 30);
    mearsureSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [mearsureSegmentedControl insertSegmentWithTitle:@"测长" atIndex:0 animated:YES];
    [mearsureSegmentedControl insertSegmentWithTitle:@"测面" atIndex:1 animated:YES];
    //[mearsureSegmentedControl insertSegmentWithImage:[UIImage imageNamed:@"MeasureDistance.png"] atIndex:0 animated:YES];
    //[mearsureSegmentedControl insertSegmentWithImage:[UIImage imageNamed:@"MeasureArea.png"] atIndex:1 animated:YES];
    mearsureSegmentedControl.layer.borderColor = titleColor.CGColor;
    mearsureSegmentedControl.tintColor = titleColor;
    mearsureSegmentedControl.selectedSegmentIndex = 0;
    mearsureSegmentedControl.segmentedControlStyle= UISegmentedControlStylePlain;
    [mearsureSegmentedControl addTarget:self action:@selector(measure:) forControlEvents:UIControlEventValueChanged];
    //创建测量结果显示lable
    lblResult = [[UILabel alloc]initWithFrame:CGRectMake(mearsureSegmentedControl.frame.size.width+10, 6, 110, 30)];
    lblResult.textAlignment = NSTextAlignmentCenter;
    lblResult.font = [UIFont systemFontOfSize: 14.0];
    
    //创建清除测量结果按钮
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnClear setFrame:CGRectMake(lblResult.frame.origin.x+lblResult.frame.size.width+10, 6, 40, 30)];
    [btnClear setTitle:@"清除" forState:UIControlStateNormal];
    [btnClear addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
    [btnClear setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    btnClear.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [btnClear setTitleColor:titleColor forState:UIControlStateNormal];
    btnClear.layer.borderColor = titleColor.CGColor;
    btnClear.layer.borderWidth = 1;
    btnClear.layer.cornerRadius = 5;
    
    //创建停止测量按钮
    UIButton *btnStop = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnStop setFrame:CGRectMake(btnClear.frame.origin.x+btnClear.frame.size.width+5, 6, 40, 30)];
    [btnStop setTitle:@"关闭" forState:UIControlStateNormal];
    [btnStop addTarget:self action:@selector(stopMearsureToolBar:) forControlEvents:UIControlEventTouchUpInside];
    [btnStop setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    btnStop.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    
    [btnStop setTitleColor:titleColor forState:UIControlStateNormal];
    btnStop.layer.borderColor = titleColor.CGColor;
    btnStop.layer.borderWidth = 1;
    btnStop.layer.cornerRadius = 5;
    
    
    
    //增加按钮到菜单View中
    [self addSubview:mearsureSegmentedControl];
    [self addSubview:lblResult];
    [self addSubview:btnClear];
    [self addSubview:btnStop];
    
    self.layer.cornerRadius = 5;//设置那个圆角的有多圆
    self.layer.backgroundColor =[[UIColor whiteColor] CGColor];
    self.layer.masksToBounds = NO;
    
    // Register for geometry changed notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:AGSSketchGraphicsLayerGeometryDidChangeNotification object:nil];
    return self;
}
//创建sketchLayer
- (void)CreatMearsureAGSSketchGraphicsLayer{
    
   // 草图编辑图层
    self.sketchLayer = [AGSSketchGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.sketchLayer withName:@"Sketch layer"];
    //如果mapView.spatialReference为空，则给其赋上webMercatorSpatialReference，解决坐标系为空时测量面积为0的问题
    if (self.mapView.spatialReference == nil) {
        spatialReference = [AGSSpatialReference webMercatorSpatialReference];
    }
}
//测量长度和测量面积按钮点击事件
- (void)measure:(UISegmentedControl*)measureMethod {
    if(measureMethod.selectedSegmentIndex == 0)
        self.sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:spatialReference];
    else
        self.sketchLayer.geometry = [[AGSMutablePolygon alloc] initWithSpatialReference:spatialReference];
}

//显示测量菜单面板点击事件
- (IBAction)showMearsureToolBar {
    if (self.isHidden) {
        self.mapView.touchDelegate = self.sketchLayer;
        self.sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:spatialReference];
        mearsureSegmentedControl.selectedSegmentIndex = 0;
        [self setHidden:NO];
        [self showAction:@"pageUnCurl" :self];
     }
}

//关闭测量菜单面板点击事件
- (void)stopMearsureToolBar:(id)sender {
    [self.sketchLayer clear];
    lblResult.text = nil;
    self.mapView.touchDelegate = self.mapTouchDelegate;
    
    [self showAction:@"pageCurl" :self];
    [self setHidden:YES];
}


//清除测量结果点击事件
- (void)reset:(id)sender {
    [self.sketchLayer clear];
    lblResult.text = nil;
}

//工具条显示动画
- (void)showAction:(NSString *)animationType : (UIView *)actionView{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    //基本型
    animation.type = kCATransitionMoveIn;
    //私有API，字符串型
    animation.type = animationType;
    [actionView.layer addAnimation:animation forKey:[NSString stringWithFormat:@"%@", animation]];
}
- (void)respondToGeomChanged:(NSNotification*)notification {
    
    //初始化默认参数
    distance = 0;
    area = 0;
    distanceUnit = AGSSRUnitMeter;
    areaUnit = AGSAreaUnitsSquareMeters;
    
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    if (![sketchGeometry isValid]) {
        return;
    }
    
    // Update the distance and area whenever the geometry changes
    if ([sketchGeometry isKindOfClass:[AGSMutablePolyline class]]) {
        [self updateDistance:distanceUnit];
    }
    else if ([sketchGeometry isKindOfClass:[AGSMutablePolygon class]]){
        [self updateArea:areaUnit];
    }
}

//测量长度
- (void)updateDistance:(AGSSRUnit)unit {
    //获得sketchLayer的geometry
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    
    //获得测量长度结果
    distance = [geometryEngine geodesicLengthOfGeometry:sketchGeometry inUnit:distanceUnit];
    if (distance > 1000) {
        distanceUnit = AGSSRUnitKilometer;
        distance = distance / 1000;
    }
    ////设置长度单位
    NSString *distanceUnitString = nil;
    switch (distanceUnit) {
        case AGSSRUnitKilometer:
            distanceUnitString = @"千米";
            break;
        case AGSSRUnitMeter:
            distanceUnitString = @"米";
            break;
        default:
            break;
    }
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    
    lblResult.text = [NSString stringWithFormat:@"%0.1f%@",distance,distanceUnitString];
}

//测量面积
- (void)updateArea:(AGSAreaUnits)unit {
    //获得sketchLayer的geometry
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    
    //获得测量面积结果
    area = [geometryEngine shapePreservingAreaOfGeometry:sketchGeometry inUnit:areaUnit];
    if (area > 1000000) {
        areaUnit = AGSAreaUnitsSquareKilometers;
        area = area / 1000000;
    }
    //设置面积单位
    NSString *areaUnitString = nil;
    switch (areaUnit) {
        case AGSAreaUnitsSquareKilometers:
            areaUnitString = @"平方千米";
            break;
        case AGSAreaUnitsSquareMeters:
            areaUnitString = @"平方米";
        default:
            break;
    }
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    
    lblResult.text = [NSString stringWithFormat:@"%0.1f%@", area, areaUnitString];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
