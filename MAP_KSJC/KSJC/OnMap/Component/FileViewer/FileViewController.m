//
//  FileViewController.m
//  gzOneMap
//
//  Created by zhangliang on 13-12-6.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "FileViewController.h"

@interface FileViewController ()

@end

@implementation FileViewController

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
    // Do any additional setup after loading the view from its nib.
    
    _galleryPhotoView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero];
    _galleryPhotoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _galleryPhotoView.autoresizesSubviews = YES;
    
    [self.photoScrollView addSubview:_galleryPhotoView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onBtnCloseTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBtnRefershTap:(id)sender {
    
}

-(void)viewDidAppear:(BOOL)animated{
    self.lblFIleName.text = self.fileName;
    
    [self.fileWebView loadHTMLString:@"<html><body></body></html>" baseURL:nil];
    _galleryPhotoView.imageView.image = nil;
    
    FileDownload *downTask=[[FileDownload alloc] init];
    downTask.delegate=self;
    
    self.fileWebView.hidden = YES;
    self.photoScrollView.hidden= YES;
    
    NSString *fileId = [[[self.path stringByReplacingOccurrencesOfString:@"\\" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString *savePath = [downTask download:[self.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] fileId:fileId fileExt:self.ext];
    if (nil!=savePath) {
        [self openFile:savePath];
    }
}

-(void)download:(FileDownload *)dowanlod onFileDownloaded:(NSString *)fileId filePath:(NSString *)filePath{
    self.downProgressView.hidden=true;
    self.downProgressLabel.hidden=true;
    [self openFile:filePath];
    
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
}

-(void)download:(FileDownload *)dowanlod updateProgress:(NSString *)fileId progress:(float)progressValue{
    self.downProgressView.progress=progressValue;
    int downlaodRate = (int)(progressValue*100);
    self.downProgressLabel.text=[NSString stringWithFormat:@"%d%%",downlaodRate];
}

-(void)openFile:(NSString *)localFilePath{
    _currentOpenFilePath = localFilePath;
    NSString *fileExt = [localFilePath pathExtension];
    if ([fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"bmp"]) {
        self.photoScrollView.hidden=NO;
        self.fileWebView.hidden=YES;
        
        _galleryPhoto = [[FGalleryPhoto alloc] initWithThumbnailPath:localFilePath fullsizePath:localFilePath delegate:self];
        [_galleryPhoto loadFullsize];
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
    [_galleryPhotoView setZoomScale:1 animated:NO];
    _galleryPhotoView.imageView.image = photo.fullsize;
    _galleryPhotoView.frame = CGRectMake(0, 0, self.photoScrollView.frame.size.width, self.photoScrollView.frame.size.height );
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.fileWaiting.hidden = YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    self.fileWaiting.hidden = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.fileWaiting.hidden = YES;
}

@end
