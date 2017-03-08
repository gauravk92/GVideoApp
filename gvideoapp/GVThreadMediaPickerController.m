//
//  GVThreadMediaPickerController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVThreadMediaPickerController.h"
#import "GVThreadMediaPickerOverlayView.h"
#import "GVSettingsUtility.h"
#import "GVLibraryMediaPickerController.h"

@interface GVThreadMediaPickerController () <GVThreadMediaPickerOverlayViewProtocol>

@property (nonatomic, strong) NSOperationQueue *swipeOperationQueue;
@property (nonatomic, strong) NSOperationQueue *cameraOverlayCaptureQueue;
@property (nonatomic, strong) NSOperationQueue *cameraStopCaptureQueue;
@property (nonatomic, strong) GVThreadMediaPickerOverlayView *cameraNavigationOverlayView;
//@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;

@end

@implementation GVThreadMediaPickerController

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static GVThreadMediaPickerController *shared = nil;
    dispatch_once(&pred, ^{
        @autoreleasepool {
            shared = [[GVThreadMediaPickerController alloc] init];
            shared
        }
    });
    return shared;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.cameraNavigationOverlayView setNeedsLayout];
    [self.cameraNavigationOverlayView layoutIfNeeded];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.swipeGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    [self.view addGestureRecognizer:self.swipeGestureRecognizer];

    self.swipeOperationQueue = [[NSOperationQueue alloc] init];
    self.swipeOperationQueue.maxConcurrentOperationCount = 1;

    self.cameraOverlayCaptureQueue = [[NSOperationQueue alloc] init];
    self.cameraOverlayCaptureQueue.maxConcurrentOperationCount = 1;

    self.cameraStopCaptureQueue = [[NSOperationQueue alloc] init];
    self.cameraStopCaptureQueue.maxConcurrentOperationCount = 1;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    });

    //[self startListeningToOrientationChanges];

    self.cameraNavigationOverlayView.chooseExistingDelegate = self;
}

//- (void)startListeningToOrientationChanges {
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
//}
//
//- (void)stopListeningToOrientationChanges {
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)handleSwipeGesture:(UIPanGestureRecognizer*)gc {
    self.animateVelocity = [gc velocityInView:gc.view];
    //NSLog(@" velocity y direction %@", [NSNumber numberWithFloat:self.animateVelocity.y]);
    if (self.animateVelocity.y > 500 && gc.state == UIGestureRecognizerStateChanged) {
        NSBlockOperation *cancelOperation = [[NSBlockOperation alloc] init];
        @weakify(self);
        @weakify(cancelOperation);
        [cancelOperation addExecutionBlock:^{
            @strongify(self);
            if ([cancelOperation_weak_ isCancelled]) {
                return;
            }

            [self.swipeOperationQueue cancelAllOperations];
            self.swipeOperationQueue = nil;

            [self imagePickerControllerDidCancel:nil];

        }];
        [self.swipeOperationQueue addOperations:@[cancelOperation_weak_] waitUntilFinished:YES];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view removeGestureRecognizer:self.swipeGestureRecognizer];
    self.swipeGestureRecognizer = nil;

    [self.swipeOperationQueue cancelAllOperations];
    self.swipeOperationQueue = nil;

    [self.cameraStopCaptureQueue cancelAllOperations];
    self.cameraStopCaptureQueue = nil;

    [self.cameraOverlayCaptureQueue cancelAllOperations];
    self.cameraOverlayCaptureQueue = nil;

    self.cameraOverlayView = nil;
    self.cameraNavigationOverlayView = nil;
    self.cameraNavigationOverlayView.chooseExistingDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Image Picker delegate methods

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self_weak_ dismissViewControllerAnimated:YES completion:nil];
    });
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if ([self.threadMediaPickerDelegate respondsToSelector:@selector(willAttemptToSaveVideo)]) {
            [self.threadMediaPickerDelegate performSelector:@selector(willAttemptToSaveVideo)];
        }

        [picker dismissViewControllerAnimated:YES completion:^{
            void (^completionBlock)() = ^{
                @strongify(self);
                // Handle a movie capture
                if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0)
                    == kCFCompareEqualTo) {
                    NSURL *url = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
                    if (url) {
                        NSString *moviePath = [url path];
                        if ([GVSettingsUtility shouldSaveNewCaptures]) {
                            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
                                UISaveVideoAtPathToSavedPhotosAlbum (moviePath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                            }
                        } else {
                            if (self.threadMediaPickerDelegate && [self.threadMediaPickerDelegate respondsToSelector:@selector(video:didFinishSavingWithError:contextInfo:)]) {
                                [self.threadMediaPickerDelegate video:[url path] didFinishSavingWithError:nil contextInfo:nil];
                            }
                        }
                    }
                }
            };

            if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                [self dismissViewControllerAnimated:YES completion:completionBlock];
            } else {
                completionBlock();
            }
        }];
    });
}


