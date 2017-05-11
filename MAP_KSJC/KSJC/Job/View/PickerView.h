//
//  PickerView.h
//  KSJC
//
//  Created by 叶松丹 on 2017/3/6.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerView : UIView
// 选择后的回调
@property(nonatomic,strong) void(^selectedBlock)();

// 初始化视图
- (void)showInView:(UIView *)superView animated:(BOOL)animated;
// 退出/退出动画
- (void)fadeIn;
- (void)fadeOut;

@property (nonatomic, strong) NSDictionary *modelDict;
- (instancetype)initWithFrame:(CGRect)frame withDictModel:(NSDictionary *)modelDict;



@end
