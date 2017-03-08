//
//  GVReactionsTableViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/3/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVMasterModelObject.h"

// send to app delegate
extern NSString *GVPlayMovieNotification;

@interface GVReactionsTableViewController : UITableViewController <GVReactionsModelObjectProtocol>

@property (nonatomic, weak) GVMasterModelObject *modelObject;

@property (nonatomic, strong) NSString *threadId;
@property (nonatomic, copy) NSIndexPath *indexPath;

@end
