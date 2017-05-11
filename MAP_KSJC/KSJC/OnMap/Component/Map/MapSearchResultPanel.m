//
//  MapSearchResultPanel.m
//  zzzf
//
//  Created by zhangliang on 14-4-16.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapSearchResultPanel.h"
#import "MapSearchResultCellTableViewCell.h"
#import "Global.h"

@implementation MapSearchResultPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createSubView];
    }
    return self;
}


-(void)createSubView{
    _waitView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _waitView.color = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1];
    _waitView.frame = CGRectMake(self.frame.size.width/2-16, 14, 32, 32);
    _waitView.hidden = YES;
    
    _lblNoData = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2-30, 14, 60, 32)];
    _lblNoData.font = [_lblNoData.font fontWithSize:13];
    _lblNoData.text = @"没有数据";
    _lblNoData.hidden = YES;
    
    _btnShowDataList = [SysButton buttonWithType:UIButtonTypeCustom];
    [_btnShowDataList setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    [_btnShowDataList setTitle:@"显示数据列表" forState:UIControlStateNormal];
    _btnShowDataList.titleLabel.font = [_btnShowDataList.titleLabel.font fontWithSize:13];
    _btnShowDataList.frame = CGRectMake(0,0,self.frame.size.width,50);
    _btnShowDataList.hidden = YES;
    [_btnShowDataList addTarget:self action:@selector(backToListOrDetail) forControlEvents:UIControlEventTouchUpInside];
    
    _pageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _page1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _page2 = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    
    _listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    _listTable.tableFooterView = ;
    _listTable.delegate = self;
    _listTable.dataSource = self;
    
    [_pageView addSubview:_page1];
    [_pageView addSubview:_page2];
    [_page1 addSubview:_listTable];
    
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:_pageView];
    [self addSubview:_waitView];
    [self addSubview:_lblNoData];
    [self addSubview:_btnShowDataList];
    
    _lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, self.frame.size.width-70, 20)];
    _lblSubInfo = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, self.frame.size.width-70, 20)];
    
    _lblName.font = [_lblName.font fontWithSize:16];
    _lblSubInfo.font = [_lblSubInfo.font fontWithSize:13];
    
    _btnStopworkForm = [SysButton buttonWithType:UIButtonTypeCustom];
    [_btnStopworkForm setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    _btnStopworkForm.titleLabel.font = [_btnStopworkForm.titleLabel.font fontWithSize:12];
    _btnStopworkForm.backgroundColor = [UIColor whiteColor];
    _btnStopworkForm.defaultBackground = _btnStopworkForm.backgroundColor;
    _btnStopworkForm.layer.cornerRadius = 3;
    //_btnStopworkForm.enabled = NO;
    
    _btnStopworkForm.frame = CGRectMake(self.frame.size.width-80, 12, 70, 25);
    //[_btnStopworkForm addTarget:self action:@selector(onBtnStopworkformTap) forControlEvents:UIControlEventTouchUpInside];
    
    _btnShowDataListForDetail = [SysButton buttonWithType:UIButtonTypeCustom];
    [_btnShowDataListForDetail setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    _btnShowDataListForDetail.titleLabel.font = [_btnShowDataListForDetail.titleLabel.font fontWithSize:12];
    
    _btnShowDataListForDetail.frame = CGRectMake(0, 80, self.frame.size.width, 38);
    _btnShowDataListForDetail.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    _btnShowDataListForDetail.defaultBackground = _btnShowDataListForDetail.backgroundColor;
    [_btnShowDataListForDetail setTitle:@"显示列表" forState:UIControlStateNormal];
    [_btnShowDataListForDetail addTarget:self action:@selector(onBtnShowListTouchup) forControlEvents:UIControlEventTouchUpInside];
    
    _btnDetail = [SysButton buttonWithType:UIButtonTypeCustom];
    [_btnDetail setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    [_btnDetail setTitle:@"详情" forState:UIControlStateNormal];
    _btnDetail.titleLabel.font = [_btnStopworkForm.titleLabel.font fontWithSize:12];
    _btnDetail.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    _btnDetail.defaultBackground = _btnDetail.backgroundColor;
    _btnDetail.layer.cornerRadius = 3;
    _btnDetail.frame = CGRectMake(self.frame.size.width-80, 30, 70, 25);
    [_btnDetail addTarget:self action:@selector(onBtnDetailTap) forControlEvents:UIControlEventTouchUpInside];
    
    _photoView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, self.frame.size.width, 100)];
    _photoView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
    
    [_page2 addSubview:_lblName];
    [_page2 addSubview:_lblSubInfo];
    [_page2 addSubview:_btnStopworkForm];
    [_page2 addSubview:_btnDetail];
//    [_page2 addSubview:_photoView];
    [_page2 addSubview:_btnShowDataListForDetail];
    
    //self.clipsToBounds = YES;
    _pageView.clipsToBounds = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:.5].CGColor;
    
    _phFilterControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"全部阶段",@"基础", @"转换", @"标准", @"封顶", @"外立面", nil]];
    //_phFilterControl = [[SEFilterControl alloc]initWithFrame:CGRectMake(0, 182, self.frame.size.width, 80) Titles:[NSArray arrayWithObjects:@"基础", @"转换", @"标准", @"封顶", @"外立面", nil]];
    _phFilterControl.frame = CGRectMake(0, 182, self.frame.size.width, 30);
    [_phFilterControl addTarget:self action:@selector(phSegmentedValueChanged:) forControlEvents:UIControlEventValueChanged];
    _phFilterControl.hidden = YES;
    
