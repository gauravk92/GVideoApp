//
//  GVThreadViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/1/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

NSString *const GVThreadCollectionViewCellIdentifier = @"GVThreadCollectionViewCellIdentifier";

#import "GVThreadViewController.h"
#import "GVThreadCollectionViewCell.h"
#import "GVMasterViewController.h"
#import "GVParseObjectUtility.h"
#import "GVThreadCollectionViewCell.h"
#import "GVCircleThumbnailInnerShadowView.h"
#import "GVVideoCameraViewController.h"
#import "MBProgressHUD.h"
#import "GVCache.h"
#import "GVAppDelegate.h"
#import "GVCircleReactionView.h"
#import "GVReactionPopoverView.h"

#define CPF_COLLECTION 0

#define MAIL_STYLE 1

#define REAL_NAVIGATION_CONTROLLER 1

@interface GVThreadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSOperationQueue *scrollOperationQueue;
@property (nonatomic, assign) BOOL willPresentAnimatedCamera;
@property (nonatomic, assign) CGPoint willPresentInitialVelocity;

//@property (nonatomic, strong) MBProgressHUD *progressHUD;

//@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;

@property (nonatomic, strong) UICollectionViewFlowLayout *portraitLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *landscapeLayout;

//@property (nonatomic, assign) BOOL shouldReloadUsingNetwork;

@property (nonatomic, strong) NSMutableArray *activitiesShowing;
@property (nonatomic, strong) NSMutableArray *userImageViews;

//@property (nonatomic, strong) NSMutableDictionary *uploadingActivities;
//@property (nonatomic, strong) NSMutableDictionary *loadingActivities;

@property (nonatomic, strong) MPMoviePlayerViewController *reactionViewController;
@property (nonatomic, weak) UIImagePickerController *reactionPickerController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) UIPopoverController *reactionPopoverController;

@property (nonatomic, weak) UIView *circleView;

@property (nonatomic, strong) UIBarButtonItem *navButtonItem;

@property (nonatomic, strong) UIPopoverController *threadPopoverController;

@end

@implementation GVThreadViewController

//- (void)loadView {
//    [super loadView];
//}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    //self.navButtonItem = barButtonItem;
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.threadPopoverController = pc;
    //@weakify(self);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //  @strongify(self);
    //[[[self.splitController viewControllers][1] navigationItem] setLeftBarButtonItem:barButtonItem animated:YES];
    //[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //});
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.navigationItem.leftBarButtonItem = nil;
    self.threadPopoverController = nil;
    //@weakify(self);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    @strongify(self);
    //[self.navigationItem setLeftBarButtonItem:nil animated:YES];
    //});
}

- (void)viewDidLoad
{
#if CPF_COLLECTION
    self.pullToRefreshEnabled = NO;
    self.loadingViewEnabled = NO;
#endif
    [super viewDidLoad];

    self.title = @"Activity";
    // Do any additional setup after loading the view from its nib.
//
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.modalPresentationCapturesStatusBarAppearance = YES;

    //self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
    //self.shareBackgroundTaskId = UIBackgroundTaskInvalid;

    if (self.threadId) {
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_180_facetime_video"] style:UIBarButtonItemStylePlain target:self action:@selector(cameraPickerAction:)];

        self.navigationItem.rightBarButtonItem = shareButton;
    }
#if REAL_NAVIGATION_CONTROLLER

#else
self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 16, 0);
#endif
    

    //NSDictionary *backAttributes = @{NSForegroundColorAttributeName: [UIColor clearColor]};

    //[self.navigationItem.backBarButtonItem setTitleTextAttributes:backAttributes forState:UIControlStateNormal];
    
    //self.springyFlowLayout = self.collectionViewLayout;
    //GVThreadCollectionViewSpringyLayout *flowLayout = (GVThreadCollectionViewSpringyLayout*)self.collectionView.collectionViewLayout;
    self.portraitLayout = [[UICollectionViewFlowLayout alloc] init];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.portraitLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, 500);
        self.landscapeLayout = [[UICollectionViewFlowLayout alloc] init];
        self.landscapeLayout.itemSize = CGSizeMake(703, 300);
    } else {
        self.portraitLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, 320);
        self.landscapeLayout = [[UICollectionViewFlowLayout alloc] init];
        self.landscapeLayout.itemSize = CGSizeMake(self.collectionView.frame.size.height, 320);
    }

    self.portraitLayout.minimumLineSpacing = 45;

    //self.springyFlowLayout.minimumLineSpacing = 45;

    [self.collectionView registerClass:[GVThreadCollectionViewCell class] forCellWithReuseIdentifier:GVThreadCollectionViewCellIdentifier];

    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:GVThreadCollectionViewCell];

    //self.collectionView.backgroundView = self.givenBackgroundView;

    [self updateGradientMask];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactionDidSelectNotification:) name:@"GVThreadCollectionViewCellSelectIdentifier" object:nil];

    //self.userImageViews = [NSMutableArray arrayWithCapacity:25];
    //self.activitiesShowing = [NSMutableArray arrayWithCapacity:25];
    //self.activities = [NSArray array];

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:GVRefreshDataNotification object:nil];
}

