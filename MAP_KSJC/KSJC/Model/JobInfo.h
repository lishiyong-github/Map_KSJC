//
//  JobInfo.h
//  zzzf
//  作业信息
//  Created by dist on 13-11-19.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaterialInfo.h"
//#import "StopWrokForm.h"

@interface JobInfo : NSObject

//作业代码
@property (nonatomic, retain) NSString *code;

//项目编号
@property (nonatomic, retain) NSString *projectId;

//材料列表
@property (nonatomic, retain) NSMutableArray *materials;

//照片
@property (nonatomic, retain) NSMutableArray *photos;

//停工单
@property (nonatomic, retain) NSMutableDictionary *stopWorkForm;

//表单信息
@property (nonatomic, retain) NSMutableArray *forms;

@end
