//
//  GVModalCameraContainerViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVModalCameraContainerViewController.h"
#import "GVSplitTableView.h"
#import "GVMasterViewController.h"
#import "GVModalCameraContainerView.h"
#import "GVSlidingDynamicTransition.h"
#import "SMBInternetConnectionIndicator.h"
#import "GVThreadBackgroundView.h"
#import "GVSettingsTableViewController.h"
#import "GVShortTapGestureRecognizer.h"

#define kModalSeguePushedBackAnimationDuration 0.3
#define kModalSegueBringForwardAnimationDuration 0.3
#define CAMERA_SCROLL_BUFFER 60


@interface GVModalCameraContainerViewController () <UIViewControllerAnimatedTransitioning>


@property (nonatomic, strong) GVModalCameraContainerView *view;
@property (nonatomic, strong) GVModalCameraVideoController *topViewController;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSOperationQueue *presentationOperationQueue;
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;
@property (nonatomic, strong) GVSlidingDynamicTransition *dynamicTransition;

@property (nonatomic, assign) CFTimeInterval startAnimationTime;
@property (nonatomic, assign) CFTimeInterval endAnimationTime;

@property (nonatomic, assign) CGPoint previousContentOffset;

@property (nonatomic, assign) BOOL runningCamera;

@property (nonatomic, assign, getter = isAnimatedBack) BOOL animatedBack;

@property (nonatomic, strong) CAShapeLayer *topMasklayer;

@property (nonatomic, strong) SMBInternetConnectionIndicator *internetConnectionIndicator;

@property (nonatomic, assign) BOOL presenting;

@property (nonatomic, weak) UIViewController *aCustomPresentedViewController;

@property (nonatomic, assign, readwrite) UIStatusBarStyle preferredStatusBarStyle;

@property (nonatomic, assign, readwrite) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@property (nonatomic, assign, readwrite) BOOL prefersStatusBarHidden;

@property (nonatomic, copy) NSValue *transitioningTransform;
@property (nonatomic, copy) NSValue *transitioningTransformBack;

@end

@implementation GVModalCameraContainerViewController

+ (UIColor *)classBackgroundColor {
    return [UIColor colorWithWhite:0.10 alpha:1];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.prefersStatusBarHidden = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.topViewController = [[GVModalCameraVideoController alloc] initWithNibName:nil bundle:nil];
        //self.splitTableViewController = [[GVSplitTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //self.splitTableViewController.splitScrollDelegate = self;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(pullUpNotification:) name:GVMasterViewControllerPullUpNotification object:nil];

        [nc addObserver:self selector:@selector(bottomFullscreenNotification:) name:GVMasterViewControllerFullscreenNotification object:nil];

        [nc addObserver:self selector:@selector(navigationPushPop:) name:GVNavigationPushPopNotification object:nil];

        [nc addObserver:self selector:@selector(dismissSettings:) name:GVSettingsTableViewControllerDismissNotification object:nil];

        [nc addObserver:self selector:@selector(objectsWillLoadData:) name:GVMasterModelObjectLoadingData object:nil];
        [nc addObserver:self selector:@selector(objectsFinishedLoading:) name:GVMasterModelObjectFinishedLoadingData object:nil];
        [nc addObserver:self selector:@selector(objectsWillLoadThumbnail:) name:GVMasterModelObjectLoadingThumbnails object:nil];
        
        [nc addObserver:self selector:@selector(objectsSetupEmptyLabel:) name:GVMasterViewControllerSetupEmptyLabelNotification object:nil];
        [nc addObserver:self selector:@selector(objectsEndEmptyLabel:) name:GVMasterViewControllerEndEmptyLabelNotification object:nil];
        
        self.presentationOperationQueue = [NSOperationQueue new];
        self.presentationOperationQueue.maxConcurrentOperationCount = 1;

    }
    return self;
}

- (void)objectsFinishedLoading:(NSNotification*)notif {
    [self.view endLoadingState];
}

- (void)objectsWillLoadData:(NSNotification*)notif {
    [self.view setupLoadingState];
}

- (void)objectsWillLoadThumbnail:(NSNotification*)notif {
    [self.view setupLoadingThumbnailState];
}

- (void)objectsSetupEmptyLabel:(NSNotification*)notif {
    [self.view setupEmptyLabel];
}

- (void)objectsEndEmptyLabel:(NSNotification*)notif {
    [self.view endEmptyLabel];
}

- (void)dismissSettings:(NSNotification*)notif {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)navigationPushPop:(NSNotification*)notif {
    NSDictionary *info = [notif userInfo];
    self.view.scrollView.pushedChildView = info[@"vc"];
 }

- (void)setupBottomViewController:(UIViewController*)bottomVC {
//    if (self.bottomViewController) {
//        [self.bottomViewController.view removeFromSuperview];
//        [self.bottomViewController willMoveToParentViewController:nil];
//        [self.bottomViewController removeFromParentViewController];
//    }

//    if (![self.childViewControllers containsObject:self.topViewController]) {
//        [self.view setupTopViewController:self.topViewController];
//        [self addChildViewController:self.topViewController];
//        [self.topViewController didMoveToParentViewController:self];
//    }


    CAShapeLayer *mLayer = [CAShapeLayer layer];
    //mLayer.fillColor = [UIColor whiteColor].CGColor;
    //mLayer.backgroundColor = [UIColor whiteColor].CGColor;
    mLayer.position = CGPointMake(0, 0);

    mLayer.frame = self.topViewController.view.bounds;


    CGRect fillPath = CGRectMake(0, 0, self.topViewController.view.frame.size.width, self.topViewController.view.frame.size.height);

    CGPathRef mLayerPath = CGPathCreateWithRect(fillPath, NULL);
    mLayer.path = mLayerPath;
#if DEBUG_CF_MEMORY
    CFBridgingRelease(mLayerPath);
#endif
    //mLayer.shouldRasterize = YES;
    //mLayer.rasterizationScale = [UIScreen mainScreen].scale;

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor whiteColor].CGColor;
    maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    //maskLayer.shouldRasterize = YES;
    maskLayer.contentsScale = [UIScreen mainScreen].scale;
    //maskLayer.rasterizationScale = [UIScreen mainScreen].scale;
    CATransform3D transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.topViewController.view.bounds.size.height, 0);
    //maskLayer.transform = transform;
    //maskLayer.frame = mLayer.bounds;
    [mLayer addSublayer:maskLayer];
    //self.topViewController.view.layer.mask = mLayer;

    //self.topMasklayer = mLayer;

    [self.view setupBottomViewController:bottomVC];
    self.bottomViewController = bottomVC;
    [self addChildViewController:self.bottomViewController];
    [self.bottomViewController didMoveToParentViewController:self];


    [self.view.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.masterViewController.tableView.panGestureRecognizer];
    self.masterViewController.parentScrollview = self.view.scrollView;
    self.view.masterViewController = self.masterViewController;
    self.view.scrollView.childTableView = self.masterViewController.tableView;
    //self.view.scrollView.masterViewController = self.masterViewController;
    //[self.view.scrollView.panGestureRe[
    //cognizer requireGestureRecognizerToFail:<#(UIGestureRecognizer *)#>]

}


