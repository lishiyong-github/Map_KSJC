//
//  JobDetailView.m
//  zzzf
//
//  Created by dist on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//表单材料等详情View

#import "JobDetailView.h"
#import "FormAndMaterialCell.h"
#import "MaterialGroupInfo.h"
#import "MaterialInfo.h"
//#import "ProjectFormInfo.h"
#import "JobDetailView+Photo.h"
#import "JobDetailView+StopworkFrom.h"
#import "MapJobViewController.h"
#import "Materialcellcell.h"
#import "Logcell.h"
#import "phLogCell.h"
//#define BOOL downLoad=false;
#import "MapJobViewController.h"
#import "MBProgressHUD+MJ.h"

@interface JobDetailView ()<NewDailyJobDelegate,MapJobViewControllerDelegate>

{
    //
    MZFormSheetController *formSheet;
    MZFormSheetController *_addLogformSheet;
    
    UIAlertView *baseAlert;
    
}
@property (nonatomic,strong)NSMutableDictionary *theProject;

@property (nonatomic,strong)NSMutableArray *materials;
@property (nonatomic,strong)NSMutableArray *logs;
@property (nonatomic,strong)NSMutableArray *phLogs;

//保存位置范围
@property (nonatomic,assign)double xmin;
@property (nonatomic,assign)double xmax;
@property (nonatomic,assign)double ymin;
@property (nonatomic,assign)double ymax;
//保存位置显示一个气泡
@property (nonatomic,assign)bool isAdded;



@end

@implementation JobDetailView

-(void)initializedView{
    if (_viewInitialized) {
        _btnPhotos.hidden = YES;
        
        return;
    }
    
    if (_newDailyJobViewController == nil) {
        //新建巡查界面
        _newDailyJobViewController =[[NewDailyJobViewController alloc] initWithNibName:@"NewDailyJobViewController" bundle:nil];
        
        //设置NewDailyJobDelegate代理
        _newDailyJobViewController.delegate = self;
    }
    
    _btnPhotos.hidden = YES;
    
    _materials =[NSMutableArray array];
    _logs =[NSMutableArray array];
    _phLogs = [NSMutableArray array];
    _readonly = NO;
    
    _xmin = DBL_MAX;
    _ymin = DBL_MAX;
    _xmax = -DBL_MAX;
    _ymax = -DBL_MAX;
    _isAdded = NO;
    
    self.materialTable.tableFooterView=[[UIView alloc] init];
    self.materialTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSString *path;
    NSURL *url;
    NSURLRequest *request;
    if (_isSP) {
        path = [[NSBundle mainBundle] pathForResource:@"form" ofType:@"htm"];
         url= [NSURL fileURLWithPath:path];
       request =[NSURLRequest requestWithURL:url];
        [self.formWebView loadRequest:request];



    }
//    else
//    {
//        NSString *urlStr=[NSString stringWithFormat:@"%@?type=formpage&r=%f",[Global serviceUrl],roundf(3.1415)];
//        url =[NSURL URLWithString:urlStr];
//
//    }
    self.formWebView.delegate=self;
    
//    [self.formWebView loadRequest:request];
    if (_jumpfromMap) {
        _logTableView.frame = CGRectMake(0, 510,794, 200);
        _phLogTableView.frame =CGRectMake(0, 510,794, 200);
        
    }
    
    
    _logTableView.delegate =self;
    _logTableView.dataSource =self;
    _logTableView.bounces = NO;
    self.logTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //批后跟踪tableView
    _phLogTableView.delegate =self;
    _phLogTableView.dataSource =self;
    _phLogTableView.bounces = NO;
    self.phLogTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    _viewInitialized = YES;
    
    self.lblProjectName.layer.cornerRadius = 5;
    
    self.jobMenuView.backgroundColor = [UIColor whiteColor];
    self.jobMenuView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.jobMenuView.layer.shadowOpacity = 1.0;
    self.jobMenuView.layer.shadowRadius = 3.0;
    self.jobMenuView.layer.shadowOffset = CGSizeMake(0,1);
    self.jobMenuView.clipsToBounds = NO;
    
    self.btnFormName.layer.cornerRadius = 5;
    
    self.btnLocation.layer.cornerRadius = 3;
    //    self.btnLocation.hidden = YES;
    self.btnPhotos.layer.cornerRadius = 3;
    self.btnGetPhoto.layer.cornerRadius = 3;
    self.btnStopwork.layer.cornerRadius = 3;
    self.btnCorrective.layer.cornerRadius = 3;
    _formDataInitialized = NO;
}



+(JobDetailView *) createView{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"JobDetailView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

-(void)setReadonly:(BOOL)readonly{
    _readonly = readonly;
    self.btnGetPhoto.hidden =self.btnRenamePhoto.hidden = self.btnSubmitPhoto.hidden = self.btnDeletePhoto.hidden = readonly;
    self.btnBackToMap.hidden = !_readonly;
    if(_readonly){
        self.photoView.frame = CGRectMake(0, 100, 723, 680);
    }
}

- (BOOL)isDoubleRandom
{
    if (self.theProject) {
        return [self.theProject[@"isDoubleRamdom"] isEqualToString:@"是"];
    }
    return NO;
}

//加载某行cell数据对应(表单/照片/停工单等)的具体信息
-(void)loadProject:(NSMutableDictionary *)theProject typeName:(NSString *)typeName{
    //保存点击的某条记录
    _theProject = theProject;
    //去掉原来的的请求
    if (_materialProvider) {
        [_materialProvider kill];
    }
    if (_photoProvider) {
        [_photoProvider kill];
    }
    if (_formProvider) {
        [_formProvider kill];
    }
    if (_stopworkformProvider) {
        [_stopworkformProvider kill];
    }
    if (_correctiveformProvider) {
        [_correctiveformProvider kill];
    }
    
    _photoThumbCreated = NO;
    //     _type="Fyx";放验线/ph etc
    _type=typeName;
    //获取和id有关的保存路径 (和id有关)
    _projectSavePath = [NSString stringWithFormat:@"%@/%@.plist",[Global currentUser].userProjectPath,[theProject objectForKey:@"projectId"]];
    //设置表单名字(多表单)
    [self.btnFormName setTitle:@"" forState:UIControlStateNormal];
    //offlineView用来显示没有网络的提示
    self.offlineView.hidden = YES;
    
    //如果是离线，则从本地缓存中取数据
    if (![Global isOnline]) {
        //读取本地缓存数据
        NSMutableDictionary *cacheData = [NSMutableDictionary dictionaryWithContentsOfFile:_projectSavePath];
        //判断缓存是否有数据
        if (nil==cacheData) {
            self.offlineView.hidden = NO;
            return;
        }else{//有数据
            theProject = cacheData;
        }
    }
    
    //在类扩展JobDetailView+StopworkFrom中
    [self clearStopworkForm];
    //隐藏photoView和取消照片按钮选中
    [self onBtnClosePhotoList:nil];
    //设置基础路径
    _projectPath=[[Global currentUser].userProjectPath stringByAppendingPathComponent:[theProject objectForKey:@"projectId"]];
    //隐藏表单的菊花
    self.formActivityIndicator.hidden = YES;
    //隐藏材料的菊花
    self.materialActivityIndicator.hidden = YES;
    //隐藏表单名按钮
    self.btnFormName.hidden = YES;
    _dataLoadFlag = 0;
    //隐藏照片view
    self.photoView.hidden = YES;
    //取消照片按钮的选中
    self.btnPhotos.selected = NO;
    //有stopworkFrom 就隐藏
    [self hideStopworkForm];
    //隐藏地图定位
    [self hideMapForm];
    //取消编辑按钮(默认显示为 编辑表单和发送)
    [self onCancelFormDetail:nil];
    
    //设置project内容
    _project = theProject;
    //获取项目名(jobDetailView的标题名)
    self.lblProjectName.text = [_project objectForKey:PROJECTKEY_NAME];
    [self.formWebView stringByEvaluatingJavaScriptFromString:@"window.clear()"];
    //    /var/mobile/Containers/Data/Application/0BE62173-C425-4F3A-A609-588E52F92FE3/Library/users/122/work/project
    NSString *userProjectPath=[Global currentUser].userProjectPath;
    //在项目路径下生成/projectList.plist 路径,并获取内容
    NSMutableArray *arrProjectList=[NSMutableArray arrayWithContentsOfFile:[userProjectPath stringByAppendingPathComponent:@"projectList.plist"]];
    //显示正在下载...的lable(隐藏)
    self.lblDownStatus.hidden=true;
    self.btnRemove.enabled=false;
    
    //判断路径下是否有存在该项目,并且下载进度为100,就显示已下载,
    for (NSMutableDictionary *item in arrProjectList) {
        if ([[item objectForKey:@"projectId"] isEqualToString:[_project objectForKey:PROJECTKEY_ID]]) {
            NSInteger downPersent=[[item objectForKey:@"downPersent"] integerValue];
            NSLog(@"..%d",downPersent);
            if (downPersent==100) {
                self.lblDownStatus.text=@"已下载";
                self.lblDownStatus.hidden=false;
                self.btnRemove.enabled=true;
            }
        }
    }
    ////获取表单信息
    NSMutableArray *forms = [_project objectForKey:@"forms"];
    //获取表单信息
    if (forms == nil||forms.count==0) {
        [self.formTable reloadData];
        _formProvider = [ServiceProvider initWithDelegate:self];
        _formProvider.tag = 1;
        //隐藏按钮(编辑表单/发送/提交/取消编辑按钮)
        self.viewOperation.hidden = YES;
        //显示表单部分的菊花
        self.formActivityIndicator.hidden=NO;
        //        168.2.239/KSYDService/serviceprovider.ashx?type=smartplan&action=formlist&projectId=76002
        ////加载表单数据
        //      39/KSYDService/serviceprovider.ashx?type=smartplan&action=formdetail&user=181&project=76002&form=3445
        
        [_formProvider getData:@"smartplan" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"formlist",@"action", [_project objectForKey:@"projectId"],@"projectId",nil]];
    }else{
        if (!_readonly) {
            //显示按钮(编辑/发送/提交)隐藏
            self.viewOperation.hidden = NO;
        }
        //显示第一个表单
        [self showForm:0];
    }
    
    ////加载材料数据
    NSMutableArray *materials = [_project objectForKey:PROJECTKEY_MATERIALS];
    
    if(materials==nil) {
        _materials = [NSMutableArray array];
        _materialProvider = [ServiceProvider initWithDelegate:self];
        _materialProvider.tag=2;
        //显示材料部分的菊花
        self.materialActivityIndicator.hidden = NO;
        //加载材料请求
        //       6.138.178:8040/KSYDService/ServiceProvider.ashx?&slbh=DGF20150021&type=smartplan&action=materials
        
        //        [_materialProvider getData:@"smartplan" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"materials",@"action",[_project objectForKey:PROJECTKEY_ID],@"project", nil]];
        [_materialProvider getData:@"smartplan" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"materials",@"action", [_project objectForKey:@"slbh"],@"slbh",nil]];
    }else
    {
        if (_ThelogClick) {  //点击某条记录,只显示这一条记录材料
            if(materials.count>0)
            {
                NSArray *mateArr =[materials[0] objectForKey:@"files"];
                for (NSDictionary *dict in mateArr) {
                    NSString *str = [dict objectForKey:@"group"];
                    if ([str isEqualToString:_xcTime]) {
                        _materials = [NSMutableArray arrayWithArray:[dict objectForKey:@"files"]];
                        
                    }
                }
                
            }
        }
        else
        {
            _materials = materials;
        }
        [self.materialTable reloadData];
        
    }
    
    
    NSLog(@"type= 类型类型类型类型%@",_type);
    if([_type isEqualToString:@"Wfxm"])
    {
        _btnLocation.hidden = NO;
        _logTableView.hidden = NO;
        _phLogTableView.hidden = YES;
        if (_ThelogClick) {  //点击某条记录,只显示这一条记录
            
            NSMutableArray *arr = [NSMutableArray arrayWithObject:_theLogDict];
            _logs = arr;
            [_project setObject:arr forKey:PROJECTKEY_LOG];
            [self.logTableView reloadData];
        }
        else
        {
            //加载记录
            NSMutableArray *log= [_project objectForKey:PROJECTKEY_LOG];
            if (log==nil) {
                //      :8040/KSYDService/ServiceProvider.ashx?type=smartplan&action=getphgldata&startDate=2016-10-30%2000:00:00&endDate=2016-12-10%2000:00:00&pid=
                _logProvider= [ServiceProvider initWithDelegate:self];
                _logProvider.tag = 9;
                [_logProvider getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getphgldata",@"action",[_project objectForKey:PROJECTKEY_ID],@"pid", nil]];
                
            }else{
                //        self.btnCorrective.hidden = NO;
                _logs = log;
                [self.logTableView reloadData];
            }
        }
    }
    else
    {
        _btnLocation.hidden = YES;
        _logTableView.hidden = YES;
        _phLogTableView.hidden = NO;
        //加载批后跟踪记录
        NSMutableArray *phlog= [_project objectForKey:PROJECTKEY_PHLOG];
        if (phlog==nil) {
            _phjlProvider = [ServiceProvider initWithDelegate:self];
            _phjlProvider.tag = 20;
            [_phjlProvider getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getsupervisorylist",@"action",@"",@"xmbh",@"",@"slbh",@"",@"prjName",@"批后过程管理",@"businessName",@"",@"businessId",@"",@"prjState",@"0",@"pageIndex",@"2000",@"pageSize",@"",@"querystring",[_project objectForKey:PROJECTKEY_XMBH],@"querystring", nil]];
        }else{
            //        self.btnCorrective.hidden = NO;
            _phLogs = phlog;
            [self.phLogTableView reloadData];
        }
    }
    
    //地图定位
    if (_mapLocationView&&!_mapLocationView.hidden) {
        //定位项目
        [self clearGraphics];
        //巡查记录定位
        [self recordLocation:_project];
        /*
         NSString *xmbh = [_project objectForKey:PROJECTKEY_XMBH];
         NSNumber *layerid = [KSJZHXID objectAtIndex:0];
         NSString *ulrStr = [NSString stringWithFormat:@"%@%@",KSJZHX,layerid];
         [self projectLocation:xmbh andURL:[NSURL URLWithString:ulrStr]];
         */
    }
    
    if ([self isDoubleRandom]) {
        CGRect frame = self.formWebView.frame;
        frame.size.height += 40;
        self.formWebView.frame = frame;
    }
    
}

- (IBAction)onCloseButtonTap:(id)sender {
    self.hidden = YES;
    //[self.delegate jobDetailClosed];
}

- (IBAction)onBtnMenuTap:(id)sender {
    self.jobMenuView.hidden = NO;
    self.maskView.hidden=NO;
    self.maskView.alpha=0;
    CGRect origionRect = self.jobMenuView.frame;
    self.jobMenuView.frame = CGRectMake(627 , 60, origionRect.size.width, origionRect.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.jobMenuView.frame = CGRectMake(637 , 60, origionRect.size.width, origionRect.size.height);;
    self.maskView.alpha=0.3;
    [UIView commitAnimations];
}

//点击同步照片
-(IBAction)onBtnSubmitPhotoTap:(id)sender{
    [self ansyPhtots];
}

- (IBAction)onBtnCorrectiveTap:(id)sender {
}
#pragma -mark -------是否从相册选取照片
//点击拍照
-(IBAction)onCameraMenuItemTap:(id)sender{
    UIAlertView *photoAlertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请选择从相册选取图片或者打开拍照功能" delegate:self cancelButtonTitle:@"从相册选取" otherButtonTitles:@"开始拍照", nil];
    photoAlertView.tag=10;
    [photoAlertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1) {
        if (buttonIndex==0) {
            //[self.delegate dailyJobCompleted];
        }
    }else if(alertView.tag==0){
        if (buttonIndex==0) {
            NSString *photoName = [alertView textFieldAtIndex:0].text;
            if (![photoName isEqualToString:@""] && ![_currentSelectedPhoto.photoName isEqualToString:photoName]) {
                if ([self checkNewPhotoName:photoName]) {
                    [self renamePhoto:photoName];
                }else{
                    _reAlertView = alertView;
                    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(reInputPhotoName) userInfo:nil repeats:NO];
                }
            }
        }
    }else if(alertView.tag==2){
        if (buttonIndex==0) {
            [self removeCurrentSelectedPhoto];
        }
    }else if(alertView.tag==3){
        if (buttonIndex==0) {
            //[self doPauseJob];
        }
    }
    else if (alertView.tag==10){
        if (buttonIndex==0) {
            NSLog(@"打开相册");
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(photoalbum) userInfo:nil repeats:NO];
        }
        if (buttonIndex==1) {
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(photograph) userInfo:nil repeats:NO];
            NSLog(@"拍照");
        }
    }
    else if (alertView.tag==100)
    {
        //     [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedNewJobView" object:nil];
        
    }
    
}

