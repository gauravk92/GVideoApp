//
//  GVMasterTableViewCollectionViewCell.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/10/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVMasterTableViewCollectionViewCell.h"
#import "GVMasterTableCollectionCellImageView.h"
#import "GVTintColorUtility.h"
#import "GVShortTapGestureRecognizer.h"

#define TESTING_COLLECTION_SHELL_VIEW 0

@interface GVMasterTableViewCollectionShellView : UIView

@end

@implementation GVMasterTableViewCollectionShellView

- (void)drawRect:(CGRect)rect {
    if ([self superview].layer.needsLayout) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[self superview] performSelector:@selector(drawContentRect:) withObject:[NSValue valueWithCGRect:rect]];
        });
    }
}

@end

NSString *const GVMasterTableViewCellCollectionSelectNotification = @"GVMasterTableViewCellCollectionSelectNotification";

@interface GVMasterTableViewCollectionViewCell () <UIToolbarDelegate>

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic, strong) CAShapeLayer *clipShapeLayer;

//@property (nonatomic, strong) GVMasterTableCollectionCellImageView *thumbImageView;

#if TESTING_COLLECTION_SHELL_VIEW
//@property (nonatomic, strong) UIView *mainContentView;
//@property (nonatomic, strong) GVMasterTableViewCollectionShellView *shellView;
#endif

@end

@implementation GVMasterTableViewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.userInteractionEnabled = YES;
        //self.contentView.userInteractionEnabled = NO;
        //self.contentView.clipsToBounds = NO;
        self.clipsToBounds = NO;
        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.exclusiveTouch = NO;
        self.contentView.exclusiveTouch = NO;
        //self.contentView.opaque = YES;
        //self.contentView.layer.opaque = YES;
        self.layer.shouldRasterize = YES;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.contentView.clipsToBounds = YES;
        self.contentView.layer.shouldRasterize = YES;
        self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.contentView.layer.contentsScale = [UIScreen mainScreen].scale;

        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
        [self.selectedBackgroundView removeFromSuperview];
        self.selectedBackgroundView = nil;

#if TESTING_COLLECTION_SHELL_VIEW
        _mainContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainContentView.translatesAutoresizingMaskIntoConstraints = NO;
        _mainContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _shellView = [[GVMasterTableViewCollectionShellView alloc] initWithFrame:CGRectZero];
        _shellView.translatesAutoresizingMaskIntoConstraints = NO;
        _shellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_shellView];
#endif

        //self.contentView.layer.shouldRasterize = YES;
        //self.contentView.layer.allowsEdgeAntialiasing = YES;
        //self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.contentView.layer.shadowOpacity = 0;
        //self.contentView.backgroundColor = [GVTintColorUtility utilityPurpleColor];
        //self.layer.borderColor = [UIColor colorWithWhite:0.996 alpha:1.000].CGColor;
        //self.layer.borderWidth = 5;
        //self.contentView.layer.cornerRadius = 20;
        //self.layer.cornerRadius = 20;
        //self.clipsToBounds = YES;
        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.contentView.backgroundColor = [UIColor whiteColor];
        //self.contentView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        //self.backgroundColor = [UIColor whiteColor];
        //self.backgroundView = nil;
        //self.opaque = YES;
        //self.layer.opaque = YES;
        //self.layer.backgroundColor = [UIColor whiteColor].CGColor;
        // Initialization code
//        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        //self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
//        //self.imageView.layer.cornerRadius = 20;
//        self.thumbnailImageView.layer.backgroundColor = [UIColor whiteColor].CGColor;
//        //self.imageView.layer.shouldRasterize = YES;
//        //self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        self.thumbnailImageView.clipsToBounds = YES;
//        self.thumbnailImageView.layer.opaque = YES;
//        self.thumbnailImageView.opaque = YES;
//        self.thumbnailImageView.alpha = 1;
//        [self.thumbnailImageView.layer setMasksToBounds:YES];
        //[self.contentView addSubview:self.imageView];
        //self.imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0);
        //self.imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
        //self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 0.0, 0.0);

        //_thumbImageView = [[GVMasterTableCollectionCellImageView alloc] initWithFrame:frame];
#if TESTING_COLLECTION_SHELL_VIEW
        [_mainContentView addSubview:_thumbImageView];
#else
        //[self.contentView addSubview:_thumbImageView];
#endif

        //        [self.toolbar setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]]
