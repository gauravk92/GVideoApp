//
//  GVMasterTableViewCell.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MASTER_TABLE_VIEW_CONTENT_VIEW 1

extern const CGFloat GVMasterTableViewCellRowHeight;
extern const CGFloat badgeSize;
extern const CGFloat badgeXPadding;

extern NSString *const GVMasterSectionHeaderViewTapToSendNotification;
extern NSString *const GVMasterSectionHeaderSelectNotification;
extern NSString *const GVMasterTableViewCellLongPressNotification;
extern NSString *const GVMasterTableViewCellLongPressReceiveNotification;
extern NSString *const GVMasterTableViewCellLongPressActivityReceiveNotification;
extern NSString *const GVMasterTableViewCellSaveMovieRequestNotification;
extern NSString *const GVMasterTableViewCellEditDataNotification;


extern NSString *const GVMasterTableViewCellCollectionSelectNotification;

@interface GVMasterTableViewCell : UITableViewCell

@property (nonatomic, weak) CALayer *highlightLayer;

//@property (nonatomic, strong) UILabel *usersLabel;
//@property (nonatomic, strong) UILabel *timeLabel;
//@property (nonatomic, strong) UILabel *usersLabelHigh;
//@property (nonatomic, strong) UILabel *timeLabelHigh;
@property (nonatomic, copy) NSString *threadId;
@property (nonatomic, copy) NSString *userString;
@property (nonatomic, copy) NSString *timeString;
//@property (nonatomic, assign) BOOL shouldStartAnimatingWaitingDots;
//@property (nonatomic, assign) BOOL shouldReloadActivities;
//@property (nonatomic, strong) UICollectionView *collectionView;
//@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;
//@property (nonatomic, strong) UILabel *waitingLabel1;
//@property (nonatomic, strong) UILabel *waitingLabel2;
//@property (nonatomic, strong) UILabel *waitingLabel3;
//@property (nonatomic, strong) UILabel *waitingLabel1High;
//@property (nonatomic, strong) UILabel *waitingLabel2High;
//@property (nonatomic, strong) UILabel *waitingLabel3High;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *mainImageView;


//@property (nonatomic, strong) CALayer *cellImageView;

@property (nonatomic, weak) UITableView *displayTableView;

//@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, assign) BOOL needsToDraw;


@property (nonatomic, strong) CAGradientLayer *gradientLayerMask;

@property (nonatomic, copy) NSDictionary *attributes;
@property (nonatomic, copy) NSString *titleTextString;
@property (nonatomic, copy) NSAttributedString *usersAttrString;
@property (nonatomic, copy) NSNumber *textXInset;
@property (nonatomic, copy) NSNumber *imageSize;
@property (nonatomic, copy) NSNumber *imagePadding;
@property (nonatomic, copy) NSNumber *tapPadding;

@property (nonatomic, copy) NSNumber *scrollWidth;

@property (nonatomic, assign) BOOL odd;

@property (nonatomic, strong) NSMutableDictionary *userImageFiles;



// self.unreadIndicator = self.imageView;

//- (void)startAnimatingWaitingDots;
- (void)addActivities:(NSArray*)activities;
//- (void)showUnreadIndicator:(BOOL)show animate:(BOOL)animate;
- (void)setUserTextString:(NSString*)string;
- (void)setTimeLabelString:(NSString*)string;
- (void)updateDisplayInRect:(CGRect)imageRect;

//- (void)resizeSubviews;

@property (nonatomic, copy) NSIndexPath *sectionIndexPath;

#if MASTER_TABLE_VIEW_CONTENT_VIEW
//@property (nonatomic, strong) UIView *mainContentView;

#endif

- (UIView*)shellView;
- (void)setupScrollContent:(CGSize)size;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)setupScrollViewTileSize;

//- (void)animateUnreadIndicatorOut;
//- (void)animateUnreadIndicatorIn;


@end