//    [_page2 addSubview:_phFilterControl];
}

#pragma mark -------------UITableViewDelegate

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CustomCellIdentifier = @"MapSearchResultCellTableCellIdentifier";
    
    MapSearchResultCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (nil==cell) {
        UINib *nib = [UINib nibWithNibName:@"MapSearchResultCellTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    NSMutableDictionary *dataItem = [self.dataSource objectAtIndex:indexPath.row];
    
    if (self.dataType==0) {
//        cell.title = [NSString stringWithFormat:@"%@(%@)    %@",[dataItem objectForKey:@"orgname"],[dataItem objectForKey:@"user"],[dataItem objectForKey:@"start"]];
        cell.title = [NSString stringWithFormat:@"%@(%@)    %@",[dataItem objectForKey:@"xmmc"],[dataItem objectForKey:@"jcry"],[dataItem objectForKey:@"jcsj"]];
    }
//    else if(self.dataType==4){
//        NSString *projectTypeName;
//        NSString *t = [dataItem objectForKey:@"type"];
//        NSString *projectType =[dataItem objectForKey:@"projecttype"];
//        if ([t isEqualToString:@"project"]) {
//            if ([projectType isEqualToString:@"1"]) {
//                projectTypeName = @"【放验线】";
//            }
//            else if ([projectType isEqualToString:@"2"]) {
//                projectTypeName = @"【批后管理】";
//            }
//            else if ([projectType isEqualToString:@"3"]) {
//                projectTypeName = @"【违法案件】";
//            }
//            else if ([projectType isEqualToString:@"4"]) {
//                projectTypeName = @"【停工单】";
//            }
//            cell.title=[NSString stringWithFormat:@"%@%@",projectTypeName,[dataItem objectForKey:@"name"]];
//        }
//        else{
//            projectTypeName =@"【日常巡查】";
//            cell.title = cell.title = [NSString stringWithFormat:@"%@%@(%@)    %@",projectTypeName,[dataItem objectForKey:@"orgname"],[dataItem objectForKey:@"user"],[dataItem objectForKey:@"start"]];
//        }
//        
//        
//    }
    else{
        cell.title=[NSString stringWithFormat:@"%@(项目编号: %@)",[dataItem objectForKey:@"totalProjectName"],[dataItem objectForKey:@"xmbh"]];
//        [dataItem objectForKey:@"totalProjectName"];
    }
    return cell;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!_open)
    {
    return self.dataSource==nil?0:self.dataSource.count;
    }else
    {
        return 0;
    
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];

//    //如果是停工单，则需要从数据中判断是否是日常巡查
//    if (self.dataType==4) {
//        NSMutableDictionary *dataItem = [self.dataSource objectAtIndex:indexPath.row];
//        if ([[dataItem objectForKey:@"type"] isEqualToString:@"dailyjob"]) {
//            _relayDataType = 0;
//        }else{
//            _relayDataType = [[dataItem objectForKey:@"projecttype"] intValue];
//        }
//    }
    
   //点击某行cell  photoCode为nil(设置cell详情的相关内容//;label的名字和个数,photosscrollview)
    [self showDataAt:indexPath.row photoCode:nil];

    NSMutableDictionary *dataItem = [self.dataSource objectAtIndex:row];
    NSString *keyId = [dataItem objectForKey:@"id"];
    
    if (_relayDataType==0) {
//        self.layerFilter  为当前数据的code值
        [self.delegate filterRCXCLayer:self.layerFilter];
    }
    //过滤(显示当前)点
    [self.delegate filterPoint:[NSString stringWithFormat:@"%d",row]];
    [self.delegate hideMapViewCallout];
    [self.delegate zoomPoint:keyId];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] init];
    headView.tag = section;
    headView.backgroundColor = GRAYCOLOR_LIGHT;
    
    UIView *backV = [[UIView alloc] init];
    backV.backgroundColor = [UIColor whiteColor];
    backV.frame = CGRectMake(0, 0,_listTable.frame.size.width, 45);
    backV.tag = section+500;
    [headView addSubview:backV];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-100)*0.5, 0,100, 45)];
    lab.font = [UIFont systemFontOfSize:16];
    [lab setTextColor:BLUECOLOR];
    

    if(!_open)
    {
        lab.text = @"隐藏搜索列表";
    }
    else
    {
    lab.text = @"显示搜索列表";
    
    }
    [headView addSubview:lab];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOrCloseHeader)];
    [headView addGestureRecognizer:tap];
    return headView;

}

