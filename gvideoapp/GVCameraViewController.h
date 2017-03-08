//
//  GfitCameraViewController.h
//  gfitapp
//
//  Created by Gaurav Khanna on 12/21/13.
//  Copyright (c) 2013 Gaurav Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GVCameraView.h"

extern NSString *const GVCameraViewControllerFlashActionNotification;
extern NSString *const GVCameraFlipActionNotification;
extern NSString *const GVCameraLibraryActionNotification;
extern NSString *const GVCameraCancelActionNotification;

@protocol GVCameraMediaPickerControllerProtocol <NSObject>

- (void)willAttemptToSaveVideo;
- (void)videoDidFinishSavingAtPath:(NSString*)videoPath;

@end


@interface GVCameraViewController : UIViewController

- (BOOL)isFrontCameraDevice;

@property (nonatomic, strong) GVCameraView *view;

/**
 *  The internal `AVCaptureSession` object
 */
@property (nonatomic, readonly) AVCaptureSession *captureSession;

@property (nonatomic, assign) BOOL loadsAsync;

@property (nonatomic, weak) id<GVCameraMediaPickerControllerProtocol> cameraMediaPickerDelegate;

@property (nonatomic, assign) BOOL loadsAudioOnStart;
@property (nonatomic, assign, readonly) BOOL recording;

- (void)forceCameraReload;

/**
 *  Starts running the capture session
 */
- (void)startRunningCaptureSession;

/**
 *  Stops running the capture session
 */
- (void)stopRunningCaptureSession;

- (void)cameraViewDidAppearOnscreen;

- (IBAction)startStopButtonPressed:(id)sender;

- (void)startRecordingAction:(UILongPressGestureRecognizer*)gc;

- (void)flashNotification:(NSNotification*)notif;

@end
