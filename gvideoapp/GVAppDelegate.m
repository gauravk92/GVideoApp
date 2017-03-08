//
//  GVAppDelegate.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/26/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVAppDelegate.h"
#import "GVThreadViewController.h"
#import "MBProgressHUD.h"
#import "GVMasterViewController.h"
#import "Reachability.h"
#import "GVTintColorUtility.h"
#import "GVSettingsUtility.h"
#import "GVWelcomeSignupViewController.h"
#import "GVThreadBackgroundView.h"
#import "GVMasterModelObject.h"
#import "GVCache.h"
#import "GVParseObjectUtility.h"
#import "GVThreadDetailNavigationController.h"
#import "GVSplitViewController.h"
#import "GVNavigationViewController.h"
#import "GVThreadTableViewController.h"
#import "GVReactionVideoViewController.h"
#import "GVModalNavigationViewController.h"
#import "GVModalCameraContainerViewController.h"
//#import "GfitHorizontalSlidingTabBarController.h"
#import "GVModalNavigationViewController.h"
#import "GVSlidingModalNavigationController.h"
#import "GVCollectionViewController.h"
#import "GVDiskCache.h"
#import "GVSettingsUtility.h"
#import "GVInviteActivityProvider.h"
#import "GVShareActivityProvider.h"
#import "GVMoviePlayerViewController.h"
#import "GVMainScrollViewController.h"


#if CYCRIPT
#import "NSString+GetIPAddress.h"
#import "Cycript/Cycript.h"
#endif

NSString *GVLoggedInNotification = @"GVLoggedInNotification";
NSString *GVLoggedOutNotification = @"GVLoggedOutNotification";
NSString *GVClearCacheNotification = @"GVLoggedOutNotification";
NSString *GVLogOutNotification = @"GVLogOutNotification";
NSString *GVAboutUsPadNotification = @"GVAboutUsPadNotification";
NSString *GVDeleteAccountNotification = @"GVDeleteAccountNotification";
NSString *GVDeleteWillDeleteThreadNotification = @"GVDeleteWillDeleteThreadNotification";
NSString *GVDeleteDidDeleteThreadNotification = @"GVDeleteDidDeleteThreadNotification";
NSString *GVPlayMovieNotification = @"GVPlayMovieNotification";
NSString *GVReactionVideoNotification = @"GVReactionVideoNotification";
NSString *GVInternetRequestNotification = @"GVInternetRequestNotification";
NSString *GVNewThreadRequestNotification = @"GVNewThreadRequestNotification";
NSString *GVSaveMovieNotification = @"GVSaveMovieNotification";
NSString *GVThreadInviteNotification = @"GVThreadInviteNotification";
NSString *GVModelHasSuccessfullyInstalledDevice = @"GVModelHasSuccessfullyInstalledDevice";


#define THREAD_TABLE 1
#define SPLIT_TABLE_TEST 1
#define NO_NAVIGATION_CONTROLLER 1
#define SIMPLE_UI 0

@interface GVAppDelegate () <UIAlertViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) UIAlertView *currentAlertView;
@property (nonatomic, strong) NSBlockOperation *currentOperation;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UISplitViewController *splitController;
#if !NO_NAVIGATION_CONTROLLER
@property (nonatomic, strong) GVNavigationViewController *navigationController;
#endif
@property (nonatomic, strong) GVMasterModelObject *masterModelObject;
@property (nonatomic, strong) GVMasterViewController *masterViewController;
#if THREAD_TABLE
@property (nonatomic, strong) GVThreadTableViewController *threadViewController;
#else
@property (nonatomic, strong) GVThreadViewController *threadViewController;
#endif
@property (nonatomic, strong) GVThreadBackgroundView *threadBackgroundView;

@property (nonatomic, strong) UIWindow *secondWindow;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) AVMutableComposition *cmp;
@property (nonatomic, strong) AVMutableVideoComposition *animComp;
@property (nonatomic, strong) UIViewController *renderController;
@property (nonatomic, strong) NSString *queryString;

@end

