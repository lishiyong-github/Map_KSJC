//
//  MapViewController.m
//  zzzf
//
//  Created by Aaron on 14-3-3.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapViewController.h"
#import "MZFormSheetController.h"
#import "QuartzCore/QuartzCore.h"
#import "MapViewController+IdentifyPictureMarker.h"
#import "MapViewController+BusinessSearch.m"
#import "DrawHelper.h"
#import "DailyJobReaderViewController.h"
#import "MapViewController+ThemeTree.h"


#import "GDMapView.h"
@interface MapViewController ()
@property (nonatomic,strong) GDMapView *gdMapView;
@end
@implementation MapViewController
@synthesize mapView;
@synthesize mapContainer;
@synthesize currentNav;
@synthesize searchBar;
@synthesize mapTypeSelectorImg;
@synthesize btnSwitchMap;


AGSEnvelope *defaultEnvelope;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    btnSwitchMap.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:0.7];
    
    [self mapJsonConfig];
        
    //点击地图时的代理
    self.mapView.touchDelegate = self;
    //打开插图查看详情
    self.mapView.callout.delegate = self;
    //图层代理
    self.mapView.layerDelegate = self;
    //继承AGSMapView,同时设置的协议
    self.mapView.mapTouchDelegate = self;
    
    //树状专题
    self.themeTableView.delegate = self;
    self.themeTableView.dataSource = self;
    [self.themeTableView registerNib:[UINib nibWithNibName:@"TreeNodeCell" bundle:nil] forCellReuseIdentifier:@"TreeNodeCell"];
    self.themeTableView.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00];
    self.themeTableView.tableHeaderView = [[UIView alloc] init];
    self.themeTableView.tableFooterView = [[UIView alloc] init];
    self.themeTableView.layer.borderWidth = 1.5;
    self.themeTableView.layer.borderColor = [[UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00] CGColor];
    
    
    _query_param_dateLevel = -1;

    [self createMapBySubThread];
    //绑定ImageView的Touch事件(修改矢量图和影像图)
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchBaseMap)];
    self.mapTypeSelectorImg.userInteractionEnabled = YES;
    [self.mapTypeSelectorImg addGestureRecognizer:singleTap];

    //设置图层容器view边框(总规,地名,蓝线)
    self.layerGroupContainer.layer.cornerRadius = 10;
    //设置(日常巡查,放验线.etc)view边框
    self.businessTypeGroupContainer.layer.cornerRadius = 10;
    
    [[searchBar.subviews objectAtIndex:0] removeFromSuperview];
    searchBar.backgroundColor = [UIColor blackColor];
    searchBar.layer.shadowColor = [UIColor grayColor].CGColor;
    searchBar.layer.shadowOpacity = 1.0;
    searchBar.layer.shadowOffset = CGSizeMake(0,1);
    searchBar.clipsToBounds = NO;
    
    for (UIView *subview in searchBar.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *searchFiled = (UITextField *) subview;
            searchFiled.borderStyle = UITextBorderStyleRoundedRect;
            searchFiled.layer.borderColor = [[UIColor whiteColor] CGColor];
            searchFiled.layer.borderWidth = 4.0f;
            searchFiled.layer.cornerRadius = 0.0f;
            break;
        }
    }
    
    
    //设置矢量图//影像图的边框
    [self setBorder:mapTypeSelectorImg.layer];
    
    //设置默认显示位置
    [self zoomfull];
    //修改地图背景
    self.mapView.gridLineWidth = 0;//(网格线的宽度)
    self.mapView.backgroundColor = [UIColor whiteColor];
    
    
    //创建右下的操作控件(定位,放大,量尺寸等)
    [self createMenu];
    //创建分类主题(@"全部", @"基础", @"转换", @"标准", @"封顶", @"外立面") ---未用到
    [self CreateFilterTheme];
    
    //日期选择器
    _dateSelector = [[DistDateSelector alloc] initWithFrame:CGRectMake(265, 635, 270, 50)];
    _dateSelector.layer.shadowColor = [UIColor grayColor].CGColor;
    _dateSelector.layer.shadowOpacity = 1.0;
    _dateSelector.layer.cornerRadius = 5;
    _dateSelector.layer.shadowOffset = CGSizeMake(0,1);
    _dateSelector.backgroundColor = [UIColor whiteColor];
    _dateSelector.delegate = self;
    [self.view addSubview:_dateSelector];
    
    //显示日期
    _lblDateInfo = [[UILabel alloc] initWithFrame:CGRectMake(265, 690, 270, 25)];

