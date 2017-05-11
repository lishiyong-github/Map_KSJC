//
//  MapViewController+ThemeTree.m
//  KSJC
//
//  Created by liuxb on 2017/1/4.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "MapViewController+ThemeTree.h"
#import "OMBaseServiceInfo.h"
#import "OMServiceLayer.h"

@implementation MapViewController (ThemeTree)

#pragma mark 加载专题服务数据
-(void)loadThemeServices {
    for (OMBaseServiceInfo* serviceInfo in self.mapServices) {
        OMServiceLayer* omLayer = [[OMServiceLayer alloc] init];
        omLayer.name = serviceInfo.name;
        omLayer.opacity = [serviceInfo.alpha isEqual:@""] ? 1.0 : serviceInfo.alpha.floatValue;
        omLayer.type = serviceInfo.type;
        
        if ([omLayer.type isEqual:@"tiled"]) {
            AGSTiledMapServiceLayer *tMap = [[AGSTiledMapServiceLayer alloc]initWithURL:[NSURL URLWithString:serviceInfo.url]];
            [self.mapView addMapLayer:tMap];
            tMap.visible = serviceInfo.visible;
            omLayer.hostLayer = tMap;
        } else if ([omLayer.type isEqual:@"dynamic"]) {
            AGSDynamicMapServiceLayer *dMap = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:serviceInfo.url]];
            dMap.visibleLayers = [NSArray array];
            [self.mapView addMapLayer:dMap];
            omLayer.hostLayer = dMap;
        } else if ([omLayer.type isEqual:@"tpk"]) {
            //暂不加离线
        } else if ([omLayer.type isEqual:@"geodatabase"]) {
            //暂不加离线
        }
        [self.serviceLayerDic setObject:omLayer forKey:omLayer.name];
    }
}

#pragma mark 打开或关闭专题图层
- (void)handlingTopicSwitchTapEvent:(OMBaseItem*) item {
    NSString* serviceId = item.serviceUid;
    OMServiceLayer * serviceLayer = [self.serviceLayerDic objectForKey:serviceId];
    id hostLayer = serviceLayer.hostLayer;
    if ([hostLayer isKindOfClass:[AGSDynamicMapServiceLayer class]]) {
        AGSDynamicMapServiceLayer* dmap = (AGSDynamicMapServiceLayer*)hostLayer;
        NSMutableArray *visibleLayers = [NSMutableArray array];
        [visibleLayers addObjectsFromArray:dmap.visibleLayers];
        if (item.visible) {
            [visibleLayers addObject:item.layerId];
        } else {
            [visibleLayers removeObject:item.layerId];
        }
        dmap.visibleLayers = visibleLayers;
    } else if ([hostLayer isKindOfClass:[AGSTiledMapServiceLayer class]]) {
        AGSTiledMapServiceLayer* tmap = (AGSTiledMapServiceLayer*)hostLayer;
        tmap.visible = item.visible;
    }
}


#pragma mark 读取专题服务配置文件
-(void)mapJsonConfig {
    
    self.expandedItems = [NSMutableArray array];
    self.allVisibleLayerIds = [NSMutableArray array];
    self.serviceLayerDic = [NSMutableDictionary dictionary];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"map.json" ofType:nil];
    
    NSFileManager* defaultManger = [NSFileManager defaultManager];
    if (![defaultManger fileExistsAtPath:path]) {
        NSLog(@"地图专题配置文件不存在！");
        return;
    }
    
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSArray* mapServices = [dict objectForKey:@"mapServices"];
    self.mapServices = [self serviceLayerModelArry:mapServices];
    NSArray* themes = [dict objectForKey:@"theme"];
    [self themeModelArry:themes];
    
}


-(NSArray*)serviceLayerModelArry:(NSArray*)mapServices {
    NSMutableArray* array = [NSMutableArray array];
    for (NSDictionary* tempDict in mapServices) {
        OMBaseServiceInfo* serviceLayer = [OMBaseServiceInfo serviceWithDict:tempDict];
        [array addObject:serviceLayer];
    }
    return array;
}

-(void)themeModelArry:(NSArray*)themes {
    NSMutableArray* array = [NSMutableArray array];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    for (NSDictionary* tempDict in themes) {
        OMBaseItem* baseItem = [OMBaseItem itemWithDict:tempDict];
        if (baseItem.type != Layer && baseItem.subLayerIds.count > 0) {
            [dict setObject:baseItem forKey:baseItem.itemId];
        }
        
        if (baseItem.type == Layer) {
            [dict setObject:baseItem forKey:baseItem.itemId];
        }
        
        if ([baseItem.parentLayerId isEqual:@"-1"] && baseItem.subLayerIds.count > 0) {
            [array addObject:baseItem];
        }
    }
    
    self.rootGroups = array;
    self.allGroupsDic = dict;
}

//-----------------------------------------------------加载专题服务数据------------------------------------------------------


