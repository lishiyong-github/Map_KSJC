//
//  CurrentJobView.m
//  zzzf
//
//  Created by dist on 13-12-1.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "CurrentJobView.h"

@implementation CurrentJobView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(CurrentJobView *)createView{
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"CurrentJobView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
