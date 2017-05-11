//
//  MapViewController.m
//  zzOneMap
//
//  Created by zhangliang on 13-12-3.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "OMapViewController.h"
#import "OMapViewController+MapTypeToggle.h"
#import "OMapViewController+searchBar.h"
#import "OMapViewController+MenuAndTools.h"
#import "WMTSLayer.h"
#import "OMapViewController+IdentifyPictureMarker.h"
#import "OMapViewController+CurrentDailyJob.h"
#import "OMapViewController+IdentifyPictureMarker.h"
#import "OMapViewController+BusinessDataQuery.h"
#import "OMapViewController+ServiceLoader.h"
#import "CurrentLocationView.h"

@interface OMapViewController ()

@end

@implementation OMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=true;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createToggle];
    [self initSearchBar];
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 7.0)
    {
        CGRect switchFrame = self.defaultDataTypeSwitch.frame;
        switchFrame.origin.x = -8;
        switchFrame.origin.y = self.defaultDataTypeSwitch.frame.origin.y;
        self.defaultDataTypeSwitch.frame = switchFrame;
        
        
        switchFrame.origin.y = self.switchFYX.frame.origin.y;
        self.switchFYX.frame = switchFrame;
        
        switchFrame.origin.y = self.switchPH.frame.origin.y;
        self.switchPH.frame = switchFrame;
        
        switchFrame.origin.y = self.switchWF.frame.origin.y;
        self.switchWF.frame = switchFrame;
        
        switchFrame.origin.y = self.switchTG.frame.origin.y;
        self.switchTG.frame = switchFrame;
        
        self.defaultDataTypeSwitch.transform = CGAffineTransformMakeScale(0.7, 1.0);
        self.switchFYX.transform = CGAffineTransformMakeScale(0.7, 1.0);
        self.switchPH.transform = CGAffineTransformMakeScale(0.7, 1.0);
        self.switchWF.transform = CGAffineTransformMakeScale(0.7, 1.0);
        self.switchTG.transform = CGAffineTransformMakeScale(0.7, 1.0);
    }
    
    _query_param_dateLevel = -1;
    

//    self.mapView.showMagnifierOnTapAndHold = YES;
    self.identityParamDic = [[NSMutableDictionary alloc] init];
//    NSThread *mapInitThread = [[NSThread alloc] initWithTarget:self selector:@selector(createMapBySubThread) object:nil];
//    [mapInitThread start];
    [self createMapBySubThread];
    
    self.mapView.touchDelegate = self;
    self.mapView.callout.delegate = self;
    self.mapView.layerDelegate = self;
    self.optionIndices = [NSMutableIndexSet indexSetWithIndex:1];
    
    [self initMenuAndTools];
    
    self.mapView.mapTouchDelegate = self;
    
    _dailyJobListener = [[DailyJobListener alloc] init];
    _dailyJobListener.delegate = self;
    [_dailyJobListener startListener];
    [self initDataQueryList];
    [self initMapServices];
    
}

-(void)createMapBySubThread{
    //矢量底图
    [LayerManager addAGSLayer:self.mapView LayerName:SHT getLayerType:@"WMTS" layerVisible:YES];
    
    [self zoomfull];
    
    [_themeLayer setVisibleLayers:[NSArray arrayWithObjects: nil]];
    
    self.dyMapServiceLayer = [LayerManager addAGSDynamicMapServiceLayer:self.mapView];

    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.graphicsLayer withName:@"IdentityGraphicsLayer"];
    
    self.pictureGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.pictureGraphicsLayer withName:@"PictureGraphicsLayer"];
}

-(void)setBoxLayerStyle:(CALayer *)layer{
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOpacity = 1.0;
    layer.shadowOffset = CGSizeMake(0,1);
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 1.0f;
}

-(void)mapViewDidLoad:(AGSMapView *)mapView{
    [self CreateFilterTheme];
    [self createThumbPhotos];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:) name:@"AGSMapViewDidEndZoomingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:) name:@"AGSMapViewDidEndPanningNotification" object:nil];
}

