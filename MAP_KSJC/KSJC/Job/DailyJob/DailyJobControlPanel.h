//
//  DailyJobControlPanel.h
//  zzzf
//
//  Created by dist on 13-12-11.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "SysButton.h"
#import "JobPhotoView.h"
#import "StopWorkFormView.h"
#import "DailyJobReport.h"
#import "ServiceProvider.h"
#import "GPS.h"
#import "CurrentLocationView.h"
#import "LayerManager.h"
#import "AFNetworking.h"

//gps定位模式
enum GPSLocationMode : NSUInteger {
    GPSLocationNoneMode = 0,    //不定位
    GPSLocationAutoMode = 1,    //自动定位
    GPSLocationManualMode = 2   //手动定位
};
typedef enum GPSLocationMode GPSLocationMode;

@protocol DailyJobControlPanelDelegate <NSObject>
@optional
-(void)dailyJobCompleted;
@optional
-(void)showcalader;

@optional
-(void)refershJob;
@optional
-(void)openPhoto:(NSString *)name path:(NSString *)path fromLocal:(BOOL)fromLocal;
//新加的方法
@optional
-(void)openPhotos:(NSArray *)photos currentPhoto:(NSString *)fileName url:(NSString *)photoUrl ext:(NSString *)ext fromLocal:(BOOL)fromLocal;
//最新添加
@optional
-(void)allFiles:(NSArray *)files at:(int)index;

@optional
-(void)showCalendarView;
@end

@interface DailyJobControlPanel : UIView<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,JobPhotoTapDegelate,StopWorkFormDelegate,UITableViewDataSource,UITableViewDelegate,DailyJobReportDelegate,GPSDelegate,ServiceCallbackDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate,AGSMapViewLayerDelegate,AGSMapViewTouchDelegate,AGSPopupsContainerDelegate,AGSIdentifyTaskDelegate>
{
    BOOL _panelInitialized;
    int _updateFormIndex;
    UIImagePickerController *_picker;
    //NSMutableDictionary *_photos;
    NSString *_dailyJobPath;
    //NSString *_photoplistPath;
    NSString *_photoSaveDirecotry;
    UIImage *_thePhotoFromCamera;
    int imgTag;
    NSString *_reComfirmPhotoName;
    JobPhotoView *_currentSelectedPhoto;
    UIView *_noDataView;
    NSMutableDictionary *_jobInfo;
    StopWorkFormView *_stopworkFormView;
    DailyJobReport *_reportView;
    BOOL _readonly;
    NSTimer *_gpsTimer;
    GPS *_gpsLoader;
    CLLocationCoordinate2D _location;
    NSMutableArray *_mayUploadPhotos;
    NSMutableArray *_mayUploadPhotosClone;
    int _submitIndex;
    BOOL _mayCompleted;
    BOOL _photoAsyHasError;
    CurrentLocationView *_currentLocationView;
    BOOL _firstLocation;
    AGSPoint *_currentLocation;
    
    UIPopoverController *poverController;
    
    NSString *_newPhotoName;
    

}
@property (nonatomic,assign)BOOL isRevice;
@property (weak, nonatomic) IBOutlet UILabel *lblPdaPositionInfo;
//整改单label
@property (weak, nonatomic) IBOutlet UILabel *lbCorrectiveInfo;
@property (weak, nonatomic) IBOutlet UIScrollView *thumbPhotoContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblNoImg;
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *lblOrg;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblPDA;
@property (weak, nonatomic) IBOutlet UILabel *lblWaitMsg;
@property (weak, nonatomic) IBOutlet SysButton *btnDeletePhoto;
@property (weak, nonatomic) IBOutlet UITableView *stopWorkFormTableView;
@property (weak, nonatomic) IBOutlet UITableView *correctiveTableView;
@property (weak, nonatomic) IBOutlet SysButton *btnNewCorrectiveForm;
@property (retain,nonatomic) id<DailyJobControlPanelDelegate> delegate;
@property (weak, nonatomic) IBOutlet SysButton *btnNewStopworkForm;
@property (weak, nonatomic) IBOutlet SysButton *btnGetPhoto;
//停工单label
@property (weak, nonatomic) IBOutlet UILabel *lblStopworkFromInfo;
@property (weak, nonatomic) IBOutlet SysButton *btnClose;
@property (weak, nonatomic) IBOutlet SysButton *btnAsyPhoto;
@property (weak, nonatomic) IBOutlet UIView *asyPhotoView;

