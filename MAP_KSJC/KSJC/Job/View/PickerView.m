//
//  PickerView.m
//  KSJC
//
//  Created by 叶松丹 on 2017/3/6.
//  Copyright © 2017年 dist. All rights reserved.
//

#import "PickerView.h"
#import "SysButton.h"
#import "AFHTTPRequestOperationManager.h"
#import "Global.h"
#import "MBProgressHUD+MJ.h"
#import "TypeList.h"
@interface PickerView ()<UITextFieldDelegate,TypeListDelegate,UITextViewDelegate>
@property(nonatomic,strong) UIView *backView;
@property (nonatomic,strong)UITextField *logNameTextField;
@property (nonatomic,strong)UITextView *qxTextView;
@property (nonatomic,strong)SysButton *gczYbtn;
@property (nonatomic,strong)SysButton *gczNbtn;
@property (nonatomic,strong)SysButton *yxYbtn;
@property (nonatomic,strong)SysButton *yxNbtn;
@property (nonatomic,strong)UILabel *personLabel;
//随行人员
@property (nonatomic,strong)NSArray *supPersonArry;
@property (nonatomic,assign)BOOL isLoadPerson;



@end

@implementation PickerView

-(NSArray *)supPersonArry
{
    if (_supPersonArry==nil) {
        _supPersonArry = [NSArray array];
    }
    return _supPersonArry;
    
}

- (void)loadcontact
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    
    NSDictionary *parameters;
    parameters = @{@"type":@"smartplan",@"action":@"allusers"};
    
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    
    NSLog(@"Contact%@",requestAddress);
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [MBProgressHUD hideHUDForView:self animated:YES];
         NSDictionary *rs = (NSDictionary *)responseObject;
         if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
             NSArray *td= [rs objectForKey:@"result"];
             
             for (NSDictionary *dict in td) {
                 if ([[dict objectForKey:@"activityID"]isEqualToString:@"131"]) {
                     self.supPersonArry = [dict objectForKey:@"users"];
                     _isLoadPerson = YES;
                 }
             }
         }else{
             
             _isLoadPerson = NO;
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         _isLoadPerson = NO;
     }];
    
}


- (instancetype)initWithFrame:(CGRect)frame withDictModel:(NSDictionary *)modelDict {
    self = [super initWithFrame:frame];
    if (self) {
        
        //监听屏幕旋转的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenRotation) name:UIDeviceOrientationDidChangeNotification object:nil];
        //蒙版(自己)
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _modelDict = modelDict;
        [self createPikerView];
        [self loadcontact];
        // 键盘唤起和隐藏的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

-(void)screenRotation
{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    _backView.frame = CGRectMake(0, SCREEN_HEIGHT-160, SCREEN_WIDTH, 160);
}

-(void)createPikerView
{
    CGFloat btn_w = SCREEN_WIDTH - 200;
    
    UIView *backV =[[UIView alloc] initWithFrame:CGRectMake(100, 100, btn_w, 500)];
    backV.layer.cornerRadius = 15;
    backV.clipsToBounds = YES;
    backV.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:243.0/255.0 alpha:1];
    backV.layer.borderColor = [UIColor blueColor].CGColor;
    _backView = backV;
    [self addSubview:_backView];
    //记录名称
    [self setLabelWithFrame:CGRectMake(10, 10, 70, 44) andTitle:@"记录名称"];
    [self setLabelWithFrame:CGRectMake(10, 74, 140, 44) andTitle:@"是否取得工程证:"];
    [self setLabelWithFrame:CGRectMake(10, 148, 100, 44) andTitle:@"是否验线:"];
    [self setLabelWithFrame:CGRectMake(10, 202, 100, 44) andTitle:@"建设情况:"];
    
    //记录内容输入
 _logNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, 730, 44)];
    _logNameTextField.delegate =self;
    [_logNameTextField setText:[_modelDict objectForKey:@"xmmc"]];
    _logNameTextField.backgroundColor =[UIColor whiteColor];
    _logNameTextField.returnKeyType = UIReturnKeyDone;
    [_backView addSubview:_logNameTextField];
    
   
    
  _gczYbtn = [self setBtnwithFrame:CGRectMake(250, 74, 100, 44) andTitle:@"是" andTag:100];
    
   _gczNbtn = [self setBtnwithFrame:CGRectMake(450, 74, 100, 44) andTitle:@"否" andTag:101];
    
   _yxYbtn = [self setBtnwithFrame:CGRectMake(250, 148, 100, 44) andTitle:@"是" andTag:102];
    _yxNbtn = [self setBtnwithFrame:CGRectMake(450, 148, 100, 44) andTitle:@"否" andTag:103];
    
    if ([[_modelDict objectForKey:@"xyjl"]isEqualToString:@"已验线"]||[[_modelDict objectForKey:@"xyjl"]isEqualToString:@"true"]) {
        _yxYbtn.selected = YES;
        
    }else if([[_modelDict objectForKey:@"xyjl"]isEqualToString:@""])
    {
        _yxYbtn.selected  = _yxNbtn.selected = NO;
    }
    
    else
    {
        _yxNbtn.selected = YES;
        
    }
    if ([[_modelDict objectForKey:@"gczjl"]isEqualToString:@"已取得"]||[[_modelDict objectForKey:@"gczjl"]isEqualToString:@"true"]) {
        _gczYbtn.selected = YES;
    }
    else if([[_modelDict objectForKey:@"gczjl"]isEqualToString:@""])
    {
        _gczYbtn.selected  = _gczNbtn.selected = NO;
    }
    
    else
    {
        _gczNbtn.selected = YES;
        
        
    }

