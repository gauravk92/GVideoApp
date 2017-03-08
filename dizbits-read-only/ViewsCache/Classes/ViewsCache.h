//
//  ViewsCache.h
//  ViewsCache
//
//  Created by Dmitry Stadnik on 1/21/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#include <UIKit/UIKit.h>

@protocol ReusableView <NSObject>

@property(copy) NSString *reuseIdentifier;

@end


@interface ViewsCache : NSObject {
	NSMutableDictionary *allViews; // reuseIdentifier -> NSMutableArray:UIView
	NSUInteger capacityPerType;
}

@property(readonly) NSUInteger capacityPerType;

+ (ViewsCache *)sharedCache;

- (UIView<ReusableView> *)dequeueReusableViewWithIdentifier:(NSString *)reuseIdentifier;
- (void)enqueueReusableView:(UIView<ReusableView> *)view;
- (void)removeReusableView:(UIView<ReusableView> *)view;
- (void)clear;

@end