- (void)updateGradientMask {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CAGradientLayer *l = [CAGradientLayer layer];
        l.frame = self.view.bounds;
        l.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        l.startPoint = CGPointMake(0.0f, -0.5f);
        l.endPoint = CGPointMake(0.0, 0.6f);
        //self.collectionView.layer.mask = l;
        self.view.layer.mask = l;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshData:(NSNotification*)notif {
    //self.shouldReloadUsingNetwork = YES;
#if CPF_COLLECTION
    [self performQuery];
#endif
//    if (self.loadingActivities) {
//        [self.loadingActivities removeAllObjects];
//    } else {
//        self.loadingActivities = [NSMutableDictionary dictionaryWithCapacity:10];
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.collectionView reloadData];
//        [self setScrollViewOffsetToBottom];
//    });
    [self objectsDidLoad:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.portraitLayout = [[UICollectionViewFlowLayout alloc] init];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.portraitLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, 500);
        self.landscapeLayout = [[UICollectionViewFlowLayout alloc] init];
        self.landscapeLayout.itemSize = CGSizeMake(703, 300);
    } else {
        self.portraitLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, 320);
        self.landscapeLayout = [[UICollectionViewFlowLayout alloc] init];
        self.landscapeLayout.itemSize = CGSizeMake(self.collectionView.frame.size.height, 320);
    }

    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 16, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(61, 0, 1, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;

    //self.extendedLayoutIncludesOpaqueBars = YES;
    

//    if (self.detailItem) {
//        UINib *cellNib = [UINib nibWithNibName:@"ThreadCell" bundle:nil];
//        [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"GVThreadCollectionViewCell"];
//        //
//        self.sizingCell = [[cellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
//    }

    //[self.collectionViewLayout invalidateLayout];
    NSLog(@" view frame: %@", NSStringFromCGRect(self.view.frame));
    NSLog(@" collectionView contentSize %@", NSStringFromCGSize(self.collectionView.contentSize));
    //self.springyFlowLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, self.collectionView.bounds.size.height - self.collectionView.contentSize.height - self.springyFlowLayout.footerReferenceSize.height - self.collectionView.scrollIndicatorInsets.top);
    //self.springyFlowLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 0);

    //[[GVCache sharedCache] setAttributesForThread:self.detailItem lastActivity:[self.detailItem updatedAt] users:[self.detailItem objectForKey:kGVThreadUsersKey] creator:nil];

    //[self.activitiesShowing removeAllObjects];
    //[self.userImageViews removeAllObjects];
    //self.activitiesShowing = [NSMutableArray arrayWithCapacity:25];
    //self.userImageViews = [NSMutableArray arrayWithCapacity:25];
//
//    for (PFObject *activity in self.activities) {
//        PFFile *videoThumb = [activity objectForKey:kGVActivityVideoThumbnailKey];
//        NSString *videoThumbUrl = [videoThumb url];
//        NSLog(@"videothumbnailUrl: %@", videoThumbUrl);
//        UIImageView *imageView = [[GVCache sharedCache] imageViewForAttributesUrl:videoThumbUrl];
//        if (imageView) {
//            [self.userImageViews addObject:imageView];
//            [self.activitiesShowing addObject:activity];
//        } else {
//            UIImageView *imageView = [[UIImageView alloc] init];
//            //imageView.alpha = 0;
//            imageView.layer.cornerRadius = 20;
//            imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
//            @weakify(imageView);
//            [imageView setImageWithURL:[NSURL URLWithString:videoThumbUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                UIImageView *imageViewW = imageView_weak_;
//                imageViewW.contentMode = UIViewContentModeScaleAspectFill;
//                imageViewW.alpha = 1;
//                CGAffineTransform imageViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//                imageViewTransform = CGAffineTransformRotate(imageViewTransform, DEGREES_TO_RADIANS(90));
//                //imageView.transform = imageViewTransform;
//                NSLog(@"created a new imageview");
//                //imageViewW.layer.cornerRadius = 20;
//                imageViewW.clipsToBounds = YES;
//                imageViewW.transform = imageViewTransform;
////                if (cacheType == SDImageCacheTypeNone || cacheType == SDImageCacheTypeDisk) {
////                    [UIView animateWithDuration:0.6
////                                          delay:0.0
////                         usingSpringWithDamping:0.8
////                          initialSpringVelocity:0.0
////                                        options:UIViewAnimationOptionBeginFromCurrentState
////                                     animations:^{
////                                         imageViewW.transform = imageViewTransform;
////                                     } completion:nil];
////                } else {
////                    imageViewW.transform = imageViewTransform;
////                }
//
//
//
//            }];
//            [self.userImageViews addObject:imageView];
//            [self.activitiesShowing addObject:activity];
//        }
//    }

//    if (self.navButtonItem) {
//        [self.navigationItem setLeftItemsSupplementBackButton:NO];
//        [self.navigationItem setLeftBarButtonItems:@[self.navButtonItem] animated:YES];
//    }

    @weakify(self);
    [self objectsDidLoad:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.extendedLayoutIncludesOpaqueBars = YES;
        [self setNeedsStatusBarAppearanceUpdate];

        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    });

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //if ([self isBeingPresented] || [self isMovingFromParentViewController]) {
        [self.reactionPickerController stopVideoCapture];
        [self.reactionPopoverController dismissPopoverAnimated:NO];
        //self.reactionPopoverController = nil;
        //self.reactionViewController = nil;
        //self.reactionPickerController = nil;
        //}
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            //[self.navigationItem.leftBarButtonItem]
        } else {

        }
    }
}

- (void)configureContentInsets {
    self.collectionView.contentInset = UIEdgeInsetsMake(16, 0, 16, 0);
    //self.collectionView.contentOffset = CGPointMake(0, 0);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self updateGradientMask];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            if (self.splitViewController) {
                UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Threads" style:UIBarButtonItemStylePlain target:self.splitViewController action:@selector(toggleMasterVisible:)];
                self.navigationItem.leftBarButtonItem = button;
            }
        }
    }

    //if (self.navButtonItem) {
    //    [self.navigationItem setLeftItemsSupplementBackButton:NO];
    //    [self.navigationItem setLeftBarButtonItems:@[self.navButtonItem] animated:YES];
    //}

    //[self.collectionViewLayout invalidateLayout];
    //self.springyFlowLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, 120);
    // this does the
#if MAIL_STYLE
    [self configureContentInsets];
#else
    if (self.collectionView.contentSize.height < self.view.bounds.size.height) {
        self.collectionView.contentInset = UIEdgeInsetsMake(self.view.bounds.size.height - self.collectionView.contentSize.height, 0, 16, 0);
    } else {
        self.collectionView.contentInset = UIEdgeInsetsMake(74, 0, 16, 0);
        //self.collectionView.contentOffset = CGPointMake(0,  self.view.bounds.size.height);
    }
