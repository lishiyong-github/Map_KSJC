//
//  MapJobViewController.h
//  zzzf
//
//  Created by mark on 14-3-3.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JobDetailView.h"
#import "ServiceProvider.h"
#import "FileViewerController.h"
@protocol MapJobViewControllerDelegate <NSObject>

@optional
-(void)mapJobViewShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext;
-(void)mapJobViewShouldShowFiles:(NSArray *)materials at:(int)index;
@end

@interface MapJobViewController : UIViewController<ServiceCallbackDelegate,JobDetailViewDelegate>{
    JobDetailView *_jobDetailView;
    
    //下载
    NSString *_toOpenFileName;
    NSString *_toOpenFilePath;
    NSString *_toOpenFileExt;
    BOOL _isLocalFile;
    
    NSArray *_toOpenFiles;
    int _toOpenFileIndex;
    
    
    
    
}
@property (nonatomic,retain) id<MapJobViewControllerDelegate> delegate;
@property BOOL defaultDsiplayForm;
@property (nonatomic,retain) NSString *projectID;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,strong)NSDictionary *project;
 //区别地图上筛选的数据是巡查记录和批后跟踪(是否需要提前请求数据)
@property (nonatomic,assign)BOOL xclog;
//用来记录是在在建巡查中跳转的  主要为了区别跳转方式
@property (nonatomic,assign)BOOL zjxcLog;


- (void)loadbaseProjectWithpid:(NSString *)pid andTime:(NSString *)time withDict:(NSDictionary *)dict;
@end
