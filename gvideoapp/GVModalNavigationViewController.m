//
//  GVModalNavigationViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVModalNavigationViewController.h"
#import "GfitHorizontalEdgePanPercentDrivenInteractiveTransition.h"
#import "GfitSerialOperationQueue.h"
#import "GfitRootNavigationDropShadowView.h"
#import "GVTintColorUtility.h"
#import "UIWindow+SBWindow.h"
#import "UIColor+Image.h"
#import "GVModalNavigationBar.h"
#import <objc/runtime.h>
#import "GVNavigationToolbar.h"

static const CGFloat kNavigationBarHeight = 64.0f;

@interface GVModalNavigationViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, GfitHorizontalEdgePanPercentDrivenInteractiveTransitionProtocol, UITabBarControllerDelegate, UINavigationBarDelegate>



//@property (nonatomic, strong) GVModalNavigationView *view;

@property (nonatomic, strong) GfitHorizontalEdgePanPercentDrivenInteractiveTransition *edgePanInteractiveTransition;
@property (nonatomic, strong) GfitSerialOperationQueue *operationQueue;


@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitioningContext;

@property (nonatomic, assign) BOOL transitioning;
@property (nonatomic, assign) BOOL pushing;
@property (nonatomic, assign) BOOL transitioningInteractively;

@property (nonatomic, strong) UIWindow *statusBarWindow;

@property (nonatomic, strong) UIView *fromNavigationSnapshotView;
@property (nonatomic, strong) UIView *toNavigtionSnapshotView;
//@property (nonatomic, strong) GVModalNavigationBar *modalNavigationBar;
//@property (nonatomic, strong) UIToolbar *navigationBarBackgroundToolbar;
@property (nonatomic, strong) GVNavigationToolbar *navigationToolbar;

@end

@implementation GVModalNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBar.hidden = YES;
        self.operationQueue = [[GfitSerialOperationQueue alloc] init];
    }
    return self;
}

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

//- (void)loadView {
//    [super loadView];
//    self.view = [[GVModalNavigationView alloc] initWithFrame:CGRectZero];
//}

//- (UINavigationBar*)navigationBar {
//    //return (UINavigationBar*)self.modalNavigationBar;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationToolbar = [[GVNavigationToolbar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.navigationToolbar];

    GVModalNavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    //navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //navigationBar.translatesAutoresizingMaskIntoConstraints = NO;

    //self.navigationBarBackgroundToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    //[GVTintColorUtility applyNavigationBarTintColor:self.navigationBarBackgroundToolbar];
    //[self.view addSubview:self.navigationBarBackgroundToolbar];

    //[GVTintColorUtility applyNavigationBarTintColor:navigationBar];
    //self.modalNavigationBar = navigationBar;
    //self.modalNavigationBar.delegate = self;
    //[self.view addSubview:navigationBar];

    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    //self.modalNavigationBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kNavigationBarHeight);
    //self.navigationBarBackgroundToolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kNavigationBarHeight);

    //[self.view bringSubviewToFront:self.navigationBarBackgroundToolbar];
    //[self.view bringSubviewToFront:self.modalNavigationBar];

    CGFloat toolbarHeight = 50;

    self.navigationToolbar.frame = CGRectMake(0, self.view.bounds.size.height - toolbarHeight, self.view.bounds.size.width, toolbarHeight);

    [self.view bringSubviewToFront:self.navigationToolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hackTheNavigationBar {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        //self.navigationBar.layer.mask = nil;
        //  [self setupNavigationBar];
        // [self.modalNavigationBar.layer setNeedsDisplay];
        //[self.modalNavigationBar.layer displayIfNeeded];
    });

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