#endif
    //[self setScrollViewOffsetToBottom];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

// called once per attempt to recognize, so failure requirements can be determined lazily and may be set up between recognizers across view hierarchies
// return YES to set up a dynamic failure requirement between gestureRecognizer and otherGestureRecognizer
//
// note: returning YES is guaranteed to set up the failure requirement. returning NO does not guarantee that there will not be a failure requirement as the other gesture's counterpart delegate or subclass methods may return YES
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0) {
//
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0) {
//
//}

//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //[self.collectionView reloadData];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self.collectionView setCollectionViewLayout:self.landscapeLayout];
        //[self.landscapeLayout resetLayout];
        //[self.collectionViewLayout invalidateLayout];

//        for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CGRect cellFrame = cell.frame;
//                cellFrame.origin.x = 0;
//                cell.frame = cellFrame;
//            });
//        }
        //[self.collectionView setNeedsLayout];
        //[self.collectionView layoutIfNeeded];
//        for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
//            //[cell invalidateIntrinsicContentSize];
//            cell.frame = cell.bounds;
//        }

    } else {
        [self.collectionView setCollectionViewLayout:self.portraitLayout];
        //[self.springyFlowLayout resetLayout];
        //[self.collectionViewLayout invalidateLayout];
    }
    //[self.collectionView reloadData];
    //[self.springyFlowLayout invalidateLayout];
    //[self.collectionView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
//        //dispatch_async(dispatch_get_main_queue(), ^{
//            cell.frame = cell.bounds;
//        //});
//    }

}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"self.collectionView.frame %@", NSStringFromCGRect(self.collectionView.frame));
//
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//
//    if (UIInterfaceOrientationIsPortrait(orientation)) {
//
//        return CGSizeMake(self.collectionView.frame.size.width, 120);
//
//    } else {
//
//        return CGSizeMake(self.collectionView.frame.size.width, 120);
//        
//    }
//    
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];



    self.scrollOperationQueue = [[NSOperationQueue alloc] init];
    self.scrollOperationQueue.maxConcurrentOperationCount = 1;

//    if (self.detailItem && [self.detailItem respondsToSelector:@selector(fetchIfNeededInBackgroundWithBlock:)]) {
//        
//    }

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self setNeedsStatusBarAppearanceUpdate];
        self.extendedLayoutIncludesOpaqueBars = YES;
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
        [self configureContentInsets];
    });

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

//    if (!self.threadMediaPickerController) {
//        self.threadMediaPickerController = [GVThreadMediaPickerController sharedInstance];
//        self.threadMediaPickerController.threadMediaPickerDelegate = self;
//        //[self.view insertSubview:self.threadMediaPickerController.view atIndex:0];
//    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

//    self.threadMediaPickerController.threadMediaPickerDelegate = nil;
//    self.threadMediaPickerController.transitioningDelegate = nil;

    [self.scrollOperationQueue cancelAllOperations];
    self.scrollOperationQueue = nil;

    [self.threadPopoverController dismissPopoverAnimated:NO];
    self.threadPopoverController = nil;
}

- (void)cameraPickerAction:(id)sender {
    NSBlockOperation *scrollOperation = [[NSBlockOperation alloc] init];
    @weakify(self);
    @weakify(scrollOperation);
    [scrollOperation addExecutionBlock:^{

        if ([scrollOperation_weak_ isCancelled]) {
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
//            if (([UIImagePickerController isSourceTypeAvailable:
//                  UIImagePickerControllerSourceTypeCamera] == NO)) {
//                return;
//            }

            //[self setScrollViewOffsetToBottom];

//            GVCameraMediaViewController *cameraUI = [[GVCameraMediaViewController alloc] init];
//            //if (cameraUI) {
//
//                cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
//
//                // Displays a control that allows the user to choose movie capture
//                cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
//
//                cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
//                cameraUI.videoMaximumDuration = 30;
//                cameraUI.showsCameraControls = NO;
//
//
//                // Hides the controls for moving & scaling pictures, or for
//                // trimming movies. To instead show the controls, use YES.
//                cameraUI.allowsEditing = NO;
//                cameraUI.showsCameraControls = NO;
//
//                cameraUI.delegate = cameraUI;
//                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//                    cameraUI.transitioningDelegate = nil;
//                } else {
//                    cameraUI.transitioningDelegate = self;
//                }
//                cameraUI.cameraMediaPickerDelegate = self;

                [TestFlight passCheckpoint:@"New Activity Action"];

             GVVideoCameraViewController *cameraUI = [[GVVideoCameraViewController alloc] initWithNavigationBarClass:nil toolbarClass:nil];
            //cameraUI.transitioningDelegate = self;

                //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                //    [self.splitViewController presentViewController:cameraUI animated:YES completion:nil];
                //} else {
            [self presentViewController:cameraUI animated:YES completion:nil];
                //}

            //}
        });
    }];
    [self.scrollOperationQueue addOperations:@[scrollOperation] waitUntilFinished:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"content Offset %f %f %f", scrollView.contentOffset.y, scrollView.contentSize.height - self.collectionView.frame.size.height, scrollView.contentInset.top);
    if (scrollView.contentOffset.y > 85 + scrollView.contentSize.height - scrollView.frame.size.height) {
        //[self cameraPickerAction:nil];
        // this should dispatch a refresh data notification
    }
}

//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@" received a memory warning: %@", self);
    // lets clear things...
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 1000;
//}

