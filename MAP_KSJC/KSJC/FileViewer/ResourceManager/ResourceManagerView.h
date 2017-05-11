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
#import "FileListContainerView.h"
#import "ResourceManagerAddressBar.h"
#import "ResourceManagerDelegate.h"
#import "OpenFileDelegate.h"
#import "FileModel.h"

@interface ResourceManagerView : UIView<UISearchBarDelegate,FileItemThumbnailDelegate,ResourceManagerAddressBarDelegate,UIAlertViewDelegate>{
    FileListContainerView *_rsView;
    int _viewType;
//    BOOL _isOnlineRsource;
    ResourceManagerAddressBar *_onlineAddressBar;
    ResourceManagerAddressBar *_localAddressBar;
    NSString *_path;
    BOOL     _isSearch;
}
@property (nonatomic) BOOL isOnlineRsource;
@property (weak, nonatomic) IBOutlet UIButton *btnMyResource;
@property (weak, nonatomic) IBOutlet UIButton *btnOnlineResource;
@property (weak, nonatomic) IBOutlet UIButton *btnShowThumbnails;
@property (weak, nonatomic) IBOutlet UIButton *btnShowDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet SysButton *btnDelete;
@property (weak, nonatomic) IBOutlet UISearchBar *seaBarFile;
@property (weak, nonatomic) IBOutlet SysButton *btnAdd;


- (IBAction)onBtnCloseTap:(id)sender;
- (IBAction)testDelete:(id)sender;
- (IBAction)onBtnShowLocalResourceTap:(id)sender;
- (IBAction)onBtnShowOnlineTap:(id)sender;
- (IBAction)onBtnAdd:(id)sender;

- (IBAction)onBtnShowThumbnailsTap:(id)sender;
- (IBAction)onBtnShowDetailTap:(id)sender;
- (IBAction)onBtnRefreshTap:(id)sender;
- (IBAction)onBtnDeleteTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *resourcesView;
@property (nonatomic,retain) id<OpenFileDelegate> fileDelegate;
@property (nonatomic,retain) id<ResourceManagerDataSourceDelegate> managerDelegate;
@property (weak, nonatomic) IBOutlet SysButton *btnClose;

@property (retain,nonatomic) NSString *path;
@property (retain,nonatomic) NSString *searchkey;


@property NSInteger intSearched;

+(ResourceManagerView *)createView;

//-(void) load:(NSString *) path andFileName:(NSString *) fileName;
-(void) showThumbnails;
-(void) showDetails;
-(void) setCloseButtonVisible:(BOOL)visible;

-(void)showOnlineResource;
-(void)showLocalResource;

@end
