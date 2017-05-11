//
//  LeaderNavigationViewController.m
//  zzzf
//
//  Created by dist on 14-3-7.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "LeaderNavigationViewController.h"

@interface LeaderNavigationViewController ()

@end

@implementation LeaderNavigationViewController

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
    OMapViewController *om = [[OMapViewController alloc] initWithNibName:@"OMapViewController" bundle:nil];
    om.view.frame = self.view.frame;
    [self pushViewController:om animated:NO];
    om.delegate = self;
    self.navigationBarHidden=YES;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)oMapShouldShowResource{
    toShowResourceView = YES;
    [self performSegueWithIdentifier:@"resource" sender:self];
}


-(void)oMapShouldSHowZZYD{
    toShowResourceView = NO;
    [self performSegueWithIdentifier:@"zzyd" sender:self];
}

-(void)oMapShouldShowFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext{
    _toOpenFileName = name;
    _toOpenFileExt = ext;
    _toOpenFileUrl = path;
    toFileView = YES;
    _toOpenFiles = nil;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}

-(void)oMapShouldShowFiles:(NSArray *)files at:(int)index{
    _toOpenFiles = files;
    _toOpenFileIndex = index;
    toFileView = YES;
    [self performSegueWithIdentifier:@"fileView" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (toShowResourceView) {
        toShowResourceView = NO;
        UIViewController *target = segue.destinationViewController;
        [target setValue:@"yes" forKey:@"showCloseButton"];
    }else if(toFileView){
        toFileView = NO;
        UIViewController *target = segue.destinationViewController;
        [target setValue:_toOpenFileName forKey:@"fileName"];
        [target setValue:_toOpenFileUrl forKey:@"filePath"];
        [target setValue:_toOpenFileExt forKey:@"fileExt"];
        [target setValue:@"YES" forKey:@"isFromNetwork"];
        [target setValue:@"NO" forKey:@"showSaveButton"];
        [target setValue:_toOpenFiles forKey:@"files"];
        [target setValue:[NSString stringWithFormat:@"%d",_toOpenFileIndex] forKey:@"currentIndex"];
    }
    
}

@end
