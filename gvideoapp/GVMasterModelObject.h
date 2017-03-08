//
//  GVMasterModelObject.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/15/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAIL_STYLE 1
#define HIERARCHY_OVERLAP 1

// sends to app delegate
extern NSString *GVNewThreadSaveNotification;
extern NSString *GVNewThreadDidSaveNotification;
extern NSString *GVThreadPushAttemptNotification;
extern NSString *GVDeleteWillDeleteThreadNotification;
extern NSString *GVDeleteDidDeleteThreadNotification;
extern NSString *GVPlayMovieNotification;
extern NSString *GVReactionVideoNotification;
extern NSString *GVNewThreadRequestNotification;
extern NSString *GVInternetRequestNotification;
extern NSString *GVMasterModelObjectFinishedLoadingData;
extern NSString *GVSaveMovieNotification;
extern NSString *GVClearCacheNotification;

// sends out
extern NSString *GVMasterModelObjectLoadingData;
extern NSString *GVMasterModelObjectLoadingThumbnails;
extern NSString * const GVMasterViewControllerPullUpNotification;

// receives
extern NSString *GVRefreshDataNotification;
extern NSString *GVThreadSelectionNotification; // indexPath
extern NSString *GVReactionCameraVideoSaveNotification;
extern NSString *GVMasterViewControllerCellSelectNotification;
extern NSString *GVMovieDidFinishPlayingNotification;
extern NSString *GVModelHasSuccessfullyInstalledDevice;

extern const CGFloat imageSize;
extern const CGFloat imageYPadding;
extern const CGFloat imagePadding;

//static inline CGFLOAT_TYPE cground(CGFLOAT_TYPE cgfloat);

@protocol GVMasterModelObjectProtocol <NSObject, UITableViewDataSource, UITableViewDelegate>

- (UITableView*)tableView;
- (void)objectsWillLoad;
- (void)objectsDidLoad:(NSError*)error;
- (void)updateRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)updateRowModelAtIndexPath:(NSIndexPath*)indexPath;

@end

@protocol GVThreadModelObjectProtocol <NSObject>

- (UIRefreshControl*)refreshControl;
- (UITableView*)tableView;
- (NSString*)threadId;
- (void)refreshData:(id)sender;

#if !MAIL_STYLE
- (BOOL)shouldScrollToBottomOffsetDelayed;
- (void)setShouldScrollToBottomOffsetDelayed:(BOOL)scroll;
#endif

@end

@protocol GVReactionsModelObjectProtocol <NSObject>

- (NSString*)sendActivityId;
- (void)refreshData:(id)sender;

@end

@interface GVMasterModelObject : NSObject

@property (nonatomic, weak) id<GVMasterModelObjectProtocol> masterViewController;
@property (nonatomic, weak) id<GVThreadModelObjectProtocol> threadViewController;
@property (nonatomic, weak) id<GVReactionsModelObjectProtocol> reactionsViewController;

@property (nonatomic, assign, getter = isLoading) BOOL loading;
@property (nonatomic, assign, getter = isSaving) BOOL saving;


#pragma mark - Master View Controller

- (NSInteger)masterViewControllerRowCount;
- (PFObject*)masterViewControllerThreadAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)masterViewControllerContainsDataAtIndexPath:(NSIndexPath*)indexPath;
- (NSDictionary*)masterViewControllerDataAtIndexPath:(NSIndexPath*)indexPath;

- (void)masterViewControllerDeleteItemAtIndexPath:(NSIndexPath*)indexPath;

//- (NSMutableArray*)sortedActivitiesOfThread:(NSString*)threadId;

- (NSArray*)masterSendingHeaderInfo:(NSIndexPath*)indexPath;

+ (void)drawProfileImage:(UIImage*)image atPoint:(CGPoint)originPoint context:(CGContextRef)context username:(NSString*)realname createdAt:(NSDate*)createdDate currentDate:(NSDate*)currentDate shouldRecord:(BOOL)shouldRecord showUnread:(BOOL)showUnread key:(NSString*)key;
+ (CGRect)drawTitleText:(NSString*)titleText atOrigin:(CGPoint)originPoint context:(CGContextRef)context;

#pragma mark - Thread View Controller

- (NSInteger)threadViewControllerRowCount:(NSString*)threadId;
- (NSArray*)threadViewControllerDataAtIndexPath:(NSIndexPath*)indexPath thread:(NSString*)threadId;
- (void)threadViewControllerDidSelectItemAtIndexPath:(NSIndexPath*)indexPath thread:(NSString*)threadId;

- (void)masterViewControllerSectionLabelWithUsernames:(NSArray*)sortedUsers completionBlock:(void (^)(NSString *labelString))completionBlock;

#pragma mark - Reactions View Controller

- (NSInteger)reactionsViewControllerRowCount:(NSString*)threadId threadIndexPath:(NSIndexPath*)indexPath;
- (PFObject*)reactionsViewControllerDataAtIndexPath:(NSIndexPath*)indexPath thread:(NSString*)threadId threadIndexPath:(NSIndexPath*)indexPath;


#pragma mark - Uploading

- (void)masterViewControllerNewThreadWithVideoPath:(NSString*)videoPath;
- (void)threadViewControllerNewSend:(NSString*)videoPath thread:(NSString*)threadId;
//- (void)threadReactionWithVideoPath:(NSString*)reactionPath thread:(NSString*)threadId indexPath:(NSIndexPath *)indexPath;

- (NSArray*)threadReactionShouldRecordAtIndexPath:(NSIndexPath*)indexPath thread:(NSString*)threadId;

- (void)clearCaches;

@end
