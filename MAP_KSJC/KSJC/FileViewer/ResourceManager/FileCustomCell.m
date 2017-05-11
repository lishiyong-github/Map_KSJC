//
//  FileCustomCell.m
//  zzzf
//
//  Created by mark on 13-11-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "FileCustomCell.h"

@implementation FileCustomCell

@synthesize strImgFileName;
@synthesize FileName;
@synthesize FileLength;
@synthesize FileDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSLog(@"111");
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    //[super setSelected:selected animated:animated];
//    if (selected) {
//        self.backgroundColor=[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
//    }else{
//        self.backgroundColor=[UIColor whiteColor];
//    }
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.backgroundColor = [UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
    self.selectedBackgroundView = view;
    [super setSelected:selected animated:animated];
}


- (BOOL)canBecomeFirstResponder{
    return YES;
}

//-(void)setCompany:(NSString *)cp{
//    if (![cp isEqualToString:company]) {
//        company = [cp copy];
//        self.lblCompany.text = company;
//    }
//}

-(void)setStrImgFileName:(NSString *)IFName
{
    NSString *strImgUrl=@"";
    if (![IFName isEqualToString:strImgFileName]) {
        strImgFileName=[IFName copy];
        if ([strImgFileName isEqualToString:@""]) {
            strImgUrl=@"filetype-folder48.png";
        }else if([strImgFileName isEqualToString:@"png"]||[strImgFileName isEqualToString:@"jpg"]){
            strImgUrl=@"filetype-img48.png";
        }else if([strImgFileName isEqualToString:@"docx"] || [strImgFileName isEqualToString:@"doc"]){
            strImgUrl=@"filetype-word48.png";
        }else if([strImgFileName isEqualToString:@"xlsx"] || [strImgFileName isEqualToString:@"xls"]){
            strImgUrl=@"filetype-excel48.png";
        }else if([strImgFileName isEqualToString:@"pptx"] || [strImgFileName isEqualToString:@"ppt"]){
            strImgUrl=@"filetype-ppt48.png";
        }else{
            strImgUrl=@"filetype-unknow48.png";
        }
        [self.imgUrl setImage:[UIImage imageNamed:strImgUrl]];
    }
}

-(void)setFileName:(NSString *)FName{
    if (![FName isEqualToString:FileName]) {
        FileName=[FName copy];
        self.lblFileName.text=FileName;
    }
}

-(void)setFileLength:(NSString *)FLength{
    if (![FLength isEqualToString:FileLength]) {
        FileLength=[FLength copy];
        self.lblFileLength.text=FileLength;
    }
}

-(void)setFileDate:(NSString *)FDate{
    if (![FDate isEqualToString:FileDate]) {
        FileDate=[FDate copy];
        self.lblFileDate.text=FileDate;
    }
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"began");
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"end");
//}
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"moved");
//}

@end
