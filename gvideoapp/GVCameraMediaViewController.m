//
//  GVCameraMediaViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/22/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCameraMediaViewController.h"
#import "GVSettingsUtility.h"
#import "GVLibraryMediaPickerController.h"
#import "GVCameraOverlayView.h"

@interface GVCameraMediaViewController () <GVCameraOverlayViewDelegateProtocol, UIPopoverControllerDelegate>

@property (nonatomic, strong) GVCameraOverlayView *customCameraOverlayView;

@property (nonatomic, strong) NSOperationQueue *startRecordingCameraQueue;
@property (nonatomic, strong) NSOperationQueue *endRecordingCameraQueue;
@property (nonatomic, strong) UILongPressGestureRecognizer *startGestureRecognizer;

@property (nonatomic, assign) BOOL cameraFlipping;

@property (nonatomic, assign) UIDeviceOrientation lastOrientation;

@property (nonatomic, strong) UIPopoverController *libraryPopoverController;
@property (nonatomic, strong) UIPopoverController *videoEditorPopoverController;
@property (nonatomic, weak) UIVideoEditorController *videoEditorController;

@property (nonatomic, assign) BOOL showingFlash;

@end

@implementation GVCameraMediaViewController

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static GVCameraMediaViewController *shared = nil;
    dispatch_once(&pred, ^{
        @autoreleasepool {
            shared = [[GVCameraMediaViewController alloc] init];
        }
    });
    return shared;
}

- (void)setupCameraOverlayView {
    if (!self.customCameraOverlayView) {
        self.customCameraOverlayView = [[GVCameraOverlayView alloc] initWithFrame:self.view.bounds];
        self.customCameraOverlayView.pickerDelegate = self;
    }
    self.cameraOverlayView = self.customCameraOverlayView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);

        self.cameraFlipping = NO;
        self.showingFlash = NO;

        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;


        [self setupCameraOverlayView];
//        GVCameraOverlayView *cameraOverlayView = [[GVCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        cameraOverlayView.pickerDelegate = self;
//        self.cameraOverlayView = cameraOverlayView;
//        self.customCameraOverlayView = cameraOverlayView;
        //self.cameraOverlayView.frame = ;

        // Displays a control that allows the user to choose movie capture
        self.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];

        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        self.videoMaximumDuration = VIDEO_MAXIMUM_DURATION;


        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        self.allowsEditing = NO;
        self.showsCameraControls = NO;

        //[self.cameraOverlayView setNeedsLayout];
        //[self.cameraOverlayView layoutIfNeeded];

//        CAGradientLayer *l = [CAGradientLayer layer];
//        l.frame = self.customCameraOverlayView.progressView.frame;
//        l.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
//        l.startPoint = CGPointMake(0.0f, -0.5f);
//        l.endPoint = CGPointMake(0.0, 0.6f);
        //self.collectionView.layer.mask = l;
        //self.customCameraOverlayView.progressView.layer.mask = l;
    });

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self startListeningToOrientationChanges];
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

    NSLog(@"nav Controller will show view controller: %@", viewController);

    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //UIImagePickerController *pickerVC = (UIImagePickerController*)viewController;
        //if ([pickerVC sourceType] == UIImagePickerControllerSourceTypeCamera) {
        [self setupCameraOverlayView];
        self.customCameraOverlayView.toolbar.userInteractionEnabled = YES;
        //}
        //self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        //self.lastOrientation = UIDeviceOrientationUnknown;
        //[self orientationChanged:nil];

//        if (!self.cameraNavigationOverlayView) {
//            self.cameraNavigationOverlayView = [[GVCameraOverlayView alloc] initWithFrame:self.view.bounds];
//        }
//        self.cameraOverlayView = self.cameraNavigationOverlayView;
//        self.cameraNavigationOverlayView.chooseExistingDelegate = self;
    }
    if ([navigationController isEqual:self.videoEditorController]) {
        //self.customCameraOverlayView.toolbar.userInteractionEnabled = NO;
        //navigationController.navigationItem.rightBarButtonItem.title = @"Send";
        UINavigationBar *navBar = [navigationController navigationBar];
        NSArray *items = [navBar items];
        if ([items count] > 0) {
            UINavigationItem *item = [items objectAtIndex:0];
            if (item) {
                NSArray *rightItems = [item rightBarButtonItems];
                if ([rightItems count] > 0) {
                    UIBarButtonItem *buttonItem = [rightItems objectAtIndex:0];
                    if (buttonItem) {
                        UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:[buttonItem target] action:[buttonItem action]];
                        //[buttonItem setTitle:@"Send"];
                        [item setRightBarButtonItems:@[sendButton] animated:NO];
                    }
                }
            }
        }
    }
    
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if ([viewController respondsToSelector:@selector(sourceType)]) {
//        UIImagePickerController *pickerVC = (UIImagePickerController*)viewController;
//        if ([pickerVC sourceType] == UIImagePickerControllerSourceTypeCamera) {
        if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
            self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        }
    //        }
