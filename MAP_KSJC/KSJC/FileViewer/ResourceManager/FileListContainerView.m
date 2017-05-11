//
//  ResourcesView.m
//  zzzf
//
//  Created by mark on 13-11-27.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "FileListContainerView.h"
#import "ServiceProvider.h"
#import "FileCustomCell.h"
#import "FileModel.h"
#import "ResourceManagerView.h"
#import "MZFormSheetController.h"

@implementation FileListContainerView
MZFormSheetController *formSheet;
@synthesize dataSource,isFromLocal = _isFromLocal,deleteDic;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)load:(NSString *)path andKey:(NSString *)key{
    _fManager=[NSFileManager defaultManager];
    _path = path;
    _searchKey = key;
    if (self.isFromLocal) {
        //[self getFilesFromLocal:path];
        self.dataSource = [self getFilesFromLocal:path key:key];
        [self createFileSubViews];
    }else{
        self.dataSource=[[NSMutableArray alloc] init];
        ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
        NSString *type=@"resource";
        NSMutableDictionary *mutableDic=[NSMutableDictionary dictionaryWithCapacity:1];
        if (nil == key || [key isEqualToString:@""]) {
            [mutableDic setObject:@"getFiles" forKey:@"action"];
        }else{
            [mutableDic setObject:@"searchFiles" forKey:@"action"];
        }
        [mutableDic setObject:path forKey:@"pathName"];
        [mutableDic setObject:key forKey:@"fileName"];
        [sp getData:type parameters:mutableDic];
    }
}

-(void)refersh{
    [self load:_path andKey:_searchKey];
}

-(NSMutableArray *)getFilesFromLocal:(NSString *)path key:(NSString *)key{
    NSError *error;
    NSArray *contents = [_fManager contentsOfDirectoryAtPath:path error:&error];
    if (![key isEqualToString:@""]) {
        NSEnumerator *childFilesEnumerator = [[_fManager subpathsAtPath:path] objectEnumerator];
        contents=[childFilesEnumerator allObjects];
    }
    if (nil!=error) {
        return [NSMutableArray arrayWithObjects: nil];
    }
    NSMutableArray *directories = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:10];
    BOOL isDir = NO;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.dataSource=[[NSMutableArray alloc] init];
    
    for (NSString *item in contents) {
        if (![key isEqualToString:@""]){
            NSRange range=[item rangeOfString:key];
            if (range.length==0)
                continue;
        }
        NSString *fp = [path stringByAppendingPathComponent:item];
        NSArray *ar=[item componentsSeparatedByString:@"/"];
        NSString *name=ar.lastObject;
        [_fManager fileExistsAtPath:fp isDirectory:(&isDir)];
        NSDictionary *fileAttributes = [_fManager attributesOfItemAtPath:fp error:nil];
        NSString *dateString = [formatter stringFromDate:[fileAttributes objectForKey:@"NSFileModificationDate"]];
        
        FileModel *fModel=nil;
        
        if (isDir) {
            fModel = [[FileModel alloc] initWithFile:@"directory" fileName:name fileLength:@"" fileDate:dateString fileType:@""];
            fModel.filePath=fp;
            if ([key isEqualToString:@""]) {
                [directories addObject:fModel];//搜索模式，不需要文件夹
            }
        }else{
            long fileSize = [[fileAttributes objectForKey:@"NSFileSize"] longValue];
            NSString *sizeString = @"";
            long kb=fileSize/1024;
            if (kb>1024) {
                long mb = kb/1024;
                sizeString = [NSString stringWithFormat:@"%ldMB",mb];
            }else{
                sizeString = [NSString stringWithFormat:@"%ldKB",kb];
            }
            fModel = [[FileModel alloc] initWithFile:@"file" fileName:name fileLength:sizeString fileDate:dateString fileType:[fp pathExtension]];
            fModel.filePath=fp;
            [files addObject:fModel];
        }
        isDir = NO;
    }
    [directories addObjectsFromArray:files];
    return directories;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"FileCustomCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
    }
    FileCustomCell *cell=[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    NSUInteger row=[indexPath row];
    FileModel *fModel=[self.dataSource objectAtIndex:row];
    cell.strImgFileName=[fModel fileType];
    cell.FileName=[fModel fileName];
    cell.FileLength=[fModel fileLength];
    cell.FileDate=[fModel fileDate];
    
    if(self.isFromLocal){
        UILongPressGestureRecognizer *longPressGesture=
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
        [cell addGestureRecognizer:longPressGesture];
    }
    
    return cell;
}