-(void)respondToEnvChange:(NSNotification *) notification{
    if (nil==_currentDailyJobLocationViews) {
        return;
    }
    for (int i=0; i<_currentDailyJobLocationViews.count; i++) {
        CurrentLocationView *locationView = [_currentDailyJobLocationViews objectAtIndex:i];
        CGPoint sp = [self.mapView toScreenPoint:locationView.point];
        locationView.frame = CGRectMake(sp.x-24, sp.y-24, 48, 48);
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onMenuClick:(id)sender {
    [self showSysMensu];
    [self moveMapTo:150];
    if (nil!=_currentPanel) {
        [_currentPanel moveToHide];
    }
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    index++;//隐藏了一期办公系统
    if (index==0) {
        //[self zoomfull];
        [self showZZYD];
        [self moveMapTo:0];
    }
    else if (index==1) {
        [self moveMapTo:300];
        _currentPanel = _layerManager;
        [_layerManager show];
    }
//    else if(index == 2){
//        [self moveMapTo:250];
//        [_favoritePanel show];
//        _currentPanel = _favoritePanel;
//    }
    else if(index ==2){
        [self moveMapTo:0];
        [NSTimer scheduledTimerWithTimeInterval:.6 target:self selector:@selector(showStatView) userInfo:nil repeats:NO];
    }
    else if (index==3) {
        [self showResourceView];
        [self moveMapTo:0];
        
    }
    else if(index==4){
        [self moveMapTo:300];
        [_userInfoPanel show];
        _currentPanel = _userInfoPanel;
    }
    else if(index==5){
        [_settingPanel show];
        [self moveMapTo:300];
        _currentPanel = _settingPanel;
    }
    [sidebar dismiss];
}


-(void)sidebar:(RNFrostedSidebar *)sidebar willDismissFromTap:(BOOL)animatedYesOrNo{
    [self moveMapTo:0];
}

-(void)zoomfull{
    AGSEnvelope *defaultEnvelope=[[AGSEnvelope alloc] initWithXmin:479252.2100000001 ymin:3062138.3599999994 xmax:531460.7300000001 ymax:3087631.0999999996 spatialReference:self.mapView.spatialReference];
    [self.mapView zoomToEnvelope:defaultEnvelope animated:YES];
}

-(void)clear{
    [self.graphicsLayer removeAllGraphics];
    //[self.graphicsLayer dataChanged];
    self.mapView.callout.hidden = YES;
    [self.mapView.locationDisplay stopDataSource];
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didEnable:(BOOL)itemEnabled itemAtIndex:(NSUInteger)index {
    if (itemEnabled) {
        [self.optionIndices addIndex:index];
    }
    else {
        [self.optionIndices removeIndex:index];
    }
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx
{
    if ((menu.tag==0)) {
        if (idx==0) {
            [GPS startMapGPS:0 AGSMapView:self.mapView];
        }
        if (idx==1) {
            [_mearsureView showMearsureToolBar];
        }
        if (idx==2) {
            [self zoomfull];
        }
        /*else if(idx==3){
            QuadCurveMenuItem *theMenuItem = [menu menuAt:idx];
            if (theMenuItem.highlightedImage == nil) {
                theMenuItem.contentImage = [UIImage imageNamed:@"maptool-iQuery"];
                theMenuItem.image = [UIImage imageNamed:@"bg-menuitem"];
                theMenuItem.highlightedImage = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
                //关闭i查询
            }else{
                theMenuItem.contentImage = [UIImage imageNamed:@"maptool-iQuery-green"];
                theMenuItem.image = [UIImage imageNamed:@"bg-menuitem-white"];
                theMenuItem.highlightedImage = nil;
                //打开i查询
            }
        }*/
        else if (idx==3) {
            [self clear];
        }
    }else if(menu.tag==1){
        if (_query_param_datetype==idx) {
            return;
        }
        nowDateTime = [NSDate date];
        _query_param_datetype = idx;
        [self updateBusinessData];
    }
}

-(void) setBorder:(CALayer *)theLayer{
    theLayer.shadowColor = [UIColor grayColor].CGColor;
    theLayer.shadowOpacity = 1.0;
    theLayer.shadowOffset = CGSizeMake(0,1);
    theLayer.borderColor = [[UIColor whiteColor] CGColor];
    theLayer.borderWidth = 1.0f;
}

-(void)controlPanelDidBack{
    [self onMenuClick:nil];
    _currentPanel = nil;
}

-(void)controlPanelDidClose{
    [self moveMapTo:0];
    _currentPanel=nil;
}

-(void)showZZYD{
    [self.delegate oMapShouldSHowZZYD];
}

-(void)showResourceView{
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //ResourceViewController *res = [[ResourceViewController alloc] init];
    [self.delegate oMapShouldShowResource];
}

-(void)showStatView{
    if(nil==_orgList){
        return;
    }
    if (nil==_statView) {
        _statView = [[LeaderStatViewController alloc] initWithNibName:@"LeaderStatViewController" bundle:nil];
        _statView.orgInfo = _orgList;
    }
    [self.navigationController pushViewController:_statView animated:YES];
}





-(void)LayerVisibleChanged:(NSString *)layerURL LayerType:(NSString *)layerType visible:(BOOL)visible{
//    if (visible) {
//        [self showLayer:layerId];
//    }else{
//        [self hideLayer:layerId];
//    }
    NSInteger layerIndex = self.mapView.mapLayers.count;
    if ([layerURL isEqual: @"KONGGUI"]){
        //控规
        [LayerManager insertAGSLayer:self.mapView LayerName:KONGGUI setLayerIndex:1 getLayerType:@"WMTS" layerVisible:visible];
    }
    else if ([layerURL isEqual: @"DM"]){
        //地名
        [LayerManager addAGSLayer:self.mapView LayerName:DM getLayerType:@"WMTS" layerVisible:visible];
    }
    else if ([layerURL isEqual: @"XZLX"]){
        //蓝线
        [LayerManager insertAGSLayer:self.mapView LayerName:XZLX setLayerIndex:layerIndex-3 getLayerType:@"DynamicLayer" layerVisible:visible];
        if (visible )
            [self.identityParamDic setValue:@"2" forKey:[LayerManager mapServiceUrl:XZLX]];
        else
            [self.identityParamDic removeObjectForKey:[LayerManager mapServiceUrl:XZLX]];
    }
    else if ([layerURL isEqual: @"YDHX"]){
        //红线
        [LayerManager insertAGSLayer:self.mapView LayerName:YDHX setLayerIndex:layerIndex-3 getLayerType:@"DynamicLayer" layerVisible:visible];
        if (visible )
            [self.identityParamDic setValue:@"2" forKey:[LayerManager mapServiceUrl:YDHX]];
        else
            [self.identityParamDic removeObjectForKey:[LayerManager mapServiceUrl:YDHX]];
    }
    else if ([layerURL isEqual: @"GHDL"]){
        //规划路网
        [LayerManager insertAGSLayer:self.mapView LayerName:GHDL setLayerIndex:layerIndex-3 getLayerType:@"WMTS" layerVisible:visible];
    }
    else if ([layerURL isEqual: @"XZDL"])
        //现状路网
        [LayerManager addAGSLayer:self.mapView LayerName:XZDL getLayerType:@"WMTS" layerVisible:visible];
    else if ([layerURL isEqual: @"XZQHBX"])
        //行政区划边线
        [LayerManager insertAGSLayer:self.mapView LayerName:XZQHBX setLayerIndex:layerIndex-3 getLayerType:@"WMTS" layerVisible:visible];
    
}



- (void)viewDidUnload{
    [super viewDidUnload];
    if (self.mapView.locationDisplay.dataSourceStarted) {
        [self.mapView.locationDisplay startDataSource];
    }
}
-(void)moveMapTo:(int)x{
    
    CGRect newFrame = CGRectMake(x, 0, 1024, 768);
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.mapComtainer.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
- (IBAction)onBtnDateSelectorClick:(id)sender {
    [_dateSelector setExpanding:![_dateSelector isExpanding]];
    
}

NSArray *photoNames;
NSMutableArray *photoArray;
-(void)createThumbPhotos{
    
}

- (IBAction)switchTheme:(id)sender {
    _query_param_dateLevel = -1;
    UISwitch *switchButton = (UISwitch *)sender;
    if (self.defaultDataTypeSwitch) {
        self.defaultDataTypeSwitch.on = NO;
        self.themeFilterView.hidden = YES;
    }
    if([switchButton isOn]){
        self.defaultDataTypeSwitch = switchButton;
        _query_param_datatype = switchButton.tag;
        [self updateBusinessData];
        if (self.defaultDataTypeSwitch.tag == 2) {
            self.themeFilterView.hidden = NO;
        }
    }else{
        self.defaultDataTypeSwitch = nil;
        _query_param_datatype = -1;
        [self updateBusinessData];
    }
}

-(void)mapDidClickAtEmpty{
    [_searchResultPanel close];
}

#pragma mark ---MapSearchResultPanelDelegate
-(void)mapSearchPanel:(MapSearchResultPanel *)panel openPhoto:(NSString *)name url:(NSString *)url ext:(NSString *)ext{
    [self.delegate oMapShouldShowFile:name path:url ext:ext];
}

-(void)mapSearchPanel:(MapSearchResultPanel *)panel openJobDaily:(NSDictionary *)data showStopworkform:(BOOL)showStopworkform{
    DailyJobReaderViewController *djvc = [[DailyJobReaderViewController alloc] initWithNibName:@"DailyJobReaderViewController" bundle:nil];
    djvc.fileDelegate = self;
    djvc.defaultDisplayStopworkfrom = showStopworkform;
    [self.navigationController pushViewController:djvc animated:YES];
    [djvc loadJobFromData:data];
}

-(void)mapSearchPanel:(MapSearchResultPanel *)panel openProject:(NSDictionary *)data showStopworkform:(BOOL)showStopworkform{
    MapJobViewController *mapj=[[MapJobViewController alloc] init];
    mapj.projectID = [data objectForKey:@"id"];
    mapj.delegate = self;
    mapj.type = _busiDataType;
    //mapj.jobDelegate = self.jobDelegate;
    [self.navigationController  pushViewController:mapj animated:YES];
    
}
-(void)filterRCXCLayer:(NSString *)layerFilter{
    [self.dyMapServiceLayer setVisible:NO];
    if (layerFilter.length == 0) {
        layerFilter = self.layerFilter;
    }
    self.identifyLayerFilter = layerFilter;
    AGSLayerDefinition *ld0 = [AGSLayerDefinition layerDefinitionWithLayerId:0 definition:layerFilter];
    AGSLayerDefinition *ld1 = [AGSLayerDefinition layerDefinitionWithLayerId:1 definition:layerFilter];
    NSArray *layerDefinitions = [[NSArray alloc]initWithObjects:ld0,ld1, nil];
    [self.dyMapServiceLayer setLayerDefinitions:layerDefinitions];
    [self.dyMapServiceLayer setVisible:YES];
}
-(void)filterPoint:(NSString*)fatherId{
    if (fatherId.length == 0) {
        [self.pictureGraphicsLayer addGraphics:self.removeGraphics];
        [self.removeGraphics removeAllObjects];
    }
    NSArray *pictureGraphics = [self.pictureGraphicsLayer graphics];
    for (AGSGraphic *graphic in pictureGraphics) {
        NSString *fId = [[graphic allAttributes]objectForKey:@"fatherId"];
        //        NSString *cId = [[graphic allAttributes]objectForKey:@"childId"];
        if(fatherId.length > 0){
            if (![fId isEqual:fatherId]) {
                [self.removeGraphics addObject:graphic];
            }
        }
    }
    [self.pictureGraphicsLayer removeGraphics:self.removeGraphics];
}
-(void)hideMapViewCallout{
    self.mapView.callout.hidden = YES;
    [self stopped];
}

-(void)CreateFilterTheme{
    self.themeFilterView = [[UIView alloc]initWithFrame:CGRectMake(2, self.mapView.frame.size.height-60, 385, 70)];
    self.themeFilterView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.themeFilterView.layer.shadowOpacity = 1.0;
    self.themeFilterView.layer.cornerRadius = 5;
    self.themeFilterView.layer.shadowOffset = CGSizeMake(0,1);
    self.themeFilterView.hidden = YES;
    self.themeFilterView.backgroundColor = [UIColor whiteColor];
    self.themeFilterControl = [[SEFilterControl alloc]initWithFrame:CGRectMake(0, 0, 385, 20) Titles:[NSArray arrayWithObjects:@"全部", @"基础", @"转换", @"标准", @"封顶", @"外立面", nil]];
    [self.themeFilterControl addTarget:self action:@selector(phFilterValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.themeFilterView addSubview:self.themeFilterControl];
    [self.mapView addSubview:self.themeFilterView];
}

- (IBAction)lastDate:(id)sender {
    NSTimeInterval secondsPerDay = 24*60*60;
    NSDate *yesterday = [startDateTime dateByAddingTimeInterval:-secondsPerDay];
    self.btnNexDate.enabled = YES;
    nowDateTime = yesterday;
    [self updateBusinessData];
}

- (IBAction)nextDate:(id)sender{
    NSTimeInterval secondsPerDay = 24*60*60;
    NSDate *tomorrow = [endDateTime dateByAddingTimeInterval:secondsPerDay];
    nowDateTime = tomorrow;
    [self updateBusinessData];
}
-(void)dateFilter:(NSDate*)nowDate{
    NSString *startDate;
    NSString *endDate;
    NSTimeInterval TimeInterval;
    NSDate *startOfDate;
    NSDate *endOfDate;
    
    if (nowDate == nil) {
        nowDate = [NSDate date];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setFirstWeekday:2];
    if (_query_param_datetype == 1) {
        [dateFormatter setDateFormat:@"yyyy年"];
        [calendar rangeOfUnit:NSYearCalendarUnit startDate:&startOfDate interval:&TimeInterval forDate:nowDate];
        endOfDate = [startOfDate dateByAddingTimeInterval:TimeInterval-1];
    }
    else if (_query_param_datetype == 2) {
        [dateFormatter setDateFormat:@"yyyy年MM月"];
        [calendar rangeOfUnit:NSQuarterCalendarUnit startDate:&startOfDate interval:&TimeInterval forDate:nowDate];
        endOfDate = [startOfDate dateByAddingTimeInterval:TimeInterval-1];
    }
    else if (_query_param_datetype == 3) {
        [dateFormatter setDateFormat:@"yyyy年MM月"];
        [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&startOfDate interval:&TimeInterval forDate:nowDate];
        endOfDate = [startOfDate dateByAddingTimeInterval:TimeInterval-1];
    }
    else if (_query_param_datetype == 4) {
        [dateFormatter setDateFormat:@"MM月dd日"];
        [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&startOfDate interval:&TimeInterval forDate:nowDate];
        endOfDate = [startOfDate dateByAddingTimeInterval:TimeInterval-1];
    }
    startDateTime = startOfDate;
    endDateTime = endOfDate;
    if ([endDateTime timeIntervalSinceDate:[NSDate date]]>0.0) {
        self.btnNexDate.enabled = NO;
    }
    startDate = [dateFormatter stringFromDate:startOfDate];
    endDate = [dateFormatter stringFromDate:endOfDate];
    [UIView animateWithDuration:0.5 animations:^{
            _lblDate.alpha = 0;
        }
        completion:^(BOOL finished){
            if (finished){
                if (_query_param_datetype == 1 || _query_param_datetype == 3) {
                    _lblDate.text = [NSString stringWithFormat:@"%@",startDate];
                }
                else{
                    _lblDate.text = [NSString stringWithFormat:@"%@\r\n|\r\n%@",startDate,endDate];
                }
                _lblDate.alpha = 1;
            }
    }];

}

-(void)phFilterValueChanged:(SEFilterControl *) sender{
    NSInteger selectIndex = sender.SelectedIndex;
    _query_param_dateLevel = selectIndex - 1;
    [self updateBusinessData];
}

-(void)openFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext isLocalFile:(BOOL)isLocalFile{
    [self.delegate oMapShouldShowFile:name path:path ext:ext];
}


-(void)mapJobViewShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext{
    [self.delegate oMapShouldShowFile:name path:path ext:ext];
}

-(void)mapJobViewShouldShowFiles:(NSArray *)materials at:(int)index{
    [self.delegate oMapShouldShowFiles:materials at:index];
}

-(void)allFiles:(NSArray *)files at:(int)index{
    [self.delegate oMapShouldShowFiles:files at:index];
}

-(void)showDetailPanelAt:(int)index photoCode:(NSString *)code{
    [_searchResultPanel showDataAt:index photoCode:code];
}

@end
