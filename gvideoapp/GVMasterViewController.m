//
//  GVMasterViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/26/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVMasterViewController.h"
#import "GVWelcomeSignupViewController.h"
#import "GVSettingsUtility.h"
#import "GVMasterTableViewCell.h"
#import "GVMasterViewControllerGradientView.h"
#import "GVTintColorUtility.h"
#import "GVMasterModelObject.h"
#import "GVVideoCameraViewController.h"
#import "GVSettingsTableViewController.h"
#import "GVMasterSectionHeaderView.h"
#import "GVNavigationProfileView.h"
#import "GVMasterSectionHeaderView.h"
#import "GVMasterTableViewCell.h"
#import "GVSettingsViewController.h"
#import "GVSettingsNavigationController.h"
#import "GVMasterTableView.h"
#import "GVSplitTableView.h"
#import "GVShortTapGestureRecognizer.h"
#import "UIColor+Image.h"




#define REAL_NAVIGATION_CONTROLLER 1

NSString *const GVMasterViewControllerCellIdentifier = @"GVMasterViewControllerCellIdentifier";
NSString *const GVMasterViewControllerSectionHeaderViewIdentifier = @"GVMasterViewControllerSectionHeaderViewIdentifier";
NSString *const GVMasterViewControllerPullUpNotification = @"GVMasterViewControllerPullUpNotification";
NSString *const GVMasterViewControllerFullscreenNotification = @"GVMasterViewControllerFullscreenNotification";
NSString *const GVMasterViewControllerDeleteThreadRequestNotification = @"GVMasterViewControllerDeleteThreadRequestNotification";
NSString *const GVMasterViewControllerCellTouchNotification = @"GVMasterViewControllerCellTouchNotification";
NSString *const GVMasterViewControllerSetupEmptyLabelNotification = @"GVMasterViewControllerSetupEmptyLabelNotification";
NSString *const GVMasterViewControllerEndEmptyLabelNotification = @"GVMasterViewControllerEndEmptyLabelNotification";



@interface GVMasterViewController () <UIActionSheetDelegate, UITableViewDataSource, GVMasterModelObjectProtocol, UIPopoverControllerDelegate, UIGestureRecognizerDelegate> {
#if PLAYS_SOUND
    SystemSoundID deadAirSound;
    SystemSoundID coffeeSound;
#endif
}

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSBlockOperation *deleteBlockOperation;
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) UIPopoverController *settingsPopoverController;
@property (nonatomic, assign) CGPoint workingContentOffset;

@property (nonatomic, strong) UIView *createNewThreadView;
@property (nonatomic, strong) NSMutableDictionary *viewsDictionary;

@property (nonatomic, strong) UIView *snapshotView;

@property (nonatomic, strong) GVSettingsNavigationController *settingsNavigationController;
@property (nonatomic, strong) UIView *settingsNavView;
@property (nonatomic, strong) NSOperationQueue *imageOperationQueue;
@property (nonatomic, strong) NSCache *imageCache;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) GVMasterTableView *tableView;

@property (nonatomic, strong) NSOperationQueue *scrollOperationQueue;
@property (nonatomic, strong) NSMutableDictionary *scrollOperations;

@end

