//
//  StopWorkFormView.m
//  zzzf
//
//  Created by dist on 13-11-30.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "StopWorkFormView.h"
#import "Global.h"
#import "GPS.h"
#import "DataPostman.h"
@interface StopWorkFormView ()<ASIHTTPRequestDelegate>

@end

@implementation StopWorkFormView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)onBtnCloseTap:(id)sender {
    self.hidden=YES;
}

-(void)initializeView{
    if(_initialized){
        return;
    }
    _initialized = YES;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"StopWorkForm" ofType:@"htm"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    self.formWebView.delegate = self;
    [self.formWebView loadRequest:request];
    
}

-(void)showForm:(NSString *)formId formData:(NSMutableDictionary *)formData{
    _formData = formData;
    _isNewForm = NO;
    _formId = formId;
    if (_webLoaded) {
        [self setWebFormData];
    }
}

-(void)newForm{
    _formId = [Global newUuid];
    _isNewForm = YES;
    _formData = nil;
    if (_webLoaded) {
        [self setWebFormData];
    }
}

-(NSString *)formId{
    return _formId;
}

-(NSString *)replaceJson:(NSString *)key{
    NSString *value = [_formData objectForKey:key];
    if (nil==value) {
        return @"";
    }
    return [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

-(void)setEditable:(BOOL)editable{
    _editable = editable;
    self.btnSave.hidden = !editable;
    if (_webLoaded) {
        [self setWebFormEnable];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    _webLoaded = YES;
    [self setWebFormEnable];
    [self setWebFormData];
}

-(void)setWebFormEnable{
    [self.formWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.setEditable(%@)",self.editable?@"true":@"false"]];
}

-(void)setWebFormData{
    if (nil!=_formData) {
        NSString *script = [NSString stringWithFormat:@"window.setData(%@)", [self renderJsonFromData]];
        _locationString = [_formData objectForKey:@"location"];
        _gpsLoader = nil;
        [self.formWebView stringByEvaluatingJavaScriptFromString:script];
    }else{
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *strDate=[df stringFromDate:[NSDate date]];
        _gpsLoader = [[GPS alloc] init];
        _gpsLoader.delegate = self;
        [_gpsLoader startGPS];
        [self.formWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"window.setData({number:'',code:'',dwgr:'',address:'',gc:'',event:'',quxian:'',dsr:'',jbr:'',dianhua:'',dizhi:'',day:'%@'})",strDate]];
        
    }
}

-(NSString *)renderJsonFromData{
    NSMutableString *script = [[NSMutableString alloc] initWithCapacity:100];
    [script appendFormat:@"{\"number\":\"%@\",\"code\":\"%@\",\"dwgr\":\"%@\",\"address\":\"%@\",\"gc\":\"%@\",\"event\":\"%@\",\"quxian\":\"%@\",\"dsr\":\"%@\",\"jbr\":\"%@\",\"dianhua\":\"%@\",\"dizhi\":\"%@\",\"day\":\"%@\"}",[self replaceJson: @"number"],[self replaceJson: @"code"],[self replaceJson: @"dwgr"],[self replaceJson: @"address"],[self replaceJson:@"gc"],[self replaceJson: @"event"],[self replaceJson:@"quxian"],[self replaceJson: @"dsr"],[self replaceJson: @"jbr"],[self replaceJson: @"dianhua"],[self replaceJson: @"dizhi"],[self replaceJson: @"day"]];
    return script;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *requestString = [[request URL] absoluteString];
    NSArray *commandInfo=[requestString componentsSeparatedByString:@":::"];
    if(commandInfo !=nil &&[commandInfo count]>1){
        NSLog(@"get commands-->%@",requestString);
        NSString *commandFlag = [commandInfo objectAtIndex:0];
        if ([commandFlag isEqualToString:@"command"]) {
            for (int i=1;i<commandInfo.count;i++) {
                NSArray *commandArguments = [[commandInfo objectAtIndex:i] componentsSeparatedByString:@"::"];
                NSString *commandName = [commandArguments objectAtIndex:0];
                if([commandName isEqualToString:@"save"]){
                    [self save:[[commandArguments objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }
        return NO;
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
    
}

-(void)save:(NSString *)json{
    //StopWrokForm *theFormData = [[StopWrokForm alloc] init];
    
    NSData *jsonStringData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *parseError = nil;
    NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:jsonStringData options:kNilOptions error:&parseError];
    NSMutableDictionary *mrs = [NSMutableDictionary dictionaryWithDictionary:rs];
    [mrs setValue:_formId forKey:@"id"];
    
    if (nil!=_gpsLoader) {
        _locationString = [NSString stringWithFormat:@"%f,%f",_location.longitude,_location.latitude];
        [mrs setValue:_locationString forKey:@"location"];
    }
    if (nil==_locationString) {
        _locationString=@"";
    }
    _formData = mrs;
    NSString *newJson = [self renderJsonFromData];
    //theFormData.name = formName;
    
    DataPostman *postman = [[DataPostman alloc] init];
    NSMutableDictionary *postdata = [NSMutableDictionary dictionaryWithCapacity:10];
    [postdata setObject:_locationString forKey:@"location"];
    [postdata setObject:@"zf" forKey:@"type"];
    [postdata setObject:@"savestopworkform" forKey:@"action"];
    [postdata setObject:self.jobId forKey:@"jobid"];
    [postdata setObject:_formId forKey:@"code"];
    NSString *deviceNum = [Global currentUser].deviceNumber;
    if (nil==deviceNum) {
        deviceNum=@"";
    }
    [postdata setObject:deviceNum forKey:@"device"];
    [postdata setObject:@"0" forKey:@"flow"];
    [postdata setObject:newJson forKey:@"json"];
    [postdata setObject:(_isNewForm?@"yes":@"no") forKey:@"newform"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [postdata setObject:[df stringFromDate:[NSDate date]] forKey:@"time"];
    [postdata setObject:@"yes" forKey:@"isDaily"];
    
    [Global wait:@"正在保存..."];
    [postman postDataWithUrl:[Global serviceUrl] data:postdata delegate:self];
    
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    [Global wait:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)requestFinished:(ASIHTTPRequest *)request{

    [Global wait:nil];
    if (request.responseStatusCode==200) {
        NSError *parseError = nil;
        NSString *responseString = request.responseString;
        NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&parseError];
        if(nil!=parseError){
            [self requestFailed:nil];
        }else if([[rs objectForKey:@"success"] isEqualToString:@"false"]){
            [self requestFailed:nil];
            NSLog(@"stopwork failed:%@",[rs objectForKey:@"message"]);
        }else{
            NSMutableDictionary *result = [rs objectForKey:@"result"];
            NSString *num = [result objectForKey:@"num"];
            NSString *code = [result objectForKey:@"code"];
            
            if (_isNewForm) {
                [_formData setObject:num forKey:@"number"];
                [_formData setObject:code forKey:@"code"];
                [_formData setObject:code forKey:@"name"];
                //如果是新停工单则需要重新加载页面;
                [self showForm:_formId formData:_formData];
            }
            [self.delegate stopWorkShouldFormSave:_formData json:nil location:_locationString newForm:_isNewForm];
            
        }
    }else{
        [self requestFailed:nil];
    }
}

- (IBAction)onBtnSaveTap:(id)sender {
    [self.formWebView stringByEvaluatingJavaScriptFromString:@"window.save()"];
}

-(void)gpsDidReaded:(CLLocationCoordinate2D)location{
    _location = location;
}

- (IBAction)onBtnGobakTap:(id)sender {
    self.hidden = YES;
    [self.delegate stopWorkFormDidClose];
}


@end
