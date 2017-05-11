//
//  FileViewerController.m
//  zzzf
//
//  Created by dist on 14-2-15.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "FileViewerController.h"

@interface FileViewerController ()

@end

@implementation FileViewerController

@synthesize files = _files;
@synthesize fileName = _fileName;
@synthesize filePath = _filePath;
@synthesize fileExt = _fileExt;
@synthesize isFromNetwork = _isFromNetwork;
@synthesize showDeleteButton = _showDeleteButton;
@synthesize showSaveButton = _showSaveButton;
@synthesize maySavePath = _maySavePath;

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
    _fileViewer = [FileViewer createView];
    _fileViewer.files=_files;
    _fileViewer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _fileViewer.delegate = self;
    [self.view addSubview:_fileViewer];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated{

    [_fileViewer setDownloadButtonVisible:[self.showSaveButton isEqualToString:@"YES"]];
    [_fileViewer setDeleteButtonVisible:[self.showDeleteButton isEqualToString:@"YES"]];
    
// 合并  打开多个文件
    if (nil!=_files) {
        [_fileViewer openFiles:_files at:[_currentIndex intValue]];
    }
    else{
        if ([_isFromNetwork isEqualToString:@"YES"]||[_isFromNetwork isEqualToString:@"yes"]) {
            [_fileViewer openFileFromNetwork:self.fileName url:_filePath ext:_fileExt];
        }else{
            [_fileViewer openFileFromLocation:self.fileName filePath:_filePath ext:_fileExt];
        }
    }
    

}

-(void)fileViewerDidClosed:(FileViewer *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)fileViewerDidDeleted:(FileViewer *)sender name:(NSString *)name path:(NSString *)path{
    
}

-(void)FileViewerDidSaved:(FileViewer *)sender name:(NSString *)name path:(NSString *)path{
    NSLog(@"保存成功");
    //写入日志
    NSString *onLinePath=[[_filePath componentsSeparatedByString:@"&path=//"] lastObject];
    ServiceProvider *logService=[ServiceProvider initWithDelegate:self];
    NSMutableDictionary *dicPara=[[NSMutableDictionary alloc] init];
    [dicPara setObject:@"newlog" forKey:@"action"];
    [dicPara setObject:@"F" forKey:@"LogType"];
    [dicPara setObject:[Global currentUser].username  forKey:@"UserName"];
    [dicPara setObject:_fileName forKey:@"DownLoadFile"];
    [dicPara setObject:onLinePath forKey:@"DownLoadFilePath"];
    [logService getData:@"zf" parameters:dicPara];
}

-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    ;
}
-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data
{
    ;
}
-(void) serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    ;
}

-(NSString *)fileViewerShouldToSave:(FileViewer *)sender name:(NSString *)name path:(NSString *)path{
    if (nil==self.maySavePath) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@",self.maySavePath,name];
}

@end
