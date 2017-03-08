//
//  GVRecordAnimatingMiniDotView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVRecordAnimatingMiniDotView.h"
#import "GVRecordMiniDotView.h"

@interface GVRecordAnimatingMiniDotView ()



@end

@implementation GVRecordAnimatingMiniDotView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.miniDotView = [[GVRecordMiniDotView alloc] initWithFrame:frame];
        self.miniDotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.miniDotView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.miniDotView];
        self.clipsToBounds = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self.miniDotView setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

//    self.miniDotView.frame = self.bounds;
}

- (void)startAnimatingDots {

    CGFloat toolbarSize = 12;
    CGFloat toolbarSizeS = 6;

    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.duration = 1.0;
    animGroup.repeatDuration = 99999;
    animGroup.repeatCount = 99999;
    animGroup.removedOnCompletion = NO;
    animGroup.fillMode = kCAFillModeBoth;
    animGroup.autoreverses = YES;


    CAKeyframeAnimation *keyFrameAnim = [CAKeyframeAnimation animationWithKeyPath:@"cornerRadius"];

    keyFrameAnim.duration = animGroup.duration;
    keyFrameAnim.repeatCount = animGroup.repeatCount;
    keyFrameAnim.repeatDuration = animGroup.repeatDuration;
    keyFrameAnim.fillMode = kCAFillModeForwards;
    keyFrameAnim.removedOnCompletion = NO;
    keyFrameAnim.autoreverses = YES;

    keyFrameAnim.keyTimes = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0]];
    keyFrameAnim.values = @[[NSNumber numberWithFloat:toolbarSize / 2], [NSNumber numberWithFloat:toolbarSizeS / 2]];


    CAKeyframeAnimation *keyScaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    keyScaleAnim.duration = animGroup.duration;
    keyScaleAnim.repeatDuration = animGroup.repeatDuration;
    keyScaleAnim.repeatCount = animGroup.repeatCount;
    keyScaleAnim.removedOnCompletion = NO;
    keyScaleAnim.autoreverses = YES;
    keyScaleAnim.fillMode = kCAFillModeForwards;




    keyScaleAnim.keyTimes = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0]];
    keyScaleAnim.values = @[[NSValue valueWithCGRect:CGRectMake(0, 0, toolbarSize, toolbarSize)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, toolbarSizeS, toolbarSizeS)]];

    animGroup.animations = @[keyFrameAnim, keyScaleAnim];
    [self.miniDotView.layer addAnimation:animGroup forKey:@"animateIt"];

}

@end
