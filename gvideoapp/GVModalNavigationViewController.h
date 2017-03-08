//
//  GVModalNavigationViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TESTING_WITHOUT_CAMERA 0

@interface GVModalNavigationViewController : UITabBarController

@property (nonatomic, strong, readonly) UINavigationBar *navigationBar;
@property (nonatomic, assign, readwrite) UIStatusBarStyle transitioningStatusBarStyle;
@property (nonatomic, assign, readwrite, getter = isTransitioningStatusBarStyle) BOOL transitionStatusBarStyle;

- (void)popToRootViewControllerAnimated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated;

- (void)hackTheNavigationBar;

@end
