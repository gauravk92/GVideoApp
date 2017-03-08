//
//  GVBubbleMaskLayer.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/24/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVBubbleMaskLayer.h"

@implementation GVBubbleMaskLayer

- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetAllowsAntialiasing(ctx, YES);
    CGContextSetFlatness(ctx, 0.0);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    
    UIBezierPath *maskLayerPath = [UIBezierPath bezierPath];
    [maskLayerPath setFlatness:0.0];

    UIBezierPath *fillPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [fillPath setFlatness:0.0];
    [maskLayerPath appendPath:fillPath];

    CGRect firstRect = [self.firstBubble CGRectValue];
    
    BOOL firstRound = YES;
    if (self.firstBubbleRounding) {
        firstRound = [self.firstBubbleRounding boolValue];
    }
    UIBezierPath *firstPath = nil;
    if (firstRound) {
        firstPath = [UIBezierPath bezierPathWithRoundedRect:firstRect cornerRadius:firstRect.size.width/2];
        [firstPath setFlatness:0.0];
    } else {
        firstPath = [UIBezierPath bezierPathWithRect:firstRect];
        [firstPath setFlatness:1.0];
    }
    [maskLayerPath appendPath:firstPath];

    CGRect secondRect = [self.secondBubble CGRectValue];
    BOOL secondRound = YES;
    if (self.secondBubbleRounding) {
        secondRound = [self.secondBubbleRounding boolValue];
    }
    UIBezierPath *secondPath = nil;
    if (secondRound) {
        secondPath = [UIBezierPath bezierPathWithRoundedRect:secondRect cornerRadius:secondRect.size.width/2];
        [secondPath setFlatness:0.0];
    } else {
        secondPath = [UIBezierPath bezierPathWithRect:secondRect];
        [secondPath setFlatness:1.0];
    }
    [maskLayerPath appendPath:secondPath];
    
    
    if (self.thirdBubble) {
        UIBezierPath *thirdPath = [UIBezierPath bezierPathWithRect:[self.thirdBubble CGRectValue]];
        [maskLayerPath appendPath:thirdPath];
    }
    
    if (self.fourthBubble) {
        UIBezierPath *fourthPath = [UIBezierPath bezierPathWithRect:[self.fourthBubble CGRectValue]];
        [maskLayerPath appendPath:fourthPath];
    }
    
    
    
    CGContextBeginPath(ctx);
    CGContextAddPath(ctx, maskLayerPath.CGPath);
    CGContextDrawPath(ctx, kCGPathEOFill);
}

@end
