//
//  StorageItemCell.m
//  zzzf
//
//  Created by dist on 13-11-15.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "StorageItemCell.h"

@implementation StorageItemCell

- (IBAction)onBtnClearTap:(id)sender {
    [self.delegate storageShouldClearAt:self.type];
}

-(void)setStorageInfo:(StorageItemInfo *)item{
    self.title.text = item.title;
    self.size.text = [item sizeString];
    self.type = item.iconIndex;
}
-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    if (selected) {
        self.backgroundColor=[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
        [self.title setTextColor:[UIColor whiteColor]];
        [self.size setTextColor:[UIColor whiteColor]];
    }else{
        self.backgroundColor=[UIColor whiteColor];
        [self.title setTextColor:[UIColor blackColor]];
        [self.size setTextColor:[UIColor blackColor]];
    }
}
- (BOOL)canBecomeFirstResponder{
    return YES;
}
@end
