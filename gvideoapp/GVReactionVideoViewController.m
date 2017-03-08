//
//  GVReactionVideoViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/4/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVReactionVideoViewController.h"
#import "GVFrontReactionViewController.h"
#import "GVVideoCameraViewController.h"
#import "GVMoviePlayerViewController.h"
#import "GVPlayPauseButton.h"
#import "GVTintColorUtility.h"
#import "GVMasterModelObject.h"
#import "GVDiskCache.h"

@interface GVReactionVideoViewController () <GVCameraMediaPickerControllerProtocol, UIAlertViewDelegate>

@property (nonatomic, strong) GVFrontReactionViewController *reactionCameraController;

@property (nonatomic, strong) UIViewController *loadingViewController;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, copy) NSString *outputPath;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) UIView *toolbarBackdrop;

@property (nonatomic, strong) CAShapeLayer *viewMask;
@property (nonatomic, strong) CAShapeLayer *viewMaskMask;

@property (nonatomic, strong) CAGradientLayer *toolbarMask;

@property (nonatomic, strong) UIImageView *cameraButton;

@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) UIColor *normalColor;

@property (nonatomic, assign) CGFloat playbackProgress;

@property (nonatomic, strong) UIView *playPauseButton;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UILongPressGestureRecognizer *playPauseTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *cancelTapGestureRecognizer;

@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;

@property (nonatomic, copy) NSURL *playURL;
@property (nonatomic, copy) NSString *playOutputPath;

@property (nonatomic, strong) UIView *circleView;

@property (nonatomic, strong) UIView *playProgressView;

@property (nonatomic, strong) NSTimer *playTimer;

@property (nonatomic, assign) BOOL cancelledReaction;

//@property (nonatomic, strong) NSOperationQueue *animateProgressBar;

@end

