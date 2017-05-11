//
//  JobDetailView+StopworkFrom.m
//  zzzf
//
//  Created by dist on 14-4-3.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "JobDetailView+StopworkFrom.h"


@implementation JobDetailView (StopworkFrom)

-(void)showStopworkForm{
    if (self.btnStopwork.selected) {
        self.btnStopwork.selected = NO;
        _stopworkFormView.hidden = YES;
    }else{
        if (nil==_stopworkFormView) {
            NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"StopWorkFormView2" owner:nil options:nil];
            _stopworkFormView = [nibView objectAtIndex:0];
            _stopworkFormView.delegate=self;
            _stopworkFormView.hidden = YES;
            _stopworkFormView.editable = YES;
            _stopworkFormView.editable = !_readonly;
            [_stopworkFormView initializeView];
            if (_readonly) {
                if ([[Global currentUser].org isEqualToString:@"局领导"]) {
                    _stopworkFormView.frame=CGRectMake(0, 100, self.frame.size.width, self.frame.size.height-100);
                }else{
                    _stopworkFormView.frame=CGRectMake(0, 100, self.frame.size.width, self.frame.size.height-160);
                }
            }else{
                _stopworkFormView.frame=CGRectMake(0, 100, 732, 615);
            }
            //NSLog(@"%f,%f",self.frame.size.width,self.frame.size.height);
            [self addSubview:_stopworkFormView];
        }
        if (!_formDataInitialized) {
            if ([_type isEqualToString:@"Phxm"]) {
                _stopworkFormView.phFlowViewVisible = YES;
                _stopworkFormView.forms = [_project objectForKey:PROJECTKEY_STOPWORKFORMS];
                if (_readonly) {
                    _stopworkFormView.currentFlow = -1;
                }else{
                    _stopworkFormView.currentFlow = _phFlowState;
                }
            }else{
                _stopworkFormView.phFlowViewVisible = NO;
                NSMutableArray *stopworkforms = [_project objectForKey:PROJECTKEY_STOPWORKFORMS];
                if (stopworkforms.count>0) {
                    NSMutableDictionary *formInfo = [stopworkforms objectAtIndex:0];
                    [_stopworkFormView showForm:[formInfo objectForKey:@"code"] formData:[formInfo objectForKey:@"content"]];
                }else{
                    [_stopworkFormView newForm];
                }
            }
            _formDataInitialized = YES;
        }
        self.btnLocation.selected = NO;
        self.btnPhotos.selected = NO;
        self.btnStopwork.selected = YES;
        _stopworkFormView.hidden = NO;
//        _mapLocationView.hidden = YES;
        self.photoView.hidden = YES;
        
    }
}

-(void)clearStopworkForm{
    //_stopworkFormView停工单2
    if (nil!=_stopworkFormView) {
        [_stopworkFormView newForm];
    }
    _formDataInitialized = NO;
}

//隐藏停工单
-(void)hideStopworkForm{
    if (nil!=_stopworkFormView) {
        _stopworkFormView.hidden = YES;
    }
    self.btnStopwork.selected = NO;
}
-(void)hideMapForm{
//    if (nil!=_mapLocationView) {
//        _mapLocationView.hidden = YES;
//    }
    self.btnLocation.selected = NO;
}

-(void)stopWorkFormDidClose{
    self.btnStopwork.selected = NO;
}

NSMutableDictionary *_newFormData;

-(void)stopWorkShouldFormSave:(NSMutableDictionary *)formData json:(NSString *)json location:(NSString *)location newForm:(BOOL)newForm{
    [Global wait:@"正在保存"];
    _newFormData = formData;
    DataPostman *postman = [[DataPostman alloc] init];
    postman.tag = 2;
    NSMutableDictionary *postdata = [NSMutableDictionary dictionaryWithCapacity:6];
    [postdata setObject:[_project objectForKey:PROJECTKEY_ID] forKey:@"project"];
    [postdata setObject:location forKey:@"location"];
    [postdata setObject:@"zf" forKey:@"type"];
    [postdata setObject:@"savestopworkform" forKey:@"action"];
    [postdata setObject:_stopworkFormView.formId forKey:@"code"];
    NSString *deviceNum = [Global currentUser].deviceNumber;
    if (nil==deviceNum) {
        deviceNum=@"";
    }
    [postdata setObject:deviceNum forKey:@"device"];
    [postdata setObject:[NSString stringWithFormat:@"%d",_phFlowState] forKey:@"flow"];
    [postdata setObject:json forKey:@"json"];
    [postdata setObject:(newForm?@"yes":@"no") forKey:@"newform"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [postdata setObject:[df stringFromDate:[NSDate date]] forKey:@"time"];
    
    [postman postDataWithUrl:[Global serviceUrl] data:postdata delegate:self];
}

-(void)stopworkfromRequestFailed:(ASIHTTPRequest *)request{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    [Global wait:nil];
}

-(void)stopworkfromRequestFinished:(ASIHTTPRequest *)request{
    [Global wait:nil];
    if (request.responseStatusCode==200) {
        NSError *parseError = nil;
        NSString *responseString = request.responseString;
        NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&parseError];
        if(nil!=parseError){
            [self stopworkfromRequestFailed:nil];
        }else if([[rs objectForKey:@"success"] isEqualToString:@"false"]){
            [self stopworkfromRequestFailed:nil];
            NSLog(@"stopwork failed:%@",[rs objectForKey:@"message"]);
        }else{
            NSMutableDictionary *result = [rs objectForKey:@"result"];
            NSString *num = [result objectForKey:@"num"];
            NSString *code = [result objectForKey:@"code"];
            
            //写回到缓存数据
            NSMutableArray *stopworkfroms = [_project objectForKey:PROJECTKEY_STOPWORKFORMS];
            if (nil==num) {
                if ([_type isEqualToString:@"Phxm"]) {
                    for (NSMutableDictionary *nd in stopworkfroms) {
                        int theFlow = [[nd objectForKey:@"flow"] intValue];
                        if (theFlow == _phFlowState) {
                            [nd setObject:_newFormData forKey:@"content"];
                            break;
                        }
                    }
                }else{
                    NSMutableDictionary *nd=[stopworkfroms objectAtIndex:0];
                    [nd setObject:_newFormData forKey:@"content"];
                }
            }else{
                //如果是新停工单，则提取新单号，并显示
                [_newFormData setObject:num forKey:@"number"];
                [_newFormData setObject:code forKey:@"code"];
                NSMutableDictionary *fd = [NSMutableDictionary dictionaryWithCapacity:10];
                [fd setObject:_stopworkFormView.formId forKey:@"code"];
                [fd setObject:code forKey:@"name"];
                [fd setObject:[_project objectForKey:PROJECTKEY_ID] forKey:@"project"];
                [fd setObject:_newFormData forKey:@"content"];
                [fd setObject:[NSString stringWithFormat:@"%d",_phFlowState] forKey:@"flow"];
                [stopworkfroms addObject:fd];
                [_stopworkFormView showForm:_stopworkFormView.formId formData:_newFormData];
            }
            [self saveProjectToDisk];
        }
    }else{
        [self stopworkfromRequestFailed:nil];
    }
}

-(NSMutableDictionary *)stopWorkNewFormParameters{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:[_project objectForKey:@"org"],@"org",[_project objectForKey:@"address"],@"address",[_project objectForKey:@"name"],@"name", nil];
}

@end
