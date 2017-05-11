//
//  PhotoViewer.h
//  zzzf
//
//  Created by dist on 14-2-26.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JobPhotoView.h"
#import "FGalleryPhoto.h"

@protocol PhotoCollectionDelegate <NSObject>

-(void)photoCollectionShouldOpenPhoto:(NSString *)name url:(NSString *)url;
//新添方法
-(void)openPhotos:(NSArray *)files at:(int)index;

@end

@interface PhotoCollection : UIScrollView<FGalleryPhotoDelegate,JobPhotoTapDegelate>{
    NSMutableArray *_photos;
    JobPhotoView *_selectedPhoto;
}

@property (nonatomic,retain) id<PhotoCollectionDelegate> photoDelegate;
-(void)loadPhotos:(NSArray *)photos;

@end
