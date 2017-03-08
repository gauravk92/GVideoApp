//
//  GVWelcomeImageView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/24/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVWelcomeImageView.h"
#import "GVBubbleMaskLayer.h"

@interface GVWelcomeImageView ()

@property (nonatomic, strong) CALayer *shapeLayer;
@property (nonatomic, strong) GVBubbleMaskLayer *shapeMaskLayer;

@end

@implementation GVWelcomeImageView


- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        CGFloat widthRatio = .75;
        CGFloat topOriginOffset = -40;
        
        self.lowOpacity = 0.0;
        self.highOpacity = 0.55;
        
        self.fadeInDuration = 0.3;
        self.fadeOutDuration = 0.3;
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, widthRatio, widthRatio);
        self.transform = CGAffineTransformTranslate(self.transform, 0, topOriginOffset);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowRadius = 8;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.needsDisplayOnBoundsChange = NO;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
       
        _shapeLayer = [CALayer layer];
        _shapeLayer.needsDisplayOnBoundsChange = NO;
        _shapeLayer.opacity = self.lowOpacity;
        _shapeLayer.shouldRasterize = YES;
        _shapeLayer.rasterizationScale = [UIScreen mainScreen].scale;
        _shapeLayer.backgroundColor = [UIColor blackColor].CGColor;
        _shapeLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_shapeLayer];
        
        _shapeMaskLayer = [GVBubbleMaskLayer layer];
        _shapeMaskLayer.needsDisplayOnBoundsChange = NO;
        _shapeMaskLayer.opacity = 1;
        _shapeMaskLayer.shouldRasterize = YES;
        _shapeMaskLayer.rasterizationScale = [UIScreen mainScreen].scale;
        _shapeMaskLayer.contentsScale = [UIScreen mainScreen].scale;
        
        _shapeLayer.mask = _shapeMaskLayer;
    }
    return self;
}

- (CGSize)realSize {
    return CGRectApplyAffineTransform(self.bounds, self.transform).size;
}

- (void)setFrameAndShadowPath:(CGRect)rect {
    self.frame = CGRectIntegral(rect);
    self.shapeLayer.frame = CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    self.shapeMaskLayer.frame = CGRectIntegral(self.shapeLayer.bounds);

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height))];
    [bezierPath setFlatness:0.0];
    self.layer.shadowPath = bezierPath.CGPath;
    
}

- (void)animateMaskFadeIn {
    if (!self.shapeLayer.opacity > 0.5) {
        self.shapeLayer.opacity = self.highOpacity;
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        basicAnimation.fromValue = (CGFLOAT_IS_DOUBLE ? [NSNumber numberWithDouble:self.lowOpacity] : [NSNumber numberWithFloat:self.lowOpacity]);
        basicAnimation.toValue = (CGFLOAT_IS_DOUBLE ? [NSNumber numberWithDouble:self.highOpacity] : [NSNumber numberWithFloat:self.highOpacity]);
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.duration = self.fadeInDuration;
        basicAnimation.fillMode = kCAFillModeBoth;
        [self.shapeLayer addAnimation:basicAnimation forKey:nil];
    }
}

- (void)animateMaskFadeOut {
    if (!self.shapeLayer.opacity < 0.5) {
        self.shapeLayer.opacity = self.lowOpacity;
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        basicAnimation.fromValue = (CGFLOAT_IS_DOUBLE ? [NSNumber numberWithDouble:self.highOpacity] : [NSNumber numberWithFloat:self.highOpacity]);
        basicAnimation.toValue = (CGFLOAT_IS_DOUBLE ? [NSNumber numberWithDouble:self.lowOpacity] : [NSNumber numberWithFloat:self.lowOpacity]);
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.duration = self.fadeOutDuration;
        basicAnimation.fillMode = kCAFillModeBoth;
        [self.shapeLayer addAnimation:basicAnimation forKey:nil];
    }
}

- (void)setFirstBubbleRounding:(BOOL)round secondBubbleRounding:(BOOL)round1 {
    self.shapeMaskLayer.firstBubbleRounding = [NSNumber numberWithBool:round];
    self.shapeMaskLayer.secondBubbleRounding = [NSNumber numberWithBool:round1];
}

- (void)setFirstBubble:(CGRect)rect secondBubble:(CGRect)rect1 {
    self.shapeMaskLayer.firstBubble = [NSValue valueWithCGRect:rect];
    self.shapeMaskLayer.secondBubble = [NSValue valueWithCGRect:rect1];
    [self.shapeMaskLayer setNeedsDisplay];
}

- (void)addThirdRegion:(CGRect)region fourthRegion:(CGRect)region1 {
    self.shapeMaskLayer.thirdBubble = [NSValue valueWithCGRect:region];
    self.shapeMaskLayer.fourthBubble = [NSValue valueWithCGRect:region1];
}

@end
