//
//  MapViewController+IdentifyPictureMarker.m
//  zzzf
//
//  Created by Aaron on 14-2-28.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapViewController+IdentifyPictureMarker.h"
#import "OMServiceLayer.h"
#import "AGSGraphic+Extention.h"

typedef enum {
    EmbeddedMapView = 0,
    EmbeddedWebView,
    CustomInfoView,
    SimpleView
} GraphicType;

@implementation MapViewController (IdentifyPictureMarker)


//利用字典数据数组添加图形图层
-(void)creatPictureMarkGraphics:(NSInteger)selectIndex pictureMarkPointsDataSource:(NSMutableArray*)pictureMarkPoints{
    //移除原有的图形
    [self removeImageViews];
    _graphicsArray = [[NSMutableArray alloc]init];
    _imageViewsArray = [[NSMutableArray alloc]init];
    AGSMutablePolygon* zoomPolygon = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
    //添加环
    [zoomPolygon addRingToPolygon];
    
    for (NSDictionary *dic in pictureMarkPoints)
    {
        NSString *type = [dic objectForKey:@"type"];
        NSString *orgId = [dic objectForKey:@"orgId"];
        //        NSString *time = [dic objectForKey:@"time"];
        NSString *x = [dic objectForKey:@"x"];
        NSString *y = [dic objectForKey:@"y"];
        NSMutableDictionary *graphicAttributes = [NSMutableDictionary dictionaryWithDictionary:dic];
        if (x.length == 0 || y.length==0)
            continue;
        AGSPoint *graphicPoint = [AGSPoint pointWithX:[x doubleValue] y:[y doubleValue] spatialReference:self.mapView.spatialReference];
        //添加点
        [zoomPolygon addPointToRing:graphicPoint];
        NSString *bussinessICOName = [self themeICOName:[orgId intValue] type:type];
        AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:bussinessICOName];
        
        
        
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:graphicPoint symbol:graphicSymbol attributes:graphicAttributes];
        //地图可视区域有点
        if ([self.mapView.visibleArea.envelope containsPoint: graphicPoint])
        {
            CGPoint screenPnt = [self.mapView toScreenPoint:graphicPoint];
            UIImageView * imageView = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:bussinessICOName]];
            
            //给_graphicsArray添加AGSGraphic
            [_graphicsArray addObject:graphic];
            //把图片加到数组中
            [_imageViewsArray addObject:imageView];
            
            CGRect endFrame = CGRectMake(screenPnt.x-18, screenPnt.y-18, 36, 36);
            imageView.frame = CGRectMake(endFrame.origin.x, endFrame.origin.y-20, 36, 36);
            imageView.alpha = 0;
            [self.mapView addSubview:imageView];
            
            [UIView animateWithDuration:1 animations:^{
                [imageView setFrame:endFrame];
                imageView.alpha = 1;
            }
                             completion:^(BOOL finished){
                                 if (finished){
                                     //[self.pictureGraphicsLayer addGraphic:graphic];
                                     //[imageView removeFromSuperview];
                                 }
                             }];
        }
        else{
            [self.pictureGraphicsLayer addGraphic:graphic];
            //画
            [self.mapView zoomToGeometry:zoomPolygon withPadding:5.0 animated:YES];
            [self stopped];
        }
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)stopped{
    //有图形图层数组不为空
    if (nil != _graphicsArray && [_graphicsArray count]>0) {
        
        //往AGSGraphicsLayer图形图层上添加
        [self.pictureGraphicsLayer addGraphics:_graphicsArray];
        //清空
        [_graphicsArray removeAllObjects];
    }
    
    [self removeImageViews];
}
-(void)removeImageViews{
    if (nil != _imageViewsArray && [_imageViewsArray count]>0) {
        for (int i = 0; i< [_imageViewsArray count]; i++) {
            UIImageView * imageView = [_imageViewsArray objectAtIndex:i];
            [imageView removeFromSuperview];
        }
        [_imageViewsArray removeAllObjects];
    }
}
#pragma clang diagnostic pop


-(NSString*)themeICOName:(NSInteger)orgID type:(NSString*)type{
    NSString *themeICOName = [[self imageNameColor:orgID] objectForKey:type];
    return themeICOName;
}

