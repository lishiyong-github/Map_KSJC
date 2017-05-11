//
//  OMapViewController+BusinessDataQuery.m
//  zzzf
//
//  Created by zhangliang on 14-4-16.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "OMapViewController+BusinessDataQuery.h"
#import "OMapViewController+IdentifyPictureMarker.h"

@implementation OMapViewController (BusinessDataQuery)

int _queryFlag = 0;
int _dataType;
NSTimer *_delayLoader;
NSString *dateFilterLable;

-(void)initDataQueryList{
    dateFilterLable = @"周";
    _query_param_datetype = 4;
    _query_param_datatype = 0;
    NSThread *jsonLoader = [[NSThread alloc] initWithTarget:self selector:@selector(loadOrgJson) object:nil];
    [jsonLoader start];
}

-(void)loadOrgJson{
    NSError *error;
    //从网络下载org.json数据
    NSString *mapJson = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/org.json",[Global serverAddress]]] encoding:NSUTF8StringEncoding error:&error];
  NSString *str=  [NSString stringWithFormat:@"%@/org.json",[Global serverAddress]];
    if (nil!=error) {
        [self performMainThreadConfigError];
        
        
        
        return;
    }
//    //转换成字典
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
    if (nil==_orgList || _orgList.count==0) {
        return;
    }
    int btnWidth = self.orgView.frame.size.width/_orgList.count;
    int btnHeight = self.orgView.frame.size.height;
    for (int i=0; i<_orgList.count; i++) {
        SysButton *btn = [SysButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
        btn.titleLabel.font= [ btn.titleLabel.font fontWithSize:13];
        btn.backgroundColor = [UIColor whiteColor];
        btn.defaultBackground = [UIColor whiteColor];
        btn.frame = CGRectMake(i*btnWidth, 0, btnWidth, btnHeight);
        [btn setTitle:[[_orgList objectAtIndex:i] objectForKey:@"name"] forState:UIControlStateNormal];
        [self.orgView addSubview:btn];
        if (i==0) {
            _currengOrgButton = btn;
            btn.selected = YES;
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(orgTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.switchContainer.hidden = NO;
    _query_param_org = [[_orgList objectAtIndex:0] objectForKey:@"id"];
    [self updateBusinessData];
    _dateSelector.hidden = NO;
}

- (void)orgTap:(id)sender {
    SysButton *target = (SysButton *)sender;
    if (target==_currengOrgButton) {
        return;
    }
    NSString *orgId = [[_orgList objectAtIndex:target.tag] objectForKey:@"id"];

    _query_param_org = orgId;
    [self updateBusinessData];
    _currengOrgButton.selected = NO;
    _currengOrgButton = target;
    target.selected = YES;
}


-(void)updateBusinessData{
    [_searchResultPanel wait];
    [self.btnFilterDate setTitle:@"--" forState:UIControlStateNormal];
    if (nil!=_delayLoader) {
        [_delayLoader invalidate];
        _delayLoader = nil;
    }
    _delayLoader = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(delayQueryBusinessData) userInfo:nil repeats:NO];
}

-(void)delayQueryBusinessData{
    [self queryData:_query_param_org dataType:_query_param_datatype dateType:_query_param_datetype dateLevel:_query_param_dateLevel];
}

-(NSString *)getOrgGraphicId:(NSString *)org{
    for (int i=0; i<_orgList.count; i++) {
        NSDictionary *orgInfo = [_orgList objectAtIndex:i];
        if ([org isEqualToString: [orgInfo objectForKey:@"id"]]) {
            return [orgInfo objectForKey:@"graphic"];
        }
    }
    return @"";
}

-(void)queryData:(NSString *)orgId dataType:(int)dataType dateType:(int)dateType dateLevel:(int)dataLevel{
    [self stopped];
    [self.pictureGraphicsLayer removeAllGraphics];
    self.mapView.callout.hidden = YES;
    
    self.removeGraphics = [[NSMutableArray alloc]init];
    
    ServiceProvider *q = [ServiceProvider initWithDelegate:self];
    _queryFlag++;
    q.tag = _queryFlag;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/M/d"];

    [self dateFilter: nowDateTime];
    NSDate *d1 = startDateTime;
    NSDate *d2 = endDateTime;
    
    if (dataType==2) {
        _busiDataType = @"Phxm";
    }else{
        _busiDataType = @"";
    }
    
    if (dateType==4) {
        //周
        dateFilterLable = @"周";
    }else if(dateType==3){
        //本月
        dateFilterLable = @"月";
    }else if(dateType==2){
        //本季度
        dateFilterLable = @"季";
    }else if(dateType == 1){
        //本年
        dateFilterLable = @"年";
    }

    NSString *strD1 = [formatter stringFromDate:d1];
    NSString *strD2 = [formatter stringFromDate:d2];
    _dataType = dataType;
    if (dataType==0) {
        [q getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"querydailyjob",@"action",strD1,@"d1",strD2,@"d2",orgId,@"org", nil]];
        orgId = [self getOrgGraphicId:orgId];
        NSString *layerFilter = nil;
        if ([orgId isEqual:@"0"]) {
            layerFilter =[NSString stringWithFormat:@"DATETIME >= date '%@' AND DATETIME <= date '%@'",strD1,strD2];
        }
        else{
            layerFilter =[NSString stringWithFormat:@"DATETIME >= date '%@' AND DATETIME <= date '%@' AND ORGID = '%@'",strD1,strD2,orgId];
        }
        [self filterRCXCLayer:layerFilter];
        
        self.layerFilter = layerFilter;
        
    }else{
        if (dataType==4) {
            [q getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"querystopworkform",@"action",strD1,@"d1",strD2,@"d2",orgId,@"org", nil]];
        }else{
            if (dataType==-1) {
                [self refershMapData:[NSMutableArray arrayWithCapacity:0] dataType:-1];
                [self.dyMapServiceLayer setVisible:NO];
            }else{
                [q getData:@"zf" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"queryproject",@"action",strD1,@"d1",strD2,@"d2",orgId,@"org",[NSString stringWithFormat:@"%d",_query_param_datatype],@"projecttype",[NSString stringWithFormat:@"%d",dataLevel],@"level", nil]];
            }
        }
        
        [self.dyMapServiceLayer setVisible:NO];
    }
}

