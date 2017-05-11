//
//  OMapViewController+CurrentDailyJob.m
//  zzzf
//
//  Created by zhangliang on 14-3-11.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController+CurrentDailyJob.h"
#import "CurrentLocationView.h"

@implementation OMapViewController (CurrentDailyJob)

- (IBAction)onBtnCarClick:(id)sender {
    self.btnNavCar.selected = !self.btnNavCar.selected;
    if (self.btnNavCar.selected) {
        [self showRouteWaitPanel];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dealyLoadRoute) userInfo:nil repeats:NO];
    }else{
        [_dailyJobListener startListener];
        if (nil!=dailyGraphicLayer) {
            [dailyGraphicLayer removeAllGraphics];
            [dailyGraphicLayer refresh];
        }
        [self clearLocationView];
    }
}

UIView *maskView;
UIView *waitPanel;
UIActivityIndicatorView *activityView;
UILabel *waitLabel;
AGSGraphicsLayer *dailyGraphicLayer;
NSMutableDictionary *polylineGraphics;

-(void)dealyLoadRoute{
    [_dailyJobListener startRouteListener];
}

-(void)showRouteWaitPanel{
    maskView = [[UIView alloc] initWithFrame:self.view.frame];
    maskView.backgroundColor = [UIColor whiteColor];
    maskView.alpha = .5;
    
    waitPanel = [[UIView alloc] initWithFrame:CGRectMake(440, 300, 200, 100)];
    waitPanel.backgroundColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1];
    waitPanel.layer.cornerRadius = 10;
    [self.view addSubview:waitPanel];
    
    waitLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 50, 160, 20)];
    waitLabel.text = @"正在获取路线信息";
    waitLabel.textAlignment = NSTextAlignmentCenter;
    waitLabel.textColor = [UIColor whiteColor];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(85, 10, 32,32);
    
    //[activityView setTintColor:[UIColor colorWithRed:122.0 green:1 blue:1 alpha:1]];
    [waitPanel addSubview:waitLabel];
    [waitPanel addSubview:activityView];
    [activityView startAnimating];
    
    [self.view addSubview:maskView];
}

-(void)closeRouteWaitePanel{
    [waitPanel removeFromSuperview];
    [maskView removeFromSuperview];
    maskView = nil;
    waitPanel = nil;
    waitLabel = nil;
    activityView = nil;
}

-(void)dailyJobListener:(DailyJobListener *)listener didReciveJob:(NSMutableArray *)jobs{
    _currentDailyJobLabel.hidden = jobs.count==0;
    _currentDailyJobLabel.text = [NSString stringWithFormat:@"%d",jobs.count];
    _currentDailyJobs = jobs;
}

-(void)dailyJobListener:(DailyJobListener *)listener didReciveRoute:(NSMutableArray *)routes{
    if (nil==routes || routes.count==0) {
        activityView.hidden = YES;
        waitLabel.text=@"没有获取到路线信息";
        _currentDailyJobLabel.hidden = YES;
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(stopWaitAndRedo) userInfo:nil repeats:NO];
    }else{
        [self closeRouteWaitePanel];
        
        [self drawRoute:routes];
    }
}

-(void)dailyJobListener:(DailyJobListener *)listener didReciveCurrentJobLocation:(NSMutableArray *)locations{
    for (int i=0; i<locations.count; i++) {
        NSDictionary *pInfo = [locations objectAtIndex:i];
        NSString *deviceCode =[pInfo objectForKey:@"device"];
        NSString *position = [pInfo objectForKey:@"position"];
        //如果多个巡查使用同一个设备，就只给一条线加点
        if (nil!=position && ![position isEqualToString:@""]) {
            NSMutableDictionary *d = [polylineGraphics objectForKey:deviceCode];
            if (nil!=d) {
                AGSMutablePolyline *theLine = [d objectForKey:@"line"];
                AGSGraphic *graphic = [d objectForKey:@"graphic"];
                AGSSimpleLineSymbol *symbol = [d objectForKey:@"symbol"];
                NSArray *ps = [position componentsSeparatedByString:@","];
                double x = [[ps objectAtIndex:0] doubleValue];
                double y = [[ps objectAtIndex:1] doubleValue];

                AGSPoint *graphicPoint = [AGSPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference];
                [theLine addPointToPath:graphicPoint];
                
                AGSGraphic *graphic2 = [[AGSGraphic alloc] initWithGeometry:theLine symbol:symbol attributes:[graphic allAttributes]];
                
                //[dailyGraphicLayer refresh];
                [dailyGraphicLayer removeGraphic:graphic];
                [dailyGraphicLayer addGraphic:graphic2];
                
                [d setObject:graphic2 forKey:@"graphic"];
                
                //更新当前位置
                for (int i=0;i<_currentDailyJobLocationViews.count; i++) {
                    CurrentLocationView *locationView = [_currentDailyJobLocationViews objectAtIndex:i];
                    if ([locationView.device isEqualToString:deviceCode]) {
                        locationView.point = graphicPoint;
                        CGPoint screenPoint =[self.mapView toScreenPoint:graphicPoint];
                        [UIView animateWithDuration:.5 animations:^(void){
                            locationView.frame = CGRectMake(screenPoint.x-24, screenPoint.y-24, 48, 48);
                        }];
                        
                        break;
                    }
                }
            }
        }
    }
}

-(void)stopWaitAndRedo{
    [self closeRouteWaitePanel];
    self.btnNavCar.selected = NO;
    [_dailyJobListener startListener];
}