@implementation GVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    @autoreleasepool {
        // Override point for customization after application launch.
        
        // register user defaults
        NSDictionary *dict = @{GVSettingsSaveNewCapturesKey: [NSNumber numberWithBool:NO]};
        [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [Parse setApplicationId:@"FZ7JpVl57WUjip9m3i4RosNQQQLxNS5GkqwmXRaM" clientKey:@"OhBAef28W4Q224Q1ydfEGqL5Vbjkq7BBPwCwiWIu"];
#if CYCRIPT
        short portNum = 5432;
        NSLog(@"LINKING CYCRIPT -> %@:%@", [NSString getIPAddress], [NSNumber numberWithShort:portNum]);
        CYListenServer(portNum);
#endif
#if TESTFLIGHT
        [TestFlight setOptions:@{ @"disableInAppUpdates" : @NO }];
#else 
        [TestFlight setOptions:@{ @"disableInAppUpdates" : @YES }];
#endif

        [TestFlight takeOff:@"3e711276-3c6a-4818-8340-fe3b84af9a36"];

        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

        [self resetBadge];

        PFACL *defaultACL = [PFACL ACL];
        // Enable public read access by default, with any newly created PFObjects belonging to the current user
        [defaultACL setPublicReadAccess:YES];
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

        [self monitorReachability];

        NSLog(@"launchOptions %@", launchOptions);

        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

        if (YES || [PFUser currentUser]) {
            [self setupGvideoApp];
        } else {
            [self loggedOutNotification:nil];
        }

        [self.window makeKeyAndVisible];

        if (launchOptions[UIApplicationLaunchOptionsURLKey]) {
            [self urlHandler:launchOptions[UIApplicationLaunchOptionsURLKey]];
        } else if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
            [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
        }

        //[self urlHandler:[NSURL URLWithString:@"http://gvideoapp.com/thread/ET6shAUMGR"]];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(loggedInNotification:) name:GVLoggedInNotification object:nil];

        //[self logOut];
        
        [nc addObserver:self selector:@selector(logOutNotification:) name:GVLogOutNotification object:nil];
        [nc addObserver:self selector:@selector(loggedOutNotification:) name:GVLoggedOutNotification object:nil];
        [nc addObserver:self selector:@selector(clearCacheNotification:) name:GVClearCacheNotification object:nil];
        [nc addObserver:self selector:@selector(willAttemptToSaveThread:) name:GVNewThreadSaveNotification object:nil];
        [nc addObserver:self selector:@selector(didAttemptToSaveThread:) name:GVNewThreadDidSaveNotification object:nil];
        [nc addObserver:self selector:@selector(attemptToPushThread:) name:GVThreadPushAttemptNotification object:nil];
        [nc addObserver:self selector:@selector(deleteAccountNotification:) name:GVDeleteAccountNotification object:nil];
        [nc addObserver:self selector:@selector(aboutUsPadNotification:) name:GVAboutUsPadNotification object:nil];
        [nc addObserver:self selector:@selector(lowMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

        [nc addObserver:self selector:@selector(statusBarDidChange:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];

        [nc addObserver:self selector:@selector(willAttemptToDeleteThread:) name:GVDeleteWillDeleteThreadNotification object:nil];
        [nc addObserver:self selector:@selector(didAttemptToDeleteThread:) name:GVDeleteWillDeleteThreadNotification object:nil];
        [nc addObserver:self selector:@selector(playMovieAtContentURL:) name:GVPlayMovieNotification object:nil];
        [nc addObserver:self selector:@selector(startRecordingReaction:) name:GVReactionVideoNotification object:nil];
        [nc addObserver:self selector:@selector(internetRequestNotification:) name:GVInternetRequestNotification object:nil];
        [nc addObserver:self selector:@selector(newThreadRequestNotification:) name:GVNewThreadRequestNotification object:nil];
        [nc addObserver:self selector:@selector(saveMovieNotification:) name:GVSaveMovieNotification object:nil];
        [nc addObserver:self selector:@selector(inviteThreadNotification:) name:GVThreadInviteNotification object:nil];
        //[PFUser enableAutomaticUser];

        //[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

        [nc postNotificationName:GVRefreshDataNotification object:nil];

#if FAKE_EXTERNAL_DISPLAY
        [self checkForExistingScreenAndInitializeIfPresent];
#endif
        
        return YES;
    }
}

- (void)setupGvideoApp {
    self.masterModelObject = [[GVMasterModelObject alloc] init];
    //self.threadBackgroundView = [[GVThreadBackgroundView alloc] initWithFrame:CGRectZero];
#if SIMPLE_UI
    
    
    GVMainScrollViewController *scrollContainerController = [[GVMainScrollViewController alloc] initWithNibName:nil bundle:nil];
    
    
    self.window.rootViewController = scrollContainerController;
    
    
    
#else
    GVModalCameraContainerViewController *containerController = [[GVModalCameraContainerViewController alloc] initWithNibName:nil bundle:nil];

    //GfitHorizontalSlidingTabBarController *tabBarController = [[GfitHorizontalSlidingTabBarController alloc] initWithNibName:nil bundle:nil];
#if !NO_NAVIGATION_CONTROLLER

    GVNavigationViewController *navController = [[GVNavigationViewController alloc] initWithNavigationBarClass:nil toolbarClass:nil];
    //GVModalNavigationViewController *navController = [[GVModalNavigationViewController alloc] initWithNibName:nil bundle:nil];
#endif

//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        GVSplitViewController *splitController = [[GVSplitViewController alloc] initWithNibName:nil bundle:nil];
//
//        GVMasterViewController *masterViewController = [[GVMasterViewController alloc] initWithStyle:UITableViewStylePlain];
//        self.masterViewController = masterViewController;
//#if !NO_NAVIGATION_CONTROLLER
//        [navController pushViewController:masterViewController animated:NO];
//#endif
////        GVNavigationViewController *navController = [[GVNavigationViewController alloc] initWithRootViewController:masterViewController];
////        [GVTintColorUtility applyNavigationBarTintColor:navController.navigationBar];
//
//#if THREAD_TABLE
//        GVThreadTableViewController *threadViewController = [[GVThreadTableViewController alloc] initWithStyle:UITableViewStylePlain];
//#else
//        GVThreadViewController *threadViewController = [[GVThreadViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
//#endif
//
//        //GVThreadDetailNavigationController *threadNavController = [[GVThreadDetailNavigationController alloc] initWithRootViewController:threadViewController];
//        
//        splitController.delegate = threadViewController;
//        self.threadViewController = threadViewController;
//#if !NO_NAVIGATION_CONTROLLER
//        [splitController setViewControllers:@[navController, threadNavController]];
//#endif
//        containerController.masterViewController = masterViewController;
//        containerController.splitViewControllerSetup = splitController;
//        //containerController.splitTableViewController.bottomViewController = splitController;
//        self.window.rootViewController = containerController;
//        //[GVTintColorUtility applyNavigationBarTintColor:threadNavController.navigationBar];
//        self.splitController = splitController;
//
//    } else {
        //#if SPLIT_TABLE_TEST




        //#else
        GVMasterViewController *masterViewController = [[GVMasterViewController alloc] initWithStyle:UITableViewStyleGrouped];
        //GVCollectionViewController *masterViewController = [[GVCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
        self.masterViewController = masterViewController;
#if !NO_NAVIGATION_CONTROLLER
        //GVNavigationViewController *navController = [[GVNavigationViewController alloc] initWithNavigationBarClass:nil toolbarClass:nil];
        [navController pushViewController:masterViewController animated:NO];
        [GVTintColorUtility applyNavigationBarTintColor:navController.navigationBar];
        //self.window.rootViewController = navController;
        self.navigationController = navController;
        containerController.masterViewController = self.masterViewController;
        containerController.bottomViewControllerSetup = self.navigationController;
#else
        containerController.masterViewController = self.masterViewController;
        containerController.bottomViewControllerSetup = self.masterViewController;
#endif
        //[containerController setupBottomViewController:self.navigationController];
        //containerController.splitTableViewController.bottomViewController = navController;
        //[containerController setupBottomViewController:navController];
        self.window.rootViewController = containerController;
    

        //#endif
//    }

    
    //self.masterViewController.collectionView.backgroundView = self.threadBackgroundView;
#if THREAD_TABLE
    self.threadViewController.tableView.backgroundView = self.threadBackgroundView;
#else
    self.threadViewController.collectionView.backgroundView = self.threadBackgroundView;
#endif
    self.masterViewController.modelObject = self.masterModelObject;
    self.threadViewController.modelObject = self.masterModelObject;
    self.masterModelObject.masterViewController = self.masterViewController;
    //self.masterModelObject.threadViewController = self.threadViewController;
    
#endif
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    
}

- (void)newThreadRequestNotification:(NSNotification*)notif {
    if (self.isParseReachable) {
        NSDictionary *dict = [notif userInfo];
        NSBlockOperation *op = dict[@"op"];
        [op start];
    } else {
        // save the video somehow..
        NSDictionary *dict = [notif userInfo];
        NSBlockOperation *op = dict[@"err"];
        [op start];
    }
}

- (void)internetRequestNotification:(NSNotification*)notif {
    if (self.isParseReachable) {
        NSDictionary *dict = [notif userInfo];
        NSBlockOperation *op = dict[@"op"];
        [op start];
    } else {
        NSDictionary *dict = [notif userInfo];
        NSNumber *noError = [dict objectForKey:@"noError"];
        [self alertNoInternetConnection];
    }
}

- (void)startRecordingReaction:(NSNotification*)notif {
    //if (false) {

    // just play the damn video
//    self.selectedIndexPath = indexPath;
    // we need to record the reaction sofb

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self.isParseReachable) {
            NSDictionary *info = [notif userInfo];
            NSString *url = info[@"URL"];
            NSString *activityId = info[@"activityId"];
            NSString *threadId = info[@"threadId"];
            NSNumber *shouldRecord = info[@"shouldRecord"];
            GVReactionVideoViewController *reactionVC = [[GVReactionVideoViewController alloc] initWithContentURL:url threadId:threadId activityId:activityId shouldRecord:shouldRecord];
            
            //[[NSNotificationCenter defaultCenter] removeObserver:reactionVC.movieViewController name:MPMoviePlayerPlaybackDidFinishNotification object:reactionVC.movieViewController.moviePlayer];
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:reactionVC.movieViewController.moviePlayer];
            [self.window.rootViewController presentViewController:reactionVC animated:YES completion:nil];
        } else {
            [self alertNoInternetConnection];
        }
    });
}

