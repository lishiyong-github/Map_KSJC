//
//  WaitingView.h
//  zzzf
//
//  Created by dist on 14-3-26.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitingView : UIView{
    UILabel *_msgLabel;
}

@property (nonatomic,strong) NSString *msg;

@end
