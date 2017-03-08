//
//  CCARadialGradientLayer.m
//  CCARadialGradientLayer
//
//  Created by Jean-Luc Dagon on 19/01/2014.
//
//  Copyright (c) 2014 Cocoapps.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "GVSmoothRadialGradientLayer.h"



struct CCARadialGradientLayerProperties
{
    __unsafe_unretained NSString *gradientOrigin;
    __unsafe_unretained NSString *gradientRadius;
    __unsafe_unretained NSString *colors;
    __unsafe_unretained NSString *locations;
};

const struct CCARadialGradientLayerProperties CCARadialGradientLayerProperties = {
	.gradientOrigin = @"gradientOrigin",
    .gradientRadius = @"gradientRadius",
    .colors = @"colors",
    .locations = @"locations",
};

@implementation GVSmoothRadialGradientLayer

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

- (BOOL)needsDisplayOnBoundsChange {
    return YES;
}

- (void)drawInContext1:(CGContextRef)theContext
{

    if (!self.locations) {
        self.locations = @[@0, @1];
    }
    if (!self.colors) {
        self.colors = @[(id)[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:1.0].CGColor,
                        (id)[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.0].CGColor];

    }

    NSInteger numberOfLocations = self.locations.count;
    NSInteger numbOfComponents = 0;
    //CGColorSpaceRef colorSpace = NULL;

    CGColorRef colorRef = (__bridge CGColorRef)[self.colors objectAtIndex:0];
    numbOfComponents = CGColorGetNumberOfComponents(colorRef);
    //colorSpace = CGColorSpaceCreateDeviceRGB();

    CGFloat gradientLocations[numberOfLocations];
    CGFloat gradientComponents[numberOfLocations * numbOfComponents];


    

    for (NSInteger locationIndex = 0; locationIndex < numberOfLocations; locationIndex++) {

        gradientLocations[locationIndex] = [self.locations[locationIndex] floatValue];
        const CGFloat *colorComponents = CGColorGetComponents((CGColorRef)self.colors[locationIndex]);

        for (NSInteger componentIndex = 0; componentIndex < numbOfComponents; componentIndex++) {
            gradientComponents[numbOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex];
        }
    }

    CGPoint contentsOriginPoint = CGPointMake(0.5, 0.5);
    if (self.contentsOriginPoint) {
        contentsOriginPoint = [self.contentsOriginPoint CGPointValue];
    }

    CGPoint radialPoint = CGPointMake(0.0, 0.0);
    if (contentsOriginPoint.x < 0.1) {
        radialPoint.x = CGRectGetMinX(self.bounds);
    } else if (contentsOriginPoint.x < 0.6) {
        radialPoint.x = CGRectGetMidX(self.bounds);
    } else {
        radialPoint.x = CGRectGetMaxX(self.bounds);
    }

    if (contentsOriginPoint.y < 0.1) {
        radialPoint.y = CGRectGetMinY(self.bounds);
    } else if (contentsOriginPoint.y < 0.6) {
        radialPoint.y = CGRectGetMidY(self.bounds);
    } else {
        radialPoint.y = CGRectGetMaxY(self.bounds);
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

    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (CFArrayRef)self.colors, NULL);
    CGContextDrawRadialGradient(theContext, gradient,
                                CGPointMake(contentsOriginPoint.x, contentsOriginPoint.y), fromRadius,
                                CGPointMake(contentsOriginPoint.x, contentsOriginPoint.y), toRadius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

@end
