//
//  ResourceManagerDelegate.h
//  zzzf
//
//  Created by dist on 14-2-15.
//  Copyright (c) 2014年 dist. All rights reserved.
//
#import "FileModel.h"
#import <Foundation/Foundation.h>

@protocol FileItemThumbnailDelegate <NSObject>
//修改方法比较方便
-(void)allFiles:(NSArray *)files currentFileDidTap:(NSString *)name type:(NSString *)type path:(NSString *)path;
//最新方法
-(void)allResource:(NSArray *)resources atIndex:(int)index;
@end

@protocol ResourceManagerDataSourceDelegate <NSObject>
-(NSString *)resouceManagerDirectory;
@optional
-(void) resourceManagerShouldClose;
@end

