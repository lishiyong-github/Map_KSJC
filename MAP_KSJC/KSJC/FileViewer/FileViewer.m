//
//  FileViewController.m
//  zzzf
//  
//  Created by dist on 13-11-22.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "FileViewer.h"
#import "Global.h"

static id<FileViewerDelegate> _globalDelegate;
static NSMutableDictionary *CACHE_FILES;

@implementation FileViewer
//UIAlertView *baseAlert;

@synthesize path=_path,fileName=_fileName,ext=_ext,delegate=_delegate;

-(void)initData{
    if (nil==CACHE_FILES) {
        CACHE_FILES = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (nil==_galleryPhotoView) {
        [self lblFileNameTextSet:self.fileName];
        _galleryPhotoView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero];
        _galleryPhotoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _galleryPhotoView.autoresizesSubviews = YES;
        [self.photoScrollView addSubview:_galleryPhotoView];
    }
    
}

+(FileViewer *) createView{
    
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"FileViewer" owner:nil options:nil];
    FileViewer *theView= [nibView objectAtIndex:0];
    return theView;
}

+(void)clearCache{
    [CACHE_FILES removeAllObjects];
}

-(void)setPagerMode:(int)fileCount currentCount:(int)curCount{
    if (fileCount>0) {
        _pageIndex = 0;
    }
    self.pagerView.delegate=self;
    self.pagerView.contentSize = CGSizeMake(fileCount*1024, 723);
    self.pagerView.contentOffset = CGPointMake(1024*[self getCurrentCount], 0);
    self.fileWebView.frame = CGRectMake(curCount*1024, 0, 1024, 732);
    self.photoScrollView.frame = CGRectMake(curCount*1024, 0, 1024,732);
}

-(void)openFileFromLocation:(NSString *)fileName filePath:(NSString *)filePath ext:(NSString *)ext{
    [self initData];
    self.path = filePath;
    self.fileName = fileName;
    self.ext = ext;
    [self openFile:filePath];
    [self lblFileNameTextSet:fileName];
}
#pragma -mark ----打开文件
-(void)openFiles:(NSArray *)files at:(int)index
{
    
    _index=index;
    
    NSDictionary *itemDic=[files objectAtIndex:index];
    
    self.fileName=[itemDic objectForKey:@"name"];
    NSString *filePath=[itemDic objectForKey:@"path"];
    NSString *ext=[itemDic objectForKey:@"ext"];
    if (ext==nil||[ext isEqualToString:@""]) {
        ext=@"jpg";
    }
    [self setPagerMode:files.count currentCount:index];
    _isNetwork=[itemDic objectForKey:@"uploaded"];
    
    BOOL isLocal = [[itemDic objectForKey:@"local"] isEqualToString:@"yes"];
    if (isLocal) {
        [self openFileFromLocation:self.fileName filePath:filePath ext:ext];
    }
//    else if ([_isNetwork isEqualToString:@"YES"]||[_isNetwork isEqualToString:@"yes"]) {
//        [self openFileFromNetwork:self.fileName url:filePath ext:ext];
//    }
    else{
        [self openFileFromLocation:self.fileName filePath:filePath ext:ext];
    }
}
#pragma -mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"---%f-page:--%d",scrollView.contentOffset.x,(int)scrollView.contentOffset.x/1024);
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    turnRight=scrollView.contentOffset.x;
    //CGFloat pageWidth = self.pagerView.frame.size.width;
    //_pageIndex = floor((self.pagerView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   // NSLog(@"----decelerate:-%f-dddddddd---",scrollView.contentOffset.x);
    /*
    CGFloat pageWidth = self.pagerView.frame.size.width;
    int newPageIndex = floor((self.pagerView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (_pageIndex==newPageIndex) {
        return;
    }*/
    
    int offsetX = turnRight-scrollView.contentOffset.x;
    if(abs(offsetX)<80)
        return;
    
    if (scrollView.contentOffset.x>scrollView.contentSize.width-1024) {
        self.pagerView.contentOffset = CGPointMake(1024*(_files.count-1), 0);
    }
    else if (scrollView.contentOffset.x<0)
    {
        self.pagerView.contentOffset = CGPointMake(0, 0);
    }
    int cur=(int)scrollView.contentOffset.x/1024;

    if (scrollView.contentOffset.x>turnRight) {
        cur=cur+1;
        if (cur>=_files.count) {
            cur=_files.count-1;
        }
    }
    
    _index=cur;
    
    NSDictionary *dic=[_files objectAtIndex:cur];
    
    if ([[dic objectForKey:@"local"]isEqualToString:@"yes"]) {
        NSString *fileName=[dic objectForKey:@"name"];
        NSString *filePath=[dic objectForKey:@"path"];
        NSString *fileExt=[dic objectForKey:@"ext"];
        if (fileExt==nil||[fileExt isEqualToString:@""]) {
            fileExt=@"jpg";
        }
        [self openFileFromLocation:fileName filePath:filePath ext:fileExt];
    }
   else if ([[dic objectForKey:@"uploaded"]isEqualToString:@"YES"]||[[dic objectForKey:@"uploaded"]isEqualToString:@"yes"]) {
        NSString *fileName=[dic objectForKey:@"name"];
        NSString *filePath=[dic objectForKey:@"path"];
       
       //NSString *filePath= [NSString stringWithFormat:@"%@?type=zf&action=getphoto&business=project&code=%@&thumbnail=no",[Global serviceUrl],[dic objectForKey:@"code"]];
        NSString *fileExt=[dic objectForKey:@"ext"];
        if (fileExt==nil||[fileExt isEqualToString:@""]) {
            fileExt=@"jpg";
        }
        [self openFileFromNetwork:fileName url:filePath ext:fileExt];
        
    }
    else if ([[dic objectForKey:@"uploaded"]isEqualToString:@"NO"]||[[dic objectForKey:@"uploaded"]isEqualToString:@"no"]){
        NSString *fileName=[dic objectForKey:@"name"];
        NSString *filePath=[dic objectForKey:@"path"];
        NSString *fileExt=[dic objectForKey:@"ext"];
        if (fileExt==nil||[fileExt isEqualToString:@""]) {
            fileExt=@"jpg";
        }
        [self openFileFromLocation:fileName filePath:filePath ext:fileExt];
    }
    
    self.fileWebView.frame = CGRectMake(cur*1024, 0, 1024, 732);
    self.photoScrollView.frame = CGRectMake(cur*1024, 0, 1024,732);
    
    NSString *text=[NSString stringWithFormat:@"%@    (%d/%d)",self.fileName,cur+1,_files.count];
    self.lblFIleName.text =text;//self.fileName;
    
}
-(int)getCurrentCount
{
    return _index;
}
-(void)openFileFromNetwork:(NSString *)fileName url:(NSString *)url ext:(NSString *)ext{
    [self initData];
    [self lblFileNameTextSet:fileName];
    self.path = url;
    self.ext = ext;
    self.fileName = fileName;
    _toSaveName = [fileName stringByDeletingPathExtension];

    self.pagerView.hidden = YES;
    self.btnRefersh.enabled = NO;
    NSString *cachePath = [CACHE_FILES objectForKey:url];
    if (nil!=cachePath) {
        [self openFile:cachePath];
    }else{
        _currentDownload = [[FileDownload alloc] init];
        _currentDownload.delegate=self;
        //_currentDownload = downTask;
        NSString *fileId = [Global newUuid];
        NSString *savePath = [_currentDownload download:[self.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] fileId:fileId fileExt:self.ext];
        //原则上这个savePath永远是nil，但这个逻辑是有效的
        if (nil!=savePath) {
            [self openFile:savePath];
        }
    }
}
-(void)openFilesFromNetwork:(NSArray *)files{
    [self setPagerMode:_files.count currentCount:[self getCurrentCount]];

}

