//
//  GVPanUpGestureRecognizer.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/8/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVPanUpGestureRecognizer.h"
#import "GVSlidingDynamicTransition.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation GVPanUpGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    self.initialLocation = [self locationOnScreenWithTouch:[touches anyObject]];

    //DLogCGFloat(self.initialLocation);

    [super touchesBegan:touches withEvent:event];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    const CGFloat translation = [self translationOnScreenWithTouch:[touches anyObject]];

    //DLogCGFloat(translation);

    if (translation < 0) {
        self.state = UIGestureRecognizerStateFailed;
    }

    [super touchesMoved:touches withEvent:event];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [self setGestureRecognizerEndedStateWithTouch:[touches anyObject]];
    [super touchesEnded:touches withEvent:event];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    [self setGestureRecognizerEndedStateWithTouch:[touches anyObject]];
    [super touchesCancelled:touches withEvent:event];

}


- (void)setGestureRecognizerEndedStateWithTouch:(UITouch*)touch {

    const CGFloat translation = [self translationOnScreenWithTouch:touch];
    const CGFloat velocity = [self velocityInView:self.view].y;

    const CGFloat translateCompare = kGVGestureThreshold * CGRectGetHeight(self.view.frame);
    const CGFloat velocityCompare = -(kGVVelocityThreshold);

    self.state = (translation > translateCompare || velocity < velocityCompare)
    ? UIGestureRecognizerStateRecognized
    : UIGestureRecognizerStateCancelled;
    
}


@end
