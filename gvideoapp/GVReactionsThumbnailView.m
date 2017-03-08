//
//  GVReactionsThumbnailView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVReactionsThumbnailView.h"
#import "GVUnreadDotView.h"

@implementation GVReactionsThumbnailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.recordDotView = [[GVUnreadDotView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.recordDotView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self sendSubviewToBack:self.imageView];

    CGFloat unreadSize = 12;
    CGFloat unreadPadding = 2;
    self.recordDotView.frame = CGRectIntegral(CGRectMake(self.bounds.size.width - unreadSize + unreadPadding, unreadPadding, unreadSize, unreadSize));

    [self bringSubviewToFront:self.recordDotView];
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
