//
//  NavigatorButton.m
//  zzzf
//
//  Created by dist on 13-11-13.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "NavigatorButton.h"

@implementation NavigatorButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    return self;
}

-(id)init{
    self = [super init];
    if(self){
        
    }
    return self;
}


-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];

    if (selected) {
        [self setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:100]];
        
        
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOffset = CGSizeMake(0,3);
        self.clipsToBounds = NO;
    }else{
        [self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
        self.layer.shadowColor = nil;
        self.layer.shadowOpacity = 0;
        self.layer.shadowRadius = 0;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.clipsToBounds = YES;
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