//- (void)didMoveToParentViewController:(UIViewController *)parent {
//    if (!parent) {
//        [self.topViewController.view removeFromSuperview];
//        [self.topViewController willMoveToParentViewController:nil];
//        [self.topViewController removeFromParentViewController];
//
//        [self.bottomViewController.view removeFromSuperview];
//        [self.bottomViewController willMoveToParentViewController:nil];
//        [self.bottomViewController removeFromParentViewController];
//        self.bottomViewController = nil;
//    }
//}

- (void)loadView {
    self.view = [[GVModalCameraContainerView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return <#expression#>
//}

//- (NSUInteger)supportedInterfaceOrientations {
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
//    }
//    return UIInterfaceOrientationPortrait;
//}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)bottomFullscreenNotification:(NSNotification*)notif {
    [self.view scrollBottomViewFullScreen:YES];
}

- (void)pullUpNotification:(NSNotification*)notif {
    //[self.splitTableViewController pullUp];

//    if ([self.bottomViewController.viewControllers count] > 1) {
//        [self.bottomViewController popToRootViewControllerAnimated:YES];
//        return;
//    }


    NSDictionary *info = [notif userInfo];
    NSArray *infoKeys = nil;
    @try {
        infoKeys = [info allKeys];
    }
    @catch (NSException *exception) {
        DLogException(exception);
    }
    @finally {
        
    }
    if ([infoKeys respondsToSelector:@selector(count)] && [infoKeys count] > 0 && [infoKeys containsObject:@"clearSelection"]) {
        self.topViewController.threadId = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:GVProgressViewUpdateContentsNotification object:nil userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GVProgressViewUpdateContentsNotification object:nil userInfo:info];
        self.topViewController.threadId = info[@"threadId"];
        [self willDisplay];
        
        [self endFullscreenAnimated];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//- (CAAnimationGroup*)animationGroupBringForward {
//    CATransform3D t1 = CATransform3DIdentity;
//    t1.m34 = 1.0 / m34multiplier;
//    t1 = CATransform3DScale(t1, 0.90, 0.90, 1);
//    t1 = CATransform3DRotate(t1, 15.0f * M_PI/180.0f, 1, 0, 0);
//
//    CATransform3D t2 = CATransform3DIdentity;
//    t2.m34 = 1.0 / m34multiplier;
//    t2 = CATransform3DTranslate(t2, 0.0, -20.0, 0.0);
//    t2 = CATransform3DScale(t2, 0.85, 0.85, 1);
//
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    animation.toValue = [NSValue valueWithCATransform3D:t1];
//    //animation.beginTime = (kModalSegueBringForwardAnimationDurati;
//    animation.duration = kModalSegueBringForwardAnimationDuration / 2;
//    animation.fillMode = kCAFillModeForwards;
//    animation.removedOnCompletion = NO;
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//
//    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    opacity.toValue = [NSNumber numberWithFloat:1.0];
//    //opacity.fromValue = [NSNumber numberWithFloat:0.7];
//    opacity.duration = kModalSegueBringForwardAnimationDuration;
//    opacity.beginTime = 0;
//    opacity.fillMode = kCAFillModeForwards;
//    opacity.removedOnCompletion = NO;
//    [opacity setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//
//    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
//    animation2.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//    animation2.beginTime = kModalSegueBringForwardAnimationDuration / 2;
//    animation2.duration = kModalSegueBringForwardAnimationDuration / 3;
//    animation2.fillMode = kCAFillModeForwards;
//    [animation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//
//    animation2.removedOnCompletion = NO;
//
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    //group.delegate = self;
//    group.fillMode = kCAFillModeForwards;
//    group.removedOnCompletion = NO;
//    [group setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//    [group setDuration:kModalSegueBringForwardAnimationDuration];
//    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, opacity, nil]];
//    return group;
//}
//
//-(CAAnimationGroup*)animationGroupPushedBackward {
//    
//    CATransform3D t1 = CATransform3DIdentity;
//    t1.m34 = 1.0 / m34multiplier;
//    t1 = CATransform3DScale(t1, 0.90, 0.90, 1);
//    t1 = CATransform3DRotate(t1, 15.0f * M_PI/180.0f, 1, 0, 0);
//
//    CATransform3D t2 = CATransform3DIdentity;
//    t2.m34 = 1.0 / m34multiplier;
//    t2 = CATransform3DTranslate(t2, 0.0, -20.0, 0.0);
//    t2 = CATransform3DScale(t2, 0.85, 0.85, 1);
//
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    animation.toValue = [NSValue valueWithCATransform3D:t1];
//    animation.duration = kModalSeguePushedBackAnimationDuration / 2;
//    animation.fillMode = kCAFillModeForwards;
//    animation.removedOnCompletion = NO;
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//
//    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    opacity.toValue = [NSNumber numberWithFloat:0.7];
//    //opacity.fromValue = [NSNumber numberWithFloat:1.0];
//    opacity.duration = kModalSeguePushedBackAnimationDuration;
//    opacity.beginTime = 0;
//    opacity.fillMode = kCAFillModeForwards;
//    opacity.removedOnCompletion = NO;
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//
//    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
//    animation2.toValue = [NSValue valueWithCATransform3D:t2];
//    animation2.beginTime = kModalSegueBringForwardAnimationDuration / 2;
//    animation2.duration = kModalSeguePushedBackAnimationDuration / 2;
//    animation2.fillMode = kCAFillModeForwards;
//    [animation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//    animation2.removedOnCompletion = NO;
//
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    group.delegate = self;
//    group.fillMode = kCAFillModeForwards;
//    group.removedOnCompletion = NO;
//    [group setDuration:kModalSeguePushedBackAnimationDuration];
//    [group setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, opacity, nil]];
//    return group;
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//
//    self.operationQueue = [[NSOperationQueue alloc] init];
//    self.operationQueue.maxConcurrentOperationCount = 1;
//
//    CGRect screenRect = CGRectMake(0, 0, self.view.frame.size.width, 30);
//    self.internetConnectionIndicator = [[SMBInternetConnectionIndicator alloc] initWithFrame:screenRect];
//    [self.view addSubview:self.internetConnectionIndicator];
//
//    //[self didEndDisplay];
//
//
//
//    //self.dynamicTransition = [[GVSlidingDynamicTransition alloc] initWithParent:self view:self.bottomViewController.view];
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self layoutInternetIndicator];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];


    [self layoutInternetIndicator];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.previousContentOffset = self.view.scrollView.contentOffset;

    [super viewWillDisappear:animated];

    //[self.dynamicTransition teardownDynamicAnimator];
    //self.dynamicTransition = nil;

    //[self.bottomViewController willMoveToParentViewController:nil];
    //[self.bottomViewController removeFromParentViewController];
    //self.bottomViewController = nil;

    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;


    //[self.view.scrollView scrollRectToVisible:CGRectMake(0, self.previousContentOffset.y, 0, 0) animated:NO];

    [self.internetConnectionIndicator removeFromSuperview];
    self.internetConnectionIndicator = nil;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self stopListeningToOrientationChanges];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

