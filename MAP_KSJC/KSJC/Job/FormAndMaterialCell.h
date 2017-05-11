//
//  MaterialCell.h
//  zzzf
//
//  Created by dist on 13-11-28.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "MaterialGroupInfo.h"
//#import "ProjectFormInfo.h"

@interface FormAndMaterialCell : UITableViewCell{
    NSTimer *_bgTimer;
}

@property (nonatomic,retain) NSMutableDictionary *materialGroup;
@property (nonatomic,retain) NSMutableDictionary *form;
@property (nonatomic,retain) NSString *fileName;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end
