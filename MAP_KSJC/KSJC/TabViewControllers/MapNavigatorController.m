//
//  MapNavigatorController.m
//  zzzf
//
//  Created by Aaron on 14-3-3.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapNavigatorController.h"


@interface MapNavigatorController ()

@end

@implementation MapNavigatorController

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
	// Do any additional setup after loading the view.
    MapViewController *mapView = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    mapView.delegate = self;
    [self pushViewController:mapView animated:YES];
    self.navigationBarHidden=YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext{
    _toOpenFileName = name;
    _toOpenFileExt = ext;
    _toOpenFilePath = path;
    _isLocalFile = NO;
    _toOpenFiles = nil;
    
    [self performSegueWithIdentifier:@"fileView" sender:self];
}

-(void)mapShouldShowFiles:(NSArray *)files at:(int)index{
    _toOpenFiles = files;
    _toOpenFileIndex = index;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}

-(void)openMaterial:(NSString *)materialName path:(NSString *)path ext:(NSString *)ext fromLocal:(BOOL)fromLocal{
    _toOpenFileExt=ext;
    _toOpenFileName=materialName;
    _toOpenFilePath=path;
    _isLocalFile = fromLocal;
    _toOpenFiles = nil;
    //_strType=type;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *target = segue.destinationViewController;
    //FileViewController *target=segue.destinationViewController;
    [target setValue:_toOpenFileName forKey:@"fileName"];
    [target setValue:_toOpenFilePath forKey:@"filePath"];
    [target setValue:_toOpenFileExt forKey:@"fileExt"];
    [target setValue:_toOpenFiles forKey:@"files"];
    [target setValue:[NSString stringWithFormat:@"%d",_toOpenFileIndex] forKey:@"currentIndex"];
    [target setValue:_isLocalFile?@"NO":@"YES" forKey:@"isFromNetwork"];
    [target setValue:@"NO" forKey:@"showSaveButton"];
    
    //target.resCon=self;
    //target.fRView=(ResourcesView *)_rview;
    //[target setvalue:self forKey:@"ownController"];
}

@end
