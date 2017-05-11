//
//  OMapViewController+MapTypeToggle.m
//  zzzf
//
//  Created by zhangliang on 14-3-6.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController+MapTypeToggle.h"

@implementation OMapViewController (MapTypeToggle)

-(void)createToggle{
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(950, 10,62 , 54)];
    //绑定ImageView的Touch事件
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchBaseMap)];
    imgView.userInteractionEnabled = YES;
    [imgView addGestureRecognizer:singleTap];
    
    imgView.image = [UIImage imageNamed:@"basemap_topographic"];
    toggleBtn = [SysButton buttonWithType:UIButtonTypeCustom];
    [toggleBtn setTitle:@"矢量图" forState:UIControlStateNormal];
    [toggleBtn addTarget:self action:@selector(switchBaseMap) forControlEvents:UIControlEventTouchUpInside];
    [toggleBtn.titleLabel setFont:[toggleBtn.titleLabel.font fontWithSize:12]];
    toggleBtn.frame = CGRectMake(951, 40, 60, 24);
    toggleBtn.backgroundColor = [UIColor grayColor];
    toggleBtn.defaultBackground = [UIColor grayColor];
    [self.view addSubview:imgView];
    [self.view addSubview:toggleBtn];

    [self setBoxLayerStyle:imgView.layer];

}
//矢量图底图和影像底图切换
- (void)switchBaseMap{
    NSString *filePath;
    AGSLayer *yxtWMTSLayer = [self.mapView mapLayerForName: @"2WMTSLayer"];
    if (yxtWMTSLayer != nil) {
        [self.mapView removeMapLayerWithName:@"2WMTSLayer"];
        [LayerManager insertAGSLayer:self.mapView LayerName:SHT setLayerIndex:0 getLayerType:@"WMTS" layerVisible:YES];
        [toggleBtn setTitle:@"矢量" forState:UIControlStateNormal];
        filePath = [[NSBundle mainBundle] pathForResource:@"basemap_topographic" ofType:@"png"];
    }else{
        [self.mapView removeMapLayerWithName:@"0WMTSLayer"];
        [LayerManager insertAGSLayer:self.mapView LayerName:YXT setLayerIndex:0 getLayerType:@"WMTS" layerVisible:YES];
        [toggleBtn setTitle:@"影像" forState:UIControlStateNormal];
        filePath = [[NSBundle mainBundle] pathForResource:@"baseMap_Image" ofType:@"png"];
    }
    //更换矢量图和影像图的图标
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:data];
    [imgView setImage:image];
}


@end
