//
//  LayerManager.m
//  zzOneMap
//
//  Created by zhangliang on 13-12-4.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "LayerManager.h"

@implementation LayerManager

static NSString *XZLXUrl = @"http://218.75.221.182:8082/arcgis/rest/services/XZLX/MapServer";/*蓝线*/
static NSString *YDHXUrl = @"http://218.75.221.182:8082/arcgis/rest/services/YDHX/MapServer";/*红线*/
static NSString *RCXCUrl = @"http://218.75.221.182:801/ArcGIS/rest/services/RCXC/MapServer"; /*日常巡查*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createLayerView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createLayerView];
    }
    return self;
}

-(void)createLayerView{
    _layerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-40) style:UITableViewStyleGrouped];
    //_layerTableView.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    //_layerTableView.backgroundView = nil;
    [self.contentView addSubview:_layerTableView];
    _layerTableView.backgroundView.alpha = 0;
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"Layers" ofType:@"plist"];
    _layerSource = [[NSMutableArray  alloc] initWithContentsOfFile:plistPath];
    _layerTableView.rowHeight = 60;
    
    _layerTableView.delegate = self;
    _layerTableView.dataSource = self;
    
     //[_titleButton setTitle:@"   图层" forState:UIControlStateNormal];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSArray *layers = [[_layerSource objectAtIndex:section]objectForKey:@"values"] ;
    NSDictionary *attrs = [layers objectAtIndex:row];
    //NSInteger *layerId = [[attrs objectForKey:@"layerId"] integerValue];
    NSString *layerURL = [attrs objectForKey:@"url"];
    NSString *layerType = [attrs objectForKey:@"type"];
    if (nil==layerURL || nil==layerType) {
        return;
    }
    [self.layerDelegate LayerVisibleChanged:layerURL LayerType:layerType visible:[[attrs objectForKey:@"visible"] isEqualToString:@"yes"]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSArray *layers = [[_layerSource objectAtIndex:section]objectForKey:@"values"] ;
    
    static NSString *GroupedTableIdentifier = @"LayerCellIdentifier";
    LayerCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             GroupedTableIdentifier];
    
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"LayerCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:GroupedTableIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:
                 GroupedTableIdentifier];
    }
    cell.attributes = [layers objectAtIndex:row];
    //cell.layerNameLabel.text = [[layers objectAtIndex:row] objectForKey:@"name"];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *groupName = [[_layerSource objectAtIndex:section] objectForKey:@"name"];
    return groupName;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *layers = [[_layerSource objectAtIndex:section]objectForKey:@"values"];
    return [layers count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _layerSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    UILabel *sectionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width, 40)];
    [sectionNameLabel setBackgroundColor:[UIColor clearColor]];
    [sectionNameLabel setTextColor:[UIColor blackColor]];
    sectionNameLabel.text = [[_layerSource objectAtIndex:section] objectForKey:@"name"];
    [sectionView addSubview:sectionNameLabel];
    sectionView.backgroundColor = [UIColor clearColor];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 38, tableView.bounds.size.width, 1)];
    [border setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.8]];
    [sectionView addSubview:border];
    
    return sectionView;
}

//加载矢量底图
+(void) addAGSLayer:(AGSMapView*)mapView LayerName:(layerTypes)layerName getLayerType:(NSString *)serverType layerVisible:(BOOL)visible
{
    AGSLayer *agsLayer;
    NSString *layerTypeName;
    //图层类型/服务类型
    if ([serverType  isEqual: @"WMTS"]) {
        layerTypeName = [NSString stringWithFormat:@"%uWMTSLayer",layerName];
        
        
        //WMTSLayer 初始化方法
        agsLayer = [[WMTSLayer alloc] initWithLayerType:layerName LocalServiceURL:nil error:nil];
    }
    else if ([serverType isEqual:@"DynamicLayer"]) {
        
        switch (layerName) {
            case 7:
                layerTypeName = XZLXUrl;
                break;
            case 8:
                layerTypeName = YDHXUrl;
            default:
                break;
        }
        agsLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL :[NSURL URLWithString: layerTypeName]];
    }
    
    //图层不为空
    if(agsLayer!=nil){
       //取出layerTypeName 名字的AGSLayer
        AGSLayer *mLayer = [mapView mapLayerForName:layerTypeName];
        if (mLayer != nil) {
            //已经存在(是否需要显示)
            mLayer.visible = visible;
        }
        else
        {
            [mapView addMapLayer:agsLayer withName:layerTypeName];
        }
    }
}


//插入
+(void) insertAGSLayer:(AGSMapView*)mapView LayerName:(layerTypes)layerName setLayerIndex:(int) index getLayerType:(NSString *)serverType layerVisible:(BOOL)visible
{
    
    NSLog(@"index=%d",index);
    AGSLayer *agsLayer;
    NSString *layerTypeName;
    if ([serverType  isEqual: @"WMTS"]) {
        layerTypeName = [NSString stringWithFormat:@"%uWMTSLayer",layerName];
        agsLayer = [[WMTSLayer alloc]initWithLayerType:layerName LocalServiceURL:nil error:nil];
    }
    if ([serverType isEqual:@"DynamicLayer"]) {
        switch (layerName) {
            case 7:
                //蓝线
                layerTypeName = XZLXUrl;
                break;
                //红线
            case 8:
                layerTypeName = YDHXUrl;
                break;
            default:
                break;
        }
        agsLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL :[NSURL URLWithString: layerTypeName]];
    }
    
    if(agsLayer!=nil){
        AGSLayer *mLayer = [mapView mapLayerForName:layerTypeName];
        if (mLayer != nil) {
            mLayer.visible =visible;
        }
        else
        {
            [mapView insertMapLayer:agsLayer withName:layerTypeName atIndex:index];
        }
    }
}
+(NSString*)mapServiceUrl:(NSInteger)layerIndex{
    NSString *layerUrl = nil;
    switch (layerIndex) {
        case 7:
            layerUrl = XZLXUrl;
            break;
        case 8:
            layerUrl = YDHXUrl;
            break;
        case 9:
            layerUrl = RCXCUrl;
            break;
        default:
            break;
    }
    return layerUrl;
}


//添加动态map(日常巡查)
+(AGSDynamicMapServiceLayer*)addAGSDynamicMapServiceLayer:(AGSMapView*)mapView{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/M/d"];
    unsigned units=NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit|NSWeekdayCalendarUnit;
    NSCalendar *calendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now=[NSDate date];
    NSDateComponents *comp =[calendar components:units fromDate:now];
    NSInteger weekDay = [comp weekday];

    NSDateComponents *dc = [[NSDateComponents alloc] init];
    [dc setDay:-(weekDay-2)];
    if (weekDay==1) {
        [dc setDay:-6];
    }
    NSDate *d1 = [calendar dateByAddingComponents:dc toDate:now options:0];
    NSDate *d2 = now;
    NSString *strD1 = [formatter stringFromDate:d1];
    NSString *strD2 = [formatter stringFromDate:d2];
    AGSDynamicMapServiceLayer *dyMapServiceLayer = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:[NSURL URLWithString:RCXCUrl]];
    AGSLayerDefinition *ld0 = [AGSLayerDefinition layerDefinitionWithLayerId:0 definition:[NSString stringWithFormat:@"DATETIME >= date '%@' AND DATETIME <= date '%@'",strD1,strD2]];
    AGSLayerDefinition *ld1 = [AGSLayerDefinition layerDefinitionWithLayerId:1 definition:[NSString stringWithFormat:@"DATETIME >= date '%@' AND DATETIME <= date '%@'",strD1,strD2]];
    NSArray *layerDefinitions = [[NSArray alloc]initWithObjects:ld0,ld1, nil];
    [dyMapServiceLayer setLayerDefinitions:layerDefinitions];
    [mapView addMapLayer:dyMapServiceLayer withName:@"RCXC DynamicLayer"];
    return dyMapServiceLayer;
}


//----------------------  分割线 --------------------

/**
 *  切换底图
 *
 *  @param mapView 底图
 *  @param type    底图类型
 */
