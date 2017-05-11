//
//  ResourceViewController.h
//  zf
//
//  Created by dist on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResourceManagerView.h"
#import "ResourceManagerDelegate.h"

@interface ResourceViewController : UIViewController<OpenFileDelegate,ResourceManagerDataSourceDelegate>{
    NSString *_currentIndex;
    NSString *_toOpenFileName;
    NSString *_toOpenFilePath;
    NSString *_toOpenFileExt;
    NSArray *_files;
    BOOL _isLocalFile;
    ResourceManagerView *theManager;
}

@property (nonatomic,retain) NSString *showCloseButton;

@end
