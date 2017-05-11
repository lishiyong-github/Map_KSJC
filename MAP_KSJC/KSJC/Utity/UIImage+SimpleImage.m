//
//  UIImage+SimpleImage.m
//  HAYD
//
//  Created by 叶松丹 on 16/9/7.
//  Copyright © 2016年 dist. All rights reserved.
//

#import "UIImage+SimpleImage.h"

@implementation UIImage (SimpleImage)
//压缩图片
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}
@end
