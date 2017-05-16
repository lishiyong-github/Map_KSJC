//
//  UICollectionViewCell.m
//  nbOneMap
//
//  Created by shiyong_li on 17/4/7.
//  Copyright © 2017年 dist. All rights reserved.
// UICollectionViewCell

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <XAspect/XAspect.h>
#define AtAspect UICollectionViewCell
#define AtAspectOfClass UICollectionViewCell
@classPatchField(UICollectionViewCell)
AspectPatch(-, instancetype, initWithFrame:(CGRect)frame){
    id cell = XAMessageForward(initWithFrame:frame);
    [self setNeedsUpdateConstraints];
    return cell;
}
@end
#undef AtAspectOfClass

#undef AtAspect


