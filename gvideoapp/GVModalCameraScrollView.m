//
//  GVModalCameraScrollView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/9/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVModalCameraScrollView.h"
#import "GVSplitTableView.h"

@interface GVModalCameraScrollView () <UIGestureRecognizerDelegate>

@end

@implementation GVModalCameraScrollView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//
//    }
//    return self;
//}

//- (void)setNeedsLayout {
//    [super setNeedsLayout];
//
////    NSArray *subviews = self.subviews;
////    for (UIView *view in subviews) {
////        [view setNeedsLayout];
////        view.bounds = self.bounds;
////    }
//}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    //NSLog(@"");
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //return YES;
    if ([gestureRecognizer.view isDescendantOfView:self]) {
        return NO;
    }
//    if (!([gestureRecognizer.view isKindOfClass:[UIScrollView class]] && gestureRecognizer != self.panGestureRecognizer)
//        || !([otherGestureRecognizer isKindOfClass:[UIScrollView class]] && otherGestureRecognizer != self.panGestureRecognizer)) {
//        return NO;
//    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //return YES;
    if (gestureRecognizer.view == self && otherGestureRecognizer.view != self) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //return YES;
    if (gestureRecognizer.view != self && otherGestureRecognizer.view == self) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    BOOL begin = [super touchesShouldBegin:touches withEvent:event inContentView:view];

    return begin;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint convertedPoint = [self convertPoint:point toView:self.superview];
    UIView *superHitView = [super hitTest:point withEvent:event];
    //DLogObject(superHitView);
//    if (superHitView == self && [self.delegate respondsToSelector:@selector(cameraHitTestViewWithPoint:withEvent:)]) {
//        return [self.delegate performSelector:@selector(cameraHitTestViewWithPoint:withEvent:) withObject:[NSValue valueWithCGPoint:point] withObject:event];
//    }

    CGFloat contentOffset = self.contentOffset.y;

    BOOL bottomIsFullscreen = (contentOffset > self.frame.size.height - splitTablePaneHeight -1) ? YES : NO;
    BOOL bottomIsModal = (contentOffset < 1) ? YES : NO;
    CGFloat splitPaneCalculatedHeight = self.bounds.size.height - splitTablePaneHeight;

    //return self;

    CGPoint convertPoint = [self convertPoint:point toView:self.childTableView];
    if ([self.childTableView pointInside:convertPoint withEvent:nil]) {
        //if (self.childTableView.contentOffset.y > -1) {
        
        if (convertPoint.y < 46 + self.childTableView.contentOffset.y) {
            return self;
        }
        
        UIView *view = [self.childTableView hitTest:convertPoint withEvent:nil];

        CGPoint aConvertPoint = [self.childTableView convertPoint:convertPoint toView:view];
        if ([view pointInside:aConvertPoint withEvent:nil]) {
            return view;
        } else {
            NSArray *cells = self.childTableView.visibleCells;
            for (UITableViewCell *cell in cells) {
                CGPoint aCellPoint = [self.childTableView convertPoint:convertPoint toView:cell];
                if ([cell pointInside:aCellPoint withEvent:nil]) {
                    UIView *aView = [cell hitTest:point withEvent:nil];
                    return aView;
                }
            }
        }


        // return view;
        //}
        return self.childTableView;
    }

//    if (self.pushedChildView.view) {
//        CGPoint pPoint = [self convertPoint:point toView:self.pushedChildView.view];
//        if ([self.pushedChildView.view pointInside:pPoint withEvent:nil]) {
//            return self.pushedChildView.view;
//        }
//    }

//    if (bottomIsFullscreen) { // if bottom view is taking up full screen
//        CGPoint convertPoint = [self convertPoint:point toView:self.childTableView];
//        if (convertPoint.y < self.bounds.size.height / 2) {
//            return self; // scroll the camera with the top half
//        } else {
//            return self.childTableView; // scrollt the table with the bottom half
//        }
//    } else {
//        // not full screen, maybe partial ...
//        CGPoint convertPoint = [self convertPoint:point toView:self.childTableView];
//        if ([self.childTableView pointInside:convertPoint withEvent:nil]) {
//            // we're in the bottom view
//            if (bottomIsModal) { // trying to detect it's midway, in which case we would want to facilitate up/down fully
//
//                return self;
//
//                // attempt at some optimization
////                NSArray *visibleCells = [self.childTableView visibleCells];
////                for (UITableViewCell *cell in visibleCells) {
////                    CGPoint cellPoint = [self convertPoint:point toView:cell.contentView];
////                    if ([cell.contentView pointInside:cellPoint withEvent:nil]) {
////
////                        CGRect cellFrame = [cell convertRect:cell.contentView.bounds toView:self];
////                        CGFloat cellOrigin = cellFrame.origin.y;
////
////                        if (cellOrigin == splitPaneCalculatedHeight) {
////                            return self;
////                        }
////                    }
//            }
//                return self.childTableView;
////} else {
////              return self;
////          }
//            //UIView *childHitView = [self.childTableView hitTest:point withEvent:nil];
//            //UIView *childChildHV = [childHitView hitTest:point withEvent:nil];
//            //DLogObject(childChildHV);
//        }


//        if (self.contentOffset.y < self.frame.size.height - splitTablePaneHeight) {
//            return self;
//        } else {
//            return self.childTableView;
//        }
//    }
    
    return superHitView;
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
