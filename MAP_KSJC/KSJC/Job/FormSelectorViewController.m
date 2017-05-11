//
//  FormSelectorViewController.m
//  zzzf
//
//  Created by mark on 14-2-14.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "FormSelectorViewController.h"
#import "FormAndMaterialCell.h"
//#import "ProjectFormInfo.h"
static NSString *CELLIDENTIFY=@"FormAndMaterialCellIdentifier";

@interface FormSelectorViewController ()

@end

@implementation FormSelectorViewController

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
    
    UIView *titleBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    titleBar.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 150, 25)];
    [lblTitle setFont:[lblTitle.font fontWithSize:13]];
    lblTitle.text = @"请选择要打开的表单";
    lblTitle.textColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1];
    
    [titleBar addSubview:lblTitle];
    [self.view addSubview:titleBar];
    
	self.formsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-340)];
    [self.view addSubview:self.formsTableView];
    self.formsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.formsTableView.delegate = self;
    self.formsTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate formSelected:[indexPath row]];
}
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _formsList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FormAndMaterialCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY];
    if (nil==cell) {
        UINib *nib = [UINib nibWithNibName:@"FormAndMaterialCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CELLIDENTIFY];
        cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY];
    }
    NSUInteger row = [indexPath row];
    NSMutableDictionary *theFormInfo = [_formsList objectAtIndex:row];
    cell.fileName=[theFormInfo objectForKey:@"name"];
    return cell;
}

-(void)setFormsList:(NSMutableArray *)formsList{
    _formsList=formsList;
    [_formsTableView reloadData];
}
@end
