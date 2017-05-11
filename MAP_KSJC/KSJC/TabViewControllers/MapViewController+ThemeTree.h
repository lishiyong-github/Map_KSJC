//
//  MapViewController+ThemeTree.h
//  KSJC
//
//  Created by liuxb on 2017/1/4.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "MapViewController.h"
#import "TreeNodeCell.h"

@interface MapViewController (ThemeTree)<UITableViewDelegate, UITableViewDataSource, TreeNodeCellDelegate>

//读取专题服务配置文件
-(void)mapJsonConfig;

//加载专题服务数据
-(void)loadThemeServices;
@end
