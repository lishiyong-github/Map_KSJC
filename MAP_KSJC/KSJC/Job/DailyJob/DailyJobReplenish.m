//
//  DailyJobReplenish.m
//  zzzf
//
//  Created by dist on 14/9/4.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DailyJobReplenish.h"
#import "Global.h"
#import "DataPostman.h"

@interface DailyJobReplenish ()<ASIHTTPRequestDelegate>

@end

@implementation DailyJobReplenish

-(void)upload:(NSMutableArray *)jobs savePath:(NSString *)savePath{
    _jobSavePath = savePath;
    UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定开始补传巡查数据吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开始上传", nil];
    [comfirm show];
    _jobs = jobs;
    _currentJobIndex = jobs.count-1;
    _currentPhotoIndex = 0;
    _currentSubIndex = 0;
    _photoCount = 0;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        for (NSMutableDictionary *job in _jobs) {
            NSMutableArray *ps = [job objectForKey:@"photos"];
            _photoCount += ps.count;
        }
        [Global wait:@"正在上传：0%"];
        [self doUploadJob];
    }
}

-(void)deyCompleted{
    [Global wait:nil];
    [self.delegate dailyjobDidReplenishCompleted];
}

-(void)doUploadJob{
    if (_currentJobIndex<0) {
        //completed
        [Global wait:@"上传完成"];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(deyCompleted) userInfo:nil repeats:NO];
    }else{
        NSMutableDictionary *jobInfo = [_jobs objectAtIndex:_currentJobIndex];
        NSMutableArray *photos = [jobInfo objectForKey:@"photos"];
        _currentSubIndex=photos.count-1;
        [self doUploadPhoto];
    }
}

-(void)doUploadPhoto{
    if (_currentSubIndex<0) {
        [self removeCurrentJob];
        _currentJobIndex--;
        [self doUploadJob];
    }else{
        NSMutableDictionary *jobInfo = [_jobs objectAtIndex:_currentJobIndex];
        NSMutableArray *photos = [jobInfo objectForKey:@"photos"];
        [self executeUpload:[photos objectAtIndex:_currentSubIndex]];
    }
}

-(void)removeCurrentJob{
    [_jobs removeObjectAtIndex:_currentJobIndex];
    [_jobs writeToFile:_jobSavePath atomically:YES];
}

-(void)removeCurrentPhoto{
    NSMutableDictionary *job = [_jobs objectAtIndex:_currentJobIndex];
    NSMutableArray *photos = [job objectForKey:@"photos"];
    NSMutableDictionary *photoInfo = [photos objectAtIndex:_currentSubIndex];
    [photos removeObjectAtIndex:_currentSubIndex];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[photoInfo objectForKey:@"path"] error:nil];
    [_jobs writeToFile:_jobSavePath atomically:YES];
    photoInfo = nil;
}

-(void)executeUpload:(NSMutableDictionary *)photo{
    //[Global wait:[NSString stringWithFormat:@"正在同步照片 %d/%d",_submitIndex+1,_mayUploadPhotosClone.count]];
    //self.lblWaitMsg.text=[NSString stringWithFormat:@"正在同步照片 %d/%d",_submitIndex+1,_mayUploadPhotos.count];
    NSString *photoName = [photo objectForKey:@"name"];
    NSString *photoCode = [photo objectForKey:@"code"];
    
    DataPostman *postman = [[DataPostman alloc] init];
    UIImage *theImg = [UIImage imageWithContentsOfFile:[photo objectForKey:@"path"]];
    
    NSMutableDictionary *postdata = [NSMutableDictionary dictionaryWithCapacity:6];
    [postdata setObject:theImg forKey:@"img"];
    [postdata setObject:[photo objectForKey:@"jobid"] forKey:@"jobid"];
    
    [postdata setObject:[photo objectForKey:@"location"] forKey:@"location"];
    [postdata setObject:photoName forKey:@"name"];
    [postdata setObject:photoCode forKey:@"code"];
    [postdata setObject:@"zf" forKey:@"type"];
    [postdata setObject:[photo objectForKey:@"createtime"] forKey:@"time"];
    [postdata setObject:@"replenishphoto" forKey:@"action"];
    [postdata setObject:[Global currentUser].deviceNumber forKey:@"device"];
    postman.tag = 1;
    [postman postDataWithUrl:[Global serviceUrl] data:postdata delegate:self];
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    //_currentSubIndex --;
    //[self doUploadJob];
    [Global wait:nil];
    [NSTimer scheduledTimerWithTimeInterval:.6 target:self selector:@selector(showError) userInfo:nil repeats:NO];
}

-(void)showError{
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"上传失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    if (request.responseStatusCode==200) {
        NSError *parseError = nil;
        NSString *responseString = request.responseString;
        NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&parseError];
        if(nil!=parseError){
            [self requestFailed:request];
        }else if([[rs objectForKey:@"status"] isEqualToString:@"false"]){
            [self requestFailed:request];
            NSLog(@"photoSubmit failed:%@",[rs objectForKey:@"message"]);
        }else {
            [self removeCurrentPhoto];
            _currentSubIndex--;
            _currentPhotoIndex++;
            float rate = (_currentPhotoIndex*1.0f)/(_photoCount*1.0f)*100;
            [Global wait:[NSString stringWithFormat:@"正在上传：%d %%",(int)rate]];
            [self doUploadPhoto];
        }
    }else{
        [self requestFailed:request];
    }
}


@end
