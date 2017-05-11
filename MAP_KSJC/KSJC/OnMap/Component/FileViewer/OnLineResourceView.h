//
//  OnLineResource.h
//  zzzf
//
//  Created by mark on 13-11-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProvider.h"
#import "SysButton.h"
#import "ResourcesView.h"
@class ResourceViewController;

@interface OnLineResourceView : UIView<UISearchBarDelegate>{
    ResourcesView *_rsView;
    NSMutableArray *_addressStack;
    UILabel *_currentAddressItem;
    NSMutableArray *_addressItems;
    int _viewType;
}

@property (weak, nonatomic) IBOutlet UIView *resourcesView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backFileName;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItemMyRes2;
@property (weak, nonatomic) IBOutlet SysButton *btnPrevious;
@property (weak, nonatomic) IBOutlet UISearchBar *seaBarFile;
@property (weak, nonatomic) IBOutlet UIScrollView *addressBar;

@property (retain,nonatomic)NSString *path;
@property ResourceViewController *ownController;

@property NSInteger intSearched;

+(OnLineResourceView *)createView;
-(void) load:(NSString *) path andFileName:(NSString *) fileName;
-(void) showThumbnails;
-(void) showDetails;
-(void) openFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext;

-(IBAction)onBtnPreviousTap:(id)sender;


@end
