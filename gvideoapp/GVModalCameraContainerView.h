//
//  GVModalCameraContainerView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVModalCameraVideoController.h"
#import "GVModalCameraScrollView.h"
#import "GVFastTopViewContentView.h"



#import "GVThreadBackgroundView.h"
@protocol GVCustomClickableScrollViewObject <NSObject>

- (BOOL)isCustomClickableScrollViewObject;
- (void)handleTap:(NSValue*)point;
- (void)handleLongPress:(CGPoint)point;
- (void)handleDoubleTap:(CGPoint)point;
- (void)handleTouchDown:(NSValue*)point;
- (void)handleTapFail:(NSValue*)point;

@end

@protocol GVModalCameraContainerView <NSObject>

- (void)goToFullscreen;
- (void)endFullscreen;
- (void)willDisplay;
- (void)didEndDisplay;
- (void)tellContentOffset:(CGPoint)contentOffset;
- (void)endedDragging;

@end

@interface GVModalCameraContainerView : UIView

@property (nonatomic, strong) UIView *contentsContainer;

@property (nonatomic, assign) CATransform3D topControllerTransform;

@property (nonatomic, strong) UIView *topContainerView;

@property (nonatomic, strong) GVThreadBackgroundView *bgView;

@property (nonatomic, strong) CAShapeLayer *shapeLayerMask;

@property (nonatomic, weak) GVModalCameraVideoController *topViewController;
@property (nonatomic, weak) UIViewController *bottomViewController;
@property (nonatomic, weak) GVMasterViewController *masterViewController;
@property (nonatomic, weak) UIViewController *splitViewController;
@property (nonatomic, strong) GVModalCameraScrollView *scrollView;

@property (nonatomic, weak) id<GVModalCameraContainerView> delegate;

@property (nonatomic, assign) BOOL showFullscreen;

@property (nonatomic, strong) GVFastTopViewContentView *fastView;

@property (nonatomic, strong) UIView *bottomContainerView;

@property (nonatomic, assign) BOOL loading;

- (void)setupLoadingState;
- (void)setupLoadingThumbnailState;
- (void)endLoadingState;
- (void)setupEmptyLabel;
- (void)endEmptyLabel;


+ (CGFloat)heightOfNavHeader;
- (CGFloat)contentOffsetForBottomView;
- (void)scrollToBottomView:(BOOL)animated;

- (void)setupTopViewController:(UIViewController*)topVC;
- (void)setupBottomViewController:(UIViewController*)bottomVC;
- (void)setupSplitViewController:(UIViewController*)splitVC;

- (void)scrollBottomViewFullScreen:(BOOL)animated;

- (CGFloat)heightOfTopView;

@end
