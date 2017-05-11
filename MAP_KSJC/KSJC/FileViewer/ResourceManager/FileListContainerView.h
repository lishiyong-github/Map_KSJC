//
//  ResourcesView.h
//  zzzf
//
//  Created by mark on 13-11-27.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"
#import "FileItemThumbnailView.h"
#import "ResourceManagerDelegate.h"
#import "SysButton.h"
#import "Global.h"
#import "FolderSelectorViewController.h"


@class ResourceManagerView;

@interface FileListContainerView : UIView<ServiceCallbackDelegate,UITableViewDataSource,UITableViewDelegate,FolderMoveDelegate>{
    NSString *_path;
    NSString *_searchKey;
    UIScrollView *_thumibnailsContainer;
    UITableView *_tableView;
    NSFileManager *_fManager;
}

@property ResourceManagerView *owner;
-(void) load:(NSString *)path andKey:(NSString *)key;
-(void) showThumbnails;
-(void) showDetails;
-(void) refersh;
-(void) editTableView;
-(void) deleteResource;
-(void) addFolder:(NSString *)folerName;

@property (strong,nonatomic) NSMutableArray *dataSource;
@property (strong,nonatomic) NSMutableDictionary *deleteDic;
@property (nonatomic,retain) id<FileItemThumbnailDelegate> resourceDelegate;
@property int viewType;
@property BOOL isFromLocal;
@end
