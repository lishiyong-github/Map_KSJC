//
//  MapViewController+BusinessSearch.m
//  zzzf
//
//  Created by zhangliang on 14-4-20.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "MapViewController+BusinessSearch.h"
#import "MapViewController+IdentifyPictureMarker.h"
#import "AGSGraphic+Extention.h"

@implementation MapViewController (BusinessSearch)


-(void)c_initDataQueryList{
    _query_param_datatype = 0;
    NSThread *jsonLoader = [[NSThread alloc] initWithTarget:self selector:@selector(loadOrgJson) object:nil];
    [jsonLoader start];
}

-(void)loadOrgJson{
    NSError *error;
    //从网络下载org.json数据
    NSString *mapJson = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/org.json",[Global serverAddress]]] encoding:NSUTF8StringEncoding error:&error];
    if (nil!=error) {
        [self performMainThreadConfigError];
        return;
    }
    //转换成字典
    NSError *parseError = nil;
    NSMutableDictionary *rs = [NSJSONSerialization JSONObjectWithData:[mapJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    if (nil!=parseError) {
        [self performMainThreadConfigError];
        return;
    }
    _orgList = [rs objectForKey:@"org"];
    [self performSelectorOnMainThread:@selector(configLoadSuccessfully) withObject:nil waitUntilDone:YES];
}

-(void)performMainThreadConfigError{
    [self performSelectorOnMainThread:@selector(configLoadError) withObject:nil waitUntilDone:YES];
}

-(void)configLoadError{
    
}

-(void)configLoadSuccessfully{
    _query_param_org = [Global currentUser].orgID;
    
    //更新数据
    [self c_updateBusinessData];
}

//更新数据
-(void)c_updateBusinessData{
    //让tableVIew转菊花
    [_searchResultPanel wait];
    
    if (nil!=_delayLoaderM) {
        [_delayLoaderM invalidate];
        _delayLoaderM = nil;
    }
    _delayLoaderM = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(delayQueryBusinessData) userInfo:nil repeats:NO];
}

-(void)delayQueryBusinessData{
    [self c_queryData:_query_param_org dataType:_query_param_datatype dateLevel:_query_param_dateLevel];
}

-(NSString *)getOrgGraphicId:(NSString *)org
{
    for (int i=0; i<_orgList.count; i++) {
        NSDictionary *orgInfo = [_orgList objectAtIndex:i];
        if ([org isEqualToString: [orgInfo objectForKey:@"id"]]) {
            return [orgInfo objectForKey:@"graphic"];
        }
    }
    return @"";
}

-(void)c_queryData:(NSString *)orgId dataType:(int)dataType  dateLevel:(int)dataLevel{
    
    [self stopped];//移除imageview
    //图形图层(移除图形图层)
    [self.pictureGraphicsLayer removeAllGraphics];
    //隐藏标注
    self.mapView.callout.hidden = YES;
    self.removeGraphics = [[NSMutableArray alloc]init];
    //设置请求代理
    ServiceProvider *q = [ServiceProvider initWithDelegate:self];
    _queryFlagM++;
    q.tag = _queryFlagM;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/M/d"];
    //开始时间
    NSString *strD1 = [formatter stringFromDate:_dateSelector.start];
    //结束时间
    NSString *strD2 = [formatter stringFromDate:_dateSelector.end];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *endDate= [dateFormatter dateFromString:strD2];
    NSDate *starDate=[dateFormatter dateFromString:strD1];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *endTime = [NSString stringWithFormat:@"%@ 23:59:59",[dateFormatter stringFromDate:endDate]];
    NSString *starTime = [NSString stringWithFormat:@"%@ 00:00:00",[dateFormatter stringFromDate:starDate]];
    _dataTypeM = dataType;
    //巡查记录
    if (dataType==0) {
        //        [q getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"querydailyjob",@"action",strD1,@"d1",strD2,@"d2",orgId,@"org", nil]];
        //       type=smartplan&action=getphgldata&startDate=2016-11-27%2000:00:00&endDate=2017-01-07%2000:00:00&pid=-1
        [q getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getphgldata",@"action",starTime,@"startDate",endTime,@"endDate",@"-1",@"pid",nil]];
        //根据当前用户id去获取组织id(graphic)
        NSString *orgID = [NSString stringWithFormat:@"%@",orgId];
        orgId = [self getOrgGraphicId:orgID];
        
        NSString *layerFilter = nil;
        if ([orgId isEqual:@"0"]) {
            layerFilter =[NSString stringWithFormat:@"DATETIME >= date '%@ 00:00:00' AND DATETIME <= date '%@ 23:59:59'",strD1,strD2];
        }
        else{
            layerFilter =[NSString stringWithFormat:@"DATETIME >= date '%@ 00:00:00' AND DATETIME <= date '%@ 23:59:59' AND ORGID = '%@'",strD1,strD2,orgId];
        }
        //执行显示列表
        [self filterRCXCLayer:layerFilter];
        //保存layerFilter
        self.layerFilter = layerFilter;
    }
    else if (dataType==1) {//批后跟踪
            //type=smartplan&prjName=&prjState=&businessName=批后过程管理&slbh=&businessId=&querystring=&action=getsupervisorylist&pageIndex=0&pageSize=100&xmbh=
            [q getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getsupervisorylist",@"action",@"",@"xmbh",@"",@"slbh",@"",@"prjName",@"批后过程管理",@"businessName",@"",@"businessId",@"",@"prjState",@"0",@"pageIndex",@"100",@"pageSize",@"",@"querystring", nil]];
            
        }
        else if (dataType ==2)
        {
            [q getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getsupervisorylist",@"action",@"",@"xmbh",@"",@"slbh",@"",@"prjName",@"验线",@"businessName",@"",@"businessId",@"",@"prjState",@"0",@"pageIndex",@"100",@"pageSize",@"",@"querystring", nil]];
            
        }
        else if (dataType ==3)
        {
            [q getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getsupervisorylist",@"action",@"",@"xmbh",@"",@"slbh",@"",@"prjName",@"核实",@"businessName",@"",@"businessId",@"",@"prjState",@"0",@"pageIndex",@"100",@"pageSize",@"",@"querystring", nil]];
            
        }
        else
        {
            [q getData:@"smartplan" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"getsupervisorylist",@"action",@"",@"xmbh",@"",@"slbh",@"",@"prjName",@"工程",@"businessName",@"",@"businessId",@"",@"prjState",@"0",@"pageIndex",@"100",@"pageSize",@"",@"querystring", nil]];
            
        }
}




#pragma mark- ServiceCallbackDelegate代理方法

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    if (provider.tag!=_queryFlagM) {
        return;
    }
    NSString *successfully = [data objectForKey:@"success"];
    if (successfully) {
        NSArray *rs = [data objectForKey:@"result"];
        //更新地图数据
        //[self refershMapData:rs dataType:_dataTypeM];
        [self refreshMapDataNew:rs dataType:_dataTypeM];
    }
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    
}

-(void)createPictureGraphic:(NSArray*)records{
    
    for (NSDictionary* dict in records) {
        CGFloat x = [(NSString*)[dict objectForKey:@"x"] floatValue];
        CGFloat y = [(NSString*)[dict objectForKey:@"y"] floatValue];
        if (x > 0 && y > 0) {
            AGSPoint *pt = [AGSPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference];
            AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"location.png"];
            
//            NSString *pid = [dict objectForKey:@"pid"];
//            NSString *onlyId = [dict objectForKey:@"id"];
//            NSMutableDictionary *attr = [NSMutableDictionary dictionary];
//            [attr setObject:pid forKey:@"pid"];
//            [attr setObject:onlyId forKey:@"id"];
            AGSGraphic *graphicGeom = [AGSGraphic graphicWithGeometry:pt symbol:graphicSymbol attributes:nil];
            graphicGeom.pid = [dict objectForKey:@"pid"];
            graphicGeom.keyId = [dict objectForKey:@"id"];
            [self.pictureGraphicsLayer addGraphic:graphicGeom];
        }
    }
}


//更新地图，定位项目 liuxb
- (void)refreshMapDataNew:(NSArray *)data dataType:(int)dataType{
    
    NSMutableArray *dataNew = [[NSMutableArray alloc]initWithArray:data];
    //遍历
    for (int index = 0; index < [dataNew count]; index++) {
        NSMutableDictionary *mapPointData =  [dataNew objectAtIndex:index];
        if (_query_param_dateLevel>=0) {
            if (![[mapPointData objectForKey:@"level"] isEqualToString:[NSString stringWithFormat:@"%d",_query_param_dateLevel]]) {
                [dataNew removeObjectAtIndex:index];
                index--;
                continue;
            }
        }
    }
    
    /* 老代码
    NSMutableArray *xmbhArray = [NSMutableArray array];
    for (NSDictionary *dict in dataNew) {
        NSString* xmbh = [dict objectForKey:@"xmbh"];
        if (xmbh && ![xmbh isEqual:@""]) {
            [xmbhArray addObject:xmbh];
        }
    }
    
    NSNumber *layerid = [KSJZHXID objectAtIndex:0];
    NSString *ulrStr = [NSString stringWithFormat:@"%@%@",KSJZHX,layerid];
    [self projectLocation:xmbhArray andURL:[NSURL URLWithString:ulrStr]];
    */
    
    //创建定位图标
    [self createPictureGraphic:dataNew];
    
    //设置列表tableView的数据源
    _searchResultPanel.dataType = dataType;
    _searchResultPanel.dataSource = dataNew;
}



//根据项目编号，进行保存位置
-(void)projectLocation:(NSArray*)xmbhArray andURL:(NSURL*) url{
    
    if (self.queryTask == nil) {
        //set up query task against layer, specify the delegate
        self.queryTask = [AGSQueryTask queryTaskWithURL:url];
        self.queryTask.delegate = self;
    }
    
    if (self.query == nil) {
        //return all fields in query
        self.query = [AGSQuery query];
        self.query.outFields = @[@"*"];
        self.query.outSpatialReference = self.mapView.spatialReference;
        
        self.query.returnGeometry=YES;
    }
    
    NSString* where = @"";
    NSString* split = @"";
    
    for (NSString* xmbh in xmbhArray) {
        
        NSString *temp = [[@"XMBH='" stringByAppendingString:xmbh] stringByAppendingString:@"'"];
        where = [where stringByAppendingString:[split stringByAppendingString:temp]];
        split = @" or ";
    }
    
    self.query.where = where;
    
    [self.queryTask executeWithQuery:self.query];
}

#pragma mark -AGSQueryTaskDelegate代理方法
- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation*)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {
    [self clearXMLocation];
    NSMutableArray *filterRepeat = [NSMutableArray array];
    if([featureSet.features count]>0){
        NSDictionary *filedAliases = featureSet.fieldAliases;
        for (AGSGraphic *feature in featureSet.features) {
            //判断是否有图形
            if (feature.geometry) {
                NSString *xmbh = [feature attributeForKey:@"XMBH"];
                if ([filterRepeat containsObject:xmbh]) {
                    continue;
                } else {
                    [filterRepeat addObject:xmbh];
                    NSLog(@"%@",xmbh);
                }
                
                //别名属性
                NSDictionary *aliasAttributes = [self replaceAlias:filedAliases att:[feature allAttributes]];
                
                //定位图标
                AGSPictureMarkerSymbol *graphicSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"home_red.png"];
                AGSGraphic *graphicPic = [AGSGraphic graphicWithGeometry:feature.geometry.envelope.center symbol:graphicSymbol attributes:aliasAttributes];
                [self.pictureGraphicsLayer addGraphic:graphicPic];
                
                /*
                 //图形样式
                 AGSSimpleFillSymbol *fillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
                 fillSymbol.color = [[UIColor darkGrayColor] colorWithAlphaComponent:0.2];
                 fillSymbol.outline.color = [UIColor redColor];
                 fillSymbol.outline.width = 3.0;
                 
                 AGSGraphic *graphicGeom = [AGSGraphic graphicWithGeometry:feature.geometry symbol:fillSymbol attributes:aliasAttributes];
                 
                 [self.pictureGraphicsLayer addGraphic:graphicGeom];
                 */
            }
            
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"未找到相关项目"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation*)op didFailWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (NSMutableDictionary *)replaceAlias:(NSDictionary *)fieldAliases att:(NSDictionary *)attributes {
    NSMutableDictionary *newAttributes = [[NSMutableDictionary alloc] init];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
        NSString *alias = [fieldAliases objectForKey:key];
        if (alias) {
            [newAttributes setObject:obj forKey:alias];
        }
    }];
    
    return newAttributes;
}


