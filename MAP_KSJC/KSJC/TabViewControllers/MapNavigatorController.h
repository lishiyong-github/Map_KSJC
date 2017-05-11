//
//  MapNavigatorController.h
//  zzzf
//
//  Created by Aaron on 14-3-3.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface MapNavigatorController : UINavigationController<MapViewDelegate>
{
    NSString *_toOpenFileName;
    NSString *_toOpenFilePath;
    NSString *_toOpenFileExt;
    BOOL _isLocalFile;
    
    NSArray *_toOpenFiles;
    int _toOpenFileIndex;
}

@end
