//
//  GVAppDelegate.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/26/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *GVLoggedInNotification;
extern NSString *GVLoggedOutNotification;
extern NSString *GVClearCacheNotification;
extern NSString *GVLogOutNotification;
extern NSString *GVAboutUsPadNotification;
extern NSString *GVDeleteAccountNotification;
extern NSString *GVDeleteWillDeleteThreadNotification;
extern NSString *GVDeleteDidDeleteThreadNotification;
extern NSString *GVPlayMovieNotification;
extern NSString *GVReactionVideoNotification;
extern NSString *GVInternetRequestNotification;
extern NSString *GVNewThreadRequestNotification;
extern NSString *GVSaveMovieNotification;
extern NSString *GVThreadInviteNotification;
extern NSString *GVModelHasSuccessfullyInstalledDevice;


@interface GVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) int networkStatus;

- (BOOL)isParseReachable;

@end