#pragma UITableViewDelegate, UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.itemsArray) {
        return self.itemsArray.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OMBaseItem *baseItem = [self.itemsArray objectAtIndex:indexPath.row];
    TreeNodeCell *cell = (TreeNodeCell *)[tableView dequeueReusableCellWithIdentifier:@"TreeNodeCell" forIndexPath:indexPath];
    cell.item = baseItem;
    cell.treeNodeCellDelegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMBaseItem* tempItem = [self.itemsArray objectAtIndex:indexPath.row];
    if (tempItem.subLayerIds.count > 0 && tempItem.type != Group) {
        if (tempItem.expanded) {
            [self removeChildrenForSelectedItem:tempItem];
            tempItem.expanded = NO;
        } else {
            [self addChildrenForSelectedItem:tempItem];
            tempItem.expanded = YES;
        }
        [tableView reloadData];
    }
}


#pragma  TreeNodeCellDelegate
- (void)treeNodeCell:(TreeNodeCell *)treeNodeCell didChangeVisibility:(BOOL)visibility {
    NSIndexPath *indexPath = [self.themeTableView indexPathForCell:treeNodeCell];
    if (indexPath) {
        OMBaseItem* baseItem = [self.itemsArray objectAtIndex:indexPath.row];
        baseItem.visible = visibility;
        [self handleSwitchNodeState:baseItem];
    }
}


#pragma Custom Method: Update UI

- (void)handleSwitchNodeState:(OMBaseItem*)baseItem {
    //更新自己，针对收藏专题
    [self updateCurrentNode:baseItem];
    //更新父节点状态
    [self updateParentNode:baseItem];
    //更新字节点
    [self updateChildNode:baseItem];
    
    [self.themeTableView reloadData];
}

// 更新对应的节点显／隐
- (void)updateCurrentNode:(OMBaseItem*)baseItem {
    if (baseItem.itemId){
        OMBaseItem *item = [self baseItemWithId:baseItem.itemId];
        if (item) {
            item.visible = baseItem.visible;
        }
    }
}

// 更新父节点
- (void)updateParentNode:(OMBaseItem*)item {
    if (item.parentLayerId) {
        if (![item.parentLayerId isEqualToString:@"-1"]) {
            //父jiedian
            OMBaseItem *parentItem = [self baseItemWithId:item.parentLayerId];
            //同级节点
            NSArray *siblingsArray = [self baseItemWithIds:parentItem.subLayerIds];
            
            BOOL parentVisible = NO;
            //遍历同级节点，只要存在一个显示，则父节点显示
            for (OMBaseItem* tempItem in siblingsArray) {
                if (![tempItem isEqual:item]) {
                    if (tempItem.visible) {
                        parentVisible = tempItem.visible;
                        break;
                    }
                }
            }
            if (!parentVisible) {
                if (item.visible) {
                    parentItem.visible = item.visible;
                } else {
                    parentItem.visible = parentVisible;
                }
            } else {
                parentItem.visible = parentVisible;
            }
            
            //继续向上递归
            [self updateParentNode:parentItem];
        }
    }
}

// 更新子节点
- (void)updateChildNode:(OMBaseItem*)item {
    [self updateAllVisibleLayerIds:item];
    if (item.subLayerIds && item.subLayerIds.count > 0) {
        NSArray* subItemNodes = [self baseItemWithIds:item.subLayerIds];
        for (OMBaseItem* subItem in subItemNodes) {
            subItem.visible = item.visible;
            [self updateChildNode:subItem];
        }
    }
    
}

// 更新可视的图层ID
- (void)updateAllVisibleLayerIds:(OMBaseItem*)item {
    if (item.layerId && ![item.layerId isEqualToString:@""]) {
        if (item.visible) {
            [self.allVisibleLayerIds addObject:item.itemId];
        } else {
            [self.allVisibleLayerIds removeObject:item.itemId];
        }
        //打开或关闭图层
        [self handlingTopicSwitchTapEvent:item];
    } else if (item.type == Group) {
        if (item.visible) {
            [self.allVisibleLayerIds addObject:item.itemId];
        } else {
            [self.allVisibleLayerIds removeObject:item.itemId];
        }
    }
}


