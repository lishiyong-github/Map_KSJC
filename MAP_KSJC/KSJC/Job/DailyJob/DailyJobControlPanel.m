//
//  DailyJobControlPanel.m
//  zzzf
//
//  Created by dist on 13-12-11.
//  Copyright (c) 2013年 dist. All rights reserved.
//
//
//新巡查界面
//


#import "DailyJobControlPanel.h"
#import "Global.h"
#import "Tools.h"
#import "FormAndMaterialCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WMTSLayer.h"
#import "DataPostman.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "BaseMessageCell.h"
#import "MBProgressHUD+MJ.h"
#import "AFNetworking.h"
#import "Global.h"
#import "UIImage+SimpleImage.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "TypeList.h"

@interface DailyJobControlPanel ()<ASIHTTPRequestDelegate,UITextViewDelegate,TypeListDelegate>
/*{
 "rn": "1",
 "xmbh": "201300969",
 "slbh": "PH20160028",
 "projectName": "巴城红杨幼儿园/配电门卫/地下泵房水池",
 "address": "巴城镇城北路西侧",
 "xzqy": "市局",
 "theoryEndTime": "2016/11/30 12:59:28",
 "company": "昆山市巴城镇城镇建设投资有限公司",
 "contactName": "龚婷婷",
 "contactPhone": "57650807",
 "hjjs": "在办",
 "wfptid": "f6d01896a86e44c496b86818b49eb29c",
 "currentUser": " 邹小峰",
 "currentOffice": " 监察大队",
 "smzt": "正常",
 "business": "批后过程管理",
 "time": "",
 "projectId": "87668",
 "totalProjectName": "巴城红杨幼儿园/配电门卫/地下泵房水池",
 "zfzt": "正常"
 },*/
//保存项目基本信息
@property (nonatomic,strong)NSMutableDictionary *theprojectInfo;
//保存已经生成的巡查记录内容
@property (nonatomic,strong)NSDictionary *logDetail;



/*{
 "success": "true",
 "result": [
 {
 "group": "材料清单",
 "count": "1",
 "groupid": "27889",
 "level": "0",
 "type": "directory",
 "fileExtension": "",
 "files": [
 {
 "group": "公共材料",
 "count": "0",
 "groupid": "187613",
 "level": "1",
 "type": "directory",
 "fileExtension": "",
 "files": []
 }
 ]
 }
 ]
 }
 */
//保存项目材料
@property (nonatomic,strong)NSMutableArray *theProjectMaterialA;

//目录templateId
@property (nonatomic,strong)NSString *templateId;

//新建的目录名
@property (nonatomic,strong)NSString *templateInstName;
//用于记录材料与巡查记录的关联
@property (nonatomic,strong)NSString *guid;

//编辑巡查 新建的巡材料目录
@property (nonatomic,assign)BOOL isreviseMaterialContent;

//设置modal模型
@property(nonatomic,assign)UIModalPresentationStyle modalPresentationStyle;

//目录id
@property (nonatomic,strong) NSString *materialInstanceId;
//= [_theProjectMaterialA[0] objectForKey:@"groupid"];
@property (nonatomic,strong)NSArray *supPersonArry;
@property (nonatomic,assign)BOOL isLoadPerson;
//定位
@property (nonatomic,assign)BOOL isLocation;
@property (nonatomic,assign)BOOL isxmLocation;


@property (nonatomic,assign)GPSLocationMode gpsLocationMode;

//经度
@property (nonatomic,strong)NSString *longitude;
//纬度
@property (nonatomic,strong)NSString *latitude;

@property (weak, nonatomic) IBOutlet UIButton *gpsBtn;

@property (strong,nonatomic) AGSPoint * agsPoint;
@property (strong,nonatomic) UIImageView * imageView;

@end
@implementation DailyJobControlPanel

static int PHOTOGAP=22;
static NSString *DATA_SYN_IDENTITY_UPDATE_DAILYJOB_PAUSE=@"DATA_SYN_IDENTITY_UPDATE_DAILYJOB_PAUSE_%@";
static NSString *DATA_SYN_IDENTITY_UPDATE_DAILYJOB_RESUME=@"DATA_SYN_IDENTITY_UPDATE_DAILYJOB_RESUME_%@";
-(NSArray *)supPersonArry
{
    if (_supPersonArry==nil) {
        _supPersonArry = [NSArray array];
    }
    return _supPersonArry;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

+(DailyJobControlPanel *)createView{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"DailyJobControlPanel" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

-(void)initialzePanel{
    if (_panelInitialized) {
        return;
    }
    _panelInitialized = YES;
    _isLoadPerson = NO;
    [self loadData];
    _baseTabelView.delegate =self;
    _baseTabelView.dataSource = self;
    _baseTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _ConStructcdTextView.delegate =  self;
    _ConStructcdTextView.text = @"请输入建设情况...";
    _ConStructcdTextView.textColor = [UIColor blackColor];
    if ([_ConStructcdTextView.text isEqualToString:@"请输入建设情况..."]) {
        _ConStructcdTextView.textColor = [UIColor lightGrayColor];
    }
    
    _ConStructcdTextView.returnKeyType = UIReturnKeyDone;
    _LogTitleTextView.delegate = self;

    _LogTitleTextView.returnKeyType = UIReturnKeyDone;
    //    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"StopWorkFormView" owner:nil options:nil];
    //    _stopworkFormView = [nibView objectAtIndex:0];
    //    _stopworkFormView.hidden = YES;
    //    _stopworkFormView.delegate = self;
    //    [self addSubview:_stopworkFormView];
    //    _stopworkFormView.editable = YES;
    //    [_stopworkFormView initializeView];
    //
    _reportView = [[DailyJobReport alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _reportView.delegate = self;
    _reportView.hidden = YES;
    [self addSubview:_reportView];
    
    
    //    self.stopworkListGroupContainer.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1].CGColor;
    //    self.stopworkListGroupContainer.layer.cornerRadius = 5;
    //    self.stopworkListGroupContainer.layer.borderWidth = 1;
    //
    //    self.correctiveListGroupContainer.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1].CGColor;
    //    self.correctiveListGroupContainer.layer.cornerRadius = 5;
    //    self.correctiveListGroupContainer.layer.borderWidth = 1;
    //设置tablView的边框
    [self addBoardWith:self.baseTabelView];
    
    //设置填写信息边框
    [self addBoardWith:self.addxcInformBV];
    //设置 输入框边框
    [self addBoardWith:self.ConStructcdTextView];
    
    
    [self setBtnBorder:self.btnJobReport];
    [self setBtnBorder:self.btnPause];
    [self setBtnBorder:self.btnLocation];
    [self setBtnBorder:self.btnCompleted];
    [self setBtnBorder:self.btnClose];
    [self setBtnBorder:self.addPersonBtn];
    
    [self.mapView.layer setBorderColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1].CGColor];
    [self.mapView.layer setBorderWidth:1.0f];
    self.mapView.touchDelegate = self;
    [self registerAsObserver];
    [self.gpsBtn setImage:[UIImage imageNamed:@"gps_normal"] forState:UIControlStateNormal];
    _gpsLocationMode = 0;
    
    //初始化i 查询
    self.visibleLayersDict = [NSMutableDictionary dictionary];
    
    _stopworkFormView.frame=CGRectMake(0 , 0,self.frame.size.width, self.frame.size.height);
    
    _gpsLoader = [[GPS alloc] init];
    //    _gpsLoader.mapView = self.mapView;
    _gpsLoader.delegate = self;
    
    //当前位置view
    _currentLocationView = [[CurrentLocationView alloc] initWithFrame:CGRectMake(200, 200, 60, 60)];
    [self.mapView addSubview:_currentLocationView];
    _currentLocationView.hidden = YES;
    
    // 键盘唤起和隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}


-(void) addBoardWith:(UIView *)object
{
    object.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1].CGColor;
    object.layer.cornerRadius = 5;
    object.layer.borderWidth = 1;
    
    object.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1].CGColor;
    object.layer.cornerRadius = 5;
    object.layer.borderWidth = 1;
    
}


#pragma mark - UITextView Delegate Methods
//点击键盘右下角的键收起键盘
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (_ConStructcdTextView.text.length == 0) {
            _ConStructcdTextView.textColor =[UIColor lightGrayColor];
            _ConStructcdTextView.text = @"请输入建设情况...";
        }
        //        else
        //        {
        //            _ConStructcdTextView.textColor = [UIColor blackColor];
        //            _tempConstructString = _ConStructcdTextView.text;
        //
        //        }
        [textView resignFirstResponder];
        
    }
    return YES;
}

// 键盘升起/隐藏
-(void)keyboardWillShow:(NSNotification *)noti
{
    // 获取键盘弹出的动画时间
    CGFloat durtion = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGSize keyboardSize = [noti.userInfo[@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue].size ;
    CGFloat keyboard_h = keyboardSize.height;
    //NSLog(@"1=====%f",keyboard_h);
    if (MainR.size.height<1024) {
        
        [UIView animateWithDuration:durtion animations:^{
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
            CGRect tableFrame = self.frame;
            if (MainR.size.width == 1024 ) {
                tableFrame.origin.y = -keyboard_h*1/2 ;
            }
            else if (MainR.size.height == 480) {
                tableFrame.origin.y = -keyboard_h*2/3;
            }else
            {
                tableFrame.origin.y = -keyboard_h*2/3;
            }
            
            self.frame = tableFrame;
            // _baseTableView.contentOffset = CGPointMake(0, keyboard_h);
        }];
    }
}
-(void)keyboardWillHide:(NSNotification *)noti
{
    // 获取键盘弹出的动画时间
    CGFloat durtion = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGSize keyboardSize = [noti.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size ;
    CGFloat keyboard_h = keyboardSize.height;
    // NSLog(@"2=====%f",keyboard_h);
    [UIView animateWithDuration:durtion animations:^{
        CGRect tableFrame = self.frame;
        tableFrame.origin.y = 51;
        self.frame = tableFrame;
        
        //_baseTableView.contentOffset = CGPointMake(0, keyboard_h);
    }];
}

//开始编辑意见框,键盘遮挡问题
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    if ([textView.text isEqualToString:@"请输入建设情况..."]) {
        _ConStructcdTextView.text = @"";
        _ConStructcdTextView.textColor = [UIColor blackColor];
    }
    
    //    if (_tempConstructString.length !=0) {
    //        _ConStructcdTextView.text = _tempConstructString;
    //    }
    //    else
    //    {
    //        _ConStructcdTextView.text=@"";
    //    }
    // _adviseTF.textColor =[UIColor blackColor];
    //    self.bgScrollView.contentOffset = CGPointMake(0, 50);
    //    if (MainR.size.height ==480) {
    //        self.bgScrollView.contentOffset = CGPointMake(0, 100);
    //    }
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [_ConStructcdTextView resignFirstResponder];
    [_LogTitleTextView resignFirstResponder];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    // [_textView resignFirstResponder];
    return YES;
}

-(void)loadData
{
    //加载随行人员
    [self loadcontact];
    NSMutableDictionary *jobInfo = [[Global currentUser] dailyJobCurrentInfo];
    NSMutableDictionary *theProjectInfo =[jobInfo objectForKey:@"theProjectInfo"];
    NSArray *arr =[theProjectInfo allKeys];
    if(!(arr.count==0))
    {
        //材料
        _theprojectInfo= [jobInfo objectForKey:@"theProjectInfo"];
        if(_isRevice)//修改巡查内容
        {
            _LogTitleTextView.text = [_logDetail objectForKey:@"xmmc"];
            _isfinishCreated = YES;
            [defaults setBool:YES forKey:@"isfinishCreated"];
            [defaults synchronize];

        }
        else
        {
        
            _LogTitleTextView.text = [_theprojectInfo objectForKey:@"totalProjectName"];

            _isfinishCreated = [defaults boolForKey:@"isfinishCreated"];

        }
        //项目
        _theProjectMaterialA=[jobInfo objectForKey:@"theMatrialInfo"];
        _templateId = [defaults objectForKey:@"groupid"];
        if (!_theProjectMaterialA.count==0) {
            _materialInstanceId= [_theProjectMaterialA[0] objectForKey:@"groupid"];
        }
        
        _templateInstName = [jobInfo objectForKey:@"times"][0];
        //延迟执行
        [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(loadmaterialdelay) userInfo:nil repeats:NO];
        
    }
    NSArray *arr1=[NSArray array];
    NSArray *arr3 =[NSArray array];
    arr1 =@[@"项目编号",@"案卷编号",@"项目名称",@"建设地址"];
    arr3= @[@"建设单位",@"联系人",@"联系电话"];
    NSArray *arr2 = @[@"1",@"2",@"3",@"4",@"5"];
    
    _infoArray = @[arr1,arr3];
    _markArray = [NSMutableArray array];
    
    for (int i=0; i<3; i++) {
        NSString *mark = @"1";
        [_markArray addObject:mark];
    }
    //分组图标
    _groupImgArray = [NSMutableArray arrayWithObjects:@"zhankai@2x.png",@"zhankai@2x.png",@"zhankai@2x.png", nil];
    _detailArray_in = [NSMutableArray array];
    _detailArray_out = [NSMutableArray array];
    
    if(_theprojectInfo)
    {
        
        [_detailArray_in addObject:[_theprojectInfo objectForKey:@"company"]];
        [_detailArray_in addObject:[_theprojectInfo objectForKey:@"contactName"]];
        [_detailArray_in addObject:[_theprojectInfo objectForKey:@"contactPhone"]];
        
        [_detailArray_out addObject:[_theprojectInfo objectForKey:@"xmbh"]];
        [_detailArray_out addObject:[_theprojectInfo objectForKey:@"slbh"]];
        [_detailArray_out addObject:[_theprojectInfo objectForKey:@"projectName"]];
        [_detailArray_out addObject:[_theprojectInfo objectForKey:@"address"]];
        
    }
}



- (void)loadcontact
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    
    NSDictionary *parameters;
    parameters = @{@"type":@"smartplan",@"action":@"allusers"};
    
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    
    NSLog(@"Contact%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [MBProgressHUD hideHUDForView:self animated:YES];
         NSDictionary *rs = (NSDictionary *)responseObject;
         if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
             NSArray *td= [rs objectForKey:@"result"];
             
             for (NSDictionary *dict in td) {
                 if ([[dict objectForKey:@"activityID"]isEqualToString:@"131"]) {
                     self.supPersonArry = [dict objectForKey:@"users"];
                     _isLoadPerson = YES;
                 }
             }
         }else{
             
             _isLoadPerson = NO;
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         _isLoadPerson = NO;
     }];
    
}
- (void)loadmaterialdelay
{
    if (!_isfinishCreated) {
        [self loadMaterila];
    }
    
    
}


