//
//  GVParseObjectUtility.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/4/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kGVParseCreatedAtKey;
extern NSString *const kGVParseUpdatedAtKey;

extern NSString *const kGVInstallationUserKey;

#pragma mark -  Thread Class

extern NSString *const kGVThreadClassKey;
extern NSString *const kGVThreadLastActivityKey;
extern NSString *const kGVThreadUsersKey;
extern NSString *const kGVThreadCreatorKey;
extern NSString *const kGVThreadForcedTitleKey;

#pragma mark - Activity Class

extern NSString *const kGVActivityClassKey;
extern NSString *const kGVActivityUserKey;
extern NSString *const kGVActivityVideoKey;
extern NSString *const kGVActivityVideoThumbnailKey;
extern NSString *const kGVActivityThreadKey;
extern NSString *const kGVActivityTypeKey;
extern NSString *const kGVActivitySendReactionsKey;
extern NSString *const kGVActivityReactionOriginalSendKey;
extern NSString *const kGVActivityVideoFileSizeKey;
extern NSString *const kGVActivityVideoDurationKey;
extern NSString *const kGVActivityReadKey;
extern NSString *const kGVActivityForcedDisplayName;
extern NSString *const kGVActivityForcedUnreadState;
extern NSString *const kGVActivityForcedUnrecordState;

#pragma mark - Activity Send Type
extern NSString *const kGVActivityTypeSendKey;
extern NSString *const kGVActivityTypeReactionKey;

#pragma mark - User Class

extern NSString *const kGVUserClassKey;
extern NSString *const kGVUserNameKey;
extern NSString *const kGVUserRealNameKey;
extern NSString *const kGVUserCameraImageKey;

// push notification keys

extern NSString *const kGVPushNotificationTypeKey;
extern NSString *const kGVPushNotificationThreadIdKey;


@interface GVParseObjectUtility : NSObject

+ (PFObject*)createNewThreadWithCreator:(PFUser*)user;

//+ (PFObject*)createNewActivitySendWithUser:(PFUser*)user thread:(PFObject*)thread videoPath:(NSString*)videoPath;
+ (PFObject*)createNewActivityReactionWithUser:(PFUser*)user thread:(PFObject*)thread videoPath:(NSString*)videoPath activity:(PFObject*)activity;
+ (NSArray*)createNewActivitySendWithUser:(PFUser*)user thread:(PFObject*)thread videoPathAndImage:(NSString*)videoPath;

+ (PFQuery*)queryForThreadsOfUser:(PFUser*)user;
+ (PFQuery*)queryForActivitiesOfThread:(PFObject*)thread;
+ (PFQuery *)queryForActivitiesOfThreads:(NSArray *)threads;

+ (PFQuery *)netQueryForUserUpdate:(PFUser*)user;

+ (void)setCameraImageForCurrentUser:(UIImage*)image;

@end
