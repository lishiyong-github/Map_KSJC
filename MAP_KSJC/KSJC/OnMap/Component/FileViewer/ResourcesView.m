//
//  ResourcesView.m
//  zzzf
//
//  Created by mark on 13-11-27.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ResourcesView.h"
#import "ServiceProvider.h"
#import "ResourcesFileView.h"
#import "FileCustomCell.h"
#import "FileModel.h"
#import "OnLineResourceView.h"

@implementation ResourcesView
@synthesize fileDic,fileModels,view1,view2,tableViewFile;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)load:(NSString *)path andFileName:(NSString *)fileName{
    fileModels=[[NSMutableArray alloc] init];
    ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
    NSString *type=@"resource";
    NSMutableDictionary *mutableDic=[NSMutableDictionary dictionaryWithCapacity:1];
    if ([fileName isEqualToString:@""]) {
        [mutableDic setObject:@"getFiles" forKey:@"action"];
    }else{
        [mutableDic setObject:@"searchFiles" forKey:@"action"];
    }
    [mutableDic setObject:path forKey:@"pathName"];
    [mutableDic setObject:fileName forKey:@"fileName"];
    [sp getData:type parameters:mutableDic];
}

-(void)openFile:(NSString *)path{
    ServiceProvider *sp=[ServiceProvider initWithDelegate:self];
    NSString *type=@"resource";
    NSMutableDictionary *mutableDic=[NSMutableDictionary dictionaryWithCapacity:1];
    [mutableDic setObject:@"openFile" forKey:@"action"];
    [mutableDic setObject:path forKey:@"pathName"];
    [sp getData:type parameters:mutableDic];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
//    BOOL nibsRegistered = NO;
//    if (!nibsRegistered) {
//        UINib *nib = [UINib nibWithNibName:@"FyxCustomCell" bundle:nil];
//        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
//        nibsRegistered = YES;
//    }
//    FyxCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
//    NSUInteger row = [indexPath row];
//    fyxModel *fyxModel=[self.wfajModels objectAtIndex:row];
//    cell.company =[fyxModel company];
//    cell.projectName =[fyxModel projectName];
//    cell.dateTime =[[fyxModel dateCreate] description];
//    return cell;
    
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"FileCustomCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
    }
    FileCustomCell *cell=[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    NSUInteger row=[indexPath row];
    FileModel *fModel=[fileModels objectAtIndex:row];
    cell.strImgFileName=[fModel fileType];
    cell.FileName=[fModel fileName];
    cell.FileLength=[fModel fileLength];
    cell.FileDate=[fModel fileDate];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return [self.fileModels count];
 
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [indexPath row];
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if ([indexPath row] % 2 == 0) {
    //        cell.backgroundColor = [UIColor blueColor];
    //    } else {
    //        cell.backgroundColor = [UIColor greenColor];
    //    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row=[indexPath row];
    FileModel *fModel=[fileModels objectAtIndex:row];
    if (![fModel.imgFile isEqualToString:@"directory"])
        return;
    
    CATransition* transition = [CATransition animation];
    //只执行0.5-0.6之间的动画部分
    //    transition.startProgress = 0.5;
    //    transition.endProgress = 0.6;
    //动画持续时间
    transition.duration = 0.5;
    //进出减缓
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    //动画效果
    transition.type = @"suckUnEffect";
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.owner.resourcesView.layer addAnimation:transition forKey:nil];
    //view之间的切换
    [self.owner.resourcesView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    
    
    NSLog(@"%@",fModel.fileName);
    
    NSString *path=[self.owner.path stringByAppendingFormat:@"//%@", fModel.fileName];
    [self.owner load:path andFileName:@""];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (void)buttonClick{
    CATransition* transition = [CATransition animation];
    //只执行0.5-0.6之间的动画部分
//        transition.startProgress = 0.1;
//        transition.endProgress = 0.2;
    //动画持续时间
    transition.duration = 0.5;
    //进出减缓
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    //动画效果
    transition.type = @"pageCurl";
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.layer addAnimation:transition forKey:nil];
    //view之间的切换
    [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
}

-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveStringData:(NSString *)data{
    NSLog(@"0");
}
-(void) serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    fileDic=data;
    double xNum=0,yNum=0,xSize=150,ySize=140;
    int i=0;
    ResourcesFileView  *resView=nil;
    FileModel *fModel=nil;
    view1=[[UIScrollView alloc]  initWithFrame:CGRectMake(40, 0, self.bounds.size.width-40, self.bounds.size.height)];
    //view1.backgroundColor=[UIColor blueColor];
    if ([data objectForKey:@"sucess"]) {
        NSArray *rs=[data objectForKey:@"result"];
        for (NSDictionary *item in rs) {
            xNum=i%7;
            yNum=i/7;
            resView=[[ResourcesFileView alloc] initWithFrame:CGRectMake(xNum*xSize, yNum*ySize, 250, 250)];
            resView.owner = self;
            [resView load:[item objectForKey:@"name"] andType:[item objectForKey:@"extension"]];
            //[self addSubview:resView];
            [view1 addSubview:resView];
            i++;
            
            fModel=[[FileModel alloc] initWithFile:[item objectForKey:@"type"] fileName:[item objectForKey:@"name"] fileLength:[item objectForKey:@"length"] fileDate:[item objectForKey:@"creationTime"] fileType:[item objectForKey:@"extension"]];
        
            [fileModels addObject:fModel];
        }
    }
    view1.contentSize=CGSizeMake(480, (yNum+1)*ySize);
    //self.contentSize=CGSizeMake(480, (yNum+1)*ySize);
    
    self.tableViewFile=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.tableViewFile.dataSource=self;
    self.tableViewFile.delegate=self;
    [self addSubview:self.tableViewFile];
    [self addSubview:view1];

    //tableViewFile.hidden=self.owner.intStyle==0?true:false;
    //view1.hidden=self.owner.intStyle==0?false:true;
    if (self.viewType==1) {
        [self showThumbnails];
    }else{
        [self showDetails];
    }
}
-(void) serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    NSLog(@"2");
}

-(void)showDetails{
    self.view1.hidden=true;
    self.tableViewFile.hidden=false;
    self.viewType = 2;
}

-(void)showThumbnails{
    self.view1.hidden=false;
    self.tableViewFile.hidden=true;
    self.viewType = 1;
}

@end
