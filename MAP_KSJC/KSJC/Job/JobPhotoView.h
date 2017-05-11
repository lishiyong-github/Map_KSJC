//
//  JobPhotoView.h
//  zzzf
//
//  Created by dist on 13-12-13.
//  Copyright (c) 2013年 dist. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "FGalleryPhoto.h"

@protocol JobPhotoTapDegelate;

static NSMutableDictionary *cacheThumbs;

@interface JobPhotoView : UIImageView<FGalleryPhotoDelegate>{
    UIActivityIndicatorView *_waiting;
    UILabel *_lblPhotoName;
    UIView *_photoNameView;
    UIImageView *_imgForUploaded;
}

@property (nonatomic) BOOL selected;
@property (nonatomic,retain) NSString *photoPath;
@property (nonatomic,retain) NSString *fullsizePhotoPath;
@property (nonatomic,retain) NSString *photoUrl;
@property (nonatomic,retain) id<JobPhotoTapDegelate> delegate;
@property (nonatomic,retain) NSString *photoName;
@property (nonatomic,retain) NSString *photoCode;
@property (nonatomic) BOOL uploaded;

@end

@protocol JobPhotoTapDegelate <NSObject>

-(void)jobPhotoTap:(JobPhotoView *)photoView;
-(void)jobPhotoDoubleTap:(JobPhotoView *)photoView;
@end