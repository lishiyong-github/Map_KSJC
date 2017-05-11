//
//  ProjectInfo.h
//  zzzf
//
//  Created by dist on 13-11-26.
//  Copyright (c) 2013年 dist. All rights reserved.
//  项目信息

#import <Foundation/Foundation.h>

@interface ProjectInfo : NSObject<NSCoding>

//项目名称
@property (nonatomic, retain) NSString *name;

//项目编号
@property (nonatomic, retain) NSString *projectId;

//项目代码
@property (nonatomic, retain) NSString *projectCode;

//建设地址
@property (nonatomic, retain) NSString *address;

//创建时间
@property (nonatomic, retain) NSString *time;

//材料列表(MaterialGroupInfo)
@property (nonatomic, retain) NSMutableArray *materials;

//表单列表(ProjectFormInfo)
@property (nonatomic, retain) NSMutableArray *forms;

//相片列表
@property (nonatomic,retain)  NSMutableArray *photos;

@property (nonatomic,retain) NSMutableArray *stopworkforms;

-(id)initWithProject:(NSString *)theName theId:(NSString *)theId theCode:(NSString *)theCode theAddress:(NSString *)theAddress theTime:(NSString *)theTime;

@end
