//
//  DailyJobReplenish.h
//  zzzf
//
//  Created by dist on 14/9/4.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DailyJobReplenishDelegate <NSObject>

-(void)dailyjobDidReplenishCompleted;

@end

@interface DailyJobReplenish : NSObject<UIAlertViewDelegate>{
    int _currentPhotoIndex;
    NSMutableArray *_jobs;
    NSString *_jobSavePath;
    int _photoCount;
    int _currentJobIndex;
    int _currentSubIndex;
}

-(void)upload:(NSMutableArray *)jobs savePath:(NSString *)savePath;
@property (nonatomic,retain) id<DailyJobReplenishDelegate> delegate;

@end
