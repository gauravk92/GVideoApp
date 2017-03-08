//
//  GVThreadTableViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/2/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVMasterModelObject.h"

// send out to app delegate
extern NSString *GVPlayMovieNotification;

@interface GVThreadTableViewController : UITableViewController <GVThreadModelObjectProtocol, UISplitViewControllerDelegate>

@property (nonatomic, weak) GVMasterModelObject *modelObject;

@property (nonatomic, copy) NSString *threadId;

- (void)refreshData:(NSNotification*)notif;

@end
