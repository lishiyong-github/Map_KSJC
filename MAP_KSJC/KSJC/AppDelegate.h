//
//  AppDelegate.h
//  KSJC
//
//  Created by 叶松丹 on 16/9/18.
//  Copyright © 2016年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <ArcGIS/ArcGIS.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability *hostReach;
}

@property (strong, nonatomic) UIWindow *window;


@end

