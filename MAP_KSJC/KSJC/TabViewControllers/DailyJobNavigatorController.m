//
//  DailyJobNavigatorController.m
//  zzzf
//
//  Created by dist on 14-2-25.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DailyJobNavigatorController.h"
#import "Global.h"

@interface DailyJobNavigatorController ()<UIAlertViewDelegate>

@end

@implementation DailyJobNavigatorController

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
    
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    maskView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.color = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1];
    activity.frame = CGRectMake(450, 300, 32, 32);
    [activity startAnimating];
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(485, 300, 140, 30)];
    loadingLabel.text=@"正在初始化数据";
    loadingLabel.font = [loadingLabel.font fontWithSize:16];
    
    [maskView addSubview:activity];
    [maskView addSubview:loadingLabel];
    [self.tabBarController.view addSubview:maskView];
    
    DailyJobViewController *djv = [[DailyJobViewController alloc] initWithNibName:@"DailyJobViewController" bundle:nil];
    [self pushViewController:djv animated:NO];
    djv.fileDelegate = self;
    self.navigationBarHidden=YES;
    [self checkVersion];
}

- (void)checkVersion
{
    
    NSError *error;
    NSString *newVersion = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://58.246.138.178/AppStore/product/ksjc/version.txt"] encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"newVersion=%@",newVersion);
    if (newVersion!=nil||[newVersion isEqualToString:@""]) {
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSLog(@"currentVersion=%@",currentVersion);
        
        
        if(![newVersion isEqualToString:currentVersion])
        {
            if (![newVersion isEqualToString:currentVersion]) {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"新版本已发布" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"去更新", nil];
                
                [alert show];
            }
        }
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1)
    {
        NSURL *url=[NSURL URLWithString:@"http://58.246.138.178/AppStore/product/ksjc"];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//打开单个文件
-(void)openFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext isLocalFile:(BOOL)isLocalFile{
    
    _toOpenFileName = name;
    _toOpenFilePath = path;
    _toOpenFileExt = ext;
    _materialFromLocal = isLocalFile;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}
//打开一组中的某个文件
-(void)allFiles:(NSArray *)files at:(int)index
{
    NSDictionary *itemDic=[files objectAtIndex:index];
    _currentIndex=[NSString stringWithFormat:@"%d",index];
    _filesArray=files;
    _toOpenFileName=[itemDic objectForKey:@"name"];
    _toOpenFilePath=[itemDic objectForKey:@"path"];
    _toOpenFileExt=[itemDic objectForKey:@"ext"];
    if ([[itemDic objectForKey:@"uploaded"] isEqualToString:@"YES"]||[[itemDic objectForKey:@"uploaded"] isEqualToString:@"yes"]) {
        _materialFromLocal=NO;
    }
    else
        _materialFromLocal=YES;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *target = segue.destinationViewController;
    [target setValue:_currentIndex forKey:@"currentIndex"];
    [target setValue:_filesArray forKeyPath:@"files"];
    [target setValue:_toOpenFileName forKey:@"fileName"];
    [target setValue:_toOpenFilePath forKey:@"filePath"];
    [target setValue:_toOpenFileExt forKey:@"fileExt"];
    [target setValue:_materialFromLocal?@"NO":@"YES" forKey:@"isFromNetwork"];
}

@end