@implementation GVMasterViewController

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isDescendantOfView:self.view]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isDescendantOfView:self.view]) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isDescendantOfView:self.view]) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }
    return self;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)loadView {
    [super loadView];
    self.view = [[GVMasterTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.imageOperationQueue = [[NSOperationQueue alloc]init];
    self.imageOperationQueue.maxConcurrentOperationCount = 4;

    //self.imageCache = [[NSCache alloc] init];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }

    self.title = @"Threads";
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.automaticallyAdjustsScrollViewInsets = NO;

    self.shouldReloadOnAppear = NO;

    //self.modalPresentationCapturesStatusBarAppearance = YES;

//    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
//    self.refreshControl.hidden = YES;
//    [self.refreshControl addTarget:self action:@selector(refreshManually:) forControlEvents:UIControlEventValueChanged];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizesSubviews = NO;
    //self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.allowsSelection = NO;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.tableHeaderView = nil;
    self.tableView.tableFooterView = nil;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    self.scrollOperationQueue = [[NSOperationQueue alloc] init];
    self.scrollOperationQueue.maxConcurrentOperationCount = 4;
    self.scrollOperations = [NSMutableDictionary dictionaryWithCapacity:10];

    //self.tableView.clearsContextBeforeDrawing = NO;

    self.createNewThreadView = [[UIView alloc] initWithFrame:CGRectZero];
    self.createNewThreadView.backgroundColor = [UIColor blackColor];
    //self.tableView.tableHeaderView = self.createNewThreadView;
    //self.tableView.exclusiveTouch = YES;

    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.showsHorizontalScrollIndicator = YES;

    self.tableView.rowHeight = GVMasterTableViewCellRowHeight;
    self.tableView.scrollsToTop = YES;


    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;

    self.tableView.panGestureRecognizer.cancelsTouchesInView = YES;
    self.tableView.panGestureRecognizer.delaysTouchesBegan = YES;
    self.tableView.canCancelContentTouches = YES;
    self.tableView.layer.needsDisplayOnBoundsChange = NO;

    //self.tableView.panGestureRecognizer.cancelsTouchesInView = NO;
#if PLAYS_SOUND
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Coffee Load Pop - Sound" ofType:@"aiff"];
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID(url, &coffeeSound);

    NSString *deadpath = [[NSBundle mainBundle] pathForResource:@"Dead Air Sound" ofType:@"aiff"];
    CFURLRef deadurl = (CFURLRef)[NSURL fileURLWithPath:deadpath];
    AudioServicesCreateSystemSoundID(deadurl, &deadAirSound);

    AudioServicesPlaySystemSound(deadAirSound);
#endif
    self.tableView.separatorColor = [UIColor colorWithWhite:0.852 alpha:1.000];

    [self.tableView registerClass:[GVMasterTableViewCell class] forCellReuseIdentifier:GVMasterViewControllerCellIdentifier];
    //[self.tableView registerClass:[GVMasterSectionHeaderView class] forHeaderFooterViewReuseIdentifier:GVMasterViewControllerSectionHeaderViewIdentifier];

    self.visibleSectionHeaderViews = [NSMutableDictionary dictionaryWithCapacity:1];

    //[self setAddButton];
    //[self setSettingsButton];
//    GVShortTapGestureRecognizer *sgc = [[GVShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleATapGesture:)];
//    [self.tableView addGestureRecognizer:sgc];
//    [sgc requireGestureRecognizerToFail:self.tableView.panGestureRecognizer];
}

- (void)dealloc {
#if PLAYS_SOUND
    AudioServicesDisposeSystemSoundID(deadAirSound);
    AudioServicesDisposeSystemSoundID(coffeeSound);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)handleATapGesture:(UIGestureRecognizer*)gc {
    //DLogObject(self);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.workingContentOffset = CGPointMake(0, 0);
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
#if REAL_NAVIGATION_CONTROLLER
        
#else
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(62, 0, 52, 0);
#endif

        self.createNewThreadView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
        [self setNeedsStatusBarAppearanceUpdate];
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.tableView.backgroundColor = [UIColor whiteColor];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    });
}

- (void)prepareSelfForScrolling {
    if (!self.snapshotView) {
        //self.tableView.layer.speed = 0.0;
        //self.snapshotView = [self.view snapshotViewAfterScreenUpdates:NO];
    }
}

- (void)endPreparationForScrolling {
    if (self.snapshotView) {
        //self.tableView.layer.speed = 1.0;
        //self.snapshotView = nil;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self endPreparationForScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self endPreparationForScrolling];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self endPreparationForScrolling];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self prepareSelfForScrolling];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat contentOffset = scrollView.contentOffset.y;
//
//
//    if (contentOffset == 0) {
//        
//    }
//
//    return;
//    if (contentOffset < 0) {
//        NSLog(@"content Offset %@", [NSValue valueWithCGPoint:scrollView.contentOffset]);
//        //self.parentScrollview.contentOffset
//
//
//        CGPoint currentOffset = self.parentScrollview.contentOffset;
//
//        self.parentScrollview.contentOffset = CGPointMake(0, currentOffset.y-contentOffset);
//        //self.tableView.contentOffset = CGPointZero;
//    }
//    if (self.parentScrollview.contentOffset.y > self.view.frame.size.height - splitTablePaneHeight) {
//        CGFloat diff = self.view.frame.size.height - splitTablePaneHeight - self.parentScrollview.contentOffset.y;
//
//        self.parentScrollview.contentOffset = CGPointMake(0, self.view.frame.size.height - splitTablePaneHeight);
//        self.tableView.contentOffset = CGPointMake(0, 0);
//    }
//    if (self.parentScrollview.contentOffset.y < 0) {
//        self.parentScrollview.contentOffset = CGPointMake(0, 0);
//    }
//    if (contentOffset > 0) {
//
//        CGPoint currentOffset = self.parentScrollview.contentOffset;
//
//        if (currentOffset.y < self.view.frame.size.height - splitTablePaneHeight ) {
//
//            self.parentScrollview.contentOffset = CGPointMake(0, currentOffset.y - contentOffset);
//            //self.tableView.contentOffset = CGPointZero;
//        } else {
////
//        }
//    }
//
//}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//
//}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)tapToSend:(NSNotification*)notif {
    NSIndexPath *indexPath = [notif userInfo][@"indexPath"];
    if (indexPath) {
        //[self pullUpAnimation];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[notif userInfo]];

        NSArray *headerInfo = [self.modelObject masterSendingHeaderInfo:indexPath];
        PFObject *thread = [self.modelObject masterViewControllerThreadAtIndexPath:indexPath];
        [dict setObject:headerInfo forKey:@"headerInfo"];
        [dict setObject:[thread objectId] forKey:@"threadId"];

        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerPullUpNotification object:nil userInfo:dict];
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }
}

