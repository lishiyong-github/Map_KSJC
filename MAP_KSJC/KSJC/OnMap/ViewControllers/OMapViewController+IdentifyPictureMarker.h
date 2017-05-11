//
//  OMapViewController+IdentifyPictureMarker.h
//  zzzf
//
//  Created by Aaron on 14-3-9.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController.h"
#import "DrawHelper.h"

@interface OMapViewController (IdentifyPictureMarker)


-(void)creatPictureMarkGraphics:(NSInteger)selectIndex pictureMarkPointsDataSource:(NSMutableArray*)pictureMarkPoints;
@end
