//
//  GVSlidingDynamicTransition.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/8/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSlidingDynamicTransition.h"
#import "GVPanDownGestureRecognizer.h"
#import "GVPanUpGestureRecognizer.h"
#import "GVSplitTableView.h"

const CGFloat kGVDynamicPush = 8500;
const CGFloat kGVDynamicDensity = 30;
const CGFloat kGVDynamicResistance = 0.8;
const CGFloat kGVDynamicGravity = 2;

const CGFloat kGVVelocityThreshold = 1000.0f;
const CGFloat kGVGestureThreshold = 0.33f;
const CGFloat kGVPanThreshold = 120;

@interface GVSlidingDynamicTransition () <UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIViewController<GVSlidingDynamicTransitionProtocol> *parent;
@property (nonatomic, weak) UIView *view;

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSBlockOperation *dynamicAnimatorCompletionBlock;

@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamicItemBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) GVPanUpGestureRecognizer *panUpGestureRecognizer;
@property (nonatomic, strong) GVPanDownGestureRecognizer *panDownGestureRecognizer;
@property (nonatomic, assign) CGPoint initialLocationOnScreen;

@property (nonatomic, assign) BOOL interactive;


@end

@implementation GVSlidingDynamicTransition

- (instancetype)initWithParent:(UIViewController<GVSlidingDynamicTransitionProtocol> *)parent view:(UIView*)view {
    self = [super init];
    if (self) {
        if ([parent conformsToProtocol:@protocol(GVSlidingDynamicTransitionProtocol)]) {
            _parent = parent;
            _view = view;

            _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.parent.view];
            _dynamicAnimator.delegate = self;

            _panUpGestureRecognizer = [[GVPanUpGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanUpGesture:)];
            _panUpGestureRecognizer.delegate = self;
            //_panUpGestureRecognizer.enabled = NO;
            [_view addGestureRecognizer:_panUpGestureRecognizer];

            _panDownGestureRecognizer = [[GVPanDownGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanDownGesture:)];
            _panDownGestureRecognizer.delegate = self;
            _panDownGestureRecognizer.enabled = NO;
            [_view addGestureRecognizer:_panDownGestureRecognizer];

        } else {
            return  nil;
        }
    }
    return self;
}

#pragma mark - Dynamic animator methods

- (void)resetDynamicAnimator {
    [self.dynamicAnimator removeAllBehaviors];
    self.gravityBehavior = nil;
    self.attachmentBehavior = nil;
    self.dynamicItemBehavior = nil;
    self.dynamicAnimatorCompletionBlock = nil;
}

- (void)teardownDynamicAnimator {

    [self.view removeGestureRecognizer:self.panDownGestureRecognizer];
    self.panDownGestureRecognizer.delegate = nil;
    self.panDownGestureRecognizer = nil;

    [self.view removeGestureRecognizer:self.panUpGestureRecognizer];
    self.panUpGestureRecognizer.delegate = nil;
    self.panUpGestureRecognizer = nil;

    [self.dynamicAnimator removeAllBehaviors];
    self.gravityBehavior = nil;
    self.attachmentBehavior = nil;
    self.dynamicItemBehavior = nil;
    self.dynamicAnimator = nil;

    self.view = nil;
    self.parent = nil;
    self.dynamicAnimatorCompletionBlock = nil;

}


#pragma mark - Scan gesture methods

- (void)setupSearchGesture {
    @autoreleasepool {

        UIView *view = self.view;

        [self resetDynamicAnimator];

        self.panDownGestureRecognizer.enabled = YES;
        self.panUpGestureRecognizer.enabled = NO;

        UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[view]];
        UIEdgeInsets collisionBoundInsets = UIEdgeInsetsMake(0, 0, -(CGRectGetHeight(view.frame) - splitTablePaneHeight - splitTableNavHeight), 0);
        [collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:collisionBoundInsets];
        [self.dynamicAnimator addBehavior:collisionBehavior];

        UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
        dynamicItemBehavior.allowsRotation = NO;

        @weakify(self);
        self.dynamicItemBehavior.action = ^{
            @strongify(self);

            CGRect snapshotRect = self.view.frame;
            snapshotRect.origin.x = 0;
            //self.view.frame = snapshotRect;

            DLogCGRect(snapshotRect);

            //[self.dynamicAnimator updateItemUsingCurrentState:self.view];

        };

        [self.dynamicAnimator addBehavior:dynamicItemBehavior];



    }
}

