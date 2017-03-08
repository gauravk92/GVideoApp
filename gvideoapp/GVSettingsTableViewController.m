//
//  GVSettingsTableViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/28/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSettingsTableViewController.h"
#import "GVAppDelegate.h"
#import "GVSettingsUtility.h"
#import "GVTwitterAuthUtility.h"
#import "GVParseObjectUtility.h"
#import "GVSettingsTableViewCellButtonView.h"
#import "MBProgressHUD.h"
#import "GVSettingsTableViewCell.h"
#import "GVTintColorUtility.h"
#import "MEExpandableHeaderView.h"
#import <AddressBookUI/AddressBookUI.h>
#import "UIColor+Image.h"
#import "GVSettingsTableHeaderView.h"
#import "GVSettingsTableFooterView.h"
#import "GVTwitterAuthUtility.h"

NSString *const GVSettingsTableViewControllerCellIdentifier = @"GVSettingsTableViewControllerCellIdentifier";
NSString *const GVSettingsTableViewControllerDismissNotification = @"com.gvideoapp.popoversettingsdismiss";
NSString *const GVSettingsTableViewControllerHeaderIdentifier = @"GVSettingsTableViewControllerHeaderIdentifier";
NSString *const GVSettingsTableViewControllerFooterIdentifier = @"GVSettingsTableViewControllerFooterIdentifier";

@interface GVSettingsTableViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) UIActionSheet *currentActionSheet;
@property (nonatomic, weak) UIAlertView *logoutAlertView;
@property (nonatomic, weak) UIAlertView *deleteAlertView;
@property (nonatomic, weak) UIAlertView *clearCacheAlertView;
@property (nonatomic, weak) UIAlertView *leavingAlertView;
@property (nonatomic, weak) UIAlertView *leavingSupportAlertView;
@property (nonatomic, weak) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) UILongPressGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) CGFloat bounceZoomViewHeight;
@property (nonatomic, strong) MEExpandableHeaderView *headerView;
@property (nonatomic, retain) NSArray *elementsList;
@property (nonatomic, weak) UIAlertView *leavingTwitterAlertView;
@property (nonatomic, weak) UIAlertView *leavingFacebookAlertView;
@property (nonatomic, weak) UIAlertView *leavingInstagramAlertView;
@property (nonatomic, weak) UIAlertView *cameraImageAlertView;

@property (nonatomic, assign) CGPoint initialContentOffset;

@property (nonatomic, strong) UIImage *socialMediaButtonImage;

@end

@implementation GVSettingsTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    //self.profileImageView.exclusiveTouch = YES;
    self.tableView.exclusiveTouch = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor clearColor];

    self.tableView.layer.needsDisplayOnBoundsChange = NO;
    //self.automaticallyAdjustsScrollViewInsets = NO;
    //self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//
//    self.usernameLabel.layer.shouldRasterize = YES;
//    self.usernameLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
//
//    self.profileImageView.layer.cornerRadius = 50;
//    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.profileImageView.layer.borderWidth = 4;
//    self.profileImageView.clipsToBounds = YES;
//    self.profileImageView.userInteractionEnabled = YES;
//
//    self.bounceZoomViewHeight = self.bounceZoomView.bounds.size.height;


    self.tableView.rowHeight = 70;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(-100, 0, 0, 0);

    [self.tableView registerClass:[GVSettingsTableViewCell class] forCellReuseIdentifier:GVSettingsTableViewControllerCellIdentifier];
    [self.tableView registerClass:[GVSettingsTableFooterView class] forHeaderFooterViewReuseIdentifier:GVSettingsTableViewControllerHeaderIdentifier];
    [self.tableView registerClass:[GVSettingsTableHeaderView class] forHeaderFooterViewReuseIdentifier:GVSettingsTableViewControllerFooterIdentifier];

    [self setupElements];
    [self setupHeaderView];
}

#pragma mark - Setup

