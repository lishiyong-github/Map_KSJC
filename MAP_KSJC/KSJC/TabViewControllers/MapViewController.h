//
//  MapViewController.h
//  zzzf
//
//  Created by Aaron on 14-3-3.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "NavigatorButton.h"
#import "QuadCurveMenu.h"
#import "MearsureView.h"
#import "DistDateSelector.h"
#import "GPS.h"
#import "LayerManager.h"
#import "JobDetailView.h"
#import "TouchableMapView.h"
#import "MapSearchResultPanel.h"
#import "SEFilterControl.h"
#import "OpenFileDelegate.h"
#import "MapJobViewController.h"
#import "MapConfig.h"
#import "OMBaseItem.h"

@protocol MapViewDelegate <NSObject>

-(void)mapShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext;
-(void)mapShouldShowFiles:(NSArray *)files at:(int)index;
@end

@interface MapViewController : UIViewController <AGSWebMapDelegate, AGSMapViewTouchDelegate, AGSCalloutDelegate, AGSIdentifyTaskDelegate,AGSQueryTaskDelegate,UIAlertViewDelegate, AGSPopupsContainerDelegate,QuadCurveMenuDelegate,DistDateSelectorDelegate,AGSMapViewLayerDelegate,MapViewTouchDelegate,MapSearchResultPanelDelegate,OpenFileDelegate,MapJobViewControllerDelegate>  {
    TouchableMapView *_mapView;//AGSMapView(继承自)
    AGSGraphicsLayer *_graphicsLayer;
    AGSIdentifyTask *_identifyTask;
    AGSIdentifyParameters *_identifyParameters;
    AGSPoint *_mapPoint;
    NSMutableArray *_visableLayers;
    UILabel *_lblDateInfo;
    UIButton *btnSwitchMap;
    NSMutableArray *mutableArray;
    MearsureView *mearsureView;
    GPS *_gps;
    NSMutableArray *_graphicsArray;
    NSMutableArray *_imageViewsArray;
    NSArray *_orgList;
    int _query_param_datatype;
    int _query_param_dateLevel;
    NSString *_query_param_org;
    MapSearchResultPanel *_searchResultPanel;
    DistDateSelector *_dateSelector;
    int _queryFlagM ;
    int _dataTypeM;
    NSTimer *_delayLoaderM;
    NSString *_busiType;
        NSMutableArray *identifyFullResult;
        int queryCounter;
        NSString *rcxcUrl;
    
    
 
}

//定位查询
@property (nonatomic, strong) AGSQueryTask *queryTask;//保存位置
@property (nonatomic, strong) AGSQuery *query;

@property (weak, nonatomic) IBOutlet TouchableMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet NavigatorButton *currentNav;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//动态图层
@property (nonatomic, strong) AGSDynamicMapServiceLayer *dyMapServiceLayer;
@property (weak, nonatomic) IBOutlet UIImageView *mapTypeSelectorImg;
@property (retain, nonatomic) IBOutlet UIButton *btnSwitchMap;
@property (nonatomic,retain) id<MapViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *businessTypeGroupContainer;
//图形图层
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;

@property (nonatomic, strong) AGSGraphicsLayer *pictureGraphicsLayer;
@property (strong,nonatomic)  NSMutableArray *removeGraphics;
@property (strong,nonatomic)  NSString *layerFilter;

@property (strong,nonatomic) NSString                            *identifyLayerFilter;
@property (strong,nonatomic) AGSGraphicsLayer                    *indentifyGraphicsLayer;
@property (strong,nonatomic) AGSIdentifyTask                     *identifyTask;
@property (strong,nonatomic) AGSIdentifyParameters               *identifyParameters;
@property (strong,nonatomic) NSMutableArray                      *identifyResults;
@property (strong,nonatomic) AGSPoint                            *mapPoint;
@property (strong,nonatomic) AGSPopupsContainerViewController    *popContainerViewController;
@property (strong,nonatomic) UIActivityIndicatorView             *activityIndicator;
@property (strong,nonatomic) NSMutableDictionary                 *filedInfo;
@property (assign,nonatomic) NSInteger                           identifyCount;
@property (strong,nonatomic) NSMutableDictionary                 *visibleLayersDict;
@property (strong,nonatomic) AGSGraphic                          *focusGraphic;

//图层容器view
@property (weak, nonatomic) IBOutlet UIView *layerGroupContainer;
//默认选中巡查记录
@property (strong, nonatomic) IBOutlet SysButton *btnDefaultRCXC;

@property (nonatomic, strong) SEFilterControl *themeFilterControl;

@property (nonatomic, strong) AGSPopupsContainerViewController *popupVC;

//图层树TableView
@property (weak, nonatomic) IBOutlet UITableView *themeTableView;

@property (strong,nonatomic) NSDictionary                   *allGroupsDic;
@property (strong,nonatomic) NSArray                        *mapServices;
@property (strong,nonatomic) NSArray                        *rootGroups;
@property (strong,nonatomic) NSMutableArray                 *itemsArray;
@property (strong,nonatomic) NSMutableArray                 *expandedItems;
@property (strong,nonatomic) NSMutableArray                 *allVisibleLayerIds;
@property (strong,nonatomic) NSMutableDictionary            *serviceLayerDic;

- (IBAction)onNavTap:(id)sender;
- (IBAction)btnSwitchBaseMap:(id)sender;
- (IBAction)switchAction:(id)sender;
- (void)mapDidClickAtEmpty;

-(void)showDetailPanelAt:(int)index photoCode:(NSString *)code;
-(void)CreateFilterTheme;
@end

















