- (void)alertNoInternetConnection {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"There was an error loading the data." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)playMovieAtContentURL:(NSNotification*)notif {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        NSString *url = [[notif userInfo] objectForKey:@"URL"];
        if ([url respondsToSelector:@selector(length)] && [url performSelector:@selector(length)]) {
            if (self.isParseReachable) {
                GVMoviePlayerViewController *moviePlayer = [[GVMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
                moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleNone;
                [moviePlayer.moviePlayer play];
                moviePlayer.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
                [[NSNotificationCenter defaultCenter] removeObserver:moviePlayer name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer.moviePlayer];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer.moviePlayer];
                [self.window.rootViewController presentViewController:moviePlayer animated:YES completion:nil];
            } else {
                [self alertNoInternetConnection];
            }
        }
    });
}

#if FAKE_EXTERNAL_DISPLAY

- (void)setupFakeInitialContent {
    self.masterModelObject = [[GVMasterModelObject alloc] init];
    //self.threadBackgroundView = [[GVThreadBackgroundView alloc] initWithFrame:CGRectZero];
    
    GVModalCameraContainerViewController *containerController = [[GVModalCameraContainerViewController alloc] initWithNibName:nil bundle:nil];
    
    GVMasterViewController *masterViewController = [[GVMasterViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //GVCollectionViewController *masterViewController = [[GVCollectionViewController alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
    self.masterViewController = masterViewController;
#if !NO_NAVIGATION_CONTROLLER
    //GVNavigationViewController *navController = [[GVNavigationViewController alloc] initWithNavigationBarClass:nil toolbarClass:nil];
    [navController pushViewController:masterViewController animated:NO];
    [GVTintColorUtility applyNavigationBarTintColor:navController.navigationBar];
    //self.window.rootViewController = navController;
    self.navigationController = navController;
    containerController.masterViewController = self.masterViewController;
    containerController.bottomViewControllerSetup = self.navigationController;
#else
    containerController.masterViewController = self.masterViewController;
    containerController.bottomViewControllerSetup = self.masterViewController;
#endif
    //[containerController setupBottomViewController:self.navigationController];
    //containerController.splitTableViewController.bottomViewController = navController;
    //[containerController setupBottomViewController:navController];
    self.secondWindow.rootViewController = containerController;
    //#endif
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    //self.masterViewController.collectionView.backgroundView = self.threadBackgroundView;
#if THREAD_TABLE
    self.threadViewController.tableView.backgroundView = self.threadBackgroundView;
#else
    self.threadViewController.collectionView.backgroundView = self.threadBackgroundView;
#endif
    self.masterViewController.modelObject = self.masterModelObject;
    self.threadViewController.modelObject = self.masterModelObject;
    self.masterModelObject.masterViewController = self.masterViewController;
    
    
#define FAKE_RENDER_TO_FILE 0
    
#if FAKE_RENDER_TO_FILE
    NSURL *url = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"movie.mov"];
    
    CGSize videoSize = CGSizeMake(1920, 1080);
    
    
    //CALayer *aLayer = containerController.view.layer;
    self.renderController = containerController;
    
    //    CALayer *aLayer = [CALayer layer];
    //    //aLayer.contents = (id) [UIImage imageNamed:@"test.png"].CGImage;
    //    aLayer.frame = CGRectMake(0, 0, 480, 320);
    //
    /* only use with videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer
     CALayer *parentLayer = [CALayer layer];
     CALayer *videoLayer = [CALayer layer];
     parentLayer.frame = CGRectMake(0, 0, 480, 320);
     videoLayer.frame = CGRectMake(0, 0, 480, 320);
     [parentLayer addSublayer:videoLayer];
     [parentLayer addSublayer:aLayer];
     */
    
    
    //
    AVURLAsset* videourl = [AVURLAsset URLAssetWithURL:url options:nil];
    
    
    
    
    AVURLAsset* videoAsset = videourl;
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //If you need audio as well add the Asset Track for audio here
    
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:clipVideoTrack atTime:kCMTimeZero error:nil];
    
    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    
    //
    //    With just this code you would be able to export the video but we want to add the layer with the watermark first.
    //    Please note that some code may seem redundant but it is necessary for everything to work.
    //        First we create the layer with the watermark image:
    //
    
    UIImage *myImage = [UIImage imageNamed:@"Default"];
    CALayer *aLayer = self.renderController.view.layer;
    [self.renderController viewWillAppear:YES];
    [self.renderController viewDidAppear:YES];
    [self.renderController viewWillLayoutSubviews];
    //aLayer.contents = (id)myImage.CGImage;
    aLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height); //Needed for proper display. We are using the app icon (57x57). If you use 0,0 you will not see it
    aLayer.opacity = 1; //Feel free to alter the alpha here
    
    //    If you want a text instead of image here is the code
    //
    //    CATextLayer *titleLayer = [CATextLayer layer];
    //    titleLayer.string = @"Text goes here";
    //    titleLayer.font = @"Helvetica";
    //    titleLayer.fontSize = videoSize.height / 6;
    //    //?? titleLayer.shadowOpacity = 0.5;
    //    titleLayer.alignmentMode = kCAAlignmentCenter;
    //    titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 6); //You may need to adjust this for proper display
    //
    //    The following code sorts the layer in proper order:
    //
    
    //CGSize videoSize = CGSizeMake(1920, 1080);
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];
    //[parentLayer addSublayer:titleLayer]; //ONLY IF WE ADDED TEXT
    //
    //    Now we are creating the composition and add the instructions to insert the layer:
    //
    //
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    /// instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    //    And now we are ready to export:
    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];//AVAssetExportPresetPassthrough
        self.exportSession.videoComposition = videoComp;
        
        NSString* videoName = @"mynewwatermarkedvideo.mov";
        
        NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
        NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
        }
        
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        self.exportSession.outputURL = exportUrl;
        self.exportSession.shouldOptimizeForNetworkUse = YES;
        
        //[strRecordedFilename setString: exportPath];
        
        @weakify(self);
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
            @strongify(self);
            switch (self.exportSession.status) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"exporting failed %@", [self.exportSession error]);
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"exporting completed");
                    //UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector  (video:didFinishSavingWithError:contextInfo:), NULL);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"export cancelled");
                    break;
            }
        }];
        
        
    });
    
    
    
    
    
    
    
    
    
    //    AVMutableComposition *videoComposition = [AVMutableComposition composition];
    //    NSError *error;
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //
    //AVMutableCompositionTrack *compositionVideoTrack = [videoComposition  addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //AVMutableCompositionTrack *compositionAudioTrack = [videoComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    //AVAssetTrack *clipVideoTrack = [[videourl tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [videourl duration])  ofTrack:clipVideoTrack atTime:kCMTimeZero error:&error];
    //if (error) {
    //    DLogObject(error);
    //}
    //
    //    AVAssetTrack *clipAudioTrack = [[url tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    //    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [url duration])  ofTrack:clipAudioTrack atTime:kCMTimeZero error:&error];
    
    //    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    //
    //    videoComp.renderSize = videoSize;
    //    videoComp.frameDuration = CMTimeMakeWithSeconds(10, 30);
    //    //videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:aLayer inLayer:parentLayer];
    //
    //    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithAdditionalLayer:aLayer asTrackID:2];
    //
    //
    //    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    //
    //    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition
    //                                                          videoComposition];
    //
    //    AVAssetTrack *firstVideoAssetTrack = [[videourl tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    ////    AVAssetTrack *secondVideoAssetTrack = [[secondVideoAsset
    ////                                            tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //
    ////    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,
    ////                                                           secondVideoAssetTrack.timeRange.duration) ofTrack:secondVideoAssetTrack
    ////                                    atTime:firstVideoAssetTrack.timeRange.duration error:nil];
    //
    //    // Create the video composition track.
    //    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition
    //                                                               addMutableTrackWithMediaType:AVMediaTypeVideo
    //                                                               preferredTrackID:kCMPersistentTrackID_Invalid];
    //    NSError * __autoreleasing timeRangeError = nil;
    //    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration) ofTrack:firstVideoAssetTrack atTime:kCMTimeZero error:&timeRangeError];
    //    AVAssetTrack *aTrack = [[mutableComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //
    //
    //    //[mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, aTrack.timeRange.duration) ofTrack:aTrack atTime:kCMTimeZero error:&timeRangeError];
    //    if (timeRangeError) {
    //        DLogObject(timeRangeError);
    //    }
    //
    //    AVMutableVideoCompositionInstruction *mutableVideoCompositionInstruction =
    //    [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    //    mutableVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,
    //                                                                   CMTimeMakeWithSeconds(10, 30));
    //    mutableVideoCompositionInstruction.backgroundColor = [[UIColor redColor] CGColor];
    //
    //    CALayer *watermarkLayer = [CALayer layer];
    //    watermarkLayer.contents = (id)[UIImage imageNamed:@"Default"].CGImage;
    //    CALayer *parentLayer = [CALayer layer];
    //    CALayer *videoLayer = [CALayer layer];
    //    mutableVideoComposition.renderSize = videoSize;
    //    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    //    parentLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width,
    //                                   mutableVideoComposition.renderSize.height);
    //    videoLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width,
    //                                  mutableVideoComposition.renderSize.height);
    //    [parentLayer addSublayer:videoLayer];
    //    watermarkLayer.position = CGPointMake(mutableVideoComposition.renderSize.width/2,
    //                                          mutableVideoComposition.renderSize.height/4);
    //    [parentLayer addSublayer:watermarkLayer];
    //    mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
    //                                             videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
    //                                             inLayer:parentLayer];
    //    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mutableCompositionVideoTrack];
    //
    //    mutableVideoCompositionInstruction.layerInstructions = @[videoLayerInstruction];
    //    mutableVideoComposition.instructions = @[mutableVideoCompositionInstruction];
    //
    //
    
    /// instruction
    //AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    //instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(10, 30) );
    //AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    //[layerInstruction setTrackID:2];
    //[layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
    //instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    //videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    
    
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //
    //        NSFileManager *fileManager = [NSFileManager defaultManager];
    //        NSError *error = nil;
    //        /// outputs
    //        NSString *filePath = nil;
    //        filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //        filePath = [filePath stringByAppendingPathComponent:@"temp.mov"];
    //        NSLog(@"exporting to: %@", filePath);
    //        if ([fileManager fileExistsAtPath:filePath]) {
    //            BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    //            if (!success) NSLog(@"FM error: %@", [error localizedDescription]);
    //        }
    //
    //        /// exporting
    //        AVAssetExportSession *exporter;
    //        exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    //        exporter.videoComposition = mutableVideoComposition;
    //        exporter.outputURL=[NSURL fileURLWithPath:filePath];
    //        exporter.outputFileType=AVFileTypeQuickTimeMovie;
    //        //exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(10, 30));
    //        self.exportSession = exporter;
    //
    //        [exporter exportAsynchronouslyWithCompletionHandler:^(void){
    //            switch (exporter.status) {
    //                case AVAssetExportSessionStatusFailed:
    //                    NSLog(@"exporting failed %@", [exporter error]);
    //                    break;
    //                case AVAssetExportSessionStatusCompleted:
    //                    NSLog(@"exporting completed");
    //                    //UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector  (video:didFinishSavingWithError:contextInfo:), NULL);
    //                    break;
    //                case AVAssetExportSessionStatusCancelled:
    //                    NSLog(@"export cancelled");
    //                    break;
    //            }
    //
    //
    //
    //        }];
    //
    //
    //    });
    //
    //CALayer *aLayer = [CALayer layer];
    //aLayer.frame = CGRectMake(5, 0, 320, 480);
    //aLayer.bounds = CGRectMake(5, 0, 320, 480);
    //aLayer.contents = (id) [UIImage imageNamed:@"boobs.PNG"].CGImage;
    //aLayer.opacity = 0.5;
    //aLayer.backgroundColor = [UIColor clearColor].CGColor;
    //NSURL *url = [NSURL fileURLWithPath:[urlsOfVideos objectAtIndex:self.pageControl.currentPage]];
    //    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    //    self.cmp = [AVMutableComposition composition];
    //    CMTimeRange duration = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(10, 30));
    // AVMutableCompositionTrack *trackA = [self.cmp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //AVAssetTrack *sourceVideoTrack = [[self.cmp tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //NSError *insertTrackError = nil;
    //[trackA insertTimeRange:duration ofTrack:sourceVideoTrack atTime:kCMTimeZero error:&insertTrackError];
    //DLogObject(insertTrackError);
    
    //    AVMutableCompositionTrack *aTrack = [[AVMutableCompositionTrack alloc] init];
    //
    //    AVMutableVideoComposition * animComp = [AVMutableVideoComposition videoComposition];
    //    animComp.renderSize = videoSize;
    //    animComp.frameDuration = CMTimeMake(1,30);
    //    CALayer *parentLayer = [CALayer layer];
    //    CALayer *videoLayer = [CALayer layer];
    //    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    //    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    //    [parentLayer addSublayer:videoLayer];
    //    //[parentLayer addSublayer:aLayer];
    //    self.animComp = animComp;
    //    CMPersistentTrackID trackId = [self.cmp unusedTrackID];
    //    animComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithAdditionalLayer:parentLayer asTrackID:trackId];
    //
    //    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    //    instruction.timeRange = duration;
    //    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:trackA];
    //    //[layerInstruction setTrackID:trackId];
    //    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
    //    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    //    animComp.instructions = [NSArray arrayWithObject:instruction];
    //
    //    [self exportMovie:self];
    // start recording as well
    //    AVMutableComposition *composition = [AVMutableComposition composition];
    //    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    //    AVMutableCompositionTrack *mutableTrack = [[AVMutableCompositionTrack alloc] init];
    //    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
    //    NSArray *array = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    //    AVAssetTrack *clipVideoTrack = nil;
    //    if ([array count] > 0) {
    //         [array objectAtIndex:0];
    //    } else {
    //        clipVideoTrack = mutableTrack;
    //    }
    //        //
    
    ////
    //    CMTime titleDuration = CMTimeMakeWithSeconds(5, 600);
    //    CMTimeRange titleRange = CMTimeRangeMake(kCMTimeZero, titleDuration);
    //
    //    [compositionVideoTrack insertTimeRange:titleRange ofTrack:nil atTime:kCMTimeZero error:nil];
    //    [compositionVideoTrack insertTimeRange:timeRange ofTrack:clipVideoTrack atTime:titleDuration error:nil];
    //
    //    //compositionVideoTrack.preferredTransform = clipVideoTrack.preferredTransform;
    //
    //    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    //    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    //    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);
    //    NSArray *arr = [composition tracksWithMediaType:AVMediaTypeVideo];
    //    AVAssetTrack *videoTrack = nil;
    //    if ([arr count] > 0) {
    //        [arr objectAtIndex:0];
    //    }
    //    AVMutableVideoCompositionLayerInstruction *passThroughLayer =[AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    //    passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
    //    videoComposition.instructions = [NSArray arrayWithObject:passThroughInstruction];
    //    videoComposition.frameDuration = CMTimeMake(1, 30);
    //    videoComposition.renderSize = videoSize;
    //    videoComposition.renderScale = 1.0;
    
    // add calayer
    //    CALayer *parentLayer = [CALayer layer];
    //    CALayer *videoLayer = [CALayer layer];
    //    CALayer *animationLayer = containerController.view.layer;
    //
    //
    //    parentLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height);
    //    parentLayer.anchorPoint =  CGPointMake(0, 0);
    //    parentLayer.position = CGPointMake(0, 0);
    //
    //    videoLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height);
    //    [parentLayer addSublayer:videoLayer];
    //    videoLayer.anchorPoint =  CGPointMake(0.5, 0.5);
    //    videoLayer.position = CGPointMake(CGRectGetMidX(parentLayer.bounds), CGRectGetMidY(parentLayer.bounds));
    //    [parentLayer addSublayer:animationLayer];
    //    animationLayer.anchorPoint =  CGPointMake(0.5, 0.5);
    //    animationLayer.position = CGPointMake(CGRectGetMidX(parentLayer.bounds), CGRectGetMidY(parentLayer.bounds));
    //    CMPersistentTrackID layerTrackId = [videoAsset unusedTrackID];
    //    passThroughLayer.trackID = [videoAsset unusedTrackID];
    //    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithAdditionalLayer:animationLayer asTrackID:[videoAsset unusedTrackID]];
    //
    //    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetPassthrough];
    //    exportSession.videoComposition = videoComposition;
    //
    //    //NSURL *segmentFileURL = url;
    //    exportSession.outputFileType = @"com.apple.quicktime-movie";
    //    exportSession.outputURL = url;
    //    self.exportSession = exportSession;
    //
    //    [exportSession exportAsynchronouslyWithCompletionHandler:^{
    //        switch ([exportSession status]) {
    //            case AVAssetExportSessionStatusFailed:
    //                DLog(@"Export failed: %@", [exportSession error]);
    //                break;
    //            case AVAssetExportSessionStatusCancelled:
    //                DLog(@"Export canceled");
    //                break;
    //            case AVAssetExportSessionStatusCompleted:
    //                DLog(@"Export done");
    //                break;
    //        }
    //    }];