- (void)cellLongPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [recognizer locationInView:self];
        NSIndexPath * indexPath = [_tableView indexPathForRowAtPoint:location];
        NSLog(@"%d",[indexPath row]);
        if (!_tableView.editing) {
            deleteDic=[NSMutableDictionary dictionaryWithCapacity:10];
            [deleteDic setObject:[dataSource objectAtIndex:[indexPath row]] forKey:indexPath];
        }
        FileCustomCell *cell = (FileCustomCell *)recognizer.view;
        [cell becomeFirstResponder];
        UIMenuItem *itCopy = [[UIMenuItem alloc] initWithTitle:@"移到" action:@selector(handleMove:)];
        UIMenuItem *itDelete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(handleDelete:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:itCopy, itDelete,  nil]];
        [menu setTargetRect:cell.frame inView:self];
        [menu setMenuVisible:YES animated:YES];
        
    }
}

- (void)handleMove:(id)sender{
    NSArray *fileList=[[NSArray alloc] init];
    fileList=[_fManager contentsOfDirectoryAtPath:[[Global currentUser] userResourcePath] error:nil];
    NSMutableArray *folderList=[[NSMutableArray alloc] init];
    BOOL isDir=NO;
//    NSArray *deleteArray=[deleteDic allValues];
//    [dataSource removeObjectsInArray:deleteArray];
//    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithArray:[deleteDic allKeys]] withRowAnimation:UITableViewRowAnimationFade];
//    
//    for (int i=0; i<deleteArray.count; i++) {
//        FileModel *f=[deleteArray objectAtIndex:i];
//        if (![_fManager removeItemAtPath:[_path stringByAppendingPathComponent:f.fileName] error:nil]) {
//            NSLog(@"remove_error_%@",[_path stringByAppendingPathComponent:f.fileName]);
//        }
//    }
    for (NSString *file in fileList) {
         NSString *path=[[[Global currentUser] userResourcePath] stringByAppendingPathComponent:file];
        [_fManager fileExistsAtPath:path isDirectory:(&isDir)];
        if (isDir) {
            [folderList addObject:file];
        }
        isDir=NO;
    }
    FolderSelectorViewController *folderSelectorController = [[FolderSelectorViewController alloc] initWithNibName:@"FolderSelectorViewController" bundle:nil];
    folderSelectorController.delegate=self;
    folderSelectorController.moveFolderPath=(NSMutableArray *)[deleteDic allValues];
    formSheet = [[MZFormSheetController alloc] initWithViewController:folderSelectorController];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    //formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 8.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 150;
    formSheet.presentedFormSheetSize = CGSizeMake(300, 400);
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (void)handleDelete:(id)sender{
    NSArray *deleteArray=[deleteDic allValues];
    [dataSource removeObjectsInArray:deleteArray];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithArray:[deleteDic allKeys]] withRowAnimation:UITableViewRowAnimationFade];
    
    for (int i=0; i<deleteArray.count; i++) {
        FileModel *f=[deleteArray objectAtIndex:i];
        if (![_fManager removeItemAtPath:[_path stringByAppendingPathComponent:f.fileName] error:nil]) {
            NSLog(@"remove_error_%@",[_path stringByAppendingPathComponent:f.fileName]);
        }
    }
    [deleteDic removeAllObjects];
}


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return [self.dataSource count];
 
}