-(void)setDownloadButtonVisible:(BOOL)visible{
    self.btnDownload.hidden = !visible;
}

-(void)setDeleteButtonVisible:(BOOL)visible{
    self.btnDelete.hidden = !visible;
}

- (IBAction)onBtnCloseTap:(id)sender {
    if (nil!=_currentDownload) {
        [_currentDownload cancel];
        _currentDownload = nil;
    }
    [self.delegate fileViewerDidClosed:self];
    
    [self clear];
}

-(void)clear{

    NSURL * url = [NSURL fileURLWithPath:@"about:blank"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.fileWebView loadRequest: request];

    
    [_galleryPhotoView setZoomScale:1 animated:NO];
    _galleryPhotoView.imageView.image = nil;
    _galleryPhotoView.frame = CGRectMake(0, 0, self.photoScrollView.frame.size.width, self.photoScrollView.frame.size.height );
}

- (IBAction)onBtnRefershTap:(id)sender {
    [self openFile:_currentOpenFilePath];
}

- (IBAction)onBtnDownload:(id)sender {
    _toSavePath = [self.delegate fileViewerShouldToSave:self name:[NSString stringWithFormat:@"%@.%@",_toSaveName,self.ext] path:_path];
    if (nil==_toSavePath) {
        UIAlertView *messageBox = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法保存，找不到存储路径" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [messageBox show];
        return;
    }
    NSFileManager *fileManager =[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_toSavePath]) {
        UIAlertView *messageBox = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已存在该文件 " delegate:self cancelButtonTitle:@"不下载" otherButtonTitles: @"覆盖",@"重命名",nil];
        messageBox.tag = 10;
        [messageBox show];
        return;
    }else{
        [self saveToPath];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.pagerView.frame.size.width;
    _pageIndex = floor((self.pagerView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
}


-(void)saveToPath{
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSError *error;
    [fileManager copyItemAtPath:_currentOpenFilePath toPath:_toSavePath error:&error];
    if (nil==error) {
        [self.delegate FileViewerDidSaved:self name:_fileName path:_toSavePath];
        UIAlertView *successMessage = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已保存到本地" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [successMessage show];
        self.btnDownload.hidden = YES;
    }else{
        UIAlertView *errorMessageBox = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"保存到本地失败:%@",error] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [errorMessageBox show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10) {
        if (buttonIndex==1) {
            [[NSFileManager defaultManager] removeItemAtPath:_toSavePath error:nil];
            [self saveToPath];
        }
        else if(buttonIndex==2){
            [self showRenameBox];
        }
    }else if(alertView.tag==1 && buttonIndex==1){
        [self deleteFile];
    }else if(alertView.tag==20 && buttonIndex==1){
        NSString *newName = [alertView textFieldAtIndex:0].text;
        if ([@"" isEqualToString:newName]) {
            [self showRenameBox];
        }else{
            _toSaveName = newName;
            [self onBtnDownload:self.btnDownload];
        }
    }
}

-(void)showRenameBox{
    UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"重命名" message:@"请输入新的名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
    comfirm.alertViewStyle = UIAlertViewStylePlainTextInput;
    [comfirm textFieldAtIndex:0].text = [self.fileName stringByDeletingPathExtension];
    [comfirm textFieldAtIndex:0].placeholder = [self.fileName stringByDeletingPathExtension];
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 60);
    [comfirm setTransform:myTransform];
    comfirm.tag = 20;
    [comfirm show];
}

-(void)deleteFile{
    
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:_currentOpenFilePath error:&error];
    if (nil==error) {
        [self.delegate fileViewerDidDeleted:self name:_fileName path:_currentOpenFilePath]; UIAlertView *successMessage = [[UIAlertView alloc] initWithTitle:@"提示" message:@"数据已移除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [successMessage show];
    }else{
        UIAlertView *errorMessageBox = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"移除数据失败:%@",error] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [errorMessageBox show];
    }
    
}