#endif
}

//-(IBAction)exportMovie:(id)sender {
//    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *tempPath = [docPaths objectAtIndex:0];
//    NSLog(@"Temp Path: %@",tempPath);
//
//    NSString *fileName = [NSString stringWithFormat:@"%@/output-anot.MOV",tempPath];
//    NSFileManager *fileManager = [NSFileManager defaultManager] ;
//    if([fileManager fileExistsAtPath:fileName ]){
//        //NSError *ferror = nil ;
//        //BOOL success = [fileManager removeItemAtPath:fileName error:&ferror];
//    }
//
//    NSURL *exportURL = [NSURL fileURLWithPath:fileName];
//
//    [AVAssetExportSession determineCompatibilityOfExportPreset:AVAssetExportPresetHighestQuality withAsset:self.cmp outputFileType:@"mov" completionHandler:^(BOOL compatible) {
//        DLogBOOL(compatible);
//    }];
//    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:self.cmp presetName:AVAssetExportPreset1920x1080];
//    exporter.outputURL = exportURL;
//    exporter.videoComposition = self.animComp;
//    exporter.outputFileType= AVFileTypeQuickTimeMovie;
//    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
//        switch (exporter.status) {
//            case AVAssetExportSessionStatusFailed:{
//                DLogObject([exporter metadata]);
//                DLog(@"asset export failed %@", [exporter error]);
//                break;
//            }
//            case AVAssetExportSessionStatusCompleted:{
//                DLogFunctionLine();
//                break;
//            }
//            case AVAssetExportSessionStatusCancelled: {
//                DLogFunctionLine();
//            }
//            case AVAssetExportSessionStatusUnknown: {
//                DLogFunctionLine();
//            }
//            case AVAssetExportSessionStatusWaiting: {
//                DLogFunctionLine();
//            }
//            default:
//                break;
//        } 
//    }];
//}

