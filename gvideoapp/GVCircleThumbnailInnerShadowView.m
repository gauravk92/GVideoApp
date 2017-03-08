//
//  GVCircleThumbnailInnerShadowView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCircleThumbnailInnerShadowView.h"

@interface GVCircleThumbnailInnerShadowView () <UIToolbarDelegate>

@end

@implementation GVCircleThumbnailInnerShadowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        @autoreleasepool {
            [self setupThumbnailView:frame];
        }

    }
    return self;
}

- (void)setupThumbnailView:(CGRect)frame {

    self.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
    //self.layer.shouldRasterize = YES;
    //self.layer.rasterizationScale = [UIScreen mainScreen].scale;

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
    self.imageView.opaque = YES;
    self.imageView.layer.opaque = YES;
    [self addSubview:self.imageView];

    //self.detailToolbar = [[UIToolbar alloc] initWithFrame:frame];
    self.detailToolbar.barStyle = UIBarStyleBlack;
    //self.detailToolbar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    self.detailToolbar.barTintColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    self.detailToolbar.translucent = NO;
    self.detailToolbar.delegate = self;
    self.detailToolbar.alpha = 0.8;
    self.detailToolbar.tintColor = [UIColor whiteColor];
    self.detailToolbar.userInteractionEnabled = NO;
    //self.detailToolbar.layer.shouldRasterize = YES;
    //self.detailToolbar.layer.rasterizationScale = [UIScreen mainScreen].scale;

    //self.detailToolbar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];


//    UIBarButtonItem *usernameItem = [[UIBarButtonItem alloc] initWithTitle:@"gauravk92" style:UIBarButtonItemStylePlain target:nil action:NULL];
//    usernameItem.enabled = NO;
//
//    self.detailToolbar.items = @[usernameItem];

    //[self insertSubview:self.detailToolbar aboveSubview:self.imageView];


    //UIColor *lightBlueColor = [UIColor colorWithRed:0.079 green:0.832 blue:1.000 alpha:1.000];
    //UIColor *pinkColor = [UIColor colorWithRed:0.894 green:0.532 blue:0.793 alpha:1.000];
    //UIColor *lightPinkColor = [UIColor colorWithRed:0.921 green:0.675 blue:0.849 alpha:1.000];

    //self.layer.borderWidth = 2.5;
    //self.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    //self.layer.shouldRasterize = YES;

//        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
//            self.layer.borderColor = [UIColor blueColor].CGColor;
//        }completion:nil];

    //self.clipsToBounds = YES;

    //CABasicAnimation *color = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    // animate from red to blue border ...
    //color.fromValue = (id)[UIColor whiteColor].CGColor;
    //color.toValue   = (id)lightBlueColor.CGColor;
    // ... and change the model value
    //self.layer.backgroundColor = [UIColor blueColor].CGColor;

    //CABasicAnimation *width = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    // animate from 2pt to 4pt wide border ...
    //width.fromValue = @2;
    //width.toValue   = @4;
    // ... and change the model value
    //self.layer.borderWidth = 4;

//    CAAnimationGroup *both = [CAAnimationGroup animation];
//    // animate both as a group with the duration of 0.5 seconds
//    both.duration   = 1.0;
//    both.animations = @[color];
//    // optionally add other configuration (that applies to both animations)
//    both.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    both.repeatDuration = 99999;
//    both.removedOnCompletion = NO;
//    both.autoreverses = YES;
//    //[self.layer addAnimation:both forKey:@"color and width"];


}

- (void)animateBorder {
//    [UIView animateKeyframesWithDuration:1.0 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionBeginFromCurrentState | UIViewKeyframeAnimationOptionRepeat animations:^{
//        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
//            self.layer.borderColor = [UIColor whiteColor].CGColor;
//            self.layer.borderWidth = 5;
//        }];
//        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
//            self.layer.borderColor = [UIColor blueColor].CGColor;
//            self.layer.borderWidth = 2.5;
//        }];
//    }completion:nil];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTop;
}

- (void)arrangeSubviews {
    [self bringSubviewToFront:self.detailToolbar];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self arrangeSubviews];

    self.imageView.frame = CGRectIntegral(self.bounds);

    CGFloat detailToolBarHeight = 44;
    CGFloat detailToolbarPadding = 7;
    

    self.detailToolbar.frame = CGRectIntegral(CGRectMake(-detailToolbarPadding, self.bounds.size.height - detailToolBarHeight, self.bounds.size.width + detailToolbarPadding, detailToolBarHeight));

//    if ([self.detailToolbar.items count] > 0) {
//        UIBarButtonItem *userItem = self.detailToolbar.items[0];
//        UIBarButtonItem *timeItem = self.detailToolbar.items[2];
//
//        NSDictionary *userAttrs = [userItem titleTextAttributesForState:UIControlStateNormal];
//        NSAttributedString *userString = [[NSAttributedString alloc] initWithString:userItem.title attributes:userAttrs];
//        CGSize usernameSize = [userString size];
//
//        NSDictionary *timeAttrs = [timeItem titleTextAttributesForState:UIControlStateNormal];
//        NSAttributedString *timeString = [[NSAttributedString alloc] initWithString:timeItem.title attributes:timeAttrs];
//        CGSize timeSize = [timeString size];
//
//        if (usernameSize.width + timeSize.width  > self.bounds.size.width) {
//            userItem.width = self.bounds.size.width - timeSize.width;
//        }
//    }

    self.layer.cornerRadius = 1;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 1;
    //self.layer.cornerRadius = 1;

    CAShapeLayer *l = [CAShapeLayer layer];
    l.frame = CGRectIntegral(self.bounds);
    l.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(1, 1)].CGPath;
    self.layer.mask = l;

    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectIntegral(self.detailToolbar.bounds);
    gl.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gl.startPoint = CGPointMake(0.0f, 0.1f);
    gl.endPoint = CGPointMake(0.0, 1.2f);
    self.detailToolbar.layer.mask = gl;

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    //// General Declarations
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    //// Shadow Declarations
//    CGColorRef shadow = [UIColor blackColor].CGColor;
//    CGSize shadowOffset = CGSizeMake(0, -2);
//    CGFloat shadowBlurRadius = 5;
//
//
//    //// Oval Drawing
//    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: self.bounds];
//    [[UIColor clearColor] setFill];
//    [ovalPath fill];
//
//    ////// Oval Inner Shadow
//    CGRect ovalBorderRect = CGRectInset([ovalPath bounds], -shadowBlurRadius, -shadowBlurRadius);
//    ovalBorderRect = CGRectOffset(ovalBorderRect, -shadowOffset.width, -shadowOffset.height);
//    ovalBorderRect = CGRectInset(CGRectUnion(ovalBorderRect, [ovalPath bounds]), -1, -1);
//
//    UIBezierPath* ovalNegativePath = [UIBezierPath bezierPathWithRect: ovalBorderRect];
//    [ovalNegativePath appendPath: ovalPath];
//    ovalNegativePath.usesEvenOddFillRule = YES;
//
//    CGContextSaveGState(context);
//    {
//        CGFloat xOffset = shadowOffset.width + round(ovalBorderRect.size.width);
//        CGFloat yOffset = shadowOffset.height;
//        CGContextSetShadowWithColor(context,
//                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
//                                    shadowBlurRadius,
//                                    shadow);
//
//        [ovalPath addClip];
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(ovalBorderRect.size.width), 0);
//        [ovalNegativePath applyTransform: transform];
//        [[UIColor grayColor] setFill];
//        [ovalNegativePath fill];
//    }
//    CGContextRestoreGState(context);
//    
//
//}


@end
