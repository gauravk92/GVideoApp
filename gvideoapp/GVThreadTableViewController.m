//
//  GVThreadTableViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/2/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVThreadTableViewController.h"
#import "GVThreadTableViewCell.h"
#import "GVVideoCameraViewController.h"
#import "GVParseObjectUtility.h"
#import "GVCircleReactionView.h"
#import "GVReactionPopoverView.h"
#import "GVReactionsTableViewController.h"
#import "GVTwitterAuthUtility.h"

#define REAL_NAVIGATION_CONTROLLER 1

NSString * const GVThreadTableViewControllerCellIdentifier = @"GVThreadTableViewControllerCellIdentifier";

@interface GVThreadTableViewController ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) UIPopoverController *threadPopoverController;

@property (nonatomic, strong) MPMoviePlayerViewController *reactionViewController;
@property (nonatomic, weak) UIImagePickerController *reactionPickerController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) UIPopoverController *reactionPopoverController;

@property (nonatomic, strong) UIPopoverController *reactionsTablePopoverController;

@property (nonatomic, weak) UIView *circleView;


@end

@implementation GVThreadTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization

        self.title = @"Activity";

        //self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactionDidSelectNotification:) name:@"GVThreadCollectionViewCellSelectIdentifier" object:nil];

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)setTableViewRowHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableView.rowHeight = 500 + GVThreadTableViewCellBottomMargin;
    } else {
        self.tableView.rowHeight = 320 + GVThreadTableViewCellBottomMargin;
    }
}

- (void)reactionDidSelectNotification:(NSNotification*)notif {
    NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
    @weakify(blockOperation);
    @weakify(self);
    [blockOperation addExecutionBlock:^{

        if ([blockOperation_weak_ isCancelled]) {
            return;
        }


        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            NSString *url = [[notif userInfo] objectForKey:@"url"];
            if (url) {
                NSDictionary *dict = @{@"URL": url};
                [[NSNotificationCenter defaultCenter] postNotificationName:GVPlayMovieNotification object:nil userInfo:dict];
            } else {
                GVReactionsTableViewController *reactionsVC = [[GVReactionsTableViewController alloc] initWithStyle:UITableViewStylePlain];
                reactionsVC.modelObject = self.modelObject;
                NSIndexPath *indexPath = [[notif userInfo] objectForKey:@"indexPath"];
                reactionsVC.threadId = self.threadId;
                reactionsVC.indexPath = indexPath;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    UINavigationController *popoverNavVC = [[UINavigationController alloc] initWithRootViewController:reactionsVC];
                    self.reactionsTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverNavVC];
                    self.reactionsTablePopoverController.delegate = self;
                    [self.reactionsTablePopoverController presentPopoverFromRect:self.view.bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                } else {
                    [self.navigationController pushViewController:reactionsVC animated:YES];
                }
            }
        });
    }];
    [self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    //self.tableView.contentInset = UIEdgeInsetsMake(16, 0, 16, 0);
    self.tableView.scrollsToTop = YES;

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = footerView;
    self.tableView.backgroundColor = [UIColor whiteColor];

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = backgroundView;

    [self setTableViewRowHeight];

    [self.tableView registerClass:[GVThreadTableViewCell class] forCellReuseIdentifier:GVThreadTableViewControllerCellIdentifier];
#if REAL_NAVIGATION_CONTROLLER


#else
    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 16, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(61, 0, 1, 0);
    self.tableView.showsHorizontalScrollIndicator = YES;
    self.tableView.showsVerticalScrollIndicator = YES;
#endif

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setAddButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self setAddButton];
    });

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.splitViewController.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.splitViewController.delegate = nil;
    }
}

- (void)setAddButton {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_180_facetime_video"] style:UIBarButtonItemStylePlain target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)refreshData:(NSNotification*)notif {
    [self objectsDidLoad:nil];
}