-(void)reInputPhotoName{
    _reAlertView.message = @"已存在的照片名称，请重新输入";
    [_reAlertView show];
}

/*
 -(void)reComfirm{
 UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"拍照" message:@"已存在的改名称，请再次输入" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"取消", nil];
 
 comfirm.alertViewStyle = UIAlertViewStylePlainTextInput;
 [comfirm textFieldAtIndex:0].text = _reComfirmPhotoName;
 CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 60);
 [comfirm setTransform:myTransform];
 [comfirm show];
 }
 */


#pragma mark ---- ServiceProvder 下载代理方法
//收到数据(材料+表单+停工单+照片)
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    //表单
    if (provider.tag==1) {
        //隐藏表单菊花
        self.formActivityIndicator.hidden=YES;
        NSMutableArray *forms = [NSMutableArray arrayWithCapacity:5];
        //_project.forms = [[NSMutableArray alloc] initWithCapacity:5];
        if ([[data objectForKey:@"success"] isEqualToString:@"true"]) {
            NSMutableArray *formlist = [data objectForKey:@"result"];
            for (NSDictionary *formAttributes in formlist) {
                //                "success": "true",
                //                "result": [
                //                           {
                //                               "id": "183930",
                //                               "project": "9663",
                //                               "busiFormId": "707",
                //                               "name": "放验线申请单",
                //                               "detail": {
                //                                   "success": "true",
                //                                   "result": [
                //                                              {
                //                                                  "id": "24584",
                //                                                  "text": "案卷编号",
                //                                                  "value": "F0[2014]0045",
                //                                                  "field": "PROJECTNO",
                //                                                  "table": "ts_project",
                //                                                  "readonly": "true",
                //                                                  "extensionType": "文本框"
                //                                              },
                //
                
                /*
                 ProjectFormInfo *formInfo = [[ProjectFormInfo alloc] init];
                 formInfo.name = [formAttributes objectForKey:@"name"];
                 formInfo.formId = [formAttributes objectForKey:@"id"];
                 formInfo.projectId = [formAttributes objectForKey:@"project"];
                 formInfo.formDefineId = [formAttributes objectForKey:@"busiFormId"];
                 */
                NSMutableDictionary *formItemInfo = [NSMutableDictionary dictionaryWithDictionary:formAttributes];
                
                NSDictionary *detail = [formAttributes objectForKey:@"detail"];
                
                [formItemInfo removeObjectForKey:@"detail"];
                NSMutableArray *formDetailDefine = [NSMutableArray arrayWithCapacity:detail.count];
                
                NSArray *rs = [detail objectForKey:@"result"];
                
                for(int i=0;i<rs.count;i++){
                    NSMutableDictionary *tableInfo = [NSMutableDictionary dictionaryWithDictionary:[rs objectAtIndex:i]];
                    [formDetailDefine addObject:tableInfo];
                }
                [formItemInfo setObject:formDetailDefine forKey:@"detail"];
                [forms addObject:formItemInfo];
            }
            //给字典添加材料key 和值
            [_project setObject:forms forKey:PROJECTKEY_FORMS];
            //有材料
            if (forms.count>0) {
                //显示第一个
                [self showForm:0];
            }
        }
        //不是只读,就可以修改表单,即可显示按钮
        if (!_readonly) {
            //显示按钮
            self.viewOperation.hidden = NO;
        }
        //刷新formtabelView
        [self.formTable reloadData];
    }
    
    
    
    
    else if(provider.tag==2){//材料
        //        "success": "true",
        //        "id": 9663,
        //        "result": [
        //                   {
        //                       "group": "放验线申请报告",
        //                       "instanceid": "626",
        //                       "groupid": "541",
        //                       "files": []
        //                   },
        //
        self.materialActivityIndicator.hidden = YES;
        NSString *success = [data objectForKey:@"success"];
        if ([success isEqualToString:@"true"]) {
            NSMutableArray *result = [data objectForKey:@"result"];
            
            [_materials addObjectsFromArray:result];
            //                                    [_dataArray insertObjects:result atIndexes:0];
            if (_ThelogClick) {  //点击某条记录,只显示这一条记录材料
                if(_materials.count>0)
                {
                    NSArray *mateArr =[_materials[0] objectForKey:@"files"];
                    for (NSDictionary *dict in mateArr) {
                        NSString *str = [dict objectForKey:@"guid"];
                        if ([str isEqualToString:_xcTime]) {
                            _materials =[NSMutableArray arrayWithObject:dict];
                            //                            [NSMutableArray arrayWithArray:[dict objectForKey:@"files"]];
                            for (NSDictionary *dic in _materials)
                            {
                                if([dic valueForKey:@"files"])
                                {
                                    NSArray *array = [dic valueForKey:@"files"];
                                    
                                    BOOL isAlreadyInserted = NO;
                                    
                                    for(NSDictionary *dInner in array)
                                    {
                                        NSInteger index=[_materials indexOfObjectIdenticalTo:dInner];
                                        //NSLog(@"index = %ld",(long)index);
                                        isAlreadyInserted = (index>0 && index!=NSIntegerMax);
                                        if(isAlreadyInserted)
                                            
                                            break;
                                    }
                                    
                                    if(isAlreadyInserted)
                                    {
                                        [self miniMizeThisRows:array];
                                    }
                                    else
                                    {
                                        NSUInteger count = self.materials.count+1;
                                        NSMutableArray *cellArr = [NSMutableArray array];
                                        for(NSDictionary *inDic in array)
                                        {
                                            
                                            [cellArr addObject:inDic];
                                        }
                                        [_materials addObjectsFromArray:cellArr];
                                        
                                        
                                        
                                    }
                                }
                                
                            }
                        }else
                        {
                            
                            
                        }
                    }
                    
                }
            }
            
            else
            {
                
                for (NSDictionary *dic in result)
                {
                    if([dic valueForKey:@"files"])
                    {
                        NSArray *array = [dic valueForKey:@"files"];
                        
                        BOOL isAlreadyInserted = NO;
                        
                        for(NSDictionary *dInner in array)
                        {
                            NSInteger index=[_materials indexOfObjectIdenticalTo:dInner];
                            //NSLog(@"index = %ld",(long)index);
                            isAlreadyInserted = (index>0 && index!=NSIntegerMax);
                            if(isAlreadyInserted)
                                
                                break;
                        }
                        
                        if(isAlreadyInserted)
                        {
                            [self miniMizeThisRows:array];
                        }
                        else
                        {
                            NSUInteger count = self.materials.count+1;
                            NSMutableArray *cellArr = [NSMutableArray array];
                            for(NSDictionary *inDic in array)
                            {
                                
                                [cellArr addObject:inDic];
                            }
                            [_materials addObjectsFromArray:cellArr];
                            
                            
                            
                        }
                    }
                    
                }
                //往_project上添加材料的key 和Value
                [_project setObject:_materials forKey:PROJECTKEY_MATERIALS];
                //            _materials = materialGroups;
            }
        }
        [self.materialTable reloadData];
        
    }
    else if(provider.tag==3){//照片
        //        "success": "true",
        //        "result": [
        //                   {
        //                       "code": "A4522C2D-B131-4A11-BDD0-D7D251A2F85F",
        //                       "name": "2",
        //                       "location": "502088.75542889,3077158.9648746",
        //                       "time": "2014/7/22 10:16:16",
        //                       "uploaded": "YES"
        //                   },
        
        //显示照片按钮
        self.btnPhotos.hidden = NO;
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:10];
        NSString *success = [data objectForKey:@"success"];
        if ([success isEqualToString:@"true"]) {
            NSArray *result = [data objectForKey:@"result"];
            for (NSDictionary *photoItem in result) {
                [photos addObject:[NSMutableDictionary dictionaryWithDictionary:photoItem]];
            }
        }
        [_project setObject:photos forKey:PROJECTKEY_PHOTOS];
        //初始化照片数据
        [self initializePhotoData];
    }else if(provider.tag==4){//停工单
        self.btnStopwork.hidden = NO;
        NSMutableArray *stopworkforms = [NSMutableArray arrayWithCapacity:10];
        NSString *success = [data objectForKey:@"success"];
        if ([success isEqualToString:@"true"]) {
            NSMutableArray *forms = [data objectForKey:@"result"];
            for (NSDictionary *formItem in forms) {
                [stopworkforms addObject:[NSMutableDictionary dictionaryWithDictionary:formItem]];
            }
        }
        [_project setObject:stopworkforms forKey:PROJECTKEY_STOPWORKFORMS];
    }
    
    
    
    
    else if(provider.tag==5){//整改单
        //            self.btnCorrective.hidden = NO;
        NSMutableArray *correctiveforms = [NSMutableArray arrayWithCapacity:10];
        NSString *success = [data objectForKey:@"success"];
        if ([success isEqualToString:@"true"]) {
            NSMutableArray *forms = [data objectForKey:@"result"];
            for (NSDictionary *formItem in forms) {
                [correctiveforms addObject:[NSMutableDictionary dictionaryWithDictionary:formItem]];
            }
        }
        [_project setObject:correctiveforms forKey:PROJECTKEY_STOPWORKFORMS];
    }
    
    if(provider.tag == 8)//表单详情
    {
        //
        NSMutableArray *correctiveforms = [NSMutableArray arrayWithCapacity:10];
        NSString *success = [data objectForKey:@"success"];
        if ([success isEqualToString:@"true"]) {
            NSMutableArray *forms = [NSMutableArray arrayWithArray:[data objectForKey:@"result"]];
            /******************* 添加双随机项目 *******************/
            NSMutableDictionary *addRandowDic = [NSMutableDictionary dictionaryWithDictionary:forms.lastObject];
            if ([self isDoubleRandom]) {
                [addRandowDic setObject:@"在建双随机项目" forKey:@"text"];
                [addRandowDic setObject:_theProject[@"teamMate"] forKey:@"value"];
                [forms addObject:addRandowDic];
            }
            /******************* 添加双随机项目 *******************/
            NSString *script =[NSString stringWithFormat:@"window.createFormPanel(%@)", [self formJsonFromDictionary:forms]];
            //                        NSLog(@"创建表单传数据_%@",script);
            // 表单
            [self.formWebView stringByEvaluatingJavaScriptFromString:script];
        }}
    [self.formTable reloadData];
    if (self.btnModifyFormDetail.hidden) {
        [self onModifyFormDetail:self.btnModifyFormDetail];
    }
    //不是只读,就可以修改表单,即可显示按钮
    if (!_readonly) {
        //显示按钮
        self.viewOperation.hidden = NO;
    }
    
    
    //每次加载完某个数据,就判断数据是否全部加载完成/如果完成,就可以缓存数据
    [self onFormDataDidLoaded];
    
    
    if(provider.tag == 9)//记录列表
    {
        NSMutableArray *logS = [NSMutableArray arrayWithCapacity:10];
        NSString *success = [data objectForKey:@"success"];
        if ([success isEqualToString:@"true"]) {
            NSMutableArray *log = [data objectForKey:@"result"];
            for (NSDictionary *logItem in log) {
                [logS addObject:[NSMutableDictionary dictionaryWithDictionary:logItem]];
            }
            [_project setObject:logS forKey:PROJECTKEY_LOG];
            _logs = logS;
            [self.logTableView reloadData];
            //记录定位
            [self recordLocation:_project];
        }
    }
    
    if(provider.tag == 20)//批后跟踪记录
    {
        
        NSMutableArray *phLogS = [NSMutableArray arrayWithCapacity:10];
        NSString *success = [data objectForKey:@"success"];
        if ([success isEqualToString:@"true"]) {
            NSMutableArray *log = [data objectForKey:@"result"];
            for (NSDictionary *logItem in log) {
                [phLogS addObject:[NSMutableDictionary dictionaryWithDictionary:logItem]];
            }
            [_project setObject:phLogS forKey:PROJECTKEY_PHLOG];
            NSLog(@"批后跟踪_____%@",phLogS);
            _phLogs = phLogS;
            [self.phLogTableView reloadData];
            
        }
        
    }
}


