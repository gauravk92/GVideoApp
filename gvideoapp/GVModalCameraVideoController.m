//
//  GVModalCameraVideoController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/6/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVModalCameraVideoController.h"
#import "GVModalCameraView.h"
#import "GVFrontCameraViewController.h"
#import "GVVideoCameraViewController.h"
#import "GVSettingsUtility.h"
#import "GVMasterViewController.h"

const CGFloat GVModalCameraDisabledButtonAlpha = 0.3;

@interface GVModalCameraVideoController ()

@property (nonatomic, assign) BOOL showingFront;
@property (nonatomic, strong) NSOperationQueue *flipOperationQueue;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) UIPopoverController *libraryPopoverController;
@property (nonatomic, strong) UIPopoverController *videoEditorPopoverController;
@property (nonatomic, weak) UIVideoEditorController *videoEditorController;
@property (nonatomic, weak) GVCameraViewController *selectedController;
@property (nonatomic, strong) GVCameraViewController *frontCameraController;
@property (nonatomic, strong) GVCameraViewController *backCameraController;



@end

@implementation GVModalCameraVideoController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;

        self.flipOperationQueue = [NSOperationQueue new];
        self.flipOperationQueue.maxConcurrentOperationCount = 1;



        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(fillProgressBarAnimated:) name:GVVideoCameraViewControllerFillProgressBarAnimation object:nil];

        [nc addObserver:self selector:@selector(finishProgressBarNotification:) name:GVVideoCameraViewControllerFinishProgressBarAnimation object:nil];

        [nc addObserver:self selector:@selector(videoDidFinishSaving:) name:GVVideoCameraViewControllerFinishSavingVideo object:nil];
        [nc addObserver:self selector:@selector(flipActionNotification:) name:GVCameraFlipActionNotification object:nil];
        [nc addObserver:self selector:@selector(libraryActionNotification:) name:GVCameraLibraryActionNotification object:nil];
        [nc addObserver:self selector:@selector(cancelActionNotification:) name:GVCameraCancelActionNotification object:nil];

    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

- (void)forceCameraReload {
#if TESTING_WITHOUT_CAMERA
    return;
#endif
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        //if (!self.selectedController.captureSession.running) {
        [self.selectedController forceCameraReload];
        //}
    });

}

- (void)willDisplay {
#if TESTING_WITHOUT_CAMERA
    return;
#endif
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        //if (!self.selectedController.captureSession.running) {
            [self.selectedController startRunningCaptureSession];
        //}
    });

}

- (void)didEndDisplay {
#if !TESTING_WITHOUT_CAMERA
    return;
#endif
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        if (self.selectedController.captureSession.running) {
            [self.selectedController stopRunningCaptureSession];
        }
    });
}


