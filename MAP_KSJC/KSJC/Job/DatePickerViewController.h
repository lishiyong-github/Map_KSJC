//
//  DatePickerViewController.h
//  zzzf
//
//  Created by dist on 14-7-16.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FormDatePickerDelegate <NSObject>

-(void)formDateDidSelected:(NSString *)date;

@end

@interface DatePickerViewController : UIViewController
- (IBAction)btnAllright:(id)sender;

- (IBAction)btnClear:(id)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,retain) id<FormDatePickerDelegate> delegate;
@property (nonatomic,retain) NSString *defaultDateString;

@end