- (void)checkForExistingScreenAndInitializeIfPresent
{
    if ([[UIScreen screens] count] > 1)
    {
        // Get the screen object that represents the external display.
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        // Get the screen's bounds so that you can create a window of the correct size.
        CGRect screenBounds = secondScreen.bounds;
        
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = secondScreen;
        
        // Set up initial content to display...
        [self setupFakeInitialContent];
        // Show the window.
        self.secondWindow.hidden = NO;
    }
}
#endif

-(void)videoFinished:(NSNotification*)aNotification{
//    //int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
#if TEST_MOVIE_PLAYER
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
#endif
//    if (value == MPMovieFinishReasonUserExited) {
//
//    }
}

- (void)statusBarDidChange:(NSNotification*)notif {
    //NSLog(@" status bar did change %@", NSStringFromCGRect([UIApplication sharedApplication].statusBarFrame));
}

- (void)lowMemoryWarning:(NSNotification*)notif {
    [TestFlight passCheckpoint:@"Low Memory Warning"];
}

- (void)deleteAccountNotification:(NSNotification*)notif {
    [self deleteAccount];
}

- (void)attemptToPushThread:(NSNotification*)notif {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        NSString *threadId = [[notif userInfo] objectForKey:@"threadId"];
        [TestFlight passCheckpoint:@"Select Thread"];
//        if (![self.threadViewController.threadId isEqualToString:threadId]) {
//    #if THREAD_TABLE
//            GVThreadTableViewController *threadVC = [[GVThreadTableViewController alloc] initWithStyle:UITableViewStylePlain];
//            threadVC.threadId = threadId;
//            self.threadViewController = threadVC;
//            self.masterModelObject.threadViewController = self.threadViewController;
//            self.threadViewController.modelObject = self.masterModelObject;
//    #else
//            GVThreadViewController *threadVC = [[GVThreadViewController alloc] initWithCollectionViewLayout:[THSpringyFlowLayout new]];
//            threadVC.threadId = threadId;
//            self.threadViewController = threadVC;
//            self.threadViewController.collectionView.backgroundView = self.threadBackgroundView;
//            self.threadViewController.modelObject = self.masterModelObject;
//            self.masterModelObject.threadViewController = self.threadViewController;
//        //self.threadViewController.shouldScrollToOffsetAtBottom = YES;
//
//            self.threadViewController.shouldScrollToOffsetAtBottom = YES;
//
//            //[self.threadViewController refreshData:nil];
//    #endif
//            // preload if possible
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                @strongify(self);
//                [self.masterModelObject threadViewControllerDataAtIndexPath:nil thread:threadId];
//            });
//        } else {
//            [self.threadViewController refreshData:nil];
//        }
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//            [[self.splitController viewControllers][1] setViewControllers:@[self.threadViewController]];
//        } else {
//            // @todo fix this if necessary
//#if !NO_NAVIGATION_CONTROLLER
//            [self.navigationController popToRootViewControllerAnimated:YES];
//            [self.navigationController pushViewController:self.threadViewController animated:YES];
//#endif
//        }
    });
}

