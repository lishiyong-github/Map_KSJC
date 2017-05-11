//
//  MaterialSelectorViewController.m
//  zzzf
//
//  Created by dist on 13-12-9.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "MaterialSelectorViewController.h"
#import "FormAndMaterialCell.h"
//#import "MaterialInfo.h"

static NSString *CELLIDENTIFY=@"FormAndMaterialCellIdentifier";

@interface MaterialSelectorViewController ()

@end

@implementation MaterialSelectorViewController

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
	// Do any additional setup after loading the view.
    
    self.materialTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.materialTableView];
    self.materialTableView.delegate = self;
    self.materialTableView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FormAndMaterialCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY];
    if (nil==cell) {
        UINib *nib = [UINib nibWithNibName:@"FormAndMaterialCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CELLIDENTIFY];
        cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY];
        
    }
    NSUInteger row = [indexPath row];
    NSDictionary *fileInfo = [self.files objectAtIndex:row];
    cell.fileName = [fileInfo objectForKey:@"name"];
    //cell.fileName = @"df";
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",indexPath);
    NSUInteger row = [indexPath row];
    NSDictionary *fileInfo = [self.files objectAtIndex:row];
    
    //        savePath=@"/private/var/mobile/Applications/069853DA-FD23-48F7-9B4B-0D4D4233E984/tmp/124.xlsx";
    [self.delegate materialSelected:_projectId fileId:[fileInfo objectForKey:@"id"] extension:[fileInfo objectForKey:@"ext"] fileName:[fileInfo objectForKey:@"name"]];
    //[self.supView.controller];
     //[self.controller showFile:g.name path:materialDownPath ext:@"jpg"];
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.files.count;
}

-(void)setFiles:(NSMutableArray *)files{
    _files = files;
    [self.materialTableView reloadData];
}



@end
