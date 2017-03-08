//
//  TextSizeCache.h
//  RightLabel
//
//  Created by Dmitry Stadnik on 1/20/10.
//  Copyright 2010 www.dimzzy.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface TextSizeCache : NSObject {
	NSMutableArray *fonts; // :UIFont
	NSMutableArray *strings; // :NSArray:NSString
	NSMutableArray *widths; // :NSArray:NSValue
}

+ (TextSizeCache *)sharedCache;

- (NSString *)shortestTextWiderThan:(CGFloat)width ofFont:(UIFont *)font;
- (void)clear;

@end
