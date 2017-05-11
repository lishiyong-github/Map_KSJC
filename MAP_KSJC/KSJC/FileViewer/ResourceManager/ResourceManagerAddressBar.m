//
//  ResourceManagerAddressBar.m
//  zzzf
//
//  Created by dist on 14-2-17.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "ResourceManagerAddressBar.h"

@implementation ResourceManagerAddressBar

@synthesize bar,btnNext,btnPrevious;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createSubViews];
        _path=@"";
    }
    return self;
}

-(void)createSubViews{
    self.btnNext = [SysButton buttonWithType:UIButtonTypeCustom];
    [self.btnNext setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
    self.btnNext.frame = CGRectMake(44, 2, 30, 30);
    [self.btnNext addTarget:self action:@selector(onBtnNextTap) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnPrevious = [SysButton buttonWithType:UIButtonTypeCustom];
    [self.btnPrevious setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
    self.btnPrevious.frame = CGRectMake(6, 2, 30, 30);
    [self.btnPrevious addTarget:self action:@selector(onBtnPreviousTap) forControlEvents:UIControlEventTouchUpInside];
    
    self.bar = [[UIScrollView alloc] initWithFrame:CGRectMake(100, 2, 900, 35)];
    
    [self addSubview:self.btnPrevious];
    [self addSubview:self.btnNext];
    [self addSubview:self.bar];
    
    _backStack = [NSMutableArray arrayWithCapacity:10];
    _addressStack = [NSMutableArray arrayWithCapacity:10];
    
}

-(void)go:(NSString *)path{
    _path  = path;
    [_addressStack addObject:path];
    [self update];
}

-(void)onBtnNextTap{
    if (_backStack.count==0) {
        return;
    }
    NSString *p = [_backStack objectAtIndex:_backStack.count-1];;
    [_backStack removeObjectAtIndex:_backStack.count-1];
    [self go:p];
    [self.delegate addressBar:self didChange:_path];
}

-(void)onBtnPreviousTap{
    if (_addressStack.count<=1) {
        return;
    }
    NSString *lastDirectory = [_addressStack objectAtIndex:_addressStack.count-1];
    [_addressStack removeObjectAtIndex:_addressStack.count-1];
    [_backStack addObject:lastDirectory];
    _path = [_addressStack objectAtIndex:_addressStack.count-1];
    [self update];
    [self.delegate addressBar:self didChange:_path];
}


-(void)update{
    NSArray *ps = [_path pathComponents];
    int left = 0;
    
    for(UIView *view in self.bar.subviews)
    {
        [view removeFromSuperview];
    }
    
    SysButton *rootItem = [self createAddressItem:[self.rootPathName stringByAppendingString:@"/"] left:left];
    rootItem.tag = 0;
    [self.bar addSubview:rootItem];
    if (ps.count==0) {
        rootItem.selected = YES;
    }
    left += rootItem.frame.size.width+5;
    for (int i=1;i<ps.count;i++) {
        NSString *directoryName = [ps objectAtIndex:i];
        SysButton *addressItem = [self createAddressItem:[directoryName stringByAppendingString:@"/"] left:left];
        addressItem.tag = i;
        left += addressItem.frame.size.width+5;
        if (i==ps.count-1) {
            addressItem.selected = YES;
        }
        [self.bar addSubview:addressItem];
    }
    self.btnNext.enabled = _backStack.count>0;
    self.btnPrevious.enabled = _addressStack.count>1;
}

-(SysButton *)createAddressItem:(NSString *)name left:(int)left{
    SysButton *addressItem = [SysButton buttonWithType:UIButtonTypeCustom];
    addressItem.layer.cornerRadius = 5;
    addressItem.titleLabel.font = [addressItem.titleLabel.font fontWithSize:13];
    [addressItem setTitle:name forState:UIControlStateNormal];
    [addressItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    CGSize size = [name sizeWithFont:addressItem.titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, addressItem.frame.size.height)];
    [addressItem setFrame:CGRectMake(left, 5, size.width+8, 25)];
    [addressItem addTarget:self action:@selector(onItemTap:) forControlEvents:UIControlEventTouchUpInside];
    return addressItem;
}

-(void)onItemTap:(SysButton *)sender{
    if (sender.selected) {
        return;
    }
    NSArray *ps = [_path pathComponents];
    NSMutableString *toPath = [NSMutableString stringWithCapacity:10];
    
    for (int i=1; i<=sender.tag; i++) {
        [toPath appendString:[NSString stringWithFormat:@"/%@",[ps objectAtIndex:i]]];
    }
    _path = toPath;
    [_addressStack addObject:toPath];
    [self update];
    [self.delegate addressBar:self didChange:_path];
}

-(NSString *)currentPath{
    return _path;
}

@end