@implementation GVReactionVideoViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (instancetype)initWithContentURL:(NSString*)contentURL threadId:(NSString*)threadId activityId:(NSString*)activityId shouldRecord:(NSNumber*)shouldRecord
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.navigationBarHidden = YES;

        // Do any additional setup after loading the view.

        //    if (([UIImagePickerController isSourceTypeAvailable:
        //          UIImagePickerControllerSourceTypeCamera] == NO)) {
        //        return;
        //    }

        _contentURL = contentURL;
        _threadId = threadId;
        _activityId = activityId;
        _shouldRecord = shouldRecord;

        CGFloat circleSize = 230;
        
        UIView *circleView;
        //GVCircleReactionView *circleReactionView;
        //if (false) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            circleView = [[UIView alloc] initWithFrame:CGRectMake(20, 30, 150, 150)];
            circleView.backgroundColor = [UIColor clearColor];
            //  circleView = circleReactionView;
            circleView.layer.cornerRadius = 75;
            circleView.autoresizesSubviews = YES;
            circleView.clipsToBounds = 1;
            circleView.contentMode = UIViewContentModeScaleAspectFit;

        } else {
            
            circleView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - circleSize/2, 25, circleSize, circleSize)];
            circleView.backgroundColor = [UIColor clearColor];
            circleView.layer.cornerRadius = circleView.frame.size.width/2;
            circleView.layer.borderWidth = 8;
            circleView.layer.borderColor = [UIColor whiteColor].CGColor;
            circleView.clipsToBounds = 1;
        }
        _circleView = circleView;
        //[circleView show];
        circleView.alpha = 1.0;
        //self.circleView = circleView;
        
        self.toolbarBackdrop = [[UIView alloc] initWithFrame:CGRectZero];
        //self.toolbarBackdrop.backgroundColor = [UIColor colorWithRed:0.000 green:0.001 blue:0.256 alpha:0.580];
        [self.view addSubview:self.toolbarBackdrop];
        
        self.normalColor = [GVTintColorUtility utilityTintColor];
        if ([self.shouldRecord boolValue]) {
            self.normalColor = [GVTintColorUtility utilityRedColor];
        }
        self.highlightColor = [UIColor whiteColor];
        
        self.view.tintColor = self.normalColor;
        
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        maskLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor];
        maskLayer.shouldRasterize = YES;
        maskLayer.startPoint = CGPointMake(0.5, 0);
        maskLayer.endPoint = CGPointMake(0.5, 1);
        maskLayer.rasterizationScale = [UIScreen mainScreen].scale;
        self.toolbarMask = maskLayer;
        //self.toolbarBackdrop.layer.mask = maskLayer;
        
        self.viewMask = [CAShapeLayer layer];
        self.viewMask.fillColor = [UIColor whiteColor].CGColor;
        self.viewMask.backgroundColor = [UIColor whiteColor].CGColor;
        //self.view.layer.mask = self.viewMask;
        
        self.viewMaskMask = [CAShapeLayer layer];
        self.viewMaskMask.fillColor = [UIColor clearColor].CGColor;
        self.viewMaskMask.backgroundColor = [UIColor clearColor].CGColor;
        //self.viewMask.mask = self.viewMaskMask;
        
        self.playPauseButton = [[GVPlayPauseButton alloc] initWithFrame:CGRectZero];
        self.playPauseButton.layer.borderColor = self.normalColor.CGColor;
        self.playPauseButton.layer.shadowOffset = CGSizeMake(0, 3);
        self.playPauseButton.layer.shadowOpacity = 1;
        self.playPauseButton.layer.shadowColor = [UIColor blackColor].CGColor;
        //[self.toolbarBackdrop addSubview:self.playPauseButton];
        
        UIImage *camImage = [[UIImage imageNamed:@"glyphicons_207_remove_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.cameraButton = [[UIImageView alloc] initWithImage:camImage];
        [self.toolbarBackdrop addSubview:self.cameraButton];
        
        UIImage *image = [[UIImage imageNamed:@"lineicons_play_full"]  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.playImageView = [[UIImageView alloc] initWithImage:image];
        [self.playPauseButton addSubview:self.playImageView];
        
        self.playPauseTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePlayPauseTap:)];
        self.playPauseTapGestureRecognizer.delegate = self;
        self.playPauseTapGestureRecognizer.minimumPressDuration = 0.01;
        self.playPauseTapGestureRecognizer.numberOfTapsRequired = 0;
        [self.playPauseButton addGestureRecognizer:self.playPauseTapGestureRecognizer];
        
        self.cancelTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTap:)];
        self.cancelTapGestureRecognizer.delegate = self;
        self.cancelTapGestureRecognizer.minimumPressDuration = 0.01;
        self.cancelTapGestureRecognizer.numberOfTapsRequired = 0;
        [self.toolbarBackdrop addGestureRecognizer:self.cancelTapGestureRecognizer];


        self.progressBar = [[UIView alloc] initWithFrame:CGRectZero];
        self.progressBar.backgroundColor = [UIColor whiteColor];
        self.progressBar.layer.cornerRadius = 1;
        self.progressBar.clipsToBounds = YES;

        self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.loadingLabel.backgroundColor = [UIColor clearColor];
        self.loadingLabel.textColor = [UIColor whiteColor];
        self.loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
        self.loadingLabel.text = @"Loading...";
        self.loadingLabel.layer.shouldRasterize = YES;
        self.loadingLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;

        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        //@autoreleasepool {