- (void)inviteThreadNotification:(NSNotification*)notif {
    NSDictionary *info = [notif userInfo];

    NSString *threadId = info[@"threadId"];
    NSString *path = [NSString stringWithFormat:@"http://gvideoapp.com/t/%@", threadId];
    NSURL *threadURL = [NSURL URLWithString:path];
    if (threadId && ![threadId isKindOfClass:[NSNull class]] && [threadId length] > 0) {
        [[UIPasteboard generalPasteboard] setString:path];
    }

    //[[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadDidSaveNotification object:nil userInfo:@{@"threadURL": threadURL}];

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        NSURL *url = nil;
        //NSURL *threadURL = [[notif userInfo] objectForKey:@"threadURL"];
        if (threadURL && ![threadId isKindOfClass:[NSNull class]] && [threadId length] > 0) {
            url = threadURL;
        } else {
            url = [NSURL URLWithString:@"http://www.gvideoapp.com"];
        }
        
        
        GVInviteActivityProvider *activityProvider = [[GVInviteActivityProvider alloc] initWithPlaceholderItem:[NSNull null]];
        NSArray *threadData = @[activityProvider, url];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:threadData applicationActivities:nil];
        
        @weakify(activityViewController);
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed){
            @strongify(self);
            [TestFlight passCheckpoint:@"Shared Link Action"];
            NSLog(@"activity type completed: %@", [NSNumber numberWithBool:completed]);
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            activityViewController_weak_.completionHandler = nil;
            NSLog(@"activityType: %@", activityType);
            
            
        };
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.splitController.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        [self.window.rootViewController presentViewController:activityViewController animated:YES completion:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.progressHUD hide:YES];
            self.progressHUD = nil;
        });
    });
}

- (void)saveMovieNotification:(NSNotification*)notif {
    @autoreleasepool {
        @weakify(self);
        NSString *contentURL = [notif userInfo][@"contentURL"];
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){



            //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.contentURL]];

            //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"filename"];



            // save to temporary directory
            NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
            //NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:outputPath]) {
                NSError *error;
                if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
                    //Error - handle if requried
                }
            }

            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            AFHTTPRequestOperation *op = [manager GET:contentURL
                                           parameters:nil
                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                  //NSLog(@"successful download to %@", path);
                                                  if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputPath)) {
                                                      UISaveVideoAtPathToSavedPhotosAlbum(outputPath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                                                  }

                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Error: %@", error);
                                                  [self video:nil didFinishSavingWithError:nil contextInfo:nil];
                                              }];
            op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPath append:NO];
            
            //NSString *moviePath = [outputURL relativeString];
        });
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^(){
        @strongify(self);
        [self.progressHUD hide:YES];
        self.progressHUD = nil;
        // do you main UI thread stuff here
    });
}