- (void)sectionSelect:(NSNotification*)notif {
    NSDictionary *info = [notif userInfo];
    if (info) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerFullscreenNotification object:nil userInfo:info];
        //[self.tableView scrollToRowAtIndexPath:info[@"indexPath"] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        //[[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerPullUpNotification object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVThreadSelectionNotification object:nil userInfo:info];
        //[[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerCellSelectNotification object:nil userInfo:info];
    }
}


#pragma mark - Button Events

- (void)setAddButton {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_180_facetime_video"] style:UIBarButtonItemStylePlain target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)setSettingsButton {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
    self.navigationItem.leftBarButtonItem = addButton;
}

- (void)playCoffeeSound {
#if PLAYS_SOUND
    AudioServicesPlaySystemSound(coffeeSound);
#endif
}

- (void)refreshManually:(id)sender {
    if ([PFUser currentUser]) {
        [self playCoffeeSound];
        //[self insertNewObject:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
    }
    
}

#pragma mark - Model Object Protocol methods

- (void)objectsDidLoad:(NSError *)error {
    //@weakify(self);
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //    @strongify(self);
    
    // we can detect here if it's going to be empty, if so we'll fill it with something
    
    if ([self numberOfSectionsInTableView:self.tableView] == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerSetupEmptyLabelNotification object:nil];
    } else {
        // remove the text
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerEndEmptyLabelNotification object:nil];
        
    }
    
    if (self.tableView.tracking) {
    
    
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
        [self performSelectorOnMainThread:@selector(layoutTableViewContentInsets) withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
        
    } else {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.tableView reloadData];
            [self layoutTableViewContentInsets];
            
        });
    }
    //[self.refreshControl endRefreshing]
    //});
}

- (void)layoutTableViewContentInsets {
    self.tableView.contentInset = UIEdgeInsetsMake(-30, 0, 50, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 52, 0);
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.modelObject masterViewControllerRowCount];
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
//    return 0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 0;
//}
//
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0;
//}

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
//
////    UIView *rView = [self.viewsDictionary objectForKey:indexPath];
////    if (rView) {
////        return rView;
////    }
//
//    GVMasterSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:GVMasterViewControllerSectionHeaderViewIdentifier];
//
//    GVMasterSectionHeaderView *gcell = (GVMasterSectionHeaderView*)headerView;
//
//    NSDictionary *results = [self.modelObject masterViewControllerDataAtIndexPath:indexPath];
//
//    BOOL shouldLayoutCell = NO;
//
//    //NSLog(@"will display %@", indexPath);
//    //
//    //            NSNumber *showUnread = results[@"showUnread"];
//    //            if (showUnread) {
//    //                NSLog(@" %@", showUnread);
//    //                [gcell showUnreadIndicator:[showUnread boolValue] animate:NO];
//    //            }
//    //[gcell showUnreadIndicator:YES animate:NO];
//
//    NSArray *sortedUsers = [results objectForKey:@"sorted_users"];
//    [self.modelObject masterViewControllerSectionLabelWithUsernames:sortedUsers completionBlock:^(NSString* newLabel) {
//        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [gcell setUserTextString:newLabel];
//        //});
//    }];
//
//    NSString *usersLabel = results[@"users_label"];
//    if (usersLabel && [usersLabel length] > 0) {
//        [gcell setUserTextString:usersLabel];
//        [gcell setNeedsLayout];
//        [gcell setNeedsDisplay];
//        shouldLayoutCell = YES;
//    } else {
//        [gcell setUserTextString:@""];
//        [gcell startAnimatingWaitingDots];
//    }
//
//    NSString *timeLabel = results[@"activity_time"];
//    if (timeLabel) {
//        [gcell setTimeLabelString:timeLabel];
//        [gcell setNeedsLayout];
//        shouldLayoutCell = YES;
//        [gcell setNeedsDisplay];
//    }
//
//    gcell.indexPath = indexPath;
//
//    //[gcell.tapGestureRecognizer requireGestureRecognizerToFail:self.tableView.panGestureRecognizer];
//
//    //            NSArray *assets = results[@"activity_images"];
//    //            if (assets) {
//    //                //            for (UIView *view in assets) {
//    //                //                if (![[self.imageViews subviews] containsObject:view]) {
//    //                //                    [self.imageViews addSubview:view];
//    //                //                }
//    //                //            }
//    //                [gcell addActivities:assets];
//    //                gcell.collectionView.frame = CGRectMake(10, 50, self.view.bounds.size.height - 10, 40);
//    //                gcell.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    //            }
//
//    //  gcell.odd = (indexPath.item % 2 == 1);
//
//    //gcell.imageView.frame = CGRectMake(0, 0, 3, self.tableView.rowHeight);
//
//    if (shouldLayoutCell) {
//        [gcell layoutIfNeeded];
//        //[gcell setupSubviews];
//        [gcell setNeedsDisplay];
//    }
//
//    NSIndexPath *idPath = [NSIndexPath indexPathForRow:0 inSection:section];
//    [self.visibleSectionHeaderViews setObject:gcell forKey:idPath];
//
//    //[headerView setNeedsDisplay];
//
//    return headerView;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    // @autoreleasepool {
//        //dispatch_async(dispatch_get_main_queue(), ^{
//
//        //});
//        //}
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
//    if (!self.viewsDictionary) {
//        self.viewsDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
//    }
//    //[self.viewsDictionary setObject:view forKey:indexPath];
//    [self.visibleSectionHeaderViews removeObjectForKey:indexPath];
//}