//}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.startRecordingCameraQueue = [[NSOperationQueue alloc] init];
    self.startRecordingCameraQueue.maxConcurrentOperationCount = 1;

    self.endRecordingCameraQueue = [[NSOperationQueue alloc] init];
    self.endRecordingCameraQueue.maxConcurrentOperationCount = 1;

    self.startGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startRecordingAction:)];
    self.startGestureRecognizer.minimumPressDuration = 0.01;
    //self.startGestureRecognizer.minimumNumberOfTouches = 1;
    //self.startGestureRecognizer.maximumNumberOfTouches = 1;

    //[self.cameraOverlayView setNeedsLayout];
    //[self.cameraOverlayView layoutIfNeeded];

    //self.customCameraOverlayView.toolbar.center =

    [self.customCameraOverlayView.tapCaptureView addGestureRecognizer:self.startGestureRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.showingFlash) {
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }
    self.showingFlash = NO;

    [self.startRecordingCameraQueue cancelAllOperations];
    self.startRecordingCameraQueue = nil;

    [self.endRecordingCameraQueue cancelAllOperations];
    self.endRecordingCameraQueue = nil;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self stopListeningToOrientationChanges];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.customCameraOverlayView.tapCaptureView removeGestureRecognizer:self.startGestureRecognizer];
    self.startGestureRecognizer = nil;

    self.cameraOverlayView = nil;
    self.customCameraOverlayView = nil;
    self.customCameraOverlayView.pickerDelegate = nil;
}


- (void)flashAction:(id)sender {
//    self.cameraFlashMode = (self.cameraFlashMode == UIImagePickerControllerCameraFlashModeOn) ? UIImagePickerControllerCameraFlashModeOff : UIImagePickerControllerCameraFlashModeOn;
    if (self.showingFlash) {
        self.showingFlash = NO;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    } else {
        self.showingFlash = YES;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        
    }
}


- (void)libraryAction:(id)sender {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{

        [TestFlight passCheckpoint:@"Library Action"];

        @strongify(self);
        GVLibraryMediaPickerController *libraryPickerController;
        libraryPickerController = [GVLibraryMediaPickerController sharedInstance];
        libraryPickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
        libraryPickerController.videoMaximumDuration = VIDEO_MAXIMUM_DURATION;
        libraryPickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;


        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        libraryPickerController.allowsEditing = YES;
        libraryPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        libraryPickerController.delegate = self;






        //        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self.libraryPickerController action:@selector(dismissButton:)];
        //        @weakify(button)
        //        libraryPickerController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button_weak_];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

            UIPopoverController *popver = [[UIPopoverController alloc] initWithContentViewController:libraryPickerController];

            self.libraryPopoverController = popver;
            self.libraryPopoverController.delegate = self;
            [popver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            [self presentViewController:libraryPickerController animated:YES completion:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        });
    });
}

- (IBAction)flipCamera:(id)sender {

    if (!_cameraFlipping)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _cameraFlipping = YES;
            [self switchCameraDevice];
            //[self performSelectorInBackground:@selector(switchCameraDevice) withObject:nil];
            [self performSelector:@selector(flipAnimation) withObject:nil afterDelay:0.4f];
        });
    }
}

-(void)flipAnimation
{
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft animations:^{

        self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, 1, 1);

    } completion:^(BOOL finished) {
        if (finished) {
            _cameraFlipping = NO;
        }
    }];

}

-(void)switchCameraDevice
{
    if(self.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else
    {
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

- (void)finishProgressBarAnimation {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        CGRect progressToolbarFrame = self.customCameraOverlayView.progressToolbar.frame;
        CGRect beforeFrame = CGRectMake(0, 0, progressToolbarFrame.size.width, progressToolbarFrame.size.height);
        //CGRect startFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
        //CGRect midFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
        //startFrame.origin.x += 100;
        beforeFrame.origin.x += beforeFrame.size.width;
        //midFrame.origin.x += 300;
        [self.customCameraOverlayView.clippedProgressView.layer removeAllAnimations];
        [UIView animateWithDuration:1.0
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             @strongify(self);
                             self.customCameraOverlayView.clippedProgressView.frame = beforeFrame;
                         } completion:nil];
    });
}

