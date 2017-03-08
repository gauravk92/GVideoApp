//
//  HeaderView.m
//  ViewsCache
//
//  Created by Dmitry Stadnik on 1/21/10.
//  Copyright 2010 www.dimzzy.com. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

@synthesize textLabel;
@synthesize subtextLabel;
@synthesize iconView;

- (id)initWithFrame:(CGRect)aRect {
	if ((self = [super initWithFrame:aRect])) {
		self.backgroundColor = [UIColor orangeColor];
		textLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 20)];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.textColor = [UIColor whiteColor];
		textLabel.font = [UIFont boldSystemFontOfSize:14];
		[self addSubview:textLabel];
		subtextLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 18, 200, 20)];
		subtextLabel.backgroundColor = [UIColor clearColor];
		subtextLabel.textColor = [UIColor whiteColor];
		subtextLabel.font = [UIFont systemFontOfSize:12];
		[self addSubview:subtextLabel];
		iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
		[self addSubview:iconView];
	}
	return self;
}

- (void)dealloc {
	[textLabel release];
	[subtextLabel release];
	[iconView release];
    [super dealloc];
}

@end
