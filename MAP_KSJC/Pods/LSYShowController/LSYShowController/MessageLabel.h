//
//  MessageLabel.h
//  ShowMessage
//
//  Created by chenjun on 16/7/4.
//  Copyright © 2016年 cloudssky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageLabel : UILabel
/**
 *  展示提示信息
 *
 *  @param message 信息
 */
+ (void)showMessage:(NSString *)message;

@end
