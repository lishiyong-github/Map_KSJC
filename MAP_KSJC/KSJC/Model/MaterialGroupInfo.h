//
//  MaterialGroupInfo.h
//  zzzf
//
//  Created by dist on 13-11-27.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaterialGroupInfo : NSObject<NSCoding>{
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic,retain) NSString *ID;
@property (nonatomic,retain) NSString *instanceID;
@property (nonatomic, retain) NSMutableArray *files;

@end
