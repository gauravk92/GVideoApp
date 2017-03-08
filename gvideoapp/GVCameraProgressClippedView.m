//
//  GVCameraProgressClippedView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/24/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCameraProgressClippedView.h"


@implementation GVCameraProgressClippedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat progressBarPadding = 44;

    self.cameraProgressView.frame = CGRectMake(progressBarPadding *-1, 0, self.bounds.size.width + (progressBarPadding*2), 0);
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
