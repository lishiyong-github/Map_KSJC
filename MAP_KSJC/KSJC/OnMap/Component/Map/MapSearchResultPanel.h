//
//  MapSearchResultPanel.h
//  zzzf
//
//  Created by zhangliang on 14-4-16.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysButton.h"
#import "JobPhotoView.h"
#import "SEFilterControl.h"

@protocol MapSearchResultPanelDelegate;

@interface MapSearchResultPanel : UIView<UITableViewDelegate,UITableViewDataSource,JobPhotoTapDegelate>{
    
    UIView *_showListView;
    UIActivityIndicatorView *_waitView;
    UILabel *_lblNoData;
    UIView *_pageView;
    UIView *_page1;
    UIView *_page2;
    UITableView *_listTable;
    
    UILabel *_lblName;
    UILabel *_lblSubInfo;
    
    UIScrollView *_photoView;
    SysButton *_btnStopworkForm;
    SysButton *_btnDetail;
    SysButton *_btnShowDataList;
    SysButton *_btnShowDataListForDetail;
    
    NSMutableDictionary *_currentData;
    JobPhotoView *_currentPhotoView;
    BOOL _isBackToList;
    int _phFlowState;
    //SEFilterControl *_phFilterControl;
    UISegmentedControl *_phFilterControl;
    BOOL _phFilterFirstChanged;
    int _relayDataType;
}
@property (strong,nonatomic) IBOutlet NSString *layerFilter;
@property (nonatomic,retain) id<MapSearchResultPanelDelegate> delegate;
@property (nonatomic,retain) NSArray *dataSource;
@property int dataType;

@property (nonatomic,assign)BOOL open;
-(void)wait;
-(void)close;
-(void)showDataAt:(int)index photoCode:(NSString *)code;

@end

@protocol MapSearchResultPanelDelegate <NSObject>

-(void)mapSearchPanel:(MapSearchResultPanel *)panel openPhoto:(NSString *)name url:(NSString *)url ext:(NSString *)ext;
-(void)mapSearchPanel:(MapSearchResultPanel *)panel openJobDaily:(NSDictionary *)data showStopworkform:(BOOL)showStopworkform;
-(void)mapSearchPanel:(MapSearchResultPanel *)panel openProject:(NSDictionary *)data showStopworkform:(BOOL)showStopworkform;
-(void)filterRCXCLayer:(NSString *)layerFilter;
-(void)filterPoint:(NSString*)fatherId;
-(void)hideMapViewCallout;
-(void)zoomPoint:(NSString*)xmbh;
-(void)zoomFullMap;
@end
