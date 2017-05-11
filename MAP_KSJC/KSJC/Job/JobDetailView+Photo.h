//
//  JobDetailView+Photo.h
//  zzzf
//
//  Created by dist on 14-3-26.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "JobDetailView.h"
#import "JobPhotoView.h"
#import "WaitingView.h"
#import "GPS.h"


@interface JobDetailView (Photo) <GPSDelegate,JobPhotoTapDegelate>


-(void)photoalbum;
-(void)photograph;
-(void)initializePhotoData;
-(void)savePhoto;
-(void)renamePhoto:(NSString *) newName;
-(void)createThumbPhotos;
-(void)removePhotoViews;
-(void)removeCurrentSelectedPhoto;
-(void)ansyPhtots;
-(void)renameOnlinePhotoNameCompleted:(BOOL)successfully;

-(void)photoRequestFailed:(ASIHTTPRequest *)request;
-(void)photoRequestFinished:(ASIHTTPRequest *)request;

@end