//    [self.topViewController.view removeFromSuperview];
//    [self.topViewController willMoveToParentViewController:nil];
//    [self.topViewController removeFromParentViewController];
//
//    [self.bottomViewController.view removeFromSuperview];
//    [self.bottomViewController willMoveToParentViewController:nil];
//    [self.bottomViewController removeFromParentViewController];
}

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//
//
//
//}

//- (void)animationDidStart:(CAAnimation *)anim {
//
//    //[self.operationQueue cancelAllOperations];
//    //self.operationQueue = nil;
//}
//
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    self.operationQueue = [[NSOperationQueue alloc] init];
//    self.operationQueue.maxConcurrentOperationCount = 1;
//}

- (void)layoutInternetIndicator {
    self.internetConnectionIndicator.frame = CGRectMake(0, 0, self.view.bounds.size.width, 30);
}

- (void)willDisplay {
    //@weakify(self);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //  @strongify(self);

        //self.topViewController.view.hidden = NO;
        [self.topViewController willDisplay];
    //});
}

- (void)forceCameraReload {
    [self.topViewController forceCameraReload];
}

- (void)didEndDisplay {
    //@weakify(self);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //  @strongify(self);
        //self.topViewController.view.hidden = YES;
        [self.topViewController didEndDisplay];
    //});
}

- (void)tellContentOffset:(CGPoint)contentOffset {

    // @weakify(self);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //  @strongify(self);

//        if (contentOffset.y == 0) {
//            [self.topViewController.view.layer removeAllAnimations];
//            self.topViewController.view.layer.speed = 1;
//            //self.displayLink = nil;
//            //self.displayLink.paused = YES;
//        } else {
//            double bound = self.view.bounds.size.height - splitTableNavHeight - splitTablePaneHeight - 60;
//            double percent = contentOffset.y / bound;
//            CFTimeInterval newTime = ((self.endAnimationTime - self.startAnimationTime) * percent);
//            self.topViewController.view.layer.timeOffset = newTime;
//        }

        //CGRect maskRect = CGRectMake(0, 0, self.view.frame.size.width, [self.view contentOffsetForBottomView] - contentOffset.y + 10);

    //self.topMasklayer.frame = maskRect;




        //self.topMasklayer.path = CGPathCreateWithRect(maskRect, NULL);

        //BOOL runningCamera = self.runningCamera;
        // CGFloat checkStart = CAMERA_SCROLL_BUFFER;
        //CGFloat checkEnd = [self.view contentOffsetForBottomView] - CAMERA_SCROLL_BUFFER;

        //DLogCGPoint(contentOffset);
        //DLogCGFloat(checkEnd);
        //DLogBOOL(runningCamera);
//        if (contentOffset.y > checkEnd) {
//            //self.runningCamera = NO;
//            [self didEndDisplay];
//        } else {
//            //self.runningCamera = YES;
//            [self willDisplay];
//        }
// });
}

