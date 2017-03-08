//
//  GfitCameraViewController.m
//  gfitapp
//
//  Created by Gaurav Khanna on 12/21/13.
//  Copyright (c) 2013 Gaurav Khanna. All rights reserved.
//

#import "GVCameraViewController.h"
#import "GVCameraView.h"
#import "GVCameraOverlayView.h"
#import "GVVideoCameraViewController.h"

NSString *const GVCameraViewControllerFlashActionNotification = @"GVCameraViewControllerFlashActionNotification";
NSString *const GVCameraCancelActionNotification = @"GVCameraCancelActionNotification";
NSString *const GVCameraFlipActionNotification = @"GVCameraFlipActionNotification";
NSString *const GVCameraLibraryActionNotification = @"GVCameraLibraryActionNotification";
NSString *const GVCameraSaveDelegateNotification = @"GVCameraSaveDelegateNotification";

#define CAPTURE_FRAMES_PER_SECOND   30

@interface GVCameraViewController () <AVCaptureFileOutputRecordingDelegate, UIToolbarDelegate, UIGestureRecognizerDelegate>



@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioDeviceInput;
@property (nonatomic, strong) NSBlockOperation *setupBlock;
@property (nonatomic, strong) NSBlockOperation *viewUpdateBlock;

@property (nonatomic, strong) NSOperationQueue *startRecordingCameraQueue;
@property (nonatomic, strong) NSOperationQueue *endRecordingCameraQueue;
@property (nonatomic, strong) UILongPressGestureRecognizer *startGestureRecognizer;
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;
@property (nonatomic, strong) NSTimer *helpTextTimer;



@property (nonatomic, assign) BOOL loading;

//@property (nonatomic, assign) BOOL cameraFlipping;
@property (nonatomic, assign, readwrite) BOOL recording;

//@property (nonatomic, assign) UIDeviceOrientation lastOrientation;

@property (nonatomic, assign) BOOL showingFlash;


@end

@implementation GVCameraViewController

- (void)loadView {
    @autoreleasepool {
        self.view = [[GVCameraView alloc] initWithFrame:CGRectZero];
    }
}

- (CGSize)preferredContentSize {
    return self.view.bounds.size;
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldEdit {
    return YES;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

//- (NSUInteger)supportedInterfaceOrientations {
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
//    }
//    return UIInterfaceOrientationPortrait;
//}

//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAll;
//}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        return UIInter;
//    }
//    return UIInterfaceOrientationMaskPortrait == self.interfaceOrientation;
//}

- (BOOL)loadsAsync {
    return YES;
}

- (void)viewDidLoad {
    @autoreleasepool {
        [super viewDidLoad];



        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        fixedSpace.width = 10;

        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_081_refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(flipAction:)];
        flipButton.title = @"Rear";

        UIBarButtonItem *libraryButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_318_more_items"] style:UIBarButtonItemStylePlain target:self action:@selector(libraryAction:)];
        libraryButton.title = @"Library";
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_192_circle_remove"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];

        UIBarButtonItem *flashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_205_electricity"] style:UIBarButtonItemStylePlain target:self action:@selector(flashAction:)];

        //UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_195_circle_info"] style:UIBarButtonItemStylePlain target:self action:@selector(infoAction:)];


        [self setToolbarItems:@[fixedSpace, flipButton, flexSpace, libraryButton, flexSpace, flashButton, flexSpace, cancelButton, fixedSpace] animated:NO];


        self.navigationController.toolbarHidden = NO;
        self.navigationController.toolbar.barStyle = UIBarStyleBlack;
        //self.navigationController.toolbar.delegate = self;
        

        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.edgesForExtendedLayout = UIRectEdgeTop;
        self.extendedLayoutIncludesOpaqueBars = YES;


        @weakify(self);
        self.setupBlock = [NSBlockOperation blockOperationWithBlock:^{
            @strongify(self);
            [self setup];
        }];
        self.viewUpdateBlock = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                NSParameterAssert(self.view);
                
                //self.view.previewLayer = self.previewLayer;
//                [self.view didSetPreviewLayer:self.previewLayer];
//                [self.view setNeedsLayout];
//                [self.view layoutIfNeeded];
            });
        }];

        if (self.loadsAsync) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @strongify(self);
                if (!self.setupBlock.isExecuting) {
                    [self.setupBlock start];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    if (!self.viewUpdateBlock.isExecuting) {
                        [self.viewUpdateBlock start];
                    }
                });
            });
        } else {
            [self.setupBlock start];
            [self.viewUpdateBlock start];
        }
    }
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTop;
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//
//    
//}

