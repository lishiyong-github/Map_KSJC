//
//  Tools.h
//  zzzf
//
//  Created by zhangliang on 13-12-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;
+ (NSString *) md5:(NSString *) input;

@end
