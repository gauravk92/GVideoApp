//
//  GVOverlayRadialGradientLayer.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/11/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVOverlayRadialGradientLayer.h"

@implementation GVOverlayRadialGradientLayer

- (instancetype)init {
    self = [super init];
    if (self) {

        self.contentsScale = 0.5;

        _overlayLayer = [CAShapeLayer layer];
        //_overlayLayer.needsDisplayOnBoundsChange = YES;
        _overlayLayer.fillColor = [UIColor whiteColor].CGColor;
        _overlayLayer.backgroundColor = [UIColor whiteColor].CGColor;
        //_overlayLayer.rasterizationScale = [UIScreen mainScreen].scale;
        //_overlayLayer.shouldRasterize = YES;
        [self addSublayer:_overlayLayer];

        // self.rasterizationScale = [UIScreen mainScreen].scale;
        //self.shouldRasterize = YES;

        self.fillColor = [UIColor clearColor].CGColor;
        self.backgroundColor = [UIColor clearColor].CGColor;


        _contentLayer = [GVSmoothRadialGradientLayer layer];
        //_contentLayer.needsDisplayOnBoundsChange = YES;
        _contentLayer.fillColor = [UIColor colorWithWhite:0.3 alpha:0.5].CGColor;
        _contentLayer.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5].CGColor;
        //_contentLayer = [GVRadialGradientLayer layer];
        //_contentLayer.shouldRasterize = YES;
        //_contentLayer.rasterizationScale = [UIScreen mainScreen].scale;
        //_contentLayer.backgroundColor = [UIColor clearColor].CGColor;
        [self addSublayer:_contentLayer];
    }
    return self;
}

- (BOOL)needsDisplayOnBoundsChange {
    return YES;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];

    [self.overlayLayer setNeedsDisplay];
    [self.contentLayer setNeedsDisplay];
}

- (void)layoutSublayers {
    [super layoutSublayers];

    self.overlayLayer.frame = self.bounds;
    self.contentLayer.frame = self.bounds;

    self.contentLayer.zPosition = 0;
    self.overlayLayer.zPosition = 1;
}

@end
