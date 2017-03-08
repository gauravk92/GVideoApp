//
//  GVMasterTableViewCellGradientView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/9/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVMasterTableViewCellGradientView.h"

@implementation GVMasterTableViewCellGradientView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor* purpledark = [UIColor colorWithRed: 0 green: 0.05 blue: 0.36 alpha: 1];
    CGFloat purpledarkHSBA[4];
    [purpledark getHue: &purpledarkHSBA[0] saturation: &purpledarkHSBA[1] brightness: &purpledarkHSBA[2] alpha: &purpledarkHSBA[3]];

    //UIColor* purplelight = [UIColor colorWithHue: purpledarkHSBA[0] saturation: purpledarkHSBA[1] brightness: 0.1 alpha: purpledarkHSBA[3]];
    UIColor *purplelight = [UIColor colorWithRed:0.040 green:0.112 blue:0.192 alpha:1.000];
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)purplelight.CGColor,
                               (id)purpledark.CGColor, nil];
    CGFloat gradientLocations[] = {0.6, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);



    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 55), CGPointMake(0, rect.size.height), 0);
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}


@end
