//
//  OMapViewController+Identity.m
//  zzzf
//
//  Created by Aaron on 14-2-25.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController+Identity.h"
#define mapServiceURL @"http://218.75.221.182:8082/arcgis/rest/services/XZLX/MapServer"

@implementation OMapViewController (Identity)

NSMutableArray *identifyFullResult;
int queryCounter;
NSString *rcxcUrl;

#pragma mark ---- AGSIdentifyTaskDelegate
-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    
    if (graphics.count==0) {
        [self mapDidClickAtEmpty];
    }
    [self.graphicsLayer removeAllGraphics];
    NSArray *graphicArray= [graphics objectForKey:@"PictureGraphicsLayer"];
    AGSGraphic *graphic = [graphicArray objectAtIndex:0];
     if ([graphic.geometry isKindOfClass:[AGSPoint class]]) {
         return;
     }
     else
     {
         self.mapView.callout.customView = nil;
         identifyFullResult = [[NSMutableArray alloc]init];
         self.mappoint = mappoint;
         
         NSArray *visableLayers = [[NSArray alloc]initWithObjects:@"1", nil];
         rcxcUrl = [NSString stringWithFormat:@"%@",[LayerManager mapServiceUrl:RCXC]];
         self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:[NSURL URLWithString:rcxcUrl]];
         self.identifyTask.delegate = self;
         self.identifyParams = [[AGSIdentifyParameters alloc] init];
         self.identifyParams.layerIds = visableLayers;
         self.identifyParams.tolerance = 4;
         self.identifyParams.geometry = self.mappoint;
         self.identifyParams.size = self.mapView.bounds.size;
         self.identifyParams.mapEnvelope = self.mapView.visibleArea.envelope;
         self.identifyParams.returnGeometry = YES;
         
         AGSLayerDefinition *ld0 = [AGSLayerDefinition layerDefinitionWithLayerId:1 definition:self.identifyLayerFilter];
         NSArray *layerDefinitions = [[NSArray alloc]initWithObjects:ld0, nil];
         self.identifyParams.layerDefinitions =layerDefinitions;
         self.identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
         self.identifyParams.spatialReference = self.mapView.spatialReference;
         
         //execute the task
         [self.identifyTask executeWithParameters:self.identifyParams];
    }
}
- (void)mapView:(AGSMapView *)mapView didTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    self.mapView.callout.customView = nil;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.mapView.callout.customView = self.activityIndicator;
    self.activityIndicator.color = [UIColor blueColor];
    [self.activityIndicator startAnimating];
    queryCounter = 0;
    identifyFullResult = [[NSMutableArray alloc]init];
    self.mappoint = mappoint;
    [self doIdentify];
    
    [self.mapView.callout showCalloutAt:self.mappoint screenOffset:CGPointZero animated:YES];
}
-(void)doIdentify{
    queryCounter++;
    if (queryCounter>self.identityParamDic.count) {
        [self identifyCompleted];
    }
    else{
        NSArray *paramDicKey = [self.identityParamDic allKeys];
        
        NSString *paramKey = [paramDicKey objectAtIndex:queryCounter-1];
        
        NSString *paramValue = [self.identityParamDic objectForKey:paramKey];
        NSArray *visableLayers = [[NSArray alloc]initWithObjects:paramValue, nil];
        NSString *themeURL = [NSString stringWithFormat:@"%@",paramKey];
        self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:[NSURL URLWithString:themeURL]];
        self.identifyTask.delegate = self;
        self.identifyParams = [[AGSIdentifyParameters alloc] init];
        self.identifyParams.layerIds = visableLayers;
        self.identifyParams.tolerance = 3;
        self.identifyParams.geometry = self.mappoint;
        self.identifyParams.size = self.mapView.bounds.size;
        self.identifyParams.mapEnvelope = self.mapView.visibleArea.envelope;
        self.identifyParams.returnGeometry = YES;
        self.identifyParams.layerOption = AGSIdentifyParametersLayerOptionVisible;
        self.identifyParams.spatialReference = self.mapView.spatialReference;
        
        //execute the task
        [self.identifyTask executeWithParameters:self.identifyParams];
    }
    
}

-(void)identifyCompleted{
    [self.activityIndicator stopAnimating];
//    self.mapView.callout.customView = nil;
    NSMutableArray *popupArray = [[NSMutableArray alloc] init];
    for (AGSIdentifyResult *identifyResult in identifyFullResult) {
        AGSPopupInfo *popuInfo = [AGSPopupInfo popupInfoForGraphic:identifyResult.feature];
        popuInfo.title = identifyResult.layerName;
        
        AGSPopup *agsPopup = [[AGSPopup alloc] initWithGraphic:identifyResult.feature popupInfo:popuInfo];
        [popupArray addObject:agsPopup];
    }
    if ([popupArray count] > 0) {
        [self showPopupView:popupArray showLocation:self.mappoint];
        AGSIdentifyResult *firstResult = [identifyFullResult objectAtIndex:0];
        [self graphicAddAGSSymbol:firstResult.feature];
        self.favoritePopup = [popupArray objectAtIndex:0];
    }
    else{
        self.mapView.callout.accessoryButtonHidden = YES;
        self.mapView.callout.title = @"无结果";
        self.mapView.callout.detail = @"";
    }
}
- (void)popupsContainerDidFinishViewingPopups:(id<AGSPopupsContainer>)popupsContainer {
    
}

