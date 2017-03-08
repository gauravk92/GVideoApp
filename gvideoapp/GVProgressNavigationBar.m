//
//  GVProgressNavigationBar.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/31/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVProgressNavigationBar.h"
#import "GVProgressView.h"

@interface GVProgressNavigationBar ()

@property (nonatomic, strong) GVProgressView *progressView;
@property (nonatomic, strong) UILabel *startTextLabel;
@property (nonatomic, strong) NSAttributedString *startString;
@property (nonatomic, strong) NSAttributedString *stopString;

@property (nonatomic, strong) UIView *borderView;

@end

@implementation GVProgressNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.progressView = [[GVProgressView alloc] initWithFrame:frame];
        self.progressView.layer.shouldRasterize = YES;
        self.progressView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self addSubview:self.progressView];

        self.borderView = [[UIView alloc] initWithFrame:frame];
        self.borderView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        [self addSubview:self.borderView];

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;

        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];

        NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                     NSFontAttributeName: font};

        NSString *stopText = @"Tap the screen to stop recording";

        self.startString = [[NSAttributedString alloc] initWithString:@"Tap the screen to start recording" attributes:attributes];

        self.stopString = [[NSAttributedString alloc] initWithString:stopText attributes:attributes];

        self.startTextLabel = [[UILabel alloc] initWithFrame:frame];
        [self.startTextLabel setAttributedText:self.startString];
        self.startTextLabel.layer.shouldRasterize = YES;
        self.startTextLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self addSubview:self.startTextLabel];


    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.layoutWithoutNavigationController) {
        self.startTextLabel.frame = CGRectIntegral(CGRectMake(0, 20, self.bounds.size.width, self.bounds.size.height - 20));
    } else {
        self.startTextLabel.frame = CGRectIntegral(self.bounds);
    }

    self.borderView.frame = CGRectIntegral(CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0.5));

    [self bringSubviewToFront:self.progressView];
}
//
//- (CGSize)sizeThatFits:(CGSize)size {
//    CGSize newSize;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        newSize = CGSizeMake(self.frame.size.width, 36);
//    }
//    newSize = CGSizeMake(self.frame.size.width,30);
//    return newSize;
//}

//- (void)finishProgressBarAnimation {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        CGRect progressToolbarFrame = self.frame;
//        CGRect beforeFrame = CGRectMake(0, 0, progressToolbarFrame.size.width, progressToolbarFrame.size.height);
//        //CGRect startFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//        //CGRect midFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//        //startFrame.origin.x += 100;
//        beforeFrame.origin.x += beforeFrame.size.width;
//        //midFrame.origin.x += 300;
//        [self.progressView.layer removeAllAnimations];
//        [UIView animateWithDuration:1.0
//                              delay:0.0
//             usingSpringWithDamping:0.8
//              initialSpringVelocity:0.0
//                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
//                         animations:^{
//                             @strongify(self);
//                             self.progressView.frame = beforeFrame;
//                         } completion:nil];
//    });
//}

//- (void)setupProgressBarAnimated {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        [self.progressView.layer removeAllAnimations];
//        CGRect boundFrame = self.frame;
//        CGRect frame = CGRectMake(boundFrame.origin.x, 0, boundFrame.size.width, boundFrame.size.height);
//        self.progressView.frame = frame;
//        CGRect afterFrame = CGRectMake(0, 0, boundFrame.size.width, boundFrame.size.height);
//        [UIView animateWithDuration:0.25
//                              delay:0.0
//             usingSpringWithDamping:0.8
//              initialSpringVelocity:0.0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                                  @strongify(self);
//                                  self.progressView.frame = afterFrame;
//                              } completion:^(BOOL finished) {
//                                  if (finished) {
//                                      [self startProgressBarAnimated];
//                                  }
//                              }];
//    });
//}

- (void)startProgressBarAnimated {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.progressView.layer removeAllAnimations];
        CGRect boundFrame = self.frame;
        CGRect frame = CGRectMake(0, 0, boundFrame.size.width, boundFrame.size.height);
        self.progressView.frame = frame;
        CGRect afterFrame = CGRectMake(boundFrame.size.width, 0, boundFrame.size.width, boundFrame.size.height);
        CABasicAnimation *tweenAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        tweenAnimation.duration = 30;
        tweenAnimation.fromValue = [NSNumber numberWithFloat:frame.origin.x];
        tweenAnimation.toValue = [NSNumber numberWithFloat:afterFrame.origin.x];
        tweenAnimation.removedOnCompletion = YES;
        tweenAnimation.fillMode = kCAFillModeForwards;
        [self.progressView.layer addAnimation:tweenAnimation forKey:@"animateLayer"];
//        [UIView animateWithDuration:30
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionOverrideInheritedOptions
//                         animations:^{
//                             @strongify(self);
//                             self.progressView.frame = afterFrame;
//                         } completion:nil];
    });
}

- (void)finishProgressBarAnimated {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        //[self.progressView.layer removeAllAnimations];
        //[self.progressView.layer removeAllAnimations];
        CGRect boundFrame = self.bounds;
        //CGRect frame = CGRectMake(boundFrame.size.width, 0, boundFrame.size.width, boundFrame.size.height);
        //self.progressView.frame = frame;
        CGRect afterFrame = CGRectMake(boundFrame.size.width, 0, boundFrame.size.width, boundFrame.size.height);
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             @strongify(self);
                             self.progressView.frame = afterFrame;
                         } completion:nil];
    });
}

- (void)fillProgressBarAnimated {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        //self.startTextLabel.hidden = YES;
        //self.stopTextLabel.hidden = NO;
        [self.progressView.layer removeAllAnimations];
        CGRect boundFrame = self.bounds;
        CGRect frame = CGRectMake(boundFrame.size.width, 0, boundFrame.size.width, boundFrame.size.height);
        //self.progressView.contentView.frame = frame;
        self.progressView.frame = frame;
        CGRect afterFrame = CGRectMake(0, 0, boundFrame.size.width, boundFrame.size.height);
//        CABasicAnimation *tweenAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
//        tweenAnimation.duration = 0.5;
//        tweenAnimation.fromValue = [NSNumber numberWithFloat:frame.origin.x];
//        tweenAnimation.toValue = [NSNumber numberWithFloat:afterFrame.origin.x];
//        tweenAnimation.removedOnCompletion = YES;
//        tweenAnimation.fillMode = kCAFillModeForwards;
//        [self.progressView.layer addAnimation:tweenAnimation forKey:@"animateLayer"];
        //CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        //shapeLayer.frame = afterFrame;
        //shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        //self.progressView.layer.mask = shapeLayer;



        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionOverrideInheritedOptions
                         animations:^{
                             @strongify(self);
                             self.progressView.frame = afterFrame;
                             //self.progressView.layer.mask.frame = afterFrame;
                         } completion:^(BOOL finished){
                             if (finished) {
                                 //@strongify(self);
                                 [self startProgressBarAnimated];
                             }
                         }];
    });
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
