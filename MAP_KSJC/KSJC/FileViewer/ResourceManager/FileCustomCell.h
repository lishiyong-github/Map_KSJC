//
//  FileCustomCell.h
//  zzzf
//
//  Created by mark on 13-11-29.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgUrl;

@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileLength;
@property (weak, nonatomic) IBOutlet UILabel *lblFileDate;

@property (copy, nonatomic) NSString *strImgFileName;
@property (copy, nonatomic) NSString *FileName;
@property (copy, nonatomic) NSString *FileLength;
@property (copy, nonatomic) NSString *FileDate;

@end
