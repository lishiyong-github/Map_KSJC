//
//  ResourcesView.m
//  zzzf
//
//  Created by mark on 13-11-25.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "ResourcesFileView.h"
#import "OnLineResourceView.h"
#import "ResourcesView.h"
#import "Global.h"


@implementation ResourcesFileView
@synthesize scrView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)load:(NSString*)name andType:(NSString *)type{
    UIImageView  *Image=[[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 72, 72)];
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
    
    [Image setImage:[UIImage imageNamed:imgName]];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 92, 72, 50)];
    //label.backgroundColor=[UIColor blueColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    [label setNumberOfLines:2];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    label.text=name;
    label.font = [label.font fontWithSize:13.0];
    [self addSubview:Image];
    [self addSubview:label];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(event:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)event:(UITapGestureRecognizer *)gesture
{
    if(gesture.view.tag!=1){
        for(UIView *view in gesture.view.subviews){
            
            if ([view isKindOfClass:[UILabel class]]){
                UILabel *label=(UILabel *) view;
                
                NSString *path=[NSString stringWithFormat:@"%@?type=download&path=%@",[Global serviceUrl],[self.owner.owner.path stringByAppendingFormat:@"//%@", label.text]];
                
                NSString * fruits = label.text;
                NSArray  * array= [fruits componentsSeparatedByString:@"."];
                NSString *extension=array.lastObject;
                
                [self.owner.owner openFile:label.text path:path ext:extension];
                
                return;
            }
        }
        
    }
    
    CATransition* transition = [CATransition animation];
    //只执行0.5-0.6之间的动画部分
    //    transition.startProgress = 0.5;
    //    transition.endProgress = 0.6;
    //动画持续时间
    transition.duration = 0.5;
    //进出减缓
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    //动画效果
    transition.type = @"suckUnEffect";
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.owner.owner.resourcesView.layer addAnimation:transition forKey:nil];
    //view之间的切换
    [self.owner.owner.resourcesView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    
    NSLog(@"%d",gesture.view.tag);
    for(UIView *view in gesture.view.subviews){
        
        if ([view isKindOfClass:[UILabel class]]){
            UILabel *label=(UILabel *) view;
            NSString *path=[self.owner.owner.path stringByAppendingFormat:@"//%@", label.text];
            [self.owner.owner load:path andFileName:@""];
            return;
        }
    }
    
//    for(UIView *view in self.superview.subviews)
//    {
//        if(view!=self){
//            [view removeFromSuperview];
//        }
//    }
//    UIView *redview=[[UIView alloc]  initWithFrame:CGRectMake(100, 100, 100, 100)];
//    redview.backgroundColor=[UIColor redColor];
//    [self.superview addSubview:redview];
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
