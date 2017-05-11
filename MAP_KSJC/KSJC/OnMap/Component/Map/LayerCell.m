//
//  LayerCell.m
//  zzOneMap
//
//  Created by zhangliang on 13-12-5.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "LayerCell.h"

@implementation LayerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundView.alpha=0;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [ super initWithCoder:aDecoder];
    if (self) {
        UIView *tempView = [[UIView alloc] init];
        [self setBackgroundView:tempView];
        [self setBackgroundColor:[UIColor clearColor]];
        self.backgroundView.alpha = 0;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //self.layer.cornerRadius = 10;
        self.contentView.layer.cornerRadius = 10;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setAttributes:(NSDictionary *)attributes{
    _attributes = attributes;
    self.layerNameLabel.text = [_attributes objectForKey:@"name"];
    if ([[_attributes objectForKey:@"visible"] isEqualToString:@"yes"]) {
        self.visibleIcon.image = [UIImage imageNamed:@"icon-selected"];
    }else{
        self.visibleIcon.image = nil;
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
 
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.contentView.backgroundColor=[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
    [UIView commitAnimations];
    if ([[_attributes objectForKey:@"visible"] isEqualToString:@"yes"]) {
        [_attributes setValue:@"no" forKey:@"visible"];
        self.visibleIcon.image = nil;
    }else{
        [_attributes setValue:@"yes" forKey:@"visible"];
        self.visibleIcon.image = [UIImage imageNamed:@"icon-selected"];
    }

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self clearBg];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self clearBg];
}

-(void)clearBg{

    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:0.6];
    //动画的内容
    self.contentView.backgroundColor=[UIColor clearColor];
    //动画结束
    [UIView commitAnimations];
}



@end
