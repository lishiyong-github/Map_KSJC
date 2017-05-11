//
//  FileDownload.m
//  CP
//  下载网络文件到Temp目录，但这个类写得有点过了，不应该包含更新逻辑。
//  Created by dist on 13-9-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "FileDownload.h"

@implementation FileDownload


-(NSString *)savePath{
    return savePath;
}

-(void)exitDownload {
    downloadFlag = NO;
}

-(void)cancel{
    if (_connection) {
        [_connection cancel];
    }
    if (nil!=downThread) {
        [downThread cancel];
        downloadFlag = NO;
    }
    [[NSFileManager defaultManager] removeItemAtPath:[self savePath] error:Nil];
}


//-(void)update:(NSString *)downloadUrl fileId:(NSString *)downFileId fileExt:(NSString *)ext{
//    [self executeDown:downloadUrl fileId:downFileId fileExt:ext update:YES];
//}

//下载文件：地址 、扩展名(返回文件路径，如果存在)
-(NSString *)download:(NSString *)url fileId:(NSString *)downFileId fileExt:(NSString *) ext {
    
    self.fileId=downFileId;
    NSMutableString *saveName = [NSMutableString stringWithFormat:@"%@.%@",self.fileId,ext];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *documentSavePath = [path stringByAppendingPathComponent:saveName];
    
    NSString *tempSavePath = [NSTemporaryDirectory() stringByAppendingPathComponent:saveName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    downloadFlag = YES;
    
    if([fileManager fileExistsAtPath:documentSavePath]==YES){
        //if (update) {
            //如果更新则移除已下载的文件
        //    [fileManager removeItemAtPath:documentSavePath error:nil];
        //}else{
            // NSLog(@"open:%@",documentSavePath);
            //如果文件存在document目录，则拷贝一份到tmp目录后返回
            //if (![fileManager fileExistsAtPath:tempSavePath]) {
            //    [fileManager copyItemAtPath:documentSavePath toPath:tempSavePath error:nil];
            //}
            self.docPath = documentSavePath;
            savePath = documentSavePath;
            return tempSavePath;
        //}
    }
    
    //如果文件存在temp目录，则直接返回
    savePath = tempSavePath;
    if([fileManager fileExistsAtPath:tempSavePath]==YES){
        self.tempPath = tempSavePath;
        
        //if (update) {
        //    [fileManager removeItemAtPath:tempSavePath error:nil];
        //}else{
            NSLog(@"file exists");
            savePath = tempSavePath;
            return tempSavePath;
        //}
    }
    paths=nil;
    path=nil;
    saveName=nil;
    tempSavePath=nil;
    
    if (nil!=downThread) {
        [downThread cancel];
        [self cancel];
        downThread = nil;
    }
    self.downloadUrl = url;
    self.downloadExt = ext;
    downThread = [[NSThread alloc] initWithTarget:self selector:@selector(executeDown) object:nil];
    [downThread start];
    return nil;
}

-(void) executeDown{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [_delegate download:self onFileStartDownload:_fileId];
    while (downloadFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
	if (_connection) {
		//[self createProgressionAlertWithMessage:_title];
	}
    
}

// -------------------------------------------------------------------------------
//  connection:didReceiveResponse:response 通过response的响应，判断是否连接存在
// -------------------------------------------------------------------------------
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.currentSize = 0;
    self.totalSize = [response expectedContentLength];
    if (self.totalSize==0) {
        downloadFlag = NO;
        NSLog(@"totalSize:0kb");
        [_delegate download:self onFileDownloadFaild:self.fileId];
    }else{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:savePath] == YES){
            NSLog(@"exists");
            [fileManager removeItemAtPath:savePath error:Nil];
        }
        [fileManager createFileAtPath:savePath contents:nil attributes:nil];
        NSLog(@"create file %@",savePath);
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
    [[NSFileManager defaultManager] removeItemAtPath:savePath error:Nil];
    [_delegate download:self onFileDownloadFaild:self.fileId];
}


// -------------------------------------------------------------------------------
//  connection:didReceiveData:data，通过data获得请求后，返回的数据，数据类型NSData
// -------------------------------------------------------------------------------
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    self.currentSize = self.currentSize + [data length];
    float progress = self.currentSize / (float)self.totalSize;
	
	[self save:data];
    
    if (progress==1) {
        //下载完成后，就不要执行updateProgress了
        NSLog(@"completed");
        [self.delegate download:self onFileDownloaded:self.fileId filePath:savePath];
        downloadFlag = NO;
    }else{
        [self.delegate download:self updateProgress:@"a" progress:progress];
    }
    data = nil;
}


-(void) save:(NSData *) data{
    
    FILE *file = fopen([savePath UTF8String], [@"ab+" UTF8String]);
    
    if(file!=NULL){
        fseek(file, 0, SEEK_END);
    }
    long readSize = [data length];
    fwrite((const void *)[data bytes], readSize, 1, file);
    fclose(file);
    data = nil;
}


@end