- (void)loadView {
    self.view = [[GVModalCameraView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    GVCameraViewController *cameraUI;
    if (YES) {
        self.showingFront = YES;
        self.flashButtonView.layer.opacity = GVModalCameraDisabledButtonAlpha;
        cameraUI = [[GVFrontCameraViewController alloc] initWithNibName:nil bundle:nil];
        self.frontCameraController = cameraUI;
    } else {
        self.showingFront = NO;
        cameraUI = [[GVCameraViewController alloc] initWithNibName:nil bundle:nil];
        self.backCameraController = cameraUI;
    }
    self.selectedController = cameraUI;

    [self.view setupCameraViewController:cameraUI];
    [self addChildViewController:cameraUI];
    [cameraUI didMoveToParentViewController:self];

    //[self.view setupCameraViewController:self.frontCameraViewController];
    //[self addChildViewController:self.frontCameraViewController];
    //[self.frontCameraViewController didMoveToParentViewController:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIView*)tapCaptureView {
    return self.view.tapCaptureView;
}

- (UIView*)flipButtonView {
    return self.view.flipButtonView;
}
- (UIView*)libraryButtonView {
    return self.view.libraryButtonView;
}
- (UIView*)flashButtonView {
    return self.view.flashButtonView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //[self.view setNeedsLayout];
    //[self.view layoutIfNeeded];
    [self.view setupInitialState];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.view layoutRasterizationScales];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Toolbar delegate methods

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTop;
}

- (void)flipActionNotification:(NSNotification*)notif {

    if (self.selectedController.recording) {
        return;
    }

    @weakify(self);
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);

            if ([blockOperation_weak_ isCancelled]) {
                return;
            }
            [self.flipOperationQueue cancelAllOperations];
            self.flipOperationQueue = nil;

            GVCameraViewController *cameraUI;
            if (self.showingFront) {
                self.showingFront = NO;
                if (!self.backCameraController) {
                    self.backCameraController = [[GVCameraViewController alloc] initWithNibName:nil bundle:nil];
                    [self.view setupCameraViewController:self.backCameraController];
                    [self addChildViewController:self.backCameraController];
                    [self.backCameraController didMoveToParentViewController:self];


                }
                cameraUI = self.backCameraController;
                
                //[self.view setupCameraViewController:cameraUI];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @strongify(self);
                    [self.frontCameraController stopRunningCaptureSession];
                    [self.backCameraController startRunningCaptureSession];
                });
                //[self.frontCameraController.view removeFromSuperview];


                // Completion is after Front Camera has finished being transitioned
                [UIView transitionFromView:self.frontCameraController.view toView:cameraUI.view
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionLayoutSubviews
                                completion:^(BOOL finished) {
                                    if (finished) {
                                        @strongify(self);

                                        self.flashButtonView.layer.opacity = 1.0;

                                        [self.frontCameraController.view removeFromSuperview];
                                        self.selectedController = self.backCameraController;
                                        self.flipOperationQueue = [[NSOperationQueue alloc] init];
                                        self.flipOperationQueue.maxConcurrentOperationCount = 1;
                                    }
                                }];

//                [self transitionFromViewController:self.frontCameraController
//                                  toViewController:cameraUI
//                                          duration:1.0
//                                           options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionLayoutSubviews
//                                        animations:^{
//                                            [self.view.cameraContainerView bringSubviewToFront:self.backCameraController.view];
//                                        } completion:^(BOOL finished) {
//                                            if (finished) {
//                                                @strongify(self);
//                                                [self.view setupCameraViewController:cameraUI];
//                                                self.flipOperationQueue = [[NSOperationQueue alloc] init];
//                                                self.flipOperationQueue.maxConcurrentOperationCount = 1;
//                                            }
//                                        }];
            } else {
                self.showingFront = YES;
                if (!self.frontCameraController) {
                    self.frontCameraController = [[GVFrontCameraViewController alloc] initWithNibName:nil bundle:nil];
                    [self.view setupCameraViewController:self.frontCameraController];
                    [self addChildViewController:self.frontCameraController];
                    [self.frontCameraController didMoveToParentViewController:self];
                }
                cameraUI = self.frontCameraController;
                //[self.view setupCameraViewController:self.frontCameraController];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @strongify(self);
                    [self.backCameraController stopRunningCaptureSession];
                    [self.frontCameraController startRunningCaptureSession];
                });


                // Completion is after Back Camera has finished being transitioned
                [UIView transitionFromView:self.backCameraController.view toView:cameraUI.view
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionLayoutSubviews
                                completion:^(BOOL finished) {
                                    if (finished) {
                                        @strongify(self);
                                        self.selectedController = self.frontCameraController;
                                        [self.backCameraController.view removeFromSuperview];

                                        self.flashButtonView.layer.opacity = GVModalCameraDisabledButtonAlpha;

                                        self.flipOperationQueue = [[NSOperationQueue alloc] init];
                                        self.flipOperationQueue.maxConcurrentOperationCount = 1;
                                    }
                                }];

//                [UIView transitionFromView:self.backCameraController.view toView:cameraUI.view
//                                  duration:1.0
//                                   options:UIViewAnimationOptionTransitionFlipFromRight
//                                completion:^(BOOL finished) {
//                                    if (finished) {
//
//                                        @strongify(self);
//                                        [self.backCameraController.view removeFromSuperview];
//                                        self.flipOperationQueue = [[NSOperationQueue alloc] init];
//                                        self.flipOperationQueue.maxConcurrentOperationCount = 1;
//                                    }
//                                }];

                //[self.backCameraController stopRunningCaptureSession];
            }
            //cameraUI.view.frame = CGRectIntegral(self.view.bounds;
            //[self.view setupCameraViewController:self.selectedController];
