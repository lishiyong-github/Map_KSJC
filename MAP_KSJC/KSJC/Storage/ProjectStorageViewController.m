//
//  ProjectStorageViewController.m
//  zzzf
//
//  Created by mark on 14-2-18.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "ProjectStorageViewController.h"
#import "ProjectStorageCell.h"

@interface ProjectStorageViewController ()

@end

@implementation ProjectStorageViewController

static BOOL nibsRegistered = NO;

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
    [self.tableView setEditing:YES animated:YES];
    self.deleteDic=[[NSMutableDictionary alloc] init];
    _type=@"Fyx";
    [self showFyxList];
    _searchKeys = [NSArray arrayWithObjects:@"fyx",@"phgz",@"wf", nil];
    self.btnFyx.layer.cornerRadius = 8;
    self.btnPhxm.layer.cornerRadius = 8;
    self.btnWfxm.layer.cornerRadius = 8;
    _userProjectPath=[Global currentUser].userProjectPath;
//    self.dataSource=[NSMutableArray arrayWithContentsOfFile:[_userProjectPath stringByAppendingPathComponent:@"projectList.plist"]];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self loadStorageData:_type];
}

-(void)loadStorageData:(NSString *)type{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    self.dataSource=[[NSMutableArray alloc] init];
    array=[NSMutableArray arrayWithContentsOfFile:[_userProjectPath stringByAppendingPathComponent:@"projectList.plist"]];
    for (int i=0; i<array.count; i++) {
        NSMutableDictionary *dic=[array objectAtIndex:i];
        if ([[dic objectForKey:@"type"] isEqualToString:type]) {
            [self.dataSource addObject:dic];
        }
    }
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CustomCellIdentifier = @"ProjectStorageCellIdentifier";
    
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"ProjectStorageCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
    }
    
    ProjectStorageCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    
    NSUInteger row = [indexPath row];
    NSMutableDictionary *projectStorageDic=[self.dataSource objectAtIndex:row];
    //ProjectInfo *project=[self.dataSource objectAtIndex:row];
    //cell.project = project;
    cell.lblCompany.text=[projectStorageDic objectForKey:@"address"];
    cell.lblProjectName.text=[projectStorageDic objectForKey:@"name"];
    cell.lblProjectSize.text=[projectStorageDic objectForKey:@"size"];
    cell.lblDateTime.text=[projectStorageDic objectForKey:@"time"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.deleteDic setObject:indexPath forKey:[self.dataSource objectAtIndex:indexPath.row]];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataSource removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.deleteDic removeObjectForKey:[self.dataSource objectAtIndex:indexPath.row]];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (IBAction)onBtnGoBackTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onBtnEdit:(id)sender {
    [self.tableView setEditing:YES animated:YES];
}

- (IBAction)onBtnConfirm:(id)sender {
    [self.tableView setEditing:NO animated:YES];
}

- (IBAction)onBtnDelete:(id)sender {
    if (self.deleteDic.count==0) {
        UIAlertView *alert1=[[UIAlertView alloc] initWithTitle:@"提示" message:@"未选中项目" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alert1.tag=1;
        [alert1 show];
    }else{
        UIAlertView *alert2=[[UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alert2.tag=2;
        [alert2 show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2) {
        if (buttonIndex==0) {
            [self deleteData];
        }
    }
}

-(void)deleteData{
    NSLog(@"sc");
    NSFileManager *fm=[NSFileManager defaultManager];
    NSArray *deleteArray=[self.deleteDic allKeys];
    [self.dataSource removeObjectsInArray:deleteArray];
    NSMutableArray *arr=[NSMutableArray arrayWithContentsOfFile:[_userProjectPath stringByAppendingPathComponent:@"projectList.plist"]];
    [arr removeObjectsInArray:deleteArray];
    [arr writeToFile:[_userProjectPath stringByAppendingPathComponent:@"projectList.plist"] atomically:YES];
    NSMutableArray *arr2=[NSMutableArray arrayWithContentsOfFile:[_userProjectPath stringByAppendingPathComponent:@"projectList.plist"]];
    NSLog(@"%@",arr2);
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithArray:[self.deleteDic allValues]] withRowAnimation:UITableViewRowAnimationFade];
    for (int i=0; i<deleteArray.count; i++) {
        NSString *projectId=[[deleteArray objectAtIndex:i] objectForKey:@"id"];
        [fm removeItemAtPath:[_userProjectPath stringByAppendingPathComponent:projectId] error:nil];
    }
    
    [self.deleteDic removeAllObjects];
}

- (IBAction)onBtnBuniessTap:(id)sender {
    self.deleteDic=[[NSMutableDictionary alloc] init];
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }
    if (btn.tag==0) {
        [self showFyxList];
        _type=@"Fyx";
        [self loadStorageData:_type];
    }else if(btn.tag==1){
        [self showPhxmList];
        _type=@"Phxm";
        [self loadStorageData:_type];
    }else if(btn.tag==2){
        [self showWfxmList];
        _type=@"Wfxm";
        [self loadStorageData:_type];
    }
}

-(void)showFyxList{
    self.btnFyx.selected = YES;
    self.btnPhxm.selected = self.btnWfxm.selected = NO;
}

-(void)showPhxmList{
    self.btnPhxm.selected = YES;
    self.btnFyx.selected = self.btnWfxm.selected = NO;
}

-(void)showWfxmList{
    self.btnWfxm.selected = YES;
    self.btnFyx.selected = self.btnPhxm.selected = NO;
}

@end