- (void) clearXMLocation{
    [self.pictureGraphicsLayer removeAllGraphics];
    [self.mapView.callout dismiss];
}














//更新地图数据
-(void)refershMapData:(NSArray *)data dataType:(int)dataType{
    NSMutableArray *dataNew = [[NSMutableArray alloc]initWithArray:data];
    NSMutableArray *mapPictureMarkerData = [[NSMutableArray alloc]init];
    
    
    //遍历
    for (int index = 0; index < [dataNew count]; index++) {
        NSString *fatherId = [NSString stringWithFormat:@"%d",index];
        NSMutableDictionary *mapPointData =  [dataNew objectAtIndex:index];
        if (_query_param_dateLevel>=0) {
            if (![[mapPointData objectForKey:@"level"] isEqualToString:[NSString stringWithFormat:@"%d",_query_param_dateLevel]]) {
                [dataNew removeObjectAtIndex:index];
                index--;
                continue;
            }
        }
        //生成photos中的坐标位置信息 保存到数组中
        NSMutableArray *pointData = [self mapPictureMarkPoint:mapPointData fatherId:fatherId pointType:@"photos"];
        if (dataType != 4 && pointData!=nil) {
            
            //保存生成photos坐标位置信息(字典)
            [mapPictureMarkerData addObjectsFromArray:pointData];
        }
        
        //生成stopworkforms中的坐标信息
        pointData = [self mapPictureMarkPoint:mapPointData fatherId:fatherId pointType:@"stopworkforms"];
        if (pointData!=nil) {
            [mapPictureMarkerData addObjectsFromArray:pointData];
        }
    }
    
    
    //有需要标注的图层
    if ([mapPictureMarkerData count]>0) {
        [self creatPictureMarkGraphics:dataType pictureMarkPointsDataSource:mapPictureMarkerData];
    }
    
    
#pragma mark - 设置tabelView的数据源
    //设置列表tableView的数据源
    _searchResultPanel.dataType = dataType;
    _searchResultPanel.dataSource = dataNew;
    
    NSMutableArray *projectIdA =[NSMutableArray array];
    if (dataType == 0) {
        
        //        for (NSDictionary *dict in dataNew) {
        //            [projectIdA addObject:[dict objectForKey:@"xmbh"]];
        //
        //        }
        
    }else{
        //self.btnFilterDate.titleLabel.text = [NSString stringWithFormat:@"%@(%d)",dateFilterLable,[mapPictureMarkerData count]];
        
        for (NSDictionary *dict in dataNew) {
            [projectIdA addObject:[dict objectForKey:@"xmbh"]];
        }
        
    }
}


