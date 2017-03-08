//
//  HeaderView.m
//  ComplementaryHeaders
//
//  Created by Dmitry Stadnik on 1/22/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import "HeaderView.h"

NSComparisonResult CompareHeaderViewsByY(HeaderView *view1, HeaderView *view2, void *context) {
	const CGFloat diff = view2.frame.origin.y - view1.frame.origin.y;
	return diff > 0 ? NSOrderedAscending : diff < 0 ? NSOrderedDescending : NSOrderedSame;
}

@implementation HeaderView

@synthesize text, subtext, complementaryHeader;

+ (NSMutableArray *)visibleViews {
	static NSMutableArray *views;
	if (!views) {
		views = [[NSMutableArray alloc] init];
	}
	return views;
}

- (void)didMoveToWindow {
	[super didMoveToWindow];
	NSMutableArray *views = [HeaderView visibleViews];
	if (self.window) {
		if (![views containsObject:self]) {
			[views addObject:self];
		}
	} else {
		[views removeObject:self];
	}
	[views sortUsingFunction:CompareHeaderViewsByY context:NULL];
	HeaderView *upperView = nil;
	for (HeaderView *view in views) {
		if (upperView && EqualStrings(view.text, upperView.text)) {
			view.complementaryHeader = YES;
		} else {
			view.complementaryHeader = NO;
		}
		[view setNeedsDisplay];
		upperView = view;
	}
}

- (void)dealloc {
	[text release];
	[subtext release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[[UIColor colorWithWhite:0.7 alpha:1] set];
	UIRectFill(self.bounds);
	if (text) {
		[[UIColor blackColor] set];
		[text drawAtPoint:CGPointMake(10, 5) withFont:[UIFont systemFontOfSize:14]];
	}
	if (subtext && !complementaryHeader) {
		[[UIColor grayColor] set];
		[subtext drawAtPoint:CGPointMake(10, 22) withFont:[UIFont systemFontOfSize:12]];
	}
}

@end
