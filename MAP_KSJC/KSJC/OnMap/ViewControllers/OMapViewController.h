//
//  MapViewController.h
//  zzOneMap
//
//  Created by zhangliang on 13-12-3.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "RNFrostedSidebar.h"
#import "QuadCurveMenu.h"
#import "LayerManager.h"
#import "MZFormSheetController.h"
#import "UserInfoControlPanel.h"
#import "SettingControlPanel.h"
#import "FavoritePanel.h"
#import "MearsureView.h"
#import "GPS.h"
#import "ResourceViewController.h"
#import "DailyJobListener.h"
#import "SEFilterControl.h"
#import "TouchableMapView.h"
#import "DailyJobReaderViewController.h"
#import "MapJobViewController.h"
#import "LeaderStatViewController.h"
#import "MapSearchResultPanel.h"
#import "OpenFileDelegate.h"


@protocol OMapViewDelegate <NSObject>

-(void)oMapShouldShowResource;
-(void)oMapShouldSHowZZYD;
@optional
-(void)oMapShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext;
-(void)oMapShouldShowFiles:(NSArray *)files at:(int)index;
@end

@interface OMapViewController : UIViewController<RNFrostedSidebarDelegate,QuadCurveMenuDelegate,LayerManagerDelegate,AGSWebMapDelegate, AGSCalloutDelegate, AGSMapViewTouchDelegate, UIAlertViewDelegate, AGSPopupsContainerDelegate,AGSIdentifyTaskDelegate,ControlPanelDelegate,FavoriteViewDelegate,AGSMapViewLayerDelegate,DailyJobListenerDelegate,MapViewTouchDelegate,MapSearchResultPanelDelegate,OpenFileDelegate,MapJobViewControllerDelegate>
{
    UserInfoControlPanel *_userInfoPanel;
    SettingControlPanel *_settingPanel;
    LayerManager *_layerManager;
    FavoritePanel *_favoritePanel;
    LeaderStatViewController *_statView;
    NSDictionary *_currentGraphicAttribute;
    AGSDynamicMapServiceLayer *_themeLayer;
    ControlPanel *_currentPanel;
    MearsureView *_mearsureView;
    GPS *_gps;
    QuadCurveMenu *_dateSelector;
    UIImageView *imgView;
    SysButton *toggleBtn;
    UILabel *_currentDailyJobLabel;
    NSMutableArray *_currentDailyJobs;
    DailyJobListener *_dailyJobListener;
    NSMutableArray *_graphicsArray;
    NSMutableArray *_imageViewsArray;
    MapSearchResultPanel *_searchResultPanel;
    NSArray *_orgList;
    int _query_param_datatype;
    int _query_param_datetype;
    NSString *_query_param_org;
    int _query_param_dateLevel;
    SysButton *_currengOrgButton;
    NSMutableArray *_currentDailyJobLocationViews;
    NSDate *startDateTime;
    NSDate *endDateTime;
    NSDate *nowDateTime;
    NSString *_busiDataType;
}

- (IBAction)onBtnDateSelectorClick:(id)sender;
@property (nonatomic,retain) id<OMapViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet TouchableMapView *mapView;
@property (nonatomic, strong) NSMutableIndexSet *optionIndices;
@property (weak, nonatomic) IBOutlet UISearchBar *mapSearchBar;
@property (weak, nonatomic) IBOutlet UIView *mapComtainer;
@property (weak, nonatomic) IBOutlet SysButton *btnNavMenu;
@property (weak, nonatomic) IBOutlet SysButton *btnNavCar;
@property (strong, nonatomic) IBOutlet SysButton *btnFilterDate;

@property (strong,nonatomic) IBOutlet NSString *layerFilter;
@property (strong,nonatomic) IBOutlet NSMutableArray *removeGraphics;
@property (strong, nonatomic) IBOutlet NSMutableDictionary *identityParamDic;
//保存swith
@property (weak, nonatomic) IBOutlet UIView *switchContainer;
@property (nonatomic, strong) AGSDynamicMapServiceLayer *dyMapServiceLayer;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, strong) AGSGraphicsLayer *pictureGraphicsLayer;
@property (nonatomic, strong) AGSIdentifyTask *identifyTask;
@property (nonatomic, strong) AGSIdentifyParameters *identifyParams;
@property (strong,nonatomic)  NSString *identifyLayerFilter;
@property (nonatomic, strong) AGSPoint* mappoint;

@property (nonatomic, strong) AGSQueryTask *queryTask;
@property (nonatomic, strong) AGSQuery *query;
@property (nonatomic, strong) AGSFeatureSet *featureSet;

@property (weak, nonatomic) IBOutlet UISwitch *defaultDataTypeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *switchFYX;
@property (strong, nonatomic) IBOutlet UISwitch *switchPH;
@property (strong, nonatomic) IBOutlet UISwitch *switchWF;
@property (strong, nonatomic) IBOutlet UISwitch *switchTG;

@property (nonatomic, strong) AGSPopup *favoritePopup;
@property (nonatomic, strong) UITextField *txtFavoriteTitle;
@property (nonatomic, strong) UIBarButtonItem *rightButton;

@property (nonatomic, strong) AGSPopupsContainerViewController *popupVC;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
//组织view
@property (weak, nonatomic) IBOutlet UIView *orgView;
@property (weak, nonatomic) IBOutlet SysButton *btnOrg1;
@property (weak, nonatomic) IBOutlet SysButton *btnOrg2;
@property (weak, nonatomic) IBOutlet SysButton *btnOrg3;
@property (weak, nonatomic) IBOutlet SysButton *btnOrg4;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet SysButton *btnNexDate;

@property (nonatomic, strong) SEFilterControl *themeFilterControl;
@property (nonatomic, strong) UIView *themeFilterView;

- (IBAction)onMenuClick:(id)sender;

-(void)setBoxLayerStyle:(CALayer *)layer;
-(void)zoomfull;
-(void)clear;
-(void)moveMapTo:(int)x;
- (IBAction)switchTheme:(id)sender;
-(void)createThumbPhotos;
-(void)mapDidClickAtEmpty;
-(void)showDetailPanelAt:(int)index photoCode:(NSString *)code;
-(void)CreateFilterTheme;
- (IBAction)lastDate:(id)sender;
- (IBAction)nextDate:(id)sender;
-(void)dateFilter:(NSDate*)nowDate;
@end