//    _lblDateInfo = [[UILabel alloc] initWithFrame:CGRectMake(265, 690, 170, 25)];
    _lblDateInfo.layer.cornerRadius=5;
    [_lblDateInfo setTextAlignment:NSTextAlignmentCenter];
    _lblDateInfo.text = _dateSelector.dateString;
    _lblDateInfo.font = [_lblDateInfo.font fontWithSize:12];
    _lblDateInfo.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    [self.view addSubview:_lblDateInfo];
    
    
    //增加测量菜单面板
    mearsureView = [[MearsureView alloc] initWithFrame:CGRectMake(_dateSelector.frame.origin.x+_dateSelector.frame.size.width+5, _dateSelector.frame.origin.y+4, 340, 40)];
    mearsureView.layer.shadowColor = [UIColor grayColor].CGColor;
    mearsureView.layer.shadowOpacity = 1.0;
    mearsureView.layer.shadowOffset = CGSizeMake(0,1);
    mearsureView.backgroundColor = [UIColor whiteColor];
    [mearsureView setHidden:YES];
    mearsureView.mapView = self.mapView;
    mearsureView.mapTouchDelegate = self;
    [mearsureView CreatMearsureAGSSketchGraphicsLayer];
    [self.view addSubview:mearsureView];
    
    
    //搜索结果tableView
    _searchResultPanel = [[MapSearchResultPanel alloc] initWithFrame:CGRectMake(265, 15, 484, 60)];
    _searchResultPanel.layer.cornerRadius = 5;
    _searchResultPanel.layer.shadowColor = [UIColor grayColor].CGColor;
    _searchResultPanel.layer.shadowOpacity = .5;
    _searchResultPanel.layer.shadowOffset = CGSizeMake(0,1);
    _searchResultPanel.hidden = YES;
    _searchResultPanel.delegate = self;
    [self.mapContainer addSubview:_searchResultPanel];
    //请求数据
    [self c_initDataQueryList];
    [self initGDMapView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.gdMapView showRecord];
}

-(void)createMapBySubThread{
    
    self.visibleLayersDict = [NSMutableDictionary dictionary];
    
    [self initMapConfig];
    [LayerManager setBaseMap:self.mapView mapType:0];
    
    //动态图层
    //self.dyMapServiceLayer = [LayerManager addAGSDynamicMapServiceLayer:self.mapView];
    
    //新建一个graphicLayer到地图上
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.graphicsLayer withName:@"GraphicsLayer"];
    
    self.indentifyGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.indentifyGraphicsLayer withName:@"IndentifyGraphicsLayer"];
    
    //图形图层
    self.pictureGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.pictureGraphicsLayer withName:@"PictureGraphicsLayer"];
}

