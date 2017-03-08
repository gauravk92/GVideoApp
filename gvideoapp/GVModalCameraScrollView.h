//
//  GVModalCameraScrollView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/9/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVMasterViewController.h"


@class GVModalCameraContainerView;

@interface GVModalCameraScrollView : UIScrollView

//@property (nonatomic, weak) GVModalCameraContainerView *parentView;
//@property (nonatomic, weak) CAShapeLayer *layerMask;
@property (nonatomic, weak) UITableView *childTableView;
@property (nonatomic, weak) UIViewController *pushedChildView;
//@property (nonatomic, weak) GVMasterViewController *masterViewController;

@end
