//
//  WhiteSearchBar.m
//  zzzf
//
//  Created by dist on 13-11-15.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "WhiteSearchBar.h"

@implementation WhiteSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setStyle];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setStyle];
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        [self setStyle];
    }
    return self;
}

-(void)setStyle{
    [[self.subviews objectAtIndex:0] removeFromSuperview];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *searchFiled = (UITextField *) subview;
            searchFiled.borderStyle = UITextBorderStyleRoundedRect;
            searchFiled.layer.borderColor = [[UIColor whiteColor] CGColor];
            searchFiled.layer.borderWidth = 0.0f;
            searchFiled.layer.cornerRadius = 0.0f;
            break;
        }
    }
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
