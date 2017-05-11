//
//  DailyJobReport.m
//  zzzf
//
//  Created by dist on 13-12-17.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "DailyJobReport.h"

#import "Global.h"

@implementation DailyJobReport

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
    }
    return self;
}

-(void)createSubViews{
    self.backgroundColor = [UIColor whiteColor];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, self.frame.size.height-50)];
    _webView.backgroundColor = [UIColor whiteColor];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 48)];
    titleView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    [self addSubview:titleView];
    
    [self addSubview:_webView];
    _editable = YES;
    _saveBtn = [SysButton buttonWithType:UIButtonTypeCustom];
    _saveBtn.frame = CGRectMake(867, 6, 52, 35);
    [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    _saveBtn.titleLabel.font = [_saveBtn.titleLabel.font fontWithSize:14];
    [_saveBtn setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(onBtnSaveTap) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveBtn];
    
    SysButton *backButton = [SysButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(940, 6, 52, 35);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBtnBackTap) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [backButton.titleLabel.font fontWithSize:14];
    [backButton setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    [self addSubview:backButton];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dailyJobForm" ofType:@"htm"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    _webView.delegate = self;
    [_webView loadRequest:request];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.frame.size.width, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];

}

-(void)setEditable:(BOOL)editable{
    _editable = editable;
    _saveBtn.hidden = !_editable;
    if (_webLoaded) {
        [self setWebFormEditable];
    }
}

-(void)setWebFormEditable{
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.setEditable(%@)",self.editable?@"true":@"false"]];
}

-(void)showForm:(NSDictionary *)data{
    _formData = data;
    _reportId = [data objectForKey:@"id"];
    if (nil==_reportId) {
        _reportId = [Global newUuid];
    }
    if (_webLoaded) {
        [self setWebFormData];
    }
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    _webLoaded = YES;
    [self setWebFormEditable];
    [self setWebFormData];
}

-(void)setWebFormData{
    if (nil!=_formData) {
        NSMutableString *script = [[NSMutableString alloc] initWithCapacity:100];
        [script appendFormat:@"window.setData({txt1:\"%@\",txt2:\"%@\",txt3:\"%@\",txt4:\"%@\",txt5:\"%@\",txt6:\"%@\",txt7:\"%@\"})",[self replaceJson: @"txt1"],[self replaceJson: @"txt2"],[self replaceJson: @"txt3"],[self replaceJson: @"txt4"],[self replaceJson: @"txt5"],[self replaceJson: @"txt6"],[self replaceJson:@"txt7"]];
        [_webView stringByEvaluatingJavaScriptFromString:script];
    }
}

-(NSString *)replaceJson:(NSString *)key{
    NSString *val = [_formData objectForKey:key];
    if (nil==val) {
        return @"";
    }
    return [val stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

-(void)onBtnSaveTap{
    [_webView stringByEvaluatingJavaScriptFromString:@"window.save()"];
}

-(void)onBtnBackTap{
    self.hidden = YES;
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
    
    NSData *jsonStringData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *parseError = nil;
    NSDictionary *rs = [NSJSONSerialization JSONObjectWithData:jsonStringData options:kNilOptions error:&parseError];
    NSMutableDictionary *mrs = [NSMutableDictionary dictionaryWithDictionary:rs];
    [mrs setValue:_reportId forKey:@"id"];
    [self.delegate dailyJobReportSave:mrs];
    
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