-(void)setBtnBorder:(UIButton *)btn{
    btn.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1].CGColor;
    btn.layer.cornerRadius = 5;
    btn.layer.borderWidth = 1;
}

-(void)removePhotoViews{
    NSArray *photoViews = [self.thumbPhotoContainer subviews];
    for (int i=photoViews.count-1; i>=0; i--) {
        [[photoViews objectAtIndex:i] removeFromSuperview];
    }
}

-(void)clearPhotos{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *photos = [_jobInfo objectForKey:@"photos"];
    for (int j=0; j<photos.count; j++ ){
        NSString *photoPath = [[photos objectAtIndex:j] objectForKey:@"path"];
        [fm removeItemAtPath:photoPath error:nil];
    }
    NSString *photoSavePath = [[[Global currentUser] userDailyJobPath] stringByAppendingString:@"/photos"];
    NSArray *photoFiles = [fm contentsOfDirectoryAtPath:photoSavePath error:nil];
    for (int i=0;i<photoFiles.count; i++) {
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@",photoSavePath,[photoFiles objectAtIndex:i]] error:nil];
    }
    [self removePhotoViews];
    
    //[_jobInfo setObject:[[NSMutableDictionary alloc] initWithCapacity:3] forKey:@"photos"];
    //_photos = [[NSMutableDictionary alloc] initWithCapacity:3];
    //[_photos writeToFile:_photoplistPath atomically:YES];
    //[[Global currentUser] saveCurrentDailyJobToDisk];
}


//-(void)startNewDailyJob
//{
//    _noDataView.hidden = YES;
//    _jobInfo = [[Global currentUser] dailyJobCurrentInfo];
//    NSDate *now  = [NSDate date];
//    [[_jobInfo objectForKey:@"times"] addObject:now];
//    [_jobInfo setObject:@"started" forKey:@"status"];
//
//    //NSString *jobId = [NSString stringWithFormat:@"DATA_DAILYJOB_NEW_%@",[Global newUuid]];
//    [_jobInfo setObject:[Global newUuid] forKey:@"jobid"];
//
//    //把当前巡查数据保存到本地(同步本地数据)
//
//    [[Global currentUser] saveCurrentDailyJobToDisk];
//
//    [self refersh];
//    //请求GPS定位
//    [self createGpsTimer];
//}



///////////////////////////////

//传表单基本信息等
-(void)startNewxcWithInformDict:(NSMutableDictionary *)dict andMatrial:(NSMutableArray *)materialA
{
    _theprojectInfo =dict;
    _theProjectMaterialA = materialA;
    [self loadData];
    if(_isRevice)//修改巡查
    {
        _LogTitleTextView.text = [_logDetail objectForKey:@"xmmc"];
        NSString *qk =[_logDetail objectForKey:@"jsqk"];
        if(qk.length>0)
        {
            _ConStructcdTextView.text = [_logDetail objectForKey:@"jsqk"];
            [_ConStructcdTextView setTextColor:[UIColor blackColor]];
        
        }
        NSString  *ry = [_logDetail objectForKey:@"jcry"];
        _personLabel.text =[ry stringByReplacingOccurrencesOfString:@"," withString:@" "];

    }
    else
    {
        _LogTitleTextView.text = [_theprojectInfo objectForKey:@"totalProjectName"];

    }
    
    [self.baseTabelView reloadData];
    //创建材料目录
    if(!(_theProjectMaterialA.count >0)||_theProjectMaterialA == nil)
    {
        [self loadMaterila];
    }
    else
    {
        if(_isRevice)//修改巡查
        {
            //获取上传材料的目录
            [self loadMaterila];

        }
        else
        {
            //添加材料目录
        [self addMatrialCatalogue];
        }
    }
    
    
    NSLog(@"%@",dict);
    
    
}


- (void)loadMaterila
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"type"] = @"smartplan";
    parameters[@"action"]=@"materials";
    parameters[@"slbh"]=[_theprojectInfo objectForKey:@"slbh"];
    
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    NSLog(@"请求材料%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            [MBProgressHUD showSuccess:@"材料请求成功" toView:self];
            NSArray *arr =[rs objectForKey:@"result"];
            [_jobInfo setObject:arr forKey:@"theMatrialInfo"];
            if(!_theProjectMaterialA.count == 0)
            {
                _materialInstanceId= [_theProjectMaterialA[0] objectForKey:@"groupid"];
            }
            else
            {
                _materialInstanceId= [arr[0] objectForKey:@"groupid"];
                
                
            }
            [[Global currentUser] saveCurrentDailyJobToDisk];
            
            if(_isRevice)//修改巡查
            {
                int i=0;
                //目录templateId
                for (NSDictionary *dict in [arr[0] objectForKey:@"files"]) {
                    //材料名称
                    NSString *materialName =[NSString stringWithFormat:@"%@ %@",_templateInstName,[_logDetail objectForKey:@"xmmc"]];
                    if(  [[dict objectForKey:@"group"]isEqualToString:materialName]||[[dict objectForKey:@"group"]isEqualToString:_templateInstName]||[[dict objectForKey:@"guid"] isEqualToString:_guid])
                    {
                        _templateId = [dict objectForKey:@"groupid"];
                        _guid = [dict objectForKey:@"guid"];
                        [defaults setObject:self.templateId forKey:@"groupid"];
                        [defaults setObject:self.guid forKey:@"guid"];
                        [defaults synchronize];
                        _isreviseMaterialContent = YES;
                        
                    }

//                    else //没找到对应的材料 ,则需要创建材料目录
//                    {
//                        i++;
//                        if (i==[arr[0] count]) {
//                            
//                            //创建材料目录
//                            [self addMatrialCatalogue];
//                        }
//                       
//                    
//                    }
//                    
                }
                //如果还是没有
                if (_isreviseMaterialContent==NO) {
                    //创建材料目录
                    [self addMatrialCatalogue];
                }
            
            }
            else
            {
                //目录templateId
                for (NSDictionary *dict in [arr[0] objectForKey:@"files"]) {
                    if(  [[dict objectForKey:@"group"]isEqualToString:_templateInstName])
                    {
                        _templateId = [dict objectForKey:@"groupid"];
                        _guid = [dict objectForKey:@"guid"];
                        [defaults setObject:self.templateId forKey:@"groupid"];
                        [defaults setObject:self.guid forKey:@"guid"];
                        [defaults synchronize];
                        if(!_isfinishCreated)
                        {
                            [self addMatrialCatalogue];
                            
                        }

                        
                    }
                    
                }
            
            }
           
          
            _theProjectMaterialA = [NSMutableArray arrayWithArray:arr];
                    }
        else
        {
            [MBProgressHUD showError:@"材料请求失败" toView:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"材料请求失败" toView:self];
    }];
    
}
//新建材料目录
- (void) addMatrialCatalogue
{
    //添加材料目录
    //    mmid 清单实例id pid项目id templateInstName 目录名
    //    parentId 父级目录id
    ///KSYDService/ServiceProvider.ashx?type=smartplan&action=addmaterialtemplateinstance&miid=&pid=&templateInstName=&parentId=
    
    //    [MBProgressHUD showMessage:@"加载详细信息" toView:self.view];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"type"] = @"smartplan";
    parameters[@"action"]=@"addmaterialtemplateinstance";
    
    parameters[@"miid"]=[_theProjectMaterialA[0] objectForKey:@"groupid"];
    parameters[@"pid"]=[_theprojectInfo objectForKey:@"projectId"];
    //目录名称
    parameters[@"templateInstName"]=_templateInstName;
    parameters[@"parentId"]=@"0";
    
    
    
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    NSLog(@"新建材料目录%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            [MBProgressHUD showSuccess:@"材料目录创建成功" toView:self];
            _isreviseMaterialContent = NO;
            _isfinishCreated = YES;
            [defaults setBool:YES forKey:@"isfinishCreated"];
            [defaults synchronize];
            [self loadMaterila];
        }
        else
        {
            [MBProgressHUD showError:@"材料目录创建失败" toView:self];
            _isfinishCreated = NO;
            _isreviseMaterialContent=YES;
            [defaults setBool:NO forKey:@"isfinishCreated"];
            [defaults synchronize];
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"创建材料目录请求失败" toView:self];
        _isfinishCreated = NO;
        
    }];
    
    
}



- (void)startNewDailyJobwithProjectInfo:(NSMutableDictionary *)dict andMatrial:(NSMutableArray *)materialA{
    _jobInfo = [[Global currentUser] dailyJobCurrentInfo];

//    @"2017/3/16 10:47:41"
    NSMutableDictionary *projectdict  = [dict objectForKey:@"projectDict"];
    NSDictionary *logDetail = [dict objectForKey:@"selectedDict"];
    _logDetail = [NSDictionary dictionaryWithDictionary:logDetail];

    if (_isRevice)
    {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        NSDate *date =[formatter dateFromString:[logDetail objectForKey:@"jcsj"]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dayStr=[formatter stringFromDate:date];
        [[_jobInfo objectForKey:@"times"] addObject:dayStr];
            _templateInstName = dayStr;
        _guid = [_logDetail objectForKey:@"guid"];

    }else
    {
        NSDate *now  = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dayStr=[formatter stringFromDate:now];
        _templateInstName = dayStr;
        [[_jobInfo objectForKey:@"times"] addObject:dayStr];
    }
    //先请求数据  创建目录
    [self startNewxcWithInformDict:projectdict andMatrial:materialA];
    if (!_theProjectMaterialA.count==0) {
        
        _materialInstanceId= [_theProjectMaterialA[0] objectForKey:@"groupid"];
    }
    _noDataView.hidden = YES;
    
//    [[_jobInfo objectForKey:@"times"] addObject:dayStr];
    
    [_jobInfo setObject:@"started" forKey:@"status"];
    //    [_jobInfo setValue:dict forKey:@"theProjectInfo"];
    //材料
    [_jobInfo setObject:dict forKey:@"theProjectInfo"];
    //项目
    [_jobInfo setObject:materialA forKey:@"theMatrialInfo"];
    //    [_jobInfo setValue:materialA forKey:@"theMatrialInfo"];
    
    //把当前巡查数据保存到本地(同步本地数据)
    
    [[Global currentUser] saveCurrentDailyJobToDisk];
    
    [self refersh];
    //请求GPS定位
    //    [self createGpsTimer];
}

-(void)createGpsTimer{
    _firstLocation = YES;
    if (nil==_gpsTimer) {
        _gpsLoader = [[GPS alloc] init];
        //        _gpsLoader.mapView = self.mapView;
        _gpsLoader.delegate = self;
        [_gpsLoader startGPS];
        _gpsTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(requestGPS) userInfo:nil repeats:YES];
    }else{
        [_gpsTimer fire];
    }
}

-(void)clearGpsTimer{
    if (nil!=_gpsTimer) {
        [_gpsTimer invalidate];
        _gpsTimer = nil;
    }
}

