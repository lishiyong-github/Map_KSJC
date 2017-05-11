//
//  JobDetailView.h
//  zzzf
//
//  Created by dist on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//表单材料等详情View

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"
//#import "ProjectInfo.h"
#import "MaterialSelectorViewController.h"
#import "FormSelectorViewController.h"
#import "FileDownload.h"
#import "Global.h"
#import "SysButton.h"
#import "DataPostman.h"
#import "StopWorkFormView2.h"
#import "FormSendViewController.h"
#import "DatePickerViewController.h"
#import "JobPhotoView.h"
#import "MZFormSheetController.h"
#import "MapLocationView.h"

#import "NewDailyJobViewController.h"
#import "DailyJobControlPanel.h"

static NSString *PROJECTKEY_ID = @"projectId";
static NSString *PROJECTKEY_XMBH = @"xmbh";
static NSString *PROJECTKEY_NAME = @"projectName";
static NSString *PROJECTKEY_FORMS = @"forms";
static NSString *PROJECTKEY_MATERIALS = @"materials";
static NSString *PROJECTKEY_PHOTOS = @"photos";
static NSString *PROJECTKEY_STOPWORKFORMS = @"stopworkforms";
static NSString *PROJECTKEY_LOG = @"log";
static NSString *PROJECTKEY_PHLOG = @"phlog";

static NSString *PROJECTKEY_SLBH = @"slbh";
static NSString *PROJECTKEY_COMPANY = @"company";
static NSString *PROJECTKEY_ADDRESS = @"address";


@protocol JobDetailViewDelegate <NSObject>

//-(void)jobDetailClosed;
@optional
-(void)openMaterial:(NSString *)materialName path:(NSString *)path ext:(NSString *)ext fromLocal:(BOOL)fromLocal;

-(void)openMaterial:(NSArray *)materials at:(int)index;

@optional
-(void)jobDetailViewShouldClose;

@optional
-(void)jobInfoDidLoadFromNetwork;

-(void)shouldReLoadList;

-(void)pushMapviewController;

- (void)popXCJMwith:(NSMutableDictionary *)dict andwithMaterialA:(NSMutableArray *)theMatrialA;
@end




@class MapJobViewController;

@interface JobDetailView : UIView<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ServiceCallbackDelegate,UITableViewDelegate,UITableViewDataSource,FileDownloadDelegate,MaterialSelectorDelegate,FormSelectorDelegate,UIAlertViewDelegate,UIWebViewDelegate,ASIHTTPRequestDelegate,FormSendCompletedDelegate,FormDatePickerDelegate,UIPopoverControllerDelegate,MapLocationDelegate,AGSQueryTaskDelegate>
{
    NSMutableDictionary *_project;
    ServiceProvider *_materialProvider;
    ServiceProvider *_formProvider;
    ServiceProvider *_formDetailProvider;

    ServiceProvider *_photoProvider;
    ServiceProvider *_stopworkformProvider;
    ServiceProvider *_correctiveformProvider;
    ServiceProvider *_logProvider;
    ServiceProvider *_phjlProvider;
    ServiceProvider *_mapProvider;
    ServiceProvider *_mapProviderLocation;
    int _dataLoadFlag;
    BOOL _viewInitialized;
    
    MaterialSelectorViewController *_materialGroupSelector;
    FormSelectorViewController *_formSelector;
    BOOL _reOpenMaterialSheet;
    //选中表单的index
    NSInteger formSelectIndex;
    NSString *_projectPath;
    NSString *_type;
    int _phFlowState;
    BOOL _photoThumbCreated;
    NSString *_newFormJson;
    NSString *_projectSavePath;
    BOOL _readonly;
   
    
    //停工单view
    StopWorkFormView2 *_stopworkFormView;
    BOOL _formDataInitialized;
    
    JobPhotoView *_currentSelectedPhoto;

    UIPopoverController *poverController;
    
    /*Photo Catagory*/
    UIImagePickerController *_picker;
    NSString *_photoSaveDirecotry;
    NSString *_photoMayUploadListFilePath;
    NSMutableArray *_mayUploadPhotos;
    NSMutableArray *_mayUploadPhotosClone;
    NSMutableArray *_allPhotos;
    GPS *_gpsLoader;
    NSString *_gpsInfo;
    NSString *_newPhotoName;
    UIImage *_currentSelectorPhoto;
    NSMutableArray *_ansyCompletedPhotos;
    ServiceProvider *_rnSp;
    UIAlertView *_reAlertView;
    //定位
    MapLocationView *_mapLocationView;
    NewDailyJobViewController *_newDailyJobViewController;
    
    DailyJobControlPanel *_jobControlPanel;

    

}

//定位查询
@property (nonatomic, strong) AGSQueryTask *queryTask;//保存位置
@property (nonatomic, strong) AGSQuery *query;



