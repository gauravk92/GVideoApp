//
//  GVVideoCameraViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/31/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVVideoCameraViewController.h"
#import "GVCameraViewController.h"
#import "GVFrontCameraViewController.h"
#import "GVTintColorUtility.h"
#import "UIColor+Image.h"
#import "GVSettingsUtility.h"
#import "GVCameraToolbar.h"

NSString * const GVVideoCameraViewControllerFillProgressBarAnimation = @"GVVideoCameraViewControllerFillProgressBarAnimation";
NSString * const GVVideoCameraViewControllerFinishProgressBarAnimation = @"GVVideoCameraViewControllerFinishProgressBarAnimation";
NSString * const GVVideoCameraViewControllerFlipCameraDeviceAnimation = @"GVVideoCameraViewControllerFlipCameraDeviceAnimation";
NSString * const GVVideoCameraViewControllerFinishSavingVideo = @"GVVideoCameraViewControllerFinishSavingVideo";
NSString * const GVVideoCameraViewControllerSendVideoNotification = @"GVVideoCameraViewControllerSendVideoNotification";

@interface GVVideoCameraViewController () <UIToolbarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UIVideoEditorControllerDelegate>

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, assign) BOOL showingFront;
@property (nonatomic, strong) UIToolbar *videoToolbar;
@property (nonatomic, strong) UIToolbar *infoToolbar;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) UIPopoverController *libraryPopoverController;
@property (nonatomic, strong) UIPopoverController *videoEditorPopoverController;
@property (nonatomic, weak) UIVideoEditorController *videoEditorController;
@property (nonatomic, strong) NSOperationQueue *flipOperationQueue;


@end

@implementation GVVideoCameraViewController

- (BOOL)shouldEdit {
    return YES;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    self = [super initWithNavigationBarClass:[GVProgressNavigationBar class] toolbarClass:[GVCameraToolbar class]];
    if (self) {
        GVCameraViewController *cameraUI;
        if ([GVSettingsUtility selfieMode]) {
            self.showingFront = YES;
            cameraUI = [[GVFrontCameraViewController alloc] initWithNibName:nil bundle:nil];
        } else {
            self.showingFront = NO;
            cameraUI = [[GVCameraViewController alloc] initWithNibName:nil bundle:nil];
        }
        [self pushViewController:cameraUI animated:NO];
        //self.progressViewHidden = YES;
        //self.extendedLayoutIncludesOpaqueBars = YES;
        //self.edgesForExtendedLayout = UIRectEdgeNone;

    }
    return self;
}

//- (BOOL)shouldAutorotate {
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        return YES;
//    }
//    return NO;
//}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self viewWillLayoutSubviews];
}

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.videoToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
//    self.videoToolbar.barStyle = UIBarStyleBlack;
//    self.videoToolbar.translucent = YES;
//    self.videoToolbar.tintColor = [GVTintColorUtility utilityTintColor];
//
//
//    self.toolbar.barStyle = UIBarStyleBlack;
//    self.toolbar.translucent = YES;
//    self.hidesBottomBarWhenPushed = NO;
//    self.toolbarHidden = NO;
//
//    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
//    fixedSpace.width = 10;
//
//    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
//    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_081_refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(flipAction:)];
//    flipButton.title = @"Rear";
//
//    UIBarButtonItem *libraryButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_318_more_items"] style:UIBarButtonItemStylePlain target:self action:@selector(libraryAction:)];
//    libraryButton.title = @"Library";
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_192_circle_remove"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
//
//    UIBarButtonItem *flashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_205_electricity"] style:UIBarButtonItemStylePlain target:self action:@selector(flashAction:)];
//
//    //UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_195_circle_info"] style:UIBarButtonItemStylePlain target:self action:@selector(infoAction:)];
//
//
//    [self.toolbar setItems:@[fixedSpace, flipButton, flexSpace, libraryButton, flexSpace, flashButton, flexSpace, cancelButton, fixedSpace] animated:NO];
//    self.videoToolbar.delegate = self;
//    //[self.view addSubview:self.videoToolbar];
//
//
//    self.infoToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
//    //self.infoToolbar.translatesAutoresizingMaskIntoConstraints = YES;
//    //self.infoToolbar.auto
//    self.infoToolbar.delegate = self;
//    self.infoToolbar.barStyle = UIBarStyleDefault;
//    self.infoToolbar.translucent = YES;
//    self.infoToolbar.tintColor = [UIColor whiteColor];
//    self.infoToolbar.barTintColor = [UIColor clearColor];
//    self.infoToolbar.backgroundColor = [UIColor clearColor];
//    self.infoToolbar.alpha = 0.0;
//    [self.infoToolbar setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
//    self.infoToolbar.userInteractionEnabled = NO;
//
//
//    UIBarButtonItem *flashTitle = [[UIBarButtonItem alloc] initWithTitle:@"Flash" style:UIBarButtonItemStylePlain target:nil action:NULL];
//    UIBarButtonItem *cancelTitle = [[UIBarButtonItem alloc] initWithTitle:@"Exit" style:UIBarButtonItemStylePlain target:nil action:NULL];
//    UIBarButtonItem *libraryTitle = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:nil action:NULL];
//    UIBarButtonItem *flipTitle = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStylePlain target:nil action:NULL];
//    UIBarButtonItem *infoTitle = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_195_circle_info"] style:UIBarButtonItemStylePlain target:nil action:NULL];
//    infoTitle.customView.hidden = YES;
//    UIBarButtonItem *infoSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
//    infoSpace.width = 31;
//    UIBarButtonItem *titleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
//    titleSpace.width = 6;
//
//    self.infoToolbar.items = @[titleSpace, flipTitle, flexSpace, libraryTitle, flexSpace, flashTitle, flexSpace, cancelTitle, titleSpace];
//    [self.view addSubview:self.infoToolbar];
//}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGFloat toolbarHeight = 100;

    self.videoToolbar.frame = CGRectMake(0, self.view.frame.size.height - toolbarHeight, self.view.frame.size.width, toolbarHeight);

    CGFloat infoToolbarHeight = 25;

    self.infoToolbar.frame = CGRectMake(0, self.view.frame.size.height - infoToolbarHeight, self.view.frame.size.width, infoToolbarHeight);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.delegate = self;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(fillProgressBarAnimated:) name:GVVideoCameraViewControllerFillProgressBarAnimation object:nil];

    [nc addObserver:self selector:@selector(finishProgressBarNotification:) name:GVVideoCameraViewControllerFinishProgressBarAnimation object:nil];

    [nc addObserver:self selector:@selector(videoDidFinishSaving:) name:GVVideoCameraViewControllerFinishSavingVideo object:nil];
    [nc addObserver:self selector:@selector(flipActionNotification:) name:GVCameraFlipActionNotification object:nil];
    [nc addObserver:self selector:@selector(libraryActionNotification:) name:GVCameraLibraryActionNotification object:nil];
    [nc addObserver:self selector:@selector(cancelActionNotification:) name:GVCameraCancelActionNotification object:nil];

    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;

    self.flipOperationQueue = [[NSOperationQueue alloc] init];
    self.flipOperationQueue.maxConcurrentOperationCount = 1;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Toolbar delegate methods 

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTop;
}