//            [UIView animateWithDuration:0.5
//                                  delay:0.0
//                                options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionLayoutSubviews animations:^{
//                                    //[self.view sendSubviewToBack:self.selectedController.view];
//                                } completion:^(BOOL finished) {
//                                    if (finished) {
//                                        self.flipOperationQueue = [[NSOperationQueue alloc] init];
//                                        self.flipOperationQueue.maxConcurrentOperationCount = 1;
//                                    }
//                                }];

//            [self transitionFromViewController:self.selectedController
//                              toViewController:cameraUI
//                                      duration:0.5
//                                       options:UIViewAnimationOptionTransitionFlipFromLeft
//                                    animations:^{
//
//                                    } completion:^(BOOL finished) {
//                                        if (finished) {
//                                            self.flipOperationQueue = [[NSOperationQueue alloc] init];
//                                            self.flipOperationQueue.maxConcurrentOperationCount = 1;
//                                        }
//                                    }];

//            [UIView transitionFromView:self.selectedController.view
//                                toView:cameraUI.view
//                              duration:0.5
//                               options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionLayoutSubviews
//                            completion:^(BOOL finished) {
//                                if (finished) {
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        @strongify(self);
//                                        self.selectedController = cameraUI;
//                                        [self.view setupCameraViewController:cameraUI];
//                                        self.flipOperationQueue = [[NSOperationQueue alloc] init];
//                                        self.flipOperationQueue.maxConcurrentOperationCount = 1;
//                                    });
//                                }
//                            }];
        });
    }];
    [self.flipOperationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

//********** DID FINISH RECORDING TO OUTPUT FILE AT URL **********
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
	  fromConnections:(NSArray *)connections
				error:(NSError *)error
{

	NSLog(@"didFinishRecordingToOutputFileAtURL - enter");

    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            RecordedSuccessfully = [value boolValue];
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


- (void)finishProgressBarNotification:(NSNotification*)notif {
    //[CATransaction begin];
    //self.view.layer.speed = 1;
    if ([notif object] == self.frontCameraController || [notif object] == self.backCameraController) {
        [self.view finishProgressBarAnimated:nil];
    }
    //[CATransaction commit];
}

- (void)videoDidFinishSaving:(NSNotification*)notif {
    NSDictionary *movieInfo = [notif userInfo];
    if (movieInfo && ( [notif object] == self.frontCameraController || [notif object] == self.backCameraController )) {
        NSURL *moviePath = [movieInfo objectForKey:@"movieURL"];
        [self showVideoEditorControllerAtPath:[moviePath relativePath]];
    }
}


- (void)fillProgressBarAnimated:(NSNotification*)notif {
    //[CATransaction begin];
    //self.view.layer.speed = 1;
    if ([notif object] == self.frontCameraController || [notif object] == self.backCameraController) {
        [self.view fillProgressBarAnimated:nil];
    }
    //[CATransaction commit];
//    if ([self.view.progressNavBar respondsToSelector:@selector(fillProgressBarAnimated)]) {
//        [self.view.progressNavBar performSelector:@selector(fillProgressBarAnimated)];
//    }
    //    @weakify(self);
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        @strongify(self);
    //        [self.progressView.layer removeAllAnimations];
    //        CGRect boundFrame = self.navigationBar.frame;
    //        CGRect frame = CGRectMake(boundFrame.size.width, 0, boundFrame.size.width, boundFrame.size.height);
    //        self.progressView.frame = frame;
    //        CGRect afterFrame = CGRectMake(0, 0, boundFrame.size.width, boundFrame.size.height);
    //        [UIView animateWithDuration:0.5
    //                              delay:0.0
    //                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionOverrideInheritedOptions
    //                         animations:^{
    //                             @strongify(self);
    //                             self.progressView.frame = afterFrame;
    //                         } completion:nil];
    //    });
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

#pragma mark - Action methods

    
- (void)cancelActionNotification:(NSNotification*)notif {
    @weakify(self);
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        @strongify(self);
        if ([blockOperation_weak_ isCancelled]) {
            return;
        }

        [self imagePickerControllerDidCancel:nil];
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)libraryActionNotification:(NSNotification*)notif {

    if (self.selectedController.recording) {
        return;
    }

    id sender = [notif userInfo][@"sender"];
    @weakify(self);
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{

            [TestFlight passCheckpoint:@"Library Action"];

            if ([blockOperation_weak_ isCancelled]) {
                return;
            }

            [self.operationQueue cancelAllOperations];
            self.operationQueue = nil;

            @strongify(self);
            UIImagePickerController *libraryPickerController;
            libraryPickerController = [[UIImagePickerController alloc] init];
            libraryPickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
            libraryPickerController.videoMaximumDuration = VIDEO_MAXIMUM_DURATION;
            libraryPickerController.videoQuality = UIImagePickerControllerQualityTypeLow;


            // Hides the controls for moving & scaling pictures, or for
            // trimming movies. To instead show the controls, use YES.
            libraryPickerController.allowsEditing = YES;
            libraryPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            libraryPickerController.delegate = self;


            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                if (self.libraryPopoverController) {
                    [self.libraryPopoverController dismissPopoverAnimated:YES];
                }

                UIPopoverController *popver = [[UIPopoverController alloc] initWithContentViewController:libraryPickerController];

                self.libraryPopoverController = popver;
                self.libraryPopoverController.delegate = self;
                [popver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                self.operationQueue = [NSOperationQueue new];
                self.operationQueue.maxConcurrentOperationCount = 1;
            } else {
                [self presentViewController:libraryPickerController animated:YES completion:nil];
                self.operationQueue = [NSOperationQueue new];
                self.operationQueue.maxConcurrentOperationCount = 1;
            }
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

#pragma mark - Image Picker Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if ([picker respondsToSelector:@selector(sourceType)] && picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            [picker dismissViewControllerAnimated:YES completion:nil];
            return;
        }
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
        //[self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)notifyDelegateOfVideoConfirmation:(NSString*)videoPath {
    
    NSParameterAssert(videoPath);
    if (self.threadId) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GVVideoCameraViewControllerSendVideoNotification object:nil userInfo:@{@"threadId": self.threadId, @"videoPath": videoPath}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GVVideoCameraViewControllerSendVideoNotification object:nil userInfo:@{@"videoPath": videoPath}];
    }
}

// Only needs to be called if we captured, not from library
- (void)saveNewCaptureIfNeededAtPath:(NSString*)moviePath {
    if ([GVSettingsUtility shouldSaveNewCaptures]) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)forwardFlipTapAction:(UILongPressGestureRecognizer*)gc {
    [self flipActionNotification:nil];
}
- (void)forwardLibraryTapAction:(UILongPressGestureRecognizer*)gc {
    [self libraryActionNotification:nil];
}
- (void)forwardFlashTapAction:(UILongPressGestureRecognizer*)gc {
    [self.selectedController flashNotification:nil];
}

- (void)forwardCameraTapAction:(UILongPressGestureRecognizer *)gc {
    [self.selectedController startRecordingAction:gc];
}

- (void)showVideoEditorControllerAtPath:(NSString*)moviePath {
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(blockOperation);
    @weakify(self);
    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if ([blockOperation_weak_ isCancelled]) {
                return;
            }

            [self.operationQueue cancelAllOperations];
            self.operationQueue = nil;
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            // we need to let them edit it
            /**
             *  Here we need to start a video editor to let them trim and play/confirm/cancel
             */
            if ([UIVideoEditorController canEditVideoAtPath:moviePath]) {
                UIVideoEditorController *videoEditor = [[UIVideoEditorController alloc] init];
                videoEditor.videoPath = moviePath;
                videoEditor.videoMaximumDuration = VIDEO_MAXIMUM_DURATION;
                videoEditor.videoQuality = UIImagePickerControllerQualityTypeHigh;
                videoEditor.delegate = self;
                //[self finishProgressBarAnimation];
                self.videoEditorController = videoEditor;

                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    self.videoEditorPopoverController = [[UIPopoverController alloc] initWithContentViewController:videoEditor];
                    self.videoEditorPopoverController.delegate = self;
                    [self.videoEditorPopoverController presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                } else {
                    [self presentViewController:videoEditor animated:YES completion:^{
                        @strongify(self);
                        self.operationQueue = [NSOperationQueue new];
                        self.operationQueue.maxConcurrentOperationCount = 1;
                        
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    }];
                }
            } else {
                NSLog(@" can't do that..let's just go skip..");

                [self saveNewCaptureIfNeededAtPath:moviePath];

                [self notifyDelegateOfVideoConfirmation:moviePath];
            }
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
    NSLog(@" video editor did save: %@ at path :%@", editor, editedVideoPath);
    @weakify(self);
    [self dismissVideoEditor:editor completion:^{
        @strongify(self);
        [TestFlight passCheckpoint:@"Pick Video Edited Action"];
        //[self dismissViewControllerAnimated:YES completion:^{
        //    @strongify(self);
        [self notifyDelegateOfVideoConfirmation:editedVideoPath];
        //}];
    }];
}

- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
    //[self videoEditorControllerDidCancel:editor];
}