- (void)resetProgressBarAnimation {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        CGRect progressToolbarFrame = self.customCameraOverlayView.progressToolbar.frame;
        CGRect beforeFrame = CGRectMake(0, 0, progressToolbarFrame.size.width, progressToolbarFrame.size.height);
        //self.customCameraOverlayView.clippedProgressView.frame = beforeFrame;
        //CGRect startFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
        //CGRect midFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
        //startFrame.origin.x += 100;
        //beforeFrame.origin.x += beforeFrame.size.width;
        //midFrame.origin.x += 300;
        [self.customCameraOverlayView.clippedProgressView.layer removeAllAnimations];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             @strongify(self);
                             self.customCameraOverlayView.clippedProgressView.frame = beforeFrame;
                         } completion:nil];
    });
}

- (void)startProgressBarAnimation {
    @weakify(self);
    CGRect beforeFrame = self.customCameraOverlayView.clippedProgressView.frame;
    CGRect startFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
    CGRect midFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
    startFrame.origin.x += 100;
    beforeFrame.origin.x += beforeFrame.size.width;
    midFrame.origin.x += 300;
    //[self.customCameraOverlayView.progressView setProgress:1.0f animated:YES];
    [self.customCameraOverlayView.clippedProgressView.layer removeAllAnimations];
    [UIView animateKeyframesWithDuration:VIDEO_MAXIMUM_DURATION delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction | UIViewKeyframeAnimationOptionBeginFromCurrentState | UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.006 animations:^{
            @strongify(self);
            self.customCameraOverlayView.clippedProgressView.frame = startFrame;
        }];
        //                        [UIView addKeyframeWithRelativeStartTime:0.006 relativeDuration:0.3 animations:^{
        //                            @strongify(self);
        //                            self.customCameraOverlayView.clippedProgressView.frame = midFrame;
        //                        }];
        [UIView addKeyframeWithRelativeStartTime:0.006 relativeDuration:0.9 animations:^{
            @strongify(self);
            self.customCameraOverlayView.clippedProgressView.frame = beforeFrame;
        }];
    } completion:^(BOOL finished) {
        if (finished) {

        }
    }];
}



- (void)startRecordingAction:(UIPanGestureRecognizer*)gc {
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
            [blockOperation addExecutionBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [TestFlight passCheckpoint:@"Video Capture Action"];
                    BOOL started = [self startVideoCapture];
                    NSLog("video capture started: %@", [NSNumber numberWithBool:started]);

                    [self startProgressBarAnimation];
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
            @weakify(self);
            [blockOperation addExecutionBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    if ([blockOperation_weak_ isCancelled]){
                        return ;
                    }

                    [self stopVideoCapture];
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



// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [TestFlight passCheckpoint:@"Picker Cancel Action"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            if (self.libraryPopoverController) {
                [self.libraryPopoverController dismissPopoverAnimated:YES];
                self.libraryPopoverController = nil;
            }
            if (self.videoEditorPopoverController) {
                [self.videoEditorPopoverController dismissPopoverAnimated:YES];
                self.videoEditorPopoverController = nil;
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)cancelAction:(id)sender {
    [self imagePickerControllerDidCancel:nil];
}

- (void)saveMovieToCameraRoll:(NSString*)moviePath {
    if ([GVSettingsUtility shouldSaveNewCaptures]) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (NSString*)moviePathForMediaType:(NSDictionary*)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        NSURL *url = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
        if (url) {
            return [url path];
        }
        return nil;
    }
    return nil;
}

/**
 *  If it was selected from the library, they already had a chance to trim
 *  and we probably don't need to save it as a new one...the raw is in the library
 */

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
//        if ([self.threadMediaPickerDelegate respondsToSelector:@selector(willAttemptToSaveVideo)]) {
//            [self.threadMediaPickerDelegate performSelector:@selector(willAttemptToSaveVideo)];
//        }
        NSString *moviePath = [self moviePathForMediaType:info];
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {

            NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
            @weakify(blockOperation);
            [blockOperation addExecutionBlock:^{

                if ([blockOperation_weak_ isCancelled]) {
                    return;
                }

                // we need to let them edit it
                /**
                 *  Here we need to start a video editor to let them trim and play/confirm/cancel
                 */
                if ([UIVideoEditorController canEditVideoAtPath:moviePath]) {
                    UIVideoEditorController *videoEditor = [[UIVideoEditorController alloc] init];
                    videoEditor.videoPath = moviePath;
                    videoEditor.videoMaximumDuration = VIDEO_MAXIMUM_DURATION;
                    videoEditor.videoQuality = UIImagePickerControllerQualityTypeMedium;
                    videoEditor.delegate = self;
                    [self finishProgressBarAnimation];
                    self.videoEditorController = videoEditor;

                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                        self.videoEditorPopoverController = [[UIPopoverController alloc] initWithContentViewController:videoEditor];
                        self.videoEditorPopoverController.delegate = self;
                        [self.videoEditorPopoverController presentPopoverFromRect:[UIScreen mainScreen].bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                    } else {
                        [self presentViewController:videoEditor animated:YES completion:nil];
                    }
                } else {
                    NSLog(@" can't do that..let's just go skip..");
                    [self notifyDelegateOfVideoConfirmation:moviePath];
                }
            }];
            [self.endRecordingCameraQueue addOperations:@[blockOperation] waitUntilFinished:YES];
            return;
        }

        [picker dismissViewControllerAnimated:YES completion:^{
            @strongify(self);

            void (^completionBlock)() = ^{
                [TestFlight passCheckpoint:@"Pick Action"];
                @strongify(self);
                // Handle a movie capture


                        //if (!selectedWithLibrary) {



                        //} else {
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

- (void)notifyDelegateOfVideoConfirmation:(NSString*)videoPath {
    if (self.cameraMediaPickerDelegate && [self.cameraMediaPickerDelegate respondsToSelector:@selector(video:didFinishSavingWithError:contextInfo:)]) {
        [self.cameraMediaPickerDelegate video:videoPath didFinishSavingWithError:nil contextInfo:nil];
    }
}

- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
    NSLog(@" video editor did save: %@ at path :%@", editor, editedVideoPath);
    @weakify(self);
    [self dismissVideoEditor:editor completion:^{
        @strongify(self);
        [TestFlight passCheckpoint:@"Pick Video Edited Action"];
        [self dismissViewControllerAnimated:YES completion:^{
            @strongify(self);
            [self notifyDelegateOfVideoConfirmation:editedVideoPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            });
        }];
    }];
}

- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
    //[self videoEditorControllerDidCancel:editor];
}


- (void)dismissVideoEditor:(UIVideoEditorController*)editor completion:(void (^)(void))completion {
    [TestFlight passCheckpoint:@"Video Editing Cancel"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.videoEditorPopoverController dismissPopoverAnimated:YES];
            self.videoEditorPopoverController = nil;
            completion();
        } else {
            [editor dismissViewControllerAnimated:YES completion:completion];
        }
        [self resetProgressBarAnimation];
    });
}

- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
    [self dismissVideoEditor:editor completion:nil];
}

//- (void)navigationController:(UINavigationController *)navigationController  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//
//    NSLog(@"nav Controller will show view controller: %@", viewController);
//
//    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
//        if (!self.customCameraOverlayView) {
//            self.customCameraOverlayView = [[GVCameraOverlayView alloc] initWithFrame:self.view.bounds];
//        }
//        self.cameraOverlayView = self.customCameraOverlayView;
//    }
//    
//}

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
                CGRect bounds = [UIScreen mainScreen].bounds;
                self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
                //self.cameraOverlayView.bounds = bounds;
                [self.cameraOverlayView setNeedsLayout];
                [self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.cameraOverlayView.frame = self.cameraOverlayView.bounds;
            }
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            if (self.lastOrientation != UIInterfaceOrientationPortraitUpsideDown) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationPortraitUpsideDown;
                CGRect bounds = [UIScreen mainScreen].bounds;
                self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
                //self.cameraOverlayView.bounds = bounds;
                [self.cameraOverlayView setNeedsLayout];
                [self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
                //self.cameraOverlayView.frame = self.cameraOverlayView.bounds;
            }
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            if (self.lastOrientation != UIInterfaceOrientationLandscapeLeft) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationLandscapeLeft;
                CGRect bounds = [UIScreen mainScreen].bounds;
                //self.cameraOverlayView.bounds = bounds;
                self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
                [self.cameraOverlayView setNeedsLayout];
                [self.cameraOverlayView layoutIfNeeded];
                //self.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.cameraOverlayView.frame = CGRectMake(0, 0, self.cameraOverlayView.bounds.size.height, self.cameraOverlayView.bounds.size.width);
            }
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            if (self.lastOrientation != UIInterfaceOrientationLandscapeRight) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                self.lastOrientation = UIInterfaceOrientationLandscapeRight;
                CGRect bounds = [UIScreen mainScreen].bounds;
                //self.cameraOverlayView.bounds = bounds;
                self.customCameraOverlayView.overlayBounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
                [self.cameraOverlayView setNeedsLayout];
                [self.cameraOverlayView layoutIfNeeded];
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

/* Called on the delegate when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view.
 */
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"popover should dismiss");
    if (self.libraryPopoverController == popoverController) {
        return YES;
    }
    return NO;
}

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"popover controller dismiss");
}

/* -popoverController:willRepositionPopoverToRect:inView: is called on your delegate when the popover may require a different view or rectangle
 */
- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view {
    NSLog(@"popover will reposition popover");
}

@end