//根据组织id 设置图片颜色
-(NSMutableDictionary*)imageNameColor:(NSInteger)orgID
{
    NSMutableDictionary *imageNames = [[NSMutableDictionary alloc]init];
    NSString *imageNameColor = nil;
    switch (orgID) {
        case 1:
            imageNameColor = @"red";
            break;
        case 2:
            imageNameColor = @"green";
            break;
        case 3:
            imageNameColor = @"orange";
            break;
        case 4:
            imageNameColor = @"blue";
            break;
        default:
            imageNameColor = @"red";
            break;
    }
    NSString *home = [NSString stringWithFormat:@"home_%@.png",imageNameColor];
    NSString *camera = [NSString stringWithFormat:@"Camera_%@.png",imageNameColor];
    NSString *wei = [NSString stringWithFormat:@"wei_%@.png",imageNameColor];
    NSString *stop = [NSString stringWithFormat:@"stop_%@.png",imageNameColor];
    NSString *ji = [NSString stringWithFormat:@"ji_%@.png",imageNameColor];
    NSString *gai = [NSString stringWithFormat:@"gai_%@.png",imageNameColor];
    NSString *zhuan = [NSString stringWithFormat:@"zhuan_%@.png",imageNameColor];
    NSString *zhu = [NSString stringWithFormat:@"zhu_%@.png",imageNameColor];
    NSString *ding = [NSString stringWithFormat:@"ding_%@.png",imageNameColor];
    NSString *wai = [NSString stringWithFormat:@"wai_%@.png",imageNameColor];
    [imageNames setValue:home forKey:@"home"];
    [imageNames setValue:camera forKey:@"photos"];
    [imageNames setValue:wei forKey:@"wei"];
    [imageNames setValue:stop forKey:@"stopworkforms"];
    [imageNames setValue:ji forKey:@"ji"];
    [imageNames setValue:gai forKey:@"gai"];
    [imageNames setValue:zhuan forKey:@"zhuan"];
    [imageNames setValue:zhu forKey:@"zhu"];
    [imageNames setValue:ding forKey:@"ding"];
    [imageNames setValue:wai forKey:@"wai"];
    return imageNames;
}


- (void)loadbaseProjectWithpid:(NSString *)pid forGraphic:(AGSGraphic*)graphic withPt:(AGSPoint*)mappoint
{
    //根据记录获取基本信息
    //58.246.138.178:8040/KSYDService/ServiceProvider.ashx?type=smartplan&action=projectbaseinfo&projectId=87668
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"type"] = @"smartplan";
    parameters[@"action"]=@"projectbaseinfo";
    parameters[@"projectId"]=pid;
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    NSLog(@"添加一条新记录%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
            NSArray *arr= [rs objectForKey:@"result"];
            if (arr.count > 0) {
                NSDictionary *dict =[rs objectForKey:@"result"][0];
                
                NSMutableDictionary* attr = [self reAttribute:dict];
                [graphic setAttributes:attr];
                [self showPopupForGraphic:graphic mapPoint:mappoint];
            } else {
                [self showCallout:IdentifyStateTypeFail location:self.mapPoint];
            }
        } else {
            [self showCallout:IdentifyStateTypeFail location:self.mapPoint];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showCallout:IdentifyStateTypeFail location:self.mapPoint];
    }];
}

-(NSMutableDictionary*)reAttribute:(NSDictionary*)dict {
    //项目编号”“案卷编号”项目名称“建设单位”“建设地址”
    NSString *xmbh = [dict objectForKey:PROJECTKEY_XMBH];
    NSString *slbh = [dict objectForKey:PROJECTKEY_SLBH];
    NSString *name = [dict objectForKey:PROJECTKEY_NAME];
    NSString *company = [dict objectForKey:PROJECTKEY_COMPANY];
    NSString *address = [dict objectForKey:PROJECTKEY_ADDRESS];
    
    NSMutableDictionary* attr = [NSMutableDictionary dictionary];
    [attr setObject:xmbh forKey:@"项目编号"];
    [attr setObject:slbh forKey:@"案卷编号"];
    [attr setObject:name forKey:@"项目名称"];
    [attr setObject:company forKey:@"建设单位"];
    [attr setObject:address forKey:@"建设地址"];
    return attr;
}