- (void)setupHeaderView
{
    NSString *username = [[PFUser currentUser] objectForKey:@"username"];
    //self.usernameLabel.text = username;
    @weakify(self);
    [GVTwitterAuthUtility shouldGetProfileImageForCurrentUserBlock:^(NSURL *imageURL, NSURL *bannerURL, NSString* realName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //@strongify(self);
            //if (image) {
            //[self.profileImageView setImage:image];
            //self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;

            @strongify(self);
            CGSize headerViewSize = CGSizeMake(320, 330);
            UIImage *backgroundImage = [UIColor imageWithColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
            NSArray *pages = @[[self createPageViewWithText:realName],
                               [self createPageViewWithText:@"Second page"],
                               [self createPageViewWithText:@"Third page"],
                               [self createPageViewWithText:@"Fourth page"]];

            MEExpandableHeaderView *headerView = [[MEExpandableHeaderView alloc] initWithSize:headerViewSize
                                                                              backgroundImage:[UIImage imageNamed:@"Default.png"]
                                                                                 contentPages:pages];
            headerView.pageControl.hidden = YES;
            headerView.pagesScrollView.pagingEnabled = NO;
            headerView.pagesScrollView.scrollEnabled = NO;
            headerView.pagesScrollView.userInteractionEnabled = NO;

            headerView.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
            headerView.contentScaleFactor = 0.5;
            headerView.clipsToBounds = YES;
            headerView.hidden = YES;
            self.tableView.tableHeaderView = headerView;
            self.headerView = headerView;
//
//            @weakify(headerView);
//            [headerView.backgroundImageView setImageWithURL:bannerURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                @strongify(headerView);
//                headerView.backgroundImageView.image = image;
//            }];


//
//            [self.profileImageView setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                @strongify(self);
//                [self.activityIndicatorView stopAnimating];
//                self.activityIndicatorView.hidden = YES;
//                self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
//            }];
//
//            //[self.bannerImageView setImage:banner];
//            //self.bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
//
//            [self.bannerImageView setImageWithURL:bannerURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                self.bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
//            }];
//
//            [self.usernameLabel setText:realName];

            //  [self.activityIndicatorView stopAnimating];
            //  self.activityIndicatorView.hidden = YES;
            //}
        });
    }];

}

- (void)setupElements
{
    self.elementsList = @[@"Row 1", @"Row 2", @"Row 3", @"Row 4", @"Row 5", @"Row 6", @"Row 7", @"Row 8", @"Row 9", @"Row 10"];
}


#pragma mark - Content

- (UIView*)createPageViewWithText:(NSString*)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];

    label.font = [UIFont boldSystemFontOfSize:27.0];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.text = text;

    return label;
}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//	if (scrollView == self.tableView)
//	{
//        NSLog(@"header scroll %@", [NSValue valueWithCGPoint:scrollView.contentOffset]);
//        [self.headerView offsetDidUpdate:scrollView.contentOffset];
//        if (CGPointEqualToPoint(CGPointZero, self.initialContentOffset)) {
//            self.initialContentOffset = scrollView.contentOffset;
//        }
//        if (scrollView.contentOffset.y < self.initialContentOffset.y) {
//            CGFloat diff = self.initialContentOffset.y + scrollView.contentOffset.y;
//            CGRect rect = CGRectMake(0, -(diff), self.tableView.frame.size.width, 260 + diff);
//            self.headerView.frame = rect;
//        }
//	}
//}


- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}


