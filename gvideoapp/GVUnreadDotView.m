//
//  GVUnreadDotView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVUnreadDotView.h"

@implementation GVUnreadDotView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.000 green:0.898 blue:1.000 alpha:1.0];
        self.opaque = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.layer.cornerRadius = self.bounds.size.width / 2;
    self.clipsToBounds = YES;
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