//刷新当前巡查信息
-(void)refersh{
    //如果未开始巡查(读本地)
    if ([[[[Global currentUser] dailyJobCurrentInfo] objectForKey:@"status"] isEqualToString:@"stoped"])
    {
        if (nil==_noDataView) {
            _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(460, 300, 180, 40)];
            [noDataLabel setFont:[noDataLabel.font fontWithSize:16]];
            noDataLabel.text = @"当前没有正在活动的巡查";
            
            [_noDataView addSubview:noDataLabel];
            _noDataView.backgroundColor = [UIColor whiteColor];
            [self clearGpsTimer];
            [self addSubview:_noDataView];
            
        }
        _noDataView.hidden = NO;
        _jobInfo = nil;
        [self updateReportButton];
        [self.stopWorkFormTableView reloadData];
        [self.correctiveTableView reloadData];
        [self clearPhotos];
        
    }
    else
    {
        //更新
        _readonly = NO;
        [self doRefersh:[[Global currentUser] dailyJobCurrentInfo]];
    }
}

//如果
//本地状态为start
-(void)doRefersh:(NSMutableDictionary *)data{
    _jobInfo = data;
    _stopworkFormView.jobId = [data objectForKey:@"jobid"];
    if (_readonly) {
        self.pauseView.hidden = YES;
        if (nil!=_noDataView) {
            _noDataView.hidden = YES;
        }
        self.btnClose.hidden = NO;
        [self clearGpsTimer];
    }
    else{
        if ([[_jobInfo objectForKey:@"status"] isEqualToString:@"paused"])
        {//暂停
            self.pauseView.hidden = NO;
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"MM/dd HH:mm:ss"];
            NSMutableArray *theTimes = [_jobInfo objectForKey:@"times"];
            self.lblPauseInfo.text = [NSString stringWithFormat:@"巡查已暂停：%@",[formatter stringFromDate:[theTimes objectAtIndex:theTimes.count-1]]];
        }
        else
        {//
            self.pauseView.hidden = YES;
            
            
//            [self createGpsTimer];
        }
        self.btnClose.hidden = YES;
    }
    //更新巡查报告按钮
    //    [self updateReportButton];
    
    
    _mayCompleted = NO;
    //设置基本信息
    //    self.lblOrg.text = [Global currentUser].org;
    //    self.lblUsername.text = [Global currentUser].username;
    //    self.lblPDA.text = [data objectForKey:@"device"];
    //self.thumbPhotoContainer.pagingEnabled = YES;
    self.thumbPhotoContainer.showsVerticalScrollIndicator = YES;
    self.thumbPhotoContainer.bounces = YES;
    
    _dailyJobPath = [[Global currentUser] userDailyJobPath];
    _photoSaveDirecotry = [_dailyJobPath stringByAppendingString:@"/photos"];
    BOOL isDir;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:_photoSaveDirecotry isDirectory:&isDir]) {
        [fm createDirectoryAtPath:_photoSaveDirecotry withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [self createThumbPhotos];
    [self updatePhotoButtons];
    //    [self.stopWorkFormTableView reloadData];
    //    [self.correctiveTableView reloadData];
    
    //    self.mapView.gridLineWidth = 0;
    //    self.mapView.backgroundColor = [UIColor whiteColor];
    
    self.btnPause.hidden = _readonly;
    self.btnLocation.hidden= _readonly;
    self.btnCompleted.hidden = _readonly;
    self.btnGetPhoto.hidden = _readonly;
    self.btnDeletePhoto.hidden = self.btnRenamePhoto.hidden = _readonly;
    self.btnNewStopworkForm.hidden = _readonly;
    
    _stopworkFormView.editable = !_readonly;
    _reportView.editable = !_readonly;
    
    [self initMapView];
}

-(void)initMapView{
    [LayerManager loadBaseMap:self.mapView];
    [LayerManager setBaseMap:self.mapView mapType:0];
    
    //加载动态服务,需要使用的服务
    NSArray *serviceLayers = @[KSKG0,KSKG1,KSXZHX,KSYDHX];
    for (NSString *url in serviceLayers) {
        [LayerManager loadDynamicMap:self.mapView withUrl:url];
    }
    
    AGSEnvelope *defaultEnvelope=[[AGSEnvelope alloc] initWithXmin:DEFAULT_X_MIN ymin:DEFAULT_Y_MIN xmax:DEFAULT_X_MAX ymax:DEFAULT_Y_MAX spatialReference:self.mapView.spatialReference];
    self.mapView.layerDelegate = self;
    [self.mapView zoomToEnvelope:defaultEnvelope animated:YES];
}



-(void)mapViewDidLoad:(AGSMapView *)mapView{
    if (!self.mapView.locationDisplay.dataSourceStarted) {
        [self.mapView.locationDisplay startDataSource];
        self.mapView.locationDisplay.alpha = 0.0;
    }
    
    self.indentifyGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.indentifyGraphicsLayer withName:@"IndentifyGraphicsLayer"];
    
    self.gpsGraphicLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.gpsGraphicLayer withName:@"GPSGraphicLayer"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:) name:@"AGSMapViewDidEndZoomingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:) name:@"AGSMapViewDidEndPanningNotification" object:nil];
}

-(void)creatProjectLocation:(NSString *)mapPointXY{
    [self clearGraphic];
    
    NSArray * pointXY = [mapPointXY componentsSeparatedByString:@","];
    double pointX = [[pointXY objectAtIndex:0]doubleValue];
    double pointY = [[pointXY objectAtIndex:1]doubleValue];
    AGSPoint *point = [[AGSPoint alloc]initWithX:pointX  y:pointY spatialReference:self.mapView.spatialReference];
    _agsPoint = point;
    CGPoint screenPoint = [self.mapView toScreenPoint:point];
    
    _imageView = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:@"location.png"]];
    CGRect endFrame = CGRectMake(screenPoint.x-18, screenPoint.y-18, 36, 36);
    _imageView.frame = CGRectMake(endFrame.origin.x, endFrame.origin.y-20, 36, 36);
    _imageView.alpha = 0;
    [self.mapView addSubview:_imageView];
    
    [UIView animateWithDuration:1 animations:^{
        [_imageView setFrame:endFrame];
        _imageView.alpha = 1;
    }
                     completion:^(BOOL finished){
                         if (finished){
                         }
                     }];
}

//手势操作执行代码
- (void)respondToEnvChange: (NSNotification*) notification {
    
    /*之前定图标代码
     if (nil!=_currentLocation) {
     [self updateCurrentLoactionView];
     }
     */
    
    //修改后代码
    if(_imageView!=nil && !_imageView.hidden){
        //用给定的图片来
        AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"location.png"];
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:_agsPoint symbol:graphicSymbol attributes:nil];
        [self.gpsGraphicLayer addGraphic:graphic];
        _imageView.hidden = YES;
    }
}

-(NSString*)getProjectLocation{
    NSString *pointXY;
    if (_agsPoint!=nil) {
        pointXY = [NSString stringWithFormat:@"%f,%f",_agsPoint.x,_agsPoint.y];
    }
    return pointXY;
}

-(void)clearGraphic{
    [self.gpsGraphicLayer removeAllGraphics];
    [_imageView removeFromSuperview];
}




//从外部加载作用（不可编辑）
-(void)loadJob:(NSMutableDictionary *)data{
    _readonly = YES;
    [self doRefersh:data];
}

-(void)updateReportButton{
    NSMutableDictionary *theReport = [_jobInfo objectForKey:@"report"];
    if (theReport.count==0) {
        [self.btnJobReport setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.btnJobReport setTitle:@"巡查报告（无）" forState:UIControlStateNormal];
        self.btnJobReport.enabled = !_readonly;
        
    }else{
        [self.btnJobReport setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
        [self.btnJobReport setTitle:@"巡查报告" forState:UIControlStateNormal];
        self.btnJobReport.enabled = YES;
    }
    
}

-(void)updatePhotoButtons{
    NSMutableArray *photos = [_jobInfo objectForKey:@"photos"];
    int c=0;
    _mayUploadPhotos = [NSMutableArray arrayWithCapacity:10];
    for(int i=0;i<photos.count;i++){
        NSMutableDictionary *photoInfo = [photos objectAtIndex:i];
        if ([[photoInfo objectForKey:@"uploaded"] isEqualToString:@"no"]) {
            c++;
            [_mayUploadPhotos addObject:photoInfo];
        }
    }
    self.btnDeletePhoto.enabled = self.btnRenamePhoto.enabled = photos.count>0;
    self.btnAsyPhoto.enabled = c>0;
    if (c==0) {
        [self.btnAsyPhoto setTitle:@"同步照片" forState:UIControlStateNormal];
    }else{
        [self.btnAsyPhoto setTitle:[NSString stringWithFormat:@"同步照片(%d)",c] forState:UIControlStateNormal];
    }
    
}

-(void)createThumbPhotos{
    //NSFileManager *fm = [NSFileManager defaultManager];
    //NSArray *photos = [fm contentsOfDirectoryAtPath:_photoSaveDirecotry error:nil];
    
    [self removePhotoViews];
    
    NSMutableArray *photos = [_jobInfo objectForKey:@"photos"];
    
    int rows = photos.count/4;
    int columns = 4;
    if (photos.count%4!=0) {
        rows++;
    }
    
    int tag = 0;
    for (int i=0; i<rows; i++) {
        for (int j=0; j<columns && tag<photos.count; j++ ){
            NSMutableDictionary *photoInfo = [photos objectAtIndex:tag];
            NSString *photoName = [photoInfo objectForKey:@"name"];
            JobPhotoView *imgView = [[JobPhotoView alloc] initWithFrame:CGRectMake(PHOTOGAP+(j*112),PHOTOGAP+(i*95),102, 76)];
            imgView.tag = tag;
            
            imgView.uploaded = [[photoInfo objectForKey:@"uploaded"] isEqualToString:@"yes"];
            imgView.photoPath = [photoInfo objectForKey:@"path"];
            imgView.photoName = photoName;
            imgView.photoCode = [photoInfo objectForKey:@"code"];
            imgView.delegate = self;
            [self.thumbPhotoContainer addSubview:imgView];
            if (tag==0) {
                imgView.selected = YES;
                _currentSelectedPhoto = imgView;
            }
            tag ++;
        }
    }
    if (photos.count>0) {
        self.lblNoImg.hidden = YES;
        self.btnDeletePhoto.enabled = self.btnRenamePhoto.enabled = YES;
    }
    imgTag = photos.count;
    self.thumbPhotoContainer.contentSize = CGSizeMake(370, rows * 95 +PHOTOGAP);
    self.thumbPhotoContainer.contentOffset = CGPointMake(0, 0);
}

- (IBAction)yxTrueClick:(id)sender {
    //    UIButton *btn=(UIButton *)sender;
    self.yxTrue.selected=!self.yxTrue.selected;
    self.yxFalse.selected =!self.yxTrue.selected;
    
    
    
}

- (IBAction)ysFalseClick:(id)sender {
    self.yxFalse.selected =!self.yxFalse.selected;
    self.yxTrue.selected=!self.yxFalse.selected;
    
    
    
}

- (IBAction)GczTrueClick:(id)sender {
    self.gczTrue.selected = !self.gczTrue.selected;
    self.gczFalse.selected = !self.gczTrue.selected;
}

- (IBAction)GczFalseClick:(id)sender {
    self.gczFalse.selected = !self.gczFalse.selected;
    self.gczTrue.selected = !self.gczFalse.selected;
    
    
}

//点击开始拍照
-(IBAction)onBtnPhotographTap:(id)sender{
    UIAlertView *photoAlertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请选择从相册选取图片或者打开拍照功能" delegate:self cancelButtonTitle:@"从相册选取" otherButtonTitles:@"开始拍照", nil];
    photoAlertView.tag=10;
    [photoAlertView show];
}
-(void)photoalbum
{
    _picker=[[UIImagePickerController alloc]init];
    _picker = [[UIImagePickerController alloc] init];//初始化
    _picker.delegate =self;
//    _picker.allowsEditing = YES;//设置可编辑
    _picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    UIPopoverController *popoverC=[[UIPopoverController alloc]initWithContentViewController:_picker];
    popoverC.delegate=self;
    poverController=popoverC;
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil) {
        controller = controller.presentedViewController;
    }
    
    [poverController presentPopoverFromRect:CGRectMake(500, 100, 1, 1) inView:controller.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//开始拍照方法
-(void)photograph
{
    //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil) {
        controller = controller.presentedViewController;
    }
    
    //sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //图片库
    //sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; //保存的相片
    _picker = [[UIImagePickerController alloc] init];//初始化
    _picker.delegate = self;
//    _picker.allowsEditing = YES;//设置可编辑
    _picker.sourceType = sourceType;
    [_gpsLoader startGPS];
    [controller presentViewController:_picker animated:YES completion:nil];
    
}

//保存照片到相册失败
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存照片到相册失败--请打开设置--隐私" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    
    
}