- (void)profilePicTap:(UIGestureRecognizer*)gc {
    CGFloat toolbarSize = 100;
    CGFloat toolbarSizeS = 110;

    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

//    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
//    animGroup.duration = 1.0;
//    //animGroup.repeatDuration = 99999;
//    //animGroup.repeatCount = 99999;
//    animGroup.removedOnCompletion = NO;
//    animGroup.fillMode = kCAFillModeForwards;
//    animGroup.timingFunction = [CAMediaTimingFunction functionWithName:@"linear"];
    //animGroup.autoreverses = YES;


//    CAKeyframeAnimation *keyFrameAnim = [CAKeyframeAnimation animationWithKeyPath:@"cornerRadius"];
//
//    keyFrameAnim.duration = animGroup.duration;
//    keyFrameAnim.repeatCount = animGroup.repeatCount;
//    keyFrameAnim.repeatDuration = animGroup.repeatDuration;
//    keyFrameAnim.fillMode = kCAFillModeForwards;
//    keyFrameAnim.removedOnCompletion = NO;
//    keyFrameAnim.autoreverses = YES;
//
//    keyFrameAnim.keyTimes = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0]];
//    keyFrameAnim.values = @[[NSNumber numberWithFloat:toolbarSize / 2], [NSNumber numberWithFloat:toolbarSizeS / 2]];
//
    CATransform3D t1 = CATransform3DIdentity;
    //t1.m34 = 1.0 / m34multiplier;
    t1 = CATransform3DScale(t1, 1.0, 1.0, 1);

    CATransform3D t2 = CATransform3DIdentity;
    //t1.m34 = 1.0 / m34multiplier;
    t2 = CATransform3DScale(t2, 1.1, 1.1, 1);

    CAKeyframeAnimation *keyScaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    keyScaleAnim.duration = 0.25;
    //keyScaleAnim.repeatDuration = animGroup.repeatDuration;
    //keyScaleAnim.repeatCount = animGroup.repeatCount;
    keyScaleAnim.removedOnCompletion = NO;
    keyScaleAnim.autoreverses = YES;
    keyScaleAnim.timingFunction = [CAMediaTimingFunction functionWithName:@"linear"];
    keyScaleAnim.fillMode = kCAFillModeForwards;



    keyScaleAnim.keyTimes = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0]];
    keyScaleAnim.values = @[[NSValue valueWithCATransform3D:t1],
                            [NSValue valueWithCATransform3D:t2]];

    //animGroup.animations = @[keyScaleAnim];
    //[self.profileImageView.layer addAnimation:keyScaleAnim forKey:nil];

}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
////        CGFloat offset = scrollView.contentOffset.y;
////        CGFloat newHeight = self.bounceZoomViewHeight - offset;
////        if (newHeight < self.bounceZoomViewHeight) {
////            newHeight = self.bounceZoomViewHeight;
////        }
////
////        CGRect bounceRect = self.bounceZoomView.bounds;
////        bounceRect.origin.y = -1*(newHeight - self.bounceZoomViewHeight);
////        bounceRect.size.height = newHeight;
////        self.bounceZoomView.frame = CGRectIntegral(bounceRect);
//        CGFloat HeaderHeight = self.bounceZoomViewHeight;
//        CGFloat yPos = -scrollView.contentOffset.y;
//        if (yPos > 0) {
//            CGRect imgRect = self.bounceZoomView.frame;
//            imgRect.origin.y = scrollView.contentOffset.y;
//            imgRect.size.height = HeaderHeight+yPos;
//            self.bounceZoomView.frame = imgRect;
//            self.bannerImageView.frame = self.bounceZoomView.bounds;
//            //[self.bounceZoomView updateConstraints];
//        }
//    });
//}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
//// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}
//
//// called once per attempt to recognize, so failure requirements can be determined lazily and may be set up between recognizers across view hierarchies
//// return YES to set up a dynamic failure requirement between gestureRecognizer and otherGestureRecognizer
////
//// note: returning YES is guaranteed to set up the failure requirement. returning NO does not guarantee that there will not be a failure requirement as the other gesture's counterpart delegate or subclass methods may return YES
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (gestureRecognizer == self.tapGestureRecognizer) {
//        return YES;
//    }
//    return NO;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (otherGestureRecognizer == self.tapGestureRecognizer) {
//        return <#expression#>
//    }
//}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if (gestureRecognizer.view == self.profileImageView) {
//        return YES;
//    }
//    return NO;
//}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)doneButtonPressed:(id)sender {
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GVSettingsTableViewControllerDismissNotification object:nil];
//        if ([self.popoverSettingsDelegate respondsToSelector:@selector(dismissSettingsPopover:)]) {
//            [self.popoverSettingsDelegate performSelector:@selector(dismissSettingsPopover:) withObject:self];
//        }
//} else {
        //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
        //@weakify(self);
        //dispatch_async(dispatch_get_main_queue(), ^{
        //    [self_weak_.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        //});
        //}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        CGFloat contentInset = self.tableView.contentInset.top;
        if (contentInset < 0) {
            contentInset = contentInset *-1;
        }
        [self.tableView setContentOffset:CGPointMake(0, 0 + contentInset)];
    });
//    [GVTwitterAuthUtility shouldGetProfileBannerForUser:username block:^(UIImage *image) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @strongify(self);
//            if (image) {
//                [self.bannerImageView setImage:image];
//                self.bannerImageView.contentMode = UIViewContentModeScaleAspectFit;
//            }
//        });
//    }];


//    [GVTwitterAuthUtility updateProfileImageForCurrentUserWithCompletion:[NSBlockOperation blockOperationWithBlock:^{
//        [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//            PFFile *profilePic = [object objectForKey:kGVUserProfilePictureKey];
//            if (profilePic) {
//                [profilePic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                    if (!error) {
//                        UIImage *image = [UIImage imageWithData:data];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            @strongify(self);
//                            [self.profileImageView setImage:image];
//                            self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
//                            [self.activityIndicatorView stopAnimating];
//                            self.activityIndicatorView.hidden = YES;
//                        });
//                        // image can now be set on a UIImageView
//                    }
//                }];
//
//            }
//        }];
//    }]];
//
//    @weakify(self);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        UIImage *profileImage = [[FHSTwitterEngine sharedEngine] getProfileImageForUsername:username andSize:FHSTwitterEngineImageSizeOriginal];
//        NSURL *profileImageURL = [[FHSTwitterEngine sharedEngine] getProfileImageURLStringForUsername:username andSize:FHSTwitterEngineImageSizeOriginal];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @strongify(self);
//            [self.activityIndicatorView stopAnimating];
//            if ([profileImage isKindOfClass:[UIImage class]]) {
//                [self.profileImageView setImage:profileImage];
//
//            } else {
//                NSLog(@"error %@", profileImage);
//            }
//            NSLog(@"url object %@", profileImageURL);
//        });
//    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];


