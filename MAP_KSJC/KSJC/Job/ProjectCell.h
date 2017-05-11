//
//  FyxCustomCell.h
//  zzzf
//
//  Created by mark on 13-11-13.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysButton.h"
#import "Global.h"

@interface ProjectCell : UITableViewCell
{
    NSMutableDictionary *_project;



}

@property (weak, nonatomic) IBOutlet UILabel *lblCompany;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectName;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet SysButton *btnNewJob;
@property (weak, nonatomic) IBOutlet UILabel *labelRandom;
@property (weak, nonatomic) IBOutlet UILabel *labelName;

-(void)setProject:(NSMutableDictionary *)value;
-(NSMutableDictionary *)project;
@end