//保存照片到相册
-(void)saveImageToAlbum:(UIImage *)img{
    UIImageWriteToSavedPhotosAlbum(img, self,
                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark -imagePickerController代理方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary||picker.sourceType==UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        [poverController dismissPopoverAnimated:YES];
    }
    else if (picker.sourceType==UIImagePickerControllerSourceTypeCamera){
        [_picker dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //相册
    if (picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary||picker.sourceType==UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        [poverController dismissPopoverAnimated:YES];
        _thePhotoFromCamera=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [self savePhoto];
    }
    else if (picker.sourceType==UIImagePickerControllerSourceTypeCamera){
        //照相机
        [_picker dismissViewControllerAnimated:YES completion:nil];
        NSString* mediaType=[info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:(NSString*)kUTTypeImage])
        {
            UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation=image.imageOrientation;
            if(imageOrientation!=UIImageOrientationUp)
            {
                // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
                // 以下为调整图片角度的部分
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                _thePhotoFromCamera = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                // 调整图片角度完毕
            }else{
                _thePhotoFromCamera = image;
            }
        }
        
        [self savePhoto];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(rePhotograph) userInfo:nil repeats:NO];
        //_thePhotoFromCamera = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
}

//再次弹出拍照
-(void)rePhotograph{
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil) {
        controller = controller.presentedViewController;
    }
    [controller presentViewController:_picker animated:YES completion:nil];
    
}


- (IBAction)onBtnRenamePhotoTap:(id)sender{
    
    if(nil==_currentSelectedPhoto){
        return;
    }
    UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"拍照" message:@"请输入照片名称" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"取消", nil];
    
    comfirm.alertViewStyle = UIAlertViewStylePlainTextInput;
    [comfirm textFieldAtIndex:0].placeholder = @"未命名照片";
    [comfirm textFieldAtIndex:0].text = _currentSelectedPhoto.photoName;
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 60);
    [comfirm setTransform:myTransform];
    
    [comfirm show];
    
}

-(void)renamePhoto:(NSString *)newName{
    _newPhotoName = newName;
    if (_currentSelectedPhoto.uploaded) {
        [Global wait:@"请稍候..."];
        ServiceProvider *rnSp = [ServiceProvider initWithDelegate:self];
        rnSp.tag = 3;
        [rnSp getString:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"renamePhoto",@"action",@"1",@"daily", _currentSelectedPhoto.photoCode,@"code",newName,@"name",nil]];
    }else{
        [self modifyLocalPhotoName:newName];
    }
}

-(void)renameOnlinePhotoNameCompleted:(BOOL)successfully{
    if (successfully) {
        [self modifyLocalPhotoName:_newPhotoName];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"修改失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)modifyLocalPhotoName:(NSString *)newName{
    _currentSelectedPhoto.photoName = newName;
    NSMutableArray *photos = [_jobInfo objectForKey:@"photos"];
    for (NSMutableDictionary *photoInfo in photos) {
        NSString *c = [photoInfo objectForKey:@"code"];
        if ([c isEqualToString:_currentSelectedPhoto.photoCode]) {
            [photoInfo setValue:newName forKey:@"name"];
        }
    }
    //同步本地数据
    [[Global currentUser] saveCurrentDailyJobToDisk];
}

//alertView代理方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) {
        if (buttonIndex==0) {
            //点击完成巡查
            [self jobCompleted];
        }
    }else if(alertView.tag==0){
        if (buttonIndex==0) {
            NSString *photoName = [alertView textFieldAtIndex:0].text;
            if (![photoName isEqualToString:@""]) {
                [self renamePhoto:photoName];
            }
        }
    }else if(alertView.tag==2){
        if (buttonIndex==0) {
            [self doRemovePhoto];
        }
    }else if(alertView.tag==3){
        if (buttonIndex==0) {
            [self doPauseJob];
        }
    }else if(alertView.tag==4 && buttonIndex==1){
        [MBProgressHUD hideHUDForView:self];
        [self.delegate dailyJobCompleted];
        _isLocation = NO;
        _isxmLocation = NO;
        [self.btnLocation setTitle:@"保存位置" forState:UIControlStateNormal];
 
        
    }else if (alertView.tag==10){
        if (buttonIndex==0) {
            NSLog(@"打开相册");
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(photoalbum) userInfo:nil repeats:NO];
        }
        if (buttonIndex==1) {
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(photograph) userInfo:nil repeats:NO];
            NSLog(@"拍照");
        }
    }
    else if (alertView.tag ==100)
    {
        [self addMatrialCatalogue];
        [self loadMaterila];
        
    }
    else if (alertView.tag == 5)//完成巡查 提醒定位
    {
        if (buttonIndex==0) {
            //自动打开定位
            [self startCurrentGPS];
            [self changeImageWithGPSMode:_gpsLocationMode];

        }
    }
    //点击保存位置
    else if (alertView.tag == 6)//保存定位
    {
        if (buttonIndex==0) {
            if(_isLocation)
            {

                    //获取图标位置坐标
                    NSString *loaction = [self getProjectLocation];
                    NSArray *arr = [loaction componentsSeparatedByString:@","];
                    if(arr.count >0)
                    {
                        _isxmLocation = YES;
                        _longitude = arr[0];
                        _latitude = arr[1];
                        [self.btnLocation setTitle:@"修改位置" forState:UIControlStateNormal];
                        [MBProgressHUD showSuccess:@"位置保存成功" toView:self];
                        NSLog(@"定位坐标 经纬%@,%@",_longitude,_latitude);

                    }
                    else
                    {
                        _isxmLocation = NO;
//                        [self gpsLocation:self.gpsBtn];
                        [self startCurrentGPS];
                        [self changeImageWithGPSMode:_gpsLocationMode];

                        
                    }
                    
            }
            else
            {
//                    [self gpsLocation:self.gpsBtn];
                [self startCurrentGPS];
                [self changeImageWithGPSMode:_gpsLocationMode];



            }
            
        }
    }
    
}
//完成巡查
-(void)jobCompleted
{
    [self clearGpsTimer];
    
    if (_mayUploadPhotos.count>0) {
        _mayCompleted = YES;
        [MBProgressHUD showMessage:@"正在提交数据..." toView:self];
        [self.delegate showcalader];
        [self ansyPhtots];
    }else{
        [MBProgressHUD hideHUDForView:self];
        [MBProgressHUD hideHUD];
        if(_isRevice)
        {
            //修改材料目录名称
            [self reviseMaterialName];

        
        }else
        {
        
        if(!_isfinishCreated)
        {
            [self addMatrialCatalogue];
        }else
        {
            //修改材料目录名称
            [self reviseMaterialName];
            //添加一条巡查记录
            [self addxcLog];
            
            //            [self.delegate dailyJobCompleted];
        }
        }
    }
    
}

- (void)reviseMaterialName
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"type"] = @"smartplan";
    parameters[@"action"]=@"editmaterialtin";
    parameters[@"id"]=_templateId;
    parameters[@"name"]=[NSString stringWithFormat:@"%@ %@",_templateInstName,_LogTitleTextView.text];
    parameters[@"guid"]=_LogTitleTextView.text;
//    _templateInstName;
    
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    NSLog(@"修改材料名称%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            [MBProgressHUD showSuccess:@"材料目录修改成功" toView:self];
            if(_isRevice)
            {
                [self commitrevise];
                       }
                    }
        else
        {
            [MBProgressHUD showError:@"材料目录修改失败" toView:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"材料目录修改失败" toView:self];
    }];


}
//修改巡查记录内容
- (void)commitrevise
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameters;
    
    [MBProgressHUD showMessage:@"正在加载" toView:self];
    
    //  http://58.246.138.178:8040/KSYDService/ServiceProvider.ashx?&id=-1&x=25734.493123&type=smartplan&y=70950.212281&yx=&action=setphgldata&jcsj=2017-03-06 11:02:43&jsqk=良好&xmmc=豪门世家&gcz=&jcry=邹小峰&pid=89644
    NSString *gczContent = @"";
    NSString *yxContent = @"";
    
    if (_gczTrue.selected == YES) {
        gczContent = @"已取得";
    }else if (_gczFalse.selected == YES)
    {
        gczContent = @"未取得";
    }else
    {
        gczContent = @"";
        
    }
    
    if(_yxTrue.selected == YES)
    {
        yxContent = @"已验线";
    }
    else if(_yxFalse.selected == YES)
    {
        yxContent = @"未验线";
        
    }
    else
    {
        yxContent = @"";
    }
    
    NSString *person = _personLabel.text;
    NSString *personA=@"";
    if([person containsString:[Global currentUser].username])
    {
        personA=[NSString stringWithFormat:@"%@",person];
    }
    else
    {
        if([person isEqualToString:@""]||person==nil)
        {
            personA=[NSString stringWithFormat:@"%@",[Global currentUser].username];
            
        }else
        {
            personA=[NSString stringWithFormat:@"%@,%@",[Global currentUser].username,person];
            
        }
    }
    NSString *textInsert=@"";
    if ([_ConStructcdTextView.text isEqualToString:@"请输入建设情况..."]) {
        textInsert = @"";
    }
    else
    {
        textInsert = _ConStructcdTextView.text;
    }
    
    parameters = @{@"type":@"smartplan",@"action":@"setphgldata",@"jcsj":[_logDetail objectForKey:@"jcsj"],@"id":[_logDetail objectForKey:@"id"],@"jcry":personA,@"xmmc":_LogTitleTextView.text,@"gcz":gczContent,@"yx":yxContent,@"jsqk":textInsert,@"x":_latitude,@"y":_longitude,@"guid":_guid,@"createuser":[Global currentUser].username};

    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    
    NSLog(@"修改巡查记录内容--未验线等%@",requestAddress);
    
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self];
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            
            _personLabel.text = @"";
            [MBProgressHUD hideHUDForView:self];
            [self.delegate dailyJobCompleted];
            _isLocation = NO;
            _isxmLocation = NO;
            [self.btnLocation setTitle:@"保存位置" forState:UIControlStateNormal];

        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self];
        
        
    }];
    
    
}


//添加一条巡查记录
- (void)addxcLog
{
    
    [MBProgressHUD hideHUDForView:self];
    //    /KSYDService/ServiceProvider.ashx?type=smartplan&action=setphgldata&id=-1&pid=87666&xmmc=华润国际社区2号垃圾房11&gcz=true&yx=false&jsqk=建设情况良好&jcry=邹小峰&jcsj=2016-11-30%2012:47:44
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"type"] = @"smartplan";
    parameters[@"action"]=@"setphgldata";
    parameters[@"id"]=@"-1";
    parameters[@"pid"]=[_theprojectInfo objectForKey:@"projectId"];;
    parameters[@"xmmc"]=_LogTitleTextView.text;
    parameters[@"guid"]=_guid;

    if(_gczTrue.selected)
    {
        parameters[@"gcz"]=@"已取得";
    }else
    {
        parameters[@"gcz"]=@"未取得";
    }
    if(_yxTrue.selected)
    {
        parameters[@"yx"]= @"已验线";
        
    }
    else
    {
        parameters[@"yx"]=@"未验线";
    }
    if((_gczTrue.selected==nil&&_gczFalse.selected==nil))
    {
    
    parameters[@"gcz"]=@"";
    }
    if((_yxTrue.selected==nil&&_yxFalse.selected==nil))
    {
        
        parameters[@"yx"]=@"";
    }
    
    NSString *textInsert=@"";
    if ([_ConStructcdTextView.text isEqualToString:@"请输入建设情况..."]) {
        textInsert = @"";
    }
    else
    {
        textInsert = _ConStructcdTextView.text;
    }
    parameters[@"jsqk"]=textInsert;
    NSString *person = _personLabel.text;
    //    [person stringByReplacingOccurrencesOfString:withString:@""];
    if([person containsString:[Global currentUser].username])
    {
        parameters[@"jcry"]=[NSString stringWithFormat:@"%@",person];
    }
    else
    {
        if([person isEqualToString:@""]||person==nil)
        {
            parameters[@"jcry"]=[NSString stringWithFormat:@"%@",[Global currentUser].username];
            
        }else
        {
            parameters[@"jcry"]=[NSString stringWithFormat:@"%@,%@",[Global currentUser].username,person];
            
        }
    }
    
    
    //    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    parameters[@"jcsj"]=_templateInstName;
    parameters[@"x"]=_longitude;
    parameters[@"y"]=_latitude;
    parameters[@"createuser"]=[Global currentUser].username;
    
    //    [df stringFromDate:[NSDate date]];
    
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    NSLog(@"添加一条新记录%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            [MBProgressHUD showSuccess:@"记录添加成功" toView:self];
            NSArray *arr =[rs objectForKey:@"result"];
            _theProjectMaterialA = [NSMutableArray arrayWithArray:arr];
            _personLabel.text = @"";
            [MBProgressHUD hideHUDForView:self];
            [self.delegate dailyJobCompleted];
            _isLocation = NO;
            _isxmLocation = NO;
            [self.btnLocation setTitle:@"保存位置" forState:UIControlStateNormal];

            
        }
        else
        {
            [MBProgressHUD showError:@"记录添加失败" toView:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"记录添加失败" toView:self];
    }];
    
    
    
}

