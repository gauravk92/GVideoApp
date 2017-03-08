//
//  GVCameraToolbar.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCameraToolbar.h"
#import "GVTintColorUtility.h"
#import "GVRadialGradientLayer.h"

@interface GVCameraToolbar ()

@property (nonatomic, strong) GVRadialGradientLayer *radialGradientLayer;

@end

@implementation GVCameraToolbar

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.layer.needsDisplayOnBoundsChange = NO;

        //self.layer.locations = @[(id)[]
        CAGradientLayer *l = (CAGradientLayer*)self.layer;
        l.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:1.0], (id)[UIColor clearColor]];

        UIColor *tintColor = [GVTintColorUtility utilityTintColor]; // [UIColor whiteColor];//[UIColor colorWithRed:0.235 green:0.205 blue:0.669 alpha:1.000]; //[UIColor colorWithRed:0.161 green:0.320 blue:0.669 alpha:1.000];//[UIColor colorWithRed:0.183 green:0.306 blue:0.466 alpha:1.000];//[UIColor colorWithRed:0.380 green:0.631 blue:0.965 alpha:1.000];//[GVTintColorUtility utilityTintColor];



        self.radialGradientLayer = [GVRadialGradientLayer layer];
        [self.radialGradientLayer setNeedsDisplay];
        self.radialGradientLayer.needsDisplayOnBoundsChange = NO;
        self.radialGradientLayer.toRadius = [NSNumber numberWithFloat:250];
        self.radialGradientLayer.contentsOriginPoint = [NSValue valueWithCGPoint:CGPointMake(0.5, 1)];
        self.radialGradientLayer.contentsOffset = [NSValue valueWithCGPoint:CGPointMake(0, 10)];
        self.radialGradientLayer.colorValues = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor];
        //self.layer.mask = self.radialGradientLayer;


        [self setNeedsDisplay];
    }
    return self;
}

- (void)flipAction:(id)sender {
    
}


- (void)layoutSubviews {
    [super layoutSubviews];





    self.radialGradientLayer.frame = CGRectIntegral(self.bounds);

}

//- (CGSize)sizeThatFits:(CGSize)size {
//    NSLog(@" size that fits");
//    return CGSizeMake(self.bounds.size.width, 100);
//}
//
//- (void)sizeToFit {
//    NSLog(@"size to fit called!!");
//    CGFloat height = 100;
//    self.frame = CGRectMake(0, self.bounds.size.height-height, self.bounds.size.width, height);
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
