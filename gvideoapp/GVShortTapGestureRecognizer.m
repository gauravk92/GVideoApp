//
//  GVShortTapGestureRecognizer.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/17/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVShortTapGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface GVShortTapGestureRecognizer ()



@end

@implementation GVShortTapGestureRecognizer

- (CGFloat)absoluteDifferenceMovement:(CGFloat)point1 toPoint:(CGFloat)point2 {
    if (point1 > point2) {
        return point1 - point2;
    } else {
        return point2 - point1;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.beginLocation = [self locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    CGPoint currentLocation = [self locationInView:self.view];

    if ([self absoluteDifferenceMovement:currentLocation.x toPoint:self.beginLocation.x] > self.allowableMovement ||
        [self absoluteDifferenceMovement:currentLocation.y toPoint:self.beginLocation.y] > self.allowableMovement) {
        self.state = UIGestureRecognizerStateCancelled;
        if ([self.delegate respondsToSelector:@selector(handleGestureRecognizer:tapFail:)]) {
            [[self delegate] performSelector:@selector(handleGestureRecognizer:tapFail:) withObject:self withObject:[NSValue valueWithCGPoint:self.beginLocation]];
        }
    } else {
        [super touchesMoved:touches withEvent:event];
    }
    

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(handleGestureRecognizer:tapFail:)]) {
        [[self delegate] performSelector:@selector(handleGestureRecognizer:tapFail:) withObject:self withObject:[NSValue valueWithCGPoint:self.beginLocation]];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(handleGestureRecognizer:tapFail:)]) {
        [[self delegate] performSelector:@selector(handleGestureRecognizer:tapFail:) withObject:self withObject:[NSValue valueWithCGPoint:self.beginLocation]];
    }
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    self.state
//}

@end