//            @weakify(self);
//            NSString *contentURL = [notif userInfo][@"contentURL"];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @strongify(self);
//                self.progressHUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
//            });
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
//


                //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.contentURL]];

                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *path = [paths objectAtIndex:0];


        NSString *cachePath = [self.activityId stringByAppendingString:@".mov"];
                // save to temporary directory
        self.playOutputPath = [[NSString alloc] initWithFormat:@"%@/%@", path, cachePath];
        NSString *playOutputPathString = self.playOutputPath;
        //NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:self.playOutputPath]) {
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

            @weakify(self);
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.contentURL]];
            NSProgress *progress;
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^(NSURL *targetPath, NSURLResponse *response) {
                @strongify(self);
                DAssertNonNil(playOutputPathString);
                return [NSURL fileURLWithPath:playOutputPathString];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                //[progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
                // …

                dispatch_async(dispatch_get_main_queue(), ^{

                    @strongify(self);
                    [UIView animateWithDuration:0.6 animations:^{
                        @strongify(self);
                        self.progressBar.alpha = 0.0;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            @strongify(self);
                            [self.progressBar removeFromSuperview];
                            [self animateOutCircleView];
                        }
                    }];

                    if (!error) {
                        if (self.playOutputPath && [self.playOutputPath respondsToSelector:@selector(length)] && [self.playOutputPath length] > 0) {
                            self.playURL = [NSURL fileURLWithPath:self.playOutputPath];
                            [self playCurrentPlayURL];
                        }
                        //self.outputPath = outputPath;

                        

                        //[self.movieViewController.moviePlayer setContentURL:[NSURL URLWithString:outputPath]];
                        //[self.movieViewController.moviePlayer play];
                    } else {
                        NSLog(@"error loading video: %@", error);
                        NSLog(@"error URL response: %@", response);
                    }
                });
            }];
            
            [downloadTask resume];
            
            [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    //NSLog(@"progress: %f", progress.fractionCompleted);
                    
                    CGFloat progressBarPadding;
                    CGFloat progressBarHeight = 5;
                    CGFloat progressBarBoundHeight = self.loadingViewController.view.bounds.size.height;
                    CGFloat progressBarBoundWidth = self.loadingViewController.view.bounds.size.width;
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        progressBarPadding = 200;
                    } else {
                        progressBarPadding = 100;
                    }
                    
                    self.progressBar.frame = CGRectIntegral(CGRectMake(progressBarPadding, (progressBarBoundHeight / 2) - (progressBarHeight / 2) + 80, (progressBarBoundWidth - (progressBarPadding*2)) * progress.fractionCompleted, progressBarHeight));
                    
                    CGFloat loadingLabelPadding = 10;
                    [self.loadingLabel sizeToFit];
                    self.loadingLabel.center = self.loadingLabel.superview.center;
                    self.loadingLabel.frame = CGRectIntegral(self.loadingLabel.frame);
                    
                    CGRect loadingLabelRect = self.loadingLabel.frame;
                    loadingLabelRect.origin.y = self.progressBar.frame.origin.y - loadingLabelPadding - loadingLabelRect.size.height;
                    self.loadingLabel.frame = CGRectIntegral(loadingLabelRect);
                    
                    if (progress.fractionCompleted > .9) {
                        self.loadingLabel.alpha = 0.0;
//                        [UIView animateWithDuration:1.5 animations:^{
//                            circleView.alpha = 0.0;
//                        }];
                    }
                    
                });
            }];
            
        } else {
            // it's effectively cached...lets just play it directly no loading needed
            self.playURL = [NSURL fileURLWithPath:self.playOutputPath];
            [self playCurrentPlayURL];
            self.loadingLabel.alpha = 0.0;
            [self animateOutCircleView];
        }
//                AFHTTPRequestOperation *op = [manager GET:self.contentURL
//                                               parameters:nil
//                                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                                      NSLog(@"successful download to %@ URL: %@", outputPath, outputURL);
////                                                      if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputPath)) {
////                                                          UISaveVideoAtPathToSavedPhotosAlbum(outputPath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
////                                                      }
////[self.movieViewController.moviePlayer setContentURL:outputURL];
//
//                                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                                      NSLog(@"Error: %@", error);
//
////                                                      [self video:nil didFinishSavingWithError:nil contextInfo:nil];
//                                                  }];
//    op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPath append:NO];
        
