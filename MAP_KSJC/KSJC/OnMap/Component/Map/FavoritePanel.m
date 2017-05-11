//
//  FavoritePanel.m
//  gzOneMap
//
//  Created by zhangliang on 13-12-6.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "FavoritePanel.h"
#import "Global.h"


@implementation FavoritePanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createLayerView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createLayerView];
    }
    return self;
}

-(void)createLayerView{
    [_titleButton setTitle:@"   收藏" forState:UIControlStateNormal];
    CGFloat titleHeight = _titleButton.frame.size.height;
    // 初始化tableView的数据
    _favoriteArray = [[Global currentUser] mapFavorites];
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, titleHeight, self.frame.size.width, self.frame.size.height- titleHeight) style:UITableViewStylePlain];
    // 设置tableView的数据源
    tableView.dataSource = self;
    // 设置tableView的委托
    tableView.delegate = self;
    self.favoriteTableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self addSubview:tableView];
    //[[Global currentUser] saveMapFavoriteToDisk];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_favoriteArray count];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获得收藏夹字典的key
    NSEnumerator * enumeratorKey = [_favoriteArray keyEnumerator];
    NSArray *dicKeys= enumeratorKey.allObjects;
    NSString *favoriteKey = [dicKeys objectAtIndex:[indexPath row]];
    //通过key获得收藏夹信息
    NSArray *favoriteInfo = [_favoriteArray objectForKey:favoriteKey];
    if(nil != favoriteInfo && [favoriteInfo count] > 0) {
        NSString *layerName = [favoriteInfo objectAtIndex:0];
        //获得Graphic
        NSDictionary *graphicJSON = [favoriteInfo objectAtIndex:1];
        AGSGraphic *favoriteGraphic = [[AGSGraphic alloc]initWithJSON:graphicJSON];
        [self.favoriteDelegate showFavoriteView:favoriteGraphic LayerName:layerName];
    }
}

- (UITableViewCell *)tableView:(UITableView *)favoriteTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellWithIdentifier = @"Cell";
    UITableViewCell *cell = [favoriteTableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize: 14.0];
    NSUInteger row = [indexPath row];
    //获得收藏夹字典的key
    NSEnumerator * enumeratorKey = [_favoriteArray keyEnumerator];
    NSArray *dicKeys= enumeratorKey.allObjects;
    cell.textLabel.text = [dicKeys objectAtIndex:row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
//执行编辑操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //获得收藏夹字典的key
    NSEnumerator * enumeratorKey = [_favoriteArray keyEnumerator];
    NSArray *dicKeys= enumeratorKey.allObjects;
    
    //删除列表中的数据和数据源中的数据
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_favoriteArray removeObjectForKey:[dicKeys objectAtIndex:indexPath.row]];
        [self.favoriteTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    //编辑
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
    [[Global currentUser] saveMapFavoriteToDisk];
}
//更改删除按钮
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
//增加信息到收藏夹
- (void)addFavorite:(NSObject*)favorite Favoritekey:(id)favoriteKey {
    [_favoriteArray setObject:favorite forKey:favoriteKey];
    [tableView reloadData];
    [[Global currentUser] saveMapFavoriteToDisk];
}
//删除收藏夹中的信息
- (void)deleteFavorite:(id)favoriteKey{
    [_favoriteArray removeObjectForKey:favoriteKey];
    [[Global currentUser] saveMapFavoriteToDisk];
    [tableView reloadData];
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
