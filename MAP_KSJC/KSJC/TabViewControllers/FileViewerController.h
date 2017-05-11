//
//  FileViewerController.h
//  zzzf
//
//  Created by dist on 14-2-15.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileViewer.h"
#import "ServiceProvider.h"
#import "Global.h"
@interface FileViewerController : UIViewController<FileViewerDelegate,ServiceCallbackDelegate>{
    FileViewer *_fileViewer;
}
@property (nonatomic,strong) NSArray *files;
@property (nonatomic,strong) NSString *currentIndex;
@property (nonatomic,retain) NSString *fileName;
@property (nonatomic,retain) NSString *filePath;
@property (nonatomic,retain) NSString *fileExt;
@property (nonatomic,retain) NSString *isFromNetwork;
@property (nonatomic,retain) NSString *showSaveButton;
@property (nonatomic,retain) NSString *showDeleteButton;
@property (nonatomic,retain) NSString *maySavePath;

@end
