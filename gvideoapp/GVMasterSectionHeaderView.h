//
//  GVMasterSectionHeaderView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/9/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVModalCameraContainerView.h"

@interface GVMasterSectionHeaderShellView : UIView

@end



@interface GVMasterSectionHeaderView : UITableViewHeaderFooterView <GVCustomClickableScrollViewObject>


//@property (nonatomic, strong) UILabel *waitingLabel1High;
//@property (nonatomic, strong) CAGradientLayer *waitingLabel1HighMask;
//@property (nonatomic, strong) UILabel *waitingLabel2High;
//@property (nonatomic, strong) CAShapeLayer *waitingLabel2HighMask;
//@property (nonatomic, strong) UILabel *waitingLabel3High;
//@property (nonatomic, strong) CAShapeLayer *waitingLabel3HighMask;
@property (nonatomic, strong) UILabel *usersLabel;
@property (nonatomic, strong) CAGradientLayer *usersLabelMask;
@property (nonatomic, strong) UILabel *timeLabel;
//@property (nonatomic, strong) UILabel *usersLabelHigh;
//@property (nonatomic, strong) CAGradientLayer *usersLabelHighMask;
//@property (nonatomic, strong) UILabel *timeLabelHigh;
@property (nonatomic, copy) NSString *userString;
@property (nonatomic, copy) NSString *timeString;
@property (nonatomic, assign) BOOL shouldStartAnimatingWaitingDots;
@property (nonatomic, assign) BOOL shouldReloadActivities;

@property (nonatomic, assign) BOOL selectedToSend;

@property (nonatomic, strong) UILabel *sendLabel;
//@property (nonatomic, strong) UILabel *sendLabelHigh;

//@property (nonatomic, weak) GVMasterViewController *windowDelegate;


@property (nonatomic, strong) UILongPressGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) GVMasterSectionHeaderShellView *shellView;

- (void)setUserTextString:(NSString*)string;
- (void)setTimeLabelString:(NSString*)string;

- (void)startAnimatingWaitingDots;

@property (nonatomic, copy) NSIndexPath *indexPath;

- (void)setupSubviews;

@end
