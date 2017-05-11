//
//  DailyJobReaderViewController.m
//  zzzf
//
//  Created by dist on 14-2-25.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DailyJobReaderViewController.h"
#import "Global.h"
#import "FormAndMaterialCell.h"
#import "MBProgressHUD+MJ.h"
#import "AFNetworking.h"
#import "Global.h"
#import "ProjectBaseMessageCell.h"
#import "Materialcellcell.h"
@interface DailyJobReaderViewController ()
@property (nonatomic,strong)NSDictionary *baseDict;
@property (nonatomic,strong)NSMutableArray *materialA;

@property (nonatomic,strong)NSString *xcLogTime;
@end

@implementation DailyJobReaderViewController

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
    _webLoadTag = 0;
    _dataReaded = NO;
    _materialA =[NSMutableArray array];
    self.baseTabelView.separatorStyle =UITableViewCellSeparatorStyleNone;
    self.baseTabelView.delegate =self;
    self.baseTabelView.dataSource =self;
    self.baseTabelView.layer.cornerRadius = 5;
    self.baseTabelView.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1].CGColor;
    self.baseTabelView.layer.borderWidth=1;
    self.baseTabelView.clipsToBounds = YES;
    
}

- (void)loadBaseMessage
{
    self.watingView.hidden = YES;
    self.jobInfoView.hidden = NO;
    self.lblUsername.text = [_baseDict objectForKey:@"jcry"];
    self.lblStartTime.text = [_baseDict objectForKey:@"jcsj"];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onBtnGobackTap:(id)sender {
    poped = YES;
//    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];

}


- (void)loadbaseProjectWithpid:(NSString *)pid andTime:(NSString *)time
{
    //根据记录获取基本信息
//58.246.138.178:8040/KSYDService/ServiceProvider.ashx?type=smartplan&action=projectbaseinfo&projectId=87668
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *date =[formatter dateFromString:time];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
 _xcLogTime = [formatter stringFromDate:date];

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
        NSLog(@"添加一条新记录%@",requestAddress);
        
        [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rs = (NSDictionary *)responseObject;
            if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
                [MBProgressHUD showSuccess:@"项目基本信息获取成功" toView:self.view];
                NSArray *arr= [rs objectForKey:@"result"];
                if(arr.count>0)
                {
                NSDictionary *dict =[rs objectForKey:@"result"][0];
                _baseDict = dict;
                [self loadmaterialWtihSLBH:[_baseDict objectForKey:@"slbh"]];
                }
                [self loadData];

            }
            else
            {
                [MBProgressHUD showError:@"项目基本信息获取成功" toView:self.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [MBProgressHUD showError:@"项目基本信息获取成功" toView:self.view];
        }];
        
        
        
    }

- (void)loadmaterialWtihSLBH:(NSString *)slbh;
{
    //加载材料请求
    //       6.138.178:8040/KSYDService/ServiceProvider.ashx?&slbh=DGF20150021&type=smartplan&action=materials
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"type"] = @"smartplan";
    parameters[@"action"]=@"materials";
    parameters[@"slbh"]=slbh;

    
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    NSLog(@"请求获取材料%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            [MBProgressHUD showSuccess:@"材料获取成功" toView:self.view];
            NSArray *mateArr =[[rs objectForKey:@"result"][0] objectForKey:@"files"];
            for (NSDictionary *dict in mateArr) {
                NSString *str = [dict objectForKey:@"group"];
                if ([str isEqualToString:_xcLogTime]) {
                    _materialA = [NSMutableArray arrayWithArray:[dict objectForKey:@"files"]];
                    
                }
            }
            [self loadData];
        }
        else
        {
            [MBProgressHUD showError:@"项目基本信息获取成功" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"项目基本信息获取成功" toView:self.view];
    }];

}



- (void)loadData
{
    NSArray *arr1=[NSArray array];
    NSArray *arr2 =[NSArray array];
    
    arr1 =@[@"项目编号",@"案卷编号",@"项目名称",@"建设地址"];
    arr2= @[@"建设单位",@"联系人",@"联系电话"];
//    NSArray *arr3 = @[@"1",@"2",@"3",@"4",@"5"];
    
    _infoArray = @[arr1,arr2,_materialA];
    _markArray = [NSMutableArray array];
    
    for (int i=0; i<3; i++) {
        NSString *mark = @"1";
        [_markArray addObject:mark];
    }
    //分组图标
    _groupImgArray = [NSMutableArray arrayWithObjects:@"zhankai@2x.png",@"zhankai@2x.png",@"zhankai@2x.png", nil];
    _detailArray_in = [NSMutableArray array];
    _detailArray_out = [NSMutableArray array];
    
    if(_baseDict)
    {
        
        [_detailArray_in addObject:[_baseDict objectForKey:@"company"]];
        [_detailArray_in addObject:[_baseDict objectForKey:@"contactName"]];
        [_detailArray_in addObject:[_baseDict objectForKey:@"contactPhone"]];
        
        [_detailArray_out addObject:[_baseDict objectForKey:@"xmbh"]];
        [_detailArray_out addObject:[_baseDict objectForKey:@"slbh"]];
        [_detailArray_out addObject:[_baseDict objectForKey:@"projectName"]];
        [_detailArray_out addObject:[_baseDict objectForKey:@"address"]];
        
    }
    
    [self.baseTabelView reloadData];
}