- (IBAction)onBtnDelete:(id)sender {
    
    UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确认要删除该文件吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertview.tag=1;
    [alertview show];
    alertview = nil;
}


-(void)download:(FileDownload *)dowanlod onFileDownloaded:(NSString *)fileId filePath:(NSString *)filePath{
    self.downProgressView.hidden=true;
    self.downProgressLabel.hidden=true;
    
    //根据网络URL缓存数据，以免再次下载
    [CACHE_FILES setValue:filePath forKey:self.path];
    [self openFile:filePath];
    _currentDownload = nil;
}

-(void)download:(FileDownload *)dowanlod onFileStartDownload:(NSString *)fileId{
    NSLog(@"start download");
    [self.downProgressLabel setFont:[UIFont systemFontOfSize:33]];
    self.downProgressView.hidden=false;
    self.downProgressLabel.hidden=false;
    self.downProgressLabel.text=@"0%";
}

-(void)download:(FileDownload *)dowanlod onFileDownloadFaild:(NSString *)fileId{
    NSLog(@"download faild");
    [self.downProgressLabel setFont:[UIFont systemFontOfSize:18]];
    self.downProgressLabel.text=@"打开失败";
    self.downProgressView.hidden=YES;
    self.pagerView.hidden = YES;
}

-(void)download:(FileDownload *)dowanlod updateProgress:(NSString *)fileId progress:(float)progressValue{
    self.downProgressView.progress=progressValue;
    int downlaodRate = (int)(progressValue*100);
    self.downProgressLabel.text=[NSString stringWithFormat:@"%d%%",downlaodRate];
}

-(void)openFile:(NSString *)localFilePath{
    _currentOpenFilePath = localFilePath;
    self.btnRefersh.enabled = YES;
    self.pagerView.hidden = NO;
    NSString *fileExt = [localFilePath pathExtension];
    if ([fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"bmp"]) {
        self.photoScrollView.hidden=NO;
        self.fileWebView.hidden=YES;
        [self openImageFromLocal:localFilePath];
        //_galleryPhoto = [[FGalleryPhoto alloc] initWithThumbnailPath:nil fullsizePath:localFilePath delegate:self];
        //[_galleryPhoto loadFullsize];
        
        
    }else{
        self.photoScrollView.hidden=YES;
        self.fileWebView.hidden = NO;
        NSURL * url = [NSURL fileURLWithPath:localFilePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.fileWebView loadRequest: request];
    }
}

- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadThumbnail:(UIImage*)image{
    
}
- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadFullsize:(UIImage*)image{
    //NSLog(@"didLoadFullsize");
    
}
-(void)openImageFromLocal:(NSString *)path{
    [_galleryPhotoView setZoomScale:1 animated:NO];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    _galleryPhotoView.imageView.image = img;
    _galleryPhotoView.frame = CGRectMake(0, 0, self.photoScrollView.frame.size.width, self.photoScrollView.frame.size.height );
    img = nil;
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.fileWaiting.hidden = YES;
    self.fileWebView.hidden = YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    self.fileWaiting.hidden = NO;
    self.fileWebView.hidden = YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.fileWaiting.hidden = YES;
    self.fileWebView.hidden = NO;
}
-(void)lblFileNameTextSet:(NSString *)fileName
{
    NSString *text=@"";
    if (_files!=nil) {
         text=[NSString stringWithFormat:@"%@    (%d/%d)",fileName,[self getCurrentCount]+1,_files.count];
    }
    else
        text=fileName;
    self.lblFIleName.text =text;//self.fileName;
}

@end