- (void)openOrCloseHeader
{

    _open = !_open;
    CGRect rect=_listTable.frame;

    if(_open)
    {
    
        _page1.frame = CGRectMake(0, 0, self.frame.size.width, 45);
        _pageView.frame = CGRectMake(0, 0, self.frame.size.width, 45);
        _listTable.frame = CGRectMake(0, 0, self.frame.size.width, 45);
        self.frame = CGRectMake(265, 15, 484, 45);

    }
    else
    {
        [self  showListPanel];
    
    }
    [_listTable reloadData];

}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 45;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;

}

//设置cell详情标签名称和数据
-(void)setLabelText{
    if (_relayDataType==0) {
        _lblName.text = [_currentData objectForKey:@"jcry"];
        _lblSubInfo.text = [NSString stringWithFormat:@"巡查时间: %@",[_currentData objectForKey:@"jcsj"]];
    }else{
        _lblName.text = [_currentData objectForKey:@"totalProjectName"];
        _lblSubInfo.text = [_currentData objectForKey:@"address"];
    }
//    NSArray *stopworkforms = [_currentData objectForKey:@"stopworkforms"];
//    _btnStopworkForm.hidden = stopworkforms.count==0;
//    [_btnStopworkForm setTitle:[NSString stringWithFormat:@"停工单(%d)",stopworkforms.count] forState:UIControlStateNormal];
}

-(void)setPhFlowInfo{
    NSArray *flows = [_currentData objectForKey:@"flows"];
    for(int i=1;i<6;i++){
        [_phFilterControl setEnabled:NO forSegmentAtIndex:i];
    }
    for (NSString *f in flows) {
        [_phFilterControl setEnabled:YES forSegmentAtIndex:[f intValue]+1];
    }
}

//如果为点击地图图标时,code有值即defaultSelectedCode有值
-(void)createThumbPhoto:(NSString *)defaultSelectedCode{
    //照片view之间的间隔
    int photoGap = 10;
    //照片的宽高
    int photoWidth = 80;
    int photoHeight = 80;
    _currentPhotoView = nil;
    //照片个数
    int subViewCount = _photoView.subviews.count;
    for (int i=subViewCount-1; i>=0; i--) {
        [[[_photoView subviews] objectAtIndex:i] removeFromSuperview];
    }
    int j=0;
    //取出当前数据的照片数组
    NSArray *photos = [_currentData objectForKey:@"photos"];
    //遍历照片数组
    for (int i=0; i<photos.count; i++) {
        NSDictionary *d = [photos objectAtIndex:i];
        if (_relayDataType==2 && _phFlowState!=-1) {
            int phFlow = [[d objectForKey:@"flow"] intValue];
            if (phFlow != _phFlowState) {
                continue;
            }
        }
        //创建小照片的view
        JobPhotoView *photoItem = [[JobPhotoView alloc] initWithFrame:CGRectMake(photoGap+j*(photoWidth+photoGap), 10, photoWidth, photoHeight)];
        j++;
        photoItem.delegate = self;
        photoItem.photoName = [d objectForKey:@"name"];
        photoItem.photoCode = [d objectForKey:@"code"];
        if (_relayDataType==0) {
            //缩略图
            photoItem.photoUrl = [NSString stringWithFormat:@"%@?type=zf&action=getphoto&code=%@&thumbnail=yes",[Global serviceUrl],[d objectForKey:@"code"]];
            //全路径
            photoItem.fullsizePhotoPath = [NSString stringWithFormat:@"%@?type=zf&action=getphoto&code=%@",[Global serviceUrl],[d objectForKey:@"code"]];
        }else {
            photoItem.photoUrl = [NSString stringWithFormat:@"%@?type=zf&action=getphoto&business=project&code=%@&thumbnail=yes",[Global serviceUrl],[d objectForKey:@"code"]];
            photoItem.fullsizePhotoPath = [NSString stringWithFormat:@"%@?type=zf&action=getphoto&business=project&code=%@",[Global serviceUrl],[d objectForKey:@"code"]];
        }
        //点击地图图标,defaultSelectedCode有值,并且当defaultSelectedCode和当前照片数组中的照片code一样时,设置为选中
        if (nil!=defaultSelectedCode && [photoItem.photoCode isEqualToString:defaultSelectedCode]) {
            photoItem.selected=YES;
            _currentPhotoView = photoItem;
        }
        [_photoView addSubview:photoItem];
    }
    _photoView.contentSize = CGSizeMake(_photoView.subviews.count*(photoWidth+photoGap)+photoGap, _photoView.frame.size.height);
}

