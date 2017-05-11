//
//  TouchableMapView.m
//  zzzf
//
//  Created by Aaron on 14-3-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "TouchableMapView.h"

@implementation TouchableMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.mapTouchDelegate stopped];
   
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
 
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   
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
