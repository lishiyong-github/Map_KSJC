//
//  MaterialInfo.m
//  zzzf
//
//  Created by dist on 13-11-19.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "MaterialInfo.h"

@implementation MaterialInfo

@synthesize extension = _extension;
@synthesize name=_name;
@synthesize savePath=_savePath;
@synthesize size=_size;
@synthesize materialId = _materialId;

-(NSString *) sizeString{
    NSString *fileSizeString=nil;
    if (self.size==0) {
        return @"--";
    }
    long kb=[self.size longValue]/1024;
    if (kb>1024) {
        long mb = kb/1024;
        fileSizeString = [NSString stringWithFormat:@"%ldMB",mb];
    }else{
        fileSizeString = [NSString stringWithFormat:@"%ldKB",kb];
    }
    return fileSizeString;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if (self!=nil) {
        self.materialId=[aDecoder decodeObjectForKey:@"materialId"];
        self.name=[aDecoder decodeObjectForKey:@"name"];
        self.savePath=[aDecoder decodeObjectForKey:@"savePath"];
        self.size=[aDecoder decodeObjectForKey:@"size"];
        self.extension=[aDecoder decodeObjectForKey:@"extension"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.materialId forKey:@"materialId"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.savePath forKey:@"savePath"];
    [aCoder encodeObject:self.size forKey:@"size"];
    [aCoder encodeObject:self.extension forKey:@"extension"];
}


@end
