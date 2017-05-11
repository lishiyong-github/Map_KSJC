//
//  MapViewController+IdentifyPictureMarker.h
//  zzzf
//
//  Created by Aaron on 14-2-28.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapViewController.h"
#import "DrawHelper.h"

@interface MapViewController (IdentifyPictureMarker)<ServiceCallbackDelegate>{

}

-(void)creatPictureMarkGraphics:(NSInteger)selectIndex pictureMarkPointsDataSource:(NSMutableArray*)pictureMarkPoints;

@end