- (void)willAttemptToDeleteThread:(NSNotification*)notif {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    });
}

- (void)didAttemptToDeleteThread:(NSNotification*)notif {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.progressHUD hide:YES];
        self.progressHUD = nil;
    });
}

- (void)willAttemptToSaveThread:(NSNotification*)notif {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    });
}

- (void)didAttemptToSaveThread:(NSNotification*)notif {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        NSURL *threadURL = [[notif userInfo] objectForKey:@"threadURL"];
        if (threadURL) {
            
            GVShareActivityProvider *activityProvider = [[GVShareActivityProvider alloc] initWithPlaceholderItem:[NSNull null]];
            NSArray *threadData = @[activityProvider, threadURL];
            
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:threadData applicationActivities:nil];

            @weakify(activityViewController);
            activityViewController.completionHandler = ^(NSString *activityType, BOOL completed){
                [TestFlight passCheckpoint:@"Shared Link Action"];
                @strongify(self);
                //[self.masterViewController dismissViewControllerAnimated:YES completion:nil];
                [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                activityViewController_weak_.completionHandler = nil;
                NSLog(@"activityType: %@", activityType);
            };
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                self.splitController.edgesForExtendedLayout = UIRectEdgeNone;
            }
            [self.window.rootViewController presentViewController:activityViewController animated:NO completion:nil];
            //[self.masterViewController presentViewController:activityViewController animated:YES completion:nil];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.progressHUD hide:YES];
            self.progressHUD = nil;
        });
    });
}

- (void)resetBadge {
    if ([PFInstallation currentInstallation].badge != 0) {
        [PFInstallation currentInstallation].badge = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }
}

- (void)registerForPushNotifications {
    if ([PFUser currentUser]) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            // logout
            //[PFUser logOut];
            if (self.currentOperation && !self.currentOperation.isExecuting) {
                [self.currentOperation start];
            }
            break;
        default:
            break;
    }
}

- (void)clearCacheNotification:(NSNotification*)notif {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    });
    [self clearCache];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.progressHUD hide:YES];
        self.progressHUD = nil;
    });

}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];

    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];

        if ([self isParseReachable] && [PFUser currentUser]) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
            //[self.masterViewController loadObjects];
        }
    };

    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };

    [hostReach startNotifier];
}

- (void)clearCache {
    [self.masterModelObject clearCaches];
    [[GVCache sharedCache] clear];
    [[GVDiskCache diskCache] clear];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [GVSettingsUtility setLastUpdatedDate:nil];
    [PFQuery clearAllCachedResults];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *cachePath = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:cachePath
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];

    NSString *directory = [cachePath absoluteString];
    if (cachePath) {
        __autoreleasing NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
            NSString *itemPath = [NSString stringWithFormat:@"%@%@", directory, file];
            BOOL success = [fm removeItemAtPath:itemPath error:&error];
            if (!success || error) {
                // it failed.
                NSLog(@"error deleting cached item:%@ error:%@", itemPath, error);
            }
        }
//        for (NSURL *path in contents) {
//            __autoreleasing NSError *error = nil;
//            DLogObject([path absoluteString]);
//            BOOL success = [fileManager removeItemAtPath:[path absoluteString] error:&error];
//            if (error) {
//                NSLog(@"failure to delete certain item:%@  %i", path, success);
//            }
//        }
    }


}

- (void)loggedInNotification:(NSNotification*)notif {

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self setupGvideoApp];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
//        [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
//            @strongify(self);
//            //[self.masterViewController playCoffeeSound];
//            [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
//        }];
    });



    // handle any new threads
    NSArray *threadsReceived = [GVSettingsUtility threadsReceivedWithoutLogin];
    //BOOL shouldRefresh = ([threadsReceived count] > 0);
    for (NSInteger i = 0;i < [threadsReceived count];i++) {
        [self handleNewThread:[threadsReceived objectAtIndex:i]];
    }
    [GVSettingsUtility clearThreadsReceived];
    //if (shouldRefresh) {
    //}

    // save the current installation right now or we lose it forever...
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kGVInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //[GVTwitterAuthUtility updateProfileImageForCurrentUserWithCompletion:nil];
            [self registerForPushNotifications];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVModelHasSuccessfullyInstalledDevice object:nil];
        } else {
            NSLog(@"there was an error saving installation, will try on app restart... %@", error);
        }
    }];

    // lets work with the users photo profile picture

}

- (void)logOutNotification:(NSNotification*)notif {
    [self logOut];
}

- (void)deleteAccount {
    @weakify(self);
    [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        @strongify(self);
        if (succeeded) {
            [self logOut];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Account Error" message:@"There was an error deleting your account. Please Try Again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            });
        }
    }];

}

- (void)logOutCompletionBlock:(NSBlockOperation*)block {
    // clear cache
    [self clearCache];
    
    // clear NSUserDefaults
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    @weakify(self);
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kGVInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
        if (succeeded) {
            @strongify(self);
            NSLog(@"successful update of installation");
            // Log out
            [PFUser logOut];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GVLoggedOutNotification object:nil];
        
            if (block) {
                [block start];
            }
        } else {
            NSLog(@" installation error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log out error" message:@"There was an error logging out. Please Try Again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    // clear out cached data, view controllers, etc
    //[self.navController popToRootViewControllerAnimated:NO];
    
    //[self presentLoginViewController];
    
    //self.homeViewController = nil;
    //self.activityViewController = nil;
}

- (void)logOut {
    [self logOutCompletionBlock:nil];
}

- (void)aboutUsPadNotification:(NSNotification*)notif {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:nil];
        UIViewController *initialVC = [storyboard instantiateInitialViewController];
        [self.window.rootViewController presentViewController:initialVC animated:YES completion:nil];
    });
}

- (void)loggedOutNotification:(NSNotification*)notif {
    
    GVWelcomeSignupViewController *loginViewController = [[GVWelcomeSignupViewController alloc] initWithNibName:nil bundle:nil];
    @weakify(self);
    if (self.window.rootViewController) {

        void (^completionBlock)() = ^void() {
            [UIView transitionFromView:self.window.rootViewController.view
                                toView:loginViewController.view
                              duration:1.0
                               options:UIViewAnimationOptionCurveLinear
                            completion:^(BOOL finished) {
                                if (finished) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        @strongify(self);
                                        
                                        self.masterModelObject = nil;
                                        self.masterViewController = nil;
                                        self.window.rootViewController = nil;
                                        self.window.rootViewController = loginViewController;
                                    });
                                }
                            }];
        };
            
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (self.window.rootViewController.presentedViewController) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completionBlock();
                });
                //[self.window.rootViewController dismissViewControllerAnimated:YES completion:completionBlock];
            } else {
                completionBlock();
            }
        });
        
    } else {
        self.window.rootViewController = loginViewController;
    }

    
    
    
}

