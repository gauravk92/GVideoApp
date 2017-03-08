//
//  GVModalCameraContainerViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVSplitViewController.h"
#import "GVNavigationViewController.h"
#import "GVMasterViewController.h"
#import "GVProgressView.h"
#import "GVReuseableViewSnapshot.h"


@interface GVModalCameraContainerViewController : UIViewController

+ (UIColor *)classBackgroundColor;

@property (nonatomic, strong) GVSplitViewController *splitViewControllerSetup;
@property (nonatomic, strong) GVMasterViewController *bottomViewControllerSetup;
@property (nonatomic, strong) GVNavigationViewController *bottomViewController;
@property (nonatomic, strong) GVMasterViewController *masterViewController;

- (void)setupBottomViewController:(GVNavigationViewController*)bottomVC;

//@property (nonatomic, strong) GVSplitTableViewController *splitTableViewController;

@end