//保存照片
-(void)savePhoto
{
    NSMutableArray *photos = [_jobInfo objectForKey:@"photos"];
    int row = photos.count/5;
    int column = photos.count%5;
    imgTag++;
    JobPhotoView *thumbView = [[JobPhotoView alloc] initWithFrame:CGRectMake(PHOTOGAP+column*112,row*95+PHOTOGAP,102, 76)];
    thumbView.delegate = self;
    self.lblNoImg.hidden = YES;
    
    thumbView.tag = photos.count;
    NSString *photoCode = [Global newUuid];
    NSString *imgSavePath = [_photoSaveDirecotry stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",photoCode]];
    
    [UIImageJPEGRepresentation(_thePhotoFromCamera, 1.0) writeToFile:imgSavePath atomically:YES];
    [self.thumbPhotoContainer addSubview:thumbView];
    
    
    //photo location and time
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss"];
    NSString *photoName = [df stringFromDate:[NSDate date]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableDictionary *photoInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [photoInfo setValue:imgSavePath forKey:@"path"];
    [photoInfo setValue:[df stringFromDate:[NSDate date]] forKey:@"createtime"];
    [photoInfo setValue:[NSString stringWithFormat:@"%f,%f",_location.longitude,_location.latitude] forKey:@"location"];
    [photoInfo setValue:photoName forKey:@"name"];
    [photoInfo setValue:photoCode forKeyPath:@"code"];
    [photoInfo setValue:@"no" forKeyPath:@"uploaded"];
    [photos addObject:photoInfo];
    
    thumbView.photoPath = imgSavePath;
    self.thumbPhotoContainer.contentSize = CGSizeMake(370, (row+1) * 95 +PHOTOGAP);
    int offsetY = self.thumbPhotoContainer.contentSize.height - self.thumbPhotoContainer.frame.size.height;
    if (offsetY<0) {
        offsetY = 0;
    }
    self.thumbPhotoContainer.contentOffset = CGPointMake(0, offsetY);
    
    if (nil!=_currentSelectedPhoto) {
        _currentSelectedPhoto.selected = NO;
    }
    thumbView.photoName = photoName;
    
    thumbView.photoCode = photoCode;
    thumbView.uploaded=NO;
    _currentSelectedPhoto = thumbView;
    thumbView.selected  = YES;
    self.btnDeletePhoto.enabled = self.btnRenamePhoto.enabled = YES;
    [[Global currentUser] saveCurrentDailyJobToDisk];
    [self updatePhotoButtons];
    [self saveImageToAlbum:_thePhotoFromCamera];
}

-(void)reComfirm{
    UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"拍照" message:@"已存在的改名称，请再次输入" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"取消", nil];
    
    comfirm.alertViewStyle = UIAlertViewStylePlainTextInput;
    [comfirm textFieldAtIndex:0].text = _reComfirmPhotoName;
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 60);
    [comfirm setTransform:myTransform];
    [comfirm show];
}

-(void)jobPhotoTap:(JobPhotoView *)photoView{
    if ([_currentSelectedPhoto.photoCode isEqualToString:photoView.photoCode]) {
        return;
    }
    _currentSelectedPhoto.selected = NO;
    _currentSelectedPhoto = photoView;
    photoView.selected = YES;
}

#pragma -mark 调用新加的方法，传一个nsarray
-(void)jobPhotoDoubleTap:(JobPhotoView *)photoView{
    
    //判断是第几个photoView
    NSMutableArray *_allFilesInfo=[NSMutableArray array];
    NSMutableArray *ps = [_jobInfo objectForKey:@"photos"];
    
    for (int i=0; i<_allFilesInfo.count; i++) {
        NSMutableDictionary *thePhoto =[_allFilesInfo objectAtIndex:i];
        NSMutableDictionary *itemDic = [NSMutableDictionary dictionaryWithDictionary:thePhoto];
        [itemDic setObject:@"jpg" forKey:@"ext"];
        [itemDic setObject:@"yes" forKey:@"local"];
        [ps addObject:itemDic];
    }
    
    [self.delegate allFiles:ps at:photoView.tag];
    
    //[self.delegate openPhoto:_currentSelectedPhoto.photoName path:_currentSelectedPhoto.photoPath fromLocal:YES];
    
    //[[JobViewController defaultController] showPhoto:_currentSelectedPhoto.photoName path:_currentSelectedPhoto.photoPath];
}

-(void)onBtnDeletePhotoTap:(id)sender{
    UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要移除该照片吗？" delegate:self cancelButtonTitle:@"移除照片" otherButtonTitles:@"取消", nil];
    comfirm.tag=2;
    [comfirm show];
    //self.thumbPhotoContainer.contentOffset = CGPointMake(0, (row-1) * 86);
}

-(void)doRemovePhoto{
    NSMutableArray *photos = [_jobInfo objectForKey:@"photos"];
    NSMutableDictionary *photoInfo = [photos objectAtIndex:_currentSelectedPhoto.tag];
    if ([[photoInfo objectForKey:@"uploaded"] isEqualToString:@"yes"]) {
        ServiceProvider *removeService = [ServiceProvider initWithDelegate:self];
        removeService.tag = 2;
        self.lblWaitMsg.text=@"正在删除照片";
        self.asyPhotoView.hidden = NO;
        [removeService getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[photoInfo objectForKey:@"code"],@"code",@"removephoto",@"action",[_jobInfo objectForKey:@"jobid"],@"job",@"yes",@"isDailyjob", nil]];
    }else{
        [self removeLocalPhoto];
    }
}

-(void)removeLocalPhoto{
    NSMutableArray *photos = [_jobInfo objectForKey:@"photos"];
    [photos removeObjectAtIndex:_currentSelectedPhoto.tag];
    [self createThumbPhotos];
    [[Global currentUser] saveCurrentDailyJobToDisk];
    [self updatePhotoButtons];
}

+(NSString *) DATAIDENTITY_DAILYJOB_NEW:(NSString *)uuid{
    return [NSString stringWithFormat:@"DATA_DAILYJOB_NEW_%@",uuid];
}

// 新建停工单
- (IBAction)onBtnNewStopworkFormTap:(id)sender
{
    _updateFormIndex = -1;
    [_gpsLoader startGPS];
    [_stopworkFormView newForm];
    _stopworkFormView.hidden = NO;
}
// 新建整改单
- (IBAction)onBtnNewCorrectiveFormTap:(id)sender
{
    _updateFormIndex = -1;
    [_gpsLoader startGPS];
    [_stopworkFormView newForm];
    _stopworkFormView.hidden = NO;
}
// 点击保存位置
- (IBAction)onBtnLocationTap:(id)sender {
    if(_isLocation)
    {
    if(!_isxmLocation)
    {
        UIAlertView *locationA = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定使用当前定位点,来记录本次巡查位置" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
        locationA.tag = 6;
        [locationA show];
    }
    else
    {
        //获取图标位置坐标
        NSString *loaction = [self getProjectLocation];
        NSArray *arr = [loaction componentsSeparatedByString:@","];
        if(arr.count >0)
        {
            _isxmLocation = YES;
            _longitude = arr[0];
            _latitude = arr[1];
            [MBProgressHUD showSuccess:@"位置保存成功" toView:self];
            NSLog(@"定位坐标 经纬%@,%@",_longitude,_latitude);
            
            
        }
        else
        {
            _isxmLocation = NO;
//            [self gpsLocation:self.gpsBtn];
            [self startCurrentGPS];
            [self changeImageWithGPSMode:_gpsLocationMode];


            
        }
        
        NSLog(@"%@",[self getProjectLocation]);
        
    }
    }else
    {
//        [self gpsLocation:self.gpsBtn];
        [self startCurrentGPS];
        [self changeImageWithGPSMode:_gpsLocationMode];


    
    }
    
}

//巡查报告
- (IBAction)onBtnReportTap:(id)sender {
    NSMutableDictionary *reportData = [_jobInfo objectForKey:@"report"];
    if (reportData.count==0) {
        NSDate *startTime = [[_jobInfo objectForKey:@"times"] objectAtIndex:0];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy年M月d日"];
        [reportData setValue:[formatter stringFromDate:startTime] forKey:@"txt1"];
        [reportData setValue:[Global currentUser].username forKey:@"txt7"];
    }
    [_reportView showForm:reportData];
    _reportView.hidden = NO;
}

//结束今日查询
- (IBAction)onBtnCompletedTap:(id)sender
{
//    if (self.yxTrue.selected==self.yxFalse.selected||self.gczFalse.selected==self.gczTrue.selected) {
//        UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填写基本信息后完成本次巡查" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
//        [comfirm show];
//        
//        
//    }
//    else
    if(!_isxmLocation)//定位
    {
        
        UIAlertView *locationAlert= [[UIAlertView alloc] initWithTitle:@"提示" message:@"移动地图上图标后点击保存位置" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        locationAlert.tag = 5;
        [locationAlert show];
    }
    else
    {
        if(![self.longitude isEqualToString:@""]||![self.longitude isEqualToString:@"0.0"])
        {
            
            UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要完成本次巡查吗？" delegate:self cancelButtonTitle:@"完成巡查" otherButtonTitles:@"取消", nil];
            comfirm.tag=1;
            [comfirm show];
        }else
        {
            //获取图标位置坐标
            NSString *loaction = [self getProjectLocation];
            NSArray *arr = [loaction componentsSeparatedByString:@","];
            if(arr.count >0)
            {
                _isxmLocation = YES;
                _longitude = arr[0];
                _latitude = arr[1];
                
            }
            else
            {
                _isxmLocation = NO;
                [self startCurrentGPS];
                [self changeImageWithGPSMode:_gpsLocationMode];

                
            }
            
        }
    }
    
}

//取消暂停
- (IBAction)onBtnResumeTap:(id)sender {
    [_jobInfo setObject:@"started" forKey:@"status"];
    self.pauseView.hidden = YES;
    NSDate *now = [NSDate date];
    [[_jobInfo objectForKey:@"times"] addObject:now];
    [[Global currentUser] saveCurrentDailyJobToDisk];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    
    //提交用户的巡查状态
    [Global addDataToSyn:[NSString stringWithFormat:DATA_SYN_IDENTITY_UPDATE_DAILYJOB_RESUME,[_jobInfo objectForKey:@"jobid"]] data:[NSMutableDictionary dictionaryWithObjectsAndKeys:[Global currentUser].userid,@"userid",@"query",@"type",@"1",@"status",[formatter stringFromDate:now],@"eventtime",nil]];
//    [self createGpsTimer];
}

- (IBAction)onBtnPauseTap:(id)sender {
    UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要暂停巡查吗？" delegate:self cancelButtonTitle:@"暂停" otherButtonTitles:@"取消", nil];
    comfirm.tag=3;
    [comfirm show];
}

//暂停巡查
-(void)doPauseJob{
    
    [_jobInfo setObject:@"paused" forKey:@"status"];
    NSDate *now = [NSDate date];
    [[_jobInfo objectForKey:@"times"] addObject:now];
    [[Global currentUser] saveCurrentDailyJobToDisk];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd HH:mm:mm"];
    self.lblPauseInfo.text = [NSString stringWithFormat:@"巡查已暂停：%@",[formatter stringFromDate:now]];
    self.pauseView.hidden = NO;
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    [Global addDataToSyn:[NSString stringWithFormat:DATA_SYN_IDENTITY_UPDATE_DAILYJOB_PAUSE,[_jobInfo objectForKey:@"jobid"]] data:[NSMutableDictionary dictionaryWithObjectsAndKeys:[Global currentUser].userid,@"userid",@"query",@"type",@"2",@"status",[formatter stringFromDate:now],@"eventtime",nil]];
    [self clearGpsTimer];
}

#pragma mark ---------stopworkform delegate
// 停工单代理
-(void)stopWorkShouldFormSave:(NSMutableDictionary *)formData json:(NSString *)json location:(NSString *)location newForm:(BOOL)newForm{
    
    NSMutableArray *stopworkforms = [_jobInfo objectForKey:@"stopwork"];
    if (_updateFormIndex==-1) {
        [stopworkforms addObject:formData];
        _stopworkFormView.hidden = YES;
    }else{
        [stopworkforms replaceObjectAtIndex:_updateFormIndex withObject:formData];
    }
    [self.stopWorkFormTableView reloadData];
    [self.correctiveTableView reloadData];
    
    [[Global currentUser] saveCurrentDailyJobToDisk];
}

-(void)stopWorkFormDidClose{
    
}
//保存巡查报告
-(void)dailyJobReportSave:(NSMutableDictionary *)data
{
    [_jobInfo setObject:data forKey:@"report"];
    [[Global currentUser] saveCurrentDailyJobToDisk];
    _reportView.hidden = YES;
    [self updateReportButton];
    
    NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithCapacity:11];
    NSError *error = nil;
    NSData *jsonReportData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    if (nil==error && ![jsonReportData isEqual:@""]) {
        [postData setObject:[[NSString alloc] initWithData:jsonReportData encoding:NSUTF8StringEncoding] forKey:@"report"];
    }
    NSString *jobId = [_jobInfo objectForKey:@"jobid"];
    [postData setObject:jobId forKey:@"jobid"];
    [postData setObject:@"savejobreport" forKey:@"action"];
    [postData setObject:@"zf" forKey:@"type"];
    DataPostman *dp = [[DataPostman alloc] init];
    dp.tag = 2;
    [dp postDataWithUrl:[Global serviceUrl] data:postData delegate:self];
}


