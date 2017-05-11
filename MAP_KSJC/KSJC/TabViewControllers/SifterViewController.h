//
//  SifterViewController.h
//  KSYD
//
//  Created by 吴定如 on 16/10/19.
//  Copyright © 2016年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SifterViewController : UIViewController
@property(nonatomic,assign) NSInteger selectedIndex;

@property(nonatomic,strong) void(^siftBlock)(NSString *title);
- (instancetype)initWithFilterArray:(NSArray *)array;
@end