//        [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//
//            NSLog(@"Download = %f", (float)totalBytesRead / totalBytesExpectedToRead);
//            CGFloat progress;
//            long long progressContentLength = (float)totalBytesRead;
//            CGFloat expectedContentLength = 1000;
//
//            if (expectedContentLength > 0 && progressContentLength <= expectedContentLength) {
//                progress = (CGFloat) progressContentLength / expectedContentLength;
//            } else {
//                progress = (progressContentLength % 1000000l) / 1000000.0f;
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //circleView.progress = progress;
//            });
//            
//        }];
                //NSString *moviePath = [outputURL relativeString];
                //   });
        //}

        GVFrontReactionViewController *cameraUI = nil;
        if ([self.shouldRecord boolValue]) {

            cameraUI = [[GVFrontReactionViewController alloc] initWithNibName:nil bundle:nil];
            self.reactionCameraController = cameraUI;
        }

        //    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        //    self.reactionPickerController = cameraUI;
        //    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        //
        //    // Displays a control that allows the user to choose movie capture
        //    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
        //
        //    cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        //    cameraUI.videoMaximumDuration = 30;
        //
        //
        //
        //    // Hides the controls for moving & scaling pictures, or for
        //    // trimming movies. To instead show the controls, use YES.
        //    cameraUI.allowsEditing = NO;
        //    cameraUI.showsCameraControls = NO;
        //    //cameraUI.view.layer.cornerRadius = 50;
        //
        //    cameraUI.delegate = self;



        self.loadingViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        self.loadingViewController.view.backgroundColor = [UIColor blackColor];

//        if (false) {
//            //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//            //[moviePlayer.view addSubview:circleView];
//        } else {
        if ([self.shouldRecord boolValue]) {
            [self.loadingViewController.view addSubview:circleView];
            [circleView addSubview:cameraUI.view];
        }
        
        [self.loadingViewController.view addSubview:self.progressBar];
        [self.loadingViewController.view addSubview:self.loadingLabel];
        
        if ([self.shouldRecord boolValue]) {
            [self.loadingViewController addChildViewController:cameraUI];
            [cameraUI didMoveToParentViewController:self.loadingViewController];
        }
            //}
        UIPopoverController *popover;
        if (false) {
            //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            //cameraUI.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
            //cameraUI.cameraViewTransform = CGAffineTransformScale(cameraUI.cameraViewTransform, 1, 1);
            //cameraUI.view.frame = CGRectMake(0, 0, 150, 150);
            //cameraUI.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
            UIViewController *containerController = [[UIViewController alloc] init];
            containerController.preferredContentSize = CGSizeMake(0.001, 0.001);
            [containerController.view addSubview:cameraUI.view];
            [containerController addChildViewController:cameraUI];
            [cameraUI didMoveToParentViewController:containerController];
            containerController.modalInPopover = YES;
            //containerController.interfaceOrientation = UIInterfaceOrientationPortrait;

            popover = [[UIPopoverController alloc] initWithContentViewController:containerController];
            //self.reactionPopoverController = popover;
            //self.reactionPopoverController.delegate = self;
            popover.backgroundColor = [UIColor clearColor];
            //popover.popoverBackgroundViewClass = [GVReactionPopoverView class];
            [popover setPopoverContentSize:CGSizeMake(200, 200)];
            [popover presentPopoverFromRect:CGRectMake(0, 0, 1, 1) inView:self.view.window permittedArrowDirections:UIPopoverArrowDirectionLeft animated:NO];
            //circleReactionView.picker = cameraUI;
            [cameraUI.view setFrame:containerController.view.frame];
            //[circleReactionView addSubview:containerController.view];
            CGRect containFrame = containerController.view.frame;
            containFrame.origin.y = -25;
            containFrame.origin.x = -25;
            containerController.view.frame = CGRectIntegral(containFrame);
            //[circleReactionView setNeedsLayout];
            //[circleReactionView layoutIfNeeded];
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                containerController.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
            } else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                containerController.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
            } else {

            }
            //[popover dismissPopoverAnimated:NO];


        }

        if ([self.shouldRecord boolValue]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cameraUI.view.frame = CGRectIntegral(circleView.bounds);
            } else {
                cameraUI.view.frame = CGRectMake(0, 0, circleSize, circleSize);
            }
        }


        // register for notifications now mofo

        //                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:moviePlayer];
        //    //
        //                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieReadyChange:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
        //    //
        //                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        //    //
        //                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayingChange:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
        
        //self.reactionPickerController.delegate = self;
        //self.reactionViewController = moviePlayer;
        //moviePlayer.transitionCoordinator = self;
        
        
        
        //[self.navigationController presentViewController:moviePlayer animated:YES completion:^{
        //    @strongify(self);
        if ([self.shouldRecord boolValue]) {
            cameraUI.cameraMediaPickerDelegate = self;
        }
        [self pushViewController:self.loadingViewController animated:YES];
        //[cameraUI startStopButtonPressed:nil];
        //[self.reactionPickerController startVideoCapture];
        //[circleReactionView setNeedsLayout];
        //[circleReactionView layoutIfNeeded];
        
        //}];
        
        
    }
    return self;
}

