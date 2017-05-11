//
//  ProjectInfo.m
//  zzzf
//
//  Created by dist on 13-11-26.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ProjectInfo.h"

@implementation ProjectInfo

static NSString *NAME_KEY = @"NAME";
static NSString *ID_KEY = @"ID";
static NSString *PROJECTCODE_KEY =@"PROJECTCODE";
static NSString *ADDRESS_KEY = @"ADRESS";
static NSString *TIME_KEY=@"TIME";
static NSString *MATERIALS_KEY=@"MATERIALS";
static NSString *FORMS_KEY=@"FORMS";
static NSString *PHOTO_KEY=@"PHOTOS";

/*
@synthesize name = _name;
@synthesize projectCode=_projectCode;
@synthesize projectId=_projectId;
@synthesize time =_time;
@synthesize address=_address;
@synthesize materials = _materials;
@synthesize forms = _forms;
*/

-(id)initWithProject:(NSString *)theName theId:(NSString *)theId theCode:(NSString *)theCode theAddress:(NSString *)theAddress theTime:(NSString *)theTime{
    self = [super init];
    if (self) {
        self.name = theName;
        self.projectId = theId;
        self.projectCode = theCode;
        self.address = theAddress;
        self.time = theTime;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self != nil) {
        self.name = [aDecoder decodeObjectForKey:NAME_KEY];
        self.projectId = [aDecoder decodeObjectForKey:ID_KEY];
        self.projectCode = [aDecoder decodeObjectForKey:PROJECTCODE_KEY];
        self.address = [aDecoder decodeObjectForKey:ADDRESS_KEY];
        self.time = [aDecoder decodeObjectForKey:TIME_KEY];
        self.materials = [aDecoder decodeObjectForKey:MATERIALS_KEY];
        self.forms = [aDecoder decodeObjectForKey:FORMS_KEY];
        self.photos = [aDecoder decodeObjectForKey:PHOTO_KEY];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:NAME_KEY];
    [aCoder encodeObject:self.projectId forKey:ID_KEY];
    [aCoder encodeObject:self.projectCode forKey:PROJECTCODE_KEY];
    [aCoder encodeObject:self.address forKey:ADDRESS_KEY];
    [aCoder encodeObject:self.time forKey:TIME_KEY];
    [aCoder encodeObject:self.materials forKey:MATERIALS_KEY];
    [aCoder encodeObject:self.forms forKey:FORMS_KEY];
    [aCoder encodeObject:self.photos forKey:PHOTO_KEY];
}


@end