- (void)handleNewThread:(NSString*)objectId {
    PFObject *thread = [PFObject objectWithoutDataWithClassName:kGVThreadClassKey objectId:objectId];

    [thread fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [thread addUniqueObjectsFromArray:@[[PFUser currentUser]] forKey:kGVThreadUsersKey];
            [thread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // should refresh data
                    [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
                } else {
                    NSLog(@"failure adding user to thread %@", error);
                }
            }];
        } else {
            NSLog(@" error adding new thread %@", error);
        }
    }];
}

- (BOOL)urlHandler:(NSURL*)url {
    DLogObject(url);
     NSArray *pathComps = [url pathComponents];
    if ([[url host] isEqualToString:@"gvideoapp.com"]) {
        if ([pathComps count] > 2 && [[[url pathComponents] objectAtIndex:1] isEqualToString:@"t"]) {
            NSString *threadObjectId = [pathComps objectAtIndex:2];
            if (![PFUser currentUser]) {
                // not currently logged in, lets save this info right now and get back to it on loggedIn
                [GVSettingsUtility addThreadReceivedWithoutLogin:threadObjectId];
            } else {
                // send out some sort of notification that you otherwise would send later i guess...
                [self handleNewThread:threadObjectId];
            }

        }
        return YES;
    } else if ([[url scheme] isEqualToString:@"gvideoapp"] && [pathComps count] > 1) {
        NSString *queryString = [pathComps objectAtIndex:1 ];
        // handle an auth challenge
        //NSArray *arr = [queryString componentsSeparatedByString:@"?a="];
        NSString *querySession = queryString;
        if ([PFUser currentUser]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Confirmation" message:@"Would you like to log out of the current account and login to the account you open the app with?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
            self.queryString = queryString;
            [alert show];
            self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
                @weakify(self);
                [self logOutCompletionBlock:[NSBlockOperation blockOperationWithBlock:^{
                    @strongify(self);
                    [PFUser becomeInBackground:self.queryString block:^(PFUser *newUser, NSError *error) {
                        
                        if ([PFUser currentUser]) {
                            
                            NSLog(@"success at logging in");
                            [[NSNotificationCenter defaultCenter] postNotificationName:GVLoggedInNotification object:nil];
                            //[hud hide:YES];
                            return;
                            
                        } else {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failure" message:@"There was a failure authenticating your account. Please try again or contact us for support." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                            [alert show];
                            
                            //NSLog(@"failure trying to login %@", logInError);
                            //[hud hide:YES];
                            return;
                        }
                    }];
                }]];
            }];
            alert.delegate = self;
        }
        [PFUser becomeInBackground:querySession block:^(PFUser *newUser, NSError *error) {
            if ([PFUser currentUser]) {
                
                NSLog(@"success at logging in");
                [[NSNotificationCenter defaultCenter] postNotificationName:GVLoggedInNotification object:nil];
                //[hud hide:YES];
                return;
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failure" message:@"There was a failure authenticating your account. Please try again or contact us for support." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                [alert show];
                
                //NSLog(@"failure trying to login %@", logInError);
                //[hud hide:YES];
                return;
            }
        }];
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {


    return [self urlHandler:url];
}

- (void)setAppearance {
    //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.024 green:0.022 blue:0.153 alpha:1.000]];
    //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.023 green:0.014 blue:0.184 alpha:0.100]];
    //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.514 green:0.000 blue:0.655 alpha:0.010]];

    NSShadow *shadow = [[NSShadow alloc] init];
    //shadow.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.750f];
    shadow.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);

    //[[UIRefreshControl appearance] setTintColor:[UIColor colorWithRed:0.000 green:0.886 blue:1.000 alpha:0.9]];

    //[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.000 green:0.886 blue:1.000 alpha:0.9]];
    //[[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSShadowAttributeName: shadow}];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //   [self.navigationController hackTheNavigationBar];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.


    [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
    }

    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {

        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error saving information necessary to push notifications. Please enable Push Notifications in the System Settings for Gvideo to send you Push Notifications and Logout/Login to re-establish." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);

	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];

    NSDictionary *threadId = [userInfo objectForKey:kGVPushNotificationThreadIdKey];
    NSDictionary *info = @{@"threadId": threadId};
    // try to push
    [[NSNotificationCenter defaultCenter] postNotificationName:GVThreadPushAttemptNotification object:nil userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }

    if ([PFUser currentUser]) {
        // handle the push



        // update the UI to reflect new push
//        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
//            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
//
//            NSString *currentBadgeValue = tabBarItem.badgeValue;
//
//            if (currentBadgeValue && currentBadgeValue.length > 0) {
//                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
//                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
//                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
//            } else {
//                tabBarItem.badgeValue = @"1";
//            }
//        }
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    

    // Clear badge and update installation, required for auto-incrementing badges.
//    if (application.applicationIconBadgeNumber != 0) {
//        application.applicationIconBadgeNumber = 0;
//        //[[PFInstallation currentInstallation] setObject:[NSNumber numberWithInteger:0] forKey:@"badge"];
//        [[PFInstallation currentInstallation] saveEventually:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//
//            } else {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error communicating to the backend." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//                [alert show];
//            }
//        }];
//    }
    [self resetBadge];

    // Clears out all notifications from Notification Center.
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    //application.applicationIconBadgeNumber = 1;
    //application.applicationIconBadgeNumber = 0;

    //[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)handlePush:(NSDictionary *)launchOptions {

//    // If the app was launched in response to a push notification, we'll handle the payload here
//    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (remoteNotificationPayload) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
//
//        if (![PFUser currentUser]) {
//            return;
//        }
//
//        // If the push notification payload references a photo, we will attempt to push this view controller into view
//        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
//        if (photoObjectId && photoObjectId.length > 0) {
//            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
//            return;
//        }
//
//        // If the push notification payload references a user, we will attempt to push their profile into view
//        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
//        if (fromObjectId && fromObjectId.length > 0) {
//            PFQuery *query = [PFUser query];
//            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
//            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
//                if (!error) {
//                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
//                    self.tabBarController.selectedViewController = homeNavigationController;
//
//                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
//                    accountViewController.user = (PFUser *)user;
//                    [homeNavigationController pushViewController:accountViewController animated:YES];
//                }
//            }];
//        }
//    }
}

@end