-(void)serviceCallback:(ServiceProvider *)provider didFinishReciveJsonData:(NSDictionary *)data{
    if (provider.tag!=_queryFlag) {
        return;
    }
    NSString *successfully = [data objectForKey:@"success"];
    if (successfully) {
        NSArray *rs = [data objectForKey:@"result"];
        [self refershMapData:rs dataType:_dataType];
    }
}

-(void)serviceCallback:(ServiceProvider *)provider requestFaild:(NSError *)error{
    
}

-(void)refershMapData:(NSArray *)data dataType:(int)dataType{
    NSMutableArray *dataNew = [[NSMutableArray alloc]initWithArray:data];
    NSMutableArray *mapPictureMarkerData = [[NSMutableArray alloc]init];
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
        NSMutableArray *pointData = [self mapPictureMarkPoint:mapPointData fatherId:fatherId pointType:@"photos"];
        if (dataType != 4 && pointData!=nil) {
            [mapPictureMarkerData addObjectsFromArray:pointData];
        
        }
        pointData = [self mapPictureMarkPoint:mapPointData fatherId:fatherId pointType:@"stopworkforms"];
        if (pointData!=nil) {
            [mapPictureMarkerData addObjectsFromArray:pointData];
        }
    }
    if ([mapPictureMarkerData count]>0) {
    
        [self creatPictureMarkGraphics:dataType pictureMarkPointsDataSource:mapPictureMarkerData];
    }
    
    _searchResultPanel.dataType = dataType;
    _searchResultPanel.dataSource = dataNew;
    [self.btnFilterDate setTitle:[NSString stringWithFormat:@"%@(%d)",dateFilterLable,[dataNew count]] forState:UIControlStateNormal];
}

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
            pointY = [pointDataDic objectForKey:@"y"] ;
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
