//
//  ResourceManagerAddressBar.h
//  zzzf
//
//  Created by dist on 14-2-17.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysButton.h"

@protocol ResourceManagerAddressBarDelegate;

@interface ResourceManagerAddressBar : UIView{
    NSMutableArray *_addressStack;
    NSMutableArray *_backStack;
    NSString *_path;
}

@property (retain, nonatomic) UIScrollView *bar;
@property (retain, nonatomic) SysButton *btnPrevious;
@property (retain, nonatomic) SysButton *btnNext;
@property (retain, nonatomic) NSString *rootPathName;
@property (retain, nonatomic) id<ResourceManagerAddressBarDelegate> delegate;

-(void)go:(NSString *)path;
-(NSString *)currentPath;

@end

@protocol ResourceManagerAddressBarDelegate <NSObject>

-(void)addressBar:(ResourceManagerAddressBar *)bar didChange:(NSString *)path;

@end