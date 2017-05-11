//
//  LayerCell.h
//  zzOneMap
//
//  Created by zhangliang on 13-12-5.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LayerCell : UITableViewCell
@property (weak,nonatomic) IBOutlet UILabel *layerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *visibleIcon;
@property (nonatomic,retain) NSDictionary *attributes;

@end
