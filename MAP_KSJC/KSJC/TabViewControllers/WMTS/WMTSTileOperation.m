//
//  WMTSTileOperation.m
//  WMTSMap
//
//  Created by Aaron on 14-1-17.
//  Copyright (c) 2014年 Aaron. All rights reserved.
//

#import "WMTSTileOperation.h"
#define kURLGetTile @"%@/%d/%d/%d"

@implementation WMTSTileOperation
@synthesize tileKey=_tileKey;
@synthesize target=_target;
@synthesize action=_action;
@synthesize imageData = _imageData;
@synthesize layerInfo = _layerInfo;

- (id)initWithTileKey:(AGSTileKey *)tileKey TiledLayerInfo:(WMTSLayerInfo *)layerInfo target:(id)target action:(SEL)action{
	
	if (self = [super init]) {
		self.target = target;
		self.action = action;
		self.tileKey = tileKey;
		self.layerInfo = layerInfo;
	}
    return self;
}
-(void)main {
	//Fetch the tile for the requested Level, Row, Column
	@try {
        if (self.tileKey.level > self.layerInfo.maxZoomLevel ||self.tileKey.level < self.layerInfo.minZoomLevel) {
            return;
        }
        NSString *baseUrl= [NSString stringWithFormat:kURLGetTile,self.layerInfo.url,self.tileKey.level + 1,self.tileKey.row,self.tileKey.column];
        //NSLog(baseUrl);
        
		NSURL* aURL = [NSURL URLWithString:baseUrl];
		self.imageData = [[NSData alloc] initWithContentsOfURL:aURL];
	}
	@catch (NSException *exception) {
		NSLog(@"main: Caught Exception %@: %@", [exception name], [exception reason]);
	}
	@finally {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		//Invoke the layer's action method
		[_target performSelector:_action withObject:self];
        #pragma clang diagnostic pop
	}
    
}
@end
