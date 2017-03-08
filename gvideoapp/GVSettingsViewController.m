//
//  GVSettingsViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/13/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSettingsViewController.h"
#import "GVSettingsView.h"
#import "GVSettingsTableViewController.h"
#import "GVTwitterAuthUtility.h"

@interface GVSettingsViewController () <GVSettingsViewDelegateProtocol>

@property (nonatomic, strong) GVSettingsView *view;
@property (nonatomic, strong) GVSettingsTableViewController *tableViewController;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation GVSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)loadView {
    self.view = [[GVSettingsView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = @"Settings";
    self.navigationItem.title = self.title;
    self.view.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.0];

    self.view.usernameLabel.text = [[PFUser currentUser] username];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    self.view.settingsDelegateProtocol = self;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];


    @weakify(self);
    [GVTwitterAuthUtility shouldGetProfileImageForCurrentUserBlock:^(NSURL *imageURL, NSURL *bannerURL, NSString* realName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.view.profilePicView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                @strongify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self.view setupProfilePicLoaded];
                    [self.view.profilePicView setNeedsDisplay];
                    [self.view setNeedsDisplay];
                });
            }];
            if (bannerURL && [bannerURL isKindOfClass:[NSURL class]] && [[bannerURL absoluteString] length] > 0) {
                [self.view.imageView sd_setImageWithURL:bannerURL placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageHighPriority];
                self.view.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            self.view.realNameLabel.text = realName;
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];

            //@strongify(self);
            //if (image) {
            //[self.profileImageView setImage:image];
            //self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;

            //@strongify(self);
//            CGSize headerViewSize = CGSizeMake(320, 300);
//            UIImage *backgroundImage = [UIColor imageWithColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
//            NSArray *pages = @[[self createPageViewWithText:realName],
//                               [self createPageViewWithText:@"Second page"],
//                               [self createPageViewWithText:@"Third page"],
//                               [self createPageViewWithText:@"Fourth page"]];
//
//            MEExpandableHeaderView *headerView = [[MEExpandableHeaderView alloc] initWithSize:headerViewSize
//                                                                              backgroundImage:[UIImage imageNamed:@"Default.png"]
//                                                                                 contentPages:pages];
//            headerView.pageControl.hidden = YES;
//            headerView.pagesScrollView.pagingEnabled = NO;
//            headerView.pagesScrollView.scrollEnabled = NO;
//            headerView.pagesScrollView.userInteractionEnabled = NO;
//
//            headerView.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
//            headerView.contentScaleFactor = 0.5;
//            headerView.clipsToBounds = YES;
//            self.tableView.tableHeaderView = headerView;
//            self.headerView = headerView;
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

    self.tableViewController = [[GVSettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.tableViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view setupSettingsTableViewController:self.tableViewController];
    [self addChildViewController:self.tableViewController];
    [self.tableViewController didMoveToParentViewController:self];


//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];

}


- (void)viewDidMoveToWindow {
    if (self.view.window) {
        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }
}


//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//
//    self.operationQueue = [NSOperationQueue new];
//    self.operationQueue.maxConcurrentOperationCount = 1;
//}

- (void)doneButtonPressed:(id)sender {
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    @weakify(blockOperation);

    [blockOperation addExecutionBlock:^{

        if ([blockOperation_weak_ isCancelled]) {
            return;
        }

        [self.operationQueue cancelAllOperations];
        self.operationQueue = nil;

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
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
