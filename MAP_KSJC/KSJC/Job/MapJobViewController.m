//
//  MapJobViewController.m
//  zzzf
//
//  Created by mark on 14-3-3.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapJobViewController.h"
#import "Global.h"
#import "MBProgressHUD+MJ.h"
#import "FileSController.h"

@interface MapJobViewController ()

@end

@implementation MapJobViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)loadbaseProjectWithpid:(NSString *)pid andTime:(NSString *)time withDict:(NSDictionary *)dict
{
  
        //根据记录获取基本信息
        //58.246.138.178:8040/KSYDService/ServiceProvider.ashx?type=smartplan&action=projectbaseinfo&projectId=87668
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        NSDate *date =[formatter dateFromString:time];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
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
                
                [MBProgressHUD showSuccess:@"项目基本信息获取成功" toView:self.view];
                NSArray *arr= [rs objectForKey:@"result"];
                if(arr.count>0)
                {
                    NSDictionary *dicts =[rs objectForKey:@"result"][0];
                    _project = dicts;
                    NSMutableDictionary *muldic = [NSMutableDictionary dictionaryWithDictionary:dicts];
                    _projectID = [dicts objectForKey:@"projectId"];
                    //点击的是巡查记录(某一条)
                    _jobDetailView.ThelogClick = YES;
                    _jobDetailView.theLogDict = dict;
                    _jobDetailView.throughfromMap = YES;
                    _jobDetailView.xcTime = [dict objectForKey:@"guid"];
//                    [NSString stringWithFormat:@"%@ %@",[formatter stringFromDate:date],[dict objectForKey:@"xmmc"]];
                    [_jobDetailView loadProject:muldic typeName:@"Wfxm"];

                }
//                [self loadData];
                else
                {
                        [self.navigationController popViewControllerAnimated:YES];
                    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"无法获取项目信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                    
                }
            }
            else
            {
                [MBProgressHUD showError:@"项目基本信息获取成功" toView:self.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [MBProgressHUD showError:@"项目基本信息获取成功" toView:self.view];
        }];
        
        
        
    }
    
    


- (void)viewDidLoad
{
    [super viewDidLoad];
    _jobDetailView = [JobDetailView createView];
    _jobDetailView.delegate = self;
    _jobDetailView.jumpfromMap = YES;
    [_jobDetailView initializedView];
    [_jobDetailView setReadonly:YES];

    _jobDetailView.frame = CGRectMake(0, 0, 1024, 768);
    CGRect frame = _jobDetailView.logTableView.frame;
    frame.size.height = frame.size.height+60;
    
    _jobDetailView.logTableView.frame = frame;
    _jobDetailView.phLogTableView.frame =frame;
    [self.view addSubview:_jobDetailView];
    NSMutableDictionary *muldict = [NSMutableDictionary dictionaryWithDictionary:_project];
    if(!_xclog)
    {
        _jobDetailView.ThelogClick = NO;
        _jobDetailView.throughfromMap = YES;
    [_jobDetailView loadProject:muldict typeName:self.type];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
}
-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data
{
   
    
    NSMutableDictionary *project = [NSMutableDictionary dictionaryWithObjectsAndKeys:[data objectForKey:@"Id"],@"id",[data objectForKey:@"ProjectName"],@"name", nil];
    [_jobDetailView loadProject:project typeName:self.type];
}
-(void) serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    
}

-(void)openMaterial:(NSString *)materialName path:(NSString *)path ext:(NSString *)ext fromLocal:(BOOL)fromLocal{
    _toOpenFileName = materialName;
    _toOpenFileExt = ext;
    _toOpenFilePath = path;
    _isLocalFile = NO;
    _toOpenFiles = nil;
    FileSController *target =[[FileSController alloc]init];
    
    
//    UIViewController *target = segue.destinationViewController;
    //FileViewController *target=segue.destinationViewController;
    [target setValue:_toOpenFileName forKey:@"fileName"];
    [target setValue:_toOpenFilePath forKey:@"filePath"];
    [target setValue:_toOpenFileExt forKey:@"fileExt"];
    [target setValue:_toOpenFiles forKey:@"files"];
    [target setValue:[NSString stringWithFormat:@"%d",_toOpenFileIndex] forKey:@"currentIndex"];
    [target setValue:_isLocalFile?@"NO":@"YES" forKey:@"isFromNetwork"];
    [target setValue:@"NO" forKey:@"showSaveButton"];
    [self presentViewController:target animated:YES completion:^{
//
    }];
    
//    [self performSegueWithIdentifier:@"fileView" sender:self];
    
//
//    [self.delegate mapJobViewShouldShowFile:materialName path:path ext:ext];
}

-(void)openMaterial:(NSArray *)materials at:(int)index{
    [self.delegate mapJobViewShouldShowFiles:materials at:index];
    
}


-(void)jobDetailViewShouldClose{
    if(self.xclog)
    {
        if(self.zjxcLog)//在建巡查中跳转的巡查记录
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];

        }
        else//地图跳巡查记录
        {
        [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        if(self.zjxcLog)//在建跳批后跟踪
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else
        {//地图调批后跟踪
    [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

@end
