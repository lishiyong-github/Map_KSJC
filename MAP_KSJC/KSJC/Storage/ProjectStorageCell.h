//
//  ProjectStorageCell.h
//  zzzf
//
//  Created by mark on 14-2-19.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectInfo.h"
@interface ProjectStorageCell : UITableViewCell{
    ProjectInfo *_project;
}


@property (weak, nonatomic) IBOutlet UILabel *lblCompany;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectName;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectSize;

-(void)setProject:(ProjectInfo *)value;
-(ProjectInfo *)project;

@end
