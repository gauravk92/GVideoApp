//
//  GfitCameraView.h
//  gfitapp
//
//  Created by Gaurav Khanna on 12/21/13.
//  Copyright (c) 2013 Gaurav Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GVCameraOverlayView.h"

extern const CGFloat kGfitCameraViewFocusAnimationMultiplier;

@interface GVCameraView : UIView

/**
 *  Required to set reference after setting up `AVCaptureSession`
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

/**
 *  Required to call after setting self.previewLayer to finish setup
 */
- (void)didSetPreviewLayer:(CALayer*)previewLayer;

/**
 *  View to receive delegate events
 */
//@property (nonatomic, strong) GVCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) UIView *tapCaptureView;


@property (nonatomic, strong) UILabel *textLabel;

//- (void)resetProgressBarAnimation;
//- (void)setupProgressBarAnimated:(BOOL)animated;
//- (void)startProgressBarAnimation;
//- (void)resetProgressBarAnimation;


- (void)setupInitialState;

- (void)animateInHelpText;
- (void)animateOutHelpText;


@end
