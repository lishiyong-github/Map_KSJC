//
//  BaseMessageCell.h
//  KSYD
//
//  Created by yesongdan on 16/8/25.
//  Copyright © 2016年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHighC;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightC;
//是否公开背景view
@property (weak, nonatomic) IBOutlet UIView *openOrNotView;
@property (weak, nonatomic) IBOutlet UIButton *openBtn;
@property (weak, nonatomic) IBOutlet UIButton *notOpenBtn;
@property (weak, nonatomic) IBOutlet UIView *qjBackView;
@property (weak, nonatomic) IBOutlet UILabel *zdrName;
@property (weak, nonatomic) IBOutlet UILabel *telephoneNum;
//报销明细
@property (weak, nonatomic) IBOutlet UIView *bxBackView;
@property (weak, nonatomic) IBOutlet UILabel *totalNum;
//报销1背景
@property (weak, nonatomic) IBOutlet UIView *bxtypeBackV;
//类型
@property (weak, nonatomic) IBOutlet UILabel *typeLable;
//内容
@property (weak, nonatomic) IBOutlet UILabel *contentL;
//内容高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counTHC;
//报销背景高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bxtypeBHC;

//金额
@property (weak, nonatomic) IBOutlet UILabel *countL;
//结账方式
@property (weak, nonatomic) IBOutlet UILabel *countStyleL;


//公章管理
@property (weak, nonatomic) IBOutlet UIView *gzBV;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gzBackVHC;
@property (weak, nonatomic) IBOutlet UITextView *gzyyL;
@property (weak, nonatomic) IBOutlet UILabel *gzType;
@property (weak, nonatomic) IBOutlet UILabel *page;
@property (weak, nonatomic) IBOutlet UILabel *part;

//政务公开

@property (weak, nonatomic) IBOutlet UIView *zwgkBV;
@property (weak, nonatomic) IBOutlet UIButton *zwgkzfB;
@property (weak, nonatomic) IBOutlet UIButton *zwgkbmB;
@property (weak, nonatomic) IBOutlet UIButton *zwgkjwB;


@end
