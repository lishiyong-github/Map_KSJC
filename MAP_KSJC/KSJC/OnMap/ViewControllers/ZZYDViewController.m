//
//  ZZYDViewController.m
//  zzzf
//
//  Created by mark on 14-3-7.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "ZZYDViewController.h"
#import "SysButton.h"

@implementation ZZYDViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    webViewZZYD = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    webViewZZYD.delegate = self;
    webViewZZYD.hidden = YES;
    [self.view addSubview:webViewZZYD];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://218.75.221.182:801/mobile"]];
    [webViewZZYD loadRequest:request];
    
    webWaitView = [[UIView alloc] initWithFrame:CGRectMake(450, 350, 200, 30)];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(10, 10, 32, 32);
    activityView.color = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1];
    [activityView startAnimating];
    
    UILabel *lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, 150, 30)];
    lblMessage.text=@"正在连接到业务办公系统";
    [lblMessage setFont:[lblMessage.font fontWithSize:13]];
    lblMessage.textColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1];
    
    [webWaitView addSubview:activityView];
    [webWaitView addSubview:lblMessage];
    
    [self.view addSubview:webWaitView];
    
    SysButton *goBackButton = [SysButton buttonWithType:UIButtonTypeCustom];
    [goBackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    goBackButton.frame = CGRectMake(980, 10, 40, 40);
    //[goBackButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [goBackButton setTitle:@"返回" forState:UIControlStateNormal];
    [goBackButton.titleLabel setFont:[goBackButton.titleLabel.font fontWithSize:16]];
    goBackButton.layer.cornerRadius = 20;
    goBackButton.backgroundColor = [UIColor colorWithRed:22.0/255.0 green:128.0/255.0 blue:67.0/255.0 alpha:1];
    [self.view addSubview:goBackButton];
    
    [goBackButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
}

-(void)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *requestString = [[request URL] absoluteString];
    NSRange range=[requestString rangeOfString:@"goBackIOS"];
    if (range.location!=NSNotFound) {
        [self dismissViewControllerAnimated:YES completion:^{}];
        return  NO;
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    webWaitView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    webWaitView.hidden = YES;
    webViewZZYD.hidden = NO;
    NSString *pwd=[Global currentUser].password;
    if (!pwd) {
        pwd=@"";
    }
    NSString *js=[NSString stringWithFormat:@"window.login('%@','%@')",[Global currentUser].username,pwd];
    [webViewZZYD stringByEvaluatingJavaScriptFromString:js];
    [webViewZZYD stringByEvaluatingJavaScriptFromString:@"window.fromIOS()"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"提示" message:@"不能连接到业务办公系统" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [msg show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
