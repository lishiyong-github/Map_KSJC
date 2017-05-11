//
//  Logcell.h
//  KSJC
//
//  Created by 叶松丹 on 2016/11/8.
//  Copyright © 2016年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Logcell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *operators;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *gczTFlabel;
@property (weak, nonatomic) IBOutlet UILabel *ysTFlabel;
@property (weak, nonatomic) IBOutlet UILabel *xcmc;

@end