+(void) setBaseMap:(AGSMapView*)mapView mapType:(BaseMapType)type {
    
    switch (type) {
            
        case 0:
            [mapView mapLayerForName:KSXZQHNAME].visible = true;
            [mapView mapLayerForName:KSIMGNAME].visible = false;
            break;
        case 1:
            [mapView mapLayerForName:KSXZQHNAME].visible = false;
            [mapView mapLayerForName:KSIMGNAME].visible = true;
            break;
        default:
            break;
    }
    
}

/**
 *  预加载底图
 *
 *  @param mapView 底图
 */
+(void) loadBaseMap:(AGSMapView *)mapView {
    AGSTiledMapServiceLayer *xzqhMap = [[AGSTiledMapServiceLayer alloc]initWithURL:[NSURL URLWithString:KSXZQHMAP]];
    xzqhMap.visible = false;
    [mapView addMapLayer:xzqhMap withName:KSXZQHNAME];
    
    AGSTiledMapServiceLayer *imgMap = [[AGSTiledMapServiceLayer alloc]initWithURL:[NSURL URLWithString:KSIMGMAP]];
    imgMap.visible = false;
    [mapView addMapLayer:imgMap withName:KSIMGNAME];
}

/**
 *  加载动态服务
 *
 *  @param mapView 底图
 *  @param url     服务url
 */
+(void) loadDynamicMap:(AGSMapView *)mapView withUrl:(NSString *)url {
    AGSDynamicMapServiceLayer *dynamicMap = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:url]];
    [mapView addMapLayer:dynamicMap withName:url];
}

/**
 *  设置动态服务显示图层
 *
 *  @param mapView 底图
 *  @param name    服务名称
 *  @param ids     操作id数组
 *  @param visible 可见性
 */
+(void) setDynamicLayer:(AGSMapView *)mapView withLayerName:(NSString *)name ids:(NSArray *)ids isVisible:(BOOL)visible {
    AGSDynamicMapServiceLayer *serviceLayer = (AGSDynamicMapServiceLayer *)[mapView mapLayerForName:name];
    
    NSMutableArray *visibleIds = [NSMutableArray arrayWithArray:serviceLayer.visibleLayers];
    if (visible) {
        [visibleIds addObjectsFromArray:ids];
        [serviceLayer setVisibleLayers:visibleIds];
    } else {
        [visibleIds removeObjectsInArray:ids];
        [serviceLayer setVisibleLayers:visibleIds];
    }
}

@end

