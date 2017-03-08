//
//  GVThreadTableViewCell.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/2/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCircleThumbnailInnerShadowView.h"

// send out
extern NSString *GVNewThreadWillSaveNotification;
extern NSString *GVNewThreadDidSaveNotification;
extern NSString *GVInternetRequestNotification;
extern NSString *GVSaveMovieNotification;

// declare for view controller
extern CGFloat const GVThreadTableViewCellBottomMargin;

@interface GVThreadTableViewCell : UITableViewCell

@property (nonatomic, strong) GVCircleThumbnailInnerShadowView *thumbnailView;

@property (nonatomic, assign) BOOL displaySentMessage;

@property (nonatomic, strong) NSString *contentURL;

@property (nonatomic, assign) BOOL willCaptureUponSelection;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSString *threadId;

@property (nonatomic, copy) NSString *sendUsername;

@property (nonatomic, copy) NSIndexPath *cellIndexPath;

@property (nonatomic, assign) BOOL showRecord;

- (void)removeAllSubImageViews;

- (void)setTimeLabelString:(NSString*)timeLabel;
- (void)addActivities:(NSArray*)activities;

- (void)setSendUsernameText:(NSString*)text;
- (void)setVideoLengthText:(NSString*)text;

@end