-(void)mapViewDidLoad:(AGSMapView *)mapView{
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    if (self.mapView.locationDisplay.dataSourceStarted) {
        [self.mapView.locationDisplay startDataSource];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc{
}

#pragma mark - 初始化配置

-(void)setRootGroups:(NSArray *)rootGroups {
    _rootGroups = rootGroups;
    self.itemsArray = [NSMutableArray arrayWithArray:rootGroups];
}

-(void) setBorder:(CALayer *)theLayer{
    theLayer.shadowColor = [UIColor grayColor].CGColor;
    theLayer.shadowOpacity = 1.0;
    theLayer.shadowOffset = CGSizeMake(0,1);
    theLayer.borderColor = [[UIColor whiteColor] CGColor];
    theLayer.borderWidth = 1.0f;
}

-(void)initMapConfig {
    [LayerManager loadBaseMap:self.mapView];
    
    /* 原始代码
    //加载动态服务,需要使用的服务
    NSArray *serviceLayers = @[KSKG,KSDM,KSLX,KSFYX];
    for (NSString *url in serviceLayers) {
        [LayerManager loadDynamicMap:self.mapView withUrl:url];
    }
    */
    
    //加载动态服务 liuxb
    [self loadThemeServices];
}


#pragma mark - 底图切换

//矢量图底图和影像底图切换
- (void)switchBaseMap{
    NSString *filePath;
    
    AGSLayer *baseLayer = [self.mapView mapLayerForName: KSXZQHNAME];
    if (!baseLayer.visible) {
        
        [LayerManager setBaseMap:self.mapView mapType:0];
        
        [self.btnSwitchMap setTitle:@"矢量" forState:UIControlStateNormal];
        filePath = [[NSBundle mainBundle] pathForResource:@"basemap_topographic" ofType:@"png"];
    }else{
        
        [LayerManager setBaseMap:self.mapView mapType:1];
        
        [self.btnSwitchMap setTitle:@"影像" forState:UIControlStateNormal];
        filePath = [[NSBundle mainBundle] pathForResource:@"baseMap_Image" ofType:@"png"];
    }
    //更换矢量图和影像图的图标
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:data];
    [self.mapTypeSelectorImg setImage:image];
}
- (IBAction)btnSwitchBaseMap:(id)sender{
    [self switchBaseMap];
}

#pragma mark - 监察业务

//点击日常巡查,放验线,批后监察等按钮的方法
- (IBAction)onNavTap:(id)sender {
    _query_param_dateLevel = -1;
    self.themeFilterControl.hidden = YES;
    SysButton *target = (SysButton *)sender;

    //取消默认现在
    if (self.btnDefaultRCXC) {
        self.btnDefaultRCXC.selected = NO;
    }
    if (target.tag==0) {
        _busiType = @"Rcxc";
    }
    else if(target.tag==1){
        _busiType = @"Fyx";
    }
    else if (target.tag == 2) {
        self.themeFilterControl.hidden = NO;
        _busiType = @"Phxm";
    }else if(target.tag==3){
        _busiType = @"Wfxm";
    }
    //当前按钮选择
    target.selected = YES;
    //把当前按钮给btn
    self.btnDefaultRCXC = target;
    //请求参数数据类型(点击按钮的tag)
    _query_param_datatype = self.btnDefaultRCXC.tag;
    
    //更新数据
    [self c_updateBusinessData];
    
}

#pragma mark - 专题图层

//显示图层信息
- (IBAction)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isVisible = [switchButton isOn];
    switch (switchButton.tag) {
        case 0:
            //控规
            [LayerManager setDynamicLayer:self.mapView withLayerName:KSKG ids:KSKGID isVisible:isVisible];
            if (isVisible) {
                [self.visibleLayersDict setObject:KSKGID forKey:KSKG];
            } else {
                [self.visibleLayersDict removeObjectForKey:KSKG];
            }
            break;
        case 1:
            //地名
            [LayerManager setDynamicLayer:self.mapView withLayerName:KSDM ids:KSDMID isVisible:isVisible];
            if (isVisible) {
                [self.visibleLayersDict setObject:KSDMID forKey:KSDM];
            } else {
                [self.visibleLayersDict removeObjectForKey:KSDM];
            }
            break;
        case 2:
            //蓝线
            [LayerManager setDynamicLayer:self.mapView withLayerName:KSLX ids:KSLXID isVisible:isVisible];
            if (isVisible) {
                [self.visibleLayersDict setObject:KSLXID forKey:KSLX];
            } else {
                [self.visibleLayersDict removeObjectForKey:KSLX];
            }
            break;
        case 3:
            //红线
            [LayerManager setDynamicLayer:self.mapView withLayerName:KSHX ids:KSHXID isVisible:isVisible];
            if (isVisible) {
                [self.visibleLayersDict setObject:KSHXID forKey:KSHX];
            } else {
                [self.visibleLayersDict removeObjectForKey:KSHX];
            }
            break;
        case 4:
            //规划路网
            [LayerManager setDynamicLayer:self.mapView withLayerName:KSGHLW ids:KSGHLWID isVisible:isVisible];
            if (isVisible) {
                [self.visibleLayersDict setObject:KSGHLWID forKey:KSGHLW];
            } else {
                [self.visibleLayersDict removeObjectForKey:KSGHLW];
            }
            break;
        default:
            break;
    }
}
-(void)moveLayerIndex:(NSInteger)layerIndex LayerName:(NSString*)layerName{
    AGSLayer *mLayer = [self.mapView mapLayerForName:layerName];
    if (mLayer != nil) {
        [self.mapView removeMapLayer:mLayer];
        [self.mapView addMapLayer:mLayer];
    }
}

-(void)mapDidClickAtEmpty{
    [_searchResultPanel close];
}



#pragma mark ---MapSearchResultPanelDelegate
//点击图片打开图片
-(void)mapSearchPanel:(MapSearchResultPanel *)panel openPhoto:(NSString *)name url:(NSString *)url ext:(NSString *)ext{
    [self.delegate mapShouldShowFile:name path:url ext:ext];
}


