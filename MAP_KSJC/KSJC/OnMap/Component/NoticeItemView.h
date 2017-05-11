//
//  NoticeItemView.h
//  zhengzhou
//
//  Created by zhangliang on 14-1-13.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMQuiltView.h"

@interface NoticeItemView : TMQuiltViewCell{
    UILabel *_titleLabel;
    UILabel *_dateLabel;
    UILabel *_contentLabel;
    NSMutableDictionary *_data;
    UIView *_bottomLine;
}

-(void)setData:(NSMutableDictionary *)data;
@end
