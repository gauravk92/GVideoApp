//
//  GVNavigationViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/27/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVNavigationViewController.h"

#import "GVSplitMasterNavigationBar.h"
#import "GVNavigationToolbar.h"
#import "GVModalCameraContainerView.h"

NSString * const GVNavigationPushPopNotification = @"GVNavigationPushPopNotification";

@interface GVNavigationViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>


@property (nonatomic, strong) GVNavigationToolbar *navigationToolbar;

@end

@implementation GVNavigationViewController

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    self = [super initWithNavigationBarClass:[UINavigationBar class] toolbarClass:toolbarClass];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        //self.navigationBarHidden = YES;
        //self.navigationBar.hidden = YES;
        self.delegate = self;

    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat toolbarHeight = 50;

    self.view.layer.needsDisplayOnBoundsChange = NO;

    self.navigationToolbar = [[GVNavigationToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [GVModalCameraContainerView heightOfNavHeader] - toolbarHeight, self.view.bounds.size.width, toolbarHeight)];
    [self.navigationToolbar setNeedsDisplay];
    self.navigationToolbar.layer.needsDisplayOnBoundsChange = NO;
    [self.view addSubview:self.navigationToolbar];

    self.view.userInteractionEnabled = YES;

    //[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];

    self.view.backgroundColor = [UIColor whiteColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    //self.navigationBar.layer.shouldRasterize = YES;
    //self.navigationBar.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    
}



- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];



    //self.navigationToolbar.frame = CGRectMake(0, self.view.bounds.size.height - toolbarHeight, self.view.bounds.size.width, toolbarHeight);

    //[self.view bringSubviewToFront:self.navigationToolbar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.view bringSubviewToFront:self.navigationToolbar];
}



//- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
//    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
//    if (self) {
//        self.view.backgroundColor = [UIColor whiteColor];
//    }
//    return self;
//}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor whiteColor];
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

- (CGSize)preferredContentSize {
    return [UIScreen mainScreen].bounds.size;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [self.parentViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self.parentViewController dismissViewControllerAnimated:flag completion:completion];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
//        return YES;
//    }
//    return NO;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
//    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
//        return YES;
//    }
//    return NO;
}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    UIGestureRecognizer *myPan = self.interactivePopGestureRecognizer;
//    if (gestureRecognizer == myPan) {
//        return YES;
//    }
//    return NO;
//}
////
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    UIGestureRecognizer *myPan = self.interactivePopGestureRecognizer;
//    if (otherGestureRecognizer == myPan) {
//        return YES;
//    }
//    return NO;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.viewControllers count] > 1) {
        NSDictionary *info = @{@"vc":viewController};
        [self.navigationToolbar showBackButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVNavigationPushPopNotification object:nil userInfo:info];
    } else {

    }
}

@end
