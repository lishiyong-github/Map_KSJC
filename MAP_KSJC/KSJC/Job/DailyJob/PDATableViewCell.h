//
//  PDATableViewCell.h
//  zzzf
//  PDA列表行
//  Created by dist on 13-12-31.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDATableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *iconStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblPDAName;
@property (weak, nonatomic) IBOutlet UILabel *lblLastPosition;

-(void)setPDAInfo:(NSMutableDictionary *)data;

@end
