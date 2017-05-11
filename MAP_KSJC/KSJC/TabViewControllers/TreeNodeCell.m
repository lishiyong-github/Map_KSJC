//
//  TreeNodeCell.m
//  KSJC
//
//  Created by liuxb on 2017/1/4.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "TreeNodeCell.h"

@implementation TreeNodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)setItem:(OMBaseItem *)item {
    _item = item;
    self.level = item.level;
    self.canExpanded = (item.subLayerIds.count > 0 && item.type != Group) ? YES:NO;
    self.visibility = item.visible;
    self.expanded = item.expanded;
    self.titleLabel.text = item.name;
}


- (void)setSwitchBtn:(ZJSwitch *)switchBtn {
    _switchBtn = switchBtn;
    self.switchBtn.style = ZJSwitchStyleNoBorder;
    self.switchBtn.tintColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    self.switchBtn.onTintColor = [UIColor colorWithRed:0.298 green:0.850 blue:0.382 alpha:1.0];
    self.switchBtn.offText = @"关";
    self.switchBtn.onText = @"开";
}

- (void)setVisibility:(BOOL)visibility {
    _visibility = visibility;
    self.switchBtn.on = visibility;
}

- (void)setCanExpanded:(BOOL)canExpanded {
    _canExpanded = canExpanded;
    _canExpanded ? [self showArrowImage]:[self hideArrowImage];
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    if (self.arrowImgView) {
        self.arrowImgView.image = [UIImage imageNamed:_expanded ? @"triangle-down":@"triangle-right"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.canExpanded) {
        self.arrowImgViewLeadingConstraint.constant = (self.level + 1) * 15;
    } else {
        self.arrowImgViewLeadingConstraint.constant = self.level * 15;
    }
}

- (IBAction)visibilityChanged:(ZJSwitch *)sender {
    self.visibility = !self.visibility;
    [self.treeNodeCellDelegate treeNodeCell:self didChangeVisibility:self.visibility];
}

//MARK: - hide/show switch
- (void) hideArrowImage {
    self.arrowImgView.hidden = YES;
}

- (void) showArrowImage {
    self.arrowImgView.hidden = NO;
}

@end




















