//设置数据
-(void)setDataSource:(NSArray *)dataSource{
    _open = NO;
    _dataSource = dataSource;
    _relayDataType = self.dataType;
    //没有数据
    if (nil==dataSource || dataSource.count==0) {
        _waitView.hidden = YES;
        [_waitView stopAnimating];
        //显示没有数据
        _lblNoData.hidden = NO;
    }else{
         [_listTable reloadData];
        [self showListPanel];
    }
}


//转菊花
-(void)wait{
    
    if (self.hidden) {
        self.hidden = NO;
        self.alpha = 0;
    }
    _lblNoData.hidden = YES;
    _waitView.hidden = NO;
    //转菊花
    [_waitView startAnimating];
    _waitView.alpha = 0;
    //隐藏显示详情按钮
    _btnShowDataList.hidden = YES;
    _btnShowDataList.alpha = 0;
    _pageView.hidden = YES;
    CGRect nextFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 60);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.frame = nextFrame;
        self.alpha = 1;
        _waitView.alpha = 1;
    } completion:^(BOOL finshed){
        [_waitView startAnimating];
    }];
}

-(void)close{
    if (self.hidden || nil==self.dataSource || self.dataSource.count==0) {
        return;
    }
    _pageView.hidden = YES;
    _lblNoData.hidden = YES;
    _waitView.hidden = YES;
    [_waitView stopAnimating];
    _btnShowDataList.hidden = NO;
    //_btnShowDataList.alpha = 0;
    CGRect nextFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 50);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.frame = nextFrame;
        _btnShowDataList.alpha = 1;
    } completion:^(BOOL finshed){
        
    }];
}

//显示数据列表(按钮点击方法)
-(void)backToListOrDetail{
    if (_isBackToList) {
        [self showListPanel];
    }else{
        [self showDetailPanel];
    }
}



//点击显示列表按钮
-(void)onBtnShowListTouchup{
    if (_relayDataType == 0 && self.dataType == 0) {
        [self.delegate filterRCXCLayer:@""];
    }
    else{
        [self.delegate filterRCXCLayer:@"null"];
    }
    //滤除图形图层(添加回已经删除的图形图层)
    [self.delegate filterPoint:@""];
    //显示列表
    [self showListPanel];
    [self.delegate zoomFullMap];
}
//显示tableview列表page1
-(void)showListPanel{
    _pageView.alpha = 0;
    _pageView.hidden = NO;
    int c = self.dataSource.count;
    //如果数据量超过10 ,设置tableview的高度仍为10个数据量
    if (c>10) {
        c=10;
    }
    CGRect nextFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, c*44+45);
    _page1.frame = CGRectMake(0, 0, self.frame.size.width, nextFrame.size.height);
    _pageView.frame = CGRectMake(0, 0, self.frame.size.width, nextFrame.size.height);
    _listTable.frame = CGRectMake(0, 0, self.frame.size.width, nextFrame.size.height);
    _page1.hidden = NO;
    _page2.hidden = YES;
    //显示详情按钮(隐藏)
    _btnShowDataList.hidden = YES;
    _btnShowDataList.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        _waitView.alpha = 0;
        _pageView.alpha = 1;
        _page1.alpha = 1;
        self.frame = nextFrame;
    } completion:^(BOOL finshed){
        _waitView.hidden = NO;
        [_waitView startAnimating];
    }];
    //已经返回到list列表
    _isBackToList = YES;
}