//// For responding to the user tapping Cancel.
//- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [picker dismissViewControllerAnimated:YES completion:nil];
//    });
//}
//
//// For responding to the user accepting a newly-captured picture or movie
//- (void) imagePickerController: (UIImagePickerController *) picker
// didFinishPickingMediaWithInfo: (NSDictionary *) info {
//
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
//
//    //[self dismissModalViewControllerAnimated:NO];
//    //[self dismissViewControllerAnimated:YES completion:nil];
//    [self imagePickerControllerDidCancel:picker];
//
//    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
//
//    // Handle a movie capture
//    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0)
//        == kCFCompareEqualTo) {
//        NSURL *url = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
//        if (url) {
//            NSString *moviePath = [url path];
//            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
//                UISaveVideoAtPathToSavedPhotosAlbum (moviePath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//            }
//        }
//    }
//}
#if CPF_COLLECTION
- (PFQuery *)queryForCollection
{
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:kGVActivityClassKey];
        [query setLimit:0];
        return query;
    }

    //PFQuery *query = [PFQuery queryWithClassName:kGVActivityClassKey];
    //[query whereKey:kGVActivityThreadKey equalTo:self.detailItem];
    //[query includeKey:kGVActivityUserKey];
    PFQuery *query = [GVParseObjectUtility queryForActivitiesOfThread:self.detailItem];
    query.limit = 25;


    // If no objects are loaded in memory, we look to the cache
    // first to fill the table and then subsequently do a query
    // against the network.
    //if ([self.objects count] == 0) {
    if ([self.objects count] == 0 || self.shouldReloadUsingNetwork) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    } else {
        query.cachePolicy = kPFCachePolicyCacheOnly;
    }
    //}

    [query orderByAscending:@"createdAt"];

    //[query orderByDescending:@"updatedAt"];
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    self.shouldReloadUsingNetwork = NO;
    if (!error) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self setScrollViewOffsetToBottom];
            //[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.objects count]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            if (self.collectionView.contentSize.height > self.view.bounds.size.height) {
                    @strongify(self);

//                [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height - self.view.bounds.size.height + 50 - self.collectionView.contentInset.top) animated:NO];

                //[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.objects count]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                //self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentSize.height + 50);
            }
            //[self.collectionView scrollRectToVisible:CGRectMake(0, self.collectionView.contentSize.height - self.collectionView.frame.size.height, self.collectionView.frame.size.width, self.collectionView.frame.size.height) animated:NO];
//            UIScrollView *scrollView = self.collectionView;
//            CGSize contentSize = scrollView.contentSize;
//            CGSize boundsSize = scrollView.bounds.size;
//            if (contentSize.height > boundsSize.height)
//            {
//                CGPoint contentOffset = scrollView.contentOffset;
//                contentOffset.y = contentSize.height - boundsSize.height;
//                [scrollView setContentOffset:contentOffset animated:YES];
//            }
        });
    }
}
#else
- (void)objectsDidLoad:(NSError*)error {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
        [self.collectionView reloadData];
        [self configureContentInsets];
        if (self.shouldScrollToOffsetAtBottom) {
            self.shouldScrollToOffsetAtBottom = NO;
            [self setScrollViewOffsetToBottom];
        }
        if (self.shouldScrollToBottomOffsetDelayed) {
            self.shouldScrollToBottomOffsetDelayed = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self);
                [self setScrollViewOffsetToBottom];
            });
        }
        //[self.collectionView setNeedsLayout];
        //[self.collectionView layoutIfNeeded];
    });
}
#endif
- (void)setScrollViewOffsetToBottom {
#if !MAIL_STYLE
    CGRect bounds = self.collectionView.bounds;
    bounds.origin.y = self.collectionView.contentSize.height - self.view.bounds.size.height + self.collectionView.contentInset.bottom;
    self.collectionView.bounds = bounds;
#else
    CGRect bounds = self.collectionView.bounds;
    bounds.origin.y = 0 + self.collectionView.contentInset.top * 2;
    self.collectionView.bounds = bounds;
#endif
}


//- (void)_configureCell:(GVThreadCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row%2)
//    {
//        cell.label.text = @"A";
//    }
//    else if (indexPath.row%3)
//    {
//        cell.label.text = @"longer";
//    }
//    else
//    {
//        cell.label.text = @"much longer";
//    }
//}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
////    if (indexPath.row % 3) {
////
////    } else {
////[self _configureCell:_sizingCell forIndexPath:indexPath];
//
//        return [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
////    }
//}

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//
//    if (self.collectionView.contentSize.height > self.view.frame.size.height) {
//        NSLog(@" its greater!");
//        // here we want to get rid of the section header and footer
//    } else {
//        // we do some calculation as to the size of the header and footer so it's still scrollable
//        self.sectionHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.collectionView.contentSize.height);
//        
//    }
//}

//- (NSInteger)activityCountIncludingUploads {
//    if ([self.uploadingActivities count] > 0) {
//        return [self.activities count] + [self.uploadingActivities count];
//    }
//    return [self.activities count];
//}
//
//- (PFObject*)activityForReverseIndexPath:(NSIndexPath*)indexPath {
//    NSInteger reverseSort = [self activityCountIncludingUploads] - indexPath.item-1;
//    PFObject *upload = [self.uploadingActivities objectForKey:indexPath];
//    PFObject *loading = [self.loadingActivities objectForKey:indexPath];
//    if (upload) {
//        return upload;
//    } else if (loading) {
//        return loading;
//    } else {
//       return [self.activities objectAtIndex:reverseSort];
//    }
//}

- (void)reactionDidSelectNotification:(NSNotification*)notif {
    NSString *url = [[notif userInfo] objectForKey:@"url"];
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
        moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        [moviePlayer.moviePlayer play];
        [self_weak_ presentViewController:moviePlayer animated:YES completion:nil];
    });
}

/* Called on the delegate when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view.
 */
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"popover should dismiss delegate call");
    return YES;
}

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"popover dismissed delegate call");
}

/* -popoverController:willRepositionPopoverToRect:inView: is called on your delegate when the popover may require a different view or rectangle
 */
- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view {
    NSLog(@"popover will repositionpopver");
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //GVThreadCollectionViewCell *cell = (GVThreadCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

//    id upload = [self.uploadingActivities objectForKey:indexPath];
//    if (upload != nil) {
//        return;
//    }
//    id loading = [self.loadingActivities objectForKey:indexPath];
//    if (loading != nil) {
//        return;
//    }
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [TestFlight passCheckpoint:@"Select Item Action"];
        @strongify(self);
        NSArray *results = [self.modelObject threadReactionShouldRecordAtIndexPath:indexPath thread:self.threadId];
        BOOL shouldRecord = [[results objectAtIndex:0] boolValue];
        NSString *url = [results objectAtIndex:1];
        if (shouldRecord) {
            //if (false) {

            // just play the damn video
            self.selectedIndexPath = indexPath;
            // we need to record the reaction sofb

            if (([UIImagePickerController isSourceTypeAvailable:
                  UIImagePickerControllerSourceTypeCamera] == NO)) {
                return;
            }

            UIView *circleView;
            GVCircleReactionView *circleReactionView;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                circleReactionView = [[GVCircleReactionView alloc] initWithFrame:CGRectMake(20, 30, 150, 150)];
                circleView.backgroundColor = [UIColor clearColor];
                circleView = circleReactionView;
                circleView.layer.cornerRadius = 75;
                circleView.autoresizesSubviews = YES;
                circleView.clipsToBounds = 1;
                //circleView.contentMode = UIViewContentModeScaleAspectFit;

            } else {
                circleView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
                circleView.backgroundColor = [UIColor clearColor];
                circleView.layer.cornerRadius = 50;
                circleView.clipsToBounds = 1;
            }
            circleView.alpha = 0.6;
            self.circleView = circleView;

            UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
            self.reactionPickerController = cameraUI;
            cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;

            // Displays a control that allows the user to choose movie capture
            cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];

            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            cameraUI.videoMaximumDuration = 30;



            // Hides the controls for moving & scaling pictures, or for
            // trimming movies. To instead show the controls, use YES.
            cameraUI.allowsEditing = NO;
            cameraUI.showsCameraControls = NO;
            //cameraUI.view.layer.cornerRadius = 50;

            cameraUI.delegate = self;

            MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
            //[UIApplication sharedApplication].statusBarHidden = NO;
            moviePlayer.edgesForExtendedLayout = UIRectEdgeAll;
            [moviePlayer.moviePlayer play];
            moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleNone;

            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                [moviePlayer.view addSubview:circleView];
            } else {
                [moviePlayer.view addSubview:circleView];
                [circleView addSubview:cameraUI.view];
                [moviePlayer addChildViewController:cameraUI];
                [cameraUI didMoveToParentViewController:moviePlayer];
            }
            UIPopoverController *popover;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
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
                self.reactionPopoverController = popover;
                //self.reactionPopoverController.delegate = self;
                popover.backgroundColor = [UIColor clearColor];
                popover.popoverBackgroundViewClass = [GVReactionPopoverView class];
                [popover setPopoverContentSize:CGSizeMake(200, 200)];
                [popover presentPopoverFromRect:CGRectMake(0, 0, 1, 1) inView:self.view.window permittedArrowDirections:UIPopoverArrowDirectionLeft animated:NO];
                circleReactionView.picker = cameraUI;
                [cameraUI.view setFrame:containerController.view.frame];
                [circleReactionView addSubview:containerController.view];
                CGRect containFrame = containerController.view.frame;
                containFrame.origin.y = -25;
                containFrame.origin.x = -25;
                containerController.view.frame = containFrame;
                [circleReactionView setNeedsLayout];
                [circleReactionView layoutIfNeeded];
                if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                    containerController.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
                } else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                    containerController.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
                } else {

                }
                //[popover dismissPopoverAnimated:NO];


            } else {
                cameraUI.view.frame = CGRectMake(0, 0, 100, 100);
            }


            // register for notifications now mofo

//                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:moviePlayer];
//    //
//                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieReadyChange:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
//    //
//                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
//    //
//                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayingChange:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];

            self.reactionPickerController.delegate = self;
            self.reactionViewController = moviePlayer;
            //moviePlayer.transitionCoordinator = self;
            [self presentViewController:moviePlayer animated:YES completion:^{
                @strongify(self);
                [self.reactionPickerController startVideoCapture];
                //[circleReactionView setNeedsLayout];
                //[circleReactionView layoutIfNeeded];

            }];
        } else {
            // just play the damn video
            if ([url respondsToSelector:@selector(length)] && [url length] > 0) {
                MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
                moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
                [moviePlayer.moviePlayer play];
                [self presentViewController:moviePlayer animated:YES completion:nil];
            }
        }
    });

}

//- (BOOL)animateAlongsideTransition:(void (^)(id <UIViewControllerTransitionCoordinatorContext>context))animation
//                        completion:(void (^)(id <UIViewControllerTransitionCoordinatorContext>context))completion {
//    @strongify(self);
//
//    UIViewController *toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
//    if (toVC == self) {
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//            [self.reactionPopoverController dismissPopoverAnimated:NO];
//            //[[circleReactionView.subviews lastObject] removeFromSuperview];
//        }
//        // this is a dismissal completion
//        self.reactionViewController = nil;
//        [self.reactionPickerController stopVideoCapture];
//        self.reactionPickerController = nil;
//    }
//}


- (void)movieReadyChange:(NSNotification*)notif {
    NSLog(@"movie Ready change");
    NSLog(@"movie player ready change");
    BOOL playing = ( self.reactionViewController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying);
    NSLog(@"playing %i", playing);
    if (playing) {
        BOOL success = [self.reactionPickerController startVideoCapture];
        if (!success) {
            NSLog(@"there was an error starting video capture, or it already started");
        }
    } else {
        // [self.reactionPickerController stopVideoCapture];
    }
}

- (void)movieLoadChange:(NSNotification*)notif {
    NSLog(@"movie load change");
    BOOL playing = ( self.reactionViewController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying);
    NSLog(@"playing %i", playing);
    if (playing) {
        BOOL success = [self.reactionPickerController startVideoCapture];
        if (!success) {
            NSLog(@"there was an error starting video capture, or it already started");
        } else {
            self.circleView.alpha = 1;
        }
    } else {
        //[self.reactionPickerController stopVideoCapture];
    }
}

