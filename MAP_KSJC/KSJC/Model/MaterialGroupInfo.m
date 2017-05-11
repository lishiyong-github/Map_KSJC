//
//  MaterialGroupInfo.m
//  zzzf
//
//  Created by dist on 13-11-27.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "MaterialGroupInfo.h"

@implementation MaterialGroupInfo

@synthesize name=_name;
@synthesize files=_files;
@synthesize ID=_ID;
@synthesize instanceID=_instanceID;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if(nil!=self){
        self.name=[aDecoder decodeObjectForKey:@"name"];
        self.files=[aDecoder decodeObjectForKey:@"files"];
        self.ID=[aDecoder decodeObjectForKey:@"ID"];
        self.instanceID=[aDecoder decodeObjectForKey:@"instanceID"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.files forKey:@"files"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.instanceID forKey:@"instanceID"];
}
@end
