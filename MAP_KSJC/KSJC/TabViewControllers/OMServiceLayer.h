//
//  OMServiceLayer.h
//  KSJC
//
//  Created by liuxb on 2017/1/6.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMServiceLayer : NSObject
@property (nonatomic, strong) NSString *name, *type;
@property (assign, nonatomic) CGFloat opacity;
@property (assign, nonatomic) BOOL visible;
@property (nonatomic, strong) id hostLayer;
@end
