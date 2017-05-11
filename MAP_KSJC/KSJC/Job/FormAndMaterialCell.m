//
//  MaterialCell.m
//  zzzf
//
//  Created by dist on 13-11-28.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "FormAndMaterialCell.h"

@implementation FormAndMaterialCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor=[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
    }else{
        self.contentView.backgroundColor= [UIColor whiteColor];
    }
    // Configure the view for the selected state
}

-(void)onTap:(UITapGestureRecognizer *)gesture{
    
}

-(void)setMaterialGroup:(NSMutableDictionary *)materialGroup{
    _materialGroup = materialGroup;
    self.lblName.text = [_materialGroup objectForKey:@"group"];
    NSMutableArray *files = [_materialGroup objectForKey:@"files"];
    if (files.count==0) {
        [_lblName setTextColor:[UIColor grayColor]];
    }else{
        [_lblName setTextColor:[UIColor colorWithRed:33.0/255.0 green:152.0/255.0 blue:58.0/255.0 alpha:1]];
    }
}

-(void)setForm:(NSMutableDictionary *)form{
    _form = form;
    self.lblName.text = [_form objectForKey:@"name"];
    
    if ([_form objectForKey:@"isSelected"]) {
        [self.contentView setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:100]];
        self.contentView.layer.shadowColor = [UIColor grayColor].CGColor;
        self.contentView.layer.shadowOpacity = 1.0;
        self.contentView.layer.shadowRadius = 2.0;
        self.contentView.layer.shadowOffset = CGSizeMake(0,1);
        self.contentView.clipsToBounds = NO;
    }else{
        [self.contentView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:100]];
        self.contentView.layer.shadowColor = nil;
        self.contentView.layer.shadowOpacity = 0;
        self.contentView.layer.shadowRadius = 0;
        self.contentView.layer.shadowOffset = CGSizeMake(0,0);
        self.contentView.clipsToBounds = YES;
    }
}

-(void)setFileName:(NSString *)fileName{
    _fileName = fileName;
    self.lblName.text = fileName;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    //if (nil!=_form && _form.isSelected) {
    //    return;
    //}
    if (self.selected) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.contentView.backgroundColor=[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1];
    [UIView commitAnimations];
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
    //if (nil!=_form && _form.isSelected) {
    //    return;
    //}
    if (self.selected) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:0.6];
    //动画的内容
    self.contentView.backgroundColor=[UIColor whiteColor];
    //动画结束
    [UIView commitAnimations];
}


@end
