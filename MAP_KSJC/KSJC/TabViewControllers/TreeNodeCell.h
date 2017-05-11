//
//  TreeNodeCell.h
//  KSJC
//
//  Created by liuxb on 2017/1/4.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJSwitch.h"
#import "OMBaseItem.h"

@class TreeNodeCell;

@protocol TreeNodeCellDelegate <NSObject>
-(void)treeNodeCell:(TreeNodeCell*)treeNodeCell didChangeVisibility:(BOOL)visibility;
@end

@interface TreeNodeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *arrowImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet ZJSwitch *switchBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowImgViewLeadingConstraint;

@property (assign, nonatomic)NSInteger level;
@property (assign, nonatomic)BOOL   expanded, canExpanded, visibility;

@property (retain,nonatomic) id<TreeNodeCellDelegate> treeNodeCellDelegate;

@property (strong, nonatomic)OMBaseItem *item;

@end
