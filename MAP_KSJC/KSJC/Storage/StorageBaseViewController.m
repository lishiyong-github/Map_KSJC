//
//  StorageBaseViewController.m
//  zzzf
//
//  Created by mark on 14-2-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "StorageBaseViewController.h"
#import "StorageItemCell.h"
#import "StorageItemInfo.h"
#import "FileViewer.h"

@implementation StorageBaseViewController


static NSString *cellIdentifier = @"StorageCellIdentifier";
static BOOL nibsRegistered = NO;

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
//     NSString *userProjectPath=[Global currentUser].userProjectPath;
//    NSString *userResources=[Global currentUser].userResourcePath;
//    float floatProjectSize=[self folderSizeAtPath:userProjectPath];
//    float floatResourcesSize=[self folderSizeAtPath:userResources];
//    NSString *stringProjectSize=[NSString stringWithFormat:@"%.1fkb",floatProjectSize];
//    NSString *stringResourcesSize=[NSString stringWithFormat:@"%.1fkb",floatResourcesSize];
//    source = [NSMutableArray arrayWithCapacity:4];
//    [source addObject:[[StorageItemInfo alloc] initWithInfo:1 titleString:@"已下载的项目" sizeString:stringProjectSize]];
//    [source addObject:[[StorageItemInfo alloc] initWithInfo:2 titleString:@"系统缓存" sizeString:@"22MB"]];
//    [source addObject:[[StorageItemInfo alloc] initWithInfo:3 titleString:@"资料" sizeString:stringResourcesSize]];
//    [source addObject:[[StorageItemInfo alloc] initWithInfo:4 titleString:@"地图数据" sizeString:@"1.2G"]];
    NSDictionary *fsAttr = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    _diskSize = [[fsAttr objectForKey:NSFileSystemSize] doubleValue];
    _lblTotalSize.text=[NSString stringWithFormat:@"总容量：%.1fG",_diskSize/1024/1024/1024];
    self.tableStorage.dataSource=self;
    self.tableStorage.delegate=self;
}
-(void)viewWillAppear:(BOOL)animated{
    [self refresh];
}

-(void)refresh{
    NSString *userProjectPath=[Global currentUser].userProjectPath;
    NSString *userResources=[Global currentUser].userResourcePath;
    NSString *tempPath=NSTemporaryDirectory();
    float floatProjectSize=[self folderSizeAtPath:userProjectPath];
    float floatResourcesSize=[self folderSizeAtPath:userResources];
    float floatTempSize=[self folderSizeAtPath:tempPath];
    float workTempSize = [self folderSizeAtPath:[Global currentUser].userWorkTempPath];
    float workCacheProjectSize = [self folderSizeAtPath:[Global currentUser].userProjectPath];
    float sunCacheSize = workTempSize+workCacheProjectSize;
    
    float floatTotalSize=floatProjectSize+floatResourcesSize+floatTempSize+sunCacheSize;
    
    NSString *str=[NSString stringWithFormat:@"已用：%@",[StorageItemInfo fileSizeString:floatTotalSize]];
    _lblUseSize.text=str;
    
    float width=300/_diskSize *floatTotalSize;
    width=width<1?1:width;
    CGRect origionRect = _viewUseSize.frame;
    CGRect newRect=CGRectMake(origionRect.origin.x, origionRect.origin.y
                              , width, origionRect.size.height);
    _viewUseSize.frame=newRect;
    //NSString *stringProjectSize=[NSString stringWithFormat:@"%.1fkb",floatProjectSize];
    //NSString *stringResourcesSize=[NSString stringWithFormat:@"%@",floatResourcesSize];
    //NSString *stringTempSize=[NSString stringWithFormat:@"%.1fkb",floatTempSize];
    source = [NSMutableArray arrayWithCapacity:3];
    
    //[source addObject:[[StorageItemInfo alloc] initWithInfo:1 titleString:@"下载的项目" sizeString:stringProjectSize]];
    [source addObject:[[StorageItemInfo alloc] initWithInfo:1 titleString:@"临时文件" size:floatTempSize]];
    [source addObject:[[StorageItemInfo alloc] initWithInfo:2 titleString:@"系统缓存" size:sunCacheSize]];
    [source addObject:[[StorageItemInfo alloc] initWithInfo:3 titleString:@"资料" size:floatResourcesSize]];
    
    //[source addObject:[[StorageItemInfo alloc] initWithInfo:4 titleString:@"地图数据" sizeString:@"3200kb"]];
    [self.tableStorage reloadData];

    for (UIView *u in self.view.subviews) {
        if (u.tag==23) {
            [u removeFromSuperview];
        }
    }
    PieChartViewController *pieChart=[PieChartViewController alloc];
    pieChart.arrData=source;
    pieChart=[pieChart init];
    pieChart.view.tag=23;
    [self.view addSubview:pieChart.view];
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
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    //return folderSize/(1024.0*1024.0);
    return folderSize;
}
//单个文件大小
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"StorageItemCell" bundle:nil];
        [self.tableStorage registerNib:nib forCellReuseIdentifier:cellIdentifier];
        nibsRegistered = YES;
    }
    
    StorageItemCell *cell = [self.tableStorage dequeueReusableCellWithIdentifier:cellIdentifier];
    NSUInteger row = [indexPath row];
    StorageItemInfo *item = [source objectAtIndex:row];
    /*
    if ([indexPath row]==1||[indexPath row]==3) {
        cell.imgArrows.hidden=YES;
        UILongPressGestureRecognizer *longPressGesture=
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
        [cell addGestureRecognizer:longPressGesture];
    }*/
    [cell setStorageInfo:item];
    cell.delegate = self;
    return cell;
}

- (void)cellLongPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [recognizer locationInView:self.tableStorage];
        NSIndexPath * indexPath = [_tableStorage indexPathForRowAtPoint:location];
        introw=[indexPath row];
        StorageItemCell *cell = (StorageItemCell *)recognizer.view;
        [cell becomeFirstResponder];
        UIMenuItem *itDelete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(handleDelete:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:itDelete,  nil]];
        [menu setTargetRect:cell.frame inView:self.tableStorage];
        [menu setMenuVisible:YES animated:YES];
    }
}

-(void)handleDelete:(id)sender{
    if (introw==1) {
        NSFileManager *fManager=[NSFileManager defaultManager];
        if (![fManager removeItemAtPath:NSTemporaryDirectory() error:nil]) {
            NSLog(@"error_remove_%@",NSTemporaryDirectory());
        }
        [self refresh];
    }else if(introw==3){
        ;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return source.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return;
    introw=[indexPath row];
    if ([indexPath row]==0) {
        [self showProjectStorageInfo];        
    }else if([indexPath row]==2){
        self.tabBarController.selectedIndex=4;
    }
}

-(void)showProjectStorageInfo{
    if (nil==_projectStorageInfo) {
        _projectStorageInfo = [[ProjectStorageViewController alloc] initWithNibName:@"ProjectStorageViewController" bundle:nil];
    }
    [self.navigationController pushViewController:_projectStorageInfo animated:YES];
}

-(void)storageShouldClearAt:(int)index{
    if (index==1) {
        [self removeFileFromPath:NSTemporaryDirectory()];
        [FileViewer clearCache];
    }else if(index==2){
        [self removeFileFromPath:[Global currentUser].userWorkTempPath];
        [self removeFileFromPath:[Global currentUser].userProjectPath];
    }else{
        self.tabBarController.selectedIndex=3;
    }
    [self refresh];
}

-(void)removeFileFromPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        [fileManager removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
    }
}

@end