- (void)cameraViewDidAppearOnscreen {
    //[self.view startFocusAnimation];
//    [UIView animateWithDuration:5 delay:0 options:UIViewAnimationOptionRepeat animations:^{
//        
//    } completion:^(BOOL finished) {
//
//    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self startListeningToOrientationChanges];
    }

    //[self.view setupInitialState];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.startRecordingCameraQueue = [[NSOperationQueue alloc] init];
    self.startRecordingCameraQueue.maxConcurrentOperationCount = 1;

    self.endRecordingCameraQueue = [[NSOperationQueue alloc] init];
    self.endRecordingCameraQueue.maxConcurrentOperationCount = 1;

    self.startGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startRecordingAction:)];
    self.startGestureRecognizer.minimumPressDuration = 0.01;
    self.startGestureRecognizer.cancelsTouchesInView = NO;
    self.startGestureRecognizer.delegate = self;

    [self.view.tapCaptureView addGestureRecognizer:self.startGestureRecognizer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flashNotification:) name:GVCameraViewControllerFlashActionNotification object:nil];

    //[[UIApplication sharedApplication] sendAction:@selector(gv_setupProgressBarAnimated) to:nil from:self forEvent:nil];

    //self.cameraOverlayView.pickerDelegate = self;

    //[self.view setupProgressBarAnimated:YES];

    @weakify(self);
    //[self.view setupInitialState];
    

    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        //[self.previewLayer setNeedsLayout];
        //[self.previewLayer layoutIfNeeded];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        //[self startRunningCaptureSession];
        //[self.captureSession startRunning];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.showingFlash) {
        [self turnTorchOn:false];
    }
    self.showingFlash = NO;

    [self.startRecordingCameraQueue cancelAllOperations];
    self.startRecordingCameraQueue = nil;

    [self.endRecordingCameraQueue cancelAllOperations];
    self.endRecordingCameraQueue = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self stopListeningToOrientationChanges];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.view.tapCaptureView removeGestureRecognizer:self.startGestureRecognizer];
    self.startGestureRecognizer = nil;
}

- (BOOL)isFrontCameraDevice {
    return NO;
}

- (AVCaptureDevice *)getFrontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