//建设情况:
    _qxTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 246, btn_w-20, 80)];
    _qxTextView.delegate =self;
    [_qxTextView setFont:[UIFont systemFontOfSize:15]];
    [_qxTextView setText:[_modelDict objectForKey:@"jsqk"]];
    _qxTextView.layer.cornerRadius = 10;
    _qxTextView.returnKeyType = UIReturnKeyDone;

    [_backView addSubview:_qxTextView];
    
    
   //添加随行人员
    
    UIButton *personBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [personBtn setTitle:@"添加随行人员" forState:UIControlStateNormal];
    [personBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal
     ];
    [personBtn setBackgroundColor:[UIColor whiteColor]];
    personBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    personBtn.layer.cornerRadius = 10;
    personBtn.layer.masksToBounds = YES;
    
    [personBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -160, 0, 500)];
    personBtn.frame =CGRectMake(10, 346,  btn_w-20, 44);
    [personBtn addTarget:self action:@selector(addPerson) forControlEvents:UIControlEventTouchUpInside];
    [personBtn setImage:[UIImage imageNamed:@"button-allright.png"] forState:UIControlStateNormal];
    [personBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -170, 0, 500)];
    [_backView addSubview:personBtn];
    
    UILabel *personLabel= [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 300, 44)];
    [personLabel setText:[_modelDict objectForKey:@"jcry"]];
    [personLabel setTextColor:[UIColor blackColor]];
    _personLabel = personLabel;
    [personBtn addSubview:_personLabel];

    //确定
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmButton.frame = CGRectMake(100,426, 200, 40);
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.backgroundColor = [UIColor colorWithRed:72/255.0 green:199/255.0 blue:150/255.0 alpha:1.000];
    confirmButton.layer.cornerRadius = 15;
    confirmButton.clipsToBounds = YES;
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(selectedEvent:) forControlEvents:UIControlEventTouchUpInside];
    //    _cancelButton = cancelButton;
    [_backView addSubview:confirmButton];
    
    // 取消
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(500,426, 200, 40);
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor colorWithRed:72/255.0 green:199/255.0 blue:150/255.0 alpha:1.000];
    cancelButton.layer.cornerRadius = 15;
    cancelButton.clipsToBounds = YES;
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelSelect) forControlEvents:UIControlEventTouchUpInside];
//    _cancelButton = cancelButton;
    [_backView addSubview:cancelButton];
}


- (SysButton *)setBtnwithFrame:(CGRect)frame andTitle:(NSString *)title andTag:(NSInteger)tag
{
    SysButton *btn = [[SysButton alloc] initWithFrame:frame];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"wxz@2x"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"xz@2x"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:btn];
    return btn;

}


- (void)addPerson
{
    if (self.isLoadPerson) {
        TypeList *typlist = [[TypeList alloc] initWithTitle:@"添加随行人员" options:_supPersonArry];
        
        typlist.delegate = self;
        
        [typlist showInView:self animated:YES];
    }
    else
    {
        [MBProgressHUD showSuccess:@"正在加载人员数据,请稍后!" toView:self];
        
    }


}

- (void)buttonSelected:(UIButton *)btn
{
    NSInteger tag = btn.tag-100;
    switch (tag) {
        case 0:
        {   _gczYbtn.selected=!_gczYbtn.selected;
            _gczNbtn.selected = !_gczYbtn.selected;
        }
            break;
        case 1:
        {
            _gczNbtn.selected = !_gczNbtn.selected;
            _gczYbtn.selected = !_gczNbtn.selected;
        
        }
            break;
        case 2:
        {
            _yxYbtn.selected=!_yxYbtn.selected;
            _yxNbtn.selected = !_yxYbtn.selected;
        }
            break;
        case 3:
        {
            _yxYbtn.selected=!_yxYbtn.selected;
            _yxNbtn.selected = !_yxYbtn.selected;
        }
            break;
        default:
        {
           
        
        }
            break;
    }


}


-(void) setLabelWithFrame:(CGRect)frame andTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setText:title];
    [label setFont:[UIFont systemFontOfSize:17]];
    [label setTextColor:[UIColor blackColor]];
    [_backView addSubview:label];


}

#pragma mark -- 确定选择事件

-(void)selectedEvent:(UIButton *)button
{
    if (_selectedBlock)
    {
        [self commitrevise];
       
    }
    
}
- (void)commitrevise
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameters;
    
    [MBProgressHUD showMessage:@"正在加载" toView:self];
    