- (void)updateRowAtIndexPath:(NSIndexPath*)indexPath {
    GVMasterTableViewCell *cell = (GVMasterTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSDictionary *results = [self.modelObject masterViewControllerDataAtIndexPath:indexPath];
        
        NSURL *mainImageUrl = results[@"main_image_url"];
        NSString *imageUrlString = [mainImageUrl path];
        [self.imageCache removeObjectForKey:imageUrlString];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
        //cell.mainImageView.image = nil;
        });
    });
    
    
}

- (void)updateRowModelAtIndexPath:(NSIndexPath*)indexPath {
    GVMasterTableViewCell *cell = (GVMasterTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSDictionary *results = [self.modelObject masterViewControllerDataAtIndexPath:indexPath];
    
        GVMasterTableViewCell *gcell = cell;
        gcell.titleTextString = results[@"user_string"];
        gcell.attributes = results[@"attrs"];
        gcell.usersAttrString = results[@"attr_string"];
        gcell.textXInset = results[@"text_inset"];
        //gcell.sortedProfilePics = results[@"sorted_pics"];
        gcell.imageSize = results[@"image_size"];
        gcell.imagePadding = results[@"image_padding"];
        gcell.tapPadding = results[@"tap_padding"];
        gcell.userImageFiles = results[@"sorted_data"];
        gcell.scrollWidth = results[@"scroll_width"];
        gcell.displayTableView = self.tableView;
        gcell.threadId = results[@"threadId"];
        gcell.sectionIndexPath = indexPath;
    });
    
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    GVMasterTableViewCell *gcell = (GVMasterTableViewCell*)cell;
    
    BOOL containsData = [self.modelObject masterViewControllerContainsDataAtIndexPath:indexPath];
    
    //[gcell setupScrollContent:CGSizeZero];
