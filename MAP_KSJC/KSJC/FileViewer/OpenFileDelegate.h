//
//  OpenFileDelegate.h
//  zzzf
//
//  Created by dist on 14-2-26.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OpenFileDelegate <NSObject>

-(void)openFile:(NSString *)name path:(NSString *)path ext:(NSString *)ext isLocalFile:(BOOL)isLocalFile;

-(void)allFiles:(NSArray *)files at:(int)index;
@end