//- (void)searchGestureDidFinish:(BOOL)recognized {
//
//}

- (void)setupScanGesture {
    @autoreleasepool {
        UIView *view = self.view;

        [self resetDynamicAnimator];
        self.panUpGestureRecognizer.enabled = YES;
        self.panDownGestureRecognizer.enabled = NO;

        UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[view]];
        UIEdgeInsets collisionBoundInsets = UIEdgeInsetsMake(0, 0, -(CGRectGetHeight(view.frame) - splitTablePaneHeight - splitTableNavHeight), 0);
        [collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:collisionBoundInsets];
        [self.dynamicAnimator addBehavior:collisionBehavior];

        self.dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
        self.dynamicItemBehavior.allowsRotation = NO;

        @weakify(self);
        self.dynamicItemBehavior.action = ^{
            @strongify(self);

            UIView *view = self.view;
            CGFloat percent = fabsf(CGRectGetMinY(view.frame) / (CGRectGetHeight(view.frame) - kGVPanThreshold));
            //strongSelf.view.scanStatusBarBackgroundImageView.alpha = percent;



            CGRect snapshotRect = self.view.frame;
            //snapshotRect.origin.x = 0;
            //snapshotRect.origin.y = [
            self.view.frame = snapshotRect;

            DLogCGRect(snapshotRect);
            //[self.dynamicAnimator updateItemUsingCurrentState:self.view];

        };

        [self.dynamicAnimator addBehavior:self.dynamicItemBehavior];
    }
}

- (void)setupSearchGestureAttachmentToLocation:(CGPoint)location {

    UIView *view = self.view;

    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:view attachedToAnchor:location];
    [self.dynamicAnimator addBehavior:self.attachmentBehavior];
}

- (void)setupScanGestureAttachmentToLocation:(CGPoint)location {

    UIView *view = self.view;

    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:view attachedToAnchor:location];
    [self.dynamicAnimator addBehavior:self.attachmentBehavior];
}

- (void)updateGestureAttachmentToLocation:(CGPoint)location {
    self.attachmentBehavior.anchorPoint = location;
}

//- (CGPoint)gestureAttachmentAnchorPoint {
//    return self.attachmentBehavior.anchorPoint;
//}
//
//- (void)setupSearchGestureFinishAttachmentToLocation:(CGPoint)location {
//    UIView *view = self.view.searchDraggableView;
//
//    [self.dynamicAnimator removeBehavior:self.attachmentBehavior];
//
//    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:view attachedToAnchor:location];
//    [self.dynamicAnimator addBehavior:self.attachmentBehavior];
//    [self.dynamicAnimator updateItemUsingCurrentState:view];
//}

- (void)detachGestureAttachment {
    [self.dynamicAnimator removeBehavior:self.attachmentBehavior];
    self.attachmentBehavior = nil;
}


- (void)setupScanGestureDidFinishWithPush:(GVSlidingDynamicTransitionDirection)show {

    UIView *view = self.view;

    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[view] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(0, (kGVDynamicPush * (show == GVSlidingDynamicTransitionDirectionUp ? 1 : -1)));
    [self.dynamicAnimator addBehavior:pushBehavior];

}

- (void)setupSearchGestureDidFinishTransition:(BOOL)finished completion:(NSBlockOperation *)block {

    UIView *view = self.view;

    self.dynamicAnimatorCompletionBlock = block;

    [self.dynamicAnimator updateItemUsingCurrentState:view];

    self.dynamicItemBehavior.density = kGVDynamicDensity;
    self.dynamicItemBehavior.resistance = kGVDynamicResistance;

    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[view]];
    self.gravityBehavior.gravityDirection = CGVectorMake(0, kGVDynamicGravity * ( finished ? 1 : -1));
    [self.dynamicAnimator addBehavior:self.gravityBehavior];


}