//生成具体位置的字典数组信息
-(NSMutableArray*)mapPictureMarkPoint:(NSMutableDictionary*)mapPointData fatherId:(NSString*)fatherId pointType:(NSString*)pointType{
    NSString *childId;
    //    NSString *time;
    NSString *userId = [mapPointData objectForKey:@"userid"];
    NSString *orgId = [mapPointData objectForKey:@"org"];
    orgId = [self getOrgGraphicId:orgId];
    NSMutableArray *mapPointArray = [[NSMutableArray alloc]init];
    NSArray *pointDataArray = [mapPointData objectForKey:pointType];
    for (int index = 0; index < [pointDataArray count]; index++) {
        NSString *pointX;
        NSString *pointY;
        NSMutableDictionary *mapPictureMarkerPoint = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *pointDataDic = [NSMutableDictionary dictionaryWithDictionary:[pointDataArray objectAtIndex:index]];
        if (pointDataDic != nil && [pointDataDic count] > 0) {
            pointX = [pointDataDic objectForKey:@"x"];
            pointY = [pointDataDic objectForKey:@"y"];
            if ([pointX length] == 0 || [pointY length] == 0) {
                double longitude = [[pointDataDic objectForKey:@"longitude"] doubleValue];
                double latitude = [[pointDataDic objectForKey:@"latitude"]doubleValue];
                AGSPoint *photoPoint = [self LongLat2XIAN80:longitude lat:latitude];
                pointX = [NSString stringWithFormat:@"%f",photoPoint.x];
                pointY = [NSString stringWithFormat:@"%f",photoPoint.y];
                [pointDataDic setValue:pointX forKey:@"x"];
                [pointDataDic setValue:pointY forKey:@"y"];
            }
        }
        childId = [NSString stringWithFormat:@"%d",index];
        [mapPictureMarkerPoint setObject:pointType forKey:@"type"];
        [mapPictureMarkerPoint setObject:fatherId forKey:@"fatherId"];
        [mapPictureMarkerPoint setObject:childId forKey:@"childId"];
        [mapPictureMarkerPoint setObject:userId forKey:@"userId"];
        [mapPictureMarkerPoint setObject:orgId forKey:@"orgId"];
        [mapPictureMarkerPoint setValuesForKeysWithDictionary:pointDataDic];
        [mapPointArray addObject:mapPictureMarkerPoint];
    }
    return mapPointArray;
}

//坐标转换
-(AGSPoint*)LongLat2XIAN80:(double)longitude lat:(double)latitude{
    //平移X
    double dx = -10607474.878072;
    //平移Y
    double dy = 235779.050280;
    //旋转角度
    double t = -0.0002335177;
    //尺度
    double k = 0.881907757507;
    //WGS84大地坐标转WGS84投影坐标
    double x = longitude * 20037508.34 / 180;
    double y = log(tan((90 + latitude) * M_PI / 360)) / (M_PI / 180);
    y = y * 20037508.34 / 180;
    //WGS84投影坐标转XIAN80投影坐标
    double xianX = k * (x - t * y) + dx;
    double xianY = k * (y + t * x) + dy;
    
    AGSPoint *point = [[AGSPoint alloc]initWithX:xianX y:xianY spatialReference:self.mapView.spatialReference];
    return point;
}
@end
