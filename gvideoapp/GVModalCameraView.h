//
//  GVModalCameraView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/6/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCameraViewController.h"
#import "GVCameraToolbarLayer.h"
#import "GVProgressView.h"

#import "GVButtonImageView.h"

extern CGFloat const GVModalCameraViewProgressBarHeight;
extern CGFloat const GVModalCameraViewToolbarHeight;

@interface GVModalCameraView : UIView

@property (nonatomic, weak) GVCameraViewController *cameraViewController;

@property (nonatomic, assign) BOOL layoutCameraFullscreen;

//
@property (nonatomic, strong) GVCameraToolbarLayer *toolbar;

@property (nonatomic, strong) UIView *cameraContainerView;

@property (nonatomic, strong) UIView *tapCaptureView;

@property (nonatomic, strong) GVButtonImageView *flipButton;
@property (nonatomic, strong) GVButtonImageView *libraryButton;
@property (nonatomic, strong) GVButtonImageView *flashButton;

- (void)setupCameraViewController:(GVCameraViewController*)cameraVC;

- (void)layoutRasterizationScales;

- (UIView*)flipButtonView;
- (UIView*)libraryButtonView;
- (UIView*)flashButtonView;

- (void)fillProgressBarAnimated:(id)sender;
- (void)finishProgressBarAnimated:(id)sender;

- (void)setupInitialState;


@end
