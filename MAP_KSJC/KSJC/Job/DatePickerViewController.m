//
//  DatePickerViewController.m
//  zzzf
//
//  Created by dist on 14-7-16.
//  Copyright (c) 2014年 dist. All rights reserved.
//

#import "DatePickerViewController.h"
#import "MZFormSheetController.h"

@interface DatePickerViewController ()

@end

@implementation DatePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-M-d"];
    if (nil!=self.defaultDateString) {
        NSDate *d = [formatter dateFromString:self.defaultDateString];
        if (d) {
            self.datePicker.date = d;
        }
    }
    self.datePicker.maximumDate = [NSDate date];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnAllright:(id)sender {
    //self.datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-M-d"];
    [self.delegate formDateDidSelected:[formatter stringFromDate:self.datePicker.date]];
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

- (IBAction)btnClear:(id)sender {
    [self.delegate formDateDidSelected:@""];
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

@end
