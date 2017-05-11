//
//  StorageBaseViewController.h
//  zzzf
//
//  Created by mark on 14-2-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectStorageViewController.h"
#import "Global.h"
#import "StorageItemCell.h"
//#import "CustomView.h"
#import "PieChartViewController.h"
#import "MapJobViewController.h"

@interface StorageBaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,StorageItemCellDelegate>{
    NSMutableArray *source;
    ProjectStorageViewController *_projectStorageInfo;
    int introw;
    double _diskSize;
}
@property (weak, nonatomic) IBOutlet UITableView *tableStorage;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *viewUseSize;
@property (weak, nonatomic) IBOutlet UILabel *lblUseSize;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalSize;

@end