//- (void)setupNavigationBar {
//    GVModalNavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kNavigationBarHeight)];
//    //navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    //navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
//    //[GVTintColorUtility applyNavigationBarTintColor:navigationBar];
//    //navigationBar.translucent = YES;
//    //navigationBar.layer.contentsScale = 2;
////    CGFloat contentScale = [UIScreen mainScreen].scale;
////    for (CALayer *layer in navigationBar.layer.sublayers) {
////
////        for (CALayer *l in layer.sublayers) {
////            l.rasterizationScale = contentScale;
////        }
////        layer.rasterizationScale = contentScale;
////    }
//    //[GVTintColorUtility applyNavigationBarTintColor:navigationBar];
//    [navigationBar setBackgroundColor:[UIColor clearColor]];
//    [navigationBar setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
//    if (self.modalNavigationBar) {
//        [self.modalNavigationBar removeFromSuperview];
//        self.modalNavigationBar = nil;
//    }
//    self.modalNavigationBar = navigationBar;
//    if (self.selectedViewController) {
//        [self.modalNavigationBar pushNavigationItem:self.selectedViewController.navigationItem animated:NO];
//    }
//    [self.view addSubview:navigationBar];
//    [self.view bringSubviewToFront:self.modalNavigationBar];
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //[self setupNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    //[self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    //self.edgePanInteractiveTransition = [[GfitHorizontalEdgePanPercentDrivenInteractiveTransition alloc] initWithDelegate:self];

    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;

#if TESTING_WITHOUT_CAMERA
    [self didEndDisplay];
#endif

    self.delegate = self;
    [self setNeedsStatusBarAppearanceUpdate];

    //[self.edgePanInteractiveTransition setupRightEdgePanGestureRecognizer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.edgePanInteractiveTransition teardownLeftEdgePanGestureRecognizer];
    [self.edgePanInteractiveTransition teardownRightEdgePanGestureRecognizer];
    self.edgePanInteractiveTransition.delegate = nil;
    self.edgePanInteractiveTransition = nil;

    //[self setupNavigationBar];

//    [self.modalNavigationBar removeFromSuperview];
//    self.modalNavigationBar = nil;

    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
    self.delegate = nil;
}

- (void)horizontalLeftEdgePanInteractiveTransitionStart {
    self.transitioningInteractively = YES;
    //[self backToMainMenu:nil];
    [self popViewControllerAnimated:YES];
    
}

- (void)horizontalRightEdgePanInteractiveTransitionStart {
    self.transitioningInteractively = YES;
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    @weakify(blockOperation);
    @weakify(self);
    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{

            @strongify(self);

            if ([blockOperation_weak_ isCancelled]) {
                return;
            }

            [self _pushGestureViewControllerAnimated:nil];

        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)_pushGestureViewControllerAnimated:(id)sender {

}

- (void)popViewControllerAnimated:(BOOL)animated {

    @weakify(self);
    NSNumber *fromIndex = [NSNumber numberWithUnsignedInteger:self.selectedIndex];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    id lastObj = [viewControllers lastObject];
    [viewControllers removeObject:lastObj];

    if ([self.viewControllers count] > 1) {

        [self setViewControllers:viewControllers animated:NO];

        [UIView animateWithDuration:( animated ? [self transitionDuration:nil] : 0)
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             @strongify(self);

                             if (fromIndex.floatValue > 0) {
                                 [self setSelectedIndex:[[NSNumber numberWithFloat:(fromIndex.floatValue - 1)] unsignedIntegerValue]];
                             }

                         } completion:^(BOOL finished) {
                             if (finished) {
                                 self.operationQueue = [[GfitSerialOperationQueue alloc] init];
                             }
                         }];


    } else {
        //if (viewController.navigationItem) {
        //[self.modalNavigationBar popNavigationItemAnimated:animated];
        //}


        [self setViewControllers:@[] animated:animated];
        self.operationQueue = [GfitSerialOperationQueue new];
    }

}