//收到数据执行的代理方法
-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    if(provider.tag==5){
        [self renameOnlinePhotoNameCompleted:[data isEqualToString:@"1"]];
    }
    if (provider.tag == 6) {
        [Global wait:nil];
        if([data isEqualToString:@"0"]){
            UIAlertView *saveAlert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"坐标保存失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [saveAlert show];
        }else{
            [self back];
        }
        
    }
    if (provider.tag == 7) {//_mapProviderLocation定位
        [self projectLocationForPoint:data];
        
    }
    if(provider.tag == 3)
    {
        
        
        
    }
    
    
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    if (provider.tag==1) {
        self.formActivityIndicator.hidden = YES;
        NSLog(@"form load faild!");
        [self onFormDataDidLoaded];
    }else if(provider.tag==2){
        self.materialActivityIndicator.hidden = YES;
        NSLog(@"material load faild!");
        [self onFormDataDidLoaded];
    }else if(provider.tag==4){
        NSLog(@"stopworkform load faild!");
        [self onFormDataDidLoaded];
    }else if(provider.tag==5){
        NSLog(@"rename photo faild!");
        [self renameOnlinePhotoNameCompleted:NO];
    }
    else if(provider.tag==6){
        NSLog(@"save projectLocation faild!");
        [Global wait:nil];
        UIAlertView *saveAlert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"保存坐标失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [saveAlert show];
    }
    else if(provider.tag==7){
        NSLog(@"projectLocation faild!");
    }
}


#pragma mark --- tableView 代理方法

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (tableView.tag==3) {
        UIView *headView = [[UIView alloc] init];
        headView.tag = section;
        headView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
        UILabel *tipLable =[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 30)];
        tipLable.text = @"监察记录";
        tipLable.textColor =[UIColor blackColor];
        [headView addSubview:tipLable];
        
        UIButton *addLogBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        addLogBtn.frame = CGRectMake(self.logTableView.frame.size.width-100, 0, 80, 30);
        [addLogBtn setTitle:@"添加巡查" forState:UIControlStateNormal];
        [addLogBtn addTarget:self action:@selector(newLog) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOrCloseHeader:)];
        //        [headView addGestureRecognizer:tap];
        [headView addSubview:addLogBtn];
        //
        return headView;
    }
    else  if (tableView.tag==30) {
        UIView *headView = [[UIView alloc] init];
        headView.tag = section;
        headView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
        
        
        UILabel *tipLable =[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 30)];
        tipLable.text = @"批后跟踪";
        tipLable.textColor =BLUECOLOR;
        [headView addSubview:tipLable];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOrCloseHeader:)];
        [headView addGestureRecognizer:tap];
        return headView;
    }
    else
        
        return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 3 || tableView.tag == 30) {
        return 30;
    }
    return 0.1;
}


