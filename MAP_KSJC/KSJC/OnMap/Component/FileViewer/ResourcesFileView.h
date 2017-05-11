//
//  ResourcesView.h
//  zzzf
//
//  Created by mark on 13-11-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResourcesView.h"

@interface ResourcesFileView : UIView

-(void)load:(NSString *) name andType:(NSString *) type;
@property (weak, nonatomic) IBOutlet UIScrollView *scrView;
@property ResourcesView *owner;
@end