- (void)setupScanGestureDidFinishTransition:(BOOL)finished completion:(NSBlockOperation *)block {

    UIView *view = self.view;

    self.dynamicAnimatorCompletionBlock = block;

    [self.dynamicAnimator updateItemUsingCurrentState:view];

    self.dynamicItemBehavior.density = kGVDynamicDensity;
    self.dynamicItemBehavior.resistance = kGVDynamicResistance;

    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[view]];
    self.gravityBehavior.gravityDirection = CGVectorMake(0, kGVDynamicGravity * ( finished ? -1 : 1));
    [self.dynamicAnimator addBehavior:self.gravityBehavior];

}

- (void)setupScanGestureDidFinishWithVelocity:(CGPoint)velocity {
    UIView *view = self.view;

    [self.dynamicItemBehavior addLinearVelocity:velocity forItem:view];
}


/**
 *  Plays the first launch animation
 */
//- (void)playFirstLaunchAnimationWithCompletion:(NSBlockOperation *)block {
//
//    //self.hueViewController.paused = YES;
//    //self.view.userInteractionEnabled = NO;
//
//    //[self.cameraViewController startRunningCaptureSession];
//
//    const CGPoint searchCenter = self.view.searchDraggableView.center;
//
//    GfitMainMenuDynamicAnimator * __weak weakSelf = self;
//    [UIView animateWithDuration:kGfitTransitionFastTime delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
//        GfitMainMenuDynamicAnimator *strongSelf = weakSelf;
//
//        CGPoint lowerCenter = searchCenter;
//        lowerCenter.y += kGfitPanThreshold;
//        strongSelf.view.searchDraggableView.center = lowerCenter;
//
//    } completion:^(BOOL finished) {
//        if (finished) {
//            [UIView animateWithDuration:kGfitTransitionFastTime delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
//                GfitMainMenuDynamicAnimator *strongSelf = weakSelf;
//
//                strongSelf.view.searchDraggableView.center = searchCenter;
//
//            } completion:^(BOOL finished) {
//                if (finished) {
//                    GfitMainMenuDynamicAnimator *strongSelf = weakSelf;
//
//                    [strongSelf setupScanGesture];
//
//                    [strongSelf setupScanGestureDidFinishTransition:NO completion:block];
//                }
//            }];
//        }
//    }];
//}

#pragma mark - Dynamic animator delegate methods

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator {
    //self.hueViewController.paused = YES;
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
//
    if (self.interactive) {
        // not a scanning gesture
        return;
    }

//    UIView *view = self.view;
//    const CGFloat height = view.frame.size.height;
//    const CGFloat origin = view.frame.origin.y;
//    const CGFloat epsilon = 1;
//    NSInteger scanning = -1;
//
//    if ((height - kGVPanThreshold) + origin < epsilon) {
//
//        scanning = 1;
//
//    } else if (origin > -(epsilon) && origin < epsilon) {
//
//        scanning = 0;
//
//    }
//
//    if (scanning > -1) {

        DLogFunctionLine();
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);

            //[strongSelf teardownDynamicAnimator];

            //[strongSelf.view showScan:scanning animated:NO];
            //strongSelf.hueViewController.paused = NO;

            //            if (scanning) {
            //                [strongSelf setupScanningGestureRecognizers];
            //            } else {
            //                [strongSelf setupMainMenuGestureRecognizers];
            //            }
            
            [self.dynamicAnimatorCompletionBlock setCompletionBlock:^{
                self_weak_.dynamicAnimatorCompletionBlock = nil;
            }];
            
            [self.dynamicAnimatorCompletionBlock start];
            
        });
        
    //}
}


#pragma mark - Pan Gesture Recognizer Action Methods

