//
//  DailyJobReport.h
//  zzzf
//
//  Created by dist on 13-12-17.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysButton.h"

@protocol DailyJobReportDelegate <NSObject>

-(void)dailyJobReportSave:(NSDictionary *)data;

@end

@interface DailyJobReport : UIView<UIWebViewDelegate>{
    UIWebView *_webView;
    BOOL _webLoaded;
    NSDictionary *_formData;
    NSString *_reportId;
    SysButton *_saveBtn;
}

@property (nonatomic) BOOL editable;
@property (nonatomic,retain) id<DailyJobReportDelegate> delegate;

-(void)showForm:(NSDictionary *)data;


@end