- (void)openOrCloseHeader:(UITapGestureRecognizer *)tap
{
    UIView *tapView = tap.view;
    _openOrClose = !_openOrClose;
  __block CGRect webViewframe = self.formWebView.frame;
    __block CGRect logTbaleViewframe = self.logTableView.frame;
    __block CGRect phlogTbaleViewframe = self.phLogTableView.frame;
    CGFloat randowHeight = [self isDoubleRandom]?40:0;
//    webViewframe.size.height = 480;
        if (_openOrClose) {
            [UIView animateWithDuration:0.5 animations:^{
                
//                [_groupImgArray replaceObjectAtIndex:tapView.tag withObject:@"zhankai"];
                logTbaleViewframe.origin.y = 430+200;
                phlogTbaleViewframe.origin.y = 200+430;
//                CGRectMake(0, 430, 492, 280);
//                self.logTableView.frame=logTbaleViewframe;
                self.phLogTableView.frame  =phlogTbaleViewframe;
//                CGRectMake(0, 430, 492, 280);
                webViewframe.size.height = 320+200 + randowHeight;
                self.formWebView.frame = webViewframe;
                
            }];
        }
        else
        {
//            [_markArray replaceObjectAtIndex:tapView.tag withObject:@"0"];
            [UIView animateWithDuration:0.5 animations:^{
//                self.logTableView.frame=CGRectMake(0, 630, 492, 280);
//                self.phLogTableView.frame=CGRectMake(0, 630, 492, 280);
                logTbaleViewframe.origin.y = 430;
                phlogTbaleViewframe.origin.y = 430;
                //                CGRectMake(0, 430, 492, 280);
//                self.logTableView.frame = logTbaleViewframe;
                self.phLogTableView.frame  =phlogTbaleViewframe;
                //                CGRectMake(0, 430, 492, 280);
                webViewframe.size.height = 320 + randowHeight;
                self.formWebView.frame = webViewframe;

//                webViewframe.size.height = 320+200;
//                self.formWebView.frame = webViewframe;
//                [_groupImgArray replaceObjectAtIndex:tapView.tag withObject:@"xiangshang"];
            }];
            
        }

}

//新建巡查记录
- (void)newLog
{
    if([[_project objectForKey:@"hjjs"]isEqualToString:@"结束"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该项目已经结案,无法添加巡查" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    
    }else
    {
    BOOL isHaveNewJob = [[defaults objectForKey:@"isHaveNewJob"] boolValue];
    //已经有巡查
    if (isHaveNewJob)
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已有新建的巡查,您需要结束正在巡查再来添加新建!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alertView.tag = 100;
        [alertView show];
    }
    
    else {
        _addLogformSheet = [[MZFormSheetController alloc] initWithViewController:_newDailyJobViewController];
        //把某条记录传给弹出框
        _newDailyJobViewController.theProject = self.theProject;
        _newDailyJobViewController.theMatrialA =self.materials;
        _newDailyJobViewController.nOrCtitleLabe.text = @"添加巡查";
        _newDailyJobViewController.tipMessageLabl.text = @"是否添加新巡查";
        _addLogformSheet.view.backgroundColor =[UIColor colorWithWhite:0 alpha:0.2];
        
        _addLogformSheet.shouldDismissOnBackgroundViewTap = YES;
        //formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        _addLogformSheet.cornerRadius = 8.0;
        _addLogformSheet.portraitTopInset = 6.0;
        _addLogformSheet.landscapeTopInset = 80;
        _addLogformSheet.presentedFormSheetSize = CGSizeMake(300, 380);
        [_addLogformSheet presentAnimated:YES completionHandler:nil];
        
    }
    
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier = @"FormAndMaterialCellIdentifier";
    
    
    if (tableView.tag==1) {
        //表单
        /*
         FormAndMaterialCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
         if (nil == cell) {
         UINib *nib = [UINib nibWithNibName:@"FormAndMaterialCell" bundle:nil];
         [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
         }
         cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
         NSUInteger row = [indexPath row];
         NSMutableDictionary *theFormInfo = [[_project objectForKey:PROJECTKEY_FORMS] objectAtIndex:row];
         cell.form = theFormInfo;
         return cell;
         */
        
    }
    else if (tableView.tag==200) {//材料
        Materialcellcell *cell;
        if(cell==nil)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"Materialcellcell" owner:nil options:nil] lastObject];
        }
        NSString *name;
        NSString *temName;
        //区别文件夹和文件
        NSDictionary *dic = [_materials objectAtIndex:indexPath.row];
        NSArray *child =[dic objectForKey:@"files"];
        
        if([[dic objectForKey:@"type"]isEqualToString:@"directory"]) {
            
            name=[[_materials objectAtIndex:indexPath.row] valueForKey:@"group"];
            temName = [name stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            cell.icon.image = [UIImage imageNamed:@"fileicon.png"];
            NSArray *child =[dic objectForKey:@"files"];
            
            NSString *subName =[NSString stringWithFormat:@"%@(%ld)",temName,child.count];
            
            cell.contentLabel.text = subName;
            
        }
        else
        {
            name=[[_materials objectAtIndex:indexPath.row] valueForKey:@"group"];
            cell.contentLabel.text = name;
            //        cell.icon.image = [UIImage imageNamed:@"阅读量"];
            NSString *type = [dic objectForKey:@"fileExtension"];
            NSString *imageName ;
            if ([type isEqualToString:@""]) {
                imageName=@"filetype-folder48.png";
            }else if([type isEqualToString:@".png"]||[type isEqualToString:@".jpg"]||[type isEqualToString:@".JPG"]){
                imageName=@"pic icon";
            }else if([type isEqualToString:@".docx"] || [type isEqualToString:@".doc"]){
                imageName=@"filetype-word48.png";
            }else if([type isEqualToString:@".xlsx"] || [type isEqualToString:@".xls"]){
                imageName=@"filetype-excel48.png";
            }else if([type isEqualToString:@".pptx"] || [type isEqualToString:@".ppt"]){
                imageName=@"filetype-ppt48.png";
            }else{
                imageName=@"filetype-unknow48.png";
            }
            //根据材料类型加载不同的图片
            cell.icon.image = [UIImage imageNamed:imageName];
        }
        
        NSInteger lever =[[[_materials objectAtIndex:indexPath.row] valueForKey:@"level"] intValue];
        [cell setIndentationLevel:lever];
        if (MainR.size.width==320) {
            cell.indentationWidth = 20;
            
        }else
        {
            cell.indentationWidth = 10;
        }
        
        cell.nameHC.constant =[self returnCellHeight:name withLever:lever];
        float indentPoints = cell.indentationLevel * cell.indentationWidth;
        
        cell.contentView.frame = CGRectMake(indentPoints,cell.contentView.frame.origin.y,cell.contentView.frame.size.width - indentPoints,cell.contentView.frame.size.height);
        
        // NSLog(@"indentationLevel=%ld",(long)cell.indentationLevel);
        
        return cell;
        
        
    }
    
    else if (tableView.tag ==3)
    {
        
        //        {
        //            "id": "21",
        //            "pid": "76723",
        //            "xmmc": "测试批后管理增加1",
        //            "gczjl": "是",
        //            "xyjl": "是",
        //            "jsqk": "建设情况",
        //            "jcry": "监察人员",
        //            "jcsj": "2016/11/8 10:00:00"
        //        },
        
        
        
        Logcell *cell = [tableView dequeueReusableCellWithIdentifier:@"logCell"];
        if(cell==nil)
        {
            UINib *nib = [UINib nibWithNibName:@"Logcell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
            
        }
        NSDictionary *dic = [_logs objectAtIndex:indexPath.row];
        cell.time.text =[dic objectForKey:@"jcsj"];
        cell.titleLabel.text = [dic objectForKey:@"jsqk"];
        cell.operators.text =[dic objectForKey:@"jcry"];
        cell.xcmc.text = [dic objectForKey:@"xmmc"];
        if ([[dic objectForKey:@"xyjl"]isEqualToString:@"true"]||[[dic objectForKey:@"xyjl"]isEqualToString:@"已验线"]) {
            cell.ysTFlabel.text =@"已验线";
            [cell.ysTFlabel setTextColor:[UIColor colorWithRed:17.0/255.0 green:160/255.0 blue:91.0/255.0 alpha:1]];
            
        }else if([[dic objectForKey:@"xyjl"]isEqualToString:@""])
        {
            cell.ysTFlabel.text =@"";
        }
        else
        {
            cell.ysTFlabel.text =@"未验线";
            [cell.ysTFlabel setTextColor:[UIColor redColor]];
            
        }
        if ([[dic objectForKey:@"gczjl"]isEqualToString:@"true"]||[[dic objectForKey:@"gczjl"]isEqualToString:@"已取得"]) {
            cell.gczTFlabel.text =@"已取得工程证";
            [cell.gczTFlabel setTextColor:[UIColor colorWithRed:17.0/255.0 green:160/255.0 blue:91.0/255.0 alpha:1]];
            
        }
        else if([[dic objectForKey:@"gczjl"]isEqualToString:@""])
        {
         cell.gczTFlabel.text =@"";
        }
        else
            
        {
            cell.gczTFlabel.text =@"未取得工程证";
            [cell.gczTFlabel setTextColor:[UIColor redColor]];
            
        }
        return cell;
    }
    //批后跟踪tableView
    else if (tableView.tag == 30)
    {
        phLogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phlogCell"];
        if(cell==nil)
        {
            UINib *nib = [UINib nibWithNibName:@"phLogCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
            [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
            
        }
        NSDictionary *dic = [_phLogs objectAtIndex:indexPath.row];
        cell.time.text =[dic objectForKey:@"theoryEndTime"];
        cell.projectName.text = [dic objectForKey:@"projectName"];
        cell.location.text =[dic objectForKey:@"address"];
        
        return cell;
    }
    
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView.tag==1){
        //if (nil!=_project && nil!=_project.forms) {
        //    return  _project.forms.count;
        //}
    }else if (tableView.tag==200) {
        if(_ThelogClick)
        {
            return _materials.count;
        }
        else{
            if (nil!=_project) {
                NSMutableArray *materials = [_project objectForKey:PROJECTKEY_MATERIALS];
                if (nil!=materials) {
                    return materials.count;
                }
            }
        }
    }
    else if (tableView.tag == 3)//巡查记录
    {
        if(_ThelogClick)
        {
            return 1;
        }
        else{
            if (nil!=_project) {
                NSMutableArray *logS = [_project objectForKey:PROJECTKEY_LOG];
                if (nil!=logS) {
                    return logS.count;
                }
            }
        }
        
    }
    else if (tableView.tag == 30)//批后跟踪
    {
        if (nil!=_project) {
            NSMutableArray *phlogS = [_project objectForKey:PROJECTKEY_PHLOG];
            if (nil!=phlogS) {
                return phlogS.count;
            }
        }
        
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat adviceH;
    //    NSMutableArray *materials = [_project objectForKey:PROJECTKEY_MATERIALS];
    
    if (tableView.tag ==200) {
        NSDictionary *dic = [_materials objectAtIndex:indexPath.row];
        NSString *name;
        if([[dic objectForKey:@"type"] isEqualToString:@"directory"]) {
            name =[dic objectForKey:@"group"];
            
        }
        else
        {
            name =[dic objectForKey:@"group"];
        }
        
        NSInteger lever= [[[_materials objectAtIndex:indexPath.row] valueForKey:@"level"] intValue];
        adviceH= [self returnCellHeight:name withLever:lever]+10;
        
        
    }
    else if (tableView.tag == 3)
    {
        
        adviceH = 120;
    }
    else if (tableView.tag == 30)
    {
        
        adviceH = 80;
    }
    
    return adviceH;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==1) {
        [self showForm:[indexPath row]];
    }else if(tableView.tag == 200){
        
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSLog(@"section=%ld,row=%ld",(long)indexPath.section,(long)indexPath.row);
        
        NSDictionary *dic = [_materials objectAtIndex:indexPath.row];
        if([dic valueForKey:@"files"])
        {
            NSArray *array = [dic valueForKey:@"files"];
            
            BOOL isAlreadyInserted = NO;
            
            for(NSDictionary *dInner in array)
            {
                NSInteger index=[_materials indexOfObjectIdenticalTo:dInner];
                //NSLog(@"index = %ld",(long)index);
                isAlreadyInserted = (index>0 && index!=NSIntegerMax);
                if(isAlreadyInserted)
                    
                    break;
            }
            
            if(isAlreadyInserted)
            {
                [self miniMizeThisRows:array];
            }
            else
            {
                NSUInteger count = indexPath.row+1;
                NSMutableArray *cellArr = [NSMutableArray array];
                for(NSDictionary *inDic in array)
                {
                    [cellArr addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                    [_materials insertObject:inDic atIndex:count++];
                }
                [tableView insertRowsAtIndexPaths:cellArr withRowAnimation:UITableViewRowAnimationBottom];
            }
            
        }
        else
        {
            NSString *str=[dic valueForKey:@"group"];
            NSLog(@"str = %@",str);
            //            FileViewController *fvc = [[FileViewController alloc]init];
            
            NSDictionary *dic =[_materials objectAtIndex:indexPath.row];
            NSString *name =  [dic objectForKey:@"group"];
            NSString *identity =[dic objectForKey:@"groupid"];
            NSString *ext =[dic objectForKey:@"fileExtension"];
            NSString *fileId = [NSString stringWithFormat:@"%@_%@",name,identity];
            NSString *downloadUrl = [NSString stringWithFormat:@"%@?type=smartplan&action=downloadmaterial&fileId=%@",[Global serviceUrl],identity];
            [self.delegate openMaterial:name path:downloadUrl ext:ext fromLocal:NO];
            
            
        }
        [self.materialTable reloadData];
        
    }
    else if (tableView.tag ==3)//巡查记录
    {if(_ThelogClick)//如果是打开某次/条巡查看看详情,则不能继续跳转
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else
    {
        
        NSDictionary *dic = [_logs objectAtIndex:indexPath.row];
        MapJobViewController *mapj=[[MapJobViewController alloc] init];
        [mapj loadbaseProjectWithpid:[dic objectForKey:@"pid"] andTime:[dic objectForKey:@"jcsj"]withDict:dic];
        //巡查记录
        mapj.xclog = YES;
        mapj.zjxcLog = YES;
        mapj.delegate = self;
        [[self viewController] presentViewController:mapj animated:YES completion:^{
            
        }];
    }
        
    }
    else if(tableView.tag == 30)
    {
        NSDictionary *dic = [_phLogs objectAtIndex:indexPath.row];
        MapJobViewController *mapj=[[MapJobViewController alloc] init];
        //        [mapj loadbaseProjectWithpid:[dic objectForKey:@"pid"] andTime:[dic objectForKey:@"jcsj"]];
        //非巡查记录(筛的是批后跟踪件)
        mapj.xclog = NO;
        //在建巡查的跳转过来的
        mapj.zjxcLog = YES;
        mapj.delegate = self;
        mapj.projectID = [dic objectForKey:@"projectId"];
        mapj.project = dic;
        //        mapj.delegate = self;
        mapj.type = @"Wfxm";
        [[self viewController] presentViewController:mapj animated:YES completion:^{
            
        }];
        
        
        
    }
}


#pragma Mark- MapJobViewControllerDelegate代理

-(void)mapJobViewShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext{
    //    [self.delegate mapShouldShowFile:name path:path ext:ext];
    
    [self.delegate openMaterial:name path:path ext:ext fromLocal:NO];
}

-(void)mapJobViewShouldShowFiles:(NSArray *)materials at:(int)index{
    //    [self.delegate mapShouldShowFiles:materials at:index];
    [self.delegate openMaterial:materials at:index];
}

//找到view的控制器：返回view所加载在的控制器

- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)loadbaseProjectWithpid:(NSString *)pid andTime:(NSString *)time
{
    
    //根据记录获取基本信息
    //58.246.138.178:8040/KSYDService/ServiceProvider.ashx?type=smartplan&action=projectbaseinfo&projectId=87668
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *date =[formatter dateFromString:time];
    //        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //        _xcLogTime = [formatter stringFromDate:date];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"type"] = @"smartplan";
    parameters[@"action"]=@"projectbaseinfo";
    parameters[@"projectId"]=pid;
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    NSLog(@"加载项目信息%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            
            [MBProgressHUD showSuccess:@"项目基本信息获取成功" toView:self];
            NSArray *arr= [rs objectForKey:@"result"];
            if(arr.count>0)
            {
                NSDictionary *dict =[rs objectForKey:@"result"][0];
                _project = dict;
                NSMutableDictionary *muldic = [NSMutableDictionary dictionaryWithDictionary:dict];
                //                        _projectID = [dict objectForKey:@"projectId"];
                [self loadProject:muldic typeName:@"Wfxm"];
                
            }
            //                [self loadData];
            else
            {
                //                        [self.navigationController popViewControllerAnimated:YES];
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"无法获取项目信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                
            }
        }
        else
        {
            [MBProgressHUD showError:@"项目基本信息获取成功" toView:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"项目基本信息获取成功" toView:self];
    }];
    
    
    
}



