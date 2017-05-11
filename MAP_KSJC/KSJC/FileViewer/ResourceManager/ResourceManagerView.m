//
//  OnLineResource.m
//  zzzf
//
//  Created by mark on 13-11-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ResourceManagerView.h"
#import "ServiceProvider.h"
#import "FileItemThumbnailView.h"
#import "SysButton.h"
#import "Global.h"

@implementation ResourceManagerView

@synthesize path = _path,searchkey = _searchkey;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self onLoaded];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onLoaded];
    }
    return self;
}

-(void)onLoaded{
    //_addressStack = [[NSMutableArray alloc] initWithCapacity:10];
    //_addressItems = [[NSMutableArray alloc] initWithCapacity:10];
    _viewType = 2;
}

-(void)createOnlineAddressbar{
    if (nil==_onlineAddressBar) {
        _onlineAddressBar = [[ResourceManagerAddressBar alloc] initWithFrame:CGRectMake(0, 52, self.frame.size.width, 39)];
        _onlineAddressBar.rootPathName = @"在线目录";
        _onlineAddressBar.delegate = self;
        [self addSubview:_onlineAddressBar];
        [_onlineAddressBar go:@""];
    }
}

-(void)createLocalAddressbar{
    if (nil==_localAddressBar) {
        _localAddressBar = [[ResourceManagerAddressBar alloc] initWithFrame:CGRectMake(0, 52, self.frame.size.width, 39)];
        _localAddressBar.rootPathName = @"本地资源目录";
        _localAddressBar.delegate = self;
        [self addSubview:_localAddressBar];
        [_localAddressBar go:@""];
    }
}


-(void)load:(NSString *)path andFileName:(NSString *)fileName{
    //_intSearched=0;
    [self doLoad:path andKey:fileName];
    if (_isOnlineRsource) {
        [_onlineAddressBar go:self.path];
    }else{
        [_localAddressBar go:self.path];
    }
}

-(void)doLoad:(NSString *)path andKey:(NSString *)key{
    for(UIView *view in self.resourcesView.subviews)
    {
        [view removeFromSuperview];
    }
    
    self.path=path;
    self.searchkey = key;
    
    _rsView=[[FileListContainerView alloc] initWithFrame:CGRectMake(0, 0, self.resourcesView.frame.size.width, self.resourcesView.frame.size.height)];
    _rsView.resourceDelegate = self;
    _rsView.viewType = _viewType;
    _rsView.isFromLocal = !_isOnlineRsource;
    if (_isOnlineRsource) {
        [_rsView load:path andKey:key];
    }else{
        NSString *realPath = [[self.managerDelegate resouceManagerDirectory] stringByAppendingPathComponent:path];
        [_rsView load:realPath andKey:key];
    }
    
    _rsView.owner=self;
    //_rsView.viewType = _viewType;
    [self.resourcesView addSubview:_rsView];
}

-(void)addressBar:(ResourceManagerAddressBar *)bar didChange:(NSString *)path{
    [self doLoad:path andKey:@""];
}

- (IBAction)onBtnCloseTap:(id)sender {
    [self.managerDelegate resourceManagerShouldClose ];
}

- (IBAction)testDelete:(id)sender {
    [_rsView deleteResource];
}

- (IBAction)onBtnShowLocalResourceTap:(id)sender {
    if (_isOnlineRsource) {
        [self showLocalResource];
    }
}

- (IBAction)onBtnShowOnlineTap:(id)sender {
    if (!_isOnlineRsource) {
        [self showOnlineResource];
    }
}

- (IBAction)onBtnAdd:(id)sender {
    UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"新建文件夹" message:@"请输入文件夹名称" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"取消", nil];
    
    comfirm.alertViewStyle = UIAlertViewStylePlainTextInput;
    [comfirm textFieldAtIndex:0].text = [NSString stringWithFormat:@"新建文件夹"];

    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 60);
    [comfirm setTransform:myTransform];
    
    [comfirm show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        NSString *folderName = [alertView textFieldAtIndex:0].text;
        NSMutableArray *array=_rsView.dataSource;
        for (int i=0;i<array.count;i++) {
            FileModel *fModel=[array objectAtIndex:i];
            if ([fModel.fileName isEqualToString:folderName]) {
                [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(reComfirm) userInfo:nil repeats:NO];
                return;
            }
        }
        [_rsView addFolder:folderName];
    }
}

