//
//  TypeList.m
//  WSYD
//
//  Created by 叶松丹 on 2016/12/14.
//  Copyright © 2016年 dist. All rights reserved.
//

#import "TypeList.h"
#define POPLISTVIEW_SCREENINSET 40.
#define POPLISTVIEW_HEADER_HEIGHT 50.
#define RADIUS 5.

@interface TypeList ()
{

    NSMutableArray *_selectedItems;
    NSIndexPath *_selectedIndexPath;


}
@property (nonatomic,strong)NSArray *selectArray;

- (void)fadeIn;
- (void)fadeOut;

@end
@implementation TypeList

- (id)initWithTitle:(NSString *)aTitle options:(NSMutableArray *)aOptions
{
    CGRect rect = CGRectMake(0, 0, MainR.size.width, MainR.size.height);
    if (self = [super initWithFrame:rect])
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        UIView *bView=[[UIView alloc]initWithFrame:CGRectMake(10, 100, MainR.size.width-20, MainR.size.height-180)];
        if(MainR.size.height==480)
        {
            bView.frame=CGRectMake(10, 100, MainR.size.width-20, MainR.size.height-130);
            
        }
        if(MainR.size.width>414)
        {
            bView.frame=CGRectMake(150, 180, MainR.size.width-300, MainR.size.height-360-64);
            
            
        }
        bView.backgroundColor =[UIColor whiteColor];
        bView.layer.cornerRadius =6;
        bView.layer.masksToBounds=YES;
        _bView = bView;
        [self addSubview:_bView];
        
        UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, bView.frame.size.width-20, 44)];
        [nameLabel setText:aTitle];
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [nameLabel setFont:[UIFont systemFontOfSize:22]];
        [nameLabel setTextColor:[UIColor blackColor]];
        [_bView addSubview:nameLabel];
        
        UIView *innerView =[[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(nameLabel.frame)+5, _bView.frame.size.width-20, _bView.frame.size.height-2*50-10)];
        [innerView.layer setMasksToBounds:YES];
        [innerView.layer setCornerRadius:10];
        [innerView.layer setBorderWidth:1.0];
        [innerView.layer setBorderColor:[UIColor blackColor].CGColor];
        
        [_bView addSubview:innerView];
     
        _typelistArray = aOptions;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, innerView.frame.size.width, innerView.frame.size.height)];
//        _tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = [UIColor colorWithWhite:0 alpha:.2];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.allowsMultipleSelection = YES;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.sectionHeaderHeight = 40;
        [innerView addSubview:_tableView];
        
        
        _confirm= [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirm setTitle:@"确定" forState:UIControlStateNormal];
        [_confirm setTitleColor:[UIColor colorWithRed:19.0/255 green:128.0/255 blue:182.0/255 alpha:1] forState:UIControlStateNormal];
        
        _confirm.frame = CGRectMake(CGRectGetMaxX(innerView.frame)-100,CGRectGetMaxY(innerView.frame) , 100, bView.frame.size.height-CGRectGetMaxY(innerView.frame));
        [_confirm addTarget:self action:@selector(confirmClick) forControlEvents:UIControlEventTouchUpInside];
        [bView addSubview:_confirm];
        _confirm= [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirm setTitle:@"取消" forState:UIControlStateNormal];
        [_confirm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        _confirm.frame = CGRectMake(CGRectGetMaxX(innerView.frame)-180,CGRectGetMaxY(innerView.frame) , 100, bView.frame.size.height-CGRectGetMaxY(innerView.frame));
        [_confirm addTarget:self action:@selector(cancelS) forControlEvents:UIControlEventTouchUpInside];
        [bView addSubview:_confirm];
        
        _selectedItems = [NSMutableArray arrayWithCapacity:10];

        
        
    }
    
    return self;
}
- (void)cancelS
{
    NSLog(@"取消");
    if (self.delegate && [self.delegate respondsToSelector:@selector(TypeListViewDidCancel)]) {
        [self.delegate TypeListViewDidCancel];
    }
    [self fadeOut];
    
}