//利用字典生成json字符串
-(NSString *)formJsonFromDictionary:(NSMutableArray *)formDefine{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:formDefine options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return json;
    /*
     NSMutableString *json = [NSMutableString stringWithCapacity:100];
     NSString *split = @"";
     [json appendString:@"["];
     for (int i=0; i<formDefine.count; i++) {
     [json appendString:split];
     NSMutableDictionary *formItem = [formDefine objectAtIndex:i];
     NSArray *keys = formItem.allKeys;
     NSString *split2 = @"";
     [json appendString:@"{"];
     for (int j=0; j<keys.count; j++) {
     NSString *theKey = [keys objectAtIndex:j];
     [json appendString:split2];
     [json appendString:theKey];
     [json appendString:@":\""];
     [json appendString:[formItem objectForKey:theKey]];
     [json appendString:@"\""];
     split2=@",";
     }
     [json appendString:@"}"];
     split=@",";
     }
     [json appendString:@"]"];
     return json;*/
}

//显示表单
-(void)showForm:(int)formIndex{
    self.btnFormName.hidden = NO;
    //保存选中的index
    formSelectIndex=formIndex;
    NSMutableArray *forms = [_project objectForKey:PROJECTKEY_FORMS];
    for (int i=0;i< forms.count;i++) {
        NSMutableDictionary *theForm = [forms objectAtIndex:i];
        if (i==formIndex) {
            //            [self.btnFormName setTitle:[theForm objectForKey:@"name"] forState:UIControlStateNormal];
            //            NSString *script =[NSString stringWithFormat:@"window.createFormPanel(%@)", [self formJsonFromDictionary:[theForm objectForKey:@"detail"]]];
            //            NSLog(@"创建表单传数据_%@",script);
            //            // 表单
            //            [self.formWebView stringByEvaluatingJavaScriptFromString:script];
            //
            //        }
            //    }
            _formIdentity = [theForm objectForKey:@"identity"];
            
            if(!_isSP)
            {
            ////获取表单详情信息
            
            _formDetailProvider = [ServiceProvider initWithDelegate:self];
            _formDetailProvider.tag = 8;
            //隐藏按钮(编辑表单/发送/提交/取消编辑按钮)
            self.viewOperation.hidden = YES;
            //显示表单部分的菊花
            self.formActivityIndicator.hidden=NO;
            
               NSString* path = [[NSBundle mainBundle] pathForResource:@"form" ofType:@"htm"];
               NSURL *url= [NSURL fileURLWithPath:path];
               NSURLRequest *request =[NSURLRequest requestWithURL:url];
                [self.formWebView loadRequest:request];
            //          ervice/serviceprovider.ashx?type=smartplan&action=formdetail&user=181&project=76002&form=3445
            [_formDetailProvider getData:@"smartplan" parameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"formdetail",@"action", [_project objectForKey:@"projectId"],@"project",[theForm objectForKey:@"identity"],@"form",[Global currentUser].userid,@"user",nil]];
                
                
            }
            else
            {
            
                NSString *urlStr=[NSString stringWithFormat:@"%@?type=formpage&r=%f",[Global serviceUrl],roundf(3.1415)];
                NSURL * url =[NSURL URLWithString:urlStr];
             NSURLRequest  *request =[NSURLRequest requestWithURL:url];
                [self.formWebView loadRequest:request];
                self.formWebView.scalesPageToFit=YES;
                _formIdentity = [theForm objectForKey:@"identity"];
            }
            [self.btnFormName setTitle:[theForm objectForKey:@"name"] forState:UIControlStateNormal];
        }
    }
}

//webView代理方法
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    if(_isSP)
    {
    
    NSString *str =[NSString stringWithFormat:@"window.loadForm('%@','%@','%@')",[Global currentUser].userid,[_project objectForKey:@"projectId"],_formIdentity];
    self.formWebView.scalesPageToFit=YES;
    
    
    [self.formWebView stringByEvaluatingJavaScriptFromString:str];
    }
    
    
}

//点击材料cell,显示材料内容
-(void)showFile:(int)materialIndex{
    
    NSMutableArray *materials = [_project objectForKey:PROJECTKEY_MATERIALS];
    //显示材料数据中某行数据
    NSMutableDictionary *g=[materials objectAtIndex:materialIndex];
    NSMutableArray *files = [g objectForKey:@"files"];
    _reOpenMaterialSheet = NO;
    if (files.count==0) {
        return;
    }else if(files.count==1){
        NSMutableDictionary *matInfo=[files objectAtIndex:0];
        NSString *materialDownPath = [NSString stringWithFormat:@"%@?type=material&fid=%@",[Global serviceUrl],[matInfo objectForKey:@"id"]];
        [self.delegate openMaterial:[matInfo objectForKey:@"name"] path:materialDownPath ext:[matInfo objectForKey:@"fileExtension"] fromLocal:NO];
    }else{//有多个材料
        if(_materialGroupSelector==nil)
            _materialGroupSelector = [[MaterialSelectorViewController alloc] init];
        _materialGroupSelector.files = files;
        _materialGroupSelector.projectId=[_project objectForKey:PROJECTKEY_ID];
        _materialGroupSelector.delegate = self;
        formSheet = [[MZFormSheetController alloc] initWithViewController:_materialGroupSelector];
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.cornerRadius = 8.0;
        formSheet.portraitTopInset = 6.0;
        formSheet.landscapeTopInset = 150;
        formSheet.presentedFormSheetSize = CGSizeMake(300, 400);
        [formSheet presentAnimated:YES completionHandler:nil];
    }
    
}