- (void)popToRootViewControllerAnimated:(BOOL)animated {

    @weakify(self);
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    @weakify(blockOperation);

    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);

            if ([blockOperation_weak_ isCancelled]) {
                return ;
            }

            [self.operationQueue cancelAllOperations];
            self.operationQueue = nil;

            NSNumber *fromIndex = [NSNumber numberWithUnsignedInteger:self.selectedIndex];

            if ([self.viewControllers count] > 0) {
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
                id lastObj = [viewControllers firstObject];
                [self setViewControllers:@[lastObj] animated:NO];

                [UIView animateWithDuration:( animated ? [self transitionDuration:nil] : 0)
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     @strongify(self);

                                    [self setSelectedIndex:0];

                                 } completion:^(BOOL finished) {
                                     if (finished) {
                                         self.operationQueue = [[GfitSerialOperationQueue alloc] init];
                                     }
                                 }];


            } else {
    //            if (viewController.navigationItem) {
    //                [self.modalNavigationBar pushNavigationItem:viewController.navigationItem animated:animated];
    //            }

                [self setViewControllers:@[] animated:NO];
                self.operationQueue = [GfitSerialOperationQueue new];
            }
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated {

    @weakify(self);
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    @weakify(blockOperation);

    [blockOperation addExecutionBlock:^{

        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);

            if ([blockOperation_weak_ isCancelled]) {
                return;
            }

            [self.operationQueue cancelAllOperations];
            self.operationQueue = nil;

            NSNumber *fromIndex = [NSNumber numberWithUnsignedInteger:self.selectedIndex];

            if ([self.viewControllers count] > 0) {
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
                [viewControllers addObject:viewController];
                [self setViewControllers:viewControllers animated:NO];



                [UIView animateWithDuration:( animated ? [self transitionDuration:nil] : 0)
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     @strongify(self);

                                     if (fromIndex.floatValue > -1) {
                                         [self setSelectedIndex:[[NSNumber numberWithFloat:(fromIndex.floatValue + 1)] unsignedIntegerValue]];
                                     } else {
                                         [self setSelectedIndex:0];
                                     }

                                 } completion:^(BOOL finished) {
                                     if (finished) {
                                         self.operationQueue = [GfitSerialOperationQueue new];
                                     }
                                 }];


            } else {
                if (viewController.navigationItem) {
                    //[self.modalNavigationBar pushNavigationItem:viewController.navigationItem animated:animated];
                }

                [self setViewControllers:@[viewController] animated:NO];
                self.operationQueue = [GfitSerialOperationQueue new];
            }
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];



    //    if (animated) {
        
        //self.selectedViewController.transitioningDelegate = self;

        //[self addChildViewController:self.selectedViewController];
        //[self.selectedViewController didMoveToParentViewController:self];

//        [self transitionFromViewController:fromVC
//                          toViewController:self.selectedViewController
//                                  duration:[self transitionDuration:nil]
//                                   options:UIViewAnimationOptionAllowAnimatedContent
//                                animations:^{
//
//                                } completion:^(BOOL finished) {
//                                    if (finished) {
//
//                                    }
//                                }];

//        [UIView animateWithDuration:(animated ? [self transitionDuration:nil] : 0.0)
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             @strongify(self);
//
//
//                             if (self.selectedViewController.navigationItem) {
//                                 [self.view.navigationBar pushNavigationItem:self.selectedViewController.navigationItem animated:animated];
//                             }
//                         } completion:^(BOOL finished) {
//                             if (finished) {
//                                 @strongify(self);
//                                 [self.selectedViewController didMoveToParentViewController:self];
//                             }
//                         }];

        // [self presentViewController:self.selectedViewController animated:animated completion:^{
        //@strongify(self);
//            [self dismissViewControllerAnimated:NO completion:^{
//                @strongify(self);
//                [self.view setupSelectedViewController:self.selectedViewController];
//   [self addChildViewController:self.selectedViewController];
            //                [self.selectedViewController didMoveToParentViewController:self];
//            }];
        //}];
//    } else {
//        [self.view setupSelectedViewController:self.selectedViewController];
//        [self addChildViewController:self.selectedViewController];
//        [self.selectedViewController didMoveToParentViewController:self];
//    }
    //
//    [UIView animateWithDuration:(animated ? [self transitionDuration:nil] : 0.0)
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         @strongify(self);
//
//
//                         if (self.selectedViewController.navigationItem) {
//                             [self.view.navigationBar pushNavigationItem:self.selectedViewController.navigationItem animated:animated];
//                         }
//                     } completion:^(BOOL finished) {
//                         if (finished) {
//                             @strongify(self);
//                             [self.selectedViewController didMoveToParentViewController:self];
//                         }
//                     }];





}