-(void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didFailWithError:(NSError *)error{
    NSLog(@"identify error");
    [self.mapView.callout dismiss];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
-(void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results{
    NSString *identityUrl = [NSString  stringWithFormat:@"%@",identifyTask.URL];
    if ([identityUrl isEqual:rcxcUrl] && [results count]>0) {
        AGSIdentifyResult* result = [results objectAtIndex:0];
        AGSGraphic *graphic = result.feature;
        NSString *code = [graphic attributeAsStringForKey:@"代码"];
        NSString *orgName = [graphic attributeAsStringForKey:@"组织机构"];
        NSString *userName = [graphic attributeAsStringForKey:@"用户ID"];
        for (NSDictionary *dailydic in _searchResultPanel.dataSource) {
            if([code isEqual:[dailydic objectForKey:@"code"]]){
                orgName = [dailydic objectForKey:@"orgname"];
                userName = [dailydic objectForKey:@"user"];
            }
        }
        self.mapView.callout.title = orgName;
        self.mapView.callout.detail = [NSString stringWithFormat:@"%@  %@",userName,
                                       [graphic attributeAsStringForKey:@"巡查时间"]];
        self.mapView.callout.accessoryButtonHidden = YES;
        [self.mapView.callout showCalloutAt:self.mappoint screenOffset:CGPointZero animated:YES];
    }
    else{
        [identifyFullResult addObjectsFromArray:results];
        [self doIdentify];
    }
}
#pragma clang diagnostic pop

-(void)popupsContainer:(id<AGSPopupsContainer>)popupsContainer didChangeToCurrentPopup:(AGSPopup *)popup{
    self.favoritePopup = popup;
    [self.graphicsLayer removeAllGraphics];
    [self graphicAddAGSSymbol:popup.graphic];
    //显示属性窗口
    AGSPoint *popupCenterPoint = popup.graphic.geometry.envelope.center;
    [self.mapView.callout moveCalloutTo:popupCenterPoint screenOffset:CGPointZero rotateOffsetWithMap:YES animated:NO];
}

-(void)hidePopupVc{
    self.mapView.callout.hidden = YES;
    [self.graphicsLayer removeAllGraphics];
}

//打开收藏夹窗口
- (void) openFavoriteView{
    self.mapView.callout.customView = [self creatFavoriteEditVive];
    //获得项目名称作为收藏的默认名称
    NSDictionary *featureAttributes = [self.favoritePopup.feature allAttributes];
    self.txtFavoriteTitle.text = [featureAttributes objectForKey:@"项目名称"];
    
    NSString *favoriteTitle = [self.txtFavoriteTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (favoriteTitle.length>0) {
        
        [self.rightButton setStyle:UIBarButtonItemStyleDone];
        [self.rightButton setAction:@selector(saveFavorite)];
    }
}
//创建收藏夹编辑窗口
- (UIView*)creatFavoriteEditVive{
    UIView *favoriteEditView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 400)];
    favoriteEditView.backgroundColor = [UIColor whiteColor];
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, favoriteEditView.frame.size.width, 44)];
    UINavigationItem *navItem = [[UINavigationItem alloc]initWithTitle:@""];
    //左边“取消”按钮
    UIBarButtonItem *lefItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style: UIBarButtonItemStyleBordered target:self action:@selector(cancelFavorite)];
    [navItem setLeftBarButtonItem:lefItem];
    
    //右边“保存”按钮
    self.rightButton = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:nil];
    [navItem setRightBarButtonItem:self.rightButton];
    
    [navBar pushNavigationItem:navItem animated:YES];
    //收藏夹标题文本框
    self.txtFavoriteTitle = [[UITextField alloc]initWithFrame:CGRectMake(7, 55, favoriteEditView.frame.size.width-14, 30)];
    [self.txtFavoriteTitle setFont:[UIFont systemFontOfSize: 16.0]];
    [self.txtFavoriteTitle setBorderStyle:UITextBorderStyleRoundedRect];
    self.txtFavoriteTitle.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.txtFavoriteTitle.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.txtFavoriteTitle becomeFirstResponder];
    [self.txtFavoriteTitle addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [favoriteEditView addSubview:self.txtFavoriteTitle];
    [favoriteEditView addSubview:navBar];
    return favoriteEditView;
}
//显示PopupView
-(void)showPopupView:(NSMutableArray*)popupArray showLocation:(AGSPoint*)point{
    self.popupVC = [[AGSPopupsContainerViewController alloc] initWithPopups:popupArray usingNavigationControllerStack:NO];
    self.popupVC.style = AGSPopupsContainerStyleDefault;
    self.popupVC.delegate = self;
    self.popupVC.pagingStyle = AGSPopupsContainerPagingStylePageControl;
    [self.popupVC.view setFrame:CGRectMake(0, 0, 300, 400)];
    
    self.mapView.callout.customView = self.popupVC.view;
    
    UIBarButtonItem *blankButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(hidePopupVc)];
    self.popupVC.actionButton = blankButton;
