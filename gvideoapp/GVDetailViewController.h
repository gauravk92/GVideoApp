//
//  GVDetailViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/26/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"

extern NSString * const GVDetailViewControllerCellIdentifier;

@interface GVDetailViewController : JSMessagesViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) PFObject *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
