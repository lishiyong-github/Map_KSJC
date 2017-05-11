//
//  FileViewController.h
//  gzOneMap
//
//  Created by zhangliang on 13-12-6.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FileDownload.h"
#import "FGalleryPhoto.h"
#import "FGalleryPhotoView.h"

@interface FileViewController : UIViewController<UIWebViewDelegate,FileDownloadDelegate,UIAlertViewDelegate,FGalleryPhotoDelegate>{
    NSString *_currentOpenFilePath;
    FGalleryPhotoView *_galleryPhotoView;
    FGalleryPhoto *_galleryPhoto;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnClose;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnRefersh;
@property (weak, nonatomic) IBOutlet UILabel *lblFIleName;
@property (weak, nonatomic) IBOutlet UIWebView *fileWebView;
@property(nonatomic,retain) IBOutlet UIScrollView *photoScrollView;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *fileWaiting;
@property(nonatomic,retain) IBOutlet UIProgressView *downProgressView;
@property(nonatomic,retain) IBOutlet UILabel *downProgressLabel;
@property (nonatomic,retain) NSString *fileName;
@property (nonatomic,retain) NSString *path;
@property (nonatomic,retain) NSString *ext;

- (IBAction)onBtnCloseTap:(id)sender;
- (IBAction)onBtnRefershTap:(id)sender;

@end
