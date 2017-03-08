//
//  GVThreadBackgroundView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/6/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVThreadBackgroundView.h"
#import <tgmath.h>

#define USE_ELLIPSE_GRADIENT 0

@implementation GVThreadBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.threadBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
#if USE_ELLIPSE_GRADIENT
    // Drawing code
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)[UIColor colorWithRed:0.161 green:0.404 blue:0.600 alpha:1.000].CGColor,
                               (id)[UIColor colorWithRed:0.020 green:0.027 blue:0.216 alpha:1.000].CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);

    CGSize drawLayerSize;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        drawLayerSize = CGSizeMake(self.bounds.size.height, 368);
    } else {
        drawLayerSize = CGSizeMake(568, self.bounds.size.width);
    }
    CGLayerRef drawLayerRef = CGLayerCreateWithContext(context, drawLayerSize, NULL);

    CGContextRef drawLayerContext = CGLayerGetContext(drawLayerRef);


    //CGLayerRelease(drawLayerRef);

    //// Rectangle Drawing
    //UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: self.bounds];
    //CGContextSaveGState(context);
    //CGContextScaleCTM(context, 10, 0);
    //    [rectanglePath addClip];
    //    CGContextDrawRadialGradient(context, gradient,
    //                                CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) - 64), 0,
    //                                CGPointMake(CGRectGetMidX(self.frame), 64), 300,
    //                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

    //    CGContextDrawRadialGradient(context, gradient,
    //                                CGPointMake(CGRectGetMaxX(self.frame) + 20, CGRectGetMidY(self.frame) + 64), 0,
    //                                CGPointMake(CGRectGetMidX(self.frame) + 20, CGRectGetMidY(self.frame) + 64), 300,
    //                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    //

    //
    CGContextDrawRadialGradient(drawLayerContext, gradient,
                                CGPointMake(drawLayerSize.width/2, - 20), 0,
                                CGPointMake(drawLayerSize.width /2, (drawLayerSize.height / 2) - 20), 300,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextDrawLayerInRect(context, self.bounds, drawLayerRef);
    //CGContextRotateCTM(context, 1.5);
    //CGContextRestoreGState(context);
    //
    //    [[UIColor blackColor] setStroke];
    //    rectanglePath.lineWidth = 1;
    //    [rectanglePath stroke];

    //// Cleanup
    CGLayerRelease(drawLayerRef);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
#else
    // Drawing code
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)[UIColor colorWithRed:0.161 green:0.404 blue:0.600 alpha:1.000].CGColor,
                               (id)[UIColor colorWithRed:0.020 green:0.027 blue:0.216 alpha:1.000].CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);


    //// Rectangle Drawing
    //    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(39.5, 20.5, 73, 90)];
    //    CGContextSaveGState(context);
    //    [rectanglePath addClip];
    //    CGContextDrawRadialGradient(context, gradient,
    //                                CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) - 64), 0,
    //                                CGPointMake(CGRectGetMidX(self.frame), 64), 300,
    //                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

    //    CGContextDrawRadialGradient(context, gradient,
    //                                CGPointMake(CGRectGetMaxX(self.frame) + 20, CGRectGetMidY(self.frame) + 64), 0,
    //                                CGPointMake(CGRectGetMidX(self.frame) + 20, CGRectGetMidY(self.frame) + 64), 300,
    //                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    //


    CGContextDrawRadialGradient(context, gradient,
                                CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds) ), 0,
                                CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds) ), 300,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);


    //CGContextRestoreGState(context);
    //
    //    [[UIColor blackColor] setStroke];
    //    rectanglePath.lineWidth = 1;
    //    [rectanglePath stroke];
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
#endif
}


@end