@property (weak, nonatomic) IBOutlet SysButton *btnSend;
@property (weak, nonatomic) IBOutlet SysButton *btnStopwork;
//整改
@property (weak, nonatomic) IBOutlet SysButton *btnCorrective;
//定位按钮
@property (weak, nonatomic) IBOutlet SysButton *btnLocation;
@property (weak, nonatomic) IBOutlet SysButton *btnPhotos;
//拍照
@property (weak, nonatomic) IBOutlet SysButton *btnGetPhoto;
@property (weak, nonatomic) IBOutlet UITableView *logTableView;
@property (weak, nonatomic) IBOutlet UITableView *phLogTableView;
//从地图模块跳进来(用于重新布局)
@property (nonatomic,assign)BOOL jumpfromMap;
//用户记录是从在建巡查 通过map 跳进来的
@property (nonatomic,assign)BOOL throughfromMap;

//点击了记录
@property(nonatomic,assign)BOOL ThelogClick;
//某条记录的巡查时间
@property (nonatomic,strong)NSString *xcTime;

@property (nonatomic,strong)NSDictionary *theLogDict;

- (IBAction)onBtnMenuTap:(id)sender;
- (IBAction)onCloseButtonTap:(id)sender;
//初始化
-(void)initializedView;
//根据xib创建view
+(JobDetailView *)createView;
//加载某行cell的数据
-(void) loadProject:(NSMutableDictionary *)theProject typeName:(NSString *)typeName;
-(IBAction)onCameraMenuItemTap:(id)sender;
-(IBAction)onStopworkMenuItemTap:(id)sender;
- (IBAction)onDownLoadItemTap:(id)sender;
- (IBAction)onRemoveItemTap:(id)sender;
//点击编辑表单按钮
- (IBAction)onModifyFormDetail:(id)sender;
- (IBAction)onBtnSendTap:(id)sender;
//点击提交
- (IBAction)onDoFormDetail:(id)sender;
//取消修改
- (IBAction)onCancelFormDetail:(id)sender;
//点击表单名字,更换表单(表单选择)
- (IBAction)onFormList:(id)sender;
- (IBAction)onBtnDeletePhotoTap:(id)sender;
- (IBAction)onBtnSubmitPhotoTap:(id)sender;
//点击定位按钮
- (IBAction)onBtnCorrectiveTap:(id)sender;
//点击定位按钮方法
- (IBAction)onBtnLationProject:(id)sender;
- (IBAction)onBtnOpenPhotoList:(id)sender;
- (IBAction)onBtnClosePhotoList:(id)sender;
- (IBAction)onBtnRenamePhotoTap:(id)sender;
-(void)setPhFlowState:(int)flowState;
-(void)saveProjectToDisk;
-(void)setReadonly:(BOOL)readonly;

@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *jobMenuView;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;
//编辑表单
@property (weak, nonatomic) IBOutlet SysButton *btnModifyFormDetail;
//提交
@property (weak, nonatomic) IBOutlet SysButton *btnDoFormDetail;
//取消编辑
@property (weak, nonatomic) IBOutlet SysButton *btnCancelFormDetail;
@property (weak, nonatomic) IBOutlet UIWebView *formWebView;
@property (weak, nonatomic) IBOutlet UITableView *materialTable;
//mapjobDetailView.xib上的tabelview
@property (weak, nonatomic) IBOutlet UITableView *formTable;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectName;
@property (weak, nonatomic) IBOutlet UILabel *lblDownStatus;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *formActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *materialActivityIndicator;
@property (weak, nonatomic) IBOutlet UIView *offlineView;
@property (weak, nonatomic) IBOutlet SysButton *btnBackToMap;
- (IBAction)onBtnGoback:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (nonatomic,retain) id<JobDetailViewDelegate> delegate;


@property (weak, nonatomic) IBOutlet SysButton *btnFormName;
@property (weak, nonatomic) IBOutlet UIScrollView *thumbPhotoContainer;
@property (weak, nonatomic) IBOutlet SysButton *btnDeletePhoto;
@property (weak, nonatomic) IBOutlet SysButton *btnSubmitPhoto;
@property (weak, nonatomic) IBOutlet SysButton *btnRenamePhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblNoImg;
//放按钮的背景view /编辑表单/发送/提交/取消编辑/
@property (weak, nonatomic) IBOutlet UIView *viewOperation;
@property (weak, nonatomic) IBOutlet UIView *viewSplit;
@property (weak, nonatomic) IBOutlet SysButton *btnClosePhotoList;

@property (nonatomic,assign)BOOL isSP;
@property (nonatomic,assign)BOOL openOrClose;
@property (nonatomic,strong)NSString *formIdentity;

@end



