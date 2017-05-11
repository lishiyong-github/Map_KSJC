//
//  LeaderNavigationViewController.h
//  zzzf
//
//  Created by dist on 14-3-7.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMapViewController.h"

@interface LeaderNavigationViewController : UINavigationController<OMapViewDelegate>
{
    BOOL toShowResourceView;
    BOOL toFileView;
    NSString *_toOpenFileName;
    NSString *_toOpenFileExt;
    NSString *_toOpenFileUrl;
    
    NSArray *_toOpenFiles;
    int _toOpenFileIndex;
}

@end