- (void)objectsDidLoad:(id)sender {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    //    if (!_objects) {
    //        _objects = [[NSMutableArray alloc] init];
    //    }
    //    [_objects insertObject:[NSDate date] atIndex:0];
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            cameraUI.threadId = self.threadId;

            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self.splitViewController presentViewController:cameraUI animated:YES completion:nil];
            } else {
                [self presentViewController:cameraUI animated:YES completion:nil];
            }
        });
    }];
    [self.operationQueue addOperations:@[operation] waitUntilFinished:YES];
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.modelObject threadViewControllerRowCount:self.threadId];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(GVThreadTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath activity:(PFObject*)activity objects:(NSDictionary*)objects {

    //PFFile *videoThumb = [activity objectForKey:kGVActivityVideoThumbnailKey];
    //NSString *videoThumbUrl = [videoThumb url];

    cell.threadId = [[activity objectForKey:kGVActivityThreadKey] objectId];

    PFUser *sendUser = [activity objectForKey:kGVActivityUserKey];
    NSString *sendusername = [sendUser username];
    [cell setSendUsernameText:sendusername];

    NSString *timeLabel;
    if (objects) {
        timeLabel = [objects objectForKey:@"activity_time"];
        [cell setTimeLabelString:timeLabel];
        [cell addActivities:[objects objectForKey:@"reactionsSorted"]];
    } else {
        [cell setTimeLabelString:nil];
        [cell addActivities:[NSArray array]];
    }

    NSArray *recordResults = [self.modelObject threadReactionShouldRecordAtIndexPath:indexPath thread:self.threadId];
    if ([recordResults count] > 0) {
        NSNumber *shouldRecord = recordResults[0];
        if ([shouldRecord boolValue]) {
            cell.showRecord = YES;
        } else {
            cell.showRecord = NO;
        }
    }

    




    cell.cellIndexPath = indexPath;

    //PFObject *activity = [self activityForReverseIndexPath:indexPath];
    // is there a reaction by this user on this activity...if not create it and save
    if (activity) {
        PFFile *video = [activity objectForKey:kGVActivityVideoKey];
        NSString *activityUserId = [[activity objectForKey:kGVActivityUserKey] objectId];
        NSString *currentUserId = [[PFUser currentUser] objectId];
        NSString *url = [video url];
        if ([[activity objectForKey:kGVActivityTypeKey] isEqualToString:kGVActivityTypeSendKey]) {
            NSArray *users = [activity objectForKey:kGVActivitySendReactionsKey];

            if ([url respondsToSelector:@selector(length)] && [url length] > 0) {
                cell.contentURL = url;
            } else {
                NSLog(@"there was a movie playback error, no movie found %@", activity);
            }

            NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:1];
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

    UIImageView *imageView = [[UIImageView alloc] init];


    imageView.contentMode = UIViewContentModeScaleAspectFill;
    //imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
    imageView.layer.shouldRasterize = YES;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    //[[GVCache sharedCache] setAttributesForImageView:imageView url:videoThumbUrl];


    [GVTwitterAuthUtility shouldGetProfileImageForAnyUser:sendusername block:^(NSURL *imageURL, NSURL *bannerURL, NSString *realname) {
        [imageView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

            //NSLog(@"created a new imageview");

            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.thumbnailView setNeedsLayout];
                [cell.thumbnailView layoutIfNeeded];
            });

        }];
            }];
    cell.thumbnailView.imageView = imageView;
    [cell.thumbnailView addSubview:imageView];
    cell.thumbnailView.imageView.frame = cell.thumbnailView.bounds;
//    [self.userImageViews addObject:imageView];
//    [self.activitiesShowing addObject:activity];
    [cell.thumbnailView setNeedsLayout];
    [cell.thumbnailView layoutIfNeeded];

    PFUser *activityUser = [activity objectForKey:kGVActivityUserKey];

    if (activityUser) {

    } else {
        //NSLog(@"activiy User nil %@", activityUser);
    }

    if ([[activityUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {

        cell.displaySentMessage = YES;
    } else {
        cell.displaySentMessage = NO;
    }
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(GVThreadTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    //NSLog(@"collection View index Path: %@", indexPath);
    NSArray *results = [self.modelObject threadViewControllerDataAtIndexPath:indexPath thread:self.threadId];
    PFObject *activity;
    NSDictionary *objects;
    if ([results count] > 0) {
        activity = [results objectAtIndex:0];
        if ([results count] > 1) {
            objects = [results objectAtIndex:1];
        }
    }
    return [self tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath activity:activity objects:objects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GVThreadTableViewCell *cell = (GVThreadTableViewCell*)[tableView dequeueReusableCellWithIdentifier:GVThreadTableViewControllerCellIdentifier forIndexPath:indexPath];

    [cell removeAllSubImageViews];

    return cell;
}

//
//- (void)startRecordingReaction:(NSString*)url indexPath:(NSIndexPath*)indexPath {
//
//}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.modelObject threadViewControllerDidSelectItemAtIndexPath:indexPath thread:self.threadId];
    //GVThreadCollectionViewCell *cell = (GVThreadCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

    //    id upload = [self.uploadingActivities objectForKey:indexPath];
    //    if (upload != nil) {
    //        return;
    //    }
    //    id loading = [self.loadingActivities objectForKey:indexPath];
    //    if (loading != nil) {
    //        return;
    //    }
    
}

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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Split View Controller delegate methods 

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.threadPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.navigationItem.leftBarButtonItem = nil;
    self.threadPopoverController = nil;
}

#pragma mark - Model Object protocol methods 


@end