//    gcell.titleTextString = nil;
//    gcell.attributes = nil;
//    gcell.usersAttrString = nil;
//    gcell.textXInset = nil;
//    //gcell.sortedProfilePics = results[@"sorted_pics"];
//    gcell.imageSize = nil;
//    gcell.imagePadding = nil;
//    gcell.tapPadding = nil;
//    gcell.userImageFiles = nil;
//    gcell.scrollWidth = nil;
//    gcell.displayTableView = nil;
//    gcell.threadId = nil;
//    gcell.sectionIndexPath = nil;
//    //[gcell.scrollView setContentOffset:CGPointZero];
//
//    gcell.mainImageView.layer.contents = nil;
//    for (UIView *view in gcell.subviews) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            for (UIView *v in view.subviews) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [v setNeedsDisplay];
//                });
//            }
//            [view setNeedsDisplay];
//        });
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [gcell.mainImageView setNeedsDisplay];
//        [gcell.scrollView setNeedsLayout];
//        [gcell.scrollView setNeedsDisplay];
//        gcell.scrollView.panGestureRecognizer.enabled = NO;
//        gcell.scrollView.panGestureRecognizer.enabled = YES;
//    });

    
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    @weakify(self);
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        
        if ([blockOperation_weak_ isCancelled]) {
            return;
        }
        
        dispatch_queue_t queue = nil;
        if (!containsData) {
            queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        } else {
            queue = dispatch_get_main_queue();
        }
        
        dispatch_async(queue, ^{
            NSDictionary *results = [self.modelObject masterViewControllerDataAtIndexPath:indexPath];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *mainImageUrl = results[@"main_image_url"];
              
            #if SDWEBIMAGE_CACHING
                //NSString *imageUrlString = [mainImageUrl absoluteString];
            #else
                NSString *imageUrlString = [mainImageUrl path];

                UIImage *imageFromCache = [self.imageCache objectForKey:imageUrlString];
            #endif
                CGFloat minValue = [UIScreen mainScreen].bounds.size.width;
                CGFloat scrollWidth = 0;
                if (CGFLOAT_IS_DOUBLE) {
                    scrollWidth = [results[@"scroll_width"] doubleValue];
                } else {
                    scrollWidth = [results[@"scroll_width"] floatValue];
                }

                CGFloat finalScrollValue = 0;
                if (scrollWidth > minValue) {
                    finalScrollValue = scrollWidth;
                } else {
                    finalScrollValue = minValue;
                }

                [gcell setupScrollContent:CGSizeMake(finalScrollValue, GVMasterTableViewCellRowHeight)];

                gcell.titleTextString = results[@"user_string"];
                gcell.attributes = results[@"attrs"];
                gcell.usersAttrString = results[@"attr_string"];
                gcell.textXInset = results[@"text_inset"];
                //gcell.sortedProfilePics = results[@"sorted_pics"];
                gcell.imageSize = results[@"image_size"];
                gcell.imagePadding = results[@"image_padding"];
                gcell.tapPadding = results[@"tap_padding"];
                gcell.userImageFiles = results[@"sorted_data"];
                gcell.scrollWidth = results[@"scroll_width"];
                gcell.displayTableView = self.tableView;
                gcell.threadId = results[@"threadId"];
                gcell.sectionIndexPath = indexPath;
                //[gcell.scrollView setContentOffset:CGPointZero];
                
            #if SDWEBIMAGE_CACHING
                @weakify(gcell);
                
                UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[mainImageUrl absoluteString]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    gcell_weak_.mainImageView.layer.contents = (id)image.CGImage;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [gcell_weak_.scrollView setNeedsLayout];
                        [gcell_weak_.scrollView setNeedsDisplay];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (UIView *view in gcell_weak_.subviews) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    for (UIView *v in view.subviews) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [v setNeedsDisplay];
                                        });
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                       [view setNeedsDisplay];
                                    });
                                });
                            }
                        });
                    });
                });
            });
        });
    }];
    if (!self.scrollOperations) {
        self.scrollOperations = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (blockOperation && indexPath) {
        [self.scrollOperations setObject:blockOperation forKey:indexPath];
        [self.scrollOperationQueue addOperations:@[blockOperation] waitUntilFinished:NO];
    }
        //DAssertNonNil(gcell.mainImageView.image);
//    [gcell.mainImageView setImageWithURL:mainImageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [gcell_weak_.mainImageView setNeedsDisplay];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [gcell_weak_.scrollView setNeedsDisplay];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSArray *subviews = [gcell_weak_ subviews];
//                    for (NSUInteger i = 0;i<[subviews count];i++) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            UIView *view = [subviews objectAtIndex:i];
//                            [view setNeedsDisplay];
//                            view.backgroundColor = [UIColor whiteColor];
//                        });
//                        if (i == [subviews count]) {
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [gcell_weak_ setNeedsDisplay];
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    [gcell_weak_ setupScrollViewTileSize];
//                                });
//                            });
//                        }
//                    }
//                    
//                    //[gcell setNeedsDisplay];
//                    
//                });
//            
//            });
//        });
//        //[gcell setNeedsDisplay];
//        //[gcell.scrollView setNeedsDisplay];
//    }];
#else

    [gcell setNeedsDisplay];
    [gcell.scrollView setNeedsDisplay];
    [gcell.shellView setNeedsDisplay];
    gcell.sectionIndexPath = indexPath;

    if (imageFromCache) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
            DAssertMainThread();
            NSParameterAssert(imageFromCache);
#if DELAYED_LOAD_IMAGE
            [gcell.mainImageView performSelectorOnMainThread:@selector(setImage:) withObject:imageFromCache waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
            [gcell performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
            [gcell.scrollView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
#else
            gcell.mainImageView.image = imageFromCache;
            DAssertNonNil(gcell.mainImageView.image);
        // gcell.cellImageView.contents = (id)imageFromCache.CGImage;
           [gcell setNeedsDisplay];
           [gcell.scrollView setNeedsDisplay];
            [gcell.scrollView setContentOffset:CGPointZero];
            [gcell scrollViewDidScroll:gcell.scrollView];
#endif
            //[gcell.cellImageView setNeedsDisplay];
            
        }];

        //[statusCell.imageCellTL setFrame: ...]; // set your frame accordingly
        [CATransaction commit];
        //});
    }
    else
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        gcell.mainImageView.image = nil;
        gcell.mainImageView.layer.contents = nil;
        //gcell.cellImageView.contents = nil;
        [gcell setNeedsDisplay];
        [gcell.scrollView setNeedsDisplay];
        //[gcell.cellImageView setNeedsDisplay];

        [CATransaction commit];
        //[statusCell.imageCellTL setFrame:CGRectZero]; // not sure if you need this line, but you had it in your original code snippet, so I include it here

        [self.imageOperationQueue addOperationWithBlock:^{
            NSURL *imageurl = mainImageUrl;
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageurl]];

            if (img != nil) {

                // update cache
                [self.imageCache setObject:img forKey:imageUrlString];

                // now update UI in main queue
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // see if the cell is still visible ... it's possible the user has scrolled the cell so it's no longer visible, but the cell has been reused for another indexPath
                    UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];

                    // if so, update the image
                    if (updateCell) {
                        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [CATransaction begin];
                        [CATransaction setDisableActions:YES];
                        
                        DAssertMainThread();
                        

                        //[updateCell.imageCellTL setFrame:...]; // I don't know what you want to set this to, but make sure to set it appropriately for your cell; usually I don't mess with the frame.
                        //gcell.cellImageView.contents = (id)img.CGImage;
#if DELAYED_LOAD_IMAGE
                        [gcell.mainImageView performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
                        [gcell performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
                        [gcell.scrollView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
#else
                        gcell.mainImageView.image = img;
                        DAssertNonNil(gcell.mainImageView.image);
                        [gcell setNeedsDisplay];
                        [gcell.scrollView setNeedsDisplay];
                        [gcell.scrollView setContentOffset:CGPointZero];
                        [gcell scrollViewDidScroll:gcell.scrollView];
#endif
                        //[gcell.cellImageView setNeedsDisplay];
                        [CATransaction commit];
                        //});
                    }
                }];
            }
        }];
    }
    
