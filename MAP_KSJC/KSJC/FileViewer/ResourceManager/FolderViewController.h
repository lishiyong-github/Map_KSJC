//
//  FolderViewController.h
//  zzzf
//
//  Created by mark on 14-2-23.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderCell.h"
#import "Global.h"
#import "FileModel.h"

@protocol FolderMoveDelegate <NSObject>
-(void)folderMove:(NSString *)toPath;
@end

@interface FolderViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSString *_nextPath;
}

@property (weak, nonatomic) IBOutlet UILabel *lblFolderName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain,nonatomic) NSMutableArray *folderList;
@property (retain,nonatomic) NSString *path;
@property (retain,nonatomic) NSMutableArray *moveFolder;
@property (retain,nonatomic) id<FolderMoveDelegate> delegate;

- (IBAction)onBtnBack:(id)sender;
- (IBAction)onBtnConfirm:(id)sender;

@end