//定位图标
@property (strong,nonatomic) AGSGraphicsLayer                    *gpsGraphicLayer;
//i 查询
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

- (IBAction)onBtnCloseTap:(id)sender;
+(DailyJobControlPanel *)createView;
- (IBAction)onBtnNewStopworkFormTap:(id)sender;
- (IBAction)onBtnReportTap:(id)sender;
- (IBAction)onBtnNewCorrectiveFormTap:(id)sender;
- (IBAction)onBtnLocationTap:(id)sender;
- (IBAction)onBtnCompletedTap:(id)sender;
- (IBAction)onBtnResumeTap:(id)sender;
- (IBAction)onBtnPauseTap:(id)sender;
- (IBAction)onBtnAsyPhotoTap:(id)sender;
- (IBAction)addPersonClick:(id)sender;
- (IBAction)onBtnRenamePhotoTap:(id)sender;
@property (weak, nonatomic) IBOutlet SysButton *btnAnsy;
//停工单
@property (weak, nonatomic) IBOutlet UIView *stopworkListGroupContainer;
//整改单
@property (weak, nonatomic) IBOutlet UIView *correctiveListGroupContainer;
//巡查报告
@property (weak, nonatomic) IBOutlet SysButton *btnJobReport;
@property (weak, nonatomic) IBOutlet UIView *addPersonBackView;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;

@property (weak, nonatomic) IBOutlet SysButton *addPersonBtn;

@property (weak, nonatomic) IBOutlet SysButton *btnPause;
@property (weak, nonatomic) IBOutlet SysButton *btnCompleted;
@property (weak, nonatomic) IBOutlet SysButton *btnReStart;
@property (weak, nonatomic) IBOutlet SysButton *btnLocation;
@property (weak, nonatomic) IBOutlet UIView *pauseView;
@property (weak, nonatomic) IBOutlet UILabel *lblPauseInfo;
@property (weak, nonatomic) IBOutlet SysButton *btnRenamePhoto;

@property (weak, nonatomic) IBOutlet UIImageView *mapTypeSelectorImg;
@property (retain, nonatomic) IBOutlet UIButton *btnSwitchMap;
//基本信息TableView
@property (weak, nonatomic) IBOutlet UITableView *baseTabelView;
@property(nonatomic,strong) NSArray *infoArray;
@property(nonatomic,strong) NSMutableArray *markArray;//标记数组(分组收放)
@property(nonatomic,strong) NSMutableArray *groupImgArray;//分组图标
@property(nonatomic,strong) NSMutableArray *detailArray_in;//详细信息
@property(nonatomic,strong) NSMutableArray *detailArray_out;//基本信息

//填写巡查信息背景view
@property (weak, nonatomic) IBOutlet UIView *addxcInformBV;
@property (weak, nonatomic) IBOutlet UITextView *LogTitleTextView;
//验线 是
@property (weak, nonatomic) IBOutlet SysButton *yxTrue;
//验线 否
@property (weak, nonatomic) IBOutlet SysButton *yxFalse;

//工程 是
@property (weak, nonatomic) IBOutlet SysButton *gczTrue;
//工程 否
@property (weak, nonatomic) IBOutlet SysButton *gczFalse;

//建设情况textView
@property (weak, nonatomic) IBOutlet UITextView *ConStructcdTextView;

//用来判断材料目录是否创建好
@property (nonatomic,assign)BOOL isfinishCreated;

//用来判断是否是退出系统重新登录的
@property (nonatomic,assign)BOOL isreloading;

- (IBAction)yxTrueClick:(id)sender;

- (IBAction)ysFalseClick:(id)sender;
- (IBAction)GczTrueClick:(id)sender;
- (IBAction)GczFalseClick:(id)sender;

-(IBAction)onBtnPhotographTap:(id)sender;
-(IBAction)onBtnDeletePhotoTap:(id)sender;
-(void)startNewDailyJobwithProjectInfo:(NSMutableDictionary *)dict andMatrial:(NSMutableArray *)materialA;
//开始巡查+新建目录
-(void)startNewxcWithInformDict:(NSMutableDictionary *)dict andMatrial:(NSMutableArray *)materialA;



//-(void)startNewDailyJob;
-(void)initialzePanel;
-(void)refersh;
-(void)loadJob:(NSMutableDictionary *)data;

@end
