//
//  GVButtonImageView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/10/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVButtonImageView.h"

@interface GVButtonImageView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation GVButtonImageView

- (instancetype)initWithImage:(UIImage*)image
{
    self = [super initWithFrame:CGRectZero];
    if (self) {

        self.autoresizesSubviews = YES;
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        self.imageView.tintColor = [UIColor whiteColor];
        self.imageView.layer.shouldRasterize = YES;
        self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.imageView.contentMode = UIViewContentModeCenter;
        //_imageView = [[UIImageView alloc] initWithFrame:frame];
        //_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //_imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.imageView];

        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        self.gradientLayer.startPoint = CGPointMake(0.0f, -1.0f);
        self.gradientLayer.endPoint = CGPointMake(0.0, 0.6f);
        //self.collectionView.layer.mask = l;
        self.layer.mask = self.gradientLayer;
    }
    return self;
}

- (void)tintColorDidChange {
    self.imageView.tintColor = self.tintColor;
    [self.imageView tintColorDidChange];
}

//- (void)setImage:(UIImage *)image {
//    [self.imageView setImage:image];
//}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.frame = self.bounds;
    self.gradientLayer.frame = self.bounds;
}

- (UIImageView*)contentImageView {
    return self.imageView;
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
