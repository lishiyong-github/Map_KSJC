//
//  BaseMessageCell.m
//  KSYD
//
//  Created by yesongdan on 16/8/25.
//  Copyright © 2016年 dist. All rights reserved.
//

#import "BaseMessageCell.h"

@implementation BaseMessageCell

- (void)awakeFromNib {
    // Initialization code
    [self setboardStyle];
}
- (void)setboardStyle
{
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, MainR.size.width-20, 140)];
//    textView.text = @"请给出您的意见...";
//    textView.textColor = [UIColor blackColor];
//    if ([textView.text isEqualToString:@"请给出您的意见..."]) {
//        textView.textColor = [UIColor lightGrayColor];
//    }
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.font = [UIFont systemFontOfSize:16.0];
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor;
    self.textView.returnKeyType = UIReturnKeyDone;
    
    
    self.gzBV.backgroundColor = [UIColor whiteColor];
//    self.gzBV.font = [UIFont systemFontOfSize:16.0];
    self.gzBV.layer.borderWidth = 0.5;
    self.gzBV.layer.borderColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor;
//    self.gzyyL.returnKeyType = UIReturnKeyDone;
    self.gzyyL.backgroundColor = [UIColor whiteColor];
    self.gzyyL.font = [UIFont systemFontOfSize:16.0];
    self.gzyyL.layer.borderWidth = 0.5;
    self.gzyyL.layer.borderColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor;
    self.gzyyL.returnKeyType = UIReturnKeyDone;
    
    
    UIImage *imaged=[UIImage imageNamed:@"wxz@2x.png"];
    UIImage *selImaged=[UIImage imageNamed:@"a_xz@2x.png"];

    [self.zwgkjwB setBackgroundImage:imaged forState:UIControlStateNormal];
//    [self.zwgkjwB setBackgroundImage:selImaged forState:UIControlStateSelected];

//    [self.zwgkjwB setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.zwgkzfB setBackgroundImage:imaged forState:UIControlStateNormal];
//    [self.zwgkzfB setBackgroundImage:selImaged forState:UIControlStateNormal];

//    [self.zwgkzfB setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.zwgkbmB setBackgroundImage:imaged forState:UIControlStateNormal];
//    [self.zwgkbmB setBackgroundImage:selImaged forState:UIControlStateSelected];

//    [self.zwgkbmB setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