//                      forToolbarPosition:UIToolbarPositionAny
//                              barMetrics:UIBarMetricsDefault];
//        [self.toolbar setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]]
//                      forToolbarPosition:UIToolbarPositionAny
//                              barMetrics:UIBarMetricsLandscapePhone];
//        [self.toolbar setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]]
//                      forToolbarPosition:UIToolbarPositionAny
//                              barMetrics:UIBarMetricsLandscapePhonePrompt];
//        [self.toolbar setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]]
//                      forToolbarPosition:UIToolbarPositionAny
//                              barMetrics:UIBarMetricsDefaultPrompt];


        //self.toolbar = [[GVDotToolbar alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        //[self.contentView addSubview:self.toolbar];


//        GVShortTapGestureRecognizer *sgc = [[GVShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//        sgc.delegate = self;
//        [self addGestureRecognizer:sgc];

        _durationLabel = [[UILabel alloc] initWithFrame:frame];
        _durationLabel.contentMode = UIViewContentModeScaleToFill;
        _durationLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.lineBreakMode = NSLineBreakByClipping;
        _durationLabel.layer.shouldRasterize = YES;
        _durationLabel.opaque = YES;
        _durationLabel.layer.contentsScale = [UIScreen mainScreen].scale;
        _durationLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _durationLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _durationLabel.backgroundColor = [GVTintColorUtility utilityPurpleColor];
#if TESTING_COLLECTION_SHELL_VIEW
        [_mainContentView addSubview:_durationLabel];
#else
        [self.contentView addSubview:_durationLabel];
#endif

    }
    return self;
}

- (void)handleTapGesture:(UIGestureRecognizer*)gc {
    //DLogObject(self);
//    /DLogObject(self.collectionIndexPath);
}

- (BOOL)isCustomClickableScrollViewObject {
    return YES;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self;
}

- (void)handleTap:(NSValue *)point {
    NSDictionary *dict = @{@"indexPath":self.collectionIndexPath, @"sectionIndexPath": self.sectionIndexPath, @"activityId": self.activityId, @"threadId": self.threadId};
    [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellCollectionSelectNotification object:nil userInfo:dict];
    DLogObject(point);
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionBottom;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    //self.imageView.image = nil;
    //self.imageView.file = nil;
    //self.thumbImageView.imageView = nil;
    self.collectionIndexPath = nil;
    self.sectionIndexPath = nil;
    self.activityId = nil;
    self.threadId = nil;
    self.showsUnread = NO;
    [self setNeedsLayout];
    //self.thumbnailImageView = nil;
    //[self.thumbnailImageView removeFromSuperview];
    //[self setNeedsDisplay];
    //[self.thumbImageView]
}

- (void)removeAllSubImageViews {
    for (UIImageView *imageView in self.thumbImageView.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
}

- (void)setImageView:(UIImageView *)imageView {
    for (UIView *subview in self.contentView.subviews) {
        if (subview != self.durationLabel) {
            [subview removeFromSuperview];
        }
    }

    self.clipShapeLayer = [CAShapeLayer layer];
    imageView.layer.mask = self.clipShapeLayer;
    //self.durationLabel.layer.zPosition = 1000000;
    //imageView.layer.zPosition = -100;
    [self.contentView insertSubview:imageView belowSubview:self.durationLabel];
    //[self.contentView addSubview:imageView];
    //[self.contentView bringSubviewToFront:self.durationLabel];
    imageView.layer.shouldRasterize = YES;
    imageView.layer.opaque = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;

    self.thumbImageView = imageView;
    //if (self.showsUnread) {
    self.durationLabel.layer.cornerRadius= 1;
    //self.durationLabel.clipsToBounds = YES;
    self.durationLabel.opaque = YES;
    self.durationLabel.layer.shadowOpacity = 0;
    self.durationLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.durationLabel.layer.borderColor = [UIColor clearColor].CGColor;

    //self.durationLabel.tintColor = [GVTintColorUtility utilityPurpleColor];
    if (self.showsUnread) {
    self.durationLabel.backgroundColor = [GVTintColorUtility utilityTintColor]; //[UIColor colorWithHue:0.778 saturation:0.600 brightness:1.000 alpha:1.000];//[UIColor colorWithHue:0.750 saturation:1.000 brightness:0.502 alpha:1.000]; //[UIColor colorWithRed:0.000 green:0.786 blue:1.000 alpha:1.0];
    } else {
        self.durationLabel.alpha = 0.0;
    }
    //} else {
    //    self.durationLabel.backgroundColor = [UIColor lightGrayColor];
    //}
    imageView.layer.contentsScale = [UIScreen mainScreen].scale;
    //self.thumbImageView.displayDelegate = self.displayDelegate;
    //self.thumbImageView.imageView.displayDelegate = self.displayDelegate;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;

}

#if TESTING_COLLECTION_SHELL_VIEW
- (void)setNeedsDisplay {

    if (![self.mainContentView superview]) {
        [self addSubview:self.mainContentView];
    }
    [self.shellView setNeedsDisplay];
}
#else
- (void)setNeedsDisplay {
    [super setNeedsDisplay];

    [self.durationLabel setNeedsDisplay];
    //if (self.displayDelegate) {
    //    [self.displayDelegate setNeedsDisplay];
    //}
}

#endif

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self.contentView setNeedsLayout];
    [self.thumbImageView setNeedsLayout];
    [self.durationLabel setNeedsLayout];
}