#pragma -mark AGSMapViewTouchDelegate代理方法
-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
//    [self.graphicsLayer removeAllGraphics];
//    NSArray *graphicArray= [graphics objectForKey:@"PictureGraphicsLayer"];
//    AGSGraphic *graphic = [graphicArray objectAtIndex:0];
//    if ([graphic.geometry isKindOfClass:[AGSPoint class]]) {
//        return;
//    }
//    else{
//        identifyFullResult = [[NSMutableArray alloc]init];
//        self.mapPoint = mappoint;
//        
//        NSArray *visableLayers = [[NSArray alloc]initWithObjects:@"1", nil];
//        rcxcUrl = [NSString stringWithFormat:@"%@",[LayerManager mapServiceUrl:RCXC]];
//        self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:[NSURL URLWithString:rcxcUrl]];
//        self.identifyTask.delegate = self;
//        self.identifyParameters = [[AGSIdentifyParameters alloc] init];
//        self.identifyParameters.layerIds = visableLayers;
//        self.identifyParameters.tolerance = 4;
//        self.identifyParameters.geometry = self.mapPoint;
//        self.identifyParameters.size = self.mapView.bounds.size;
//        self.identifyParameters.mapEnvelope = self.mapView.visibleArea.envelope;
//        self.identifyParameters.returnGeometry = YES;
//        
//        AGSLayerDefinition *ld0 = [AGSLayerDefinition layerDefinitionWithLayerId:1 definition:self.identifyLayerFilter];
//        NSArray *layerDefinitions = [[NSArray alloc]initWithObjects:ld0, nil];
//        self.identifyParameters.layerDefinitions =layerDefinitions;
//        self.identifyParameters.layerOption = AGSIdentifyParametersLayerOptionVisible;
//        self.identifyParameters.spatialReference = self.mapView.spatialReference;
//        
//        //execute the task
//        [self.identifyTask executeWithParameters:self.identifyParameters];
//    }
    
    
    NSArray *indetifyGraphics = [graphics objectForKey:@"IndentifyGraphicsLayer"];
    NSArray *picGraphics = [graphics objectForKey:@"PictureGraphicsLayer"];
    
    if (indetifyGraphics) {
        return [self.indentifyGraphicsLayer removeAllGraphics];
    }
    
    if (picGraphics) {
        AGSGraphic *graphic = [picGraphics objectAtIndex:0];
        NSString *pid = graphic.pid;
        [self showCallout:IdentifyStateTypeIdentifying location:mappoint];
        return [self loadbaseProjectWithpid:pid forGraphic:graphic withPt:mappoint];
    }
    
    if (graphics.count == 0) {
        if (self.allVisibleLayerIds.count == 0) {
            return [self.indentifyGraphicsLayer removeAllGraphics];
        } else {
            [self showCallout:IdentifyStateTypeIdentifying location:mappoint];
            [self identifyOnline:mappoint];
        }
    }
    
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#pragma  mark- AGSIdentifyTaskDelegate代理方法
-(void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results{
    /* 原始代码
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
        [self.mapView.callout showCalloutAt:self.mapPoint screenOffset:CGPointZero animated:YES];
    }
    */
    
    
    // liuxb 2016-12-15
    [self.indentifyGraphicsLayer removeAllGraphics];
    if (results == nil || results.count == 0) {
        return [self doIdentifyOperation];
    }
    
    for (AGSIdentifyResult *result in results) {
        NSString *key = [NSString stringWithFormat:@"%@_%i",result.layerName,result.layerId];
        NSString *ulrStr = [NSString stringWithFormat:@"%@/%i?f=json",identifyTask.URL,result.layerId];
        if ([self.filedInfo objectForKey:key] == nil) {
            NSURL *url = [NSURL URLWithString:ulrStr];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            NSDictionary *layerDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (layerDict) {
                NSArray *fields = [layerDict objectForKey:@"fields"];
                [self.filedInfo setObject:fields forKey:key];
            }
        }
    }
    
    [self.identifyResults addObjectsFromArray:results];
    [self doIdentifyOperation];
    
}
#pragma clang diagnostic pop
#pragma mark - AGSCalloutDelegate代理方法
//将要显示图标详情
-(BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint
{   /* 原始代码
    self.mapView.callout.customView = nil;
    AGSGraphic* graphic = (AGSGraphic*)feature;
    NSDictionary *d = [graphic allAttributes];
    if ([layer.name isEqualToString:@"CurrentDailyGraphicsLayer"]) {
        NSString *t = [NSString stringWithFormat:@"%@-%@-%@",[d objectForKey:@"dept"],[d objectForKey:@"user"],[d objectForKey:@"lasttime"]];
        self.mapView.callout.title = t;
    }
    else if([layer.name isEqualToString:@"PictureGraphicsLayer"]){
        self.mapView.callout.title = [d objectForKey:@"name"];
        self.mapView.callout.detail = [d objectForKey:@"time"];
        self.mapView.callout.accessoryButtonHidden = YES;
        NSString *t = [d objectForKey:@"type"];
        //显示图片信息详情
        if ([t isEqualToString:@"stopworkforms"]) {
            [self showDetailPanelAt:[[d objectForKey:@"fatherId"] intValue] photoCode:nil];
        }else if([t isEqualToString:@"photos"]){
            [self showDetailPanelAt:[[d objectForKey:@"fatherId"] intValue] photoCode:[d objectForKey:@"code"]];
        }
    }*/
    return YES;
}










#pragma mark -- i 查询 相关操作

- (void)identifyOnline:(AGSPoint*)point{
    self.mapPoint = point;
    if (self.allVisibleLayerIds.count == 0) {
        return;
    }
    
    self.identifyCount = 0;
    self.identifyResults = [NSMutableArray array];
    self.filedInfo = [NSMutableDictionary dictionary];
    
    [self doIdentifyOperation];
}

- (void)doIdentifyOperation{
    self.identifyCount += 1;
    if (self.identifyCount > self.allVisibleLayerIds.count ) {
        if (self.identifyCount - self.allVisibleLayerIds.count > 2) {
            return;
        } else {
            [self identifyCompleted];
        }
    } else {
        /* 使用老代码图层加载逻辑时的i查询方式
        NSArray* allKeys = [self.visibleLayersDict allKeys];
        NSString *urlStr = [allKeys objectAtIndex:self.identifyCount - 1];
        NSArray *ids = [self.visibleLayersDict objectForKey:urlStr];
        if (urlStr&&ids) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [self executeIdentifyTask:url andIds:ids];
        } else {
            [self doIdentifyOperation];
        }
        */
        NSString* itemId = [self.allVisibleLayerIds objectAtIndex: self.identifyCount -1 ];
        OMBaseItem *item = [self.allGroupsDic objectForKey:itemId];
        if (item) {
            if (item.type == Layer) {
                OMServiceLayer *omServiceLayer = [self.serviceLayerDic objectForKey:item.serviceUid];
                if ([omServiceLayer.hostLayer isKindOfClass:[AGSDynamicMapServiceLayer class]]) {
                    AGSDynamicMapServiceLayer* hostLayer = (AGSDynamicMapServiceLayer*)omServiceLayer.hostLayer;
                    NSArray* layerIds = [NSArray arrayWithObject:item.layerId];
                    [self executeIdentifyTask:hostLayer.URL andIds:layerIds];
                }
            } else {
                [self doIdentifyOperation];
            }
        }
    }
}

- (void)identifyCompleted{
    [self.activityIndicator stopAnimating];
    self.mapView.callout.customView = nil;
    NSMutableArray *graphics = [NSMutableArray array];
    for (AGSIdentifyResult* result in self.identifyResults) {
        if (result) {
            AGSGraphic* graphic = result.feature;
            NSString *layerId = [NSString stringWithFormat:@"%i",result.layerId];
            [graphic setValue:layerId forKey:@"layerId"];
            [graphic setValue:result.layerName forKey:@"layerName"];
            [graphics addObject:graphic];
        }
    }
    if (graphics.count > 0) {
        //显示气泡
        [self showPopupResultWithLocation:graphics andLocation:self.mapPoint];
    } else {
        //显示空
        [self identifyNullResultCompleted];
    }
    
}



- (void)executeIdentifyTask:(NSURL *)url andIds:(NSArray *)ids {
    self.identifyParameters = [[AGSIdentifyParameters alloc] init];
    self.identifyParameters.layerIds = ids;
    self.identifyParameters.tolerance = 3;
    self.identifyParameters.geometry = self.mapPoint;
    self.identifyParameters.size = self.mapView.bounds.size;
    self.identifyParameters.mapEnvelope = self.mapView.visibleAreaEnvelope;
    self.identifyParameters.returnGeometry = YES;
    self.identifyParameters.layerOption = AGSIdentifyParametersLayerOptionAll;
    self.identifyParameters.spatialReference = self.mapView.spatialReference;
    
    self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:url];
    self.identifyTask.delegate = self;
    [self.identifyTask executeWithParameters:self.identifyParameters];
}


#pragma mark -- i 查询气泡信息展示

// 气泡属性
-(void)showPopupForGraphic:(AGSGraphic *)picGraphic mapPoint:(AGSPoint *)location {
    self.mapPoint = location;
    AGSGraphic *filterGraphic = [self filterGraphic:picGraphic withFilters:IDENTIFY_SYS_FIELDS];
    AGSPopupInfo *popInfo = [AGSPopupInfo popupInfoForGraphic:filterGraphic];
    
    AGSPopup *pop = [AGSPopup popupWithGraphic:filterGraphic popupInfo:popInfo];
    [self displayResultsWithPopupVC:[NSArray arrayWithObject:pop]];
}

- (void) identifyNullResultCompleted{
    [self showCallout:IdentifyStateTypeNoResult location:self.mapPoint];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mapView.callout dismiss];
    });
}

