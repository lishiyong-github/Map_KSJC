//
//  MessageLabel.m
//  ShowMessage
//
//  Created by chenjun on 16/7/4.
//  Copyright © 2016年 cloudssky. All rights reserved.
//

#import "MessageLabel.h"

@implementation MessageLabel

+ (void)showMessage:(NSString *)message {
    if (!message.length) {
        return;
    }
    UIView *view = [[UIApplication sharedApplication].windows lastObject];
    UILabel *label = [self currentLabel];
    [view addSubview:label];
    label.text = [@"  " stringByAppendingString:message];
    label.alpha = 0;
    view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.8 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
            view.userInteractionEnabled = YES;
        }];
    }];
}

+ (UILabel *)currentLabel {
    UILabel *label = [[UILabel alloc] init];
    float width = [UIScreen mainScreen].bounds.size.width - 60;
    float HEIG = [UIScreen mainScreen].bounds.size.height;
    float height = 30;
    label.frame = CGRectMake(30, HEIG - height - 44, width, height);
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    label.textColor = [UIColor whiteColor];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 5.0;
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

@end