- (void)setup {

    self.captureSession = [[AVCaptureSession alloc] init];

    self.loading = YES;

    NSParameterAssert(self.captureSession != nil);
    if (self.captureSession == nil) {

        NSLog(@"FATAL ERROR: Could not init a new AVCaptureSession");

        return;
    }

    [self.captureSession beginConfiguration];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(captureSessionError:) name:AVCaptureSessionRuntimeErrorNotification object:self.captureSession];
    [nc addObserver:self selector:@selector(captureSessionEvent:) name:AVCaptureSessionDidStartRunningNotification object:self.captureSession];
    [nc addObserver:self selector:@selector(captureSessionEvent:) name:AVCaptureSessionDidStopRunningNotification object:self.captureSession];
    [nc addObserver:self selector:@selector(captureSessionEvent:) name:AVCaptureSessionWasInterruptedNotification object:self.captureSession];
    [nc addObserver:self selector:@selector(captureSessionEvent:) name:AVCaptureSessionInterruptionEndedNotification object:self.captureSession];


    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {

        self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;

    } else {

        NSLog(@"Error: Could not set AVCaptureSessionPresetMedium on AVCaptureSession:%@", self.captureSession);
    }

    if ([[AVCaptureDevice devices] count] == 0) {
#if FAKE_EXTERNAL_DISPLAY
        NSLog(@"Injecting stock photo instead of camera");
        
        [self.captureSession commitConfiguration];
        return;
#else
        NSLog(@"FATAL ERROR: Could not get any AVCaptureDevices");

        
        return;
#endif
    }

    NSLog(@"Adding audio input");
	AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	NSError * __autoreleasing error = nil;
	self.audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];

    if (audioCaptureDevice == nil || self.audioDeviceInput == nil) {
        NSLog(@"FATAL ERROR: (could not get AVCaptureDeviceInput audio: %@) %@", audioCaptureDevice, error);
    }

    if (!self.loadsAudioOnStart) {
        if ([self.captureSession canAddInput:self.audioDeviceInput]) {
            [self.captureSession addInput:self.audioDeviceInput];
        } else {
            NSLog(@"FATAL ERROR: Cannot add AVCaptureSession audio input: %@", self.audioDeviceInput);
        }
    }

    if ([self isFrontCameraDevice]) {
        self.captureDevice = [self getFrontCamera];
    } else {
        self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }

    NSParameterAssert(self.captureDevice != nil);
    if (self.captureDevice == nil) {

        NSLog(@"FATAL ERROR: Could not get default video AVCaptureDevice");

        return;
    }

    NSError * __autoreleasing deviceInputError;
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:&deviceInputError];

    NSParameterAssert(self.captureDeviceInput != nil);
    if (self.captureDeviceInput == nil) {

        NSLog(@"FATAL ERROR: (could not get AVCaptureDeviceInput from device:%@) %@", self.captureDevice, deviceInputError);

        return;
    }

    if ([self.captureSession canAddInput:self.captureDeviceInput]) {

        [self.captureSession addInput:self.captureDeviceInput];

    } else {

        NSLog(@"FATAL ERROR: Cannot add AVCaptureSession device input: %@", self.captureDeviceInput);

        return;
    }

    //ADD MOVIE FILE OUTPUT
	NSLog(@"Adding movie file output");
	self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];

	Float64 TotalSeconds = VIDEO_MAXIMUM_DURATION;			//Total seconds
	int32_t preferredTimeScale = 30;	//Frames per second
	CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	///<SET MAX DURATION
	self.movieFileOutput.maxRecordedDuration = maxDuration;

	self.movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
    self.movieFileOutput.maxRecordedFileSize = 1024*1024*9.5;

    if ([self.captureSession canAddOutput:self.movieFileOutput]) {
        [self.captureSession addOutput:self.movieFileOutput];
    }

    [self setCameraProperties];

    NSError * __autoreleasing lockConfigError;
    if (![self.captureDevice lockForConfiguration:&lockConfigError]) {

        NSLog(@"Error: (could not lock AVCaptureDevice for config: %@) %@", self.captureDevice, lockConfigError);

    } else {
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        [self.captureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND)];
        [self.captureDevice unlockForConfiguration];

    }

    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];

    NSParameterAssert(self.previewLayer != nil);
    if (self.previewLayer == nil) {

        NSLog(@"FATAL ERROR: Could not init new AVCaptureVideoPreviewLayer with session: %@", self.captureSession);

        return;
    }

    [self.captureSession commitConfiguration];

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        NSParameterAssert(self.view);

        self.loading = NO;

        [self startRunningCaptureSession];

        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

        [self.view didSetPreviewLayer:self.previewLayer];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];

        

        //[self.captureSession startRunning];

    });



}

- (void)setCameraProperties {
    //SET THE CONNECTION PROPERTIES (output properties)
    AVCaptureConnection *captureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];

    //Set landscape (if required)
    if ([captureConnection isVideoOrientationSupported])
    {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;		///<<<SET VIDEO ORIENTATION IF LANDSCAPE
        [captureConnection setVideoOrientation:orientation];
    }

    //Set frame rate (if requried)
//    CMTimeShow(captureConnection.videoMinFrameDuration);
//    CMTimeShow(captureConnection.videoMaxFrameDuration);
//
//    if (captureConnection.supportsVideoMinFrameDuration) {
//        captureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
//    }
//    if (captureConnection.supportsVideoMaxFrameDuration) {
//        captureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
//    }
//    
//    CMTimeShow(captureConnection.videoMinFrameDuration);
//    CMTimeShow(captureConnection.videoMaxFrameDuration);
}

#pragma mark - Session event methods

- (void)forceCameraReload {
    //if (!self.captureSession.running) {
#if !TARGET_OS_SIMULATOR
    @try {
        [self.captureSession stopRunning];
        [self.captureSession startRunning];
    }
    @catch (NSException *exception) {
        DLogException(exception);
    }
    @finally {
        
    }
    
#endif
    //}
}

/**
 *  Starts running the capture session
 */
- (void)startRunningCaptureSession {
//    NSError * __autoreleasing lockConfigError;
//    if (![self.captureDevice lockForConfiguration:&lockConfigError]) {
//
//        NSLog(@"Error: (could not lock AVCaptureDevice for config: %@) %@", self.captureDevice, lockConfigError);
//        @weakify(self);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            @strongify(self);
//            [self startRunningCaptureSession];
//        });
//
//    } else {
//[self.captureSession beginConfiguration];
    BOOL loading = self.loading;
    BOOL running = self.captureSession.running;
    if (!running && !loading) {
#if !TARGET_OS_SIMULATOR
        @try {
            [self.captureSession startRunning];
        }
        @catch (NSException *exception) {
            DLogException(exception);
        }
        @finally {
            
        }
        
#endif
    }
    //  [self.captureSession commitConfiguration];
//        [self.captureDevice unlockForConfiguration];
//    }
}

