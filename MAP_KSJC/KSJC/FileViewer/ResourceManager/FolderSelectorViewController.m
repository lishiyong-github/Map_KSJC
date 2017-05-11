//
//  FolderSelectorViewController.m
//  zzzf
//
//  Created by mark on 14-2-23.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "FolderSelectorViewController.h"

@interface FolderSelectorViewController ()

@end

@implementation FolderSelectorViewController

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
    NSFileManager *fManager=[NSFileManager defaultManager];
    NSArray *fileList=[[NSArray alloc] init];
    fileList=[fManager contentsOfDirectoryAtPath:[[Global currentUser] userResourcePath] error:nil];
    NSMutableArray *folderList=[[NSMutableArray alloc] init];
    BOOL isDir=NO;
    for (NSString *file in fileList) {
        NSString *path=[[[Global currentUser] userResourcePath] stringByAppendingPathComponent:file];
        [fManager fileExistsAtPath:path isDirectory:(&isDir)];
        if (isDir) {
            for (FileModel *f in _moveFolderPath) {
                if (![f.filePath isEqualToString:path]) {
                    [folderList addObject:file];
                }
            }
            
        }
        isDir=NO;
    }
    UIBarButtonItem *confirm=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(move:)];
     UIBarButtonItem *back=[[UIBarButtonItem alloc] initWithTitle:@"上级" style:UIBarButtonItemStyleBordered target:self action:nil];
    FolderViewController *rootFolderView = [[FolderViewController alloc] initWithNibName:@"FolderViewController" bundle:nil];
    //rootFolderView.title = @"本地资源目录";
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.font=[UIFont systemFontOfSize:12];
    lblTitle.text=@"本地资源目录";
    lblTitle.backgroundColor=[UIColor clearColor];
    rootFolderView.delegate=self.delegate;
    rootFolderView.navigationItem.titleView=lblTitle;
    rootFolderView.navigationItem.rightBarButtonItem=confirm;
    rootFolderView.navigationItem.backBarButtonItem=back;
    rootFolderView.folderList = folderList;
    rootFolderView.moveFolder=_moveFolderPath;
    rootFolderView.path=[[Global currentUser] userResourcePath];
    _navigator = [[UINavigationController alloc] initWithRootViewController:rootFolderView];
    _navigator.view.frame = self.view.frame;
    rootFolderView.view.frame = _navigator.view.frame;
    [self.view addSubview:_navigator.view];
}

-(void)move:(id)sender{
    [self.delegate folderMove:[Global currentUser].userResourcePath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