- (void)confirmClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TypeListViewDidConfirmWithArr:)]) {
        NSLog(@"------%@",_selectedItems);
        NSMutableArray * mulArr =[NSMutableArray array];
        for (NSString *userId in _selectedItems) {
            for (NSDictionary *dict in _typelistArray) {
                if ([[dict objectForKey:@"userId"] isEqualToString:userId]) {
                    [mulArr addObject:[dict objectForKey:@"userName"]];
                }
            }
        }
        
        [self.delegate TypeListViewDidConfirmWithArr:mulArr];
    }
    [self fadeOut];
    
}

//- (void)allSelect:(UIButton *)btn
//{
//    _selected= !_selected;
//    BOOL state= _selected;
//    
//    for (SHMembersModel *membersModel in _contacts) {
//        
//        if (state ==YES) {
//            _selectedAll.image =[UIImage imageNamed:@"iconfont-selected"];
//            membersModel.selected = true;
//        }
//        else
//        {
//            _selectedAll.image =[UIImage imageNamed:@"iconfont-unselected"];
//            
//            
//            membersModel.selected = false;
//            
//        }
//        
//        for (SHMembers *mem in membersModel.users) {
//            
//            
//            if (state == YES) {
//                mem.selected = true;
//                
//                //                [btn setTitle:@"取消" forState:UIControlStateNormal];
//                
//            }
//            else{
//                
//                mem.selected = false;
//                //                [btn setTitle:@"全选" forState:UIControlStateNormal];
//            }
//            
//        }
//    }
//    
//    [_tableView reloadData];
//}


#pragma mark - Private Methods
- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}
- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _typelistArray.count;
}

#pragma mark -tabelViewDelge代理方法

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    SHmemeberHeadder *headerView = [SHmemeberHeadder memberHeaderWithTableView:tableView];
//    headerView.selectBut.tag = section+1;
//    headerView.delegate =self;
//    headerView.membersModel = _contacts[section+1];
//    
//    SHMembersModel *model = [self.contacts objectAtIndex:0];
//    NSLog(@"model= %@,model.name=%@",model,model.activityName);
//    
//    [_sumName setText: model.activityName];
//    
//    
//    return headerView;
//    
//    
//}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return  1;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifierCell=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:indentifierCell];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifierCell];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:189.0/255.0 blue:21.0/255.0 alpha:1];
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    
   
    NSDictionary *userInfo = [_typelistArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [userInfo objectForKey:@"userName"];
    int si = [self selectedIndex:[userInfo objectForKey:@"userId"]];
//    cell.selected = si!=-1;

    return cell;
}
-(int)selectedIndex:(NSString *)uid{
    NSLog(@"%@",_selectedItems);
    for (int i=0; i<_selectedItems.count; i++) {
        NSString *saveId = [_selectedItems objectAtIndex:i];
        if ([saveId isEqualToString:uid]) {
            return i;
        }
    }
    return -1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        NSString *uid=[[_typelistArray objectAtIndex:indexPath.row] objectForKey:@"userId"];
        [_selectedItems addObject:uid];
    NSLog(@"选中后%@",_selectedItems);
         _selectedIndexPath = indexPath;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
        NSString *uid=[[_typelistArray objectAtIndex:indexPath.row] objectForKey:@"userId"];
        int si = [self selectedIndex:uid];
        [_selectedItems removeObjectAtIndex:si];
//        if (_selectedItems.count==0) {
//          
//        }
}

#pragma mark-SHmemeberHeadder代理方法
- (void)clickHeaderView
{
    
    [_tableView reloadData];
    
}

- (void)selctGroupWithButton:(UIButton *)btn;
{
    
//    //点击了选择组按钮;
//    SHMembersModel *membersModel = _contacts[btn.tag];
//    membersModel.selected = !membersModel.selected;
//    
//    for (SHMembers *mm in membersModel.users) {
//        
//        if (membersModel.selected == true) {
//            mm.selected = true;
//        }
//        else
//        {
//            mm.selected = false;
//        }
//        
//    }
//    [_tableView reloadData];
    
}

#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(memberListViewDidCancel)]) {
        [self.delegate TypeListViewDidCancel];
    }
    
    // dismiss self
    [self fadeOut];
}

@end