- (void)setupAnimationTiming:(CAAnimation*)anim {
    return;
    self.startAnimationTime = [self.view.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.endAnimationTime = self.startAnimationTime + [anim duration];
    //self.topViewController.view.layer.beginTime = self.startAnimationTime;
    self.topViewController.view.layer.speed = 0.0;
    //DLogdouble(self.startAnimationTime);
    //DLogdouble(self.endAnimationTime);
    self.topViewController.view.layer.allowsEdgeAntialiasing = YES;
    self.topViewController.view.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge | kCALayerBottomEdge;
}

- (void)endedDragging {
    // self.topViewController.view.layer.speed = 1.0;
}

- (void)goToFullscreen {
    // return;
    if (self.view.showFullscreen) {
        //self.showingFullscreen = YES;
        return;
    }



//    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
//    @weakify(blockOperation);
//
//  @weakify(self);
//
//    [blockOperation addExecutionBlock:^{
//dispatch_async(dispatch_get_main_queue(), ^{
//            if ([blockOperation_weak_ isCancelled]) {
//                return;
//            }

    //       @strongify(self);
//
//            [self.operationQueue cancelAllOperations];
//            self.operationQueue = nil;

    //   NSLog(@"fullscreen");

#if MOTION_EFFECTING
    UIView *motionView = self.topViewController.view;
    NSArray *motionEffects = self.topViewController.view.motionEffects;
    for (UIMotionEffect *motionEffect in motionEffects) {
        [motionView removeMotionEffect:motionEffect];
    }
#endif
            self.view.showFullscreen = YES;

            //[self.topViewController.view.layer removeAllAnimations];

    //CAAnimationGroup *group = [self animationGroupBringForward];


    //[self.topViewController.view.layer addAnimation:group forKey:nil];
    //[self setupAnimationTiming:group];



            //self.topViewController
            //self.topViewController.view.layer.zPosition = -1000;
            //self.splitTableViewController.view.layer.zPosition = 1;
        //    CATransform3D t2 = CATransform3DIdentity;
        //    //t2.m34 = 1.0 /;
        //
        //    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
        //    animation2.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        //    animation2.duration = 0.0;
        //
        //    [self.splitTableViewController.view.layer addAnimation:animation2 forKey:@"animate"];
        //
        //    self.splitTableViewController.view.layer.transform = t2;

            //self.splitTableViewController.view.layer;
            //[self.view bringSubviewToFront:self.splitTableViewController.view];
            //self.splitTableViewController.view.layer.zPosition = 1000;
            //self.splitTableViewController.view.userInteractionEnabled = NO;
            //self.splitTableViewController.tableView.scrollEnabled = NO;

    //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    //[self.view setNeedsLayout];
    return;
//            [UIView animateWithDuration:kModalSeguePushedBackAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent animations:^{
//                @strongify(self);
//                //self.topViewController.view.alpha = 1.0;
//                //[self.view layoutIfNeeded];
//                //[self.splitTableViewController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
//            } completion:^(BOOL finished) {
//                if (finished) {
//                    @strongify(self);
//                    //self.splitTableViewController.view.userInteractionEnabled = YES;
//                    //self.topViewController.view.layer.zPosition = -1000;
//                    //self.splitTableViewController.tableView.scrollEnabled = YES;
//                    //[[UIApplication sharedApplication] endIgnoringInteractionEvents];
//                    self.operationQueue = [[NSOperationQueue alloc] init];
//                    self.operationQueue.maxConcurrentOperationCount = 1;
//                }
//            }];
    //  });

    //  }];
//[self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)endFullscreenAnimated {

    if (self.view.showFullscreen) {
        //self.showingFullscreen = YES;
        return;
    }


    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{

        //    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
        //    @weakify(blockOperation);
        //
        @strongify(self);
        //
        //    [blockOperation addExecutionBlock:^{
        //dispatch_async(dispatch_get_main_queue(), ^{
        //            if ([blockOperation_weak_ isCancelled]) {
        //                return;
        //            }

        //       @strongify(self);
        //
        //            [self.operationQueue cancelAllOperations];
        //            self.operationQueue = nil;

        //   NSLog(@"fullscreen");

        UIView *motionView = self.topViewController.view;
        NSArray *motionEffects = self.topViewController.view.motionEffects;
        for (UIMotionEffect *motionEffect in motionEffects) {
            [motionView removeMotionEffect:motionEffect];
        }
//
        self.view.showFullscreen = NO;
        // self.topViewController.view.layer.speed = 1.0;
//
//        //[self.topViewController.view.layer removeAllAnimations];
//
//        CAAnimationGroup *group = [self animationGroupBringForward];
//
//
//        [self.topViewController.view.layer addAnimation:group forKey:nil];
//[self.splitTableViewController.tableView setContentOffset:CGPointMake(0, self.view.bounds.size.height - splitTableNavHeight - splitTablePaneHeight) animated:YES];
//[self.splitTableViewController]
//[self.splitTableViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        //[self.splitTableViewController.tableView setContentOffset:CGPointMake(0, -(self.view.bounds.size.height - splitTablePaneHeight)) animated:YES];
//[self.splitTableViewController.tableView reloadData];
        [self.view scrollToBottomView:YES];
    });

}

- (void)endFullscreen {

    if (!self.view.showFullscreen) {
        return;
    }

//    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
//    @weakify(blockOperation);
//
// @weakify(self);
//
//
//    [blockOperation addExecutionBlock:^{
//      dispatch_async(dispatch_get_main_queue(), ^{
//            if ([blockOperation_weak_ isCancelled]) {
//                return;
//            }

    //           @strongify(self);
#if MOTION_EFFECTING
            UIInterpolatingMotionEffect *verticalMotionEffect =
            [[UIInterpolatingMotionEffect alloc]
             initWithKeyPath:@"center.y"
             type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            verticalMotionEffect.minimumRelativeValue = @(-7);
            verticalMotionEffect.maximumRelativeValue = @(7);

            // Set horizontal effect
            UIInterpolatingMotionEffect *horizontalMotionEffect =
            [[UIInterpolatingMotionEffect alloc]
             initWithKeyPath:@"center.x"
             type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            horizontalMotionEffect.minimumRelativeValue = @(-7);
            horizontalMotionEffect.maximumRelativeValue = @(7);

            // Create group to combine both
            // @todo cleanup to actually tilt the damn view in 3d
            UIMotionEffectGroup *motionGroup = [UIMotionEffectGroup new];
            motionGroup.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
            
            // Add both effects to your view
            [self.topViewController.view addMotionEffect:motionGroup];
#endif
//            [self.operationQueue cancelAllOperations];
//            self.operationQueue = nil;

            //    NSLog(@"hit end fullscreeen");

            self.view.showFullscreen = NO;

            //[self.topViewController.view.layer removeAllAnimations];
            //CAAnimationGroup *group = [self animationGroupPushedBackward];

            //           [self.topViewController.view.layer addAnimation:group forKey:nil];
            //[self setupAnimationTiming:group];


            //self.startAnimationTime = CACurrentMediaTime();

            //self.splitTableViewController.view.layer.zPosition = 1;

        //    CATransform3D t2 = CATransform3DIdentity;
        //    t2.m34 = 1.0 / 1000;
        //
        //    self.splitTableViewController.view.layer.transform = t2;
        //self.splitTableViewController.view.layer.zPosition = 1000;
            //[self.view bringSubviewToFront:self.splitTableViewController.view];
            //self.splitTableViewController.view.userInteractionEnabled = NO;
            //self.splitTableViewController.tableView.scrollEnabled = NO;
            //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            return ;
//            [UIView animateWithDuration:kModalSeguePushedBackAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowUserInteraction animations:^{
//                @strongify(self);
//                self.topViewController.view.alpha = 0.7;
//            } completion:^(BOOL finished) {
//                if (finished) {
//                    @strongify(self);
//                    //self.splitTableViewController.view.userInteractionEnabled = YES;
//                    //self.topViewController.view.layer.zPosition = -1000;
//                    //self.splitTableViewController.tableView.scrollEnabled = YES;
//                    //[[UIApplication sharedApplication] endIgnoringInteractionEvents];
//                    self.operationQueue = [[NSOperationQueue alloc] init];
//                    self.operationQueue.maxConcurrentOperationCount = 1;
//                }
//            }];

    //  });
    //  }];
//   [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //[self.view addSubview:self.topViewController.view];
    [self.view setupTopViewController:self.topViewController];
    [self addChildViewController:self.topViewController];
    [self.topViewController didMoveToParentViewController:self];

    // [self.view setupSplitViewController:self.splitTableViewController];
    //[self addChildViewController:self.splitViesplitTableViewControllerself.splitTableViewController didMoveToParentViewController:self];

    self.view.showFullscreen = YES;
    //self.runningCamera = YES;
    self.view.delegate = self;

    //self.view.backgroundColor = [GVModalCameraContainerViewController classBackgroundColor];

 
    //[self.view addSubview:self.splitTableViewController.view];
    //[self.view setupBottomViewController:self.splitTableViewController];
    //[self addChildViewController:self.splitTableViewController];
    //[self.splitTableViewController didMoveToParentViewController:self];
}



//- (void)willMoveToParentViewController:(UIViewController *)parent {
//    if (parent) {
//        if (![self.childViewControllers containsObject:self.bottomViewController]) {
//            [self setupBottomViewController:self.bottomViewControllerSetup];
//
//        }
//    }
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self startListeningToOrientationChanges];
    }

    //[self.view setNeedsLayout];
    //[self.view layoutIfNeeded];