#endif

//    @weakify(self);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        @strongify(self);
//        //        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //       NSDictionary *results = [self.modelObject masterViewControllerDataAtIndexPath:indexPath];
//        //
//        //        //dispatch_async(dispatch_get_main_queue(), ^{
//
//        NSDictionary *results = [self.modelObject masterViewControllerDataAtIndexPath:indexPath];
//        NSURL *url = results[@"main_image_url"];
//        NSString *path = [url path];
//        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            GVMasterTableViewCell *gcell = (GVMasterTableViewCell*)cell;
//            [gcell.cellImageView setImage:image];
//        });
//    });
//
////    NSDictionary *results = [self.modelObject masterViewControllerDataAtIndexPath:indexPath];
//    NSArray *assets = results[@"activity_images"];
//    if (assets) {
//        //            for (UIView *view in assets) {
//        //                if (![[self.imageViews subviews] containsObject:view]) {
//        //                    [self.imageViews addSubview:view];
//        //                }
//        //            }
//        [gcell addActivities:assets];
//        //gcell.collectionView.frame = CGRectMake(10, 50, self.view.bounds.size.height - 10, 40);
//        //gcell.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    }
    //if (gcell.needsToDraw) {

    //[cell performSelector:@selector(updateContentsDisplayWithRect:) withObject:[NSValue valueWithCGRect:cell.frame]];

    //}
    //[gcell performSelector:@selector(updateContentsDisplayWithRect:) withObject:nil];
//    @autoreleasepool {
//        // dispatch_async(dispatch_get_main_queue(), ^{
//
//            
//
//
//    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        NSOperation *op = [self.scrollOperations objectForKey:indexPath];
        [op cancel];
        if (op && indexPath) {
            [self.scrollOperations removeObjectForKey:indexPath];
        }
    }
}

//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        GVMasterTableViewCell *gcell = (GVMasterTableViewCell*)cell;
//        PFObject *thread = [self.objects objectAtIndex:indexPath.row];
//        NSString *threadId = [thread objectId];
//
//        NSMutableDictionary *threadActivityAssets = [self.modelAssets objectForKey:threadId];
//        if (threadActivityAssets) {
//            NSDictionary *imageAssets = threadActivityAssets[@"activity_images"];
//            if (imageAssets) {
//                for (UIImageView *aImageView in imageAssets) {
//
//                }
//            }
//            [self.modelAssets removeObjectForKey:threadId];
//        }
//    });
//}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GVMasterTableViewCell *cell = (GVMasterTableViewCell*)[tableView dequeueReusableCellWithIdentifier:GVMasterViewControllerCellIdentifier forIndexPath:indexPath];
    //GVMasterTableViewCell *gcell = (GVMasterTableViewCell*)cell;


    //               placeholderImage:[UIColor imageWithColor:[UIColor redColor]]];