//  http://58.246.138.178:8040/KSYDService/ServiceProvider.ashx?&id=-1&x=25734.493123&type=smartplan&y=70950.212281&yx=&action=setphgldata&jcsj=2017-03-06 11:02:43&jsqk=良好&xmmc=豪门世家&gcz=&jcry=邹小峰&pid=89644
    NSString *gczContent = @"";
    NSString *yxContent = @"";

    if (_gczYbtn.selected == YES) {
        gczContent = @"已取得";
    }else if (_gczNbtn.selected == YES)
    {
     gczContent = @"未取得";
    }else
    {
    gczContent = @"";
    
    }
    
    if(_yxYbtn.selected == YES)
    {
    yxContent = @"已验线";
    }
    else if(_yxNbtn.selected == YES)
    {
    yxContent = @"未验线";
    
    }
    else
    {
     yxContent = @"";
    }
    
    NSString *person = _personLabel.text;
    NSString *personA=@"";
    if([person containsString:[Global currentUser].username])
    {
       personA=[NSString stringWithFormat:@"%@",person];
    }
    else
    {
        if([person isEqualToString:@""]||person==nil)
        {
            personA=[NSString stringWithFormat:@"%@",[Global currentUser].username];
            
        }else
        {
            personA=[NSString stringWithFormat:@"%@,%@",[Global currentUser].username,person];
            
        }
    }
    
    
    parameters = @{@"type":@"smartplan",@"action":@"setphgldata",@"jcsj":[_modelDict objectForKey:@"jcsj"],@"id":[_modelDict objectForKey:@"id"],@"jcry":personA,@"xmmc":_logNameTextField.text,@"gcz":gczContent,@"yx":yxContent,@"jsqk":_qxTextView.text,@"x":[_modelDict objectForKey:@"x"],@"y":[_modelDict objectForKey:@"y"]};
    NSMutableString *requestAddress = [NSMutableString stringWithString:[Global serviceUrl]];
    [requestAddress appendString:@"?"];
    
    if (nil!=parameters) {
        for (NSString *key in parameters.keyEnumerator) {
            NSString *val = [parameters objectForKey:key];
            [requestAddress appendFormat:@"&%@=%@",key,val];
        }
    }
    
    NSLog(@"提交修改%@",requestAddress);
    
    
    [manager POST:[Global serviceUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self];
        NSDictionary *rs = (NSDictionary *)responseObject;
        if ([[rs objectForKey:@"success"] isEqualToString:@"true"]) {
   
            _selectedBlock();
            [self fadeOut];
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self];
        
        
    }];


}
#pragma mark -- 取消选择事件

-(void)cancelSelect
{
    [self fadeOut];
}

-(void)showInView:(UIView *)superView animated:(BOOL)animated
{
    [superView addSubview:self];
    if (animated)
    {
        [self fadeIn];
    }
}

-(void)fadeIn
{
    /**
     *  弹出动画
     */
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}
-(void)fadeOut
{
    /**
     *  消失动画
     */
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished)
        {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark -- touch

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
    [self fadeOut];
}


#pragma mark- typelistDelegate 代理方法
- (void)TypeListViewDidConfirmWithArr:(NSArray *)arr
{
    NSString *str= [arr componentsJoinedByString:@" "];
    self.personLabel.text = str;
    NSLog(@"执行了代理方法%@",arr);
    
}
//
- (void)TypeListViewDidCancel
{
    self.personLabel.text = @"";
    
    NSLog(@"取消");
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    if ([textField.text isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
//    }

    return YES;
}

#pragma mark - UITextView Delegate Methods
//点击键盘右下角的键收起键盘
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (_qxTextView.text.length == 0) {
            _qxTextView.textColor =[UIColor lightGrayColor];
            _qxTextView.text = @"请输入建设情况...";
        }
     
        [textView resignFirstResponder];
        
    }
    return YES;
}

// 键盘升起/隐藏
-(void)keyboardWillShow:(NSNotification *)noti
{
    // 获取键盘弹出的动画时间
    CGFloat durtion = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
//    CGSize keyboardSize = [noti.userInfo[@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue].size ;
//    CGFloat keyboard_h = keyboardSize.height;
        [UIView animateWithDuration:durtion animations:^{
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
            CGRect tableFrame = self.frame;
                tableFrame.origin.y = -100 ;
            self.frame = tableFrame;
        }];
}
-(void)keyboardWillHide:(NSNotification *)noti
{
    // 获取键盘弹出的动画时间
    CGFloat durtion = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGSize keyboardSize = [noti.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size ;
    CGFloat keyboard_h = keyboardSize.height;
    [UIView animateWithDuration:durtion animations:^{
        CGRect tableFrame = self.frame;
        tableFrame.origin.y =0;
        self.frame = tableFrame;
    }];
}

//开始编辑意见框,键盘遮挡问题
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    if ([textView.text isEqualToString:@"请输入建设情况..."]) {
        _qxTextView.text = @"";
        _qxTextView.textColor = [UIColor blackColor];
    }
    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [_qxTextView resignFirstResponder];
    [_logNameTextField resignFirstResponder];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    // [_textView resignFirstResponder];
    return YES;
}




@end
