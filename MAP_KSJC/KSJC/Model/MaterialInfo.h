//
//  MaterialInfo.h
//  zzzf
//
//  Created by dist on 13-11-19.
//  Copyright (c) 2013年 dist. All rights reserved.
//  表单材料

#import <Foundation/Foundation.h>

@interface MaterialInfo : NSObject<NSCoding>

@property (nonatomic,retain) NSString *materialId;

//材料名称
@property (nonatomic, retain) NSString *name;

//保存路径(如果改属性为nil，则表示没有下载文件)
@property (nonatomic, retain) NSString *savePath;

//文件大小
@property (nonatomic, retain) NSNumber *size;

//扩展名
@property (nonatomic, retain) NSString *extension;

-(NSString *)sizeString;

@end
