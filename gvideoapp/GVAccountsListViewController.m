//
//  GVAccountsListViewController.m
//  TwitterClient
//
//  Created by Peter Friese on 19.09.11.
//  Copyright (c) 2011, 2012 Peter Friese. All rights reserved.
//  Copyright (c) 2014, Gaurav Khanna. All rights reserved
//

#import "GVAccountsListViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "GVTwitterAuthUtility.h"
#import "GVCache.h"

NSString * const GVAccountsListViewControllerCellIdentifier = @"GVAccountsListViewControllerCellIdentifier";

@interface GVAccountsListViewController ()
- (void)fetchData;

@end

@implementation GVAccountsListViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    self.title = @"Accounts";
    if (self) {
        @autoreleasepool {
            [self fetchData];
        }
    }
    return self;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.preferredContentSize = CGSizeMake(320, 480);
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.modalPresentationStyle = UIModalPresentationPageSheet;
//        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    }

    self.navigationItem.title = @"Twitter Accounts";
    self.tableView.rowHeight = 70;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [self.refreshControl addTarget:self action:@selector(refreshManually:) forControlEvents:UIControlEventValueChanged];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:GVAccountsListViewControllerCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.view.superview.bounds = CGRectMake(0, 0, 320, 480);
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Data handling

- (void)fetchData {
    if (self.accountStore == nil) {
        self.accountStore = [[ACAccountStore alloc] init];
        if (self.accounts == nil) {
            ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter options:nil completion:^(BOOL granted, NSError *error) {
                if(granted) {
                    self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }];
        }
    }
  
    //[self performSelector:@selector(doneLoadingTableViewData)
    //          withObject:nil afterDelay:1.0];  // Need a delay here otherwise it gets called to early and never finishes.
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GVAccountsListViewControllerCellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }

    // Configure the cell...
    ACAccount *account = [self.accounts objectAtIndex:[indexPath row]];
    cell.textLabel.text = account.username;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    //UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    //cell.imageView = activityIndicator;
    //[activityIndicator stopAnimating];

//    [GVTwitterAuthUtility shouldGetProfileImageForUser:account.username block:^(UIImage *image) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.imageView.image = image;
//            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
//            [cell.imageView setNeedsDisplay];
//
//            @weakify(indexPath);
//            //[tableView reloadRowsAtIndexPaths:@[indexPath_weak_] withRowAnimation:NO];
//        });
//    }];

    //NSDictionary *userAttributes = [GVCache sharedCache] attr

    //NSString *username = [_usernameCache objectForKey:account.username];
//    if (username) {
//        cell.textLabel.text = username;
//    }
//    else {
//        TWRequest *fetchAdvancedUserProperties = [[TWRequest alloc]
//                                                  initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/users/show.json"]
//                                                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil]
//                                                  requestMethod:TWRequestMethodGET];
//        [fetchAdvancedUserProperties performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//            if ([urlResponse statusCode] == 200) {
//                NSError *error;
//                id userInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
//                if (userInfo != nil) {
//                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        [_usernameCache setObject:[userInfo valueForKey:@"name"] forKey:account.username];
//                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
//                    });
//                }
//            }
//        }];
//    }
//
//    UIImage *image = [_imageCache objectForKey:account.username];
//    if (image) {
//        cell.imageView.image = image;
//    }
//    else {
//        TWRequest *fetchUserImageRequest = [[TWRequest alloc]
//                                            initWithURL:[NSURL URLWithString:
//                                                         [NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@",
//                                                          account.username]]
//                                            parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"bigger", @"size", nil]
//                                            requestMethod:TWRequestMethodGET];
//        [fetchUserImageRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//            if ([urlResponse statusCode] == 200) {
//                UIImage *image = [UIImage imageWithData:responseData];
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    [_imageCache setObject:image forKey:account.username];
//                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
//                });
//            }
//        }];
//    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.selectedCompletionBlock) {
        self.tableSelectedIndex = [NSNumber numberWithInt:indexPath.row];
        [self.selectedCompletionBlock start];
        
        //self.selectedCompletionBlock = nil;
        @weakify(self);
        
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        });
    }
}

- (void)refreshManually:(id)sender {
    self.accounts = nil;
    [self fetchData];
    [self.refreshControl endRefreshing];
}

@end
