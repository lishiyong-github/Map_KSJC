//
//  FolderSelectorViewController.h
//  zzzf
//
//  Created by mark on 14-2-23.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderViewController.h"
#import "Global.h"
#import "FileModel.h"

@interface FolderSelectorViewController : UIViewController{
    UINavigationController *_navigator;
}
@property (retain,nonatomic) NSMutableArray *moveFolderPath;
@property (retain,nonatomic) id<FolderMoveDelegate> delegate;
@end
