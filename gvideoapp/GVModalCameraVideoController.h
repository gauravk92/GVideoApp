//
//  GVModalCameraVideoController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/6/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVModalCameraView.h"
#import "GVModalCameraContainerViewController.h"

extern const CGFloat GVModalCameraDisabledButtonAlpha;

@interface GVModalCameraVideoController : UIViewController

@property (nonatomic, strong) GVModalCameraView *view;


@property (nonatomic, copy) NSString *threadId;

- (void)forceCameraReload;
- (void)willDisplay;
- (void)didEndDisplay;

- (void)forwardCameraTapAction:(UILongPressGestureRecognizer*)gc;
- (void)forwardFlipTapAction:(UILongPressGestureRecognizer*)gc;
- (void)forwardLibraryTapAction:(UILongPressGestureRecognizer*)gc;
- (void)forwardFlashTapAction:(UILongPressGestureRecognizer*)gc;

- (UIView*)tapCaptureView;
- (UIView*)flipButtonView;
- (UIView*)libraryButtonView;
- (UIView*)flashButtonView;

@end
