//
//  StorageItemCell.h
//  zzzf
//
//  Created by dist on 13-11-15.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StorageItemInfo.h"

@protocol StorageItemCellDelegate <NSObject>

-(void)storageShouldClearAt:(int)index;

@end

@interface StorageItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *size;
@property int type;
@property (nonatomic,retain) id<StorageItemCellDelegate> delegate;

- (IBAction)onBtnClearTap:(id)sender;
-(void)setStorageInfo:(StorageItemInfo *)item;

@end