-(void)fileViewClosed{
    if (_reOpenMaterialSheet) {
        formSheet = [[MZFormSheetController alloc] initWithViewController:_materialGroupSelector];
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.cornerRadius = 8.0;
        formSheet.portraitTopInset = 6.0;
        formSheet.landscapeTopInset = 150;
        formSheet.presentedFormSheetSize = CGSizeMake(300, 400);
        [formSheet presentAnimated:NO completionHandler:nil];
    }
}

#pragma mark -MaterialSelectorDelegate(点击材料cell后有超过一个材料)代理方法

-(void)materialSelected:(NSString *)projectId fileId:(NSString *)fileId extension:(NSString *)extension fileName:(NSString *)Name{
    NSString *fileName=[projectId stringByAppendingFormat:@"_%@.%@",fileId,extension];
    NSString *fileNamePath=nil;
    NSString *userProjectPath=[Global currentUser].userProjectPath;
    NSString *projectDirectory = [userProjectPath stringByAppendingPathComponent:projectId];
    fileNamePath=[projectDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileNamePath]) {
        //文件如果已经存在，打开本地文件
        [self.delegate openMaterial:Name path:fileNamePath ext:extension fromLocal:YES];
        //[self.controller showPhoto:Name path:fileNamePath];
    }else{
        //打开在线文件
        NSString *materialDownPath = [NSString stringWithFormat:@"%@?type=material&fid=%@",[Global serviceUrl],fileId];
        [self.delegate openMaterial:Name path:materialDownPath ext:extension fromLocal:NO];
    }
    
    //关闭材料列表
    [formSheet dismissAnimated:NO completionHandler:nil];
    _reOpenMaterialSheet = YES;
}



#pragma mark- FormSelectorDelegate代理方法---表单 选择器
-(void)formSelected:(NSInteger)rowIndex{
    //显示表单
    [self showForm:rowIndex];
    
    NSMutableDictionary *p=[[_project objectForKey:PROJECTKEY_FORMS] objectAtIndex:formSelectIndex];
    //self.btnFormName.titleLabel.text=p.name;
    [_btnFormName setTitle:[p objectForKey:@"name"] forState:UIControlStateNormal];
    [formSheet dismissAnimated:YES completionHandler:nil];
}


-(IBAction)onStopworkMenuItemTap:(id)sender{
    [self showStopworkForm];
}

- (IBAction)onDownLoadItemTap:(id)sender {
    /*
     NSFileManager *fm=[NSFileManager defaultManager];
     NSString *projectID=[_project projectId];
     NSString *userProjectPath=[Global currentUser].userProjectPath;
     NSString *projectDirectory = [userProjectPath stringByAppendingPathComponent:projectID];
     [fm createDirectoryAtPath:projectDirectory withIntermediateDirectories:YES attributes:nil error:nil];
     NSString *saveName=nil;
     //将当前对象，存入本地文件
     [NSKeyedArchiver archiveRootObject:_project toFile:[projectDirectory stringByAppendingString:@"/projectInfo.archive"]];
     ProjectInfo *pp=[[ProjectInfo alloc] init];
     pp=[NSKeyedUnarchiver unarchiveObjectWithFile:[projectDirectory stringByAppendingString:@"/projectInfo.archive"]];
     
     for (int i=0;i<_project.materials.count; i++) {
     //创建项目文件夹
     //NSFileManager *fm=[NSFileManager defaultManager];
     //NSString *userProjectPath=[Global currentUser].userProjectPath;
     //projectID=[_project projectId];
     //         NSString *projectDirectory = [userProjectPath stringByAppendingPathComponent:projectID];
     if ([fm fileExistsAtPath:projectDirectory]==NO) {
     [fm createDirectoryAtPath:projectDirectory withIntermediateDirectories:YES attributes:nil error:nil];
     }
     
     MaterialGroupInfo *matGroupInfo=[_project.materials objectAtIndex:i];
     for (int i=0; i<matGroupInfo.files.count; i++) {
     MaterialInfo *matInfo=[matGroupInfo.files objectAtIndex:i];
     NSString *fid=[matInfo materialId];
     NSLog(@"%@",fid);
     
     FileDownload *downTask=[[FileDownload alloc] init];
     downTask.delegate=self;
     
     NSString *path=[NSString stringWithFormat:@"%@?type=material&fid=%@",[Global serviceUrl],fid];
     saveName=[projectID stringByAppendingFormat:@"_%@",fid];
     downLoad=YES;
     self.lblDownStatus.hidden=NO;
     self.lblDownStatus.text=@"正在下载...";
     [downTask download:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] fileId:saveName fileExt:[matInfo extension]];
     }
     
     }
     //    if (downLoad) {
     self.lblDownStatus.text=@"下载完成";
     self.btnRemove.enabled=YES;
     float floatProjectSize=[self folderSizeAtPath:_projectPath];
     NSString *stringProjectSize=[NSString stringWithFormat:@"%.1fkb",floatProjectSize];
     NSMutableDictionary *dicPro=[[NSMutableDictionary alloc] init];
     [dicPro setValue:[_project projectId] forKey:@"id"];
     [dicPro setValue:[_project name] forKey:@"name"];
     [dicPro setValue:[_project projectCode] forKey:@"code"];
     [dicPro setValue:[_project address] forKey:@"address"];
     [dicPro setValue:[_project time] forKey:@"time"];
     [dicPro setValue:@"100" forKey:@"downPersent"];
     [dicPro setValue:_type forKey:@"type"];
     [dicPro setValue:stringProjectSize forKey:@"size"];
     
     
     NSMutableArray *arrProList=nil;
     arrProList=[NSMutableArray arrayWithContentsOfFile:[userProjectPath stringByAppendingPathComponent:@"projectList.plist"]];
     if (arrProList ==nil) {
     arrProList=[[NSMutableArray alloc] init];
     }
     if (![arrProList containsObject:dicPro]) {
     [arrProList addObject:dicPro];
     }
     
     [arrProList writeToFile:[userProjectPath stringByAppendingPathComponent:@"projectList.plist"] atomically:YES];
     
     NSMutableArray *arr2=[NSMutableArray arrayWithContentsOfFile:[userProjectPath stringByAppendingPathComponent:@"projectList.plist"]];
     
     NSLog(@"dicPro is :%@",arr2);
     //    }
     */
}


//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex==1) {
//        [self fileRemove];
//    }
//}

-(void)fileRemove{
    /*
     NSString *userProjectPath=[Global currentUser].userProjectPath;
     //移除本地projectList集合中对应的项目
     NSMutableArray *arrProjectList=[NSMutableArray arrayWithContentsOfFile:[userProjectPath stringByAppendingPathComponent:@"projectList.plist"]];
     for (NSMutableDictionary *item in arrProjectList) {
     if ([[item objectForKey:@"id"] isEqualToString:[_project projectId]]) {
     [arrProjectList removeObject:item];
     break;
     }
     }
     [arrProjectList writeToFile:[userProjectPath stringByAppendingPathComponent:@"projectList.plist"] atomically:YES];
     
     NSMutableArray *arr2=[NSMutableArray arrayWithContentsOfFile:[userProjectPath stringByAppendingPathComponent:@"projectList.plist"]];
     
     NSLog(@"dicPro is :%@",arr2);
     
     //移除该项目下所有本地文件
     NSString *projectDic=[userProjectPath stringByAppendingPathComponent:_project.projectId];
     NSFileManager *fileManager=[NSFileManager defaultManager];
     [fileManager removeItemAtPath:projectDic error:nil];
     baseAlert = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"移除完成"  delegate:self cancelButtonTitle:nil  otherButtonTitles: nil];
     [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector: @selector(performDismiss:)  userInfo:nil repeats:NO];
     [baseAlert show];
     self.lblDownStatus.hidden=YES;
     self.lblDownStatus.text=@"";
     */
}

- (IBAction)onRemoveItemTap:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认移除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView show];
    
}


//点击编辑表单按钮方法
- (IBAction)onModifyFormDetail:(id)sender {
    //设置按钮显示
    self.btnModifyFormDetail.hidden=YES;
    self.btnDoFormDetail.hidden=NO;
    self.btnCancelFormDetail.hidden=NO;
    self.btnSend.hidden = YES;
    
    [self.formWebView stringByEvaluatingJavaScriptFromString:@"window.switchView(0)"];
}

//点击发送按钮
- (IBAction)onBtnSendTap:(id)sender {
    FormSendViewController *fsv = [[FormSendViewController alloc] initWithNibName:@"FormSendViewController" bundle:nil];
    fsv.projectId = [_project objectForKey:PROJECTKEY_ID];
    fsv.delegate = self;
    MZFormSheetController *fs = [[MZFormSheetController alloc] initWithViewController:fsv];
    fs.shouldDismissOnBackgroundViewTap = NO;
    fs.cornerRadius = 8.0;
    fs.portraitTopInset = 6.0;
    fs.landscapeTopInset = 150;
    fs.presentedFormSheetSize = CGSizeMake(320, 450);
    [fs presentAnimated:YES completionHandler:nil];
}


#pragma  mark- FormSendCompletedDelegate 代理方法
//点击发送,发送结束时调用代理方法(弹出版)
-(void)formSendCompleted{
    [self.delegate shouldReLoadList];
}

//点击提交按钮执行的方法
- (IBAction)onDoFormDetail:(id)sender {
    [self.formWebView stringByEvaluatingJavaScriptFromString:@"window.createSaveXml()"];
}

//取消修改点击时执行的方法
- (IBAction)onCancelFormDetail:(id)sender {
    //编辑表单按钮(显示)
    self.btnModifyFormDetail.hidden=NO;
    //self.btnSend.hidden = NO;
    //判断是否是违法案件(需要显示定位按钮)
    //    if ([_type isEqualToString:@"Wfxm"]) {
    //        self.btnLocation.hidden = NO;
    ////        self.btnSend.hidden = YES;
    //    }
    //    else{//非违法按钮
    //        self.btnLocation.hidden = YES;
    ////        self.btnSend.hidden = NO;
    //    }
    //            self.btnSend.hidden = NO;
    
    //提交按钮(隐藏)
    self.btnDoFormDetail.hidden=YES;
    //取消按钮(隐藏)
    self.btnCancelFormDetail.hidden=YES;
    
    [self.formWebView stringByEvaluatingJavaScriptFromString:@"window.switchView(1)"];
}



//点击表单名字,更换表单(表单选择)
- (IBAction)onFormList:(id)sender {
    //    if(_formSelector==nil)
    //    {
    //表单选择器
    _formSelector = [[FormSelectorViewController alloc] init];
    _formSelector.formsList=[_project objectForKey:PROJECTKEY_FORMS];
    _formSelector.delegate=self;
    formSheet = [[MZFormSheetController alloc] initWithViewController:_formSelector];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    //formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 8.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 150;
    formSheet.presentedFormSheetSize = CGSizeMake(300, 400);
    /*
     formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
     presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
     };*/
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
    
    //    }
}

- (IBAction)onBtnDeletePhotoTap:(id)sender {
    UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要移除该照片吗？" delegate:self cancelButtonTitle:@"移除照片" otherButtonTitles:@"取消", nil];
    comfirm.tag=2;
    [comfirm show];
}