//    UIBarButtonItem *defaultButton = [[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStyleDone target:self action:@selector(openFavoriteView)];
    self.popupVC.doneButton = nil;// defaultButton;
    //显示属性窗口
    [self.mapView.callout showCalloutAt:point screenOffset:CGPointZero animated:YES];
}
//关闭收藏夹编辑窗口
- (void)cancelFavorite{
    self.mapView.callout.customView = self.popupVC.view;
    [self showAction:@"oglFlip" View:self.mapView.callout.customView];
}
//保存属性信息到收藏夹
- (void)saveFavorite{
    NSString *favoriteTitle = [self.txtFavoriteTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSDictionary *graphicJson = [self.favoritePopup.graphic encodeToJSON];
    NSArray *favoriteInfos = [[NSArray alloc]initWithObjects:self.favoritePopup.title,graphicJson, nil];
    [_favoritePanel addFavorite:favoriteInfos Favoritekey:favoriteTitle];
    [self cancelFavorite];
}
//收藏标题文本框监听文字输入事件
- (void) textFieldDidChange:(UITextField *) TextField{
    NSString *favoriteTitle = [TextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (favoriteTitle.length > 0) {
        [self.rightButton setStyle:UIBarButtonItemStyleDone];
        [self.rightButton setAction:@selector(saveFavorite)];
    }else{
        [self.rightButton setStyle:UIBarButtonItemStyleBordered];
        [self.rightButton setAction:nil];
    }
}

-(void)graphicAddAGSSymbol:(AGSGraphic*)graphic{
    
    if ([graphic.geometry isKindOfClass:[AGSPoint class]]) {
        //create and set marker symbol
        AGSSimpleMarkerSymbol *symbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
        symbol.color = [UIColor redColor];
        symbol.style = AGSSimpleMarkerSymbolStyleDiamond;
        graphic.symbol = symbol;
    }
    else if ([graphic.geometry isKindOfClass:[AGSPolyline class]]) {
        //create and set simple line symbol
        AGSSimpleLineSymbol *symbol = [AGSSimpleLineSymbol simpleLineSymbol];
        symbol.style = AGSSimpleLineSymbolStyleSolid;
        symbol.color = [UIColor redColor];
        symbol.width = 4;
        graphic.symbol = symbol;
    }
    else if ([graphic.geometry isKindOfClass:[AGSPolygon class]]) {
        //面状符号
        AGSSymbol* symbol = [AGSSimpleFillSymbol simpleFillSymbol];
        symbol.color = [UIColor redColor];
        graphic.symbol = symbol;
    }
    [self.graphicsLayer addGraphic:graphic];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
-(void)showFavoriteView:(AGSGraphic *)graphic LayerName:(NSString*)layerName{
    self.mapView.callout.customView = nil;
    [self graphicAddAGSSymbol:graphic];
    
    NSMutableArray *popupArray = [[NSMutableArray alloc] init];
    if ([[graphic allAttributes] count] > 0){
        AGSPopupInfo *popuInfo = [AGSPopupInfo popupInfoForGraphic:graphic];
        popuInfo.title = layerName;
        AGSPopup *agsPopup = [[AGSPopup alloc] initWithGraphic:graphic popupInfo:popuInfo];
        [popupArray addObject:agsPopup];
        if ([popupArray count] > 0) {
            AGSPoint *popupCenterPoint = graphic.geometry.envelope.center;
            [self showPopupView:popupArray showLocation:self.mappoint];
            //显示属性窗口
            [self.mapView.callout showCalloutAt:popupCenterPoint screenOffset:CGPointZero animated:YES];
            //缩放
            AGSEnvelope *envelope = graphic.geometry.envelope;
            AGSMutableEnvelope *extent = [AGSMutableEnvelope envelopeWithXmin:envelope.xmin ymin:envelope.ymin xmax:envelope.xmax ymax:envelope.ymax spatialReference:self.mapView.spatialReference];
            [extent expandByFactor:8];
            [self.mapView zoomToEnvelope:extent animated:YES];
        }
    }
}
#pragma clang diagnostic pop

//工具条显示动画
- (void)showAction:(NSString *)animationType View:(UIView *)actionView{
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [animation setType:animationType];
    [actionView.layer addAnimation:animation forKey:animationType];
}
@end