- (void)moviePlayingChange:(NSNotification*)notif {
    NSLog(@"movie playing change");
    BOOL playing = ( self.reactionViewController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying);
    NSLog(@"playing %i", playing);
    if (playing) {
        BOOL success = [self.reactionPickerController startVideoCapture];
        if (!success) {
            NSLog(@"there was an error starting video capture, or it already started");
        }
    } else {
        //[self.reactionPickerController stopVideoCapture];
    }
}

- (void)movieStateChange:(NSNotification*)notif {
    NSLog(@"movie state change");
    if (self.reactionViewController) {
        // here we can access playback state changes
        switch (self.reactionViewController.moviePlayer.playbackState) {
            case MPMoviePlaybackStateInterrupted:
                NSLog(@" fuck");
                break;
            case MPMoviePlaybackStatePaused:
                NSLog(@" fuck");
                break;
            case MPMoviePlaybackStatePlaying: {
                // here we wanna start capture if we have not already started
                BOOL videoCapSuccess = [self.reactionPickerController startVideoCapture];
                if (!videoCapSuccess) {
                    UIAlertView *reactionAlert = [[UIAlertView alloc] initWithTitle:@"Reaction error" message:@"There was an error recording your reaction. Sorry." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [reactionAlert show];
                }
                break;
            }
            case MPMoviePlaybackStateStopped: {
                // hopefully everything is smooth, we stop capture
                // we'll get the notification imagePickerblah
                // we're the delegate...
                //[self.reactionPickerController stopVideoCapture];

                break;
            }
            case MPMoviePlaybackStateSeekingBackward:
                break;
            case MPMoviePlaybackStateSeekingForward:
                break;
            default:
                break;
        }
    }
}

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    self.selectedIndexPath = nil;
//}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//
//    //@weakify(self);
//    //dispatch_async(dispatch_get_main_queue(), ^{
//    // @strongify(self);
//        //[self.threadMediaPickerDelegate performSelector:@selector(willAttemptToSaveVideo)];
//
//        //[picker dismissViewControllerAnimated:YES completion:^{
//        //void (^completionBlock)() = ^{
//        //@strongify(self);
//                // Handle a movie capture
//                if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0)
//                    == kCFCompareEqualTo) {
//                    NSURL *url = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
//                    if (url) {
//                        NSString *moviePath = [url path];
//                        [self reaction:moviePath didFinishSavingWithError:nil];
//                    }
//                }
//
//        //  }
//        //}];
//        //});
//}

//- (void)reaction:(NSString*)reactionPath didFinishSavingWithError:(NSError*)error {
//
//    if (error) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
//        [alert show];
//    } else {
//        [TestFlight passCheckpoint:@"New Reaction Action"];
//        [self.modelObject threadReactionWithVideoPath:reactionPath thread:self.threadId indexPath:self.selectedIndexPath];
//        self.selectedIndexPath = nil;
//        
//    }
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.reactionPickerController = nil;
//        self.reactionPopoverController = nil;
//        self.reactionViewController = nil;
//    }
//}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [self.collectionView.collectionViewLayout invalidateLayout];
    return [self.modelObject threadViewControllerRowCount:self.threadId];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    PFObject *upload = [self.uploadingActivities objectForKey:indexPath];
//    PFObject *loading = [self.loadingActivities objectForKey:indexPath];
//    if (upload) {
//        return [self collectionViewCellForUploadingForIndexPath:indexPath];
//    } else if (loading) {
//        return [self collectionViewCellForLoadingForIndexPath:indexPath];
//    } else {
    NSLog(@"collection View index Path: %@", indexPath);
    NSArray *results = [self.modelObject threadViewControllerDataAtIndexPath:indexPath thread:self.threadId];
    PFObject *activity;
    NSDictionary *objects;
    if ([results count] > 0) {
        activity = [results objectAtIndex:0];
        if ([results count] > 1) {
            objects = [results objectAtIndex:1];
        }
    }
    return [self collectionView:collectionView cellForItemAtIndexPath:indexPath activity:activity objects:objects];
    //}
}
//
//- (UICollectionViewCell*)collectionViewCellForUploadingForIndexPath:(NSIndexPath*)indexPath {
//    NSDictionary *activityDict = [self.uploadingActivities objectForKey:indexPath];
//    GVThreadCollectionViewCell *cell = (GVThreadCollectionViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:GVThreadCollectionViewCellIdentifier forIndexPath:indexPath];
//
//    cell.thumbnailView.imageView.image = activityDict[@"thumb"];
//    cell.displaySentMessage = YES;
//    [cell setNeedsLayout];
//    [cell layoutIfNeeded];
//    return cell;
//}
//
//- (UICollectionViewCell*)collectionViewCellForLoadingForIndexPath:(NSIndexPath*)indexPath {
//    NSDictionary *activityDict = [self.loadingActivities objectForKey:indexPath];
//    GVThreadCollectionViewCell *cell = (GVThreadCollectionViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:GVThreadCollectionViewCellIdentifier forIndexPath:indexPath];
//
//    cell.thumbnailView.imageView.image = activityDict[@"thumb"];
//    cell.displaySentMessage = YES;
//    [cell setNeedsLayout];
//    [cell layoutIfNeeded];
//    return cell;
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath activity:(PFObject*)activity objects:(NSDictionary*)objects {
    GVThreadCollectionViewCell *cell = (GVThreadCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:GVThreadCollectionViewCellIdentifier forIndexPath:indexPath];

    //NSString *actType = [object objectForKey:kGVActivityTypeKey];

    //cell.willCaptureUponSelection = YES;

    //PFObject *activity = [objects firstObject];

    [cell removeAllSubImageViews];
    //[cell.thumbnailView.imageView removeFromSuperview];
    //cell.thumbnailView.imageView = [self.userImageViews objectAtIndex:indexPath.row];
    //[cell.thumbnailView addSubview:cell.thumbnailView.imageView];

    PFFile *videoThumb = [activity objectForKey:kGVActivityVideoThumbnailKey];
    NSString *videoThumbUrl = [videoThumb url];

    cell.threadId = [[activity objectForKey:kGVActivityThreadKey] objectId];

    PFUser *sendUser = [activity objectForKey:kGVActivityUserKey];
    NSString *sendusername = [sendUser username];
    [cell setSendUsernameText:sendusername];

    NSString *timeLabel;
    if (objects) {
        timeLabel = [objects objectForKey:@"activity_time"];
        [cell setTimeLabelString:timeLabel];
        [cell addActivities:[objects objectForKey:@"reactionsSorted"]];
    }

    //PFObject *activity = [self activityForReverseIndexPath:indexPath];
    // is there a reaction by this user on this activity...if not create it and save
    if (activity) {
        PFFile *video = [activity objectForKey:kGVActivityVideoKey];
        NSString *activityUserId = [[activity objectForKey:kGVActivityUserKey] objectId];
        NSString *currentUserId = [[PFUser currentUser] objectId];
        NSString *url = [video url];
        if ([[activity objectForKey:kGVActivityTypeKey] isEqualToString:kGVActivityTypeSendKey]) {
            NSArray *users = [activity objectForKey:kGVActivitySendReactionsKey];

            if (!([url length] > 0)) {
                NSLog(@"there was a movie playback error, no movie found %@", activity);
                //return;
            }

            NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:[users count]];
            for (PFUser *user in users) {
                [userIds addObject:[user objectId]];
            }

            if (![activityUserId isEqualToString:currentUserId] && ![userIds containsObject:currentUserId]) {
                //cell.thumbnailView.layer.borderWidth = 2.5;
                //cell.thumbnailView.layer.borderColor = [UIColor whiteColor].CGColor;
            } else {
                //cell.thumbnailView.layer.borderWidth = 2.5;
                //cell.thumbnailView.layer.borderColor = [UIColor whiteColor].CGColor;
            }
        }
    }


    //NSLog(@"videothumbnailUrl: %@", videoThumbUrl);
