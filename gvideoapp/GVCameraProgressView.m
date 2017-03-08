//
//  GVCameraProgressView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/24/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCameraProgressView.h"

@implementation GVCameraProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.progress = 1.0;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(size.width, 44);
    return newSize;
}

@end
