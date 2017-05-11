//
//  AGSGraphic+Extention.m
//  KSJC
//
//  Created by liuxb on 2017/1/9.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "AGSGraphic+Extention.h"

@implementation AGSGraphic (Extention)

-(void)setPid:(NSString *)pid {
    objc_setAssociatedObject(self, @selector(pid), pid, OBJC_ASSOCIATION_RETAIN);
}

-(void)setKeyId:(NSString *)keyId {
    objc_setAssociatedObject(self, @selector(keyId), keyId, OBJC_ASSOCIATION_RETAIN);
}

-(NSString *)pid {
    return objc_getAssociatedObject(self, @selector(pid));
}

-(NSString *)keyId {
    return objc_getAssociatedObject(self, @selector(keyId));
}

@end
