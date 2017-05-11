//
//  StoreViewController.m
//  zf
//
//  Created by dist on 13-11-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "StorageNaigatorController.h"


@interface StorageNaigatorController ()

@end

@implementation StorageNaigatorController

-(void)viewDidLoad{
    _baseView = [[StorageBaseViewController alloc] initWithNibName:@"StorageBaseViewController" bundle:nil];
    //_baseView=[[PieChartViewController alloc] init];
    [self pushViewController:_baseView animated:NO];
    self.navigationBarHidden=YES;
}

@end