-(BOOL)checkNewPhotoName:(NSString *)newName{
    for (NSMutableDictionary *p in _allPhotos) {
        NSString *n = [p objectForKey:@"name"];
        if ([n isEqualToString:newName]) {
            return NO;
        }
    }
    return YES;
}

//点击重命名照片
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

#pragma mark  -MapLocationDelegate 地图定位代理方法
//点击地图上返回按钮
-(void)back{
    _mapLocationView.hidden = YES;
    self.btnLocation.selected = NO;
    [self clearGraphics];
}
//MapLocationDelegate
-(void)saveProjectLocation{
    NSString *projectID = [_project objectForKey:PROJECTKEY_ID];
    //    NSString *projectLocation = [_mapLocationView getProjectLocation];
    if (_mapProvider == nil) {
        _mapProvider = [ServiceProvider initWithDelegate:self];
        _mapProvider.tag=6;
    }
    [Global wait:@"请稍后..."];
    //    [_mapProvider getString:@"zf" parameters:[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"projectlocation",@"action",projectID,@"ProjectID",projectLocation,@"projectLocation", nil]];
    
}


//收到数据后执行的---定位
-(void)projectLocationForPoint:(NSString *)projectLocation{
    if ([projectLocation length]==0) {
        projectLocation = @"0,0";
    }
    //在地图上定位数据
    //    [_mapLocationView projectLocationForGPS:projectLocation];
}


//定位按钮点击方法
-(IBAction)onBtnLationProject:(id)sender{
    
    if(_mapLocationView==nil){
        _mapLocationView = [[MapLocationView alloc]init];
        if(self.jumpfromMap)
        {
            _mapLocationView.frame =CGRectMake(0, 100, 794, 615);
        }
        else
        {
            _mapLocationView.frame=CGRectMake(0, 100, 732, 615);
        }
        _mapLocationView.delegate = self;
        [self addSubview:_mapLocationView];
        _mapLocationView.hidden = YES;
    }
    
    if (_mapLocationView.hidden) {
        _mapLocationView.hidden = NO;
        self.btnLocation.selected = YES;
        [_mapLocationView clearGraphic];
        //设置请求
        if (_mapProviderLocation == nil) {
            _mapProviderLocation = [ServiceProvider initWithDelegate:self];
            _mapProviderLocation.tag=7;
        }
        //NSString *projectID = [_project objectForKey:PROJECTKEY_ID];
        //[_mapProviderLocation getString:@"zf" parameters:[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getprojectlocation",@"action",projectID,@"ProjectID", nil]];
        
        /*
         //字段这里面取
         NSString *xmbh = [_project objectForKey:PROJECTKEY_XMBH];
         NSMutableArray *locationSite =[NSMutableArray array];
         for (NSDictionary *dict in [_project objectForKey:PROJECTKEY_LOG]) {
         if (![[dict objectForKey:@"x"] isEqualToString:@""]&&![[dict objectForKey:@"y"]isEqualToString:@""]) {
         //自己加哈
         [locationSite addObject:@""];
         }
         
         }
         
         NSNumber *layerid = [KSJZHXID objectAtIndex:0];
         NSString *ulrStr = [NSString stringWithFormat:@"%@%@",KSJZHX,layerid];
         [self projectLocation:xmbh andURL:[NSURL URLWithString:ulrStr]];
         */
        [self recordLocation:_project];
    }
    else{
        _mapLocationView.hidden = YES;
        self.btnLocation.selected = NO;
        [self clearGraphics];
    }
    
    //_mapLocationView 方法
    [_mapLocationView activeSaveBtn:NO];
    //隐藏照片view和照片按钮选择
    self.photoView.hidden = YES;
    self.btnPhotos.selected = NO;
    //隐藏停工单
    [self hideStopworkForm];
}

//打开照片
- (IBAction)onBtnOpenPhotoList:(id)sender {
    _btnGetPhoto.hidden = YES;
    _btnRenamePhoto.hidden = YES;
    _btnDeletePhoto.hidden = YES;
    _btnSubmitPhoto.hidden = YES;
    if (self.btnPhotos.selected) {
        [self onBtnClosePhotoList:nil];
    }else{
        if (!_photoThumbCreated) {
            [self createThumbPhotos];
        }
        _photoThumbCreated = YES;
        self.photoView.hidden = NO;
        self.btnPhotos.selected = YES;
        [self hideStopworkForm];
        [self hideMapForm];
    }
}

- (IBAction)onBtnClosePhotoList:(id)sender {
    self.photoView.hidden = YES;
    self.btnPhotos.selected = NO;
}


//清除绘制图层
-(void)clearGraphics{
    [_mapLocationView.pictureGraphicsLayer removeAllGraphics];
    [_mapLocationView.geomeryGraphicsLayer removeAllGraphics];
    _isAdded = NO;
    [_mapLocationView.callout dismiss];
    [_mapLocationView zoomfull];
    
    _xmin = DBL_MAX;
    _ymin = DBL_MAX;
    _xmax = -DBL_MAX;
    _ymax = -DBL_MAX;
}


-(void)recordLocation:(NSDictionary*)project {
    if (!project) {
        return;
    }
    //项目编号”“案卷编号”项目名称“建设单位”“建设地址”
    NSString *xmbh = [project objectForKey:PROJECTKEY_XMBH];
    NSString *slbh = [project objectForKey:PROJECTKEY_SLBH];
    NSString *name = [project objectForKey:PROJECTKEY_NAME];
    NSString *company = [project objectForKey:PROJECTKEY_COMPANY];
    NSString *address = [project objectForKey:PROJECTKEY_ADDRESS];
    
    NSMutableDictionary* attr = [NSMutableDictionary dictionary];
    [attr setObject:xmbh forKey:@"项目编号"];
    [attr setObject:slbh forKey:@"案卷编号"];
    [attr setObject:name forKey:@"项目名称"];
    [attr setObject:company forKey:@"建设单位"];
    [attr setObject:address forKey:@"建设地址"];
    
    NSArray *records = [project objectForKey:PROJECTKEY_LOG];
    [self createPictureGraphic:records andAttribute:attr];
}


-(void)createPictureGraphic:(NSArray*)records andAttribute:(NSDictionary*)attr {
    
    NSMutableArray* results = [NSMutableArray array];
    
    for (NSDictionary* dict in records) {
        CGFloat x = [(NSString*)[dict objectForKey:@"x"] floatValue];
        CGFloat y = [(NSString*)[dict objectForKey:@"y"] floatValue];
        if (x > 0 && y > 0) {
            AGSPoint *pt = [AGSPoint pointWithX:x y:y spatialReference:_mapLocationView.spatialReference];
            
            [results addObject:pt];
            
            [self getExtentOfSearchResult:pt];
            
            AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"location.png"];
            
            AGSGraphic *graphicGeom = [AGSGraphic graphicWithGeometry:pt symbol:graphicSymbol attributes:attr];
            [_mapLocationView.geomeryGraphicsLayer addGraphic:graphicGeom];
        }
    }
    
    if (results.count > 1) {
        
        //get geometry extent
        AGSEnvelope *extent = [AGSEnvelope envelopeWithXmin:_xmin ymin:_ymin xmax:_xmax ymax:_ymax spatialReference:_mapLocationView.spatialReference];
        
        //location extent
        [_mapLocationView zoomToEnvelope:extent animated:YES];
    } else if (results.count == 1) {
        AGSPoint *pt = [results objectAtIndex:0];
        //[_mapLocationView zoomToGeometry:pt withPadding:500 animated:YES];
        [_mapLocationView zoomToResolution:10.0 withCenterPoint:pt animated:YES];
    } else {
        [_mapLocationView zoomfull];
    }
}







//根据项目编号，进行保存位置
-(void)projectLocation:(NSString*)xmbh andURL:(NSURL*) url{
    
    if (self.queryTask == nil) {
        //set up query task against layer, specify the delegate
        self.queryTask = [AGSQueryTask queryTaskWithURL:url];
        self.queryTask.delegate = self;
    }
    
    if (self.query == nil) {
        //return all fields in query
        self.query = [AGSQuery query];
        self.query.outFields = [NSArray arrayWithObjects:@"*", nil];
        self.query.outSpatialReference = _mapLocationView.spatialReference;
        self.query.returnGeometry=YES;
    }
    
    self.query.where = [[@"XMBH='" stringByAppendingString:xmbh] stringByAppendingString:@"'"];
    
    [self.queryTask executeWithQuery:self.query];
}

#pragma mark -AGSQueryTaskDelegate代理方法
- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation*)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {
    if([featureSet.features count]>0){
        NSDictionary *filedAliases = featureSet.fieldAliases;
        for (AGSGraphic *feature in featureSet.features) {
            //判断是否有图形
            if (feature.geometry) {
                
                //别名属性
                NSDictionary *aliasAttributes = [self replaceAlias:filedAliases att:[feature allAttributes]];
                
                [self getExtentOfSearchResult:feature.geometry];
                
                if (!_isAdded) {
                    //定位图标
                    AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"location.png"];
                    AGSGraphic *graphicPic = [AGSGraphic graphicWithGeometry:feature.geometry.envelope.center symbol:graphicSymbol attributes:aliasAttributes];
                    
                    [_mapLocationView.pictureGraphicsLayer addGraphic:graphicPic];
                    _isAdded = YES;
                }
                
                //图形样式
                AGSSimpleFillSymbol *fillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
                fillSymbol.color = [[UIColor darkGrayColor] colorWithAlphaComponent:0.2];
                fillSymbol.outline.color = [UIColor redColor];
                fillSymbol.outline.width = 3.0;
                AGSGraphic *graphicGeom = [AGSGraphic graphicWithGeometry:feature.geometry symbol:fillSymbol attributes:aliasAttributes];
                [_mapLocationView.geomeryGraphicsLayer addGraphic:graphicGeom];
            }
            
        }
        
        //get geometry extent
        AGSEnvelope *extent = [AGSEnvelope envelopeWithXmin:_xmin ymin:_ymin xmax:_xmax ymax:_ymax spatialReference:_mapLocationView.spatialReference];
        
        //location extent
        [_mapLocationView zoomToEnvelope:extent animated:YES];
    }  else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"未找到相关项目"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation*)op didFailWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

/**
 计算搜索结果的范围
 */
- (void) getExtentOfSearchResult:(AGSGeometry*) geometry {
    if (geometry.envelope.xmin < _xmin) {
        _xmin = geometry.envelope.xmin;
    }
    
    if (geometry.envelope.xmax > _xmax) {
        _xmax = geometry.envelope.xmax;
    }
    
    if (geometry.envelope.ymin < _ymin) {
        _ymin = geometry.envelope.ymin;
    }
    
    if (geometry.envelope.ymax > _ymax) {
        _ymax = geometry.envelope.ymax;
    }
}