- (void)handlePanDownGesture:(GVPanDownGestureRecognizer *)gc {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        CGPoint location = [gc locationInView:gc.view];
        location.x = CGRectGetMidX(gc.view.bounds);

        CGPoint translation = [gc translationInView:gc.view];
        translation.x = 0;

        switch (gc.state) {
            case UIGestureRecognizerStatePossible:
            case UIGestureRecognizerStateFailed: {

                break;
            }
            case UIGestureRecognizerStateBegan: {
                self.interactive = YES;

                [self setupSearchGesture];
                [self setupSearchGestureAttachmentToLocation:location];

                //            if ([self.parent respondsToSelector:@selector(search:)]) {
                //                [self.parent performSelector:@selector(search:) withObject:nil];
                //            }

                //GfitSearchViewController *searchController = [[GfitSearchViewController alloc] initWithNibName:nil bundle:nil];
                //searchController.transitioningDelegate = self.parent;
                //            [self.parent presentViewController:searchController animated:YES completion:^{
                //
                //            }];

                //            self.parent.presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
                //            self.parent.presentedViewController.transitioningDelegate = self.parent;
                //            [self.parent dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case UIGestureRecognizerStateChanged: {


                CGFloat percent = [gc translationInView:gc.view].y / CGRectGetHeight(gc.view.frame);
                percent = fmin(fmax(0.0, percent), .99);

                [self updateGestureAttachmentToLocation:location];

                //[self updateGestureAttachmentToLocation:location];

                //[self updateInteractiveTransition:percent];
                break;
            }
            case UIGestureRecognizerStateRecognized: {
                //[self finishInteractiveTransition];
                //            BOOL recognized = (gc.state == UIGestureRecognizerStateRecognized);
                //
                //            [self.mainMenuDynamicAnimator detachGestureAttachment];
                //
                //			if (recognized) {
                //				//[self _showSearch:YES];
                //			} else {
                //				//[self _showSearch:NO];
                //			}
                //            self.interactive = NO;
                [self gestureRecognizerPanDownEndedGesture:gc];
                break;
            }
            case UIGestureRecognizerStateCancelled: {
                //[self cancelInteractiveTransition];
                //            self.interactive = NO;
                [self gestureRecognizerPanDownEndedGesture:gc];
                break;
            }
        }
    });
}

- (void)gestureRecognizerPanDownEndedGesture:(GVPanDownGestureRecognizer*)gc {
    BOOL recognized = (gc.state == UIGestureRecognizerStateRecognized);

    [self detachGestureAttachment];

    if (recognized) {
        [self setupSearchGestureDidFinishTransition:YES completion:[NSBlockOperation blockOperationWithBlock:^{
            [self setupScanGesture];
        }]];
        //        if ([self.parent respondsToSelector:@selector(_showSearch:)]) {
        //            [self.parent performSelector:@selector(_showSearch:) withObject:[NSNumber numberWithBool:YES]];
        //        }

        //        if ([self.parent respondsToSelector:@selector(search:)]) {
        //            [self.parent performSelector:@selector(search:) withObject:nil];
        //        }
        //[self _showSearch:YES];
    } else {
        //        if ([self.parent respondsToSelector:@selector(_showSearch:)]) {
        //            [self.parent performSelector:@selector(_showSearch:) withObject:[NSNumber numberWithBool:NO]];
        //        }
        //        GfitMainMenuSearchInteractiveTransition * __weak weakSelf = self;
        @weakify(self);
        [self setupSearchGestureDidFinishTransition:NO completion:[NSBlockOperation blockOperationWithBlock:^{
            @strongify(self);
            [self setupSearchGesture];
        }]];
        //        //[self _showSearch:NO];
        //        if ([self.parent respondsToSelector:@selector(searchCancel:)]) {
        //            [self.parent performSelector:@selector(searchCancel:) withObject:nil];
        //        }
    }
    
    self.interactive = NO;
}