- (void) displayResultsWithPopupVC:(NSArray *)popups {
    [self setupPopupVC:popups];
    [self showCallout:IdentifyStateTypeHasResult location:self.mapPoint];
}


- (void) setupPopupVC: (NSArray *)popups {
    self.popContainerViewController = [[AGSPopupsContainerViewController alloc] initWithPopups:popups usingNavigationControllerStack:false];
    self.popContainerViewController.style = AGSPopupsContainerStyleCustomColor;
    self.popContainerViewController.delegate = self;
    self.popContainerViewController.pagingStyle = AGSPopupsContainerPagingStylePageControl;
    self.popContainerViewController.view.frame = CGRectMake(0, 0, 250, 300);
    
    UIColor *customColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
    self.popContainerViewController.attributeTitleColor = customColor;
    self.popContainerViewController.attributeTitleFont = [UIFont systemFontOfSize:14];
    self.popContainerViewController.attributeDetailFont = [UIFont systemFontOfSize:15];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    closeBtn.frame = CGRectMake(0, 0, 50, 40);
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:customColor forState:UIControlStateNormal];
    [closeBtn addTarget:self action: @selector(closePopup)  forControlEvents:UIControlEventTouchUpInside];
    self.popContainerViewController.actionButton = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    
    self.popContainerViewController.doneButton = [[UIBarButtonItem alloc] init];
}


