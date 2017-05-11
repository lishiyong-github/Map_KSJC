//
//  PhotoViewer.m
//  zzzf
//
//  Created by dist on 14-2-26.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "PhotoCollection.h"
#import "Global.h"

@implementation PhotoCollection

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//加载照片
-(void)loadPhotos:(NSArray *)photos{
    _photos = [[NSMutableArray alloc]initWithArray:photos];
    int thumbWidth = 150;
    int thumbHeight = 150;
    int thumbGap = 20;
    int thumbColumns = (self.frame.size.width-thumbGap)/(thumbWidth+thumbGap);
    
    int rows = _photos.count/thumbColumns;
    if (_photos.count%thumbColumns!=0) {
        rows++;
    }
    
    int tag = 0;
    for (int i=0; i<rows; i++) {
        for (int j=0; j<thumbColumns && tag<_photos.count; j++ ){
            JobPhotoView *imgView = [[JobPhotoView alloc] initWithFrame:CGRectMake(thumbGap*(j+1)+j*thumbWidth,thumbGap*(i+1)+i*thumbHeight,thumbWidth, thumbHeight)];
            imgView.delegate=self;
            imgView.tag = tag;
            NSMutableDictionary *photoInfo = [NSMutableDictionary dictionary];
            photoInfo=[_photos objectAtIndex:tag];
            NSString *photoThumbnailUrl = [NSString stringWithFormat:@"%@?type=zf&action=getphoto&code=%@&thumbnail=yes",[Global serviceUrl],[photoInfo objectForKey:@"code"]];
            
            NSString *photoNoThumbnailUrl = [NSString stringWithFormat:@"%@?type=zf&action=getphoto&code=%@&thumbnail=no",[Global serviceUrl],[photoInfo objectForKey:@"code"]];
            
            imgView.photoUrl = photoThumbnailUrl;
            imgView.photoName = [photoInfo objectForKey:@"name"];
            imgView.uploaded = NO;
            
            if (imgView.photoPath!=nil) {
                [photoInfo setObject:imgView.photoPath forKey:@"path"];
                [photoInfo setObject:@"yes" forKey:@"local"];
            }
            else{
                [photoInfo setObject:photoNoThumbnailUrl forKey:@"path"];
                [photoInfo setObject:@"yes" forKey:@"uploaded"];
            }
            [self addSubview:imgView];
            
            tag++;
        }
    }
    self.contentSize = CGSizeMake(self.frame.size.width, (thumbHeight+thumbGap)*rows+100);
}

-(void)galleryPhoto:(FGalleryPhoto *)photo didLoadThumbnail:(UIImage *)image{
    JobPhotoView *jp = [self.subviews objectAtIndex:photo.tag];
    jp.image = image;
}

-(void)galleryPhoto:(FGalleryPhoto *)photo didLoadFullsize:(UIImage *)image{
    
}

-(void)jobPhotoTap:(JobPhotoView *)photoView{
    [self openPhotoAt:photoView];
}

-(void)jobPhotoDoubleTap:(JobPhotoView *)photoView{
    [self openPhotoAt:photoView];
}

-(void)openPhotoAt:(JobPhotoView *)p{
    if (nil!=_selectedPhoto) {
        _selectedPhoto.selected = NO;
    }
    p.selected = YES;
    _selectedPhoto = p;
    
    //改
    if (_photos!=nil&&_photos.count>1) {
        NSMutableArray *_allFilesInfo=[[NSMutableArray alloc]initWithArray:_photos];
        NSMutableDictionary *itemDic=[NSMutableDictionary dictionary];
        for (int i=0; i<_allFilesInfo.count; i++) {
            itemDic=[_allFilesInfo objectAtIndex:i];
            [itemDic setObject:@"jpg" forKey:@"ext"];
            // [itemDic setObject:[itemDic objectForKey:@"createtime"] forKey:@"time"];
        }
        [self.photoDelegate openPhotos:_allFilesInfo at:p.tag];
    }
    //保留打开单张图片
    else{
        NSDictionary *photoInfo = [_photos objectAtIndex:p.tag];
        NSString *photoUrl = [NSString stringWithFormat:@"%@?type=zf&action=getphoto&code=%@",[Global serviceUrl],[photoInfo objectForKey:@"code"]];
        [self.photoDelegate photoCollectionShouldOpenPhoto:[photoInfo objectForKey:@"name"] url:photoUrl];
    }
}

@end