/**
 *  Stops running the capture session
 */
- (void)stopRunningCaptureSession {
//    NSError * __autoreleasing lockConfigError;
//    if (![self.captureDevice lockForConfiguration:&lockConfigError]) {
//        @weakify(self);
//        NSLog(@"Error: (could not lock AVCaptureDevice for config: %@) %@", self.captureDevice, lockConfigError);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            @strongify(self);
//            [self stopRunningCaptureSession];
//        });
//    } else {
//   [self.captureSession beginConfiguration];
    if (self.captureSession.running && !self.loading) {
#if !TARGET_OS_SIMULATOR
        @try {
            [self.captureSession stopRunning];
        }
        @catch (NSException *exception) {
            DLogException(exception);
        }
        @finally {
            
        }
#endif
    }
    //  [self.captureSession commitConfiguration];
//        [self.captureDevice unlockForConfiguration];
//    }
}

- (void)captureSessionError:(NSNotification*)notif {
    @autoreleasepool {
        NSError * __autoreleasing err = [notif.userInfo objectForKey:AVCaptureSessionErrorKey];

        NSLog(@"FATAL ERROR: (AVCaptureSessionRuntimeError: %@) %@", self.captureSession, err);
    }
}

- (void)captureSessionEvent:(NSNotification*)notif {

    NSLog(@"AVCaptureSessionEvent: %@", notif);
}

#pragma mark - Gesture Recognizer methods 

- (void)startRecordingAction:(UILongPressGestureRecognizer*)gc {
    //    CGPoint tapLocation = [gc locationInView:self.cameraOverlayView];
    //    if ([self.customCameraOverlayView.progressView pointInside:tapLocation withEvent:nil]) {
    //        return;
    //    }
    //    if ([self.customCameraOverlayView.toolbar pointInside:tapLocation withEvent:nil]) {
    //        return;
    //    }
    //return;
    switch (gc.state) {
        case UIGestureRecognizerStatePossible: {
            break;
        }
        case UIGestureRecognizerStateBegan: {
            @weakify(self);
            NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
            @weakify(blockOperation);
            [blockOperation addExecutionBlock:^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @strongify(self);
                    [TestFlight passCheckpoint:@"Video Capture Action"];
                    //BOOL started = [self startVideoCapture];
                    //NSLog("video capture started: %@", [NSNumber numberWithBool:started]);

                    //UIEvent *event = [[UIEvent alloc] init];
                    if ([blockOperation_weak_ isCancelled]) {
                        return;
                    }


                    [self startStopButtonPressed:nil];

                    //BOOL handled = [[UIApplication sharedApplication] sendAction:@selector(gv_fillProgressBarAnimation:forEvent:) to:nil from:self forEvent:event];
                    //[self.view startProgressBarAnimation];
                    //NSLog(@"event handled %i", handled);
                });
            }];
            [self.startRecordingCameraQueue addOperations:@[blockOperation] waitUntilFinished:YES];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            NSLog(@" gesture recognizer stopped");
            NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
            @weakify(blockOperation);
            //@weakify(self);
            [blockOperation addExecutionBlock:^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //@strongify(self);
                    if ([blockOperation_weak_ isCancelled]){
                        return ;
                    }

                    //[[NSNotificationCenter defaultCenter] postNotificationName:GVVideoCameraViewControllerFinishProgressBarAnimation object:nil];

                    //[self stopVideoCapture];
                    //                    self.showsCameraControls = YES;
                    //                    self.allowsEditing = YES;
                    //                    self.customCameraOverlayView = nil;
                    //                    self.customCameraOverlayView.pickerDelegate = nil;
                    //                    self.cameraOverlayView = nil;
                    //                    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    //                        [self.customCameraOverlayView.progressView setProgress:1 animated:YES];
                    //                    } completion:^(BOOL finished) {
                    //
                    //                    }];
                });
            }];
            [self.startRecordingCameraQueue addOperations:@[blockOperation] waitUntilFinished:YES];
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            break;
        }
        case UIGestureRecognizerStateFailed: {
            break;
        }
        default: {
            break;
        }
    }
}


#pragma mark - Delegate methods 

