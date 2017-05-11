//
//  StopWorkFormView2.h
//  zzzf
//
//  Created by dist on 14-3-21.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SysButton.h"
#import "GPS.h"

@protocol StopWorkFormDelegate2 <NSObject>

-(void)stopWorkShouldFormSave:(NSMutableDictionary *)formData json:(NSString *) json location:(NSString *)location newForm:(BOOL)newForm;
@optional
-(void)stopWorkFormDidClose;
-(NSMutableDictionary *)stopWorkNewFormParameters;
@end

@interface StopWorkFormView2 : UIView<UIWebViewDelegate,GPSDelegate>
{
    BOOL _initialized;
    BOOL _webLoaded;
    BOOL _isNewForm;
    NSDictionary *_formData;
    NSString *_formId;
    NSString *_locationString;
    CLLocationCoordinate2D _location;
    GPS *_gpsLoader;
    NSArray *_flowButtons;
    SysButton *_currentFlowButton;
    BOOL _editModel;
}

@property (nonatomic) int currentFlow;
- (IBAction)onFlowBtnTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *flowView;
@property (weak, nonatomic) IBOutlet UIButton *btnFlow5;
@property (weak, nonatomic) IBOutlet UIButton *btnFlow4;
@property (weak, nonatomic) IBOutlet UIButton *btnFlow2;
@property (weak, nonatomic) IBOutlet UIButton *btnFlow1;
@property (weak, nonatomic) IBOutlet UIButton *btnFlow3;
- (IBAction)onBtnGobakTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIWebView *formWebView;
@property (nonatomic) BOOL editable;
@property (nonatomic,retain) id<StopWorkFormDelegate2> delegate;
@property (weak, nonatomic) IBOutlet SysButton *btnSave;
@property (weak, nonatomic) IBOutlet SysButton *btnGoBack;
@property (nonatomic,strong) NSMutableArray *forms;
@property (nonatomic) BOOL phFlowViewVisible;

- (IBAction)onBtnCloseTap:(id)sender;
- (IBAction)onBtnSaveTap:(id)sender;

-(void)initializeView;
-(void)newForm;
-(void)showForm:(NSString *)formId formData:(NSDictionary *)formData;
-(NSString *)formId;

@end



