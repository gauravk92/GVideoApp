//
//  GVCameraOverlayView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/22/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCameraProgressClippedView.h"

@protocol GVCameraOverlayViewDelegateProtocol <NSObject>

- (IBAction)flipCamera:(id)sender;
- (void)cancelAction:(id)sender;
- (void)libraryAction:(id)sender;
- (void)flashAction:(id)sender;

@end

@interface GVCameraOverlayView : UIView

@property (nonatomic, assign) CGRect overlayBounds;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) GVCameraProgressClippedView *clippedProgressView;

@property (nonatomic, strong) UIToolbar *progressToolbar;

@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, strong) UIView *tapCaptureView;

@property (nonatomic, weak) id<GVCameraOverlayViewDelegateProtocol>pickerDelegate;

@end
