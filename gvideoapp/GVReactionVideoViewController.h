//
//  GVReactionVideoViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/4/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

// sends to model
extern NSString *GVReactionCameraVideoSaveNotification;

@interface GVReactionVideoViewController : UINavigationController

@property (nonatomic, copy) NSString *contentURL;
@property (nonatomic, copy) NSString *activityId;
@property (nonatomic, copy) NSString *threadId;
@property (nonatomic, copy) NSNumber *shouldRecord;

@property (nonatomic, strong) MPMoviePlayerViewController *movieViewController;

- (instancetype)initWithContentURL:(NSString*)contentURL threadId:(NSString*)threadId activityId:(NSString*)activityId shouldRecord:(NSNumber*)shouldRecord;

@end
