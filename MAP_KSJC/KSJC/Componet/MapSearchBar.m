//
//  MapSearchBar.m
//  zzzf
//
//  Created by dist on 13-11-14.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "MapSearchBar.h"

@implementation MapSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews{
    UITextField *searchField;
    NSUInteger numViews = [self.subviews count];
    for (int i=0; i<numViews; i++) {
        if ([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [self.subviews objectAtIndex:i];
        }
    }
    if (searchField!=nil) {
        [searchField setBorderStyle:UITextBorderStyleNone];
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