#pragma mark -----------tableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.baseTabelView ])
    {
        
        return _infoArray.count;
    }
    else
    {
        return 1;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.stopWorkFormTableView ])
    {
        int val=0;
        if (_jobInfo != nil) {
            NSMutableArray *stopworkforms = [_jobInfo objectForKey:@"stopwork"];
            val = stopworkforms.count;
        }
        self.lblStopworkFromInfo.text = [NSString stringWithFormat:@"停工单（%d）",val];
        return val;
    }
    else if([tableView isEqual:self.correctiveTableView])
    {
        int val=0;
        if (_jobInfo != nil) {
            NSMutableArray *stopworkforms = [_jobInfo objectForKey:@"stopwork"];
            val = stopworkforms.count;
        }
        self.lbCorrectiveInfo.text = [NSString stringWithFormat:@"整改单（%d）",val];
        return val;
    }
    else if ([tableView isEqual:self.baseTabelView])
    {
        
        NSString *mark = [_markArray objectAtIndex:section];
        
        if (section == 0)
        {
            return [_infoArray[section] count];
        }
        else if(section ==1)
        {
            if([mark isEqualToString:@"1"])
            {
                return [_infoArray[section] count];
                
            }else
            {
                
                return 0;
            }
        }
        
        
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.stopWorkFormTableView)
    {
        static NSString *CustomCellIdentifier = @"FormAndMaterialCellIdentifier";
        FormAndMaterialCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        
        if (nil==cell) {
            UINib *nib = [UINib nibWithNibName:@"FormAndMaterialCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        }
        NSMutableArray *stopworkforms = [_jobInfo objectForKey:@"stopwork"];
        NSUInteger row = [indexPath row];
        NSDictionary *theForm = [stopworkforms objectAtIndex:row];
        cell.fileName = [theForm objectForKey:@"code"];
        
        return cell;
    }
    else if([tableView isEqual:self.correctiveTableView])
    {
        static NSString *CustomCellIdentifier = @"FormAndMaterialCellIdentifier";
        FormAndMaterialCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        
        if (nil==cell) {
            UINib *nib = [UINib nibWithNibName:@"FormAndMaterialCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        }
        NSMutableArray *stopworkforms = [_jobInfo objectForKey:@"stopwork"];
        NSUInteger row = [indexPath row];
        NSDictionary *theForm = [stopworkforms objectAtIndex:row];
        cell.fileName = [theForm objectForKey:@"code"];
        
        return cell;
    }
    else
    {
        BaseMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BaseMessageCell"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BaseMessageCell" owner:nil options:nil] lastObject];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.title.text = _infoArray[indexPath.section][indexPath.row];
        if (indexPath.section == 0) {
            
            if(_theprojectInfo)
            {
                cell.detailTitle.text = _detailArray_out[indexPath.row];
            }
            else
            {
                cell.detailTitle.text = @"";
                
            }
            
        }
        
        else if (indexPath.section == 1){
            if (_theprojectInfo) {
                cell.detailTitle.text = _detailArray_in[indexPath.row];
                
                
                if([_detailArray_in[indexPath.row] isEqualToString:@"不计时"])
                {
                    [cell.detailTitle setTextColor:[UIColor colorWithRed:77.0/255.0 green:186.0/255.0 blue:122.0/255.0 alpha:1.0f]];
                    
                }
            } else
            {
                cell.detailTitle.text = @"";
                
            }
        }
        
        
        UIView *line =[[UIView alloc] initWithFrame:CGRectMake(15, 0, MainR.size.width, 1)];
        line.backgroundColor = GRAYCOLOR;
        [cell.contentView addSubview:line];
        
        return cell;
    }
    
}
//头部视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if([tableView isEqual:self.baseTabelView])
    {
        UIView *headView = [[UIView alloc] init];
        headView.tag = section;
        headView.backgroundColor = GRAYCOLOR_LIGHT;
        
        UIView *backV = [[UIView alloc] init];
        backV.backgroundColor = [UIColor whiteColor];
        backV.frame = CGRectMake(0, 0, MainR.size.width, 45);
        backV.tag = section+500;
        [headView addSubview:backV];
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, MainR.size.width-60, 45)];
        lab.font = [UIFont systemFontOfSize:16];
        
        if (section == 1)
        {
            lab.text = @"建设单位信息 (3)";
            
        }
        [headView addSubview:lab];
        UIButton *groupBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        groupBtn.frame = CGRectMake(320-35, 30/2.0, 15, 15);
        [groupBtn setImage:[UIImage imageNamed:_groupImgArray[section]] forState:UIControlStateNormal];
        groupBtn.enabled = NO;
        groupBtn.tag = section+1000;
        [headView addSubview:groupBtn];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOrCloseHeader:)];
        [headView addGestureRecognizer:tap];
        return headView;
    }
    else
    {
        
        return nil;
    }
}
//打开关闭分组
-(void)openOrCloseHeader:(UITapGestureRecognizer *)tap
{
    UIView *tapView = tap.view;
    NSString *mark = _markArray[tapView.tag];
    //UIButton *btn = (UIButton *)[tapView viewWithTag:tapView.tag+1000];
    
    //NSLog(@"tag: %ld, %@",(long)btn.tag,btn);
    if ([mark isEqualToString:@"0"]) {
        [_markArray replaceObjectAtIndex:tapView.tag withObject:@"1"];
        [UIView animateWithDuration:0.5 animations:^{
            //                        [btn setImage:[UIImage imageNamed:@"zhankai"] forState:UIControlStateNormal];
            [_groupImgArray replaceObjectAtIndex:tapView.tag withObject:@"xiangshang"];
            
        }];
        
    }
    else
    {
        [_markArray replaceObjectAtIndex:tapView.tag withObject:@"0"];
        [UIView animateWithDuration:0.5 animations:^{
            //[btn setImage:[UIImage imageNamed:@"zhankai"] forState:UIControlStateNormal];
            [_groupImgArray replaceObjectAtIndex:tapView.tag withObject:@"zhankai"];
        }];
        
    }
    [self.baseTabelView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if([tableView isEqual:self.baseTabelView])
        
    {
        if (section == 0) {
            return 0.0;
        }
        return 45.0;
    }else
    {
        return 0;
        
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    if([tableView isEqual:self.baseTabelView])
        
    {
        return 3;
    }
    else
    {
        return 0;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger row = [indexPath row];
    if (tableView == self.stopWorkFormTableView)
    {
        NSDictionary *theForm = [[_jobInfo objectForKey:@"stopwork"] objectAtIndex:row];
        _updateFormIndex = row;
        [_stopworkFormView showForm:[theForm objectForKey:@"id"] formData:theForm];
        _stopworkFormView.hidden = NO;
    }
    else if (tableView == self.correctiveTableView)
    {
        NSDictionary *theForm = [[_jobInfo objectForKey:@"stopwork"] objectAtIndex:row];
        _updateFormIndex = row;
        [_stopworkFormView showForm:[theForm objectForKey:@"id"] formData:theForm];
        _stopworkFormView.hidden = NO;
    }
    else
    {
        
        
        
        
    }
    
}

- (IBAction)onBtnCloseTap:(id)sender
{
    [self.delegate refershJob];
}


-(void)updateCurrentLoactionView{
    _firstLocation = NO;
    CGPoint screenPoint = [self.mapView toScreenPoint:_currentLocation];
    _currentLocationView.hidden = NO;
    _currentLocationView.frame = CGRectMake(screenPoint.x-24, screenPoint.y-24, 48, 48);
    if (![self.lblPdaPositionInfo.text isEqualToString:@"N/A"]) {
        [_currentLocationView startAnimate];
    }
}

//请求PDA的最后位置
-(void)requestGPS{
    ServiceProvider *p = [ServiceProvider initWithDelegate:self];
    p.tag=1;
    NSString *pdaId = [_jobInfo objectForKey:@"deviceId"];
    [p getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"lastposition",@"action",pdaId,@"device", nil]];
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    if (provider.tag==1) {
        BOOL successfully = [[data objectForKey:@"success"] isEqualToString:@"true"];
        NSString *position = [data objectForKey:@"result"];
        if (successfully && nil!=position && ![position isEqualToString:@""]) {
            self.lblPdaPositionInfo.text = position;
            NSArray *xy = [position componentsSeparatedByString:@","];
            if (xy.count==2) {
                _currentLocation = [[AGSPoint alloc]initWithX:[[xy objectAtIndex:0] doubleValue] y:[[xy objectAtIndex:1] doubleValue] spatialReference:self.mapView.spatialReference];
                if (_firstLocation) {
                    [self.mapView zoomToScale:3521.2337357988677 withCenterPoint:_currentLocation animated:YES];
                }else{
                    [self.mapView zoomToScale:self.mapView.mapScale withCenterPoint:_currentLocation animated:YES];
                }
                [self updateCurrentLoactionView];
                
            }else{
                [_currentLocationView stopAnimate];
                self.lblPdaPositionInfo.text = @"N/A";
            }
        }else{
            [_currentLocationView stopAnimate];
            self.lblPdaPositionInfo.text = @"N/A";
        }
    }else if(provider.tag==2){
        self.asyPhotoView.hidden = YES;
        BOOL successfully = [[data objectForKey:@"status"] isEqualToString:@"true"];
        if (successfully) {
            [self removeLocalPhoto];
        }else{
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除照片失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [error show];
        }
    }
}
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    if(provider.tag==3){
        [self renameOnlinePhotoNameCompleted:[data isEqualToString:@"1"]];
    }
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    if (provider.tag==1) {
        self.lblPdaPositionInfo.text = @"N/A";
    }else if(provider.tag==2){
        self.asyPhotoView.hidden = YES;
    }else if(provider.tag==3){
        [self renameOnlinePhotoNameCompleted:NO];
    }
}

-(void)gpsDidReaded:(CLLocationCoordinate2D)location{
    _location=location;
}

-(IBAction)onBtnAsyPhotoTap:(id)sender{
    [self ansyPhtots];
}

//点击添加随行人员
- (IBAction)addPersonClick:(id)sender {
    if (self.isLoadPerson) {
        TypeList *typlist = [[TypeList alloc] initWithTitle:@"添加随行人员" options:_supPersonArry];
        
        typlist.delegate = self;
        
        [typlist showInView:self animated:YES];
    }
    else
    {
        [MBProgressHUD showSuccess:@"正在加载人员数据,请稍后!" toView:self];
        
    }
}


#pragma mark- typelistDelegate 代理方法
- (void)TypeListViewDidConfirmWithArr:(NSArray *)arr
{
    NSString *str= [arr componentsJoinedByString:@" "];
    self.personLabel.text = str;
    NSLog(@"执行了代理方法%@",arr);
    
}
//
- (void)TypeListViewDidCancel
{
    self.personLabel.text = @"";
    
    NSLog(@"取消");
}


- (void)ansyPhtots {
    
    if(!_isfinishCreated)
    {
        [self loadMaterila];
    }
    if ([Global isOnline]) {
        //        [Global wait:@"正在提交照片..."];
        _mayUploadPhotosClone = [NSMutableArray arrayWithArray:_mayUploadPhotos];
        //self.asyPhotoView.hidden = NO;
        _submitIndex = 0;
        _photoAsyHasError = NO;
        [self doAnsyPhoto];
    }else{
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有网络,请稍后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles :nil];
        [MBProgressHUD hideHUDForView:self animated:YES];
        [msg show];
    }
}