//巡查记录打开详情
-(void)mapSearchPanel:(MapSearchResultPanel *)panel openJobDaily:(NSDictionary *)data showStopworkform:(BOOL)showStopworkform{
//    DailyJobReaderViewController *djvc = [[DailyJobReaderViewController alloc] initWithNibName:@"DailyJobReaderViewController" bundle:nil];
//    djvc.fileDelegate = self;
//    
////    djvc.defaultDisplayStopworkfrom = showStopworkform;
//    [djvc loadbaseProjectWithpid:[data objectForKey:@"pid"] andTime:[data objectForKey:@"jcsj"]];
//    [self.navigationController pushViewController:djvc animated:YES];
////    [djvc loadJobFromData:data];
    MapJobViewController *mapj=[[MapJobViewController alloc] init];
    [mapj loadbaseProjectWithpid:[data objectForKey:@"pid"] andTime:[data objectForKey:@"jcsj"]withDict:data];
    
    mapj.xclog = YES;
  
    mapj.delegate = self;
    
//    mapj.type = @"";
    [self.navigationController pushViewController:mapj animated:YES];

}


//验线详情/批后/核实/工程
-(void)mapSearchPanel:(MapSearchResultPanel *)panel openProject:(NSDictionary *)data showStopworkform:(BOOL)showStopworkform{
    MapJobViewController *mapj=[[MapJobViewController alloc] init];
    mapj.projectID = [data objectForKey:@"projectId"];
    mapj.project = data;
    mapj.delegate = self;
    mapj.type = _busiType;
    //mapj.jobDelegate = self.jobDelegate;
    [self.navigationController pushViewController:mapj animated:YES];
    
}

//显示列表 代理方法
//AGSLayerDefinition使用日期类型字段过滤
-(void)filterRCXCLayer:(NSString *)layerFilter{
    //动态图层
    [self.dyMapServiceLayer setVisible:NO];
    //点击显示列表,layerFilter.length =0,让layerFilter为跳转之前的值
    if (layerFilter.length == 0) {
        layerFilter = self.layerFilter;
    }
    //点击cell layerFilter 有值
    self.identifyLayerFilter = layerFilter;
    AGSLayerDefinition *ld0 = [AGSLayerDefinition layerDefinitionWithLayerId:0 definition:layerFilter];
    AGSLayerDefinition *ld1 = [AGSLayerDefinition layerDefinitionWithLayerId:1 definition:layerFilter];
    NSArray *layerDefinitions = [[NSArray alloc]initWithObjects:ld0,ld1, nil];
    
    [self.dyMapServiceLayer setLayerDefinitions:layerDefinitions];//开始过滤 
    [self.dyMapServiceLayer setVisible:YES];
}

//滤除某些图形图层
-(void)filterPoint:(NSString*)fatherId{
    if (fatherId.length == 0) {
        [self.pictureGraphicsLayer removeAllGraphics];
        //把之前移除掉的图形图层加回来
        [self.pictureGraphicsLayer addGraphics:self.removeGraphics];
        //清空图形图层
        [self.removeGraphics removeAllObjects];
    }
    //获取图形图层
    NSArray *pictureGraphics = [self.pictureGraphicsLayer graphics];
    //遍历图形图层
    for (AGSGraphic *graphic in pictureGraphics) {
        //取出图形图层中的fatherId字符串
        NSString *fId = [[graphic allAttributes]objectForKey:@"fatherId"];
        //        NSString *cId = [[graphic allAttributes]objectForKey:@"childId"];
        if(fatherId.length > 0){
            //滤掉不等的
            if (![fId isEqual:fatherId]) {
                //把不相等的图形图层添加到数组中
                [self.removeGraphics addObject:graphic];
            }
        }
    }
    //移除不等的图形图层.
    [self.pictureGraphicsLayer removeGraphics:self.removeGraphics];
}
-(void)hideMapViewCallout{
    self.mapView.callout.hidden = YES;
    [self stopped];
}

-(void)zoomPoint:(NSString *)keyId {
    if (self.removeGraphics.count > 0) {
        for (AGSGraphic* graphic in self.removeGraphics) {
            NSString* g_keyId = graphic.keyId;
            if ([g_keyId isEqualToString:keyId]) {
                [self.pictureGraphicsLayer addGraphic:graphic];
                [self.mapView zoomToGeometry:graphic.geometry withPadding:100.0 animated:YES];
                break;
            }
        }
    }
}

-(void)zoomFullMap {
    [self zoomfull];
}