- (void)notifyDelegateOfVideoConfirmation:(NSString*)videoPath {
    if (self.cameraMediaPickerDelegate && [self.cameraMediaPickerDelegate respondsToSelector:@selector(videoDidFinishSavingAtPath:)]) {
        [self.cameraMediaPickerDelegate videoDidFinishSavingAtPath:videoPath];
    }
}

#pragma mark - Action methods 

//- (IBAction)flipCamera:(id)sender {
//    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
//    @weakify(blockOperation);
//    [blockOperation addExecutionBlock:^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:GVVideoCameraViewControllerFlipCameraDeviceAnimation object:nil];
//    }];
//    [self.startRecordingCameraQueue addOperations:@[blockOperation] waitUntilFinished:YES];
//}

//- (void)cancelAction:(id)sender {
//    [self imagePickerControllerDidCancel:nil];
//}

- (void) turnTorchOn: (bool) on {

    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){

            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                self.showingFlash = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                self.showingFlash = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

- (void)flipAction:(id)sender {
    if (!self.recording) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GVCameraFlipActionNotification object:nil];
    }
}

- (void)libraryAction:(id)sender {
    if (!self.recording) {
        NSDictionary *info = @{@"sender": sender};
        [[NSNotificationCenter defaultCenter] postNotificationName:GVCameraLibraryActionNotification object:nil userInfo:info];
    }
}

- (void)cancelAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:GVCameraCancelActionNotification object:nil];
}

- (void)flashAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:GVCameraViewControllerFlashActionNotification object:nil];
}

- (void)flashNotification:(NSNotification*)notif {
    if (![self isFrontCameraDevice]) {
        [self turnTorchOn:!self.showingFlash];
    }
}

- (void)writeVideoToCameraRoll:(NSURL*)outputFileURL {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                    completionBlock:^(NSURL *assetURL, NSError *error) {
                                        if (error) {

                                        }
                                    }];
    }

}

//********** DID FINISH RECORDING TO OUTPUT FILE AT URL **********
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
	  fromConnections:(NSArray *)connections
				error:(NSError *)error
{

	NSLog(@"didFinishRecordingToOutputFileAtURL - enter");
    [self finishedRecordingAction];
    
    
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id successFinish = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        BOOL maxFinish = ([error code] == AVErrorMaximumDurationReached);
        BOOL maxFileFinish = ([error code] == AVErrorMaximumFileSizeReached);
        if (successFinish) {
            RecordedSuccessfully = [successFinish boolValue];
        }
        if (maxFinish || maxFileFinish) {
            RecordedSuccessfully = YES;
        }
        NSLog(@"recording error: %@", error);
    }

	if (RecordedSuccessfully) {
		//----- RECORDED SUCESSFULLY -----
        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
        NSDictionary *movieInfo = @{@"movieURL": outputFileURL };
        [[NSNotificationCenter defaultCenter] postNotificationName:GVVideoCameraViewControllerFinishSavingVideo object:self userInfo:movieInfo];
	}
}

//********** START STOP RECORDING BUTTON **********
- (IBAction)startStopButtonPressed:(id)sender {
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (!self.recording) {
        //----- START RECORDING -----
        NSLog(@"START RECORDING");
        self.recording = YES;

        //Create temporary URL to record to
        [self saveToTemporaryDirectory];
        //[self.view animateOutHelpText];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVVideoCameraViewControllerFillProgressBarAnimation object:self];
    } else {
        //----- STOP RECORDING -----
        NSLog(@"STOP RECORDING");
        [self stopRecordingMovieOutput];

    }
    //});
}

- (void)finishedRecordingAction {
    self.recording = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:GVVideoCameraViewControllerFinishProgressBarAnimation object:self];
}

- (void)stopRecordingMovieOutput {
    [self.movieFileOutput stopRecording];

    if (self.loadsAudioOnStart) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.audioDeviceInput];
        [self.captureSession commitConfiguration];
    }

}

- (void)saveToDocumentsDirectory {
    NSString *DestFilename = @ "output.mov";

	//Set the file save to URL
	NSLog(@"Starting recording to file: %@", DestFilename);
	NSString *DestPath;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Drafts"];

    NSError *__autoreleasing error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:DestPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DestPath withIntermediateDirectories:NO attributes:nil error:&error];
    }

    //DestPath = [paths objectAtIndex:0];
	DestPath = [DestPath stringByAppendingPathComponent:DestFilename];

    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:DestPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:DestPath]) {
        NSError *__autoreleasing error;
        if ([fileManager removeItemAtPath:DestPath error:&error] == NO) {
            //Error - handle if requried
            NSLog(@"file was removed successfully");
        }
    }
    if (self.navigationController) {
        [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self.navigationController];
    } else {
        [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
        //[[NSNotificationCenter defaultCenter] postNotificationName:GVCameraSaveDelegateNotification object:nil];
    }
}

