//
//  ServiceProvider.m
//  YDZF
//
//  Created by dist on 13-10-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//
#import "AFHTTPRequestOperationManager.h"
#import "ServiceProvider.h"
#import "Global.h"

@implementation ServiceProvider{
    BOOL killed;
}

+(ServiceProvider *) initWithDelegate:(id) delegat{
    ServiceProvider *s = [ServiceProvider alloc];
    s.delegate = delegat;
    return s;
}
//地图请求数据
-(void)getString:(NSString *)type parameters:(NSMutableDictionary *)params{
    requestParameters = params;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    dataType = 1;
    requestType = type;
    [thread start];
}

-(void)getData:(NSString *)type parameters:(NSMutableDictionary *)params{
    requestParameters = params;
    dataType = 2;
    requestType = type;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    NSLog(@" 当前线程  %@",[NSThread currentThread]);
    [thread start];
}

-(void) run{
    NSError *error = nil;
    NSMutableString *requestAddress;
    if ([requestType isEqualToString:@"resource"]) {
        requestAddress =    [NSMutableString stringWithString:[Global serviceUrl]];

    }
    else
    {
   requestAddress= [NSMutableString stringWithString:[Global serviceUrl]];
    }
    [requestAddress appendFormat:@"?type=%@",requestType];
    
    if (nil!=requestParameters) {
        for (NSString *key in requestParameters.keyEnumerator)
        {
            NSString *val =[NSString stringWithFormat:@"%@", [requestParameters objectForKey:key]];
            [requestAddress appendFormat:@"&%@=%@",key,[val stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    NSLog(@"%@",requestAddress);
    
    NSString *theData = [NSString stringWithContentsOfURL:[NSURL URLWithString:requestAddress] encoding:NSUTF8StringEncoding error:&error];
//     NSString *theData = [NSString stringWithContentsOfURL:[NSURL URLWithString:requestAddress]];
    if (error!=nil) {
        [self performSelectorOnMainThread:@selector(callbackDidFail:) withObject:error waitUntilDone:YES];
    }else{
        if (dataType==1) {
            [self performSelectorOnMainThread:@selector(callbackStringData:) withObject:theData waitUntilDone:YES];
            
        }else if(dataType==2){
            NSData *jsonStringData = [theData dataUsingEncoding:NSUTF8StringEncoding];
            NSError *parseError = nil;
            
            NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:jsonStringData options:NSJSONReadingMutableContainers error:&parseError];
//          NSJSONReadingMutableContainers
            
            if(nil!=parseError){
                [self performSelectorOnMainThread:@selector(callbackDidFail:) withObject:parseError waitUntilDone:YES];
            }else{
                [self performSelectorOnMainThread:@selector(callbackJsonObject:) withObject:rs waitUntilDone:YES];
            }
        }
    }
}

//-(void)loadData{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//   
//    [manager POST:[Global serverAddress] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [MBProgressHUD hideHUDForView:self.view];
//        
//        NSDictionary *rs = (NSDictionary *)responseObject;
//        //NSLog(@"数据::%@",rs);
//        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
//            
//            NSArray *td= [rs objectForKey:@"result"];
//            SPDetailModel *spModel;
//            NSMutableArray *mulArr =[NSMutableArray array];
//            for (NSDictionary *dict in td) {
//                spModel = [SPDetailModel spDetailModelWithDict:dict];
//                //                if (![spModel.groupId isEqualToString:@"101"])
//                //                {
//                [mulArr addObject:spModel];
//                //                }
//                
//            }
//            if(mode==0)
//            {
//                _datasource = mulArr;
//            }
//            else if (mode==1)//搜索
//            {
//                _searchSource = mulArr;
//                
//            }
//        }
//        [_spDetailTableView.header endRefreshing];
//        [_spDetailTableView.footer endRefreshing];
//        [MBProgressHUD hideHUDForView:self.view];
//        
//        
//        [_spDetailTableView reloadData];
//        //        //设置下次取消下拉刷新
//        //        _isDropRefersh = NO;
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [MBProgressHUD hideHUDForView:self.view];
//        
//        
//        [_spDetailTableView.header endRefreshing];
//        [_spDetailTableView.footer endRefreshing];
//        
//        //        _isDropRefersh = NO;
//    }];
//}


//-(void) run{
//    NSError *error = nil;
//    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
//    [requestAddress appendFormat:@"?type=%@",requestType];
//    
//    if (nil!=requestParameters) {
//        for (NSString *key in requestParameters.keyEnumerator) {
//            NSString *val = [requestParameters objectForKey:key];
//            [requestAddress appendFormat:@"&%@=%@",key,[val stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        }
//    }
//    
//    NSLog(@"%@",requestAddress);
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    [manager POST:[Global serviceUrl] parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//         NSDictionary *rs = (NSDictionary *)responseObject;
//        if (dataType==1) {
//                        [self performSelectorOnMainThread:@selector(callbackStringData:) withObject:rs waitUntilDone:YES];
//            
//                    }else if(dataType==2){
//                      
//                            [self performSelectorOnMainThread:@selector(callbackJsonObject:) withObject:rs waitUntilDone:YES];
//                        }
//                    }
//
//        
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             
//             
//        
//          }];
////    
////    NSString *theData = [NSString stringWithContentsOfURL:[NSURL URLWithString:requestAddress] encoding:NSUTF8StringEncoding error:&error];
////    if (error!=nil) {
////        [self performSelectorOnMainThread:@selector(callbackDidFail:) withObject:error waitUntilDone:YES];
////    }else{
////        if (dataType==1) {
////            [self performSelectorOnMainThread:@selector(callbackStringData:) withObject:theData waitUntilDone:YES];
////            
////        }else if(dataType==2){
////            NSData *jsonStringData = [theData dataUsingEncoding:NSUTF8StringEncoding];
////            NSError *parseError = nil;
////            
////            NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:jsonStringData options:NSJSONReadingMutableContainers error:&parseError];
////          
////            if(nil!=parseError){
////                [self performSelectorOnMainThread:@selector(callbackDidFail:) withObject:parseError waitUntilDone:YES];
////            }else{
////                [self performSelectorOnMainThread:@selector(callbackJsonObject:) withObject:rs waitUntilDone:YES];
////            }
////        }
////    }
//}

-(void)callbackStringData:(NSString *)data{
    if (!killed && self.delegate) {
        [self.delegate serviceCallback:self didFinishReciveStringData:data];
    }
}

-(void)callbackJsonObject:(NSDictionary *)data{
    if (!killed && self.delegate) {
        [self.delegate serviceCallback:self didFinishReciveJsonData:data];
    }
}

-(void)callbackDidFail:(NSError *)error{
    if (!killed && self.delegate) {
        [self.delegate serviceCallback:self requestFaild:error];
    }
}

-(void)kill{
    killed = true;
    if (thread.isExecuting) {
        [thread cancel];
    }
}

@end

