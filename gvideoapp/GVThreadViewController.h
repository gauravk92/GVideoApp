//
//  GVThreadViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/1/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVMasterModelObject.h"

@interface GVThreadViewController : UICollectionViewController <GVThreadModelObjectProtocol>

//@property (strong, nonatomic) NSMutableArray *messages;
//@property (strong, nonatomic) NSDictionary *avatars;


@property (nonatomic, weak) GVMasterModelObject *modelObject;

//@property (strong, nonatomic) PFObject *detailItem;

@property (nonatomic, copy) NSString *threadId;

//@property (nonatomic, strong) NSArray *activities;

//@property (nonatomic, strong) UIView *givenBackgroundView;

@property (nonatomic, assign) BOOL shouldScrollToOffsetAtBottom;
@property (nonatomic, assign, setter = setShouldScrollToBottomOffsetDelayed:) BOOL shouldScrollToBottomOffsetDelayed;

- (void)refreshData:(NSNotification*)notif;
//- (void)objectsDidLoad:(NSError*)error;
@end
