//
//  GVThreadMediaPickerOverlayView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/8/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GVThreadMediaPickerOverlayViewProtocol <NSObject>

- (void)chooseExistingButton:(id)sender;
- (void)chooseCaptureButton:(id)sender;
- (void)chooseRetakeButton:(id)sender;

@end

@interface GVThreadMediaPickerOverlayView : UIView

@property (nonatomic, weak) id<GVThreadMediaPickerOverlayViewProtocol> chooseExistingDelegate;

- (BOOL)libraryButtonHidden;

//- (void)animateOrientationChange;
- (void)hideLibraryButton;
- (void)showLibraryButton;
- (void)showRetakeButton;
- (void)hideRetakeButton;

@end