//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary *results = [self.modelObject masterViewControllerDataAtIndexPath:indexPath];
//
//        //dispatch_async(dispatch_get_main_queue(), ^{
//        //dispatch_async(dispatch_get_main_queue(), ^{
//        BOOL shouldLayoutCell = NO;
//        //
//        //            NSNumber *showUnread = results[@"showUnread"];
//        //            if (showUnread) {
//        //                //NSLog(@" %@", showUnread);
//        //                //[gcell showUnreadIndicator:[showUnread boolValue] animate:NO];
//        //            }
//        //            //[gcell showUnreadIndicator:YES animate:NO];
//        //
//        //            NSString *usersLabel = results[@"users_label"];
//        //            if (usersLabel && [usersLabel length] > 0) {
//        //                [gcell setUserTextString:usersLabel];
//        //                [gcell setNeedsLayout];
//        //                shouldLayoutCell = YES;
//        //            } else {
//        //                [gcell setUserTextString:@""];
//        //                [gcell startAnimatingWaitingDots];
//        //            }
//        //
//        //            NSString *timeLabel = results[@"activity_time"];
//        //            if (timeLabel) {
//        //                [gcell setTimeLabelString:timeLabel];
//        //                [gcell setNeedsLayout];
//        //                shouldLayoutCell = YES;
//        //            }
//
//        NSArray *sortedUsers = [results objectForKey:@"sorted_users"];
//        [self.modelObject masterViewControllerSectionLabelWithUsernames:sortedUsers completionBlock:^(NSString* newLabel) {
//            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            [gcell setUserTextString:newLabel];
//
//            //[gcell setNeedsDisplay];
//            //});
//        }];
//
//        NSString *usersLabel = results[@"users_label"];
//        if (usersLabel && [usersLabel length] > 0) {
//            //[gcell setUserTextString:usersLabel];
//            //[gcell setNeedsLayout];
//            //[gcell setNeedsDisplay];
//            [gcell setUserTextString:@""];
//            //shouldLayoutCell = YES;
//        } else {
//            [gcell setUserTextString:@""];
//            //[gcell startAnimatingWaitingDots];
//        }
//
//        NSString *timeLabel = results[@"activity_time"];
//        if (timeLabel) {
//            //[gcell setTimeLabelString:timeLabel];
//            //[gcell setNeedsLayout];
//            //shouldLayoutCell = YES;
//            //[gcell setNeedsDisplay];
//        }
//
//        NSArray *assets = results[@"activity_images"];
//        if (assets) {
//            //            for (UIView *view in assets) {
//            //                if (![[self.imageViews subviews] containsObject:view]) {
//            //                    [self.imageViews addSubview:view];
//            //                }
//            //            }
//            [gcell addActivities:assets];
//            //gcell.collectionView.frame = CGRectMake(10, 50, self.view.bounds.size.height - 10, 40);
//            //gcell.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        }
//
//        gcell.displayTableView = self.tableView;
//
//        gcell.sectionIndexPath = indexPath;
//
//        //gcell.odd = (indexPath.item % 2 == 1);
//
//        //gcell.imageView.frame = CGRectMake(0, 0, 3, self.tableView.rowHeight);
//
//        if (shouldLayoutCell) {
//            //[gcell setNeedsLayout];
//            //[gcell layoutIfNeeded];
//            //[cell performSelector:@selector(updateContentsDisplayWithRect:) withObject:nil];
//        }
//
//
//        //});
//        //if (gcell.needsToDraw) {
//        //        [cell performSelector:@selector(updateContentsDisplayWithRect:) withObject:[NSValue valueWithCGRect:cell.frame]];
//        //       gcell.needsToDraw = NO;
//        //   }
//        
//        
//        // });
//    });
    return cell;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [GVTintColorUtility applyNavigationBarTintColor:self.navigationController.navigationBar];

    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self setAddButton];
        [self setSettingsButton];
    });

    if (![PFUser currentUser]) {

        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            GVWelcomeSignupViewController *loginViewController = [[GVWelcomeSignupViewController alloc] initWithNibName:nil bundle:nil];
            [self_weak_ presentViewController:loginViewController animated:YES completion:nil];
        });
    } else if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
    }

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(showSettingsNotification:) name:GVNavigationProfileViewSettingsTapNotification object:nil];
    [nc addObserver:self selector:@selector(tapToSend:) name:GVMasterSectionHeaderViewTapToSendNotification object:nil];
    [nc addObserver:self selector:@selector(sectionSelect:) name:GVMasterSectionHeaderSelectNotification object:nil];
    [nc addObserver:self selector:@selector(masterCellSelectNotification:) name:GVMasterTableViewCellCollectionSelectNotification object:nil];
    [nc addObserver:self selector:@selector(masterCellTouchNotification:) name:GVMasterTableViewCellCollectionTouchNotification object:nil];
    [nc addObserver:self selector:@selector(deleteThreadRequestNotification:) name:GVMasterViewControllerDeleteThreadRequestNotification object:nil];


}

- (void)deleteThreadRequestNotification:(NSNotification*)notif {
    NSDictionary *info = [notif userInfo];

    NSIndexPath *sectionIndexPath = info[@"sectionIndexPath"];
    if (sectionIndexPath) {
        [self.modelObject masterViewControllerDeleteItemAtIndexPath:sectionIndexPath];
    }
}