- (NSMutableDictionary *)replaceAlias:(NSDictionary *)fieldAliases att:(NSDictionary *)attributes {
    NSMutableDictionary *newAttributes = [[NSMutableDictionary alloc] init];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
        NSString *alias = [fieldAliases objectForKey:key];
        if (alias) {
            [newAttributes setObject:obj forKey:alias];
        }
    }];
    
    return newAttributes;
}


#pragma mark -webViie代理方法
//准备加载内容时调用的方法，通过返回值来进行是否加载的设置
/**
 提示：如果 OC 的代理方法要求返回 BOOL，程序直接返回 YES，通常一切正常，NO就是不工作！
 
 参数
 1. webView
 2. request：加载页面的请求
 3. navigationType: 浏览的类型，例如：在新窗口中打开链接
 */
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *requestString = [[request URL] absoluteString];
    //    file:///var/containers/Bundle/Application/D8C63B31-B108-4CE7-A4BA-DB9A4D5FF763/zzzf.app/form.htm
    //    command::::datepick:::2014-07-01
    NSArray *commandInfo=[requestString componentsSeparatedByString:@"::::"];
    if(commandInfo !=nil &&[commandInfo count]>1){
        NSLog(@"get commands-->%@",requestString);
        NSString *commandFlag = [commandInfo objectAtIndex:0];
        if ([commandFlag isEqualToString:@"command"]) {
            for (int i=1;i<commandInfo.count;i++) {
                NSArray *commandArguments = [[commandInfo objectAtIndex:i] componentsSeparatedByString:@":::"];
                NSString *commandName = [commandArguments objectAtIndex:0];
                if([commandName isEqualToString:@"save"]){
                    //修改数据前的一段
                    NSArray *data=[[commandArguments objectAtIndex:1] componentsSeparatedByString:@"::"];
                    //保存json数据
                    [self save:[[data objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] json1:[[data objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }else if([commandName isEqual:@"datepick"]){
                    [self showDatePicker:[commandArguments objectAtIndex:1]];
                }
            }
        }
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

//提交按钮保存json数据(::后数据)
-(void) save:(NSString *)json json1:(NSString *)json1{
    if ([json isEqualToString:@"-"]) {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"表单还没有做任何修改，无需提交" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        //[alert show];
        [self onCancelFormDetail:self.btnCancelFormDetail];
        return;
    }
    _newFormJson = json1;
    
    
    DataPostman *postman = [[DataPostman alloc] init];
    
    NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithCapacity:3];
    //    [postData setObject:json forKey:@"data"];
    //    [postData setObject:[_project objectForKey:PROJECTKEY_ID] forKey:@"project"];
    //    [postData setObject:[[Global currentUser] userid] forKey:@"user"];
    //    [postData setObject:@"save" forKey:@"action"];
    //    [postData setObject:@"smartplan" forKey:@"type"];
    [postData setObject:json forKey:@"xml"];
    [postData setObject:[_project objectForKey:PROJECTKEY_ID] forKey:@"projectId"];
    [postData setObject:@"saveform" forKey:@"action"];
    [postData setObject:@"smartplan" forKey:@"type"];
    
    [Global wait:@"正在保存"];
    postman.tag = 3;
    //请求保存数据(表单数据表单数据)
    [postman postDataWithUrl:[Global serviceUrl] data:postData delegate:self];
    
    //[Global addDataToSyn:[NSString stringWithFormat:@"DATAIDENTITY_SAVEFORMDETAIL_%@_%@",[_project objectForKey:PROJECTKEY_ID],[Global newUuid]] data:postData];
}





//请求成功(发送表单)
-(void)onFormSaveCompleted:(BOOL)successfully{
    [Global wait:nil];
    if (successfully) {
        self.btnModifyFormDetail.hidden=NO;
        //        self.btnSend.hidden = NO;
        //        if ([_type isEqualToString:@"Wfxm"]) {
        //            //违法项目
        //            self.btnLocation.hidden = NO;
        ////            self.btnSend.hidden = YES;
        //        }
        //        else{
        //            self.btnLocation.hidden = YES;
        ////            self.btnSend.hidden = NO;
        //        }
        //提交按钮(隐藏)
        self.btnDoFormDetail.hidden=YES;
        //取消编辑按钮(隐藏)
        self.btnCancelFormDetail.hidden=YES;
        //修改表单内容
        NSMutableArray *forms=[_project objectForKey:PROJECTKEY_FORMS];
        NSMutableDictionary *p=[forms objectAtIndex:formSelectIndex];
        
        NSArray *arr1=[_newFormJson componentsSeparatedByString:@"5f;n"];
        //循环变量变化数组
        for (NSString *item in arr1) {
            if ([item isEqualToString:@""]) {
                continue;
            }
            //分割4,gv数据
            NSArray *arr2=[item componentsSeparatedByString:@"4g,v"];
            //表单详情
            NSMutableArray *detail =[p objectForKey:@"detail"];
            for (NSMutableDictionary *itemDic in detail) {
                //找出表单中对应键相同的,修改对应的值
                if ([[itemDic objectForKey:@"id"] isEqualToString:[arr2 objectAtIndex:0]]) {
                    [itemDic setObject:[arr2 objectAtIndex:1] forKey:@"value"];
                }
            }
        }
        NSString *script =[NSString stringWithFormat:@"window.createFormPanel(%@);",[self formJsonFromDictionary:[p objectForKey:@"detail"]]];
        
        //把整个表单内容写入
        [self.formWebView stringByEvaluatingJavaScriptFromString:script];
        //保存数据到本地
        [self saveProjectToDisk];
        //刷新数据
        [self loadProject:_theProject typeName:_type];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"表单保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (void) performDismiss: (NSTimer *)timer {
    [baseAlert dismissWithClickedButtonIndex:0 animated:NO];//important
    baseAlert = NULL;
}

-(void)download:(FileDownload *)dowanlod onFileDownloaded:(NSString *)fileId filePath:(NSString *)filePath{
    /*
     NSLog(@"downloaded");
     NSArray  * array= [filePath componentsSeparatedByString:@"."];
     NSString *extension=array.lastObject;
     NSString *txtPath=[Global currentUser].userProjectPath;
     //    txtPath=[txtPath stringByAppendingPathComponent:[_project projectId]];
     //    txtPath=[txtPath stringByAppendingPathComponent:fileId];
     txtPath=[txtPath stringByAppendingFormat:@"/%@/%@.%@",[_project projectId],fileId,extension];
     NSFileManager *fileManager=[NSFileManager defaultManager];
     NSError *error;
     [fileManager copyItemAtPath:filePath toPath:txtPath error:&error];
     */
}

-(void)download:(FileDownload *)dowanlod onFileStartDownload:(NSString *)fileId{
    NSLog(@"start download");
    
}

-(void)download:(FileDownload *)dowanlod onFileDownloadFaild:(NSString *)fileId{
    NSLog(@"download faild");
    
}

-(void)download:(FileDownload *)dowanlod updateProgress:(NSString *)fileId progress:(float)progressValue{
    NSLog(@"updateProgress");
}

//获取文件夹大小
- (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        NSLog(@"%@",fileAbsolutePath);
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    //return folderSize/(1024.0*1024.0);
    return folderSize/1024.0;
}
//单个文件大小
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//返回按钮点击
- (IBAction)onBtnGoback:(id)sender {
    
    [self.delegate jobDetailViewShouldClose];
    //[self.ownController.navigationController popViewControllerAnimated:YES];
}

//设置批后状态改变//@"基础", @"转换", @"标准", @"封顶", @"外立面"
-(void)setPhFlowState:(int)flowState{
    _phFlowState = flowState;
}


#pragma  ASI 代理方法 --执行完点击提交按钮的请求后执行的方法
-(void)requestFailed:(ASIHTTPRequest *)request{
    if (request.tag==1) {
        [self photoRequestFailed:request];
    }else if(request.tag==2){
        [self stopworkfromRequestFailed:request];
    }else if(request.tag==3){
        [self onFormSaveCompleted:NO];
    }
}


-(void)requestFinished:(ASIHTTPRequest *)request{
    if (request.tag==1) {
        [self photoRequestFinished:request];
    }else if(request.tag==2){
        [self stopworkfromRequestFinished:request];
    }else if(request.tag==3){
        [self onFormSaveCompleted:YES];
    }
}





//每次加载完数据(表单/材料/照片/停工单)-----缓存数据
-(void)onFormDataDidLoaded{
    
    _dataLoadFlag++;
    //如果数据全部加载完成，则把数据缓存到本地
    if (_dataLoadFlag==4) {
        //[self.delegate jobInfoDidLoadFromNetwork];
        [self saveProjectToDisk];
    }
}
//缓存数据到本地
-(void)saveProjectToDisk{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    //project保存路径/id.plist
    if ([fm fileExistsAtPath:_projectSavePath]) {
        //清空
        [fm removeItemAtPath:_projectSavePath error:nil];
    }
    //把_project写到路径下
    [_project writeToFile:_projectSavePath atomically:YES];
}

//显示日期拾取视图
-(void)showDatePicker:(NSString *)dateStr{
    DatePickerViewController *dpv = [[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
    dpv.delegate = self;
    dpv.defaultDateString = dateStr;
    MZFormSheetController *fs = [[MZFormSheetController alloc] initWithViewController:dpv];
    fs.shouldDismissOnBackgroundViewTap = YES;
    //formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    fs.cornerRadius = 8.0;
    fs.portraitTopInset = 6.0;
    fs.landscapeTopInset = 150;
    fs.presentedFormSheetSize = CGSizeMake(300, 280);
    [fs presentAnimated:YES completionHandler:nil];
}
#pragma mark-FormDatePickerDelegate 日期拾取视图代理方法

//修改日期
-(void)formDateDidSelected:(NSString *)date{
    NSString *script =[NSString stringWithFormat:@"window.setDateVal('%@')", date];
    [self.formWebView stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark - 处理多层级列表


-(void)miniMizeThisRows:(NSArray*)arr
{
    
    for(NSDictionary *inDic in arr )
    {
        NSUInteger indexToRemove = [_materials indexOfObjectIdenticalTo:inDic];
        NSArray *inarr=[inDic valueForKey:@"files"];
        
        if(inarr && [inarr count]>0)
        {
            [self miniMizeThisRows:inarr];
        }
        
        if([_materials indexOfObjectIdenticalTo:inDic]!=NSNotFound)
        {
            [_materials removeObjectIdenticalTo:inDic];
            [self.materialTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToRemove inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}


////////////////////////////////////////
//点击弹出框(开始巡查)
-(void)newDailyJobwithDict:(NSMutableDictionary *)dict andwithMaterialA:(NSMutableArray *)matrialA
{
    [self.delegate popXCJMwith:dict andwithMaterialA:matrialA];
}

-(CGFloat)returnCellHeight:(NSString *)string withLever:(NSInteger)lever
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(161-10*lever,MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    NSLog(@"foot_H::%lf",rect.size.height);
    return rect.size.height+10;
}

@end