//- (void)orientationChanged:(NSNotification *)notification {
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//
//    switch (orientation) {
//        case UIDeviceOrientationUnknown:
//
//            break;
//        case UIDeviceOrientationPortrait:
//            if (self.lastOrientation != UIInterfaceOrientationPortrait) {
//                //[self.cameraNavigationOverlayView animateOrientationChange];
//                self.lastOrientation = UIInterfaceOrientationPortrait;
//            }
//            break;
//        case UIDeviceOrientationPortraitUpsideDown:
//            if (self.lastOrientation != UIInterfaceOrientationPortraitUpsideDown) {
//                //[self.cameraNavigationOverlayView animateOrientationChange];
//                self.lastOrientation = UIInterfaceOrientationPortraitUpsideDown;
//            }
//            break;
//        case UIDeviceOrientationLandscapeLeft:
//            if (self.lastOrientation != UIInterfaceOrientationLandscapeLeft) {
//                //[self.cameraNavigationOverlayView animateOrientationChange];
//                self.lastOrientation = UIInterfaceOrientationLandscapeLeft;
//            }
//            break;
//        case UIDeviceOrientationLandscapeRight:
//            if (self.lastOrientation != UIInterfaceOrientationLandscapeRight) {
//                //[self.cameraNavigationOverlayView animateOrientationChange];
//                self.lastOrientation = UIInterfaceOrientationLandscapeRight;
//            }
//            break;
//        case UIDeviceOrientationFaceUp:
//
//            break;
//        case UIDeviceOrientationFaceDown:
//
//            break;
//        default:
//            break;
//    }
//}

- (void)chooseRetakeButton:(id)sender {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.cameraOverlayCaptureQueue = [[NSOperationQueue alloc] init];
        self.cameraOverlayCaptureQueue.maxConcurrentOperationCount = 1;

        [self.cameraNavigationOverlayView showLibraryButton];
        self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
    });
}

- (void)chooseCaptureButton:(id)sender {
    if ([self.cameraNavigationOverlayView libraryButtonHidden]) {
        NSBlockOperation *captureStopOperation = [[NSBlockOperation alloc] init];
        @weakify(self);
        @weakify(captureStopOperation);
        [captureStopOperation addExecutionBlock:^{

            if ([captureStopOperation_weak_ isCancelled]) {
                return;
            }

            @strongify(self);

            [self.cameraStopCaptureQueue cancelAllOperations];
            self.cameraStopCaptureQueue = nil;

            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.cameraNavigationOverlayView showRetakeButton];
                [self stopVideoCapture];
            });

            //[self stopListeningToOrientationChanges];

        }];
        [self.cameraStopCaptureQueue addOperations:@[captureStopOperation_weak_] waitUntilFinished:YES];
    } else {
        NSBlockOperation *captureBlockOperation = [[NSBlockOperation alloc] init];
        @weakify(self);
        @weakify(captureBlockOperation);
        [captureBlockOperation addExecutionBlock:^{
            if ([captureBlockOperation_weak_ isCancelled]) {
                return;
            }

            @strongify(self);

            [self.cameraOverlayCaptureQueue cancelAllOperations];
            self.cameraOverlayCaptureQueue = nil;

            self.cameraStopCaptureQueue = [[NSOperationQueue alloc] init];
            self.cameraStopCaptureQueue.maxConcurrentOperationCount = 1;

            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.cameraNavigationOverlayView hideLibraryButton];
                [self startVideoCapture];
            });

            //[self startListeningToOrientationChanges];
        }];
        [self.cameraOverlayCaptureQueue addOperations:@[captureBlockOperation_weak_] waitUntilFinished:YES];
    }
}

- (void)navigationController:(UINavigationController *)navigationController  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

    NSLog(@"nav Controller will show view controller: %@", viewController);

    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (!self.cameraNavigationOverlayView) {
            self.cameraNavigationOverlayView = [[GVThreadMediaPickerOverlayView alloc] initWithFrame:self.view.bounds];
        }
        self.cameraOverlayView = self.cameraNavigationOverlayView;
        self.cameraNavigationOverlayView.chooseExistingDelegate = self;
    }

}

- (void)chooseExistingButton:(id)sender {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        GVLibraryMediaPickerController *libraryPickerController;
        libraryPickerController = [GVLibraryMediaPickerController sharedInstance];
        libraryPickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
        libraryPickerController.videoMaximumDuration = 30;
        libraryPickerController.videoQuality = UIImagePickerControllerQualityTypeLow;


        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        libraryPickerController.allowsEditing = YES;
        libraryPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        libraryPickerController.delegate = self;


//        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self.libraryPickerController action:@selector(dismissButton:)];
//        @weakify(button)
//        libraryPickerController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button_weak_];

        [self presentViewController:libraryPickerController animated:YES completion:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        });
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