//创建
-(void)CreateFilterTheme{
    self.themeFilterControl = [[SEFilterControl alloc]initWithFrame:CGRectMake(0, 638, 385, 20) Titles:[NSArray arrayWithObjects:@"全部", @"基础", @"转换", @"标准", @"封顶", @"外立面", nil]];
    [self.themeFilterControl addTarget:self action:@selector(phFilterValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.themeFilterControl.layer.shadowColor = [UIColor grayColor].CGColor;
    self.themeFilterControl.layer.shadowOpacity = 1.0;
    self.themeFilterControl.layer.cornerRadius = 5;
    self.themeFilterControl.layer.shadowOffset = CGSizeMake(0,1);
    self.themeFilterControl.hidden = YES;
    self.themeFilterControl.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.themeFilterControl];
}
-(void)phFilterValueChanged:(UISegmentedControl *) sender{
    NSInteger selectIndex = sender.selectedSegmentIndex;
    _query_param_dateLevel = selectIndex - 1;
    [self c_updateBusinessData];
}

-(void)openFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext isLocalFile:(BOOL)isLocalFile{
    [self.delegate mapShouldShowFile:name path:path ext:ext];
}

-(void)allFiles:(NSArray *)files at:(int)index{
    [self.delegate mapShouldShowFiles:files at:index];
}


#pragma Mark- MapJobViewControllerDelegate代理

-(void)mapJobViewShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext{
    [self.delegate mapShouldShowFile:name path:path ext:ext];
    
    
    
}

-(void)mapJobViewShouldShowFiles:(NSArray *)materials at:(int)index{
    [self.delegate mapShouldShowFiles:materials at:index];
}


//点击查看地图图标详情
-(void)showDetailPanelAt:(int)index photoCode:(NSString *)code{
    [_searchResultPanel showDataAt:index photoCode:code];
}


#pragma mark -DistDateSelectorDelegate(日期选择代理方法)

-(void)distDateSelector:(DistDateSelector *)selector dateDisChanged:(NSDate *)start endDate:(NSDate *)end{
    _lblDateInfo.text=selector.dateString;
    //更新数据信息
    [self c_updateBusinessData];
}

#pragma mark - 工具菜单

//创建右下的操作控件(定位,放大,量尺寸等)
-(void)createMenu{
    
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    
    QuadCurveMenuItem *locateMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[UIImage imageNamed:@"maptool-locate"]
                                                         highlightedContentImage:nil];
    
    QuadCurveMenuItem *measureMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                 highlightedImage:storyMenuItemImagePressed
                                                                     ContentImage:[UIImage imageNamed:@"maptool-measure"]
                                                          highlightedContentImage:nil];
    
    QuadCurveMenuItem *zoomfullMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                  highlightedImage:storyMenuItemImagePressed
                                                                      ContentImage:[UIImage imageNamed:@"maptool-zoomfull"]
                                                           highlightedContentImage:nil];
    
    QuadCurveMenuItem *clearMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[UIImage imageNamed:@"maptool-clear"]
                                                        highlightedContentImage:nil];
    
    NSArray *menus = [NSArray arrayWithObjects:locateMenuItem, measureMenuItem, zoomfullMenuItem, clearMenuItem, nil];
    
    QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds menus:menus nearRadius:100.0f endRadius:110.0f farRadius:130.0f startPoint:CGPointMake(960, 670) timeOffset:0.026f angle:M_PI_2];
    menu.delegate = self;
    [self.view addSubview:menu];
}

//全图
-(void)zoomfull{
    defaultEnvelope=[[AGSEnvelope alloc] initWithXmin:DEFAULT_X_MIN ymin:DEFAULT_Y_MIN xmax:DEFAULT_X_MAX ymax:DEFAULT_Y_MAX spatialReference:self.mapView.spatialReference];
    
    [self.mapView zoomToEnvelope:defaultEnvelope animated:YES];
}

//清除
-(void)clear{
    [self.graphicsLayer removeAllGraphics];
    self.mapView.callout.hidden = YES;
    [self.mapView.locationDisplay stopDataSource];
}


#pragma  QuadCurveMenuDelegate -代理方法

- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx
{
    switch (idx) {
        case 0:
            [GPS startMapGPS:0 AGSMapView:self.mapView];
            break;
        case 1:
            [mearsureView showMearsureToolBar];
            break;
        case 2:
            [self zoomfull];
            break;
        case 3:
            [self clear];
            break;
        default:
            break;
    }
}

/******************* 高德地图 *******************/
/******************* 高德地图 *******************/
- (void)initGDMapView
{
    //764 720
    self.gdMapView = [[GDMapView alloc] initWithFrame:self.mapView.frame];
    [self.gdMapView setLocationInView:self.view frame:CGRectMake(1024 - 80, 768-44-80, 40, 40)];
    [self.mapView addSubview:self.gdMapView];
    
    //    self.traceManager = [[MATraceManager alloc] init];
}



@end