- (void) showPopupResultWithLocation:(NSArray *)graphics andLocation:(AGSPoint *)point {
    NSMutableArray *popups = [NSMutableArray array];
    NSMutableArray *resultGraphias = [NSMutableArray array];
    AGSGraphic *firstGraphic = nil;
    
    for (AGSGraphic* graphic in graphics) {
        NSString *layerId = [graphic attributeForKey:@"layerId"];
        NSString *layerName = [graphic attributeForKey:@"layerName"];
        NSString *key = [NSString stringWithFormat:@"%@_%@",layerName,layerId];
        
        NSMutableArray* filterKeys = [NSMutableArray array];
        [filterKeys addObjectsFromArray:IDENTIFY_SYS_FIELDS];
        if (self.filedInfo == nil || self.filedInfo.count == 0) {
            [filterKeys addObjectsFromArray:CUSTOM_SYS_FIELDS];
        }
        
        AGSGraphic *filterGraphic = [self filterGraphic:graphic withFilters:filterKeys];
        AGSPopupInfo *popInfo = [AGSPopupInfo popupInfoForGraphic:filterGraphic];
        popInfo.accessibilityLabel = layerName;
        
        NSMutableArray *filedInfos = [NSMutableArray array];
        NSArray *fieldItems = [self.filedInfo objectForKey:key];
        if (fieldItems) {
            for (NSDictionary *dict in fieldItems) {
                NSString *aliasName = [dict objectForKey:@"alias"];
                for (AGSPopupFieldInfo* popFieldInfo in popInfo.fieldInfos) {
                    if ([popFieldInfo.fieldName isEqualToString:aliasName]) {
                        [filedInfos addObject:popFieldInfo];
                        break;
                    }
                }
            }
            popInfo.fieldInfos = filedInfos;
        }
        
        AGSPopup *pop = [AGSPopup popupWithGraphic:filterGraphic popupInfo:popInfo];
        
        [popups addObject:pop];
        [resultGraphias addObject:graphic];
    }
    
    if (resultGraphias.count > 0) {
        firstGraphic = [resultGraphias objectAtIndex:0];
    }
    
    if (firstGraphic != nil) {
        [self setGraphicWithSymbol:firstGraphic];
        [self.indentifyGraphicsLayer addGraphic:firstGraphic];
        self.focusGraphic = firstGraphic;
    }
    
    [self displayResultsWithPopupVC:popups];
    
}