//    if (!CGPointEqualToPoint(CGPointZero, self.previousContentOffset)) {
//        [self.view.scrollView setContentOffset:self.previousContentOffset animated:NO];
//    }

    if (!self.view.bottomViewController) {
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            [self setupBottomViewController:self.splitViewControllerSetup];
//        } else {
            [self setupBottomViewController:self.bottomViewControllerSetup];
//        }

        [self.view.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, (self.view.frame.size.height*2) -[GVModalCameraContainerView heightOfNavHeader]  - splitTablePaneHeight )];
        //if (self.bottomViewController.view.layer.needsLayout) {
        self.view.bottomContainerView.frame = CGRectMake(0, [self.view contentOffsetForBottomView], self.view.frame.size.width, self.view.frame.size.height - [GVModalCameraContainerView heightOfNavHeader]);
        self.view.bottomViewController.view.frame = self.view.bottomContainerView.bounds;
        //}
        [self.view.scrollView setContentOffset:CGPointZero animated:NO];

        //[self.view.fastView setNeedsLayout];
        //[self.view.fastView layoutIfNeeded];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
#if FAKE_EXTERNAL_DISPLAY
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view.scrollView setContentOffset:CGPointMake(0, 700) animated:YES];
            [self.view setNeedsDisplay];
            [self.view.layer displayIfNeeded];
//            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"contentOffset"];
//            anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
//            anim.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 400)];
//            anim.removedOnCompletion = NO;
//            anim.beginTime = AVCoreAnimationBeginTimeAtZero;
//            
//            [self.view.scrollView.layer addAnimation:anim forKey:nil];
            
            
        });

        
#endif
        
        //[self.bottomViewController.view setNeedsLayout];
        //[self.bottomViewController.view layoutIfNeeded];
    }

}