- (void)handlePanUpGesture:(GVPanUpGestureRecognizer *)gc {
    CGPoint location = [gc locationInView:gc.view];
	location.x = CGRectGetMidX(gc.view.bounds);

    

    switch (gc.state) {
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed: {

            break;
        }
        case UIGestureRecognizerStateBegan: {
            self.interactive = YES;

            CGPoint locInView = [gc locationInView:gc.view];

            CGPoint locInWindow = [gc.view.window convertPoint:locInView fromView:gc.view];

            self.initialLocationOnScreen = locInWindow;


            [self setupScanGesture];
            [self setupScanGestureAttachmentToLocation:location];

            //            if ([self.parent respondsToSelector:@selector(search:)]) {
            //                [self.parent performSelector:@selector(search:) withObject:nil];
            //            }

            //GfitSearchViewController *searchController = [[GfitSearchViewController alloc] initWithNibName:nil bundle:nil];
            //searchController.transitioningDelegate = self.parent;
            //            [self.parent presentViewController:searchController animated:YES completion:^{
            //
            //            }];

            //            self.parent.presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
            //            self.parent.presentedViewController.transitioningDelegate = self.parent;
            //            [self.parent dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case UIGestureRecognizerStateChanged: {

            CGFloat percent = [gc locationInView:gc.view].y / CGRectGetHeight(gc.view.frame);
            percent = fmin(fmax(0.0, percent), .99);

            CGPoint translationInView = [gc translationInView:gc.view];

            CGPoint translationInWindow = [gc.view.window convertPoint:translationInView fromView:gc.view];

            //translationInView.x = CGRectGetMidX(gc.view.window);
            [self updateGestureAttachmentToLocation:translationInWindow];

            //[self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateRecognized: {
            //[self finishInteractiveTransition];
            //            BOOL recognized = (gc.state == UIGestureRecognizerStateRecognized);
            //
            //            [self.mainMenuDynamicAnimator detachGestureAttachment];
            //
            //			if (recognized) {
            //				//[self _showSearch:YES];
            //			} else {
            //				//[self _showSearch:NO];
            //			}
            //            self.interactive = NO;
            [self gestureRecognizerPanUpEndedGesture:gc];
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            //[self cancelInteractiveTransition];
            //            self.interactive = NO;
            [self gestureRecognizerPanUpEndedGesture:gc];
            break;
        }
    }
}

- (void)gestureRecognizerPanUpEndedGesture:(GVPanUpGestureRecognizer*)gc {
    BOOL recognized = (gc.state == UIGestureRecognizerStateRecognized);

    [self detachGestureAttachment];

    if (recognized) {
        [self setupScanGestureDidFinishTransition:YES completion:[NSBlockOperation blockOperationWithBlock:^{
            [self setupSearchGesture];
        }]];
        //        if ([self.parent respondsToSelector:@selector(_showSearch:)]) {
        //            [self.parent performSelector:@selector(_showSearch:) withObject:[NSNumber numberWithBool:YES]];
        //        }

//        if ([self.parent respondsToSelector:@selector(search:)]) {
//            [self.parent performSelector:@selector(search:) withObject:nil];
//        }
        //[self _showSearch:YES];
    } else {
        //        if ([self.parent respondsToSelector:@selector(_showSearch:)]) {
        //            [self.parent performSelector:@selector(_showSearch:) withObject:[NSNumber numberWithBool:NO]];
        //        }
//        GfitMainMenuSearchInteractiveTransition * __weak weakSelf = self;
        @weakify(self);
        [self setupScanGestureDidFinishTransition:NO completion:[NSBlockOperation blockOperationWithBlock:^{
            @strongify(self);
            [self setupScanGesture];
        }]];
//        //[self _showSearch:NO];
//        if ([self.parent respondsToSelector:@selector(searchCancel:)]) {
//            [self.parent performSelector:@selector(searchCancel:) withObject:nil];
//        }
    }
    
    self.interactive = NO;
}


#pragma mark - Gesture Recognizer Delegate Methods


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //DLogObject(gestureRecognizer);
    //DLogObject(otherGestureRecognizer);
    return NO;

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer == self.panUpGestureRecognizer || otherGestureRecognizer == self.panDownGestureRecognizer) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.panUpGestureRecognizer || gestureRecognizer == self.panDownGestureRecognizer) {
        return YES;
    }
    return NO;
}


@end
