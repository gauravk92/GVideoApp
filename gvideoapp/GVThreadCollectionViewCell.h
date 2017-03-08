//
//  GVThreadCollectionViewCell.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/1/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCircleThumbnailInnerShadowView.h"

@interface GVThreadCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) GVCircleThumbnailInnerShadowView *thumbnailView;

@property (nonatomic, assign) BOOL displaySentMessage;

@property (nonatomic, strong) NSString *contentURL;

@property (nonatomic, assign) BOOL willCaptureUponSelection;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSString *threadId;

@property (nonatomic, copy) NSString *sendUsername;

- (void)removeAllSubImageViews;

- (void)setTimeLabelString:(NSString*)timeLabel;
- (void)addActivities:(NSArray*)activities;

- (void)setSendUsernameText:(NSString*)text;

@end
