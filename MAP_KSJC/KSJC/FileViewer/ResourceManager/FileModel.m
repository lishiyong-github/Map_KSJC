//
//  FileModel.m
//  zzzf
//
//  Created by mark on 13-11-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel
+(id)CreateFile
{
    FileModel *fModel=[[FileModel alloc] init];
    return fModel;
}
-(id)initWithFile:(NSString *)theImgFile fileName:(NSString *)theFileName fileLength:(NSString *)theFileLength fileDate:(NSString *)theFileDate fileType:(NSString *)theFileType
{

    self=[super init];
    if (self) {
        [self setImgFile:theImgFile];
        [self setFileName:theFileName];
        [self setFileLength:theFileLength];
        [self setFileDate:theFileDate];
        [self setFileType:theFileType];
    }
    return self;
}

-(void)setFilePath:(NSString *)filePath{
    _filePath=filePath;
}
@end
