//
//  UserLocationModel.h
//  KSJC
//
//  Created by shiyong_li on 2017/5/15.
//  Copyright © 2017年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserLocationModel : NSObject
@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *longitude;
@property (nonatomic,strong) NSString *pid;
@property (nonatomic,strong) NSString *projectName;
@property (nonatomic,strong) NSString *projectAddress;
@property (nonatomic,strong) NSString *company;
@end