// 打开子级树状节点
- (void)addChildrenForSelectedItem:(OMBaseItem*)baseItem {
    [self.expandedItems addObject:baseItem];
    
    NSUInteger index = [self.itemsArray indexOfObject:baseItem];
    if (index != NSNotFound) {
        //check if the layer info has sublayers
        if (baseItem.subLayerIds && baseItem.subLayerIds.count > 0) {
            //if true add the sublayers after the parent layer info in the items array
            NSInteger i = 1;
            for (NSString* itemid in baseItem.subLayerIds) {
                OMBaseItem* subItem = [self baseItemWithId:itemid];
                if (subItem) {
                    subItem.level = baseItem.level + 1;
                    [self.itemsArray insertObject:subItem atIndex:(index + i)];
                    i += 1;
                }
            }
        }
    }
}
// 关闭子级树状节点
- (void)removeChildrenForSelectedItem:(OMBaseItem*)baseItem {
    NSUInteger index = [self.expandedItems indexOfObject:baseItem];
    if (index != NSNotFound) {
        [self.expandedItems removeObjectAtIndex:index];
    }
    NSUInteger baseItemIndex = [self.itemsArray indexOfObject:baseItem];
    if (baseItemIndex != NSNotFound) {
        NSInteger endOfRange = 0;
        NSUInteger siblingBaseItemIndex = [self indexOfNextSibling:baseItem];
        if (siblingBaseItemIndex == -2) {
            NSLog(@"Unexpected error while finding siblings");
            return;
        }
        else if (siblingBaseItemIndex == -1) {
            endOfRange = self.itemsArray.count-1;
        }
        else {
            endOfRange = siblingBaseItemIndex-1;
        }
        
        if (baseItemIndex != endOfRange) {
            //to check for items with no children
            //update the expanded state to false
            for (int i = baseItemIndex+1; i < endOfRange+1; i++) {
                OMBaseItem* tempItem = [self.itemsArray objectAtIndex:i];
                tempItem.expanded = NO;
            }
            
            if (baseItemIndex+1 == endOfRange) {
                [self.itemsArray removeObjectAtIndex:endOfRange];
            } else {
                
                NSUInteger startLoc = baseItemIndex + 1;
                NSUInteger length = endOfRange - startLoc + 1;
                //remove the items
                [self.itemsArray removeObjectsInRange:NSMakeRange(startLoc, length)];
            }
            
        }
    }
}

//returns -1 if layerInfo is the last node
//returns -2 unexpected behavior
-(NSInteger)indexOfNextSibling:(OMBaseItem*)baseItem {
    NSArray *siblingsArray = nil;
    //get the siblings array
    if (baseItem.parentLayerId && ![baseItem.parentLayerId isEqual:@"-1"]){
        OMBaseItem* parentItem = [self baseItemWithId:baseItem.parentLayerId];
        siblingsArray = [self baseItemWithIds:parentItem.subLayerIds];
    } else if ([baseItem.parentLayerId isEqual:@"-1"]){
        siblingsArray = self.rootGroups;
    } else {
        //use the root as the parent
        return -1;
    }
    
    //find the index of the layerInfo in the siblings array
    NSUInteger baseItemIndex = [siblingsArray indexOfObject:baseItem];
    if (baseItemIndex != NSNotFound) {
        if (baseItemIndex < siblingsArray.count - 1) {
            //get the sibling layerInfo
            OMBaseItem* siblingBaseItem = [siblingsArray objectAtIndex:baseItemIndex+1];
            //find the index of sibling in the itemsArray
            NSUInteger siblingBaseItemIndex = [self.itemsArray indexOfObject:siblingBaseItem];
            if (siblingBaseItemIndex != NSNotFound) {
                return siblingBaseItemIndex;
            } else {
                return -2;
            }
        }
        else {
            if (baseItem.parentLayerId && ![baseItem.parentLayerId isEqual:@"-1"]) {
                OMBaseItem* parentItem = [self baseItemWithId:baseItem.parentLayerId];
                return [self indexOfNextSibling:parentItem];
            } else {
                return -1;
            }
        }
    }
    return -2;
}


//根据id，获取对应的baseitem
- (OMBaseItem*)baseItemWithId:(NSString*)itemId {
    OMBaseItem *baseItem = (OMBaseItem*)[self.allGroupsDic objectForKey:itemId];
    return baseItem;
}

//根据id数组，获取对应的baseitem数组
- (NSMutableArray*)baseItemWithIds:(NSArray*)ids {
    NSMutableArray* array = [NSMutableArray array];
    for (NSString* itemId in ids) {
        OMBaseItem *item = [self baseItemWithId:itemId];
        if (item) {
            [array addObject:item];
        }
    }
    return array;
}


//专题用到的服务
-(NSMutableArray*)getMapServices:(OMBaseItem*)data {
    NSMutableArray *services = [NSMutableArray array];
    if (data.subLayerIds.count == 0){
        return services;
    }
    NSArray* subItemIds = [self getAllSubItemIds:data.itemId];
    for (NSString* tempId in subItemIds) {
        OMBaseItem* item = [self.allGroupsDic objectForKey:tempId];
        if (item) {
            item.visible = data.visible;
            if (item.layerId && ![item.layerId isEqual:@""]) {
                if (![services containsObject:item.serviceUid]) {
                    [services addObject:item.serviceUid];
                }
            }
        }
    }
    return services;
}


- (NSMutableArray*)getAllSubItemIds:(NSString*)itemId {
    NSMutableArray* allSubItemIds = [NSMutableArray array];
    OMBaseItem* omBaseItem = [self.allGroupsDic objectForKey:itemId];
    if (omBaseItem){
        for (NSString* tempID in omBaseItem.subLayerIds) {
            if (![allSubItemIds containsObject:tempID]) {
                [allSubItemIds addObject:tempID];
            }
            [self getAllSubItemIds:tempID];
        }
    }
    return allSubItemIds;
}


@end





















































































