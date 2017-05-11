//
//  ResourceViewController.m
//  zf
//
//  Created by dist on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ResourceViewController.h"
#import "Global.h"



@implementation ResourceViewController


@synthesize showCloseButton = _showCloseButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [theManager setCloseButtonVisible:[self.showCloseButton isEqualToString:@"yes"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    theManager = [ResourceManagerView createView];
    theManager.frame = CGRectMake(0, 0, 1024, self.view.frame.size.height);
    [self.view addSubview:theManager];
    
    theManager.fileDelegate = self;
    theManager.managerDelegate = self;
    [theManager showLocalResource];
    self.navigationController.navigationBarHidden=false;
}

-(void)openFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext isLocalFile:(BOOL)isLocalFile{
    _toOpenFileExt=ext;
    _toOpenFileName=name;
    _toOpenFilePath=path;
    _isLocalFile = isLocalFile;
    //_strType=type;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}
#pragma -mark ----------
-(void)allFiles:(NSArray *)files at:(int)index
{
    NSDictionary *itemDic=[files objectAtIndex:index];
    _currentIndex=[NSString stringWithFormat:@"%d",index];
    _files=files;
    _toOpenFileName=[itemDic objectForKey:@"name"];
    _toOpenFilePath=[itemDic objectForKey:@"path"];
    _toOpenFileExt=@"jpg";
    if ([[itemDic objectForKey:@"uploaded"] isEqualToString:@"YES"]||[[itemDic objectForKey:@"uploaded"] isEqualToString:@"yes"]) {
        _isLocalFile=NO;
    }
    else
        _isLocalFile=YES;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *target = segue.destinationViewController;
    //FileViewController *target=segue.destinationViewController;
    [target setValue:_currentIndex forKey:@"currentIndex"];
    [target setValue:_files forKey:@"files"];
    [target setValue:_toOpenFileName forKey:@"fileName"];
    [target setValue:_toOpenFilePath forKey:@"filePath"];
    [target setValue:_toOpenFileExt forKey:@"fileExt"];
    [target setValue:_isLocalFile?@"NO":@"YES" forKey:@"isFromNetwork"];
    [target setValue:_isLocalFile?@"NO":@"YES" forKey:@"showSaveButton"];
    [target setValue:[[Global currentUser] userResourcePath] forKey:@"maySavePath"];
    //target.resCon=self;
    //target.fRView=(ResourcesView *)_rview;
    //[target setvalue:self forKey:@"ownController"];

}

-(NSString *)resouceManagerDirectory{
    return [[Global currentUser] userResourcePath];
}

-(void)resourceManagerShouldClose{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