- (void)dismissVideoEditor:(UIVideoEditorController*)editor completion:(void (^)(void))completion {
    [TestFlight passCheckpoint:@"Video Editing Cancel"];
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.videoEditorPopoverController dismissPopoverAnimated:YES];
            self.videoEditorPopoverController = nil;
            if (completion) {
                completion();
            }
        } else {
            [editor dismissViewControllerAnimated:YES completion:completion];
        }
    });
}

- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
    [self dismissVideoEditor:editor completion:nil];
}

- (NSString*)moviePathForMediaType:(NSDictionary*)info {
    DLogObject(info);
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSString *movieType = (id)kUTTypeMovie;
    if ([mediaType isEqualToString:movieType]) {
        NSURL *url = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
        if (url) {
            return [url path];
        } else {
            NSURL *refUrl = (NSURL *)[info objectForKey:UIImagePickerControllerReferenceURL];
            if (refUrl) {
                return [refUrl path];
            }
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
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [self showVideoEditorControllerAtPath:moviePath];

            return;
        }
        
        DLogObject(moviePath);

        void (^completionBlock)() = ^{
            [TestFlight passCheckpoint:@"Pick Action"];
            @strongify(self);
            // Handle a movie capture


            //if (!selectedWithLibrary) {


            DLogObject(moviePath);
            DLogObject(info);
            //} else {
            [self notifyDelegateOfVideoConfirmation:moviePath];

        };

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self imagePickerControllerDidCancel:nil];
            //[self dismissViewControllerAnimated:YES completion:^{
                completionBlock();
            //}];
            return;
        }

        [picker dismissViewControllerAnimated:YES completion:^{
            // @strongify(self);

            //if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            //    [picker dismissViewControllerAnimated:YES completion:completionBlock];
            //} else {
                completionBlock();
            //}
        }];
    });
}

#pragma mark - Navigation Delegate methods

- (void)attemptToChangeVideoEditorToSendButton:(UINavigationController*)navigationController {
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

- (void)navigationController:(UINavigationController *)navigationController  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

    NSLog(@"nav Controller will show view controller: %@", viewController);
    if (![navigationController respondsToSelector:@selector(sourceType)]) {
        //self.customCameraOverlayView.toolbar.userInteractionEnabled = NO;
        //navigationController.navigationItem.rightBarButtonItem.title = @"Send";
        [self attemptToChangeVideoEditorToSendButton:navigationController];
    }

    if (self.videoEditorController == navigationController) {
        [self attemptToChangeVideoEditorToSendButton:navigationController];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    [self.toolbar setNeedsLayout];
//    [self.toolbar layoutIfNeeded];
//    [self.toolbar.layer setNeedsDisplay];
//    [self.toolbar.layer displayIfNeeded];
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

#pragma mark - Popover methods

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