-(void)reComfirm{
    UIAlertView *comfirm = [[UIAlertView alloc] initWithTitle:@"添加文件夹" message:@"已存在的文件夹，请再次输入" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"取消", nil];
    
    comfirm.alertViewStyle = UIAlertViewStylePlainTextInput;
    [comfirm textFieldAtIndex:0].text = @"新建文件夹";
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0, 60);
    [comfirm setTransform:myTransform];
    [comfirm show];
}

- (IBAction)onBtnShowThumbnailsTap:(id)sender{
    [self showThumbnails];
}

- (IBAction)onBtnShowDetailTap:(id)sender{
    [self showDetails];
}

- (IBAction)onBtnRefreshTap:(id)sender {
    [_rsView refersh];
}

- (IBAction)onBtnDeleteTap:(id)sender {
    [_rsView editTableView];
}

-(void)showDetails{
    [_rsView showDetails];
    _viewType = 2;
    self.btnShowDetails.selected = YES;
    self.btnShowThumbnails.selected = NO;
}

-(void)showThumbnails{
    [_rsView showThumbnails];
    _viewType = 1;
    self.btnShowDetails.selected = NO;
    self.btnShowThumbnails.selected = YES;
}

-(void)showOnlineResource{
    [self createOnlineAddressbar];
    _isOnlineRsource=YES;
    _onlineAddressBar.hidden = NO;
    _localAddressBar.hidden = YES;
    _btnMyResource.selected = NO;
    _btnOnlineResource.selected = YES;
    self.lblTitle.text = @"在线资源";
    self.btnDelete.hidden = YES;
    self.btnAdd.hidden=YES;
    [self doLoad:[_onlineAddressBar currentPath] andKey:@""];
}

-(void)showLocalResource{
    [self createLocalAddressbar];
    _isOnlineRsource = NO;
    _onlineAddressBar.hidden = YES;
    _localAddressBar.hidden = NO;
    _btnMyResource.selected = YES;
    _btnOnlineResource.selected = NO;
    self.btnDelete.hidden = NO;
    self.btnAdd.hidden=NO;
    self.lblTitle.text = @"我的资源";
    [self doLoad:[_localAddressBar currentPath] andKey:@""];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *fileName = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    if (![fileName isEqualToString:@""]) {
        _intSearched=1;
    }else{
        _intSearched=0;
    }
    
    [self load:self.path andFileName:fileName];
    _isSearch=YES;

}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSString *fileName = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    if (![fileName isEqualToString:@""]) {
        _intSearched=1;
    }else{
        _intSearched=0;
    }
    if (_isSearch&&[fileName isEqualToString:@""]) {
        [self load:self.path andFileName:fileName];
        _isSearch=NO;
    }
}

//- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    NSString *fileName = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
//    if (![fileName isEqualToString:@""]) {
//        _intSearched=1;
//    }else{
//        _intSearched=0;
//    }
//    [self load:self.path andFileName:fileName];
//    
//}