#pragma mark - Navigation Bar Delegate Methods 
// called to push. return NO not to.
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    //[self popViewControllerAnimated:YES];
    return YES;
}
// called at end of animation of push or immediately if not animated
- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {

}
// same as push methods
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (!self.transitioning && item == navigationBar.topItem) {
        @weakify(self);
        NSBlockOperation *blockOperation = [NSBlockOperation new];
        @weakify(blockOperation);

        [blockOperation addExecutionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);

                if ([blockOperation_weak_ isCancelled]) {
                    return;
                }

                self.transitioning = YES;

                [self.operationQueue cancelAllOperations];
                self.operationQueue = nil;

                [self popViewControllerAnimated:YES];
            });
        }];
        [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];


    }
    return YES;
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {

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

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC {
    float fromIndex = [[NSNumber numberWithUnsignedInteger:[self.viewControllers indexOfObject:fromVC]] floatValue] + 1;
    float toIndex = [[NSNumber numberWithUnsignedInteger:[self.viewControllers indexOfObject:toVC]] floatValue] + 1;
    self.pushing = (fromIndex < toIndex);
    return self;


}

- (id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                      interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    if (self.transitioningInteractively) {
        return self.edgePanInteractiveTransition;
    }
    return nil;
}

#pragma mark - UIViewController animated transitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning> )transitionContext {
	//return 5.0f;
	return 0.30f;
	//return 1.0f;
}

/**
 *  Delegate method for the fake navigation bar we present during animation
 *
 *  @param bar the `UINavigationBar` object
 *
 *  @return the `UIBarPosition` style
 */
- (UIBarPosition)positionForBar:(id <UIBarPositioning> )bar {
	return UIBarPositionBottom;
}


