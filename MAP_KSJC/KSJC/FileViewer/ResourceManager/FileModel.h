//
//  FileModel.h
//  zzzf
//
//  Created by mark on 13-11-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject

+(id)CreateFile;
-(id)initWithFile:(NSString *)theImgFile fileName:(NSString *)theFileName fileLength:(NSString *)theFileLength fileDate:(NSString *)theFileDate fileType:(NSString *)theFileType;

@property(nonatomic,strong) NSString *imgFile;
@property(nonatomic,strong) NSString *fileName;
@property(nonatomic,strong) NSString *fileLength;
@property(nonatomic,strong) NSString *fileDate;
@property(nonatomic,strong) NSString *fileType;
@property(nonatomic,strong) NSString *filePath;
@end
