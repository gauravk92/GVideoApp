//
//  GVCellSlidePanGestureRecognizer.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/21/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCellSlidePanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

const CGFloat kGVGestureThreshold = .33;
const CGFloat kGVVelocityThreshold = 500;

@interface GVCellSlidePanGestureRecognizer ()

@property (nonatomic, assign) CGFloat initialLocation;

- (CGFloat)locationOnScreenWithTouch:(UITouch*)touch;
- (CGFloat)translationOnScreenWithTouch:(UITouch*)touch;
- (void)setGestureRecognizerEndedStateWithTouch:(UITouch*)touch;


@end

@implementation GVCellSlidePanGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        self.minimumNumberOfTouches = 1;
        self.maximumNumberOfTouches = 1;
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = YES;
    }
    return self;
}

#pragma mark - Point manipulation methods

- (CGFloat)locationOnScreenWithTouch:(UITouch*)touch {

    UIWindow *win = self.view.window;
    const CGPoint winLoc = [touch locationInView:win];

    return [win convertPoint:winLoc fromWindow:nil].x;
}


- (CGFloat)translationOnScreenWithTouch:(UITouch*)touch {

    UIWindow *win = self.view.window;
    const CGPoint winLoc = [touch locationInView:win];
    const CGPoint currentLocation = [win convertPoint:winLoc fromWindow:nil];

    return self.initialLocation - currentLocation.x;
}

//- (void)setGestureRecognizerEndedStateWithTouch:(UITouch*)touch {
//
//    NSAssert(YES, @"GfitBasePanGestureRecognizer subclass has no implementation: %@", self);
//    
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    self.initialLocation = [self locationOnScreenWithTouch:[touches anyObject]];

    //DLogCGFloat(self.initialLocation);

    [super touchesBegan:touches withEvent:event];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    const CGFloat translation = [self translationOnScreenWithTouch:[touches anyObject]];

    //DLogCGFloat(translation);

    //if (translation < 0) {
    //    self.state = UIGestureRecognizerStateFailed;
    //}

    [super touchesMoved:touches withEvent:event];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    //[self setGestureRecognizerEndedStateWithTouch:[touches anyObject]];
    [super touchesEnded:touches withEvent:event];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    //[self setGestureRecognizerEndedStateWithTouch:[touches anyObject]];
    [super touchesCancelled:touches withEvent:event];

}


- (void)setGestureRecognizerEndedStateWithTouch:(UITouch*)touch {

    const CGFloat translation = [self translationOnScreenWithTouch:touch];
    const CGFloat velocity = [self velocityInView:self.view].x;

    const CGFloat translateCompare = kGVGestureThreshold * CGRectGetHeight(self.view.frame);
    const CGFloat velocityCompare = -(kGVVelocityThreshold);

    //DLogCGFloat(translateCompare);
    //DLogCGFloat(velocityCompare);

    self.state = (translation > translateCompare || velocity < velocityCompare)
    ? UIGestureRecognizerStateRecognized
    : UIGestureRecognizerStateCancelled;
    
}

@end