- (void)setDurationString:(NSString *)string {
    self.durationLabel.text = string;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.showsUnread) {
        self.contentView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
        self.contentView.layer.borderWidth = 0.6; // 0.6, white: 0.7 alpha 0.7
    } else {
        self.contentView.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.0].CGColor;
        self.contentView.layer.borderWidth = 0.6;
    }

    CGFloat outerRadiusInset = 12;
    CGFloat innerRadiusInset = 4;

    //self.clipsToBounds = YES;
    //self.contentView.clipsToBounds = YES;
    self.thumbImageView.clipsToBounds = YES;
    self.thumbImageView.layer.contentsScale = [UIScreen mainScreen].scale;
    self.thumbImageView.layer.shouldRasterize = YES;
    self.thumbImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.thumbImageView.layer.borderColor = [UIColor clearColor].CGColor;
    self.thumbImageView.layer.borderWidth = 1;

    //self.layer.cornerRadius = self.bounds.size.width / 2;

    //self.contentView.frame = CGRectIntegral(CGRectInset(self.bounds, outerRadiusInset, outerRadiusInset));

    self.thumbImageView.frame = CGRectIntegral(CGRectInset(self.contentView.bounds, outerRadiusInset, outerRadiusInset));

    //self.contentView.layer.cornerRadius = self.contentView.frame.size.width / 2 - self.contentView.layer.borderWidth;

    UIBezierPath *aBeziPath = [UIBezierPath bezierPathWithRoundedRect:CGRectIntegral(self.thumbImageView.bounds) cornerRadius:self.thumbImageView.frame.size.width/2];
    [aBeziPath setFlatness:0.0];
    self.clipShapeLayer.path = aBeziPath.CGPath;
    //self.thumbImageView.layer.cornerRadius = 1;

    //self.thumbImageView.layer

    //if (self.thumbImageView.imageView.image) {

    //[self.contentView bringSubviewToFront:self.thumbImageView];

    CGFloat durationPadding = 3;

        [self.durationLabel sizeToFit];

        CGRect durationRect = self.durationLabel.frame;
        durationRect.origin.x = self.bounds.size.width- durationRect.size.width -durationPadding - innerRadiusInset;
    durationRect.size.width = durationRect.size.width + (durationPadding);
        self.durationLabel.frame = durationRect;
    //}
    //[self bringSubviewToFront:self.durationLabel];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}

#if TESTING_COLLECTION_SHELL_VIEW
- (void)drawContentRect:(CGRect)rect {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGRect bounds = CGRectIntegral(rect);

    CGContextRef context = UIGraphicsGetCurrentContext();


    UIView *view = self.mainContentView;

    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Center the context around the view's anchor point
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    // Apply the view's transform about the anchor point
    CGContextConcatCTM(context, [view transform]);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context,
                          -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);

    // Render the layer hierarchy to the current context
    [[view layer] renderInContext:context];

    // Restore the context
    CGContextRestoreGState(context);

    //[snapshot drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    //UIView *snapshot = [self.mainContentView snapshotViewAfterScreenUpdates:YES];
    //[self.mainContentView drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    //[self.mainContentView removeFromSuperview];
    //[self.mainContentView.layer drawInContext:ctx];
    [self.mainContentView removeFromSuperview];
}
#endif

@end