//    self.tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(profilePicTap:)];
//    self.tapGestureRecognizer.minimumPressDuration = 0.01;
//    self.tapGestureRecognizer.delegate = self;
//    self.tapGestureRecognizer.cancelsTouchesInView = NO;
//    [self.profileImageView addGestureRecognizer:self.tapGestureRecognizer];

    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

//    [self.profileImageView removeGestureRecognizer:self.tapGestureRecognizer];
//    self.tapGestureRecognizer = nil;

    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    CGFloat normalAmount = 6;
    if (TESTING_ACCOUNT) {
        return normalAmount + 1;
    }
    return normalAmount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//
//    [self.tableView reloadData];
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //[self.tableView reloadData];
}

- (NSString*)settingsTableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
//        case 0: {
//            return @"Camera Settings";
//            break;
//        }
        case 0: {
            return @"About";

            break;
        }
        case 3: {
            return @"Data Settings";
            break;
        }
        case 4: {
            return @"Account Settings";
            break;
        }
        case 5: {
            return @"Camera Roll Settings";
            break;
        }
        case 6: {
            return @"Set Camera Image";
        }
        default: {
            return @"";
            break;
        }
    }
}

- (NSString*)settingsTableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
//        case 0: {
//            return ([GVSettingsUtility selfieMode] ? @"Currently showing front camera first" : @"Currently showing back camera first");
//        }
        case 3: {
            return ([GVSettingsUtility shouldSaveNewCaptures] ? @"Currently saving new videos to the Camera Roll" : @"Currently not saving new videos to the Camera Roll");
            break;
        }
        default: {
            return nil;
            break;
        }
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GVSettingsTableHeaderView *headerView = [[GVSettingsTableHeaderView alloc] initWithReuseIdentifier:GVSettingsTableViewControllerHeaderIdentifier];

    headerView.stringLabel.text = [self settingsTableView:tableView titleForHeaderInSection:section];
    //headerView.backgroundColor = [UIColor whiteColor];

    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    GVSettingsTableFooterView *footerView = [[GVSettingsTableFooterView alloc] initWithReuseIdentifier:GVSettingsTableViewControllerFooterIdentifier];
    footerView.stringLabel.text = [self settingsTableView:tableView titleForFooterInSection:section];
    //headerView.backgroundColor = [UIColor whiteColor];


    return footerView;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([[self settingsTableView:tableView titleForFooterInSection:section] length] > 0) {
        //if (section == 0) {
            return 40;
        //}
        //return 50;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[self settingsTableView:tableView titleForHeaderInSection:section] length] > 0) {
        return 30;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(GVSettingsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    for (UIView *subview in cell.contentView.subviews) {
//        [subview removeFromSuperview];
//    }


    //[cell setNeedsLayout];
    //[cell.mainView setNeedsLayout];
    //[cell layoutIfNeeded];
    //[cell.contentView setNeedsLayout];
    //[cell.contentView layoutIfNeeded];
    //[cell.mainView layoutIfNeeded];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    GVSettingsTableViewCell *cell = (GVSettingsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:GVSettingsTableViewControllerCellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    
    cell.layer.needsDisplayOnBoundsChange = NO;
    //cell.layer.shouldRasterize = YES;
    //cell.layer.rasterizationScale = [UIScreen mainScreen].scale;

    cell.accessoryType = UITableViewCellAccessoryNone;

    switch (indexPath.section) {
//        case 0: {
//            UISwitch *switchView = [self switchForCell:cell withTitle:@"Front Camera First" action:@selector(selfieModeAction:)];
//            switchView.on = [GVSettingsUtility selfieMode];
//            break;
//        }
        case 0: {
            [self buttonForCell:cell withTitle:@"FAQ & Support" color:[GVTintColorUtility utilityPurpleColor] action:@selector(supportAction:)];
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1: {
            [self buttonForCell:cell withTitle:@"About Gvideo" color:[GVTintColorUtility utilityPurpleColor] action:@selector(aboutUsAction:)];
            break;
        }
        case 2: {
            [self buttonForCell:cell withTitle:@"Follow Us" color:[GVTintColorUtility utilityPurpleColor] action:@selector(facebookButton:forEvent:)];
            break;
        }
        case 3: {
            UISwitch *switchView = [self switchForCell:cell withTitle:@"Save new captures" action:@selector(saveNewCapturesAction:)];
            switchView.on = [GVSettingsUtility shouldSaveNewCaptures];
            break;
        }
        case 4: {
            [self buttonForCell:cell withTitle:@"Log Out" color:nil action:@selector(clearCacheAction:)];
            break;
        }
        case 5: {
            [self buttonForCell:cell withTitle:@"Delete Account" color:[UIColor redColor] action:@selector(deleteAccountAction:)];
            break;
        }
        case 6: {
            [self buttonForCell:cell withTitle:@"Set Camera Image" color:[UIColor blueColor] action:@selector(cameraImageAction:)];
        }
        default: {
            break;
        }
    }

    return cell;
}

- (UISwitch*)switchForCell:(GVSettingsTableViewCell*)cell withTitle:(NSString*)title action:(SEL)action {
    cell.actionSel = action;
    cell.textLabel.text = title;
    cell.button.hidden = YES;
    cell.uiSwitch.hidden = NO;
    cell.uiSwitch.opaque = YES;
    cell.uiSwitch.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.accessoryView.hidden = NO;
    
    for (id target in [cell.uiSwitch allTargets]) {
        [cell.uiSwitch removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
    }
    
    [cell.uiSwitch addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    
    return cell.uiSwitch;
}

- (void)buttonForCell:(GVSettingsTableViewCell*)cell withTitle:(NSString*)title color:(UIColor*)color action:(SEL)action {
    cell.actionSel = action;
    //cell.button.tintColor = color;
    //cell.button.adjustsImageWhenHighlighted = YES;
    NSString *titleString = title;
    //cell.button.adjustsImageWhenDisabled = YES;
    //cell.button.adjustsImageWhenHighlighted = YES;
    //cell.button.showsTouchWhenHighlighted = YES;
    if ([title isEqualToString:@"Follow Us"]) {
        titleString = @"";
        //cell.button.adjustsImageWhenHighlighted = NO;
        //cell.button.adjustsImageWhenDisabled = NO;
        //cell.button.showsTouchWhenHighlighted = NO;
        CGFloat buttonWidth = CGRectGetWidth(cell.bounds) / 3;
        
        CGRect buttonRect = cell.bounds;
        buttonRect.size.width = buttonWidth;
        cell.button.frame = CGRectIntegral(buttonRect);
        [cell.button setImage:[[UIImage imageNamed:@"lineicons_facebook"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        
        if (!cell.secondButton.superview) {
            [cell addSubview:cell.secondButton];
        }
        
        CGRect secondRect = cell.bounds;
        secondRect.origin.x = buttonWidth;
        secondRect.size.width = buttonWidth;
        cell.secondButton.frame = CGRectIntegral(secondRect);
        [cell.secondButton setImage:[[UIImage imageNamed:@"lineicons_twitter"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        cell.secondButton.tintColor = color;
        
        for (id target in [cell.secondButton allTargets]) {
            [cell.secondButton removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
        }
        
        [cell.secondButton addTarget:self action:@selector(twitterButton:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        if (!cell.thirdButton.superview) {
            [cell addSubview:cell.thirdButton];
        }
        
        CGRect thirdRect = cell.bounds;
        thirdRect.origin.x = buttonWidth*2;
        thirdRect.size.width = buttonWidth;
        cell.thirdButton.frame = CGRectIntegral(thirdRect);
        [cell.thirdButton setImage:[[UIImage imageNamed:@"lineicons_instagram"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        cell.thirdButton.tintColor = color;
        
        for (id target in [cell.thirdButton allTargets]) {
            [cell.thirdButton removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
        }
        
        [cell.thirdButton addTarget:self action:@selector(instagramButton:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    //cell.textLabel.tintColor = color;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:titleString attributes:cell.customTextAttributes];
    [cell.button setAttributedTitle:attrString forState:UIControlStateNormal];
    [cell.button setTintColor:color];
    //cell.textLabel.text = title;

    for (id target in [cell.button allTargets]) {
        [cell.button removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
    }
    [cell.button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    cell.uiSwitch.hidden = YES;
    cell.button.hidden = NO;
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.opaque = YES;

    cell.accessoryView.hidden = YES;
}

- (void)cameraImageAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Set Camera Image" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Use Clipboard", @"Use URL", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
    self.cameraImageAlertView = alert;
    
}

- (void)facebookButton:(id)sender forEvent:(UIEvent*)event {
    [self facebookButtonAction:sender];
}

- (void)twitterButton:(id)sender forEvent:(UIEvent*)event {
    [self twitterButtonAction:sender];
}

- (void)instagramButton:(id)sender forEvent:(UIEvent*)event {
    [self instagramButtonAction:sender];
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//
//    if (section != 0) {
//        return nil;
//    }
//
//    UIView *footerView;
//
//    NSString *footerText = NSLocalizedString(@"Currently not saving new captures to the Camera Roll", nil);
//
//    // set the container width to a known value so that we can center a label in it
//    // it will get resized by the tableview since we set autoresizeflags
//    float footerWidth = 150.0f;
//    float padding = 10.0f; // an arbitrary amount to center the label in the container
//
//    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, footerWidth, 44.0f)];
//    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//
//    // create the label centered in the container, then set the appropriate autoresize mask
//    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, footerWidth - 2.0f * padding, 44.0f)];
//    footerLabel.font = [footerLabel.font fontWithSize:12];
//    footerLabel.textColor = [UIColor colorWithWhite:0.333 alpha:1.000];
//    footerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    footerLabel.textAlignment = NSTextAlignmentCenter;
//    footerLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    footerLabel.text = [footerText uppercaseStringWithLocale:[NSLocale currentLocale]];
//
//    [footerView addSubview:footerLabel];
//    //[footerLabel sizeToFit];
//    //[footerView sizeToFit];
//
//    return footerView;
//}

- (void)supportAction:(id)sender {
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(self);
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if ([blockOperation_weak_ isCancelled]) {
                return;
            }
            
            //            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            //                [[NSNotificationCenter defaultCenter] postNotificationName:GVAboutUsPadNotification object:nil];
            //            } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open in Safari" message:@"This will leave the application" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Safari", nil];
            
            self.currentActionSheet = alertView;
            self.leavingSupportAlertView = alertView;
            
            [alertView show];
            
            
            //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:nil];
            //UIViewController *initialVC = [storyboard instantiateInitialViewController];
            //[self.navigationController pushViewController:initialVC animated:YES];
            //}
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)aboutUsAction:(id)sender {
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(self);
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if ([blockOperation_weak_ isCancelled]) {
                return;
            }

//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:GVAboutUsPadNotification object:nil];
//            } else {

                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open in Safari" message:@"This will leave the application" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Safari", nil];

                self.currentActionSheet = alertView;
                self.leavingAlertView = alertView;

                [alertView show];


                //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:nil];
                //UIViewController *initialVC = [storyboard instantiateInitialViewController];
                //[self.navigationController pushViewController:initialVC animated:YES];
            //}
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)facebookButtonAction:(id)sender {
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(self);
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if ([blockOperation_weak_ isCancelled]) {
                return;
            }
            
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:GVAboutUsPadNotification object:nil];
//            } else {
            BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
            
            if (isInstalled) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open in Facebook" message:@"This will leave the application" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Facebook", nil];
                
                self.currentActionSheet = alertView;
                self.leavingFacebookAlertView = alertView;
                
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open in Safari" message:@"This will leave the application" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Safari", nil];
                
                self.currentActionSheet = alertView;
                self.leavingFacebookAlertView = alertView;
                
                [alertView show];
            }
            
                
                
                //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:nil];
                //UIViewController *initialVC = [storyboard instantiateInitialViewController];
                //[self.navigationController pushViewController:initialVC animated:YES];
            //}
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)twitterButtonAction:(id)sender {
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(self);
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if ([blockOperation_weak_ isCancelled]) {
                return;
            }
            
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:GVAboutUsPadNotification object:nil];
//            } else {
            BOOL canTwitter = [GVTwitterAuthUtility userHasAccessToTwitter];
            
            if (canTwitter) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open in Twitter" message:@"This will leave the application" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Twitter", nil];
                
                self.currentActionSheet = alertView;
                self.leavingTwitterAlertView = alertView;
                
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open in Safari" message:@"This will leave the application" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Safari", nil];
                
                self.currentActionSheet = alertView;
                self.leavingTwitterAlertView = alertView;
                
                [alertView show];
            }
                
                //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:nil];
                //UIViewController *initialVC = [storyboard instantiateInitialViewController];
                //[self.navigationController pushViewController:initialVC animated:YES];
            //}
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)instagramButtonAction:(id)sender {
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(self);
    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if ([blockOperation_weak_ isCancelled]) {
                return;
            }
            
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:GVAboutUsPadNotification object:nil];
//            } else {
//
            NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open in Instagram" message:@"This will leave the application" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Instagram", nil];
                
                self.currentActionSheet = alertView;
                self.leavingInstagramAlertView = alertView;
                
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Open in Safari" message:@"This will leave the application" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Safari", nil];
                
                self.currentActionSheet = alertView;
                self.leavingInstagramAlertView = alertView;
                
                [alertView show];
            }
            
            
                
                
                //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:nil];
                //UIViewController *initialVC = [storyboard instantiateInitialViewController];
                //[self.navigationController pushViewController:initialVC animated:YES];
//            }
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

//- (void)updateContacts {
////    ABAddressBookRef addressBook;
////    addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
////
////    if (addressBook != Nil)
////    {
////        int howManySocialApps;
////        ABRecordRef who = ABAddressBookGetPersonWithRecordID (addressBook, ABRecordGetRecordID(person));
////
////        NSArray *linkedPeople = (__bridge_transfer NSArray *)ABPersonCopyArrayOfAllLinkedPeople(who);
////
////        for (int x = 0; x < [linkedPeople count]; x++)
////        {
////            ABMultiValueRef socialApps = ABRecordCopyValue((ABRecordRef)[linkedPeople objectAtIndex:x], kABPersonSocialProfileProperty);
////
////            CFIndex thisSocialAppCount = ABMultiValueGetCount(socialApps);
////
////            for (int i = 0; i < thisSocialAppCount; i++)
////            {
////                NSDictionary *socialItem = (__bridge_transfer NSDictionary*)ABMultiValueCopyValueAtIndex(socialApps, i);
////                NSLog(@"Social Item of type %@", [socialItem objectForKey:(NSString *)kABPersonSocialProfileServiceKey]);
////            }
////
////            if (socialApps != Nil)
////                CFBridgingRelease(socialApps);
////
////            howManySocialApps += thisSocialAppCount;
////        }
////
////        NSLog (@"Number of SocialApps Found is %i", howManySocialApps);
////        
////        CFBridgingRelease(addressBook);
////    }
//    /*
//
//     Returns an array of contacts that contain the phone number
//
//     */
//
//    NSString *phoneNumber = @"gauravk92";
//
//    // Remove non numeric characters from the phone number
//    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
//
//    // Create a new address book object with data from the Address Book database
//    CFErrorRef error = nil;
//    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
//    if (!addressBook) {
//        return;
//    } else if (error) {
//        CFBridgingRelease(addressBook);
//        return;
//    }
//
//    // Requests access to address book data from the user
//    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
//
//    // Build a predicate that searches for contacts that contain the phone number
//    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
//        ABMultiValueRef socialApps = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonSocialProfileProperty);
//
//        CFIndex thisSocialAppCount = ABMultiValueGetCount(socialApps);
//
//        for (int i = 0; i < thisSocialAppCount; i++)
//        {
//            NSDictionary *socialItem = (__bridge_transfer NSDictionary*)ABMultiValueCopyValueAtIndex(socialApps, i);
//            NSString *key = [socialItem objectForKey:(NSString *)kABPersonSocialProfileServiceKey];
//            if (key) {
//                NSLog(@"Social Item of type %@", key);
//                if ([key isEqualToString:(NSString*)kABPersonSocialProfileServiceTwitter]) {
//                    NSLog(@"Social name %@", [socialItem objectForKey:(NSString*)kABPersonSocialProfileUsernameKey]);
//                }
//
//                
//
////                if ([key isEqualToString:kABPersonSocialProfileServiceTwitter]) {
////                    NSString *username = ABRecordCopyValue((ABRecordRef)record, kABPersonSocialProfileServiceTwitter);
////                    NSLog(@" username found %@", username);
////                }
//            }
//        }
//
//        if (socialApps != Nil) {
//                CFBridgingRelease(socialApps);
//        }
//
//        //howManySocialApps += thisSocialAppCount;
//
//
//                              // NSLog(@"Number of SocialApps Found is ");
////        ABMultiValueRef phoneNumbers = ABRecordCopyValue( (ABRecordRef)record, kABPersonSocialProfileServiceTwitter);
////        BOOL result = NO;
////        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
////            NSString *contactPhoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
////            contactPhoneNumber = [[contactPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
////            if ([contactPhoneNumber rangeOfString:phoneNumber].location != NSNotFound) {
////                result = YES;
////                break;
////            }
////        }
////        CFBridgingRelease(phoneNumbers);
//        return YES;
//    }];
//
//    // Search the users contacts for contacts that contain the phone number
//    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
//    NSArray *filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
//    CFBridgingRelease(addressBook);
//
//}

//- (void)updateContactsAction:(id)sender {
//
//    // Request authorization to Address Book
//    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//
//    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
//        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//            if (granted) {
//                // First time access has been granted, add the contact
//                //[self _addContactToAddressBook];
//                [self updateContacts];
//            } else {
//                // User denied access
//                // Display an alert telling user the contact could not be added
//            }
//        });
//    }
//    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
//        // The user has previously given access, add the contact
//        //[self _addContactToAddressBook];
//        [self updateContacts];
//    }
//    else {
//        // The user has previously denied access
//        // Send an alert telling user to change privacy setting in settings app
//
//    }
//    CFBridgingRelease(addressBookRef);
//}

- (void)clearCacheAction:(id)sender {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out Confirmation" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    self.clearCacheAlertView = alert;
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)selfieModeAction:(id)sender {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        } else {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        }
    });
    UISwitch *switchObj = (UISwitch*)sender;
    if (switchObj && [switchObj respondsToSelector:@selector(isOn)]) {
        BOOL state = [switchObj isOn];
        [GVSettingsUtility setSelfieMode:state];
    }

    [self.progressHUD hide:YES afterDelay:5.0];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.tableView reloadData];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.progressHUD hide:YES];
        self.progressHUD = nil;
    });
}

- (void)saveNewCapturesAction:(id)sender {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        } else {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        }
    });
    UISwitch *switchObj = (UISwitch*)sender;
    if (switchObj && [switchObj respondsToSelector:@selector(isOn)]) {
        BOOL state = [switchObj isOn];
        [GVSettingsUtility setShouldSaveNewCaptures:state];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.tableView reloadData];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.progressHUD hide:YES];
        self.progressHUD = nil;
    });

}

