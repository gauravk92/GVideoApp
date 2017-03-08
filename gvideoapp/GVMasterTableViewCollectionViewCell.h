//
//  GVMasterTableViewCollectionViewCell.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/10/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVSpringLoadImageView.h"
#import "GVDotToolbar.h"
#import "GVModalCameraContainerView.h"

@interface GVMasterTableViewCollectionViewCell : UICollectionViewCell <GVCustomClickableScrollViewObject>

//@property (nonatomic, strong) UIImageView *thumbnailImageView;

//@property (nonatomic, strong) GVDotToolbar *toolbar;

@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, weak) UIView *displayDelegate;

- (void)setImageView:(UIImageView*)imageView;
- (void)removeAllSubImageViews;

- (void)startAnimatingDots;

@property (nonatomic, copy) NSString *threadId;
@property (nonatomic, copy) NSString *activityId;

@property (nonatomic, assign) BOOL showsUnread;

@property (nonatomic, copy) NSIndexPath *sectionIndexPath;
@property (nonatomic, copy) NSIndexPath *collectionIndexPath;

- (void)setDurationString:(NSString*)string;

@end