//同步照片
-(void)doAnsyPhoto{
    if (_submitIndex==_mayUploadPhotosClone.count) {
        [MBProgressHUD hideHUDForView:self];
        self.asyPhotoView.hidden = YES;
        [self updatePhotoButtons];
        [Global wait:nil];
        [[Global currentUser] saveCurrentDailyJobToDisk];
        if (_mayCompleted) {
            if (_photoAsyHasError) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"有照片保存失败了，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"丢弃照片，继续完成巡查", nil];
                [alert show];
                alert.tag = 4;
            }else{
                //修改材料目录名称
                [self reviseMaterialName];
                if(!_isRevice)
                {
                //添加一条巡查记录
                [self addxcLog];
                }
                //                [self.delegate dailyJobCompleted];
            }
        }else if(_photoAsyHasError){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"有照片保存失败了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }else{
        NSMutableDictionary *photoInfo = [_mayUploadPhotosClone objectAtIndex:_submitIndex];
        [Global wait:[NSString stringWithFormat:@"正在同步照片 %d/%d",_submitIndex+1,_mayUploadPhotosClone.count]];
        //self.lblWaitMsg.text=[NSString stringWithFormat:@"正在同步照片 %d/%d",_submitIndex+1,_mayUploadPhotos.count];
        NSString *photoName = [photoInfo objectForKey:@"name"];
        NSString *photoCode = [photoInfo objectForKey:@"code"];
        
        //        DataPostman *postman = [[DataPostman alloc] init];
        NSString *path =[NSString stringWithFormat:@"%@/%@.jpg",_photoSaveDirecotry,photoCode];
        NSLog(@"photoPath = %@",path);
        UIImage *theImg = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.jpg",_photoSaveDirecotry,photoCode]];
        [self submitPhotoswithImage:theImg andImageName:photoName];
        
    }
}

//提交照片材料
- (void)submitPhotoswithImage:(UIImage *)theImg andImageName:(NSString *)photoName;
{
//    UIImage *newImage=[UIImage imageWithImageSimple:theImg scaledToSize:CGSizeMake(819.2, 614.4)];
//    (816.8, 537.6)
//    (819, 614)
//    (921, 691)
    
    
    //上传材料
    //    materialInstanceId 材料清单实例Id templateId 目录实例Id guid  空
    //92.168.2.239/KSYDService/ServiceProvider.ashx?type=smartplan&action=uploadMaterial&materialInstanceId=&templateId=&projectId&=userId=&fileName=&guid=
    NSDictionary *params = [NSDictionary dictionary];
    //    NSDate *day =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    //    NSString *dayStr=[formatter stringFromDate:day];
    //    NSString *dayStr1 =[NSString stringWithFormat:@"%@.jpg",dayStr];
    NSDate *tempDate=[formatter dateFromString:photoName];
    [formatter setDateFormat:@"HHmmss"];
    
    NSString *photoNamed = [formatter stringFromDate:tempDate];
    if([photoNamed isEqualToString:@""]||photoNamed == nil)
    {
        photoNamed = photoName;
        
    }
    NSString *pName = [NSString stringWithFormat:@"%@.jpg",photoNamed];
    if (_theProjectMaterialA==nil||_theProjectMaterialA.count==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取材料失败,请稍后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else
    {
        NSString *materialInstanceId = _materialInstanceId;
        params = @{@"action":@"uploadMaterial",@"type":@"smartplan",@"materialInstanceId":materialInstanceId,@"templateId":_templateId,@"projectId":[_theprojectInfo objectForKey:@"projectId"],@"userId":[Global currentUser].userid,@"fileName":pName,@"guid":@""};
        //    [Global currentUser].userid
        //    NSString *zjmUrl =@"http://192.168.2.144/ksyd/ServiceProvider.ashx";
        NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
        //    NSMutableString *requestAddress = [NSMutableString stringWithString:zjmUrl];
        [requestAddress appendString:@"?"];
        
        if (nil!=params) {
            for (NSString *key in params.keyEnumerator) {
                NSString *val = [params objectForKey:key];
                [requestAddress appendFormat:@"&%@=%@",key,val];
            }
        }
        
        NSLog(@"上传照片----%@",requestAddress);
    }
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObject:@"application/json"];
    [manager POST:[Global serviceUrl] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (theImg) {
//            UIImagePNGRepresentation(theImg)
            [formData appendPartWithFileData:UIImageJPEGRepresentation(theImg, 1.0)
              name:@"image"fileName:@"image.png"mimeType:@"image/png"];
        }
        NSLog(@" 取材料当前线程  %@",[NSThread currentThread]);

        
    }success:^(AFHTTPRequestOperation *operation,id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers |
                                     
                                     NSJSONReadingMutableLeaves error:nil];
        
        NSDictionary *rs = (NSDictionary *)responseDic;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            NSLog(@" 图片上传当前线程  %@",[NSThread currentThread]);

            NSMutableDictionary *photoInfo = [_mayUploadPhotosClone objectAtIndex:_submitIndex];
            [photoInfo setObject:@"yes" forKey:@"uploaded"];
            
            NSString *photoCode = [photoInfo objectForKey:@"code"];
            NSArray *photoViews = self.thumbPhotoContainer.subviews;
            NSLog(@"子照片有%d张",photoViews.count);
            for (int i=0; i<photoViews.count; i++) {
             if   (![[photoViews objectAtIndex:i]isKindOfClass:[JobPhotoView class]])
             {
                 NSLog(@"有照片不对");

                 continue;
             }else
             {
                JobPhotoView *pv = (JobPhotoView *)[photoViews objectAtIndex:i];
                
                if (pv.photoCode) {
                    if ([pv.photoCode isEqualToString:photoCode]) {
                        pv.uploaded = YES;
                        break;
                    }
                }
             }
            }
            _submitIndex++;
            [self updatePhotoButtons];
            [[Global currentUser] saveCurrentDailyJobToDisk];
            [self doAnsyPhoto];
            
            
        }
        else{
            
            [Global wait:nil];
            NSString *message=@"";
            if(_mayCompleted)
            {
                [MBProgressHUD hideHUDForView:self];
                message = @"有照片提交失败,可以通过点击同步上传照片来结束巡查";
                
            }
            else
            {
                message = @"照片上传失败,请稍后再试";
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            
            
        }
        
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        NSLog(@"错误错误错误%@",error);
        [Global wait:nil];
        NSString *message=@"";
        if(_mayCompleted)
        {
            [MBProgressHUD hideHUDForView:self];
            message = @"有照片提交失败,可以通过点击同步上传照片来结束巡查";
            
        }
        else
        {
            message = @"照片上传失败,请稍后再试";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }];
}

-(void)showReportErrorMsg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"巡查报告保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    if (request.tag==2) {
        [self showReportErrorMsg];
    }else{
        _submitIndex++;
        _photoAsyHasError = YES;
        [self doAnsyPhoto];
    }
}

#pragma -mark----------取消了uploaded==yes
-(void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.responseStatusCode==200) {
        NSError *parseError = nil;
        NSString *responseString = request.responseString;
        NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&parseError];
        if(nil!=parseError){
            [self requestFailed:request];
        }else if([[rs objectForKey:@"status"] isEqualToString:@"false"]){
            [self requestFailed:request];
            NSLog(@"photoSubmit failed:%@",[rs objectForKey:@"message"]);
        }else if(request.tag==1){
            
            NSMutableDictionary *photoInfo = [_mayUploadPhotosClone objectAtIndex:_submitIndex];
            [photoInfo setObject:@"yes" forKey:@"uploaded"];
            
            NSString *photoCode = [photoInfo objectForKey:@"code"];
            NSArray *photoViews = self.thumbPhotoContainer.subviews;
            for (int i=0; i<photoViews.count; i++) {
                JobPhotoView *pv = [photoViews objectAtIndex:i];
                if ([pv.photoCode isEqualToString:photoCode]) {
                    pv.uploaded = YES;
                    break;
                }
            }
            _submitIndex++;
            [self updatePhotoButtons];
            [[Global currentUser] saveCurrentDailyJobToDisk];
            [self doAnsyPhoto];
        }
    }else{
        [self requestFailed:request];
    }
}
- (IBAction)locaBtnClick:(UIButton *)sender {
    AGSEnvelope *defaultEnvelope=[[AGSEnvelope alloc] initWithXmin:DEFAULT_X_MIN ymin:DEFAULT_Y_MIN xmax:DEFAULT_X_MAX ymax:DEFAULT_Y_MAX spatialReference:self.mapView.spatialReference];
    
    [self.mapView zoomToEnvelope:defaultEnvelope animated:YES];
    
}

//矢量图底图和影响底图切换
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
- (IBAction)btnSwitchBaseMap:(id)sender
{
    [self switchBaseMap];
}


#pragma mark - 坐标转换
/**
 *  定位到本地坐标系
 *
 *  @param longitude 经度
 *  @param latitude  纬度
 */

-(void)displayGPSLong:(NSString*)longitude andLat:(NSString*)latitude{
    
    NSDictionary *dict = @{ @"strLong":longitude, @"strLat":latitude };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:KSGPSSERVERURL parameters:dict success: ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self clearGraphic];
        
        NSDictionary *dic = (NSDictionary *)responseObject;
        double y = [[dic objectForKey:@"x"] doubleValue];
        double x = [[dic objectForKey:@"y"] doubleValue];
        
        AGSPoint *gps = [AGSPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference];
        
        self.agsPoint = gps;
        
        AGSPictureMarkerSymbol * symbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"location.png"];
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:gps symbol:symbol attributes:nil];
        [self.gpsGraphicLayer addGraphic:graphic];
        
        [self.mapView zoomToEnvelope:graphic.geometry.envelope animated:true];
        
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

/**
 *  开始定位
 */

-(void)startCurrentGPS{
    if (!self.mapView.locationDisplay.dataSourceStarted) {
        [self.mapView.locationDisplay startDataSource];
        self.mapView.locationDisplay.alpha = 0.0;
    }
    _gpsLocationMode = 1;
    _isLocation = true;
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
}

-(void)closeCurrentGPS{
    if (self.mapView.locationDisplay.dataSourceStarted) {
        [self.mapView.locationDisplay stopDataSource];
    }
}

- (IBAction)switchTheme:(UISwitch *)sender {
    BOOL isVisible = [sender isOn];
    switch (sender.tag) {
        case 0:
            //控规
            [LayerManager setDynamicLayer:self.mapView withLayerName:KSKG0 ids:KSKG0ID isVisible:isVisible];
            [LayerManager setDynamicLayer:self.mapView withLayerName:KSKG1 ids:KSKG1ID isVisible:isVisible];
            if (isVisible) {
                [self.visibleLayersDict setObject:KSKG0ID forKey:KSKG0];
                [self.visibleLayersDict setObject:KSKG1ID forKey:KSKG1];
            } else {
                [self.visibleLayersDict removeObjectForKey:KSKG0];
                [self.visibleLayersDict removeObjectForKey:KSKG1];
            }
            break;
        case 1:
            //选址红线
            [LayerManager setDynamicLayer:self.mapView withLayerName:KSXZHX ids:KSXZHXID isVisible:isVisible];
            if (isVisible) {
                [self.visibleLayersDict setObject:KSXZHXID forKey:KSXZHX];
            } else {
                [self.visibleLayersDict removeObjectForKey:KSXZHX];
            }
            break;
        case 2:
            //用地红线
            [LayerManager setDynamicLayer:self.mapView withLayerName:KSYDHX ids:KSYDHXID isVisible:isVisible];
            if (isVisible) {
                [self.visibleLayersDict setObject:KSYDHXID forKey:KSYDHX];
            } else {
                [self.visibleLayersDict removeObjectForKey:KSYDHX];
            }
            break;
        default:
            break;
    }
}
- (IBAction)gpsLocation:(UIButton *)sender {
    switch (_gpsLocationMode) {
        case 0:
            //自动模式
            _isLocation = true;
            _gpsLocationMode = 1;
            [self startCurrentGPS];
            break;
        case 1:
            //手动模式
            _isLocation = true;
            _gpsLocationMode = 2;
            [self closeCurrentGPS];
            break;
        default:
            //关闭定位
            _isLocation = false;
            _gpsLocationMode = 0;
            [self closeCurrentGPS];
            break;
    }
    [self changeImageWithGPSMode:_gpsLocationMode];
}


- (void)changeImageWithGPSMode:(GPSLocationMode) gpsMode {
    switch (gpsMode) {
        case 0:
            //自动模式
            [self.gpsBtn setImage:[UIImage imageNamed:@"gps_normal"] forState:UIControlStateNormal];
            break;
        case 1:
            //手动模式
            [self.gpsBtn setImage:[UIImage imageNamed:@"gps_auto"] forState:UIControlStateNormal];
            break;
        default:
            //关闭定位
            [self.gpsBtn setImage:[UIImage imageNamed:@"gps_maual"] forState:UIControlStateNormal];
            break;
    }
}


- (void)registerAsObserver {
    [ self.mapView.locationDisplay addObserver:self
                                    forKeyPath:@"location"
                                       options:(NSKeyValueObservingOptionNew)
                                       context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"location"]) {
        NSLog(@"Location updated to %@", [self.mapView.locationDisplay mapLocation]);
        AGSLocation *loction = self.mapView.locationDisplay.location;
        if (loction != nil && _isLocation && _gpsLocationMode == 1) {
            self.mapView.locationDisplay.alpha = 0.0;
            NSString * strLong = [NSString stringWithFormat:@"%f",loction.point.x];
            NSString * strLat = [NSString stringWithFormat:@"%f",loction.point.y];
            [self displayGPSLong:strLong andLat:strLat];
        }
    }
}