-(void) showCallout:(IdentifyStateType) state location:(AGSPoint *)mappoint {
    switch (state) {
        case IdentifyStateTypeIdentifying:
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.activityIndicator.color = [UIColor blueColor];
            [self.activityIndicator startAnimating];
            
            self.mapView.callout.customView = self.activityIndicator;
            self.mapView.callout.customView.layer.cornerRadius = 0;
            self.mapView.callout.cornerRadius = 0;
            self.mapView.callout.margin = CGSizeMake(5, 5);
            
            break;
        case IdentifyStateTypeHasResult:
            self.mapView.callout.customView = self.popContainerViewController.view;
            self.mapView.callout.cornerRadius = 20;
            self.mapView.callout.customView.layer.cornerRadius = 20;
            self.mapView.callout.customView.clipsToBounds = YES;
            self.mapView.callout.margin = CGSizeZero;
            break;
        case IdentifyStateTypeNoResult:
            self.mapView.callout.tintColor = [UIColor redColor];
            self.mapView.callout.accessoryButtonHidden = YES;
            self.mapView.callout.title = @"无查询结果";
            self.mapView.callout.detail = @"";
            break;
        default:
            self.mapView.callout.tintColor = [UIColor redColor];
            self.mapView.callout.accessoryButtonHidden = YES;
            self.mapView.callout.title = @"查询失败";
            self.mapView.callout.detail = @"";
            break;
    }
    
    [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
}


// 过滤grahpic属性
-(AGSGraphic *)filterGraphic:(AGSGraphic *)graphic withFilters:(NSArray*)filterKeys {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[graphic allAttributes]];
    NSArray *keys = [attributes allKeys];
    for (NSString *key in keys) {
        //移除系统字段
        if ([filterKeys containsObject:key]) {
            [attributes removeObjectForKey:key];
            continue;
        }
        
        //移除空字段
        NSString *graphicValue = nil;
        id value = [attributes objectForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            graphicValue = [(NSNumber *)value stringValue];
        } else if ([value isKindOfClass:[NSString class]]) {
            graphicValue = value;
        } else {
            graphicValue = @"";
        }
        
        if ([graphicValue.uppercaseString isEqualToString:@"NULL"]||[graphicValue.uppercaseString isEqualToString:@""]) {
            [attributes removeObjectForKey:key];
        }
    }
    
    AGSGraphic *newGraphic = [AGSGraphic graphicWithGeometry:graphic.geometry symbol:graphic.symbol attributes:attributes];
    return newGraphic;
}


- (void) setGraphicWithSymbol:(AGSGraphic *)graphic {
    AGSGeometry *geometry = graphic.geometry;
    if ([geometry isKindOfClass:[AGSPoint class]]) {
        AGSSimpleMarkerSymbol *symbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
        symbol.color = [UIColor redColor];
        symbol.style = AGSSimpleMarkerSymbolStyleDiamond;
        graphic.symbol = symbol;
    }
    if ([geometry isKindOfClass:[AGSPolyline class]]) {
        AGSSimpleLineSymbol *symbol = [AGSSimpleLineSymbol simpleLineSymbol];
        symbol.style = AGSSimpleLineSymbolStyleSolid;
        symbol.color = [UIColor yellowColor];
        symbol.width = 4.0;
        graphic.symbol = symbol;
    }
    if ([geometry isKindOfClass:[AGSPolygon class]]) {
        AGSSimpleLineSymbol *outline = [AGSSimpleLineSymbol simpleLineSymbol];
        outline.style = AGSSimpleLineSymbolStyleSolid;
        outline.color = [UIColor yellowColor];
        outline.width = 2.0;
        
        AGSSimpleFillSymbol *symbol = [AGSSimpleFillSymbol simpleFillSymbol];
        symbol.color = [UIColor redColor];
        symbol.outline = outline;
        graphic.symbol = symbol;
    }
}


// 关闭弹出窗
-(void)closePopup {
    [self.mapView.callout dismiss];
    [self.indentifyGraphicsLayer removeAllGraphics];
}



#pragma mark -  AGSPopupsContainerDelegate
-(void)popupsContainer:(id<AGSPopupsContainer>)popupsContainer didChangeToCurrentPopup:(AGSPopup *)popup{
    AGSGraphic* graphic = nil;
    if (popup.feature) {
        graphic = [AGSGraphic graphicWithFeature:popup.feature];
    }
    
    [self.indentifyGraphicsLayer removeGraphic:self.focusGraphic];
    [self setGraphicWithSymbol:graphic];
    [self.indentifyGraphicsLayer addGraphic:graphic];
    self.focusGraphic = graphic;
    
    [self.mapView.callout moveCalloutTo:graphic.geometry.envelope.center screenOffset:CGPointZero animated:true];
    
}




@end
