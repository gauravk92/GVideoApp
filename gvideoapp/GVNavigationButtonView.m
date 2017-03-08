//
//  GVNavigationButtonView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/12/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVNavigationButtonView.h"
#import "GVTintColorUtility.h"

@interface GVNavigationButtonView ()


@end


@implementation GVNavigationButtonView

- (instancetype)initWithImage:(UIImage*)image
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _imageView.tintColor = [GVTintColorUtility utilityTintColor];
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.alpha = 0.8;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    DLogMainThread();

    [self.imageView setNeedsLayout];
}
//
- (void)layoutSubviews {
    [super layoutSubviews];
    DLogMainThread();

    CGPoint center = self.center;
    center.y = self.center.y;
    self.imageView.center = center;
    self.imageView.frame = CGRectIntegral(self.imageView.frame);
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
