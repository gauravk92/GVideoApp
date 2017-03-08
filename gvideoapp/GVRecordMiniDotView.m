//
//  GVRecordMiniDotView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVRecordMiniDotView.h"
//#import "UIView+AnimatedProperty.h"
#import <tgmath.h>

@interface GVRecordMiniDotView ()

@end

@implementation GVRecordMiniDotView

//- (CGFloat)cornerRadius {
//    return self.layer.cornerRadius;
//}
//
//- (void)setCornerRadius:(CGFloat)cornerRadius {
//    if ([UIView currentAnimation]) {
//        [[UIView currentAnimation] animateLayer:self.layer keyPath:@"cornerRadius" toValue:@(cornerRadius)];
//    }
//    else {
//        self.layer.cornerRadius = cornerRadius;
//    }
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor redColor];
//        self.colorView = [[UIView alloc] initWithFrame:frame];
//        self.colorView.backgroundColor = [UIColor redColor];
//        self.colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.colorView.translatesAutoresizingMaskIntoConstraints = NO;
//        [self addSubview:self.colorView];
//        //self.layer.shouldRasterize = YES;
//        self.colorView.alpha = 0.9;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat cRadius = round(self.bounds.size.width / 2);
    //[self setCornerRadius:cRadius];
    self.layer.cornerRadius = cRadius;
    self.clipsToBounds = YES;
    

    //self.colorView.frame = self.bounds;

//    CAShapeLayer *l = [CAShapeLayer layer];
//    l.frame = self.bounds;
//    l.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(cRadius, cRadius)].CGPath;
//    self.layer.mask = l;

    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = self.bounds;
    gl.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:0.7].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:1.0].CGColor, nil];
    gl.startPoint = CGPointMake(0.0f,-0.2f);
    gl.endPoint = CGPointMake(0.0, 1.2f);
    //self.colorView.layer.mask = gl;
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