- (void)saveToTemporaryDirectory {
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        NSError *__autoreleasing error;
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
            //Error - handle if requried
        }
    }

    //ADD AUDIO INPUT

    if (self.loadsAudioOnStart) {
        [self.captureSession beginConfiguration];
        if ([self.captureSession canAddInput:self.audioDeviceInput]) {
            [self.captureSession addInput:self.audioDeviceInput];
        } else {
            NSLog(@"FATAL ERROR: Cannot add AVCaptureSession audio input: %@", self.audioDeviceInput);
        }
        [self.captureSession commitConfiguration];
    }

    //Start recording
    [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

#pragma mark - Image Picker delegate methods

/**
 *  If it was selected from the library, they already had a chance to trim
 *  and we probably don't need to save it as a new one...the raw is in the library
 */

- (NSString*)moviePathForMediaType:(NSDictionary*)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    CFStringRef cMediaType = (__bridge CFStringRef) mediaType;
    if (CFStringCompare (cMediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        NSURL *url = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
        if (url) {
            return [url path];
        }
        return nil;
    }
    return nil;
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        //        if ([self.threadMediaPickerDelegate respondsToSelector:@selector(willAttemptToSaveVideo)]) {
        //            [self.threadMediaPickerDelegate performSelector:@selector(willAttemptToSaveVideo)];
        //        }
        NSString *moviePath = [self moviePathForMediaType:info];
        [picker dismissViewControllerAnimated:YES completion:^{
            @strongify(self);

            void (^completionBlock)() = ^{
                [TestFlight passCheckpoint:@"Pick Action"];
                @strongify(self);
                
                [self notifyDelegateOfVideoConfirmation:moviePath];

            };

            if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                [self dismissViewControllerAnimated:YES completion:completionBlock];
            } else {
                completionBlock();
            }
        }];
    });
}

#pragma mark - Orientation changes 

- (void)startListeningToOrientationChanges {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)stopListeningToOrientationChanges {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    switch (orientation) {
        case UIDeviceOrientationUnknown:

            break;
        case UIDeviceOrientationPortrait: {
            if (self.lastOrientation != UIInterfaceOrientationPortrait) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationPortrait;
                //CGRect bounds = [UIScreen mainScreen].bounds;
                //self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
                //self.cameraOverlayView.bounds = bounds;
                //[self.cameraOverlayView setNeedsLayout];
                //[self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.cameraOverlayView.frame = self.cameraOverlayView.bounds;
            }
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            if (self.lastOrientation != UIInterfaceOrientationPortraitUpsideDown) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationPortraitUpsideDown;
                //CGRect bounds = [UIScreen mainScreen].bounds;
                //self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
                //self.cameraOverlayView.bounds = bounds;
                //[self.cameraOverlayView setNeedsLayout];
                //[self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
                //self.cameraOverlayView.frame = self.cameraOverlayView.bounds;
            }
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            if (self.lastOrientation != UIInterfaceOrientationLandscapeLeft) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationLandscapeLeft;
                //CGRect bounds = [UIScreen mainScreen].bounds;
                //self.cameraOverlayView.bounds = bounds;
                //self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
                //[self.cameraOverlayView setNeedsLayout];
                //[self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.cameraOverlayView.frame = CGRectMake(0, 0, self.cameraOverlayView.bounds.size.height, self.cameraOverlayView.bounds.size.width);
            }
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            if (self.lastOrientation != UIInterfaceOrientationLandscapeRight) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationLandscapeRight;
                //CGRect bounds = [UIScreen mainScreen].bounds;
                //self.cameraOverlayView.bounds = bounds;
                //self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
                //[self.cameraOverlayView setNeedsLayout];
                //[self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.cameraOverlayView.frame = CGRectMake(0, 0, self.cameraOverlayView.bounds.size.height, self.cameraOverlayView.bounds.size.width);
            }
            break;
        }
        case UIDeviceOrientationFaceUp:

            break;
        case UIDeviceOrientationFaceDown:

            break;
        default:
            break;
    }
}

#pragma mark - Delegate methods

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex == 0){
//        //Code for Done button
//        // TODO: Create a finished view
//    }
//    if (buttonIndex == 1){
//        //Code for Scan more button
//        [self.captureSession startRunning];
//    }
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
