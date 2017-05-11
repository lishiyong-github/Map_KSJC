//
//  ResourcesView.h
//  zzzf
//
//  Created by mark on 13-11-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResourceManagerDelegate.h"

@interface FileItemThumbnailView : UIView{
    UILabel *lblFileName;
    NSString *_name;
    NSString *_type;
    NSString *_filePath;
}

-(void)load:(NSString *) name andType:(NSString *) type andFile:(NSString *)filePath;
@property (weak, nonatomic) IBOutlet UIScrollView *scrView;
@property (nonatomic,retain) id<FileItemThumbnailDelegate> delegate;
@end