- (void)masterCellSelectNotification:(NSNotification*)notif {
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    @weakify(blockOperation);
    @weakify(self);

    [blockOperation addExecutionBlock:^{

        if ([blockOperation_weak_ isCancelled]) {
            return;
        }
        @strongify(self);

        [self.operationQueue cancelAllOperations];
        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;

        NSDictionary *info = [notif userInfo];
        //PFObject *reaction = [self.userImageFiles objectAtIndex:indexPath.row];
        //NSString *url = (NSString*)[[reaction objectForKey:kGVActivityVideoKey] url];
        //NSDictionary *info = @{@"url": url};
        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerCellSelectNotification object:nil userInfo:info];
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)masterCellTouchNotification:(NSNotification*)notif {
    NSDictionary *info = [notif userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerCellTouchNotification object:nil userInfo:info];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;

    [self.settingsPopoverController dismissPopoverAnimated:NO];
    self.settingsPopoverController = nil;
    self.settingsPopoverController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSettingsNotification:(NSNotification*)notif {
    [self showSettings:nil];
}

- (void)showSettings:(id)sender {
    @weakify(self);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

        if (self.settingsPopoverController) {
            return;
        }

        UIStoryboard *settings = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        UIViewController *initVC = [settings instantiateInitialViewController];
        UINavigationBar *navBar = [initVC performSelector:@selector(navigationBar)];
        navBar.translucent = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popoverToDismiss:) name:GVSettingsTableViewControllerDismissNotification object:nil];

        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:initVC];
        self.settingsPopoverController = popover;
        self.settingsPopoverController.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [popover presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            //UIStoryboard *settings = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
            //UIViewController *initVC2 = [settings instantiateInitialViewController];
            //if (!self.settingsNavigationController ) {
            GVSettingsViewController *sc = [[GVSettingsViewController alloc] initWithNibName:nil bundle:nil];
            //GVSettingsTableViewController *tc = [[GVSettingsTableViewController alloc] initWithStyle:UITableViewStylePlain];
            GVSettingsNavigationController *initVC = [[GVSettingsNavigationController alloc] initWithNavigationBarClass:nil toolbarClass:nil];
            //UIViewController *blankVC = [[UIViewController alloc] initWithNibName:nil bundle:nil];
            //blankVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(someDone:)];
            [initVC pushViewController:sc animated:NO];
            self.settingsNavigationController = initVC;
            //    self.settingsNavView = self.settingsNavigationController.view;
                //self.settingsNavigationController.reusabelViewSnapshot = [self.settingsNavView snapshotViewAfterScreenUpdates:YES];
            //}
            //self.navigationController.parentViewController.definesPresentationContext = YES;
            //self.navigationController.parentViewController.modalPresentationStyle = UIModalPresentationFormSheet;
            //self.navigationController.parentViewController.providesPresentationContextTransitionStyle = YES;
            //self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            //self.navigationController.definesPresentationContext = NO;
            //self.navigationController.providesPresentationContextTransitionStyle = NO;
            //self.modalPresentationStyle = UIModalPresentationFullScreen;
            //self.providesPresentationContextTransitionStyle = NO;
            //self.definesPresentationContext = NO;
//            self.parentViewController.parentViewController.definesPresentationContext = YES;
//            self.parentViewController.parentViewController.providesPresentationContextTransitionStyle = YES;
//            self.parentViewController.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//            self.parentViewController.definesPresentationContext = NO;
//            self.parentViewController.providesPresentationContextTransitionStyle = NO;
//self.definesPresentationContext = NO;
            
            //self.providesPresentationContextTransitionStyle = NO;
            //self.modalPresentationStyle = UIModalPresentationCurrentContext;
            //initVC.transitioningDelegate = self.view.window.rootViewController;
            [self.view.window.rootViewController presentViewController:initVC animated:YES completion:^{
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    @strongify(self);
//                    initVC.presentingViewController.definesPresentationContext = YES;
//                    initVC.presentingViewController.providesPresentationContextTransitionStyle = YES;
//                    initVC.presentingViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//                    initVC.definesPresentationContext = NO;
//                    initVC.providesPresentationContextTransitionStyle = NO;
//                    initVC.modalPresentationStyle = UIModalPresentationCurrentContext;
//                    [tc.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//                });
            }];
        });
        //[self endEditingCells];
        //[self setEditing:NO animated:YES];
    }
}

- (void)someDone:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)popoverToDismiss:(NSNotification*)notif {
    [self.settingsPopoverController dismissPopoverAnimated:YES];
    self.settingsPopoverController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GVSettingsTableViewControllerDismissNotification object:nil];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"dismissed popover");
    self.settingsPopoverController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GVSettingsTableViewControllerDismissNotification object:nil];
}

- (void)endEditingCells {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        [cell setEditing:NO animated:YES];
    }
}

- (void)pullUpAnimation {
    //[sell setEditing:NO animated:YES];
    [self endEditingCells];

}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.y < -90) {
//        [self pullUpAnimation];
//        //[self playCoffeeSound];
//    }
//}

- (void)insertNewObject:(id)sender {
    [self pullUpAnimation];
    return;
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    @weakify(operation);
    @weakify(self);
    [operation addExecutionBlock:^{
        @strongify(operation);
        if ([operation isCancelled]) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);

            [TestFlight passCheckpoint:@"New Thread Action"];

            GVVideoCameraViewController *cameraUI = [[GVVideoCameraViewController alloc] initWithNavigationBarClass:nil toolbarClass:nil];

            [self presentViewController:cameraUI animated:YES completion:nil];
        });
    }];
    [self.operationQueue addOperation:operation];
}



//- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
//{
//    if (error) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
//        [alert show];
//    } else {
//        [self.modelObject masterViewControllerNewThreadWithVideoPath:videoPath];
//    }
//}


#pragma mark - Table View

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        UIActionSheet *deleteSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
//        [deleteSheet showInView:self.view.window];
//        @weakify(self);
//        self.deleteBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @strongify(self);
//                [self.modelObject masterViewControllerDeleteItemAtIndexPath:indexPath];
//            });
//        }];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@" action sheet button index %@", [NSNumber numberWithInteger:buttonIndex]);
    if (buttonIndex == 0 && !self.deleteBlockOperation.isExecuting) {
        [self.deleteBlockOperation start];
        self.deleteBlockOperation = nil;
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    self.deleteBlockOperation = nil;
}


//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    if (action == @selector(saveAction:)) {
//            return YES;
//    }
//    return (action == @selector(inviteAction:));
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    DLogObject(indexPath);
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    DLogFunctionLine();
//}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    NSLog(@"didSelect %@", indexPath);
//        
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    // this should just post a notification with the userinfo of the index to the model object
//    //NSDictionary *info = @{@"indexPath": indexPath};
//
//}

@end
