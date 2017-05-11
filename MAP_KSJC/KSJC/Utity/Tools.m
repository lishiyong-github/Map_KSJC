//
//  Tools.m
//  zzzf
//
//  Created by zhangliang on 13-12-12.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "Tools.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Tools

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

+(NSString *) md5:(NSString *) input
{
    //看你怎么碰撞
    NSString *nString = [NSString stringWithFormat:@"sp1234sp1234%@x(*&(*#(*#*brrfefd@#ffdXXfeef$(33ksdf@#$dfllj)((  sdfl!~@$$xxef@**$$!!##xxfefd*&*&&&^&0000*&……^%%aqfje%@sp1234%@xxfsdfefjidsiflsdifjlsfieasdlfdiejffeeeoadsfljiefasiee**(**(888808  sdfsde((**&ddfebbbbr3434(((fffllsfajsflleefkelkfjeflka;dfa;lfjefieeifjj$@sdllsxx*)(@*#sfldndf",input,input,input];
    
    const char *cStr = [nString UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