-(UIColor *)colorWithOrg:(NSString *)org{
    NSString *orgColorStr;
    for (int i=0; i<_orgList.count; i++) {
        NSDictionary *orgInfo = [_orgList objectAtIndex:i];
        if ([org isEqualToString: [orgInfo objectForKey:@"id"]]) {
            orgColorStr = [orgInfo objectForKey:@"color"];
            break;
        }
    }
    UIColor *defaultColor = [UIColor colorWithRed:23.0/255.0 green:158.0/255.0 blue:17.0/255.0 alpha:.6];
    if (nil==orgColorStr) {
        return defaultColor;
    }else{
        NSArray *rgb = [orgColorStr componentsSeparatedByString:@","];
        if (rgb.count!=3) {
            return defaultColor;
        }
        return [UIColor colorWithRed:[[rgb objectAtIndex:0] doubleValue]/255.0 green:[[rgb objectAtIndex:1] doubleValue]/255.0 blue:[[rgb objectAtIndex:2] doubleValue]/255.0 alpha:.6];
    }
}

-(void)clearLocationView{
    if (nil!=_currentDailyJobLocationViews) {
        for (int i=0; i<_currentDailyJobLocationViews.count; i++) {
            CurrentLocationView *locationView = [_currentDailyJobLocationViews objectAtIndex:i];
            [locationView stopAnimate];
            [locationView removeFromSuperview];
        }
    }
    _currentDailyJobLocationViews = [NSMutableArray arrayWithCapacity:4];
}

-(void)drawRoute:(NSArray *)jobs{
    [self clearLocationView];
    _currentDailyJobLabel.hidden = jobs.count==0;
    _currentDailyJobLabel.text = [NSString stringWithFormat:@"%d",jobs.count];
    polylineGraphics = [NSMutableDictionary dictionaryWithCapacity:10];
    if (nil==dailyGraphicLayer) {
        dailyGraphicLayer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:dailyGraphicLayer withName:@"CurrentDailyGraphicsLayer"];
    }
    [dailyGraphicLayer removeAllGraphics];
    NSMutableArray *devices = [NSMutableArray arrayWithCapacity:10];
    for (int i=0; i<jobs.count; i++) {
        AGSMutablePolyline *polyLine = [[AGSMutablePolyline alloc]initWithSpatialReference:self.mapView.spatialReference];
        [polyLine addPathToPolyline];
        NSMutableDictionary *jobInfo = [jobs objectAtIndex:i];
        NSString *pointInfo = [jobInfo objectForKey:@"route"];
        
        NSMutableDictionary *cacheInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        
        NSString *deviceCode = [jobInfo objectForKey:@"device"];
        
        if ([pointInfo isEqualToString:@""]) {
            continue;
        }
        [devices addObject:deviceCode];
        NSArray *ps = [pointInfo componentsSeparatedByString:@","];
        for (int i = 0; i<ps.count; i++) {
            double x = [[ps objectAtIndex:i] doubleValue];
            i++;
            double y = [[ps objectAtIndex:i] doubleValue];
            AGSPoint *graphicPoint = [AGSPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference];
            [polyLine addPointToPath:graphicPoint];
        }
        
        AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        myOutlineSymbol.color = [self colorWithOrg:[jobInfo objectForKey:@"org"]];
        myOutlineSymbol.width = 6;
        myOutlineSymbol.style = AGSSimpleLineSymbolStyleSolid;
        
        AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:polyLine symbol:myOutlineSymbol attributes:jobInfo];
        
        [dailyGraphicLayer addGraphic:graphic];
        
        [cacheInfo setObject:graphic forKey:@"graphic"];
        [cacheInfo setObject:polyLine forKey:@"line"];
        [cacheInfo setObject:myOutlineSymbol forKey:@"symbol"];
        [polylineGraphics setObject:cacheInfo forKey:deviceCode];
        
        if (ps.count>1) {
            double lastX = [[ps objectAtIndex:ps.count-2] doubleValue];
            double lastY = [[ps objectAtIndex:ps.count-1] doubleValue];
            AGSPoint *graphicPoint = [AGSPoint pointWithX:lastX y:lastY spatialReference:self.mapView.spatialReference];
            
            CGPoint screenPoint = [self.mapView toScreenPoint:graphicPoint];
            CurrentLocationView *currentLocation = [[CurrentLocationView alloc] initWithFrame:CGRectMake(screenPoint.x-24, screenPoint.y-24, 48, 48)];
            currentLocation.device = deviceCode;
            currentLocation.point = graphicPoint;
            [currentLocation startAnimate];
            [_currentDailyJobLocationViews addObject:currentLocation];
            [self.mapView addSubview:currentLocation];
            
            //AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"point-green"];
            //AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:graphicPoint symbol:graphicSymbol attributes:jobInfo];
            //[dailyGraphicLayer addGraphic:graphic];
        }
        
        if (ps.count>2) {
            double firstX = [[ps objectAtIndex:0] floatValue];
            double firstY = [[ps objectAtIndex:1] floatValue];
            AGSPoint *graphicPoint = [AGSPoint pointWithX:firstX y:firstY spatialReference:self.mapView.spatialReference];
            AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"point-green-s"];
            AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:graphicPoint symbol:graphicSymbol attributes:jobInfo];
            [dailyGraphicLayer addGraphic:graphic];
        }
    }
    [_dailyJobListener beginLoadLastPosition:devices];
}

@end
