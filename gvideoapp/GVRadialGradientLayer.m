//
//  GVRadialGradientLayer.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/11/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVRadialGradientLayer.h"

#define SMOOTHING 0

@interface GVRadialGradientLayer ()

@property (nonatomic, assign, readwrite) BOOL animateShine;

@end

@implementation GVRadialGradientLayer


//- (BOOL)shouldRasterize {
//    return YES;
//}
//
//- (CGFloat)rasterizationScale {
//    return [UIScreen mainScreen].scale;
//}
//
//- (BOOL)needsDisplayOnBoundsChange {
//    return YES;
//}

//- (CGFloat)contentsScale {
//    return [UIScreen mainScreen].scale;
//}

//+ (BOOL)needsDisplayForKey:(NSString *)key
//{
//    if ([key isEqualToString:CCARadialGradientLayerProperties.gradientOrigin]
//        || [key isEqualToString:CCARadialGradientLayerProperties.gradientRadius]
//        || [key isEqualToString:CCARadialGradientLayerProperties.colors]
//        || [key isEqualToString:CCARadialGradientLayerProperties.locations])
//    {
//        return YES;
//    }
//    return [super needsDisplayForKey:key];
//}
//
//- (id)actionForKey:(NSString *) key
//{
//    if ([key isEqualToString:CCARadialGradientLayerProperties.gradientOrigin]
//        || [key isEqualToString:CCARadialGradientLayerProperties.gradientRadius]
//        || [key isEqualToString:CCARadialGradientLayerProperties.colors]
//        || [key isEqualToString:CCARadialGradientLayerProperties.locations])
//    {
//        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:key];
//        theAnimation.fromValue = [self.presentationLayer valueForKey:key];
//        return theAnimation;
//    }
//    return [super actionForKey:key];
//}

- (void)setupAnimateShine {
    self.animateShine = YES;

    
}

- (void)animateShineNow {

}

- (void)drawInContext:(CGContextRef)ctx {
    //CGContextSetAllowsAntialiasing(ctx, true);
    //CGContextSetShouldAntialias(ctx, true);
    CGContextSetRenderingIntent(ctx, kCGRenderingIntentAbsoluteColorimetric);

    //CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);

    // Drawing code

    CGRect bounds = self.bounds;
    if (self.contentsDrawRectFrame) {
        bounds = [self.contentsDrawRectFrame CGRectValue];
    }

    //// General Declarations

    //CGContextRef context = UIGraphicsGetCurrentContext();

    //// Gradient Declarations
    NSArray* gradientColors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor];
    if (self.colorValues) {
        gradientColors = self.colorValues;
    }
    CGFloat gradientLocations[] = {0, 1};

    CGColorRef aColor = [UIColor whiteColor].CGColor;
    if (gradientColors) {
        aColor = (__bridge CGColorRef)[gradientColors objectAtIndex:0];
    }
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(aColor);

    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (CFArrayRef)gradientColors, gradientLocations);

    CGPoint contentsOriginPoint = CGPointMake(0.5, 0.5);
    if (self.contentsOriginPoint) {
        contentsOriginPoint = [self.contentsOriginPoint CGPointValue];
    }

    // SMOOTHING BY SCALING *2

    CGFloat scalingFactor = 2 * [UIScreen mainScreen].scale;

    CGRect smoothRect = CGRectMake(0, 0, self.bounds.size.width * scalingFactor, self.bounds.size.height * scalingFactor);
    CGSize drawLayerSize = CGSizeMake(self.bounds.size.width * scalingFactor, self.bounds.size.height * scalingFactor);

    
    CGPoint radialPoint = CGPointMake(0, 0);
    CGPoint smoothingPoint = CGPointMake(0, 0);
    if (contentsOriginPoint.x < 0.1) {
        radialPoint.x = CGRectGetMinX(bounds);
        smoothingPoint.x = CGRectGetMinX(smoothRect);
    } else if (contentsOriginPoint.x < 0.6) {
        radialPoint.x = CGRectGetMidX(bounds);
        smoothingPoint.x = CGRectGetMidX(smoothRect);
    } else {
        radialPoint.x = CGRectGetMaxX(bounds);
        smoothingPoint.x = CGRectGetMaxX(smoothRect);
    }

    if (contentsOriginPoint.y < 0.1) {
        radialPoint.y = CGRectGetMinY(bounds);
        smoothingPoint.y = CGRectGetMinY(smoothRect);
    } else if (contentsOriginPoint.y < 0.6) {
        radialPoint.y = CGRectGetMidY(bounds);
        smoothingPoint.y = CGRectGetMidY(smoothRect);
    } else {
        radialPoint.y = CGRectGetMaxY(bounds);
        smoothingPoint.y = CGRectGetMaxY(smoothRect);
    }

    CGPoint contentOffset = CGPointMake(0, 0);
    if (self.contentsOffset) {
        contentOffset = [self.contentsOffset CGPointValue];
    }

    CGFloat fromRadius = 0;
    if (self.fromRadius) {
        fromRadius = [self.fromRadius floatValue];
    }

    CGFloat toRadius = 10;
    if (self.toRadius) {
        toRadius = [self.toRadius floatValue];
    }

#if SMOOTHING

    CGContextSaveGState(ctx);

    CGLayerRef drawLayerRef = CGLayerCreateWithContext(ctx, drawLayerSize, NULL);

    CGContextRef drawLayerContext = CGLayerGetContext(drawLayerRef);
    CGContextSetInterpolationQuality(drawLayerContext, kCGInterpolationHigh);
    
    CGContextDrawRadialGradient(drawLayerContext, gradient,
                                CGPointMake(smoothingPoint.x, smoothingPoint.y + (contentOffset.y*2)), fromRadius*2,
                                CGPointMake(smoothingPoint.y, smoothingPoint.y + (contentOffset.y*2)), toRadius*2,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(ctx);
    CGContextDrawLayerInRect(ctx, bounds, drawLayerRef);

    CGLayerRelease(drawLayerRef);

#else
    CGContextDrawRadialGradient(ctx, gradient,
                                CGPointMake(radialPoint.x, radialPoint.y + contentOffset.y), fromRadius,
                                CGPointMake(radialPoint.x, radialPoint.y + contentOffset.y), toRadius,
                                kCGGradientDrawsAfterEndLocation);
#endif
    //// Cleanup
    CGGradientRelease(gradient);
    //CGColorSpaceRelease(colorSpace);

}

@end
