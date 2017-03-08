//
//  SimpleReusableView.m
//  ViewsCache
//
//  Created by Dmitry Stadnik on 1/21/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import "SimpleReusableView.h"

@implementation SimpleReusableView

@synthesize reuseIdentifier;

- (void)dealloc {
	[reuseIdentifier release];
    [super dealloc];
}

- (void)didMoveToWindow {
	self.window ?
	[[ViewsCache sharedCache] removeReusableView:self] :
	[[ViewsCache sharedCache] enqueueReusableView:self];
}

@end