- (void)animateOutCircleView {
    
    @weakify(self);
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        @strongify(self);
        self.circleView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.shouldRecord boolValue]) {
        [self.reactionCameraController startStopButtonPressed:nil];
    }
    
}

- (void)playCurrentPlayURL {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:self.playURL];
        //moviePlayer.moviePlayer.shouldAutoplay = NO;
        
        //[UIApplication sharedApplication].statusBarHidden = NO;
        moviePlayer.edgesForExtendedLayout = UIRectEdgeAll;
        moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        //[moviePlayer.moviePlayer play];
        [moviePlayer.moviePlayer pause];
        moviePlayer.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleNone;
        NSTimeInterval timeInterval = moviePlayer.moviePlayer.duration;
        self.moviePlayer = moviePlayer;
        self.movieViewController = moviePlayer;
        
        CGFloat width = self.view.frame.size.width;
        CGFloat height = 3.0;
        UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        UIView *progressBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        self.playProgressView = progressView;
        self.playProgressView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.playProgressView.layer.shadowOpacity = 1;
        self.playProgressView.layer.shadowOffset = CGSizeMake(0, 2);
        
        self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        
        [self.loadingViewController.view addSubview:moviePlayer.view];
        [self.loadingViewController.view sendSubviewToBack:moviePlayer.view];
        [self.loadingViewController addChildViewController:moviePlayer];
        [moviePlayer didMoveToParentViewController:self.loadingViewController];
        moviePlayer.view.frame = CGRectIntegral(self.loadingViewController.view.bounds);
        progressView.layer.needsDisplayOnBoundsChange = YES;
        
        
        [self.view addSubview:progressBackground];
        [self.view bringSubviewToFront:progressBackground];
        
        [self.view addSubview:progressView];
        [self.view bringSubviewToFront:progressView];
        if ([self.shouldRecord boolValue]) {
            progressView.backgroundColor = [GVTintColorUtility utilityRedColor];
            
        } else {
            progressView.backgroundColor = [UIColor whiteColor];
        }
        
        progressBackground.backgroundColor = progressView.backgroundColor;
        progressBackground.alpha = 0.4;
//        [UIView animateWithDuration:timeInterval
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveLinear
//                         animations:^{
//                             progressView.frame = CGRectMake(width, 0, width, height);
//                         } completion:^(BOOL finished) {
//                             [progressView removeFromSuperview];
//                         }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer.moviePlayer];
    });
}

- (void)updateProgress:(id)sender {
    CGRect progressRect = CGRectMake(0, 0, self.view.frame.size.width, self.playProgressView.frame.size.height);
    NSTimeInterval playbackTime = self.moviePlayer.moviePlayer.currentPlaybackTime;
    NSTimeInterval duration = self.moviePlayer.moviePlayer.playableDuration + 2;
    self.playbackProgress = (playbackTime / duration);
    if (duration > 0) {
        progressRect.origin.x = self.playbackProgress * self.view.frame.size.width;
    }
    if (progressRect.origin.x < 0.1) {
        progressRect.origin.x = 0;
    }
    //DLogCGRect(progressRect);
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform = CATransform3DTranslate(CATransform3DIdentity, progressRect.origin.x, 0, 0);
    basicAnimation.toValue = [NSValue valueWithCATransform3D:transform];
//    basicAnimation.additive = YES;
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.duration = 0.25;
    basicAnimation.cumulative = YES;
    basicAnimation.fillMode = kCAFillModeForwards;
    [self.playProgressView.layer addAnimation:basicAnimation forKey:nil];
    //self.playProgressView.frame = CGRectIntegral(progressRect);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
}