- (CGFloat)transitionAngle {
    return DEGREES_TO_RADIANS(15.0f);
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {

    NSBlockOperation *blockOperation = [NSBlockOperation new];
    @weakify(blockOperation);
    @weakify(self);
    
    [blockOperation addExecutionBlock:^{
        
        if ([blockOperation_weak_ isCancelled]) {
            return;
        }
        
        @strongify(self);
        
        [self.presentationOperationQueue cancelAllOperations];
        self.presentationOperationQueue = nil;
    
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            @strongify(self);
            
            [self.topViewController didEndDisplay];
            
            self.animatedBack = YES;
            
            if (flag) {

                
                self.preferredStatusBarStyle = viewControllerToPresent.preferredStatusBarStyle;
                self.preferredStatusBarUpdateAnimation = UIStatusBarAnimationSlide;
                self.prefersStatusBarHidden = viewControllerToPresent.prefersStatusBarHidden;
                //self.prefersStatusBarHidden = NO;
                self.aCustomPresentedViewController = viewControllerToPresent;
            #if SHOWING_MANUAL_ANIMATION
                UIView *viewToPresent = viewControllerToPresent.view;
            //    if ([viewControllerToPresent conformsToProtocol:@protocol(GVReuseableViewSnapshot)]
            //        && [viewControllerToPresent respondsToSelector:@selector(reusabelViewSnapshot)]) {
            //        viewToPresent = [viewControllerToPresent performSelector:@selector(reusabelViewSnapshot)];
            //    }
                [self.view.window addSubview:viewToPresent];
                [self.view.window bringSubviewToFront:viewToPresent];
                [self addChildViewController:viewControllerToPresent];
                [viewControllerToPresent didMoveToParentViewController:self];
            #endif


                CATransform3D currentTopTransform = self.view.topControllerTransform;

                CATransform3D toTopTransform = CATransform3DScale(currentTopTransform, .9, .9, 1);
                toTopTransform = CATransform3DTranslate(toTopTransform, 0, -50, 0);
                toTopTransform = CATransform3DRotate(toTopTransform, DEGREES_TO_RADIANS(15.0f), 1.0f, 0.0, 0.0);


                CATransform3D currentBottomTransform = CATransform3DIdentity;

                self.view.topContainerView.layer.mask = nil;

                CATransform3D toBottomTransform = CATransform3DScale(currentBottomTransform, 0.8, 0.8, 1);
                toBottomTransform = CATransform3DRotate(toBottomTransform, DEGREES_TO_RADIANS(15.0f), 1.0f, 0.0, 0.0);
                
                toBottomTransform = CATransform3DTranslate(toBottomTransform, 0, -120, 0);
                toBottomTransform.m34 = 1/-1000;

                self.view.bottomContainerView.layer.zPosition = -1000000;

                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [CATransaction setAnimationDuration:[self transitionDuration:nil]];

                self.view.bottomContainerView.layer.anchorPointZ = 1;

                CABasicAnimation *bottomAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
                bottomAnimation.fromValue = [NSValue valueWithCATransform3D:currentBottomTransform];
                self.transitioningTransform = [NSValue valueWithCATransform3D:self.view.topControllerTransform];
                bottomAnimation.toValue = [NSValue valueWithCATransform3D:toTopTransform];
                self.transitioningTransformBack = [NSValue valueWithCATransform3D:toTopTransform];
                bottomAnimation.duration = [self transitionDuration:nil];
                //self.view.topViewController.view.layer.transform = toTopTransform;

                //self.view.topViewController.view.layer.transform = toTopTransform;
                self.view.bottomContainerView.layer.transform = toBottomTransform;

                bottomAnimation.additive = YES;

                bottomAnimation.fillMode = kCAFillModeForwards;
                //bottomAnimation.repeatCount = 1;
                //bottomAnimation.autoreverses = YES;
                bottomAnimation.removedOnCompletion = NO;
                bottomAnimation.delegate = self;
                //self.basicAnimation = bottomAnimation;
                //self.basicAnimation.repeatCount = 1;
                //self.basicAnimation.delegate = self;
                //self.basicAnimation.repeatDuration = [self transitionDuration:nil];
                //self.basicAnimation.autoreverses = YES;
                //self.basicAnimation.removedOnCompletion = NO;
                [self.view.topViewController.view.layer addAnimation:bottomAnimation forKey:@"moveBack"];
                //[self.view.topViewController.view.layer addAnimation:bottomAnimation forKey:@"moveBack"];
                self.view.bottomContainerView.layer.allowsEdgeAntialiasing = YES;
                self.view.bottomContainerView.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;


                CABasicAnimation *anAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
                anAnim.fromValue = [NSValue valueWithCATransform3D:currentBottomTransform];
                anAnim.toValue = [NSValue valueWithCATransform3D:toBottomTransform];
                anAnim.duration = [self transitionDuration:nil];

                [self.view.bottomContainerView.layer addAnimation:anAnim forKey:nil];

                [CATransaction commit];

                CGRect toFrame = CGRectIntegral(self.view.frame);
                CGRect fromFrame = CGRectIntegral(self.view.frame);
                fromFrame.origin.y = self.view.frame.size.height;

                //viewControllerToPresent.view.frame = fromFrame;
            }
        #if SHOWING_MANUAL_ANIMATION

            CABasicAnimation *moveAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
            moveAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.size.height, 0)];
            moveAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            moveAnim.duration = [self transitionDuration:nil];
            moveAnim.fillMode = kCAFillModeForwards;
            moveAnim.delegate = self;
            moveAnim.removedOnCompletion = NO;
            //self.transitionStartAnimation = moveAnim;

            [viewControllerToPresent.view.layer addAnimation:moveAnim forKey:@"presentation"];

        #else

            [super presentViewController:viewControllerToPresent animated:YES completion:completion];
        #endif

            if (!flag) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self.presentationOperationQueue cancelAllOperations];
                    self.presentationOperationQueue = [NSOperationQueue new];
                    self.presentationOperationQueue.maxConcurrentOperationCount = 1;
                });
            }
            
            //CAAnimationGroup *grp = [CAAnimationGroup animation];
            [self setNeedsStatusBarAppearanceUpdate];
                
        });
        
    }];
    [self.presentationOperationQueue addOperations:@[blockOperation] waitUntilFinished:YES];

}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    @weakify(blockOperation);
    @weakify(self);
    
    [blockOperation addExecutionBlock:^{
        
        if ([blockOperation_weak_ isCancelled]) {
            return ;
        }
        
        [self.presentationOperationQueue cancelAllOperations];
        self.presentationOperationQueue = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            
            
            
            self.view.hidden = NO;

//            if (self.aCustomPresentedViewController.presentedViewController != nil) {
//                
//                //[super dismissViewControllerAnimated:flag completion:completion];
//                //self.aCustomPresentedViewController = nil;
//                //[self.presentationOperationQueue cancelAllOperations];
//                //if (self.presentationOperationQueue != nil) {
//                ///    [self.presentationOperationQueue cancelAllOperations];
//                //    self.presentationOperationQueue = [NSOperationQueue new];
//                //    self.presentationOperationQueue.maxConcurrentOperationCount = 1;
//                //}
//                return;
//            }
            
            if (!self.isAnimatedBack) {
                // we don't need to do anything?
                if (self.presentationOperationQueue == nil) {
                    self.presentationOperationQueue = [NSOperationQueue new];
                    self.presentationOperationQueue.maxConcurrentOperationCount = 1;
                }
                return;
            }
            
            self.animatedBack = NO;
            
            if (flag) {
            
                UIViewController *viewControllerToPresent = self.aCustomPresentedViewController;
                self.preferredStatusBarStyle = viewControllerToPresent.preferredStatusBarStyle;
                self.preferredStatusBarUpdateAnimation = UIStatusBarAnimationSlide;
                self.prefersStatusBarHidden = YES;

                CATransform3D currentBottomTransform = CATransform3DIdentity;
                //self.view.shapeLayerMask.fillColor = [UIColor whiteColor].CGColor;
                //self.view.shapeLayerMask.backgroundColor = [UIColor whiteColor].CGColor;
                //[self.view.shapeLayerMask setNeedsDisplay];
                //self.view.topContainerView.layer.opacity = 1.0;
                //self.view.topContainerView.layer.mask = nil;

                CATransform3D toBottomTransform = CATransform3DScale(currentBottomTransform, 0.8, 0.8, 1);
                toBottomTransform = CATransform3DRotate(toBottomTransform, DEGREES_TO_RADIANS(-15.0f), 1.0f, 0.0, 0.0);
                toBottomTransform = CATransform3DTranslate(toBottomTransform, 0, -120, 0);
                toBottomTransform.m34 = 1/-1000;

                self.view.bottomContainerView.layer.zPosition = -1000000;

                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [CATransaction setAnimationDuration:[self transitionDuration:nil]];

                self.view.bottomContainerView.layer.anchorPointZ = 1;

                CABasicAnimation *bottomAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
                bottomAnimation.fromValue = self.transitioningTransformBack;
                bottomAnimation.toValue = self.transitioningTransform;

                //bottomAnimation.additive = YES;

                bottomAnimation.duration = [self transitionDuration:nil];

                //bottomAnimation.fillMode = kCAFillModeForwards;
                //bottomAnimation.removedOnCompletion = NO;
                //self.view.topViewController.view.layer.transform = [self.transitioningTransform CATransform3DValue];

                //self.basicAnimation.beginTime = 2;
                //self.basicAnimation.speed = 0;
                //self.basicAnimation.delegate = nil;
                //self.basicAnimation.removedOnCompletion = YES;
                //self.basicAnimation = nil;
                //self.basicAnimation.delegate = self;
                //self.topViewController.view.layer.speed = 1.0;

                [self.view.topViewController.view.layer removeAllAnimations];
                bottomAnimation.delegate = self;
                bottomAnimation.removedOnCompletion = NO;
                //bottomAnimation.fillMode = kCAFillModeForwards;
                [self.view.topViewController.view.layer addAnimation:bottomAnimation forKey:@"moveForward"];
                //[self resumeLayer:self.topViewController.view.layer];
                //-self.topViewController.view.layer.transform = [self.transitioningTransform CATransform3DValue];

                self.view.bottomContainerView.layer.allowsEdgeAntialiasing = YES;
                self.view.bottomContainerView.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;


                CABasicAnimation *anAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
                anAnim.fromValue = [NSValue valueWithCATransform3D:toBottomTransform];
                anAnim.toValue = [NSValue valueWithCATransform3D:currentBottomTransform];
                anAnim.duration = [self transitionDuration:nil];

                self.view.bottomContainerView.layer.transform = currentBottomTransform;
                anAnim.delegate = self;
                [self.view.bottomContainerView.layer addAnimation:anAnim forKey:@"moveForward"];
                
                [CATransaction commit];

                CGRect fromFrame = CGRectIntegral(self.view.bounds);
                CGRect toFrame = CGRectIntegral(self.view.bounds);
                toFrame.origin.y = self.view.bounds.size.height;
                    
            }
            //viewControllerToPresent.view.frame = fromFrame;
        #if SHOWING_MANUAL_ANIMATION
            CABasicAnimation *translateAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
            translateAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            translateAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DTranslate(CATransform3DIdentity, 0, self.view.frame.size.height, 0)];
            //self.transitionCompletionAnimation = translateAnim;
            translateAnim.duration = [self transitionDuration:nil];
            translateAnim.delegate = self;
            translateAnim.removedOnCompletion = NO;
            translateAnim.fillMode = kCAFillModeForwards;
            [viewControllerToPresent.view.layer addAnimation:translateAnim forKey:@"dismissal"];
        #else
            
            [super dismissViewControllerAnimated:YES completion:completion];
        #endif
            [self setNeedsStatusBarAppearanceUpdate];
            
            if (!flag) {
                [self.presentationOperationQueue cancelAllOperations];
                self.presentationOperationQueue = [NSOperationQueue new];
                self.presentationOperationQueue.maxConcurrentOperationCount = 1;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self);
                [self forceCameraReload];
            });
        //    @weakify(self);
        //
        //    [UIView animateWithDuration:[self transitionDuration:nil]
        //                          delay:0.0
        //                        options:UIViewAnimationOptionCurveLinear
        //                     animations:^{
        //                         [self setNeedsStatusBarAppearanceUpdate];
        //                         viewControllerToPresent.view.frame = toFrame;
        //
        //                     } completion:^(BOOL finished) {
        //                         if (finished) {
        //                             @strongify(self);
        //                             self.basicAnimation = nil;
        //
        //                             [self.topViewController willDisplay];
        //
        //                             [self.view.topViewController.view.layer removeAllAnimations];
        //                             //[self.view.bottomContainerView.layer removeAllAnimations];
        //                             self.view.topContainerView.layer.mask = self.view.shapeLayerMask;
        //
        //                             [self.aCustomPresentedViewController.view removeFromSuperview];
        //                             [self.aCustomPresentedViewController willMoveToParentViewController:nil];
        //                             [self.aCustomPresentedViewController removeFromParentViewController];
        //                             self.aCustomPresentedViewController = nil;
        //                         }
        //                     }];
        });
    }];
    [self.presentationOperationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    //if (flag) {
        [self.presentationOperationQueue cancelAllOperations];
        self.presentationOperationQueue = [NSOperationQueue new];
        self.presentationOperationQueue.maxConcurrentOperationCount = 1;
//
//        if (anim == [self.view.topViewController.view.layer animationForKey:@"moveForward"]) {
//            
//            [self.view.topViewController.view.layer removeAllAnimations];
////            [self.topViewController willDisplay];
////
////            
////            
////            DLogMainThread();
////            self.topViewController.view.layer.transform = [self.transitioningTransform CATransform3DValue];
////            //[self.topViewController.view.layer setNeedsDisplay];
////            [self.topViewController.view.layer removeAllAnimations];
////            [self.aCustomPresentedViewController.view.layer removeAllAnimations];
////            [self.aCustomPresentedViewController.view removeFromSuperview];
////            [self.aCustomPresentedViewController willMoveToParentViewController:nil];
////            [self.aCustomPresentedViewController removeFromParentViewController];
////            self.aCustomPresentedViewController = nil;
//            //if (self.aCustomPresentedViewController.presentedViewController == nil) {
//            //[self.presentationOperationQueue cancelAllOperations];
//            self.presentationOperationQueue = [NSOperationQueue new];
//            self.presentationOperationQueue.maxConcurrentOperationCount = 1;
//            //}
//        } else if (anim == [self.topViewController.view.layer animationForKey:@"moveBack"]) {
//            //[self pauseLayer:self.topViewController.view.layer];
//#if HIDES_WHEN_ANIMATED
//            self.view.hidden = YES;
//#endif
//            self.presentationOperationQueue = [NSOperationQueue new];
//            self.presentationOperationQueue.maxConcurrentOperationCount = 1;
//            
//            //CAAnimation *moveBackAnim = [self.topViewController.view.layer animationForKey:@"moveBack"];
//            //moveBackAnim.speed = 0.0;
//            return;
//        }
    //}
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//
//
//}

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//
//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Orientation changes

- (void)startListeningToOrientationChanges {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)stopListeningToOrientationChanges {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    switch (orientation) {
        case UIDeviceOrientationUnknown:

            break;
        case UIDeviceOrientationPortrait: {
            if (self.lastOrientation != UIInterfaceOrientationPortrait) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationPortrait;
                CGRect bounds = [UIScreen mainScreen].bounds;
                [self.view setNeedsLayout];
                //[self.view layoutIfNeeded];
                //self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
                //self.cameraOverlayView.bounds = bounds;
                //[self.cameraOverlayView setNeedsLayout];
                //[self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.cameraOverlayView.frame = self.cameraOverlayView.bounds;
            }
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            if (self.lastOrientation != UIInterfaceOrientationPortraitUpsideDown) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationPortraitUpsideDown;
                CGRect bounds = [UIScreen mainScreen].bounds;
                [self.view setNeedsLayout];
                //[self.view layoutIfNeeded];

                //self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
                //self.cameraOverlayView.bounds = bounds;
                //[self.cameraOverlayView setNeedsLayout];
                //[self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
                //self.cameraOverlayView.frame = self.cameraOverlayView.bounds;
            }
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            if (self.lastOrientation != UIInterfaceOrientationLandscapeLeft) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationLandscapeLeft;
                CGRect bounds = [UIScreen mainScreen].bounds;
                [self.view setNeedsLayout];
                //[self.view layoutIfNeeded];
                //self.cameraOverlayView.bounds = bounds;
                //self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
                //[self.cameraOverlayView setNeedsLayout];
                //[self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.cameraOverlayView.frame = CGRectMake(0, 0, self.cameraOverlayView.bounds.size.height, self.cameraOverlayView.bounds.size.width);
            }
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            if (self.lastOrientation != UIInterfaceOrientationLandscapeRight) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationLandscapeRight;
                CGRect bounds = [UIScreen mainScreen].bounds;
                [self.view setNeedsLayout];
                //[self.view layoutIfNeeded];
                //self.cameraOverlayView.bounds = bounds;
                //self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
                //[self.cameraOverlayView setNeedsLayout];
                //[self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.cameraOverlayView.frame = CGRectMake(0, 0, self.cameraOverlayView.bounds.size.height, self.cameraOverlayView.bounds.size.width);
            }
            break;
        }
        case UIDeviceOrientationFaceUp:

            break;
        case UIDeviceOrientationFaceDown:

            break;
        default:
            break;
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .30;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *containerView = [transitionContext containerView];

    //UIView *fromSnapshot = [fromVC.view resizableSnapshotViewFromRect:fromVC.view.bounds afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
