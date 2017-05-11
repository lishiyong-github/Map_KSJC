//
//  DailyJobNavigatorController.h
//  zzzf
//
//  Created by dist on 14-2-25.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyJobViewController.h"
#import "OpenFileDelegate.h"

@interface DailyJobNavigatorController : UINavigationController<OpenFileDelegate>{
    NSArray *_filesArray;
    NSString *_currentIndex;
    NSString *_toOpenFileName;
    NSString *_toOpenFilePath;
    NSString *_toOpenFileExt;
    BOOL _materialFromLocal;
}

@end