//    UIImageView *imageView = [[GVCache sharedCache] imageViewForAttributesUrl:videoThumbUrl];
//    if (imageView) {
//        cell.thumbnailView.imageView = imageView;
//        [cell.thumbnailView addSubview:imageView];
//        cell.thumbnailView.imageView.frame = cell.thumbnailView.bounds;
//        [self.userImageViews addObject:imageView];
//        [self.activitiesShowing addObject:activity];
//    } else {
        UIImageView *imageView = [[UIImageView alloc] init];

//    NSDictionary *stillLoadingActivity = [self.loadingActivities objectForKey:indexPath];
//    if (stillLoadingActivity) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            imageView.image = stillLoadingActivity[@"thumb"];
//        });
//    }


    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
    imageView.layer.shouldRasterize = YES;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //imageView.alpha = 0;
        //imageView.layer.cornerRadius = 20;
        //imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        [[GVCache sharedCache] setAttributesForImageView:imageView url:videoThumbUrl];
    //@weakify(imageView);
        [imageView setImageWithURL:[NSURL URLWithString:videoThumbUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            //[self.loadingActivities removeObjectForKey:indexPath];

            //UIImageView *imageViewW = imageView_weak_;
            //imageViewW.contentMode = UIViewContentModeScaleAspectFill;
            //imageViewW.alpha = 1;
            //CGAffineTransform imageViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            //imageViewTransform = CGAffineTransformRotate(imageViewTransform, DEGREES_TO_RADIANS(90));
            //imageView.transform = imageViewTransform;
            NSLog(@"created a new imageview");
            //imageViewW.layer.cornerRadius = 20;
            //imageViewW.clipsToBounds = YES;
            //imageViewW.transform = imageViewTransform;
            //                if (cacheType == SDImageCacheTypeNone || cacheType == SDImageCacheTypeDisk) {
            //                    [UIView animateWithDuration:0.6
            //                                          delay:0.0
            //                         usingSpringWithDamping:0.8
            //                          initialSpringVelocity:0.0
            //                                        options:UIViewAnimationOptionBeginFromCurrentState
            //                                     animations:^{
            //                                         imageViewW.transform = imageViewTransform;
            //                                     } completion:nil];
            //                } else {
            //                    imageViewW.transform = imageViewTransform;
            //                }
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.thumbnailView setNeedsLayout];
                [cell.thumbnailView layoutIfNeeded];
            });
            
        }];
        cell.thumbnailView.imageView = imageView;
        [cell.thumbnailView addSubview:imageView];
        cell.thumbnailView.imageView.frame = cell.thumbnailView.bounds;
        [self.userImageViews addObject:imageView];
        [self.activitiesShowing addObject:activity];
        [cell.thumbnailView setNeedsLayout];
        [cell.thumbnailView layoutIfNeeded];
        //}



