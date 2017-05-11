//
//  OnLineResource.m
//  zzzf
//
//  Created by mark on 13-11-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "OnLineResourceView.h"
#import "ServiceProvider.h"
#import "ResourcesFileView.h"
#import "SysButton.h"
#import "ResourceViewController.h"

@implementation OnLineResourceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self onLoaded];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onLoaded];
    }
    return self;
}

-(void)onLoaded{
    _addressStack = [[NSMutableArray alloc] initWithCapacity:10];
    _addressItems = [[NSMutableArray alloc] initWithCapacity:10];
    _viewType = 1;
}

-(void)load:(NSString *)path andFileName:(NSString *)fileName{
    
    [self loadAction:path andFileName:fileName action:1];
}

-(void)loadAction:(NSString *)path andFileName:(NSString *)fileName action:(int)action{
    [_addressStack addObject:path];
    
    for(UIView *view in self.resourcesView.subviews)
    {
        [view removeFromSuperview];
    }
    
    self.path=path;
    _rsView=[[ResourcesView alloc] initWithFrame:CGRectMake(0, 0, self.resourcesView.bounds.size.width, self.resourcesView.bounds.size.height)];
    [_rsView load:path andFileName:fileName];
    _rsView.owner=self;
    _rsView.viewType = _viewType;
    [self.resourcesView addSubview:_rsView];
    
    if (action==1)
        [self pushAddressbar:path];
    else if(action==2)
        [self popAddressbar];
    
}

-(void)showDetails{
    [_rsView showDetails];
    _viewType = 2;
}

-(void)showThumbnails{
    [_rsView showThumbnails];
    _viewType = 1;
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *fileName = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    NSLog(@"%@",fileName);
    NSLog(@"%@",self.path);
    if (![fileName isEqualToString:@""]) {
        _intSearched=1;
    }else{
        _intSearched=0;
    }
    [self load:self.path andFileName:fileName];
}

+(OnLineResourceView *) createView{
    
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"OnLineResourceView" owner:nil options:nil];
    OnLineResourceView *theView= [nibView objectAtIndex:0];
    
    [[theView.seaBarFile.subviews objectAtIndex:0] removeFromSuperview];
    for (UIView *subview in theView.seaBarFile.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *searchFiled = (UITextField *) subview;
            searchFiled.borderStyle = UITextBorderStyleRoundedRect;
            searchFiled.layer.borderColor = [[UIColor whiteColor] CGColor];
            searchFiled.layer.borderWidth = 4.0f;
            searchFiled.layer.cornerRadius = 0.0f;
            break;
        }
    }
    theView.seaBarFile.delegate=theView;
    
    return theView;
}

-(void)updateHistoryButtons{
    if(_addressItems.count>1){
        self.btnPrevious.enabled = YES;
    }else{
        self.btnPrevious.enabled = NO;
    }
}

-(void)pushAddressbar:(NSString *)path{
    if ([path isEqualToString:@""]) {
        path = @"资源目录";
    }
    int left = 0;
    if (nil != _currentAddressItem) {
        _currentAddressItem.backgroundColor = [UIColor clearColor];
        [_currentAddressItem setTextColor:[UIColor grayColor]];
        left = _currentAddressItem.frame.origin.x + _currentAddressItem.frame.size.width + 10;
    }
    UILabel *addressItem = [[UILabel alloc] initWithFrame:CGRectMake(left, 2, 20, 25)];
    addressItem.layer.cornerRadius = 5;
    addressItem.backgroundColor = [UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
    addressItem.font = [addressItem.font fontWithSize:13];
    CGSize size = [path sizeWithFont:addressItem.font constrainedToSize:CGSizeMake(MAXFLOAT, addressItem.frame.size.height)];
    [addressItem setFrame:CGRectMake(left, 5, size.width+6, 25)];
    addressItem.textAlignment = NSTextAlignmentCenter;
    addressItem.text = path;
    [addressItem setTextColor:[UIColor whiteColor]];
    [_addressStack addObject:path];
    [self.addressBar addSubview:addressItem];
    [_addressItems addObject:addressItem];
    _currentAddressItem = addressItem;

    [self updateHistoryButtons];
}

-(void)popAddressbar{
    [_currentAddressItem removeFromSuperview];
    if (_addressItems.count==1) {
        return;
    }
    [_addressItems removeObjectAtIndex:_addressItems.count-1];
    UILabel *lastAddressItem = [_addressItems objectAtIndex:_addressItems.count-1];
    [lastAddressItem setTextColor:[UIColor whiteColor]];
    lastAddressItem.backgroundColor = [UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
    _currentAddressItem = lastAddressItem;
    [self updateHistoryButtons];
}

-(IBAction)onBtnPreviousTap:(id)sender{
    CATransition* transition = [CATransition animation];
    //只执行0.5-0.6之间的动画部分
    //    transition.startProgress = 0.5;
    //    transition.endProgress = 0.6;
    //动画持续时间
    transition.duration = 0.5;
    //进出减缓
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    //动画效果
    transition.type = @"suckUnEffect";
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.resourcesView.layer addAnimation:transition forKey:nil];
    //view之间的切换
    [self.resourcesView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    
    NSString * fruits = self.path;
    NSArray  * array= [fruits componentsSeparatedByString:@"//"];
    NSString *path=array.lastObject;
    path=[@"" stringByAppendingFormat:@"//%@", path];
    path =[self.path stringByReplacingOccurrencesOfString:path withString:@""];
    _intSearched=0;
    [self loadAction:path andFileName:@"" action:2];
}

-(void)openFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext{
    //[self.ownController openFile:name path:path ext:ext];
}

@end
