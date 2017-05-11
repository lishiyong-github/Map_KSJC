//
//  FolderViewController.m
//  zzzf
//
//  Created by mark on 14-2-23.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "FolderViewController.h"
static NSString *CELLIDENTIFY=@"FolderCell";
@interface FolderViewController ()

@end

@implementation FolderViewController
@synthesize folderList = _folderList;

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
    _tableView.delegate = self;
    _tableView.dataSource = self;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FolderCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY];
    if (nil==cell) {
        UINib *nib = [UINib nibWithNibName:@"FolderCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CELLIDENTIFY];
        cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY];
        
    }
    NSUInteger row = [indexPath row];
    NSString *strfolerName=[_folderList objectAtIndex:row];
    cell.lblFolderName.text=strfolerName;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _folderList.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *folderName=[_folderList objectAtIndex:[indexPath row]];
    _nextPath=[_path stringByAppendingPathComponent:folderName];
    NSFileManager *fManager=[NSFileManager defaultManager];
    NSArray *fileList=[[NSArray alloc] init];
    fileList=[fManager contentsOfDirectoryAtPath:_nextPath error:nil];
    NSMutableArray *folderList=[[NSMutableArray alloc] init];
    BOOL isDir=NO;
    for (NSString *file in fileList) {
        NSString *path=[_nextPath stringByAppendingPathComponent:file];
        [fManager fileExistsAtPath:path isDirectory:(&isDir)];
        if (isDir) {
            for (FileModel *f in _moveFolder) {
                if (![f.filePath isEqualToString:path]) {
                    [folderList addObject:file];
                }
            }
        }
        isDir=NO;
    }
    UIBarButtonItem *confirm=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(move:)];
    UIBarButtonItem *back=[[UIBarButtonItem alloc] initWithTitle:@"上级" style:UIBarButtonItemStyleBordered target:self action:nil];
    FolderViewController *nextFolderView = [[FolderViewController alloc] initWithNibName:@"FolderViewController" bundle:nil];
    nextFolderView.delegate=self.delegate;
    nextFolderView.view.frame = self.view.frame;
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.font=[UIFont systemFontOfSize:12];
    lblTitle.text=folderName;
    lblTitle.backgroundColor=[UIColor clearColor];
    nextFolderView.navigationItem.titleView=lblTitle;
    nextFolderView.folderList = folderList;
    nextFolderView.moveFolder=_moveFolder;
    nextFolderView.path=_nextPath;
    nextFolderView.navigationItem.rightBarButtonItem=confirm;
    nextFolderView.navigationItem.backBarButtonItem=back;
    [self.navigationController pushViewController:nextFolderView animated:YES];
}

-(void)move:(id)sender{
    [self.delegate folderMove:_nextPath];
}

-(void)test:(NSString *)path{
    ;
}

-(void)setFolderList:(NSMutableArray *)folderList{
    _folderList=folderList;
    [_tableView reloadData];
}

-(void)setPath:(NSString *)path{
    _path=path;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnBack:(id)sender {
}

- (IBAction)onBtnConfirm:(id)sender {
}
@end
