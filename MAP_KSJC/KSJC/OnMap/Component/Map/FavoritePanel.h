//
//  FavoritePanel.h
//  gzOneMap
//
//  Created by zhangliang on 13-12-6.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ControlPanel.h"
#import <ArcGIS/ArcGIS.h>

@protocol FavoriteViewDelegate;

@interface FavoritePanel : ControlPanel <UITableViewDataSource,UITableViewDelegate>
{
    NSMutableDictionary *_favoriteArray;
    UITableView *tableView;
}

@property (nonatomic, retain) UITableView *favoriteTableView;
@property (nonatomic, retain) id<FavoriteViewDelegate> favoriteDelegate;

- (void)addFavorite:(NSObject*)favorite Favoritekey:(id)favoriteKey;
- (void)deleteFavorite:(id)favoriteKey;
@end

@protocol FavoriteViewDelegate <NSObject>
@optional
-(void)showFavoriteView:(AGSGraphic *)graphic LayerName:(NSString*)layerName;
@end
