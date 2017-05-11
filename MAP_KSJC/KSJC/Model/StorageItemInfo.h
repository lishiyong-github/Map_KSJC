//
//  StorageItemInfo.h
//  zzzf
//
//  Created by dist on 13-11-15.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageItemInfo : NSObject

@property int iconIndex;
@property (nonatomic, retain) NSString *title;
@property float size;

-(StorageItemInfo *) initWithInfo:(int) i titleString:(NSString *) titleString size:(float) size;
-(NSString *)sizeString;
+(NSString *)fileSizeString:(float)size;
@end
