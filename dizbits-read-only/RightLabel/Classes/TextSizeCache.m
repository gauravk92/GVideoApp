//
//  TextSizeCache.m
//  RightLabel
//
//  Created by Dmitry Stadnik on 1/20/10.
//  Copyright 2010 www.dimzzy.com. All rights reserved.
//

#import "TextSizeCache.h"

#define kFillText @"-"

@implementation TextSizeCache

- (id)init {
	if (self = [super init]) {
		fonts = [[NSMutableArray alloc] init];
		strings = [[NSMutableArray alloc] init];
		widths = [[NSMutableArray alloc] init];
	}
	return self;
}

+ (TextSizeCache *)sharedCache {
	static TextSizeCache *cache;
	if (!cache) {
		cache = [[TextSizeCache alloc] init];
	}
	return cache;
}

- (NSString *)shortestTextWiderThen:(CGFloat)width
							strings:(NSMutableArray *)cachedStrings
							 widths:(NSMutableArray *)cachedWidths
						   minIndex:(NSUInteger)minIndex
						   maxIndex:(NSUInteger)maxIndex
{
	if (minIndex == maxIndex) {
		NSNumber *value = [cachedWidths objectAtIndex:minIndex];
		return [value doubleValue] > width ? [cachedStrings objectAtIndex:minIndex] : nil;
	}
	const NSUInteger index = minIndex + (maxIndex - minIndex) / 2;
	NSNumber *value = [cachedWidths objectAtIndex:index];
	if ([value doubleValue] > width) {
		return [self shortestTextWiderThen:width strings:cachedStrings widths:cachedWidths minIndex:minIndex maxIndex:index];
	} else {
		return [self shortestTextWiderThen:width strings:cachedStrings widths:cachedWidths minIndex:(index + 1) maxIndex:maxIndex];
	}
}

- (NSString *)shortestTextWiderThan:(CGFloat)width ofFont:(UIFont *)font {
	if (!font || width < 0) {
		return @"";
	}
	NSString *text = nil;
	NSMutableArray *cachedStrings = nil;
	NSMutableArray *cachedWidths = nil;
	for (NSInteger i = [fonts count] - 1; i >= 0; i--) {
		UIFont *cachedFont = [fonts objectAtIndex:i];
		if ([cachedFont isEqual:font]) {
			cachedStrings = [strings objectAtIndex:i];
			cachedWidths = [widths objectAtIndex:i];
			break;
		}
	}
	if (cachedStrings) {
		// TODO: check max element first before searching
		text = [self shortestTextWiderThen:width
								   strings:cachedStrings
									widths:cachedWidths
								  minIndex:0
								  maxIndex:[cachedStrings count] - 1];
		if (text) {
			return text;
		}
	} else {
		[fonts addObject:font];
		cachedStrings = [NSMutableArray array];
		[strings addObject:cachedStrings];
		cachedWidths = [NSMutableArray array];
		[widths addObject:cachedWidths];
	}
	NSString *longestText = [cachedStrings lastObject];
	if (longestText) {
		longestText = [longestText stringByAppendingString:kFillText];
	} else {
		longestText = kFillText;
	}
	for (;;) {
		const CGFloat longestWidth = [longestText sizeWithFont:font].width;
		[cachedStrings addObject:longestText];
		[cachedWidths addObject:[NSNumber numberWithDouble:longestWidth]];
		if (longestWidth >= width) {
			return longestText;
		}
		longestText = [longestText stringByAppendingString:kFillText];
	}
}

- (void)clear {
	[fonts removeAllObjects];
	[strings removeAllObjects];
	[widths removeAllObjects];
}

@end
