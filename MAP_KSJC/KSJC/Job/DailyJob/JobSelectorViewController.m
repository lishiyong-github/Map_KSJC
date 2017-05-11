//
//  JobSelectorViewController.m
//  zzzf
//
//  Created by dist on 14-1-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "JobSelectorViewController.h"
#import "FormAndMaterialCell.h"

@interface JobSelectorViewController ()

@end

@implementation JobSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblDate.text = _winTitle;
    //self.jobListControl.frame = CGRectMake(0, 55, 300, 300);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setJobs:(NSMutableArray *)jobs{
    _jobs = jobs;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _jobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier = @"FormAndMaterialCellIdentifier";
    
    FormAndMaterialCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (nil == cell) {
        UINib *nib = [UINib nibWithNibName:@"FormAndMaterialCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
    }
    cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    NSUInteger row = [indexPath row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    cell.fileName = [[_jobs objectAtIndex:row] objectForKey:@"patrolltime"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    [self.delegate jobSelected:row];
}

-(void)setTitleText:(NSString *)title{
    _winTitle = title;
}

//(void)setTitle:(NSString *)title{
//    self.lblDate.text = title;
//}

@end
