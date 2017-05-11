//
//  SysTabBarViewController.m
//  zzzf
//
//  Created by dist on 13-11-14.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "SysTabBarViewController.h"

@interface SysTabBarViewController ()

@end

@implementation SysTabBarViewController

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
	
    //CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 48);
    //UIView *v = [[UIView alloc] initWithFrame:frame];
    //[v setBackgroundColor:[UIColor whiteColor]];
    //[v setAlpha:0.5];
    //[[self tabBar] addSubview:v];
    //UIView *bgView = [self.tabBar.subviews objectAtIndex:0];
    //bgView.backgroundColor = [UIColor whiteColor];
    //bgView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    //NSLog(@"%@",[[self.tabBar.subviews objectAtIndex:0] class]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