//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //return [indexPath row];
//    return 0;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    if ([indexPath row] % 2 == 0) {
//    //        cell.backgroundColor = [UIColor blueColor];
//    //    } else {
//    //        cell.backgroundColor = [UIColor greenColor];
//    //    }
//}
#pragma -mark 创建数组
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //制造数组（字典）
    NSMutableArray *_allfiles=[NSMutableArray array];
    for (int i=0; i<self.dataSource.count; i++) {
        FileModel *fModel=[self.dataSource objectAtIndex:i];
        NSMutableDictionary *itemDic=[NSMutableDictionary dictionary];
        [itemDic setObject:fModel.fileName forKey:@"name"];
        [itemDic setObject:fModel.fileType forKey:@"ext"];
        [itemDic setObject:fModel.fileDate forKey:@"time"];

        NSString *isOnline=@"";
        if (_owner.isOnlineRsource==NO) {
            isOnline=@"NO";
            [itemDic setObject:fModel.filePath forKey:@"path"];
        }
        else if(_owner.isOnlineRsource==YES){
            isOnline=@"YES";
//            NSString *p=[NSString stringWithFormat:@"%@?type=download&path=%@",[Global serviceUrl],[_path stringByAppendingFormat:@"//%@", fModel.fileName]];
            NSString *p=[NSString stringWithFormat:@"%@?type=download&path=%@",[Global tempUrl],[_path stringByAppendingFormat:@"//%@", fModel.fileName]];
            [itemDic setObject:p forKey:@"path"];
        }
        [itemDic setObject:isOnline forKey:@"uploaded"];
        [_allfiles addObject:itemDic];
    }
    
    NSUInteger row=[indexPath row];
    
    FileModel *fModel=[self.dataSource objectAtIndex:row];
    if (_tableView.editing) {
        [deleteDic setObject:fModel forKey:indexPath];
    }else{
        
        [self.resourceDelegate allResource:_allfiles atIndex:row];
        
        //[self.resourceDelegate fileItemDidTap:fModel.fileName type:fModel.fileType path:fModel.filePath];
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataSource removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.deleteDic removeObjectForKey:[dataSource objectAtIndex:[indexPath row]]];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    
}
-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    if ([data objectForKey:@"sucess"]) {
        NSArray *rs=[data objectForKey:@"result"];
        for (NSDictionary *item in rs) {
            FileModel *fModel=[[FileModel alloc] initWithFile:[item objectForKey:@"type"] fileName:[item objectForKey:@"name"] fileLength:[item objectForKey:@"length"] fileDate:[item objectForKey:@"creationTime"] fileType:[item objectForKey:@"extension"]];
            NSString *f=[item objectForKey:@"filePath"];
            fModel.filePath=[f stringByReplacingOccurrencesOfString:@">>" withString:@"//"];
            [self.dataSource addObject:fModel];
        }
    }
    [self createFileSubViews];
}

-(void)createFileSubViews{
    double xNum=0,yNum=0,xSize=100,ySize=140;
    int i=0;
    int gap = 10;
    FileItemThumbnailView  *resView=nil;
    if (nil!=_thumibnailsContainer) {
        [_thumibnailsContainer removeFromSuperview];
        _thumibnailsContainer = nil;
    }
    _thumibnailsContainer=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    int columnCount = (int)self.bounds.size.width/(xSize+gap);
    for(FileModel *f in self.dataSource){
        xNum=i%columnCount;
        yNum=i/columnCount;
        resView=[[FileItemThumbnailView alloc] initWithFrame:CGRectMake(xNum*xSize+gap*xNum+gap
                                                                        , yNum*ySize+yNum*gap, xSize, ySize)];
        resView.delegate = self.resourceDelegate;
        [resView load:f.fileName andType:f.fileType andFile:f.filePath];
        //[self addSubview:resView];
        [_thumibnailsContainer addSubview:resView];
        i++;
    }
    
    _thumibnailsContainer.contentSize=CGSizeMake(self.frame.size.width, (yNum+1)*ySize+yNum*gap);
    //self.contentSize=CGSizeMake(480, (yNum+1)*ySize);
    if (nil==_tableView) {
        _tableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:_tableView];
    }else{
        [_tableView reloadData];
    }
    
    [self addSubview:_thumibnailsContainer];
    
    //tableViewFile.hidden=self.owner.intStyle==0?true:false;
    //view1.hidden=self.owner.intStyle==0?false:true;
    if (self.viewType==1) {
        [self showThumbnails];
    }else{
        [self showDetails];
    }
}


