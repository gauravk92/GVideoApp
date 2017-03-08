//
//  GVMasterViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/26/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVMasterModelObject.h"

@class GVDetailViewController;

extern NSString * const GVMasterViewControllerPullUpNotification;
extern NSString * const GVMasterViewControllerFullscreenNotification;
extern NSString *const GVMasterViewControllerDeleteThreadRequestNotification;
extern NSString * const GVMasterTableViewCellCollectionTouchNotification;
extern NSString * const GVMasterViewControllerCellTouchNotification;
extern NSString * const GVMasterViewControllerSetupEmptyLabelNotification;
extern NSString * const GVMasterViewControllerEndEmptyLabelNotification;

@interface GVMasterViewController : UITableViewController <GVMasterModelObjectProtocol>

@property (nonatomic, weak) GVMasterModelObject *modelObject;



@property (nonatomic, weak) UIScrollView *parentScrollview;
@property (nonatomic, strong) NSMutableDictionary *visibleSectionHeaderViews;

- (void)playCoffeeSound;
- (void)insertNewObject;


@end
