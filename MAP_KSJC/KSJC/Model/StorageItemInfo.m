//
//  StorageItemInfo.m
//  zzzf
//
//  Created by dist on 13-11-15.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "StorageItemInfo.h"

@implementation StorageItemInfo

-(StorageItemInfo *) initWithInfo:(int)i titleString:(NSString *)titleString size:(float)size{
    self=[super init];
    if (self) {
        self.iconIndex = i;
        self.title = titleString;
        self.size = size;
    }
    return self;
}

-(NSString *)sizeString{
    return [StorageItemInfo fileSizeString:self.size];
}

+(NSString *)fileSizeString:(float)size{
    NSString *fileSizeString=nil;
    if (size==0) {
        return @"0KB";
    }
    float kb = size/1024;
    float mb = kb/1024;
    float gb = mb/1024;
    if (gb>=1) {
        fileSizeString = [NSString stringWithFormat:@"%.1fG",gb];
    }else if(mb>=1){
        fileSizeString = [NSString stringWithFormat:@"%.1fMB",mb];
    }else{
        fileSizeString = [NSString stringWithFormat:@"%.1fKB",kb];
    }
    return fileSizeString;
}

@end