//    CAShapeLayer *blankLayer = [CAShapeLayer layer];
//    blankLayer.opaque = YES;
//    blankLayer.needsDisplayOnBoundsChange = NO;
//    [blankLayer setNeedsDisplay];
//    blankLayer.fillColor = [UIColor whiteColor].CGColor;
//    blankLayer.backgroundColor = [UIColor whiteColor].CGColor;
//    [containerView.layer addSublayer:blankLayer];

    CGFloat affineTransformScale = .9;


    //blankLayer.frame = containerView.bounds;
    containerView.opaque = YES;
    containerView.backgroundColor = [GVModalCameraContainerViewController classBackgroundColor];

    if (self.presenting) {

        UIView *bgSnapshot = [self.view.bgView snapshotViewAfterScreenUpdates:NO];
        UIView *topSnapshot = [self.view.topContainerView snapshotViewAfterScreenUpdates:NO];
        UIView *bottomSnapshot = [self.view.bottomContainerView snapshotViewAfterScreenUpdates:NO];
        [containerView addSubview:bgSnapshot];
        [containerView addSubview:topSnapshot];
        [containerView addSubview:bottomSnapshot];
        [containerView addSubview:toVC.view];

        bgSnapshot.frame = containerView.bounds;
        topSnapshot.frame = self.view.topContainerView.frame;
        bottomSnapshot.frame = [self.view convertRect:self.view.bottomContainerView.frame fromView:self.view.scrollView];

        //CGRect fromVCFromFrame = containerView.bounds;
        //fromVC.view.frame = fromVCFromFrame;

        CGRect toVCFromFrame = containerView.bounds;
        toVCFromFrame.origin.y = containerView.bounds.size.height;
        toVC.view.frame = toVCFromFrame;

        CGRect toVCToFrame = containerView.bounds;

        [UIView animateWithDuration:[self transitionDuration:nil]
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             bottomSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity, affineTransformScale, affineTransformScale);
                             topSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity, .8, .8);
                             toVC.view.frame = toVCToFrame;
        } completion:^(BOOL finished){
            if (finished) {
                [bgSnapshot removeFromSuperview];
                [topSnapshot removeFromSuperview];
                [bottomSnapshot removeFromSuperview];
                //[blankLayer removeFromSuperlayer];
                [fromVC.view removeFromSuperview];

                [transitionContext completeTransition:YES];
            }
        }];

    } else {
        UIView *bgSnapshot = [self.view.bgView snapshotViewAfterScreenUpdates:NO];
        UIView *topSnapshot = [self.view.topContainerView snapshotViewAfterScreenUpdates:NO];
        UIView *bottomSnapshot = [self.view.bottomContainerView snapshotViewAfterScreenUpdates:NO];
        [containerView addSubview:bgSnapshot];
        [containerView addSubview:topSnapshot];
        [containerView addSubview:bottomSnapshot];
        //[containerView addSubview:toVC.view];
        [containerView addSubview:fromVC.view];

        bgSnapshot.frame = containerView.bounds;
        topSnapshot.frame = self.view.topContainerView.frame;
        bottomSnapshot.frame = [self.view convertRect:self.view.bottomContainerView.frame fromView:self.view.scrollView];

        CGRect fromVCFromFrame = containerView.bounds;
        fromVC.view.frame = containerView.bounds;

        CGRect fromVCToFrame = containerView.bounds;
        fromVCToFrame.origin.y = containerView.bounds.size.height;


        topSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity, .8, .8);
        bottomSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity, affineTransformScale, affineTransformScale);

        //CGRect toVCFromFrame = containerView.bounds;
        //toVC.view.frame = containerView.bounds;
        //toVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, affineTransformScale, affineTransformScale);


        [UIView animateWithDuration:[self transitionDuration:nil]
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             topSnapshot.transform = CGAffineTransformIdentity;
                             bottomSnapshot.transform = CGAffineTransformIdentity;
                             //toVC.view.transform = CGAffineTransformIdentity;
                             fromVC.view.frame = fromVCToFrame;
                         }completion:^(BOOL finished) {
                             if (finished) {
                                 [bgSnapshot removeFromSuperview];
                                 [topSnapshot removeFromSuperview];
                                 [bottomSnapshot removeFromSuperview];
                                 //[blankLayer removeFromSuperlayer];
                                 [fromVC.view removeFromSuperview];
                                 [transitionContext completeTransition:YES];
                             }
                         }];
    }
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.presenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.presenting = NO;
    return self;
}

//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
//    return self;
//}
//
//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
//    return self;
//}

#pragma mark - Delegate methods


@end