- (void)logOutAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Confirmation" message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    self.logoutAlertView = alert;
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)deleteAccountAction:(id)sender {

    UIActionSheet *deleteSheet;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        deleteSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete your account? This will delete all existing data tied to this account. This is permanent and irreversible." delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete Account" otherButtonTitles:@"Cancel", nil];
    } else {
    deleteSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete your account? This will delete all existing data tied to this account. This is permanent and irreversible." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Account" otherButtonTitles:nil];
    }
    //if (!self.currentActionSheet) {
    self.currentActionSheet = deleteSheet;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [deleteSheet showInView:self.view.window];
        } else {
            [deleteSheet showInView:self.view.window];
        }
    });
    //}
}
// http://wiki.akosma.com/IPhone_URL_Schemes
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (self.clearCacheAlertView == alertView) {
            [self doneButtonPressed:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVLogOutNotification object:nil];
        } else if (self.deleteAlertView == alertView) {
            // this is a delete account
            NSLog(@" wow you really want to delete your account:%@", [PFUser currentUser]);
            [self doneButtonPressed:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVDeleteAccountNotification object:nil];
    //    } else if (self.clearCacheAlertView == alertView) {
    //        if (buttonIndex == 1) {
    //            // yes sir clearing all caches..
    //            [[NSNotificationCenter defaultCenter] postNotificationName:GVClearCacheNotification object:nil];
    //        }
        } else if (self.leavingAlertView == alertView) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.gvideoapp.com/"]];
        } else if (self.leavingFacebookAlertView == alertView) {
            BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
            
            if (isInstalled) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/355509764597245"]];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/gvideoapp"]];
            }
        } else if (self.leavingTwitterAlertView == alertView) {
            BOOL canTwitter = [GVTwitterAuthUtility userHasAccessToTwitter];
            
            [GVTwitterAuthUtility openTwitterToGvideoapp];
            
        } else if (self.leavingInstagramAlertView == alertView) {
            NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"instagram://user?username=gvideoapp"]];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.instagram.com/gvideoapp"]];
            }
        } else if (self.leavingSupportAlertView == alertView) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://gvideoapp.com/support"]];
        }
    }
    if (alertView == self.cameraImageAlertView) {
        if (buttonIndex > 0) {
            // we have to save the image now...
            // if use clipboard grab from clipboard and just save it to settings somewhere, add a key to the user!
            DLogNSInteger(buttonIndex);
            UIImage *image = nil;
            if (buttonIndex > 1) {
                // use contentURL...
            } else {
                image = [[UIPasteboard generalPasteboard] image];
            }
            [GVParseObjectUtility setCameraImageForCurrentUser:image];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GVClearCacheNotification object:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@" action sheet: %@", actionSheet);
    NSLog(@" button index %i", buttonIndex);
    if (buttonIndex == 0) {
        UIAlertView *deleteAccountAlert = [[UIAlertView alloc] initWithTitle:@"Delete Account Confirmation" message:@"Are you sure you want to delete your account?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete Account", nil];
        self.deleteAlertView = deleteAccountAlert;
        [deleteAccountAlert show];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//        case 0:
//            <#statements#>
//            break;
//        case 1:
//        default:
//            break;
//    }
//}

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