////********** DID FINISH RECORDING TO OUTPUT FILE AT URL **********
//- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
//didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
//	  fromConnections:(NSArray *)connections
//				error:(NSError *)error
//{
//
//	NSLog(@"didFinishRecordingToOutputFileAtURL - enter");
//
//    BOOL RecordedSuccessfully = YES;
//    if ([error code] != noErr) {
//        // A problem occurred: Find out if the recording was successful.
//        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
//        if (value) {
//            RecordedSuccessfully = [value boolValue];
//        }
//        NSLog(@"recording error: %@", error);
//    }
//	if (RecordedSuccessfully) {
//		//----- RECORDED SUCESSFULLY -----
//        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
//        NSDictionary *movieInfo = @{@"movieURL": outputFileURL };
//        [[NSNotificationCenter defaultCenter] postNotificationName:GVVideoCameraViewControllerFinishSavingVideo object:nil userInfo:movieInfo];
//	}
//}

- (void)handlePlayPauseTap:(UILongPressGestureRecognizer*)gc {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (gc.state == UIGestureRecognizerStateBegan) {
            self.playPauseButton.layer.borderColor = self.highlightColor.CGColor;
            self.playImageView.tintColor = self.highlightColor;
            return;
        }
        if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
            if (self.moviePlayer.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
                [self.moviePlayer.moviePlayer pause];
                self.playImageView.image = [[UIImage imageNamed:@"lineicons_play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            } else {
                [self.moviePlayer.moviePlayer play];
                self.playImageView.image = [[UIImage imageNamed:@"lineicons_play_full"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }
        [CATransaction begin];
        [CATransaction setAnimationDuration:1.0];
        self.playImageView.tintColor = self.normalColor;
        self.playPauseButton.layer.borderColor = self.normalColor.CGColor;
        [CATransaction commit];
    });
}

- (void)handleCancelTap:(UILongPressGestureRecognizer*)gc {
    CGPoint location = [gc locationInView:gc.view];
    if (location.x < self.view.frame.size.width*.3) {
        if (gc.state == UIGestureRecognizerStateBegan) {
            self.cameraButton.tintColor = self.highlightColor;
            return;
        }
        if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
            
            if ([self.shouldRecord boolValue]) {
                if (self.playbackProgress < .9) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reaction Cancellation Confirmation" message:@"Are you sure you want to exit, this will cancel the reaction recording?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
                    alert.delegate = self;
                    [alert show];
                } else {
                    [self alertView:nil clickedButtonAtIndex:1];
                }
            } else {
                [self dismissSelfAnimated];
            }
        }
        self.cameraButton.tintColor = self.normalColor;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.cancelledReaction = YES;
        [self playbackFinished:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat toolbarHeight = 120;
    
    CGFloat cameraPadding = 30;
    
    CGFloat buttonSize = 65;
    CGFloat buttonPadding = 20;
    
    self.toolbarBackdrop.frame = CGRectMake(0, self.view.frame.size.height - toolbarHeight +5, self.view.frame.size.width, toolbarHeight);
    
    self.toolbarMask.frame = self.toolbarBackdrop.bounds;
    
    self.playPauseButton.frame = CGRectIntegral(CGRectMake(self.view.frame.size.width/2 - buttonSize/2, self.toolbarBackdrop.frame.size.height - buttonPadding - buttonSize, buttonSize, buttonSize));
    
    self.playImageView.frame = CGRectIntegral(CGRectMake(self.playPauseButton.frame.size.width/2 - self.playImageView.image.size.width/2+3, self.playPauseButton.frame.size.height/2 - self.playImageView.image.size.height/2, self.playImageView.image.size.width, self.playImageView.image.size.height));
    //self.playImageView.center = self.playPauseButton.center;
    self.cameraButton.frame = CGRectIntegral(CGRectMake(cameraPadding, self.toolbarBackdrop.frame.size.height/2 - self.cameraButton.image.size.height/2 + 8, self.cameraButton.image.size.width, self.cameraButton.image.size.height));
    
    self.viewMaskMask.frame = CGRectMake(cameraPadding, self.view.frame.size.height - cameraPadding, 40, 40);
    
    self.viewMask.frame = self.view.bounds;
    //
    //    [self.toolbarBackdrop setNeedsDisplay];
    //    [self.playPauseButton setNeedsDisplay];
    //    [self.cameraButton setNeedsDisplay];
    //    [self.playImageView setNeedsDisplay];
}


- (void)willAttemptToSaveVideo {

}

- (void)playbackFinished:(NSNotification*)notif {
    NSBlockOperation *op = [NSBlockOperation new];
    @weakify(op);
    @weakify(self);
    [op addExecutionBlock:^{
        if ([op_weak_ isCancelled]) {
            return ;
        }
        @strongify(self);
        [self.operationQueue cancelAllOperations];
        self.operationQueue = nil;

        [self.playTimer invalidate];
        self.playTimer = nil;
        
        NSLog(@"notif received playback finished!!!!!!");
        //@weakify(self);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishSavingNotification:) name:GVVideoCameraViewControllerFinishSavingVideo object:nil];

        NSDictionary *dict = nil;
        if (self.threadId && self.activityId) {
            dict = @{@"threadId": self.threadId, @"activityId": self.activityId};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GVMovieDidFinishPlayingNotification object:nil userInfo:dict];

        int64_t timeDelay = (int64_t)(2.0 * NSEC_PER_SEC);
        if (self.cancelledReaction) {
            timeDelay = (int64_t)(0.2 * NSEC_PER_SEC);
        }
        
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        CATransform3D transform = CATransform3DTranslate(CATransform3DIdentity, self.view.frame.size.width, 0, 0);
        basicAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        //    basicAnimation.additive = YES;
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.duration = 2;
        basicAnimation.cumulative = YES;
        basicAnimation.fillMode = kCAFillModeForwards;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self_weak_.playProgressView.layer addAnimation:basicAnimation forKey:nil];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeDelay), dispatch_get_main_queue(), ^{
            if ([self.shouldRecord boolValue]) {
                [self.reactionCameraController performSelectorOnMainThread:@selector(startStopButtonPressed:) withObject:nil waitUntilDone:NO];
            }
            //[self dismissSelfAnimated];
        });
        //[self.reactionCameraController performSelector:@selector(startStopButtonPressed:) withObject:nil afterDelay:3.0];
        //[self performSelector:@selector(dismissSelfAnimated) withObject:nil afterDelay:3.0];

    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        @strongify(self);
    //        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishSaving:) name:GVVideoCameraViewControllerFinishSavingVideo object:nil];
    //
    //        [self.reactionCameraController startStopButtonPressed:nil];
    //    });
    }];
    [self.operationQueue addOperations:@[op] waitUntilFinished:YES];
}

- (void)dismissSelfAnimated {
    self.playProgressView.hidden = YES;
      [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)videoDidFinishSavingNotification:(NSNotification*)notif {
    NSLog(@"notif %@", [notif userInfo]);
    NSURL *moviePath = [notif userInfo][@"movieURL"];
    if ([notif object] == self.reactionCameraController) {
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:^{
            NSLog(@"completed");
            NSDictionary *info = @{@"activityId": self.activityId, @"threadId": self.threadId, @"outputPath": [moviePath relativePath]};
            [[NSNotificationCenter defaultCenter] postNotificationName:GVReactionCameraVideoSaveNotification object:nil userInfo:info];
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
