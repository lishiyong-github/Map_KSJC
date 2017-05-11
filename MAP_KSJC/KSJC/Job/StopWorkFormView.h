//
//  StopWorkFormView.h
//  zzzf
//
//  Created by dist on 13-11-30.
//  Copyright (c) 2013年 dist. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SysButton.h"
#import "GPS.h"

@protocol StopWorkFormDelegate <NSObject>

-(void)stopWorkShouldFormSave:(NSMutableDictionary *)formData json:(NSString *) json location:(NSString *)location newForm:(BOOL)newForm;
@optional
-(void)stopWorkFormDidClose;
@end


@interface StopWorkFormView : UIView<UIWebViewDelegate,GPSDelegate>
{
    BOOL _initialized;
    BOOL _webLoaded;
    BOOL _isNewForm;
    NSMutableDictionary *_formData;
    NSString *_formId;
    NSString *_locationString;
    CLLocationCoordinate2D _location;
    GPS *_gpsLoader;
}
- (IBAction)onBtnGobakTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIWebView *formWebView;
@property (nonatomic) BOOL editable;
@property (nonatomic,retain) id<StopWorkFormDelegate> delegate;
@property (weak, nonatomic) IBOutlet SysButton *btnSave;
@property (weak, nonatomic) IBOutlet SysButton *btnGoBack;
@property (weak, nonatomic) IBOutlet UITextView *txtFormName;
@property (nonatomic,retain) NSString *jobId;
- (IBAction)onBtnCloseTap:(id)sender;
- (IBAction)onBtnSaveTap:(id)sender;

-(void)initializeView;
-(void)newForm;
-(void)showForm:(NSString *)formId formData:(NSDictionary *)formData;
-(NSString *)formId;

@end