#pragma mark --  AGSMapViewTouchDelegate

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features {
    
    //手动定位模式
    if (_isLocation&&_gpsLocationMode==2) {
        [self creatProjectLocation:[NSString stringWithFormat:@"%f,%f",mappoint.x,mappoint.y]];
        return;
    }
    
    NSArray *indetifyGraphics = [features objectForKey:@"IndentifyGraphicsLayer"];
    NSArray *gpsGraphics = [features objectForKey:@"GPSGraphicLayer"];
    
    if (indetifyGraphics) {
        return [self.indentifyGraphicsLayer removeAllGraphics];
    }
    
    if (gpsGraphics) {
        return;
    }
    
    if (features.count == 0) {
        if (self.visibleLayersDict.count == 0) {
            return [self.indentifyGraphicsLayer removeAllGraphics];
        } else {
            [self showCallout:IdentifyStateTypeIdentifying location:mappoint];
            [self identifyOnline:mappoint];
        }
    }
    
}




#pragma mark -- i 查询

- (void)identifyOnline:(AGSPoint*)point{
    self.mapPoint = point;
    if (self.visibleLayersDict.count == 0) {
        return;
    }
    
    self.identifyCount = 0;
    self.identifyResults = [NSMutableArray array];
    self.filedInfo = [NSMutableDictionary dictionary];
    
    [self doIdentifyOperation];
}

- (void)doIdentifyOperation{
    self.identifyCount += 1;
    if (self.identifyCount > self.visibleLayersDict.count ) {
        [self identifyCompleted];
    } else {
        NSArray* allKeys = [self.visibleLayersDict allKeys];
        NSString *urlStr = [allKeys objectAtIndex:self.identifyCount - 1];
        NSArray *ids = [self.visibleLayersDict objectForKey:urlStr];
        if (urlStr&&ids) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [self executeIdentifyTask:url andIds:ids];
        } else {
            [self doIdentifyOperation];
        }
    }
}

- (void)identifyCompleted{
    [self.activityIndicator stopAnimating];
    self.mapView.callout.customView = nil;
    NSMutableArray *graphics = [NSMutableArray array];
    for (AGSIdentifyResult* result in self.identifyResults) {
        if (result) {
            AGSGraphic* graphic = result.feature;
            NSString *layerId = [NSString stringWithFormat:@"%i",result.layerId];
            [graphic setValue:layerId forKey:@"layerId"];
            [graphic setValue:result.layerName forKey:@"layerName"];
            [graphics addObject:graphic];
        }
    }
    if (graphics.count > 0) {
        //显示气泡
        [self showPopupResultWithLocation:graphics andLocation:self.mapPoint];
    } else {
        //显示空
        [self identifyNullResultCompleted];
    }
    
}



- (void)executeIdentifyTask:(NSURL *)url andIds:(NSArray *)ids {
    self.identifyParameters = [[AGSIdentifyParameters alloc] init];
    self.identifyParameters.layerIds = ids;
    self.identifyParameters.tolerance = 3;
    self.identifyParameters.geometry = self.mapPoint;
    self.identifyParameters.size = self.mapView.bounds.size;
    self.identifyParameters.mapEnvelope = self.mapView.visibleAreaEnvelope;
    self.identifyParameters.returnGeometry = YES;
    self.identifyParameters.layerOption = AGSIdentifyParametersLayerOptionAll;
    self.identifyParameters.spatialReference = self.mapView.spatialReference;
    
    self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:url];
    self.identifyTask.delegate = self;
    [self.identifyTask executeWithParameters:self.identifyParameters];
}


#pragma mark -- AGSIdentifyTaskDelegate

-(void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results{
    [self.indentifyGraphicsLayer removeAllGraphics];
    if (results == nil || results.count == 0) {
        return [self doIdentifyOperation];
    }
    
    for (AGSIdentifyResult *result in results) {
        NSString *key = [NSString stringWithFormat:@"%@_%i",result.layerName,result.layerId];
        NSString *ulrStr = [NSString stringWithFormat:@"%@/%i?f=json",identifyTask.URL,result.layerId];
        if ([self.filedInfo objectForKey:key] == nil) {
            NSURL *url = [NSURL URLWithString:ulrStr];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            NSDictionary *layerDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (layerDict) {
                NSArray *fields = [layerDict objectForKey:@"fields"];
                [self.filedInfo setObject:fields forKey:key];
            }
        }
    }
    
    [self.identifyResults addObjectsFromArray:results];
    [self doIdentifyOperation];
}

-(void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didFailWithError:(NSError *)error{
    
}



//************************************************************************************************************

- (void) identifyNullResultCompleted{
    [self showCallout:IdentifyStateTypeNoResult location:self.mapPoint];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView.callout dismiss];
    });
}

- (void) displayResultsWithPopupVC:(NSArray *)popups {
    [self setupPopupVC:popups];
    [self showCallout:IdentifyStateTypeHasResult location:self.mapPoint];
}


- (void) setupPopupVC: (NSArray *)popups {
    self.popContainerViewController = [[AGSPopupsContainerViewController alloc] initWithPopups:popups usingNavigationControllerStack:false];
    self.popContainerViewController.style = AGSPopupsContainerStyleCustomColor;
    self.popContainerViewController.delegate = self;
    self.popContainerViewController.pagingStyle = AGSPopupsContainerPagingStylePageControl;
    self.popContainerViewController.view.frame = CGRectMake(0, 0, 250, 300);
    
    UIColor *customColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
    self.popContainerViewController.attributeTitleColor = customColor;
    self.popContainerViewController.attributeTitleFont = [UIFont systemFontOfSize:14];
    self.popContainerViewController.attributeDetailFont = [UIFont systemFontOfSize:15];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    closeBtn.frame = CGRectMake(0, 0, 50, 40);
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:customColor forState:UIControlStateNormal];
    [closeBtn addTarget:self action: @selector(closePopup)  forControlEvents:UIControlEventTouchUpInside];
    self.popContainerViewController.actionButton = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    
    self.popContainerViewController.doneButton = [[UIBarButtonItem alloc] init];
}


- (void) showPopupResultWithLocation:(NSArray *)graphics andLocation:(AGSPoint *)point {
    NSMutableArray *popups = [NSMutableArray array];
    NSMutableArray *resultGraphias = [NSMutableArray array];
    AGSGraphic *firstGraphic = nil;
    
    for (AGSGraphic* graphic in graphics) {
        NSString *layerId = [graphic attributeForKey:@"layerId"];
        NSString *layerName = [graphic attributeForKey:@"layerName"];
        NSString *key = [NSString stringWithFormat:@"%@_%@",layerName,layerId];
        
        NSMutableArray* filterKeys = [NSMutableArray array];
        [filterKeys addObjectsFromArray:IDENTIFY_SYS_FIELDS];
        if (self.filedInfo == nil || self.filedInfo.count == 0) {
            [filterKeys addObjectsFromArray:CUSTOM_SYS_FIELDS];
        }
        
        AGSGraphic *filterGraphic = [self filterGraphic:graphic withFilters:filterKeys];
        AGSPopupInfo *popInfo = [AGSPopupInfo popupInfoForGraphic:filterGraphic];
        popInfo.accessibilityLabel = layerName;
        
        NSMutableArray *filedInfos = [NSMutableArray array];
        NSArray *fieldItems = [self.filedInfo objectForKey:key];
        if (fieldItems) {
            for (NSDictionary *dict in fieldItems) {
                NSString *aliasName = [dict objectForKey:@"alias"];
                for (AGSPopupFieldInfo* popFieldInfo in popInfo.fieldInfos) {
                    if ([popFieldInfo.fieldName isEqualToString:aliasName]) {
                        [filedInfos addObject:popFieldInfo];
                        break;
                    }
                }
            }
            popInfo.fieldInfos = filedInfos;
        }
        
        AGSPopup *pop = [AGSPopup popupWithGraphic:filterGraphic popupInfo:popInfo];
        
        [popups addObject:pop];
        [resultGraphias addObject:graphic];
    }
    
    if (resultGraphias.count > 0) {
        firstGraphic = [resultGraphias objectAtIndex:0];
    }
    
    if (firstGraphic != nil) {
        [self setGraphicWithSymbol:firstGraphic];
        [self.indentifyGraphicsLayer addGraphic:firstGraphic];
        self.focusGraphic = firstGraphic;
    }
    
    [self displayResultsWithPopupVC:popups];
    
}

-(void) showCallout:(IdentifyStateType) state location:(AGSPoint *)mappoint {
    switch (state) {
        case IdentifyStateTypeIdentifying:
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.activityIndicator.color = [UIColor blueColor];
            [self.activityIndicator startAnimating];
            
            self.mapView.callout.customView = self.activityIndicator;
            self.mapView.callout.customView.layer.cornerRadius = 0;
            self.mapView.callout.cornerRadius = 0;
            self.mapView.callout.margin = CGSizeMake(5, 5);
            
            break;
        case IdentifyStateTypeHasResult:
            self.mapView.callout.customView = self.popContainerViewController.view;
            self.mapView.callout.cornerRadius = 20;
            self.mapView.callout.customView.layer.cornerRadius = 20;
            self.mapView.callout.customView.clipsToBounds = YES;
            self.mapView.callout.margin = CGSizeZero;
            break;
        case IdentifyStateTypeNoResult:
            self.mapView.callout.tintColor = [UIColor redColor];
            self.mapView.callout.accessoryButtonHidden = YES;
            self.mapView.callout.title = @"无查询结果";
            self.mapView.callout.detail = @"";
            break;
        default:
            self.mapView.callout.tintColor = [UIColor redColor];
            self.mapView.callout.accessoryButtonHidden = YES;
            self.mapView.callout.title = @"查询失败";
            self.mapView.callout.detail = @"";
            break;
    }
    
    [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
}


// 过滤grahpic属性
-(AGSGraphic *)filterGraphic:(AGSGraphic *)graphic withFilters:(NSArray*)filterKeys {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[graphic allAttributes]];
    NSArray *keys = [attributes allKeys];
    for (NSString *key in keys) {
        //移除系统字段
        if ([filterKeys containsObject:key]) {
            [attributes removeObjectForKey:key];
            continue;
        }
        
        //移除空字段
        NSString *graphicValue = nil;
        id value = [attributes objectForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            graphicValue = [(NSNumber *)value stringValue];
        } else if ([value isKindOfClass:[NSString class]]) {
            graphicValue = value;
        } else {
            graphicValue = @"";
        }
        
        if ([graphicValue.uppercaseString isEqualToString:@"NULL"]||[graphicValue.uppercaseString isEqualToString:@""]) {
            [attributes removeObjectForKey:key];
        }
    }
    
    AGSGraphic *newGraphic = [AGSGraphic graphicWithGeometry:graphic.geometry symbol:graphic.symbol attributes:attributes];
    return newGraphic;
}


- (void) setGraphicWithSymbol:(AGSGraphic *)graphic {
    AGSGeometry *geometry = graphic.geometry;
    if ([geometry isKindOfClass:[AGSPoint class]]) {
        AGSSimpleMarkerSymbol *symbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
        symbol.color = [UIColor redColor];
        symbol.style = AGSSimpleMarkerSymbolStyleDiamond;
        graphic.symbol = symbol;
    }
    if ([geometry isKindOfClass:[AGSPolyline class]]) {
        AGSSimpleLineSymbol *symbol = [AGSSimpleLineSymbol simpleLineSymbol];
        symbol.style = AGSSimpleLineSymbolStyleSolid;
        symbol.color = [UIColor yellowColor];
        symbol.width = 4.0;
        graphic.symbol = symbol;
    }
    if ([geometry isKindOfClass:[AGSPolygon class]]) {
        AGSSimpleLineSymbol *outline = [AGSSimpleLineSymbol simpleLineSymbol];
        outline.style = AGSSimpleLineSymbolStyleSolid;
        outline.color = [UIColor yellowColor];
        outline.width = 2.0;
        
        AGSSimpleFillSymbol *symbol = [AGSSimpleFillSymbol simpleFillSymbol];
        symbol.color = [UIColor redColor];
        symbol.outline = outline;
        graphic.symbol = symbol;
    }
}


// 关闭弹出窗
-(void)closePopup {
    [self.mapView.callout dismiss];
    [self.indentifyGraphicsLayer removeAllGraphics];
}

#pragma mark -  AGSPopupsContainerDelegate

-(void)popupsContainer:(id<AGSPopupsContainer>)popupsContainer didChangeToCurrentPopup:(AGSPopup *)popup{
    AGSGraphic* graphic = nil;
    if (popup.feature) {
        graphic = [AGSGraphic graphicWithFeature:popup.feature];
    }
    
    [self.indentifyGraphicsLayer removeGraphic:self.focusGraphic];
    [self setGraphicWithSymbol:graphic];
    [self.indentifyGraphicsLayer addGraphic:graphic];
    self.focusGraphic = graphic;
    
    [self.mapView.callout moveCalloutTo:graphic.geometry.envelope.center screenOffset:CGPointZero animated:true];
    
}


@end
