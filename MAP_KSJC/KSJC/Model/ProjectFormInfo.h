//
//  ProjectFormInfo.h
//  zzzf
//
//  Created by dist on 13-11-28.
//  Copyright (c) 2013年 dist. All rights reserved.
//  表单数据

#import <Foundation/Foundation.h>

@interface ProjectFormInfo : NSObject<NSCoding>{
    BOOL _isSelected;
}

@property (retain,nonatomic) NSString *name;
@property (retain,nonatomic) NSString *projectId;
@property (retain,nonatomic) NSString *formId;
@property (retain,nonatomic) NSString *formDefineId;
@property (retain,nonatomic) NSMutableArray *detail;

-(void)isSelected:(BOOL)selected;
-(BOOL)isSelected;
-(NSString *)formDetailJson;

@end
