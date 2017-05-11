//
//  StopWorkFormView2.m
//  zzzf
//
//  Created by dist on 14-3-21.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "StopWorkFormView2.h"
#import "Global.h"
#import "GPS.h"

@implementation StopWorkFormView2

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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"StopWorkForm2" ofType:@"htm"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    self.formWebView.delegate = self;
    [self.formWebView loadRequest:request];
    
    self.btnFlow1.layer.cornerRadius = 8;
    self.btnFlow2.layer.cornerRadius = 8;
    self.btnFlow3.layer.cornerRadius = 8;
    self.btnFlow4.layer.cornerRadius = 8;
    self.btnFlow5.layer.cornerRadius = 8;
    _flowButtons = [NSArray arrayWithObjects:self.btnFlow1,self.btnFlow2,self.btnFlow3,self.btnFlow4,self.btnFlow5, nil];
}

-(void)showForm:(NSString *)formId formData:(NSDictionary *)formData{
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
    return [self doReplaceJson:value];
}

-(NSString *)doReplaceJson:(NSString *)s{
    return [s stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

-(void)setEditable:(BOOL)editable{
    _editable = editable;
    [self setControlEditModel:_editable];
}

-(void)setControlEditModel:(BOOL)editable{
    _editModel = editable;
    self.btnSave.hidden = !_editModel;
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
    [self.formWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.setEditable(%@)",_editModel?@"true":@"false"]];
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
        NSMutableDictionary *ps = [self.delegate stopWorkNewFormParameters];
        NSString *script = [NSString stringWithFormat: @"window.setData({number:'',code:'',dwgr:'%@',address:'%@',gc:'%@',event:'',quxian:'',dsr:'',jbr:'',dianhua:'',dizhi:'',day:'%@'})",[self doReplaceJson:[ps objectForKey:@"org"]],[self doReplaceJson:[ps objectForKey:@"address"]],[self doReplaceJson:[ps objectForKey:@"name"]],strDate];
        [self.formWebView stringByEvaluatingJavaScriptFromString:script];
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
    [self.delegate stopWorkShouldFormSave:mrs json:newJson location:_locationString newForm:_isNewForm];
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

-(void)setCurrentFlow:(int)currentFlow{
    _currentFlow = currentFlow;
    if (_currentFlow==-1) {
        for (int i=0; i<_flowButtons.count; i++) {
            SysButton *btn = (SysButton *)[_flowButtons objectAtIndex:i];
            if (!btn.hidden) {
                [self showFlowForm:btn.tag];
                break;
            }
        }
    }else{
        for (int i=0; i<_flowButtons.count; i++) {
            SysButton *btn = (SysButton *)[_flowButtons objectAtIndex:i];
            if (i==_currentFlow) {
                btn.hidden = NO;
                break;
            }
        }
        [self showFlowForm:_currentFlow];
    }
}

-(void)setForms:(NSMutableArray *)forms{
    _forms = forms;
    if (nil!=_forms) {
        for (int i=0; i<_flowButtons.count; i++) {
            SysButton *btn = (SysButton *)[_flowButtons objectAtIndex:i];
            BOOL haveForm = NO;
            for (int j=0; j<_forms.count; j++) {
                NSMutableDictionary *theForm = [_forms objectAtIndex:j];
                int formFlow = [[theForm objectForKey:@"flow"] intValue];
                if (formFlow == btn.tag) {
                    haveForm=YES;
                    break;
                }
            }
            btn.hidden = !haveForm;
        }
    }
}

-(void)setPhFlowViewVisible:(BOOL)phFlowViewVisible{
    _phFlowViewVisible = phFlowViewVisible;
    self.flowView.hidden = !_phFlowViewVisible;
}

-(void)showFlowForm:(int)flow{
    if (_currentFlowButton) {
        _currentFlowButton.selected = NO;
    }
    SysButton *btn = (SysButton *)[_flowButtons objectAtIndex:flow];
    _currentFlowButton = btn;
    btn.selected = YES;
    if (btn.enabled) {
        if (self.editable) {
            [self setControlEditModel:flow==_currentFlow];
        }
        BOOL haveForm = NO;
        for (int i=0; i<_forms.count; i++) {
            NSMutableDictionary *theForm = [_forms objectAtIndex:i];
            int formFlow = [[theForm objectForKey:@"flow"] intValue];
            if (formFlow == flow) {
                [self showForm:[theForm objectForKey:@"code"] formData:[theForm objectForKey:@"content"]];
                haveForm = YES;
                break;
            }
        }
        if (!haveForm) {
            [self newForm];
        }
    }
}

- (IBAction)onFlowBtnTap:(id)sender {
    SysButton *target = (SysButton *)sender;
    if (target == _currentFlowButton) {
        return;
    }
    [self showFlowForm:target.tag];
}

@end