#pragma mark -----------tableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return _infoArray.count;
   
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        NSString *mark = [_markArray objectAtIndex:section];
        if (section == 0)
        {
            if([mark isEqualToString:@"1"])
            {
                return [_infoArray[section] count];
                
            }
            else
            {
                
                return 0;
            }        }
        else if (section == 1)
        {
            if([mark isEqualToString:@"1"])
            {
                return [_infoArray[section] count];
                
            }
            else
            {
                
                return 0;
            }
        }
    else if (section == 2)
    {
        if([mark isEqualToString:@"1"])
        {
            return _materialA.count;
            
        }
        else
        {
            
            return 0;
        }
    
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
        ProjectBaseMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectBaseMessageCell"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ProjectBaseMessageCell" owner:nil options:nil] lastObject];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section == 0) {
            cell.titleLabel.text = _infoArray[indexPath.section][indexPath.row];

            if(_baseDict)
            {
                cell.contentLabel.text = _detailArray_out[indexPath.row];
            }
            else
            {
                cell.contentLabel.text = @"";
                
            }
            
        }
        
        else if (indexPath.section == 1){
            cell.titleLabel.text = _infoArray[indexPath.section][indexPath.row];

            if (_baseDict) {
                cell.contentLabel.text = _detailArray_in[indexPath.row];
                
                
                if([_detailArray_in[indexPath.row] isEqualToString:@"不计时"])
                {
                    [cell.contentLabel setTextColor:[UIColor colorWithRed:77.0/255.0 green:186.0/255.0 blue:122.0/255.0 alpha:1.0f]];
                    
                }
            }
            else
            {
                cell.contentLabel.text = @"";
                
            }
        }
    else if (indexPath.section == 2)
    {
        Materialcellcell *cell;
        if(cell==nil)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"Materialcellcell" owner:nil options:nil] lastObject];
        }
        NSString *name;
        NSString *temName;
        //区别文件夹和文件
        NSDictionary *dic = [_materialA objectAtIndex:indexPath.row];
        NSArray *child =[dic objectForKey:@"files"];
        
        if([[dic objectForKey:@"type"]isEqualToString:@"directory"]) {
            
            name=[[_materialA objectAtIndex:indexPath.row] valueForKey:@"group"];
            temName = [name stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            cell.icon.image = [UIImage imageNamed:@"fileicon.png"];
            NSArray *child =[dic objectForKey:@"files"];
            
            NSString *subName =[NSString stringWithFormat:@"%@(%ld)",temName,child.count];
            cell.contentLabel.text = subName;
        }
        else
        {
            name=[[_materialA objectAtIndex:indexPath.row] valueForKey:@"group"];
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
        
        [cell setIndentationLevel:[[[_materialA objectAtIndex:indexPath.row] valueForKey:@"level"] intValue]-1];
        if (MainR.size.width==320) {
            cell.indentationWidth = 20;
            
        }else
        {
            cell.indentationWidth = 25;
        }
        
        cell.nameHC.constant =[self returnCellHeight:name];
        float indentPoints = cell.indentationLevel * cell.indentationWidth;
        
        cell.contentView.frame = CGRectMake(indentPoints,cell.contentView.frame.origin.y,cell.contentView.frame.size.width - indentPoints,cell.contentView.frame.size.height);
        
        // NSLog(@"indentationLevel=%ld",(long)cell.indentationLevel);
        
        return cell;
        
        
    
    }
    
    
        UIView *line =[[UIView alloc] initWithFrame:CGRectMake(15, 0, MainR.size.width, 1)];
        line.backgroundColor = GRAYCOLOR;
        [cell.contentView addSubview:line];
        
        return cell;
    
}
//头部视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
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
    [lab setTextColor:BLUECOLOR];
    [lab setFont:[UIFont systemFontOfSize:18]];
        
        if(section == 0)
        {
            lab.text = [_baseDict objectForKey:@"business"];
        
        }
        else if (section == 1)
        {
            lab.text = @"建设单位信息 (3)";
            
        }else if (section == 2)
        {
           NSString *mateTitle = [NSString stringWithFormat:@"%@ (%d)",_xcLogTime,_materialA.count];
            lab.text = mateTitle;
        
        }
        [headView addSubview:lab];
        UIButton *groupBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        groupBtn.frame = CGRectMake(1024-35, 30/2.0, 15, 15);
        [groupBtn setImage:[UIImage imageNamed:_groupImgArray[section]] forState:UIControlStateNormal];
        groupBtn.enabled = NO;
        groupBtn.tag = section+1000;
        [headView addSubview:groupBtn];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOrCloseHeader:)];
        [headView addGestureRecognizer:tap];
        return headView;
    
}
//打开关闭分组
-(void)openOrCloseHeader:(UITapGestureRecognizer *)tap
{
    UIView *tapView = tap.view;
    NSString *mark = _markArray[tapView.tag];
    if ([mark isEqualToString:@"0"]) {
        [_markArray replaceObjectAtIndex:tapView.tag withObject:@"1"];
        [UIView animateWithDuration:0.5 animations:^{
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
    
    if(indexPath.section == 2)
    {
        CGFloat adviceH;
        NSDictionary *dic = [_materialA objectAtIndex:indexPath.row];
        NSString *name;
        if([[dic objectForKey:@"type"] isEqualToString:@"directory"]) {
            name =[dic objectForKey:@"group"];
            
        }
        else
        {
            name =[dic objectForKey:@"group"];
            
            
        }
        
        adviceH= [self returnCellHeight:name ]+15;
        
        
        
        return adviceH;

    
    }
    else
    {
    
    return 44;
    }
    
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
//    
//        if (section == 0) {
//            return 0.0;
//        }
        return 45.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
        return 3;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    "group": "78EFF7610E2BFD4D9B876C42C03646D9.2016-7-20.png",
    //                                    "groupid": "59259",
    //                                    "type": "file",
    //                                    "fileExtension": ".png",
    //                                    "level": "2"
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section==2)
    {
    
    NSLog(@"section=%ld,row=%ld",(long)indexPath.section,(long)indexPath.row);
    
    NSDictionary *dic = [_materialA objectAtIndex:indexPath.row];
    if([dic valueForKey:@"files"])
    {
        NSArray *array = [dic valueForKey:@"files"];
        
        BOOL isAlreadyInserted = NO;
        
        for(NSDictionary *dInner in array)
        {
            NSInteger index=[_materialA indexOfObjectIdenticalTo:dInner];
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
                [cellArr addObject:[NSIndexPath indexPathForRow:count inSection:2]];
                [_materialA insertObject:inDic atIndex:count++];
            }
            [tableView insertRowsAtIndexPaths:cellArr withRowAnimation:UITableViewRowAnimationBottom];
        }
        
    }
    else
    {
        NSString *str=[dic valueForKey:@"group"];
        NSLog(@"str = %@",str);
     
        NSDictionary *dic =[_materialA objectAtIndex:indexPath.row];
        NSString *name =  [dic objectForKey:@"group"];
        NSString *identity =[dic objectForKey:@"groupid"];
        NSString *ext =[dic objectForKey:@"fileExtension"];
        NSString *fileId = [NSString stringWithFormat:@"%@_%@",name,identity];
        NSString *downloadUrl = [NSString stringWithFormat:@"%@?type=smartplan&action=downloadmaterial&fileId=%@",[Global serviceUrl],identity];
//
//        [fvc openFile:fileId url:downloadUrl ext:ext];
//        
//        //    [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController: fvc animated: YES completion:nil];
//        
//        
//        if([[[UIDevice currentDevice] systemVersion] floatValue]<8.0)
//        {
//            
//            [self.nav pushViewController:fvc animated:YES];
//            
//            
//        }
//        else
//        {
//            
//            [self presentViewController:fvc animated:YES completion:nil];
//            
//        }
        [self.fileDelegate openFile:name path:downloadUrl ext:ext isLocalFile:NO];
        
    }
    [_baseTabelView reloadData];
    }
}

-(void)miniMizeRows:(NSArray*)arr
{
    
    for(NSDictionary *inDic in arr )
    {
        NSUInteger indexToRemove = [_materialA indexOfObjectIdenticalTo:inDic];
        NSArray *inarr=[inDic valueForKey:@"files"];
        
        if(inarr && [inarr count]>0)
        {
            [self miniMizeRows:inarr];
        }
        
        if([_materialA indexOfObjectIdenticalTo:inDic]!=NSNotFound)
        {
            [_materialA removeObjectIdenticalTo:inDic];
            //            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToRemove inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(void)miniMizeThisRows:(NSArray*)arr
{
    
    for(NSDictionary *inDic in arr )
    {
        NSUInteger indexToRemove = [_materialA indexOfObjectIdenticalTo:inDic];
        NSArray *inarr=[inDic valueForKey:@"files"];
        
        if(inarr && [inarr count]>0)
        {
            [self miniMizeThisRows:inarr];
        }
        
        if([_materialA indexOfObjectIdenticalTo:inDic]!=NSNotFound)
        {
            [_materialA removeObjectIdenticalTo:inDic];
            [self.baseTabelView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToRemove inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}


//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    NSUInteger row = [indexPath row];
//    if (tableView == self.stopWorkFormTableView)
//    {
//        NSDictionary *theForm = [[_jobInfo objectForKey:@"stopwork"] objectAtIndex:row];
//        _updateFormIndex = row;
//        [_stopworkFormView showForm:[theForm objectForKey:@"id"] formData:theForm];
//        _stopworkFormView.hidden = NO;
//    }
//    else if (tableView == self.correctiveTableView)
//    {
//        NSDictionary *theForm = [[_jobInfo objectForKey:@"stopwork"] objectAtIndex:row];
//        _updateFormIndex = row;
//        [_stopworkFormView showForm:[theForm objectForKey:@"id"] formData:theForm];
//        _stopworkFormView.hidden = NO;
//    }
//    else
//    {
//        
//        
//        
//        
//    }
//    
//}


-(void) loadJob:(NSString *)day withDict:(NSDictionary *)dict
{
    _day = day;
    _baseDict = dict;
    self.lblDateTitle.text = _day;
    ServiceProvider *dataProvider = [ServiceProvider initWithDelegate:self];
    [dataProvider getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[Global currentUser].userid],@"uid",_day,@"day",@"getjob",@"action", nil]];
    /*
    //延迟一秒，为了让UIWebView加载完成
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doLoad) userInfo:nil repeats:NO];*/
}

-(void)doLoad{
    
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    
    NSString *status = [data objectForKey:@"success"];
    if ([status isEqualToString:@"false"]) {
        [self showErrorMessageAndGoBack];
    }else{
        self.watingView.hidden = YES;
        self.jobInfoView.hidden = NO;
        _dataSource = [data objectForKey:@"result"];
        [self readJobItem:[_dataSource objectAtIndex:0]];
    }

//    NSString *status = [data objectForKey:@"status"];
//    if ([status isEqualToString:@"false"]) {
//        [self showErrorMessageAndGoBack];
//    }else{
//        self.watingView.hidden = YES;
//        self.jobInfoView.hidden = NO;
//        _dataSource = [data objectForKey:@"result"];
//        [self readJobItem:[_dataSource objectAtIndex:0]];
//    }
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    [self showErrorMessageAndGoBack];
}


//alertView Delegate方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [self onBtnGobackTap:nil];
}

-(void)showErrorMessageAndGoBack{
    if (!poped) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未能加载数据" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

//加载表格数据
-(void)loadJobFromData:(NSDictionary *)data{
    [self readJobItem:data];
}

-(void)delayLoadJobFromData{
   
}

//读数据,设置值
-(void)readJobItem:(NSDictionary *)jobInfo{
    _currentJobInfo = jobInfo;
    if (_webLoadTag!=2 || _dataReaded) {
        return;
    }
    self.watingView.hidden = YES;
    self.jobInfoView.hidden = NO;
    _dataReaded = YES;
    self.lblUsername.text = [jobInfo objectForKey:@"user"];
    self.lblPda.text = [jobInfo objectForKey:@"pda"];
    self.lblStartTime.text = [jobInfo objectForKey:@"start"];
    self.lblEndTime.text = [jobInfo objectForKey:@"end"];
    _photots = [jobInfo objectForKey:@"photos"];
    NSString *photoButtonTitle = [NSString stringWithFormat:@"照片(%d)",_photots.count];
    [self.btnPhotos setTitle:photoButtonTitle forState:UIControlStateNormal];
    [self.btnPhotos setTitle:photoButtonTitle forState:UIControlStateSelected];
    
    _stopworkforms = [jobInfo objectForKey:@"stopworkforms"];
    self.lblStopworkforms.text = [NSString stringWithFormat:@"停工单(%d)",_stopworkforms.count];
    
    [self.webReport stringByEvaluatingJavaScriptFromString:@"window.setEditable(false)"];
    [self.webReport stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"window.setData(%@)",[jobInfo objectForKey:@"report"]]];
    
    //设置停工单tableview代理
    self.tableStopworkforms.delegate = self;
    self.tableStopworkforms.dataSource = self;
    [self.tableStopworkforms reloadData];
    
    if (self.defaultDisplayStopworkfrom) {
        NSIndexPath *ip=[NSIndexPath indexPathForRow:0 inSection:0];
    //默认选中第一行
        [self.tableStopworkforms selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionBottom];
        //取消巡查报告显示
        self.btnReport.selected = NO;
        
        NSDictionary *theForm = [_stopworkforms objectAtIndex:0];
        //显示停工单的webView
        self.webStopworkform.hidden = NO;
        self.webReport.hidden = _photoViewer.hidden = YES;
        [self.webStopworkform stringByEvaluatingJavaScriptFromString:@"window.setEditable(false)"];
        [self.webStopworkform stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"window.setData(%@)",[theForm objectForKey:@"content"]]];
        _currentSelectedTableViewCell = [self.tableStopworkforms cellForRowAtIndexPath:ip];
    }
}


-(CGFloat)returnCellHeight:(NSString *)string
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MainR.size.width-30,MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    NSLog(@"foot_H::%lf",rect.size.height + 10.0);
    return rect.size.height + 10.0;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    //点击tableView时,让照片和巡查报告按钮取消选中
//    self.btnPhotos.selected = self.btnReport.selected = NO;
//    //读取选中数据
//    NSDictionary *theForm = [_stopworkforms objectAtIndex:indexPath.row];
//    self.webStopworkform.hidden = NO;
//    //把巡查报告表和照片隐藏
//    self.webReport.hidden = _photoViewer.hidden = YES;
//    
//    [self.webStopworkform stringByEvaluatingJavaScriptFromString:@"window.setEditable(false)"];
//    [self.webStopworkform stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"window.setData(%@)",[theForm objectForKey:@"content"]]];
//    //保存当前选中cell
//    _currentSelectedTableViewCell = [tableView cellForRowAtIndexPath:indexPath];
//    
//}
//
//
//-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return _stopworkforms.count;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *CustomCellIdentifier = @"FormAndMaterialCellIdentifier";
//    FormAndMaterialCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
//    if (nil==cell) {
//        UINib *nib = [UINib nibWithNibName:@"FormAndMaterialCell" bundle:nil];
//        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
//        cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
//    }
//    NSUInteger row = [indexPath row];
//    NSDictionary *theForm = [_stopworkforms objectAtIndex:row];
//    cell.fileName = [theForm objectForKey:@"name"];
//    return cell;
//}
//
////点击巡查报告
//- (IBAction)onBtnReportTap:(id)sender {
//    self.btnReport.selected = YES;
//    //取消其他按钮选中和隐藏相应的webView
//    self.btnPhotos.selected = NO;
//    self.webStopworkform.hidden = _photoViewer.hidden =  YES;
//    self.webReport.hidden = NO;
//    //取消cell选中
//    if (nil!=_currentSelectedTableViewCell) {
//        _currentSelectedTableViewCell.selected = NO;
//    }
//}
//
////点击照片
//- (IBAction)onBtnPhotoTap:(id)sender {
//    if (!_photoInitlized) {
//        [_photoViewer loadPhotos:_photots];
//    }
//    _photoInitlized = YES;
//    //取消巡查报告按钮
//    self.btnReport.selected = NO;
//    //选中照片按钮
//    self.btnPhotos.selected = YES;
//    //隐藏停工单和巡查表单WebView
//    self.webStopworkform.hidden = self.webReport.hidden = YES;
//    _photoViewer.hidden = NO;
//    //取消cell的选中状态
//    if (nil!=_currentSelectedTableViewCell) {
//        _currentSelectedTableViewCell.selected = NO;
//    }
//}
//
//#pragma mark -PhotoCollectionDelegate代理方法
//
//-(void)photoCollectionShouldOpenPhoto:(NSString *)name url:(NSString *)url{
//    
//       [self.fileDelegate openFile:name path:url ext:@"jpg" isLocalFile:NO];
//}
//-(void)openPhotos:(NSArray *)files at:(int)index
//{
//    [self.fileDelegate allFiles:files at:index];
//}
//
//
//
//-(void)webViewDidFinishLoad:(UIWebView *)webView{
//    _webLoadTag++;
//    if (_webLoadTag==2 && nil!=_currentJobInfo) {
//        NSLog(@"web loaded");
//        [self readJobItem:_currentJobInfo];
//    }
//}
@end