//点击cell后显示详情
-(void)showDetailPanel{
    int h = 120;
//    if (_relayDataType == 2) {
//        h = 253;
//        _phFilterControl.hidden = NO;
//        _btnShowDataListForDetail.frame = CGRectMake(0, 214, self.frame.size.width, 38);
//        _pageView.frame = CGRectMake(0, 0, self.frame.size.width, 252);
//        _page2.frame = CGRectMake(0, 0, self.frame.size.width, 252);
//    }else{
        _phFilterControl.hidden = YES;
        //显示列表
        _btnShowDataListForDetail.frame = CGRectMake(0, 80, self.frame.size.width, 38);
        _pageView.frame = CGRectMake(0, 0, self.frame.size.width, 120);
  
        _page2.frame = CGRectMake(0, 0, self.frame.size.width, 120);
   
//    }
    CGRect nextFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
    
    _btnShowDataList.hidden = YES;
    if (_page2.hidden || self.frame.size.height==50) {
        _page2.alpha = 0;
        _page2.hidden = NO;
    }
    if (_pageView.hidden) {
        _pageView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.frame = nextFrame;
        _page1.alpha = 0;
    } completion:^(BOOL finshed){
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            _page2.alpha = 1;
        } completion:nil];
    }];
    //不返回到列表
    _isBackToList = NO;
}


#pragma mark --------------jobPhoto
//点击照片
-(void)jobPhotoTap:(JobPhotoView *)photoView{
    if (nil!=_currentPhotoView) {
        _currentPhotoView.selected = NO;
    }
    _currentPhotoView=photoView;
    photoView.selected = YES;
    [self.delegate mapSearchPanel:self openPhoto:photoView.photoName url:photoView.fullsizePhotoPath ext:@"jpg"];
    
}
//双击照片
-(void)jobPhotoDoubleTap:(JobPhotoView *)photoView{
    [self.delegate mapSearchPanel:self openPhoto:photoView.photoName url:photoView.fullsizePhotoPath ext:@"jpg"];
}

//点击详情按钮
-(void)onBtnDetailTap{
    //是否是日常巡查
    if (_relayDataType==0) {
        [self.delegate mapSearchPanel:self openJobDaily:_currentData showStopworkform:NO];
    }else{
        [self.delegate mapSearchPanel:self openProject:_currentData showStopworkform:NO];
    }
}

-(void)onBtnStopworkformTap{
    if (_relayDataType==0) {
        [self.delegate mapSearchPanel:self openJobDaily:_currentData showStopworkform:YES];
    }else{
        [self.delegate mapSearchPanel:self openProject:_currentData showStopworkform:YES];
    }
}

-(void)phSegmentedValueChanged:(UISegmentedControl *) sender{
    _phFlowState = sender.selectedSegmentIndex-1;
    
    if (_relayDataType == 2) {
        [self createThumbPhoto:nil];
    }
}

//点击cell(或者是点击地图图标查看详情时----停工单code为nil photo code有值)
-(void)showDataAt:(int)index photoCode:(NSString *)code{
    NSMutableDictionary *d = [self.dataSource objectAtIndex:index];
    if (d==_currentData) {
        //点击地图图标
        if (nil!=code) {
            NSArray *pvs = _photoView.subviews;
            for (int i=0; i<pvs.count; i++) {
                JobPhotoView *jobPhoto = (JobPhotoView *)[pvs objectAtIndex:i];
                if ([jobPhoto.photoCode isEqualToString:code]) {
                    _currentPhotoView.selected = NO;
                    jobPhoto.selected = YES;
                    _currentPhotoView = jobPhoto;
                    break;
                }
            }
        }
        else if(nil!=_currentPhotoView){//有当前选择照片
            _currentPhotoView.selected = NO;
            _currentPhotoView = nil;
        }
    }else{
        //_phFilterFirstChanged = YES;
        _phFilterControl.selectedSegmentIndex = 0;
        //设置当前数据
        _currentData = d;
        _phFlowState = -1;
        //创建拇指照片
//        [self createThumbPhoto:code];
        [self setLabelText];
//        if (_relayDataType==2) {
//            [self setPhFlowInfo];
//        }
    }
    self.layerFilter =[NSString stringWithFormat:@"CODE = '%@'",[d objectForKey:@"code"]];
    //显示详情
    [self showDetailPanel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
