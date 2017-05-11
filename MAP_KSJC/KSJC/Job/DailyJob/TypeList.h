//
//  TypeList.h
//  WSYD
//
//  Created by 叶松丹 on 2016/12/14.
//  Copyright © 2016年 dist. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TypeListDelegate;

@interface TypeList : UIView<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSString *_title;
    UIView *_bView;
    UIImageView *_selectedAll;
    UIButton *_topbtn;
    
    
}
@property (nonatomic,assign) BOOL selected;

/******/
@property (nonatomic,weak) UIButton *btn;


@property (nonatomic ,strong)UIButton *confirm;
@property (nonatomic,strong) NSMutableArray *typelistArray;
@property (nonatomic,strong) UILabel *sumName;


/*****/

@property (nonatomic, assign) id<TypeListDelegate> delegate;


- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions;
- (void)showInView:(UIView *)aView animated:(BOOL)animated;

@end

@protocol TypeListDelegate <NSObject>


- (void)TypeListViewDidConfirmWithArr:(NSArray *)arr;

- (void)TypeListViewDidCancel;

@end