//    NSDictionary *cachedActivity = [[GVCache sharedCache] attributesForActivity:object];
//    if (cachedActivity) {
//        cell.contentURL = cachedActivity[kGVActivityVideoKey];
////        dispatch_async(dispatch_get_main_queue(), ^{
////            cell.thumbnailView.imageView.image = cachedActivity[kGVActivityVideoThumbnailKey];
////            dispatch_async(dispatch_get_main_queue(), ^{
////                cell.thumbnailView.imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
////            });
////        });
//    } else {
//        cell.contentURL = [[object objectForKey:kGVActivityVideoThumbnailKey] url];
//        PFFile *thumbPic = [object objectForKey:kGVActivityVideoThumbnailKey];
//        [thumbPic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            UIImage *image = [UIImage imageWithData:data];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                cell.thumbnailView.imageView.image = image;
//            });
//        }];
//        // need to update cache
//    }
    //cell.thumbnailView.imageView.file = thumbPic;
    //[cell.thumbnailView.imageView loadInBackground];




    PFUser *activityUser = [activity objectForKey:kGVActivityUserKey];

    if (activityUser) {

    } else {
        NSLog(@"activiy User nil %@", activityUser);
    }

    if ([[activityUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {

        cell.displaySentMessage = YES;
    } else {
        cell.displaySentMessage = NO;
    }

    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    return cell;

//        dispatch_async(dispatch_get_main_queue(), ^{
//            CGRect cellFrame = cell.frame;
//            cellFrame.origin.x = 0;
//            cell.frame = cellFrame;
//        });

//    if (!cell) {
//        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 107)];
//    }

//    NSDictionary *actAttributes = [[GVCache sharedCache] attributesForActivity:object];
//    if (actAttributes) {
//        
//    } else {
//[object fetchIfNeededInBackgroundWithBlock:^(PFObject *obj, NSError *error) {
// NSLog(@"cell call %@", object);
//            PFUser *user = [obj objectForKey:kGVActivityUserKey];
//            PFFile *video = [obj objectForKey:kGVActivityVideoKey];
//            PFFile *thumbPic = [obj objectForKey:kGVActivityVideoThumbnailKey];
//            NSString *actType = [obj objectForKey:kGVActivityTypeKey];
//            cell.thumbnailView.imageView.file = thumbPic;
//            [cell.thumbnailView.imageView loadInBackground];
            //[[GVCache sharedCache] setAttributesForActivity:obj user:nil video:video thumbPicture:thumbPic thread:self.detailItem type:actType reactions:nil original:nil];

//            if (thumbPic) {
//                [thumbPic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                    if (!error) {
//                        UIImage *image = [UIImage imageWithData:data];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                        if (!cell.thumbnailView) {
//                            PFUser *activityUser = [object objectForKey:kGVActivityUserKey];
//                            [activityUser fetchIfNeededInBackgroundWithBlock:^(PFObject *actUser, NSError *error) {
//                                NSString *cellUsername = [actUser objectForKey:kGVUserNameKey];
//                                NSString *currentUsername = [[PFUser currentUser] objectForKey:kGVUserNameKey];
//                                if ([cellUsername isEqualToString:currentUsername]) {
//                                    cell.displaySentMessage = YES;
//                                } else {
//                                    cell.displaySentMessage = NO;
//                                }
//                                if (!cell.thumbnailView) {
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        GVCircleThumbnailInnerShadowView *shadowView = [[GVCircleThumbnailInnerShadowView alloc] initWithFrame:CGRectMake(0, 0, 115, 115)];
//                                        [shadowView.imageView setImage:image];
//                                        cell.thumbnailView = shadowView;
//                                        [cell layoutThumbnailView];
//                                    });
//                                }
//                                //[cell setNeedsLayout];
//                                //[cell layoutIfNeeded];
//                            }];
//                        }
//                        });
//                        // image can now be set on a UIImageView
//                    }
//                }];
//            }
//        }];
//    }

    //cell.backgroundColor = [UIColor redColor];

    return cell;
}

- (void)willAttemptToSaveVideo {
    //@weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self_weak_.progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
//    });
}

- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
        [alert show];
    } else {
        [TestFlight passCheckpoint:@"New Video Action"];
        [self.modelObject threadViewControllerNewSend:videoPath thread:self.threadId];
    }
}

#pragma mark - UIViewController animated transitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        UIView *containerView = [transitionContext containerView];
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

        //UIView *fromViewSnapshot;
        //UIView *toViewSnapshot;
        //UIView *navBarSnapshot;

        CGRect fromVCAnimateUpFrame;
        CGRect toVCAnimateDownFrame;

        BOOL willPresent = self.willPresentAnimatedCamera;
        if (willPresent) {

            [containerView addSubview:fromVC.view];
            [containerView insertSubview:toVC.view belowSubview:fromVC.view];

            fromVCAnimateUpFrame = fromVC.view.frame;
            fromVCAnimateUpFrame.origin.y -= CGRectGetHeight(fromVC.view.frame);

        } else {

            [containerView addSubview:fromVC.view];
            [containerView addSubview:toVC.view];

            [fromVC.view setFrame:containerView.bounds];

            CGRect toVCUpFrame = containerView.bounds;
            toVCUpFrame.origin.y -= CGRectGetHeight(containerView.bounds);

            toVCAnimateDownFrame = containerView.bounds;

            [toVC.view setFrame:toVCUpFrame];
        }



        CGPoint initVelocity = self.willPresentInitialVelocity;

        NSLog(@"initVelocity %@", NSStringFromCGPoint(initVelocity));


        [UIView animateWithDuration:[self transitionDuration:nil]
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:fabsf(initVelocity.y / 800)
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             if (willPresent) {
                                 //@strongify(self);

                                 //CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
                                 //navigationBarFrame.origin.y -= navigationBarFrame.size.height;
                                 //[navBarSnapshot setFrame:navigationBarFrame];

                                 //CGRect collectionViewUpFrame = self.collectionView.frame;
                                 //collectionViewUpFrame.origin.y -= collectionViewUpFrame.size.height;
                                 //[self.collectionView setFrame:collectionViewUpFrame];
                                 [fromVC.view setFrame:fromVCAnimateUpFrame];
                             } else {
                                 [toVC.view setFrame:toVCAnimateDownFrame];
                             }
        } completion:^(BOOL completed) {
            if (completed) {
                NSLog(@"completed animation yo");

                //[fromViewSnapshot removeFromSuperview];
                //[toViewSnapshot removeFromSuperview];
                //[navBarSnapshot removeFromSuperview];
                [fromVC.view removeFromSuperview];
                //[fromVC.view removeFromSuperview];

                [transitionContext completeTransition:YES];
            }
        }];
    });
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.willPresentAnimatedCamera = YES;
    self.willPresentInitialVelocity = [self.collectionView.panGestureRecognizer velocityInView:self.collectionView];
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.willPresentAnimatedCamera = NO;
    //self.willPresentInitialVelocity = [GVThreadMediaPickerController sharedInstance].animateVelocity;
    return self;
}



@end
