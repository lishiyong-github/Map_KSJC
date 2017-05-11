//
//  FormSelectorViewController.h
//  zzzf
//
//  Created by mark on 14-2-14.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FormSelectorDelegate <NSObject>

-(void)formSelected:(NSInteger) rowIndex;

@end

@interface FormSelectorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (retain,nonatomic) UITableView *formsTableView;
@property (retain,nonatomic) NSMutableArray *formsList;
@property (retain,nonatomic) id<FormSelectorDelegate> delegate;

@end
