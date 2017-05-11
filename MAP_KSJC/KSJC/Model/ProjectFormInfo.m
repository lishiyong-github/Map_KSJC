//
//  ProjectFormInfo.m
//  zzzf
//
//  Created by dist on 13-11-28.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ProjectFormInfo.h"

@implementation ProjectFormInfo

-(BOOL)isSelected{
    return _isSelected;
}

-(void)isSelected:(BOOL)selected{
    _isSelected=selected;
}	

-(NSString *)formDetailJson{
    NSMutableString *json = [NSMutableString stringWithCapacity:100];
    [json appendString:@"["];
    NSString *split = @"";
    for (NSDictionary *control in self.detail) {
        [json appendFormat:@"%@{text:\"%@\",value:\"%@\",id:\"%@\",field:\"%@\",table:\"%@\",readonly:\"%@\",extensionType:\"%@\"}",split,[control objectForKey:@"text"],[control objectForKey:@"value"],[control objectForKey:@"id"],[control objectForKey:@"field"],[control objectForKey:@"table"],[control objectForKey:@"readonly"],[control objectForKey:@"extensionType"]];
        split=@",";
    }
    [json appendString:@"]"];
    return json;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if (nil!=self) {
        self.name=[aDecoder decodeObjectForKey:@"name"];
        self.projectId=[aDecoder decodeObjectForKey:@"projectId"];
        self.formId=[aDecoder decodeObjectForKey:@"formId"];
        self.formDefineId=[aDecoder decodeObjectForKey:@"formDefineId"];
        self.detail=[aDecoder decodeObjectForKey:@"detail"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.projectId forKey:@"projectId"];
    [aCoder encodeObject:self.formId forKey:@"formId"];
    [aCoder encodeObject:self.formDefineId forKey:@"formDefineId"];
    [aCoder encodeObject:self.detail forKey:@"detail"];
}

@end
