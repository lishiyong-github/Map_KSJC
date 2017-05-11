//
//  ResourcesView.m
//  zzzf
//
//  Created by mark on 13-11-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "FileItemThumbnailView.h"
#import "Global.h"


@implementation FileItemThumbnailView
@synthesize scrView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)load:(NSString*)name andType:(NSString *)type andFile:(NSString *)filePath{
    UIImageView  *thumbnail=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 80)];
    _name = name;
    _type = type;
    _filePath=filePath;
    thumbnail.contentMode = UIViewContentModeCenter;
    //Image.backgroundColor=[UIColor redColor];
    NSString *imgName=@"";
    self.tag=0;
    if ([type isEqualToString:@""]) {
        imgName=@"filetype-folder72.png";
        self.tag=1;
    }else if([type isEqualToString:@"png"]||[type isEqualToString:@"jpg"]){
        imgName=@"filetype-img72.png";
    }else if([type isEqualToString:@"docx"] || [type isEqualToString:@"doc"]){
        imgName=@"filetype-word72.png";
    }else if([type isEqualToString:@"xlsx"] || [type isEqualToString:@"xls"]){
        imgName=@"filetype-excel72.png";
    }else if([type isEqualToString:@"pptx"] || [type isEqualToString:@"ppt"]){
        imgName=@"filetype-ppt72.png";
    }else{
        imgName=@"filetype-unknow72.png";
    }
    
    [thumbnail setImage:[UIImage imageNamed:imgName]];
    lblFileName=[[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.frame.size.width, self.frame.size.height-80)];
    //label.backgroundColor=[UIColor blueColor];
    lblFileName.textAlignment = NSTextAlignmentCenter;
    
    [lblFileName setNumberOfLines:2];
    lblFileName.lineBreakMode = NSLineBreakByWordWrapping;
    
    lblFileName.text=name;
    lblFileName.font = [lblFileName.font fontWithSize:13.0];
    [self addSubview:thumbnail];
    [self addSubview:lblFileName];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(event:)];
    [self addGestureRecognizer:tapGesture];
    self.layer.cornerRadius = 8;
    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    [self setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1]];
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
    
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:0.6];
    //动画的内容
    [self setBackgroundColor:[UIColor clearColor]];
    //动画结束
    [UIView commitAnimations];
}

- (void)event:(UITapGestureRecognizer *)gesture
{
    [self.delegate allFiles:nil currentFileDidTap:_name type:_type path:_filePath];
    //[self.delegate fileItemDidTap:_name type:_type path:_filePath];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
