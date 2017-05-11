//
//  FyxCustomCell.m
//  zzzf
//
//  Created by mark on 13-11-13.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ProjectCell.h"
#import "MZFormSheetController.h"

@implementation ProjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        [self showDoubleRandom:NO];
          }
    return self;
}

- (void)showDoubleRandom:(BOOL)show
{
    [self.labelName setHidden:!show];
    [self.labelRandom setHidden:!show];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    if (selected) {
        self.backgroundColor=[UIColor colorWithRed:191.0/255.0 green:243.0/255.0 blue:235.0/255.0 alpha:1];
        //[self.lblCompany setTextColor:[UIColor whiteColor]];
        //[self.lblDateTime setTextColor:[UIColor whiteColor]];
        //[self.lblProjectName setTextColor:[UIColor whiteColor]];
    }else{
        self.backgroundColor=[UIColor whiteColor];
        //[self.lblDateTime setTextColor:[UIColor colorWithRed:86.0/255.0 green:151.0/255.0 blue:170.0/255.0 alpha:1]];
        //[self.lblProjectName setTextColor:[UIColor blackColor]];
    }
    // Configure the view for the selected state
}

-(void)setProject:(NSMutableDictionary *)value{
    
    _project = value;
    self.lblProjectName.text = [value objectForKey:@"projectName"];
    self.lblCompany.text = [value objectForKey:@"address"];
    self.lblDateTime.text = [value objectForKey:@"time"];
    self.labelName.text = [value objectForKey:@"teamMate"];
    [self showDoubleRandom:[[value objectForKey:@"isDoubleRamdom"] isEqualToString:@"是"]];
}

-(NSMutableDictionary *)project{
    return _project;
}


@end