+(ResourceManagerView *) createView{
    
    NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"ResourceManagerView" owner:nil options:nil];
    ResourceManagerView *theView= [nibView objectAtIndex:0];

    theView.seaBarFile.delegate=theView;
    theView.seaBarFile.backgroundColor = [UIColor whiteColor];
    theView.seaBarFile.clipsToBounds = NO;
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version<7) {
        [[theView.seaBarFile.subviews objectAtIndex:0] removeFromSuperview];
        for (UIView *subview in theView.seaBarFile.subviews) {
            if ([subview isKindOfClass:[UITextField class]]) {
                UITextField *searchFiled = (UITextField *) subview;
                searchFiled.borderStyle = UITextBorderStyleRoundedRect;
                searchFiled.layer.borderColor = [[UIColor whiteColor] CGColor];
                searchFiled.layer.borderWidth = 4.0f;
                searchFiled.layer.cornerRadius = 0.0f;
                break;
            }
        }
    }else{
        [theView.seaBarFile setBarTintColor:[UIColor whiteColor]];
    }
     
    theView.btnShowDetails.layer.cornerRadius = 3;
    theView.btnShowThumbnails.layer.cornerRadius = 3;
    theView.btnMyResource.layer.cornerRadius = 4;
    theView.btnOnlineResource.layer.cornerRadius = 4;
    return theView;
}
#pragma -mark ----------最新方法 (没有)在此处添加 uploaded 字段  此处须过滤文件夹
-(void)allResource:(NSArray *)resources atIndex:(int)index
{
    NSDictionary *itemDic=[resources objectAtIndex:index];
    NSString *type=[itemDic objectForKey:@"ext"];
    NSString *name=[itemDic objectForKey:@"name"];
    NSString *path=[itemDic objectForKey:@"path"];
    
    if([type isEqualToString:@""]){
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
        [self.resourcesView.layer addAnimation:transition forKey:nil];
        //view之间的切换
        [self.resourcesView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
        
        NSString *path=[self.path stringByAppendingFormat:@"//%@", name];
        [self load:path andFileName:@""];
        
    }else{
        if (_isOnlineRsource) {
            //[self.fileDelegate allFiles:files nowOpenFile:name path:p ext:extension isLocalFile:NO];
            //[self.fileDelegate openFile:name path:p ext:extension isLocalFile:NO];
            NSArray *array=[self subtractFolder:resources];
            static int newIndex;
            for (int i=0; i<array.count; i++) {
                NSDictionary *dic=[array objectAtIndex:i];
                if ([dic isEqualToDictionary:itemDic]) {
                    newIndex=i;
                    break;
                }
            }
            [self.fileDelegate allFiles:array at:newIndex];
        }else{
            NSString *p=@"";
            if ([path isEqualToString:@""]) {
                p = [NSString stringWithFormat:@"%@/%@/%@",[self.managerDelegate  resouceManagerDirectory],self.path,name];
            }else{
                p=path;
            }
            NSArray *array=[self subtractFolder:resources];
           static int newIndex;
            for (int i=0; i<array.count; i++) {
                NSDictionary *dic=[array objectAtIndex:i];
                if ([dic isEqualToDictionary:itemDic]) {
                    newIndex=i;
                    break;
                }
            }
            [self.fileDelegate allFiles:array at:newIndex];
        }
    }

}
//除去文件夹信息
-(NSArray *)subtractFolder:(NSArray *)allFields
{
    NSMutableArray *muArray=[NSMutableArray array];
    for (int i=0; i<allFields.count; i++) {
        NSDictionary *dic=[allFields objectAtIndex:i];
        if ([dic objectForKey:@"ext"]!=nil&&![[dic objectForKey:@"ext"]isEqualToString:@""]) {
            [muArray addObject:dic];
        }
    }
    return muArray;
}
/*-(void)allFiles:(NSArray *)files currentFileDidTap:(NSString *)name type:(NSString *)type path:(NSString *)path{
    if([type isEqualToString:@""]){
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
        [self.resourcesView.layer addAnimation:transition forKey:nil];
        //view之间的切换
        [self.resourcesView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
        
        NSString *path=[self.path stringByAppendingFormat:@"//%@", name];
        [self load:path andFileName:@""];
        
    }else{
        if (_isOnlineRsource) {
            NSString *filePath=self.path;
            if (_intSearched==1) {
                filePath=[path stringByAppendingString:filePath];
            }
            
            NSString *p=[NSString stringWithFormat:@"%@?type=download&path=%@",[Global serviceUrl],[filePath stringByAppendingFormat:@"//%@", name]];
            NSString * fruits = name;
            NSArray  * array= [fruits componentsSeparatedByString:@"."];
            NSString *extension=array.lastObject;
            [self.fileDelegate allFiles:files nowOpenFile:name path:p ext:extension isLocalFile:NO];
            //[self.fileDelegate openFile:name path:p ext:extension isLocalFile:NO];
        }else{
            NSString *p=@"";
            if ([path isEqualToString:@""]) {
                p = [NSString stringWithFormat:@"%@/%@/%@",[self.managerDelegate  resouceManagerDirectory],self.path,name];
            }else{
                p=path;
            }
            [self.fileDelegate allFiles:files nowOpenFile:name path:p ext:[name pathExtension] isLocalFile:YES];
            //[self.fileDelegate openFile:name path:p ext:[name pathExtension] isLocalFile:YES];
        }
    }
}*/

-(void)setCloseButtonVisible:(BOOL)visible{
    
    if (visible) {
        self.btnMyResource.frame = CGRectMake(60, 11, 48, 32);
        self.btnOnlineResource.frame = CGRectMake(120, 11, 48, 32);
    }else{
        self.btnMyResource.frame = CGRectMake(13, 11, 48, 32);
        self.btnOnlineResource.frame = CGRectMake(83, 11, 48, 32);
    }
    self.btnClose.hidden=!visible;
}

@end
