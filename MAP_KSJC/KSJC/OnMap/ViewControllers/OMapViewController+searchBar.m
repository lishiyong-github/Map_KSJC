//
//  OMapViewController+searchBar.m
//  zzzf
//
//  Created by zhangliang on 14-3-6.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController+searchBar.h"

@implementation OMapViewController (searchBar)
-(void)initSearchBar{
    
    self.mapSearchBar.layer.shadowColor = [UIColor grayColor].CGColor;
    self.mapSearchBar.layer.shadowOpacity = .5;
    self.mapSearchBar.layer.shadowOffset = CGSizeMake(0,1);
    self.mapSearchBar.layer.cornerRadius = 2;
    self.mapSearchBar.backgroundColor = [UIColor whiteColor];
    self.mapSearchBar.clipsToBounds = NO;
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version<7) {
        [[self.mapSearchBar.subviews objectAtIndex:0] removeFromSuperview];
        for (UIView *subview in self.mapSearchBar.subviews) {
            if ([subview isKindOfClass:[UITextField class]]) {
                UITextField *searchFiled = (UITextField *) subview;
                searchFiled.borderStyle = UITextBorderStyleRoundedRect;
                searchFiled.layer.borderColor = [[UIColor whiteColor] CGColor];
                searchFiled.layer.borderWidth = 4.0f;
                searchFiled.layer.cornerRadius = 0.0f;
                break;
            }
        }
    }else{
        [self.mapSearchBar setBarTintColor:[UIColor whiteColor]];
    }
    
}
@end
