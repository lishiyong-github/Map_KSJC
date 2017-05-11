//
//  JobDetailView+Photo.m
//  zzzf
//
//  Created by dist on 14-3-26.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "JobDetailView+Photo.h"

#import "Global.h"
#import "MaterialGroupInfo.h"
#import <MobileCoreServices/UTCoreTypes.h>


@implementation JobDetailView (Photo)

int thumbWidth = 150;
int thumbHeight = 150;
int thumbGap = 20;
int thumbColumns=3;

-(void)initializePhotoData{
    //获取路径
    
    _photoSaveDirecotry=[_projectPath stringByAppendingString:@"/photos"];
    _photoMayUploadListFilePath = [_photoSaveDirecotry stringByAppendingString:@"/mayupload.plist"];
    
    //加载未同步的照片列表
    NSFileManager *manager = [NSFileManager defaultManager];
    
    //如果已经存在路径,就加载为上传照片列表
    if ([manager fileExistsAtPath:_photoMayUploadListFilePath]){
        _mayUploadPhotos = [NSMutableArray arrayWithContentsOfFile:_photoMayUploadListFilePath];
    }else{
        //不存在,可能上传的照片即为空
        _mayUploadPhotos = nil;
    }
    
    
    NSMutableArray *ps = [_project objectForKey:PROJECTKEY_PHOTOS];
    //获取所有照片
    _allPhotos = [NSMutableArray arrayWithArray:ps];
    //如果存在未同步照片,加到所有照片中
    if (nil!=_mayUploadPhotos) {
        [_allPhotos addObjectsFromArray:_mayUploadPhotos];
    }
    //列数
    thumbColumns = (self.frame.size.width-thumbGap)/(thumbWidth+thumbGap);
    
}
//打开相册获取图片
-(void)photoalbum
{
    _picker=[[UIImagePickerController alloc]init];
    _picker = [[UIImagePickerController alloc] init];//初始化
    _picker.delegate =self;
//    _picker.allowsEditing = YES;//设置可编辑
    _picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    UIPopoverController *popoverC=[[UIPopoverController alloc]initWithContentViewController:_picker];
    popoverC.delegate=self;
    poverController=popoverC;
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil) {
        controller = controller.presentedViewController;
    }
    
    [poverController presentPopoverFromRect:CGRectMake(500, 100, 1, 1) inView:controller.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

//拍照获取图片
-(void)photograph{
//    //打开定位
//    if (nil==_gpsLoader) {
//        _gpsLoader = [[GPS alloc] init];
//        _gpsLoader.delegate = self;
//    }
//    //开始定位
//    [_gpsLoader startGPS];
    
    //[self hideMenu];
    //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController != nil) {
        controller = controller.presentedViewController;
    }
    
    //sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //图片库
    //sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; //保存的相片
    _picker = [[UIImagePickerController alloc] init];//初始化
    _picker.delegate = self;
//    _picker.allowsEditing = YES;//设置可编辑
    _picker.sourceType = sourceType;
    [controller presentViewController:_picker animated:YES completion:nil];
}

//-(void)gpsDidReaded:(CLLocationCoordinate2D)location{
//    _gpsInfo = [NSString stringWithFormat:@"%f,%f",location.longitude,location.latitude];
//}

#pragma mark -UIImagePickerController代理方法

//点击取消
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary||picker.sourceType==UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        [poverController dismissPopoverAnimated:YES];
    }
    else if (picker.sourceType==UIImagePickerControllerSourceTypeCamera){
        [_picker dismissViewControllerAnimated:YES completion:nil];
    }
}

//点击使用照片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary||picker.sourceType==UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        [poverController dismissPopoverAnimated:YES];
        _currentSelectorPhoto=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [self savePhoto];
    }
    else if (picker.sourceType==UIImagePickerControllerSourceTypeCamera){
        [_picker dismissViewControllerAnimated:YES completion:nil];
        NSString* mediaType=[info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:(NSString*)kUTTypeImage])
        {
            UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation=image.imageOrientation;
            if(imageOrientation!=UIImageOrientationUp)
            {
                // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
                // 以下为调整图片角度的部分
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                _currentSelectorPhoto = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                // 调整图片角度完毕
            }else{
                _currentSelectorPhoto = image;
            }
        }
