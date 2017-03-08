//
//  GVShiningRadialGradientLayer.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/14/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVShiningRadialGradientLayer.h"

@interface GVShiningRadialGradientLayer ()

@property (nonatomic, strong) CAShapeLayer *leftShape;
@property (nonatomic, strong) CAShapeLayer *rightShape;

@end

@implementation GVShiningRadialGradientLayer
//
//- (BOOL)needsDisplayOnBoundsChange {
//    return YES;
//}

- (void)setupInitialState {
    // self.transform = CATransform3DTranslate(CATransform3DIdentity, -(self.bounds.size.height), 0, 0);
//    [self setNeedsDisplay];
//    [self displayIfNeeded];
    self.opacity = 0.0;
    [self setNeedsDisplay];
}

//- (void)drawInContext:(CGContextRef)ctx {
//
////    CGRect bound = CGContextGetClipBoundingBox(ctx);
////    [[UIColor whiteColor] setFill];
////    CGContextFillRect(ctx, bound);
//
//    [super drawInContext:ctx];
//}

//- (void)layoutSublayers {
//    [super layoutSublayers];
//
//    self.leftShape.frame = CGRectMake(-(self.bounds.size.width), 0, self.bounds.size.width, self.bounds.size.height);
//    self.rightShape.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
//}

//- (void)setNeedsDisplay {
//    [super setNeedsDisplay];
//
//    [self.leftShape setNeedsDisplay];
//    [self.rightShape setNeedsDisplay];
//}

- (void)animateShineNow {

    //CAAnimationGroup *groupAnim = [CAAnimationGroup animation];
    //groupAnim.duration = 3.5;
    //groupAnim.removedOnCompletion = NO;
    //groupAnim.fillMode = kCAFillModeForwards;
    //self.opacity = 1.0;

    for (CALayer *layer in self.sublayers) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }

    [self removeAllAnimations];

    CATransform3D fromTransform = CATransform3DIdentity;
    self.transform = CATransform3DTranslate(fromTransform, -(self.bounds.size.width), 0, 0);

    UIColor *normalColor = [UIColor colorWithWhite:1.0 alpha:0.3];

    CAShapeLayer *leftShape = [CAShapeLayer layer];
    self.leftShape = leftShape;
    //leftShape.needsDisplayOnBoundsChange = YES;
    leftShape.frame = CGRectMake(-(self.bounds.size.width), 0, self.bounds.size.width, self.bounds.size.height);
    leftShape.fillColor = normalColor.CGColor;
    leftShape.backgroundColor = normalColor.CGColor;
    CAShapeLayer *rightShape = [CAShapeLayer layer];
    self.rightShape = rightShape;
    rightShape.fillColor = normalColor.CGColor;
    //rightShape.needsDisplayOnBoundsChange = YES;
    rightShape.backgroundColor = normalColor.CGColor;
    rightShape.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);




    //[self addSublayer:leftShape];
    //[self addSublayer:rightShape];
    //self.needsDisplayOnBoundsChange = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [leftShape setNeedsDisplay];
    [rightShape setNeedsDisplay];
    [self setNeedsDisplay];

    CABasicAnimation *opacAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacAnim.fromValue = [NSNumber numberWithFloat:0.0];
    opacAnim.toValue = [NSNumber numberWithFloat:1.0];
    opacAnim.duration = 1.0;
    //opacAnim.fillMode = kCAFillModeForwards;
    //opacAnim.removedOnCompletion = NO;
    opacAnim.delegate = self;

    self.opacity = 1.0;

    [self removeAllAnimations];

//    CATransform3D fromTransform = CATransform3DIdentity;
//    fromTransform = CATransform3DTranslate(fromTransform, -(self.bounds.size.width), 0, 0);
//
//    CATransform3D toTransform = CATransform3DIdentity;
//    toTransform = CATransform3DTranslate(toTransform, self.bounds.size.width, 0, 0);
//
//    CABasicAnimation *textMaskSlide = [CABasicAnimation animationWithKeyPath:@"transform"];
//    textMaskSlide.fromValue = [NSValue valueWithCATransform3D:fromTransform];
//    textMaskSlide.toValue = [NSValue valueWithCATransform3D:toTransform];
//    textMaskSlide.beginTime = 0.0;
//    textMaskSlide.duration = 3.5;
//    //textMaskSlide.timeOffset = [self convertTime:(CACurrentMediaTime() + textMaskSlide.beginTime) toLayer:nil];
//    textMaskSlide.fillMode = kCAFillModeBoth;
//    //textMaskSlide.autoreverses = YES;
//    textMaskSlide.repeatCount = 999999;
//    textMaskSlide.repeatDuration = 99999;
//    textMaskSlide.timingFunction = [CAMediaTimingFunction functionWithName:@"easeOut"];
//    textMaskSlide.removedOnCompletion = NO;


    //[groupAnim setAnimations:@[opacAnim, textMaskSlide]];

    //[self addAnimation:textMaskSlide forKey:nil];

    [self addAnimation:opacAnim forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        //anim.delegate = nil;
        self.opacity = 1.0;

        [self removeAllAnimations];

        CATransform3D fromTransform = CATransform3DIdentity;
        fromTransform = CATransform3DTranslate(fromTransform, -(self.bounds.size.width), 0, 0);

        CATransform3D toTransform = CATransform3DIdentity;
        toTransform = CATransform3DTranslate(toTransform, self.bounds.size.width, 0, 0);

        CABasicAnimation *textMaskSlide = [CABasicAnimation animationWithKeyPath:@"transform"];
        textMaskSlide.fromValue = [NSValue valueWithCATransform3D:fromTransform];
        textMaskSlide.toValue = [NSValue valueWithCATransform3D:toTransform];

        textMaskSlide.duration = 4.0;
        textMaskSlide.beginTime = 0.0;
        textMaskSlide.timeOffset = 0.0;
        textMaskSlide.fillMode = kCAFillModeForwards;
        //textMaskSlide.autoreverses = YES;
        textMaskSlide.repeatCount = 999999;
        textMaskSlide.repeatDuration = 99999;
        textMaskSlide.timingFunction = [CAMediaTimingFunction functionWithName:@"easeOut"];
        textMaskSlide.removedOnCompletion = NO;


        //[groupAnim setAnimations:@[opacAnim, textMaskSlide]];

        [self addAnimation:textMaskSlide forKey:nil];
    }
}

@end
