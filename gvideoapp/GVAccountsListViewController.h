//
//  GVAccountsListViewController.h
//  TwitterClient
//
//  Created by Peter Friese on 19.09.11.
//  Copyright (c) 2011, 2012 Peter Friese. All rights reserved.
//  Copyright (c) 2014, Gaurav Khanna. All rights reserved
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"


@interface GVAccountsListViewController : UITableViewController

@property (strong, nonatomic) ACAccountStore *accountStore; 
@property (strong, nonatomic) NSArray *accounts;
@property (strong, nonatomic) NSNumber *tableSelectedIndex;
@property (strong, nonatomic) NSBlockOperation *selectedCompletionBlock;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end