//        _picker.sourceType =  UIImagePickerControllerSourceTypeCamera;
//        _currentSelectorPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self savePhoto];
        //过1.5秒再次弹出拍照界面
        [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(rePhotograph) userInfo:nil repeats:NO];
    }
}

//再次弹出拍照界面
-(void)rePhotograph{
     UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
     while (controller.presentedViewController != nil) {
     controller = controller.presentedViewController;
     }
     [controller presentViewController:_picker animated:YES completion:nil];
}


//保存图片设置照片属性
-(void)savePhoto{
    
    NSFileManager *fm=[NSFileManager defaultManager];
    //如果路径不存在即创建保存路径
    if ([fm fileExistsAtPath:_photoSaveDirecotry]==NO) {
        [fm createDirectoryAtPath:_photoSaveDirecotry withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //判断是否初始化可能同步数组
    if (nil==_mayUploadPhotos) {
        _mayUploadPhotos = [NSMutableArray arrayWithCapacity:10];
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"HH:mm:ss";
    //照片名称为当前时间
    NSString *photoName = [df stringFromDate:[NSDate date]];
    
    self.lblNoImg.hidden = YES;
    
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //生成照片唯一标识字符串
    NSString *photoCode = [Global newUuid];
    
    NSMutableDictionary *photoInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    [photoInfo setObject:[df stringFromDate:[NSDate date]] forKey:@"time"];
    [photoInfo setObject:photoCode forKey:@"code"];
    [photoInfo setObject:photoName forKey:@"name"];
    if (nil==_gpsInfo) {
        _gpsInfo = @"";
    }
    [photoInfo setObject:_gpsInfo forKey:@"location"];
    [photoInfo setObject:@"NO" forKey:@"uploaded"];
    [_mayUploadPhotos addObject:photoInfo];
    
    NSString *imgSavePath = [_photoSaveDirecotry stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",photoCode]];
    [UIImageJPEGRepresentation(_currentSelectorPhoto, 1.0) writeToFile:imgSavePath atomically:YES];
    
    
    [photoInfo setObject:imgSavePath forKey:@"path"];
    //自动写入保存路径
    [_mayUploadPhotos writeToFile:_photoMayUploadListFilePath atomically:YES];
    //计算行列
    int column = _allPhotos.count%thumbColumns+1;
    int row = _allPhotos.count/thumbColumns+1;
    
    JobPhotoView *thumbView = [[JobPhotoView alloc] initWithFrame:CGRectMake(thumbGap*column+(column-1)*thumbWidth,thumbGap*row+(row-1)*thumbHeight,thumbWidth, thumbHeight)];
    thumbView.delegate = self;
    thumbView.uploaded = NO;
    thumbView.photoCode = photoCode;
    [photoInfo setObject:[NSString stringWithFormat:@"%d",_phFlowState] forKey:@"flow"];
    //设置照片名称   批后
    if ([_type isEqualToString:@"Phxm"]) {
        thumbView.photoName = [NSString stringWithFormat:@"%@-%@",[self phFlowNameFromCode:[NSString stringWithFormat:@"%d",_phFlowState]],photoName];
    }else{
        //时间
        thumbView.photoName = photoName;
    }
    thumbView.tag = _allPhotos.count;
    thumbView.uploaded = NO;
    
    [self.thumbPhotoContainer addSubview:thumbView];
    
    
    thumbView.photoPath = imgSavePath;
    //把照片添加到所有照片中
    [_allPhotos addObject:photoInfo];
    
    int rows = _allPhotos.count/thumbColumns;
    if (_allPhotos.count%thumbColumns!=0) {
        rows++;
    }
    //设置底部scrollview的可显示范围
    self.thumbPhotoContainer.contentSize = CGSizeMake(self.thumbPhotoContainer.frame.size.width,rows *(thumbHeight+thumbGap)+thumbGap);
    
    if (nil==_currentSelectedPhoto) {
        _currentSelectedPhoto = thumbView;
        thumbView.selected  = YES;
    }
    //删除照片和重命名照片按钮可点击
    self.btnDeletePhoto.enabled = self.btnRenamePhoto.enabled = YES;
    [self refreshButtonStatus];
    [self saveImageToAlbum:_currentSelectorPhoto];
}

-(void)renamePhoto:(NSString *)newName{
    _newPhotoName = newName;
    if (_currentSelectedPhoto.uploaded) {
        [Global wait:@"请稍候..."];
        _rnSp = [ServiceProvider initWithDelegate:self];
        _rnSp.tag = 5;
        [_rnSp getString:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"renamePhoto",@"action",@"0",@"daily", _currentSelectedPhoto.photoCode,@"code",newName,@"name",nil]];
        
    }else{
        [self modifyLocalPhotoName:newName];
    }
}

-(void)renameOnlinePhotoNameCompleted:(BOOL)successfully{
    if (successfully) {
        [Global wait:nil];
        [self modifyLocalPhotoName:_newPhotoName];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"修改失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)modifyLocalPhotoName:(NSString *)newName{
    _currentSelectedPhoto.photoName = newName;
    for (NSMutableDictionary *photoInfo in _allPhotos) {
        NSString *c = [photoInfo objectForKey:@"code"];
        if ([c isEqualToString:_currentSelectedPhoto.photoCode]) {
            [photoInfo setValue:newName forKey:@"name"];
        }
    }
    /*
    if (_currentSelectedPhoto.uploaded) {
        NSMutableArray *ps = [_project objectForKey:PROJECTKEY_PHOTOS];
        for (NSMutableDictionary *photoInfo in ps) {
            NSString *c = [photoInfo objectForKey:@"code"];
            if ([c isEqualToString:_currentSelectedPhoto.photoCode]) {
                [photoInfo setValue:newName forKey:@"name"];
            }
        }
        
    }*/
    [self saveProjectToDisk];
    [_mayUploadPhotos writeToFile:_photoMayUploadListFilePath atomically:YES];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存照片到相册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

//把照片保存到相册中
-(void)saveImageToAlbum:(UIImage *)img{
    UIImageWriteToSavedPhotosAlbum(img, self,
                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//更新按钮状态
-(void)refreshButtonStatus{
    //同步照片按钮的状态(根据可能上传的个数决定)
    self.btnSubmitPhoto.enabled = _mayUploadPhotos!=nil && _mayUploadPhotos.count>0;
    //有可同步的照片 在按钮后加上个数
    if (self.btnSubmitPhoto.enabled) {
        [self.btnSubmitPhoto setTitle:[NSString stringWithFormat:@"同步照片(%d)",_mayUploadPhotos.count] forState:UIControlStateNormal];
    }else{
        [self.btnSubmitPhoto setTitle:@"同步照片" forState:UIControlStateNormal];
    }
    //如果有选中某个照片,那么删除和修改名称按钮可点击
    self.btnDeletePhoto.enabled = self.btnRenamePhoto.enabled = nil!=_currentSelectedPhoto;
}

//创建相册
-(void)createThumbPhotos{
    _currentSelectedPhoto = nil;
    //移除子视图
    [self removePhotoViews];
    int rows = _allPhotos.count/thumbColumns;
    if (_allPhotos.count%thumbColumns!=0) {
        rows++;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    int tag = 0;
    for (int i=0; i<rows; i++) {
        for (int j=0; j<thumbColumns && tag<_allPhotos.count; j++ ){
            NSMutableDictionary *photoInfo = [_allPhotos objectAtIndex:tag];
            NSString *photoName = [photoInfo objectForKey:@"name"];
            NSString *photoCode = [photoInfo objectForKey:@"code"];
            NSString *localPath = [NSString stringWithFormat:@"%@/%@.jpg",_photoSaveDirecotry,photoCode];
            JobPhotoView *imgView = [[JobPhotoView alloc] initWithFrame:CGRectMake(thumbGap*(j+1)+j*thumbWidth,thumbGap*(i+1)+i*thumbHeight,thumbWidth, thumbHeight)];
            [photoInfo objectForKey:@"flow"];
            //取出
            if ([fm enumeratorAtPath:localPath]) {
                imgView.photoPath = localPath;
                [photoInfo setObject:@"yes" forKey:@"local"];
                [photoInfo setObject:localPath forKey:@"path"];
            }else{
                imgView.photoUrl = [NSString stringWithFormat:@"%@?type=zf&action=getphoto&business=project&code=%@&thumbnail=yes",[Global serviceUrl],photoCode];
                NSString *path=[NSString stringWithFormat:@"%@?type=zf&action=getphoto&business=project&code=%@&thumbnail=no",[Global serviceUrl],photoCode];
                [photoInfo setObject:path forKey:@"path"];
            }
            imgView.photoCode = photoCode;
            imgView.tag = tag;
            //批后监察
            if ([_type isEqualToString:@"Phxm"]) {
                imgView.photoName = [NSString stringWithFormat:@"%@-%@",[self phFlowNameFromCode:[photoInfo objectForKey:@"flow"]],photoName];
            }else{
                imgView.photoName = photoName;
            }
            imgView.delegate = self;
            imgView.uploaded = [[photoInfo objectForKey:@"uploaded"] isEqualToString:@"YES"];
            [self.thumbPhotoContainer addSubview:imgView];
            //默认选择第一张照片
            if (tag==0) {
                imgView.selected = YES;
                _currentSelectedPhoto = imgView;
            }
            tag ++;
        }
    }
    if (_allPhotos.count>0) {
        self.lblNoImg.hidden = YES;
    }
    self.thumbPhotoContainer.contentSize = CGSizeMake(self.thumbPhotoContainer.frame.size.width,rows *(thumbHeight+thumbGap)+thumbGap);
    [self refreshButtonStatus];
}

-(NSString *)phFlowNameFromCode:(NSString *)code{
    NSString *flowStr = @"";
    int flowVal = [code intValue];
    switch (flowVal) {
        case 0:flowStr = @"基础";break;
        case 1:flowStr = @"转换";break;
        case 2:flowStr = @"标准";break;
        case 3:flowStr = @"封顶";break;
        case 4:flowStr = @"外立面";break;
        default:break;
    }
    return flowStr;
}


int submitIndex=0;

//点击同步照片执行的方法
- (void)ansyPhtots {
    //有网
    if([Global isOnline]){
        //[Global wait:@"正在提交照片..."];
        submitIndex = 0;
        _ansyCompletedPhotos = [NSMutableArray arrayWithCapacity:10];
        _mayUploadPhotosClone = [NSMutableArray arrayWithArray:_mayUploadPhotos];
        [self doAnsyPhoto];
    }else{
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles :nil];
        [msg show];
    }
}

//执行同步照片操作
-(void)doAnsyPhoto{
    //同步位置和张数相同时
    if (submitIndex==_mayUploadPhotos.count) {
        [Global wait:nil];
        [self refreshButtonStatus];
        for (NSString *pc in _ansyCompletedPhotos) {
            for (int i=0;i<_mayUploadPhotos.count;i++) {
                NSMutableDictionary *di = [_mayUploadPhotos objectAtIndex:i];
                NSString *pc2 = [di objectForKey:@"code"];
                if ([pc2 isEqualToString:pc]) {
                    [_mayUploadPhotos removeObjectAtIndex:i];
                    break;
                }
            }
        }
        [_ansyCompletedPhotos removeAllObjects];
        [self refreshButtonStatus];
        if (_mayUploadPhotos.count>0) {
            UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"提示" message:@"有照片没有上传成功，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles :nil];
            [msg show];
        }
    }
    else{
        NSMutableDictionary *photoInfo = [_mayUploadPhotos objectAtIndex:submitIndex];
        
        NSString *photoName = [photoInfo objectForKey:@"name"];
        NSString *photoCode = [photoInfo objectForKey:@"code"];
        
        DataPostman *postman = [[DataPostman alloc] init];
        postman.tag=1;
        UIImage *theImg = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.jpg",_photoSaveDirecotry,photoCode]];
        
        NSString *deviceNumber = [Global currentUser].deviceNumber;
        if (nil==deviceNumber) {
            deviceNumber = @"";
        }
        NSMutableDictionary *postdata = [NSMutableDictionary dictionaryWithCapacity:6];
        [Global wait:[NSString stringWithFormat:@"正在提交照片(%d/%d)...",submitIndex+1,_mayUploadPhotos.count]];
        [postdata setObject:theImg forKey:@"img"];
        [postdata setObject:[photoInfo objectForKey:@"location"] forKey:@"location"];
        [postdata setObject:photoName forKey:@"name"];
        [postdata setObject:photoCode forKey:@"code"];
        [postdata setObject:_type forKey:@"business"];
        [postdata setObject:@"zf" forKey:@"type"];
        [postdata setObject:[photoInfo objectForKey:@"time"] forKey:@"time"];
        [postdata setObject:@"uploadphoto" forKey:@"action"];
        [postdata setObject:[_project objectForKey:PROJECTKEY_ID] forKey:@"project"];
        [postdata setObject:deviceNumber forKey:@"device"];
        [postdata setObject:[NSString stringWithFormat:@"%d",_phFlowState] forKey:@"flow"];
        //上传
        [postman postDataWithUrl:[Global serviceUrl] data:postdata delegate:self];
    }
}


-(void)photoRequestFailed:(ASIHTTPRequest *)request{
    submitIndex++;
    [self doAnsyPhoto];
}


-(void)photoRequestFinished:(ASIHTTPRequest *)request{
    if (request.responseStatusCode==200) {
        NSError *parseError = nil;
        NSString *responseString = request.responseString;
        NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&parseError];
        if(nil!=parseError){
            [self photoRequestFailed:nil];
        }else if([[rs objectForKey:@"status"] isEqualToString:@"false"]){
            [self photoRequestFailed:nil];
            NSLog(@"photoSubmit failed:%@",[rs objectForKey:@"message"]);
        }else{
            
            NSMutableArray *ps = [_project objectForKey:PROJECTKEY_PHOTOS];
            
            NSMutableDictionary *photoInfo = [_mayUploadPhotos objectAtIndex:submitIndex];
            [_mayUploadPhotosClone removeObjectAtIndex:0];
            [_mayUploadPhotosClone writeToFile:_photoMayUploadListFilePath atomically:YES];
            
            [photoInfo setObject:@"YES" forKey:@"uploaded"];
            [ps addObject:photoInfo];
            [self saveProjectToDisk];
            
            NSString *photoCode = [photoInfo objectForKey:@"code"];
            NSArray *photoViews = self.thumbPhotoContainer.subviews;
            for (int i=0; i<photoViews.count; i++) {
                JobPhotoView *pv = [photoViews objectAtIndex:i];
                if ([pv.photoCode isEqualToString:photoCode]) {
                    pv.uploaded = YES;
                    break;
                }
            }
            [_ansyCompletedPhotos addObject:photoCode];
            submitIndex++;
            [self refreshButtonStatus];
            [self doAnsyPhoto];
        }
        
    }else{
        [self photoRequestFailed:nil];
    }
    
    
}


-(void)removePhotoViews{
    NSArray *photoViews = [self.thumbPhotoContainer subviews];
    for (int i=photoViews.count-1; i>=0; i--) {
        [[photoViews objectAtIndex:i] removeFromSuperview];
    }
}

-(void)removeCurrentSelectedPhoto{
    
    NSString *photoCode = _currentSelectedPhoto.photoCode;
    //如果是已经上传的
    if (_currentSelectedPhoto.uploaded) {
        [Global addDataToSyn:[NSString stringWithFormat:@"REMOVEPHOTO_%@",photoCode] data:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"removePhoto",@"action",photoCode,@"code",@"zf",@"type",[Global serviceUrl],@"posturl", nil]];
        NSMutableArray *ps = [_project objectForKey:PROJECTKEY_PHOTOS];
        for (int i=0; i<ps.count;i++) {
            NSString *pc = [[ps objectAtIndex:i] objectForKey:@"code"];
            if ([pc isEqualToString:photoCode]) {
                [ps removeObjectAtIndex:i];
                break;
            }
        }
        [self saveProjectToDisk];
    }else{
        //还未上传
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:_currentSelectedPhoto.photoPath error:nil];
        //移除可能上传照片数组
        for (int i=0; i<_mayUploadPhotos.count;i++) {
            NSString *pc = [[_mayUploadPhotos objectAtIndex:i] objectForKey:@"code"];
            if ([pc isEqualToString:photoCode]) {
                [_mayUploadPhotos removeObjectAtIndex:i];
                break;
            }
        }
        [_mayUploadPhotos writeToFile:_photoMayUploadListFilePath atomically:YES];
    }
    //从所有照片中移除
    for (int i=0; i<_allPhotos.count; i++) {
        NSString *pc = [[_allPhotos objectAtIndex:i] objectForKey:@"code"];
        if ([pc isEqualToString:photoCode]) {
            [_allPhotos removeObjectAtIndex:i];
            break;
        }
    }
    
    //将当前选中照片移除
    [_currentSelectedPhoto removeFromSuperview];
    NSArray *photoViews = [self.thumbPhotoContainer subviews];
    [UIView beginAnimations:nil context:nil];
    //保存当前选中的照片tag
    int moveTag = _currentSelectedPhoto.tag;
    //清空选中照片
    _currentSelectedPhoto = nil;
    //设定动画持续时间
    [UIView setAnimationDuration:0.3];
    //从删除掉照片的位置开始布局
    for (int i=moveTag; i<photoViews.count;i++) {
        //取需要移位置的照片
        JobPhotoView *nextPhoto = [photoViews objectAtIndex:i];
        //选中删除后的最后一个照片
        if (nil==_currentSelectedPhoto) {
            _currentSelectedPhoto = nextPhoto;
            nextPhoto.selected = YES;
        }
        int row = i/thumbColumns;
        int column = i%thumbColumns;
        nextPhoto.tag = i;
        //设置frame
        nextPhoto.frame = CGRectMake(thumbGap*(column+1)+column*thumbWidth,thumbGap*(row+1)+row*thumbHeight,thumbWidth, thumbHeight);
    }
    //提交动画
    [UIView commitAnimations];
    //如果删除的是最后一张照片(手动选择删除后的最后一张照片)
    if (nil==_currentSelectedPhoto && photoViews.count!=0) {
        _currentSelectedPhoto = [photoViews objectAtIndex:photoViews.count-1];
        _currentSelectedPhoto.selected = YES;
    }
    
    //刷新按钮状态
    [self refreshButtonStatus];
}



#pragma -mark 调用新加的方法，传一个nsarray
-(void)jobPhotoDoubleTap:(JobPhotoView *)photoView{
    NSMutableArray *toOpenFiles =[NSMutableArray arrayWithCapacity:_allPhotos.count];
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSMutableDictionary *photoInfo in _allPhotos) {
        NSMutableDictionary *clonePhoto = [NSMutableDictionary dictionaryWithDictionary:photoInfo];
        NSString *localPath = [clonePhoto objectForKey:@"path"];
        if ([fm fileExistsAtPath:localPath]) {
            [clonePhoto setObject:@"NO" forKey:@"uploaded"];
        }
        [toOpenFiles addObject:clonePhoto];
    }
    [self.delegate openMaterial:toOpenFiles at:photoView.tag];
}


-(void)jobPhotoTap:(JobPhotoView *)photoView{
    if ([_currentSelectedPhoto.photoCode isEqualToString:photoView.photoCode]) {
        return;
    }
    _currentSelectedPhoto.selected = NO;
    _currentSelectedPhoto = photoView;
    photoView.selected = YES;
    if(_readonly)
        [self jobPhotoDoubleTap:photoView];
}
@end
