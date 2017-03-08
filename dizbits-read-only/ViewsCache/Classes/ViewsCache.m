//
//  ViewsCache.m
//  ViewsCache
//
//  Created by Dmitry Stadnik on 1/21/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import "ViewsCache.h"

@implementation ViewsCache

@synthesize capacityPerType;

- (id)init {
	if ((self = [super init])) {
		allViews = [[NSMutableDictionary alloc] init];
		capacityPerType = 8;
	}
	return self;
}

+ (ViewsCache *)sharedCache {
	static ViewsCache *cache;
	if (!cache) {
		cache = [[ViewsCache alloc] init];
	}
	return cache;
}

- (UIView<ReusableView> *)dequeueReusableViewWithIdentifier:(NSString *)reuseIdentifier {
	if (!reuseIdentifier) {
		return nil;
	}
	NSMutableArray *views = [allViews objectForKey:reuseIdentifier];
	UIView<ReusableView> *view = [views lastObject];
	if (view) {
		[[view retain] autorelease];
		[views removeLastObject];
		return view;
	}
	return nil;
}

- (void)enqueueReusableView:(UIView<ReusableView> *)view {
	if (![view reuseIdentifier]) {
		return;
	}
	NSMutableArray *views = [allViews objectForKey:[view reuseIdentifier]];
	if (views) {
		if ([views count] < capacityPerType) {
			[views addObject:view];
		}
	} else {
		views = [NSMutableArray arrayWithObject:view];
		[allViews setObject:views forKey:[view reuseIdentifier]];
	}
}

- (void)removeReusableView:(UIView<ReusableView> *)view {
	if (![view reuseIdentifier]) {
		return;
	}
	NSMutableArray *views = [allViews objectForKey:[view reuseIdentifier]];
	if (views) {
		[views removeObjectIdenticalTo:view];
	}
}

- (void)clear {
	[allViews removeAllObjects];
}

@end
