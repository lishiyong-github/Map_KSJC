//
//  JobPhotoView.m
//  zzzf
//
//  Created by dist on 13-12-13.
//  Copyright (c) 2013年 dist. All rights reserved.
//

#import "JobPhotoView.h"
#import "Tools.h"
#import "Global.h"

@implementation JobPhotoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tap];
        
        _waiting = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _waiting.color = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1];
        _waiting.frame =CGRectMake((self.frame.size.width-32)/2,(self.frame.size.height-32)/2,32,32);
        //_waiting.frame = CGRectMake(20, 20, 42, 42);
        [self addSubview:_waiting];
        
        _photoNameView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-25, self.frame.size.width, 25)];
        _photoNameView.backgroundColor = [UIColor whiteColor];
        _photoNameView.alpha = .6;
        
        _lblPhotoName = [[UILabel alloc] initWithFrame:CGRectMake(5, self.frame.size.height-23, self.frame.size.width-10, 20)];
        [_lblPhotoName setTextAlignment:NSTextAlignmentCenter];
        [_lblPhotoName setTextColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1]];
        [_lblPhotoName setFont:[_lblPhotoName.font fontWithSize:12]];
        
        _imgForUploaded = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-37, 5, 32, 32)];
        _imgForUploaded.image = [UIImage imageNamed:@"icon_selected_green"];
        _imgForUploaded.hidden = YES;
        
        [self addSubview:_photoNameView];
        [self addSubview:_lblPhotoName];
        [self addSubview:_imgForUploaded];
        
        self.layer.cornerRadius=3;
        self.clipsToBounds = YES;
        
        [self clearImageViewBorder];
        
        
    }
    return self;
}


-(void)setSelected:(BOOL)selected{
    _selected = selected;
    if (_selected) {
        [self setImageViewBorder];
    }else{
        [self clearImageViewBorder];
    }
}

-(void)setUploaded:(BOOL)uploaded{
    _uploaded = uploaded;
    _imgForUploaded.hidden = !uploaded;
}

-(void)setPhotoPath:(NSString *)photoPath{
    _waiting.hidden = YES;
    _photoPath = photoPath;
    self.image = [Tools thumbnailWithImageWithoutScale:[UIImage imageWithContentsOfFile:_photoPath] size:CGSizeMake(102, 76)];
}

-(void)setPhotoUrl:(NSString *)photoUrl{
    _photoUrl = photoUrl;
    if (nil==cacheThumbs) {
        NSString *cacheThumbListSavePath = [[Global currentUser].userWorkTempPath stringByAppendingString:@"/thumb.plist"];
        cacheThumbs = [NSMutableDictionary dictionaryWithContentsOfFile:cacheThumbListSavePath];
        if (nil==cacheThumbs) {
            cacheThumbs = [NSMutableDictionary dictionaryWithCapacity:100];
        }
    }
    
    NSString *cachePath;
    if (nil!=cacheThumbs) {
        cachePath = [cacheThumbs objectForKey:photoUrl];
    }
    
    FGalleryPhoto *photoLoader = nil;
    if (nil==cachePath) {
        photoLoader = [[FGalleryPhoto alloc] initWithThumbnailUrl:photoUrl fullsizeUrl:nil delegate:self];
        [photoLoader loadThumbnail];
        _waiting.hidden = NO;
        [_waiting startAnimating];
    }else{
        _waiting.hidden = YES;
        [_waiting stopAnimating];
        self.image = [UIImage imageWithContentsOfFile:cachePath];
    }
    
}

-(void)setPhotoName:(NSString *)photoName{
    _photoName = photoName;
    _lblPhotoName.text = photoName;
    
}

-(void)setImageViewBorder{
    self.layer.borderColor = [UIColor colorWithRed:103.0/255.0 green:216.0/255.0 blue:198.0/255.0 alpha:1].CGColor;
    self.layer.borderWidth=6;
}

-(void)clearImageViewBorder{
    self.layer.borderColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:.3].CGColor;
    self.layer.borderWidth = 1;
}

-(void)onTap{
    if (_selected) {
        [self.delegate jobPhotoDoubleTap:self];
    }else{
        [self.delegate jobPhotoTap:self];
    }
}

-(void)galleryPhoto:(FGalleryPhoto *)photo didLoadThumbnail:(UIImage *)image{
    self.image = image;
    [_waiting stopAnimating];
    _waiting.hidden=YES;
    
    if (nil==_photoUrl) {
        return;
    }
    
    NSString *saveName = [NSString stringWithFormat:@"/%@.jpg",[Global newUuid]];
    NSString *imgSavePath = [[Global currentUser].userWorkTempPath stringByAppendingString:saveName];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:imgSavePath atomically:YES];
    [cacheThumbs setValue:imgSavePath forKey:_photoUrl];
    
    NSString *cacheThumbListSavePath = [[Global currentUser].userWorkTempPath stringByAppendingString:@"/thumb.plist"];
    [cacheThumbs writeToFile:cacheThumbListSavePath atomically:YES];
}

-(void)galleryPhoto:(FGalleryPhoto *)photo didLoadFullsize:(UIImage *)image{
    
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