- (void)animateTransition:(id <UIViewControllerContextTransitioning> )transitionContext {
	@autoreleasepool {
		// okay here's the plan, we're going to setup a plan, reverse it if necessary, then execute

		/**
		 *  setup
		 */
        //self.transitioning = YES;

		// get view controllers
		UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		UIView *containerView = [transitionContext containerView];

		// create animation start/end values
		const CGRect bounds = containerView.bounds;
		const CGFloat width = CGRectGetWidth(bounds);
		static const CGFloat kSlidingOffset = 96.0f; // constant offset value for view sliding underneath

		const CGRect viewOnScreenFrame = bounds; // view onscreen
		const CGRect newViewOffscreenFrame = CGRectOffset(bounds, width, 0); // new view offscreen
		const CGRect viewSlidingOffscreenFrame = CGRectOffset(bounds, -(kSlidingOffset), 0);  // view slid offscreen

		// create setup interface variables (these are same regardless of present/dismiss)

		//NSString *navControllerFromViewControllerTitle = fromVC.title;
        //        UIViewController *topViewController = self.contentNavigation;
        //		NSString *navControllerTopViewControllerTitle = topViewController.title;
        //        NSArray *contentNavigationViewControllers = self.contentNavigation.viewControllers;
        //        NSString *navControllerBackViewControllerTitle = nil;
        //        // if pushed past 2 controllers this will have to use the back button already there
        //        NSUInteger topViewControllerIndex = [contentNavigationViewControllers indexOfObject:topViewController];
        //        if ([contentNavigationViewControllers count] > 1) {
        //            // it is pushed past 2 controllers
        //            id previousViewController = [contentNavigationViewControllers objectAtIndex:topViewControllerIndex-1];
        //            if (previousViewController && [previousViewController respondsToSelector:@selector(title)]) {
        //                  navControllerBackViewControllerTitle = [previousViewController performSelector:@selector(title) withObject:nil];
        //            }
        //        } else {
        //            // it's not pushed past, just grab the main menu
        //            navControllerBackViewControllerTitle = [self.mainMenuNavigation.title copy];
        //        }

		//GfitFakeNavigationBar *fakeNavigationBar;
		GfitRootNavigationDropShadowView *dropShadowView;

        //self.modalNavigationBar.hidden = YES;
		// create animation fake auxiliary assets

		// container view for front most view
		dropShadowView = [[GfitRootNavigationDropShadowView alloc] initWithFrame:bounds];
		// this should be set to the target views background color
		dropShadowView.backgroundColor = [UIColor whiteColor]; // nav bar is translucent, black bg will show through
		dropShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		// fake the navigation bar item transition push/pop
        GVModalNavigationBar *fakeNavigationBar = nil;
		//fakeNavigationBar = [[GfitFakeNavigationBar alloc] initWithFrame:CGRectMake(0, 0, width, kNavigationBarHeight)];
		fakeNavigationBar.delegate = self;


		// hide the real navigation bar for faking transition
		// HACK: setting navigationBarHidden on the `UINavigationController`
		// casues the status bar fade to no longer be animated
		// setting the layer navigationBar's layer seems to work
		//
		// @note this also has to be called after the navigationViewController's
		// snapshot is taken after updates
		//
		// @note setting the navigationBar.layer.hidden causes layout to change
		// @note setting opacity or alpha doesn't work for some reason
		// setting the zPosition accomplishes our goals perfectly
		// we just want to get it out of the way for the snapshot so
		// we can add our own fake navigation bar on top without an incorrect layout
		//self.contentNavigation.navigationBar.layer.zPosition = -100;

		/**
		 *  these are the plan variables, these get loaded with appropriate values
		 */

		// plan variables for views (reversed on dismiss animation)
		UIView *fromView;
		UIView *toView;

		// plan variables for navigation items (push/pop for present/dismiss)
		UINavigationItem *fromNavigationItem;
		UINavigationItem *toNavigationItem;

		// plan variables for rect (reversed on dismiss animation)
		CGRect fromViewStartFrame;
		CGRect toViewStartFrame;
		CGRect fromViewEndFrame;
		CGRect toViewEndFrame;

		//self.navigationViewController.edgesForExtendedLayout = UIRectEdgeBottom;

		/**
		 *  Here's the reversal if necessary
		 */

		if (self.pushing) {
//			fromView = [fromVC.view snapshotViewAfterScreenUpdates:NO];
//			fromView.layer.shouldRasterize = YES;
//			fromView.layer.drawsAsynchronously = YES;
//			fromView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//            fromView.opaque = YES;
            self.fromNavigationSnapshotView = fromVC.view;

			toView = dropShadowView;

			fromNavigationItem = fromVC.navigationItem;
			toNavigationItem = toVC.navigationItem;

			// sending NO causes the navigation controllers contents to be missing
			// sending YES causes the childViewControllerForStatusBarStyle to be called early
			// and for the change to be instant instead of animated
            UIView *snapshotView;
            if (self.toNavigtionSnapshotView) {
                snapshotView = self.toNavigtionSnapshotView;
            } else {
                //snapshotView = [toVC.view snapshotViewAfterScreenUpdates:YES];
                snapshotView = [toVC.view snapshotViewAfterScreenUpdates:YES];
                self.toNavigtionSnapshotView = snapshotView;
            }
			snapshotView.opaque = YES;
			snapshotView.layer.drawsAsynchronously = YES;
			snapshotView.layer.shouldRasterize = YES;
			snapshotView.layer.rasterizationScale = [UIScreen mainScreen].scale;

			[dropShadowView addSubview:snapshotView];
			[containerView addSubview:fromView];
			[containerView addSubview:toView];

			fromViewStartFrame = viewOnScreenFrame;
			toViewStartFrame = newViewOffscreenFrame;
			fromViewEndFrame = viewSlidingOffscreenFrame;
			toViewEndFrame = viewOnScreenFrame;
		} else {
            if (self.toNavigtionSnapshotView) {
                toView = self.toNavigtionSnapshotView;
            } else {
                toView = [fromVC.view snapshotViewAfterScreenUpdates:YES];
                self.toNavigtionSnapshotView = toView;
            }
            toView.layer.drawsAsynchronously = YES;
            toView.layer.shouldRasterize = YES;
            toView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            toView.opaque = YES;
			fromView = dropShadowView;

			fromNavigationItem = fromVC.navigationItem;
			toNavigationItem = toVC.navigationItem;

			UIView *snapshotView = [toVC.view snapshotViewAfterScreenUpdates:NO];

			snapshotView.opaque = YES;
			snapshotView.layer.shouldRasterize = YES;
			snapshotView.layer.drawsAsynchronously = YES;
			snapshotView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            self.toNavigtionSnapshotView = snapshotView;

			[dropShadowView addSubview:snapshotView];
			[containerView addSubview:toView];
			[containerView addSubview:fromView];

			fromViewStartFrame = viewOnScreenFrame;
			toViewStartFrame = viewSlidingOffscreenFrame;
			fromViewEndFrame = newViewOffscreenFrame;
			toViewEndFrame = viewOnScreenFrame;
		}


		/**
		 *  Setup the animation initial state
		 */
		fromView.frame = fromViewStartFrame;
		toView.frame = toViewStartFrame;

		// setup the drop shadow animation
		//[dropShadowView addSubview:fakeNavigationBar];
		dropShadowView.shadowImageView.alpha = 1.0;

		// required for navigationBar title labels to be in proper places
		// we basically layout both possible states
		[fakeNavigationBar setItems:@[fromNavigationItem] animated:NO];
		[fakeNavigationBar setNeedsLayout];
		[fakeNavigationBar layoutIfNeeded];
		[fakeNavigationBar setItems:@[fromNavigationItem, toNavigationItem] animated:NO];
		[fakeNavigationBar setNeedsLayout];
		[fakeNavigationBar layoutIfNeeded];

		// if reverse animation we're going to animate the pop, otherwise
		// pop it unanimated now to get it ready for the animation start
		if (self.pushing) {
			[fakeNavigationBar popNavigationItemAnimated:NO];
		} else {

		}

		//GfitHorizontalSlidingTabBarController *__weak weakSelf = self;
        @weakify(self);

		[UIView animateWithDuration:[self transitionDuration:transitionContext]
		                      delay:0
		                    options:UIViewAnimationOptionAllowAnimatedContent
		                 animations: ^{
                             /**
                              *  Run the animation
                              */
                             //GfitHorizontalSlidingTabBarController *strongSelf = weakSelf;
                             @strongify(self);

                             fromView.frame = fromViewEndFrame;
                             toView.frame = toViewEndFrame;

                             // animate the drop shadow
                             dropShadowView.shadowImageView.alpha = 0.0;

                             // animate the navigation bar transition
                             if (self.pushing) {
                                 //[self.modalNavigationBar pushNavigationItem:toNavigationItem animated:YES];
                             } else {
                                 //[self.modalNavigationBar popNavigationItemAnimated:YES];
                             }
                         } completion: ^(BOOL finished) {
                             @autoreleasepool {
                                 if (finished) {
                                     /**
                                      *  Undo animation initial state
                                      */
                                     //GfitHorizontalSlidingTabBarController *strongSelf = weakSelf;
                                     @strongify(self);

                                     // remove fake assets
                                     [fromView removeFromSuperview];
                                     [toView removeFromSuperview];
                                     [dropShadowView removeFromSuperview];
                                     //[fakeNavigationBar removeFromSuperview];
                                     //[self.contentNavigation.snapshotView removeFromSuperview];
                                     //self.contentNavigation.snapshotView = nil;
                                     self.transitioning = NO;

                                     // switch back to the the real navigation bar
                                     //self.contentNavigation.navigationBar.layer.zPosition = self.contentNavigation.originalNavigationBarZPosition;

                                     // interactive animation might cancel
                                     if ([transitionContext transitionWasCancelled]) {
                                         // animation cancel
                                         fromView.frame = fromViewStartFrame;
                                         toView.frame = toViewStartFrame;

                                         [containerView addSubview:fromVC.view];

                                     } else {
                                         // animation completion
                                         fromView.frame = fromViewEndFrame;
                                         toView.frame = toViewEndFrame;

                                         [containerView addSubview:toVC.view];



                                     }

                                     [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                                 }
                             }
                         }];
	}
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
    self.transitioningInteractively = NO;
    self.transitioning = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.edgePanInteractiveTransition teardownLeftEdgePanGestureRecognizer];
    [self.edgePanInteractiveTransition teardownRightEdgePanGestureRecognizer];
    if (self.selectedIndex == 0) {
        if ([self.viewControllers count] > [NSNumber numberWithUnsignedInteger:self.selectedIndex].floatValue) {
            [self.edgePanInteractiveTransition setupRightEdgePanGestureRecognizer];
        }
    } else {
        [self.edgePanInteractiveTransition setupLeftEdgePanGestureRecognizer];
    }
}



#pragma mark - Tab Bar View Controller Transitioning Methods




@end
