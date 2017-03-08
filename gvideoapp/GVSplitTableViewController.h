//
//  GVSplitTableViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/6/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GVSplitTableViewControllerScrollDelegate <NSObject>

- (void)goToFullscreen;
- (void)endFullscreen;
- (void)willDisplay;
- (void)didEndDisplay;
- (void)tellContentOffset:(CGPoint)contentOffset;
- (void)endedDragging;

@end

@interface GVSplitTableViewController : UITableViewController

@property (nonatomic, weak) id<GVSplitTableViewControllerScrollDelegate> splitScrollDelegate;

@property (nonatomic, strong) UIViewController *bottomViewController;

- (void)pullUp;

@end