- (void)flipActionNotification:(NSNotification*)notif {
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
                cameraUI = [[GVCameraViewController alloc] initWithNibName:nil bundle:nil];
            } else {
                self.showingFront = YES;
                cameraUI = [[GVFrontCameraViewController alloc] initWithNibName:nil bundle:nil];
            }
            cameraUI.view.frame = self.view.bounds;
            [UIView transitionFromView:[self.viewControllers[0] view]
                                toView:cameraUI.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            completion:^(BOOL finished) {
                                if (finished) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        @strongify(self);
                                        self.viewControllers = @[cameraUI];
                                        self.flipOperationQueue = [[NSOperationQueue alloc] init];
                                        self.flipOperationQueue.maxConcurrentOperationCount = 1;
                                    });
                                }
                            }];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GVVideoCameraViewControllerFinishSavingVideo object:nil userInfo:movieInfo];
	}
}


- (void)finishProgressBarNotification:(NSNotification*)notif {
    if ([self.progressView respondsToSelector:@selector(finishProgressBarAnimated)]) {
        [self.progressView performSelector:@selector(finishProgressBarAnimated)];
    }
}

- (void)videoDidFinishSaving:(NSNotification*)notif {
    NSDictionary *movieInfo = [notif userInfo];
    if (movieInfo) {
        if ([notif object] == self) {
            NSURL *moviePath = [movieInfo objectForKey:@"movieURL"];
            [self showVideoEditorControllerAtPath:[moviePath relativePath]];
        }
    }
}


- (void)fillProgressBarAnimated:(NSNotification*)notif {
    if ([self.progressView respondsToSelector:@selector(fillProgressBarAnimated)]) {
        [self.progressView performSelector:@selector(fillProgressBarAnimated)];
    }
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        [self.progressView.layer removeAllAnimations];
//        CGRect boundFrame = self.progressView.frame;
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
            } else {
                [self presentViewController:libraryPickerController animated:YES completion:nil];
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
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)notifyDelegateOfVideoConfirmation:(NSString*)videoPath {
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
                    [self presentViewController:videoEditor animated:YES completion:nil];
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
        [self dismissViewControllerAnimated:YES completion:^{
            @strongify(self);
            [self notifyDelegateOfVideoConfirmation:editedVideoPath];
        }];
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
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [self showVideoEditorControllerAtPath:moviePath];

            return;
        }

        void (^completionBlock)() = ^{
            [TestFlight passCheckpoint:@"Pick Action"];
            @strongify(self);
            // Handle a movie capture


            //if (!selectedWithLibrary) {



            //} else {
            [self notifyDelegateOfVideoConfirmation:moviePath];
            
        };

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self imagePickerControllerDidCancel:nil];
            [self dismissViewControllerAnimated:YES completion:^{
                completionBlock();
            }];
            return;
        }

        [picker dismissViewControllerAnimated:YES completion:^{
            @strongify(self);

            if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                [self dismissViewControllerAnimated:YES completion:completionBlock];
            } else {
                completionBlock();
            }
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
    [self.toolbar setNeedsLayout];
    [self.toolbar layoutIfNeeded];
    [self.toolbar.layer setNeedsDisplay];
    [self.toolbar.layer displayIfNeeded];
}

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