-(void) serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    NSLog(@"FileListContainerView has error:serviceCallback");
}

-(void)showDetails{
    _thumibnailsContainer.hidden=true;
    _tableView.hidden=false;
    self.viewType = 2;
}

-(void)showThumbnails{
    _thumibnailsContainer.hidden=false;
    _tableView.hidden=true;
    self.viewType = 1;
}

-(void)editTableView{
    deleteDic=[NSMutableDictionary dictionaryWithCapacity:5];
    if (_tableView.editing) {
        [_tableView setEditing:NO animated:YES];
    }else{
        [_tableView setEditing:YES animated:YES];
    }
    
}

-(void)deleteResource{
    NSArray *deleteArray=[deleteDic allValues];
    [dataSource removeObjectsInArray:deleteArray];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithArray:[deleteDic allKeys]] withRowAnimation:UITableViewRowAnimationFade];
    
    for (int i=0; i<deleteArray.count; i++) {
        FileModel *f=[deleteArray objectAtIndex:i];
        if (![_fManager removeItemAtPath:[_path stringByAppendingPathComponent:f.fileName] error:nil]) {
            NSLog(@"remove_error_%@",[_path stringByAppendingPathComponent:f.fileName]);
        }
    }
    
    
    [deleteDic removeAllObjects];
}

-(void) addFolder:(NSString *)folerName{
    NSDate *today=[NSDate date];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *strToday=[formatter stringFromDate:today];
    NSString *addResourceFolderPath=[_path stringByAppendingPathComponent:folerName];
    FileModel *fModel=[[FileModel alloc]  initWithFile:@"directory" fileName:folerName fileLength:@"" fileDate:strToday fileType:@""];
    fModel.filePath=addResourceFolderPath;
    [dataSource insertObject:fModel atIndex:0];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    [_tableView endUpdates];
    
    [_fManager createDirectoryAtPath:addResourceFolderPath withIntermediateDirectories:YES attributes:Nil error:Nil];
}
-(void)folderMove:(NSString *)toPath{
    if (![toPath isEqualToString:_path]){
        NSArray *fModels=[deleteDic allValues];
        for (int i=0; i<fModels.count; i++) {
            FileModel *fModel=[fModels objectAtIndex:i];
            NSString *filePath=[_path stringByAppendingPathComponent:fModel.fileName];
            
            NSEnumerator *childFilesEnumerator = [[_fManager subpathsAtPath:filePath] objectEnumerator];
            NSArray *arr= [filePath componentsSeparatedByString:@"/"];
            NSString *str=[arr lastObject];
            NSString* fileName;
            while ((fileName = [childFilesEnumerator nextObject]) != nil){
                NSString *from = [filePath stringByAppendingPathComponent:fileName];
                NSString *to=[toPath stringByAppendingFormat:@"/%@/%@",str,fileName];
                if (![_fManager moveItemAtPath:from toPath:to error:nil]) {
                    NSLog(@"error_%@",from);
                }
            }

            if(![_fManager moveItemAtPath:filePath toPath:[toPath stringByAppendingPathComponent:fModel.fileName] error:nil]){
                NSLog(@"error_%@",filePath);
            }
            
        }

        [dataSource removeObjectsInArray:fModels];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithArray:[deleteDic allKeys]] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    [deleteDic removeAllObjects];
    [formSheet dismissAnimated:NO completionHandler:nil];
}

@end
