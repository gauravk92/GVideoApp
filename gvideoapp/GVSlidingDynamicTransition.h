//
//  GVSlidingDynamicTransition.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/8/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GVSlidingDynamicTransitionDirection) {
    GVSlidingDynamicTransitionDirectionUp,
    GGVSlidingDynamicTransitionDirectionDown
};

extern const CGFloat kGVDynamicPush;
extern const CGFloat kGVDynamicDensity;
extern const CGFloat kGVDynamicResistance;
extern const CGFloat kGVDynamicGravity;

extern const CGFloat kGVVelocityThreshold;
extern const CGFloat kGVGestureThreshold;
extern const CGFloat kGVPanThreshold;

@protocol GVSlidingDynamicTransitionProtocol <NSObject>

@end

@interface GVSlidingDynamicTransition : NSObject

- (instancetype)initWithParent:(UIViewController<GVSlidingDynamicTransitionProtocol> *)parent view:(UIView*)view;

- (void)teardownDynamicAnimator;

@end
