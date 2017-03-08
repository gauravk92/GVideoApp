//
//  GVProgressView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/9/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVProgressView.h"
#import "GVProgressBarView.h"
#import "GVRadialGradientLayer.h"
#import "GVProgressCollectionViewCell.h"

NSString *const GVProgressViewUpdateContentsNotification = @"GVProgressViewUpdateContentsNotification";
NSString *const GVProgressViewCollectionViewCellIdentifier = @"GVProgressViewCollectionViewCellIdentifier";

@interface GVProgressView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) GVProgressBarView *progressView;
@property (nonatomic, strong) UILabel *startTextLabel;
@property (nonatomic, strong) NSAttributedString *startString;
@property (nonatomic, strong) NSAttributedString *stopString;
@property (nonatomic, strong) GVRadialGradientLayer *radialGradientLayerText;
@property (nonatomic, strong) GVRadialGradientLayer *radialGradientLayer;

@property (nonatomic, strong) CAGradientLayer *textGradientLayer;
@property (nonatomic, strong) UICollectionView *contentsView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSArray *headerInfo;
@property (nonatomic, strong) UILabel *toLabel;

@property (nonatomic, assign) BOOL showsImage;

@property (nonatomic, strong) NSAttributedString *dotString;

@property (nonatomic, strong) NSDictionary *userTextAttributes;

@property (nonatomic, assign) CGFloat descender;

@end

@implementation GVProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // Initialization code

        //self.alpha = 0.8;

        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.needsDisplayOnBoundsChange = NO;
        self.layer.allowsEdgeAntialiasing = YES;
        self.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;

        //self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.backgroundColor = [UIColor colorWithRed:0.000 green:0.001 blue:0.137 alpha:0.600];

        self.progressView = [[GVProgressBarView alloc] initWithFrame:CGRectZero];
        self.progressView.layer.shouldRasterize = YES;
        self.progressView.layer.needsDisplayOnBoundsChange = NO;
        self.progressView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.progressView.alpha = 0.8;
        [self addSubview:self.progressView];

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;

//        Futura-Medium,
//        Futura-CondensedMedium,
//        Futura-MediumItalic,
//        Futura-CondensedExtraBold
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];

        NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSBackgroundColorAttributeName: [UIColor clearColor],
                                     NSFontAttributeName: font};
        self.descender = font.descender;

        
        
        self.startString = [[NSAttributedString alloc] initWithString:@"New Thread" attributes:attributes];
        //self.dotString = [[NSAttributedString alloc] initWithString:@"..." attributes:attributes];

        //self.stopString = [[NSAttributedString alloc] initWithString:stopText attributes:attributes];

        self.startTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.startTextLabel setAttributedText:self.startString];
        self.startTextLabel.layer.shouldRasterize = YES;
        //self.startTextLabel.layer.contentsScale = [UIScreen mainScreen].scale;
        self.startTextLabel.layer.needsDisplayOnBoundsChange = NO;
        //self.startTextLabel.alpha = 0.97;
        //self.startTextLabel.shadowColor = [UIColor lightGrayColor];
        //self.startTextLabel.shadowOffset = CGSizeMake(0, 1);
        // self.startTextLabel.contentMode = UIViewContentModeScaleAspectFill;
        //self.startTextLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.startTextLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self addSubview:self.startTextLabel];

        self.toLabel = [[UILabel alloc] initWithFrame:frame];
        self.toLabel.text = @"To:";
        self.toLabel.textColor = [UIColor whiteColor];
        self.toLabel.layer.shouldRasterize = YES;
        self.toLabel.layer.needsDisplayOnBoundsChange = NO;
        self.toLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.toLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        //self.toLabel.alpha = 0.97;
        self.toLabel.font = font;
        self.toLabel.alpha = 0.0;

        //self.toLabel.layer.duration = 1.0;
        [self addSubview:self.toLabel];
//
//        self.gradientLayer = [CAGradientLayer layer];
//        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
//        self.gradientLayer.startPoint = CGPointMake(0.0, -1.0f);// CGPointMake(0.0f, -50.0f);
//        self.gradientLayer.endPoint = CGPointMake(0.0, 0.8f);
        //self.collectionView.layer.mask = l;
        //self.layer.mask = self.gradientLayer;

        self.radialGradientLayer = [GVRadialGradientLayer layer];
        [self.radialGradientLayer setNeedsDisplay];

        ///self.radialGradientLayer.opaque
        //self.radialGradientLayer.shouldRasterize = YES;
        //self.radialGradientLayer.contentsScale = [UIScreen mainScreen].scale;
        //self.radialGradientLayer.rasterizationScale = [UIScreen mainScreen].scale;
        self.radialGradientLayer.needsDisplayOnBoundsChange = NO;
        self.radialGradientLayer.toRadius = [NSNumber numberWithFloat:200];
        self.radialGradientLayer.contentsOriginPoint = [NSValue valueWithCGPoint:CGPointMake(0.5, 0)];
        self.radialGradientLayer.contentsOffset = [NSValue valueWithCGPoint:CGPointMake(0, 120)];
        //self.layer.mask = self.radialGradientLayer;

        self.radialGradientLayerText = [GVRadialGradientLayer layer];
        [self.radialGradientLayerText setNeedsDisplay];
        //self.radialGradientLayerText.shouldRasterize = YES;
        //self.radialGradientLayerText.rasterizationScale = [UIScreen mainScreen].scale;
        //self.radialGradientLayerText.contentsScale = [UIScreen mainScreen].scale;
        self.radialGradientLayerText.needsDisplayOnBoundsChange = NO;
        self.radialGradientLayerText.toRadius = [NSNumber numberWithFloat:250];
        self.radialGradientLayerText.colorValues = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor];
        self.radialGradientLayerText.contentsOffset = [NSValue valueWithCGPoint:CGPointMake(0, -15)];
        //self.startTextLabel.layer.mask = self.radialGradientLayerText;

        //[self.layer addSublayer:self.radialGradientLayer];

        UICollectionViewFlowLayout *headerFlowLayout = [UICollectionViewFlowLayout new];
        self.flowLayout = headerFlowLayout;
        //headerFlowLayout.itemSize = CGSizeMake(100, 40);
        headerFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.contentsView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:headerFlowLayout];
        //self.contentsView.hidden = YES;
        self.contentsView.backgroundColor = [UIColor clearColor];
        self.contentsView.scrollEnabled = NO;
        self.contentsView.layer.needsDisplayOnBoundsChange = NO;
        self.contentsView.delegate = self;
        self.contentsView.dataSource = self;
        //[self addSubview:self.contentsView];

        [self.contentsView registerClass:[GVProgressCollectionViewCell class] forCellWithReuseIdentifier:GVProgressViewCollectionViewCellIdentifier];


        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContents:) name:GVProgressViewUpdateContentsNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.headerInfo count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GVProgressCollectionViewCell *pcell = (GVProgressCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:GVProgressViewCollectionViewCellIdentifier forIndexPath:indexPath];

    NSDictionary *dict;
    if (indexPath.item < [self.headerInfo count]) {
        dict = [self.headerInfo objectAtIndex:indexPath.item];
    }
    UILabel *label = [dict objectForKey:@"usernameLabel"];
    UIImageView *imageView = [dict objectForKey:@"imageView"];

    [pcell setupImageView:imageView];
    [pcell setupUsernameLabel:label];

    pcell.showsImage = self.showsImage;

    [pcell setNeedsLayout];
    [pcell layoutIfNeeded];
    //[self.contentsView addSubview:label];
    //[self.contentsView addSubview:imageView];

    return pcell;
}

- (void)updateContents:(NSNotification*)notif {
    @weakify(self);
    NSString *userString = [notif userInfo][@"indexPath"][@"user_string"];
    dispatch_async(dispatch_get_main_queue(), ^{
        DLogObject([notif userInfo]);
        if (userString && [userString respondsToSelector:@selector(length)] && [userString length] > 0) {
            self.toLabel.text = [@"To: " stringByAppendingString:userString];
            [self.toLabel setNeedsDisplay];
            [UIView animateWithDuration:0.35 animations:^{
                self.toLabel.alpha = 1;
                self.startTextLabel.alpha = 0.0;
            }];
            
        } else {
            
            
            self.toLabel.text = @"To:";
            [self.toLabel setNeedsDisplay];
            
            [UIView animateWithDuration:0.35 animations:^{
                self.toLabel.alpha = 0.0;
                self.startTextLabel.alpha = 1.0;
            }];
        }

    });
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.radialGradientLayer.frame = CGRectIntegral(self.bounds);

    //if (self.layoutWithoutNavigationController) {
    //    self.startTextLabel.frame = CGRectMake(0, 15, self.bounds.size.width, self.bounds.size.height - 20);
    //} else {

    [self.startTextLabel sizeToFit];
    self.startTextLabel.center = CGPointMake(self.center.x, self.center.y);
    self.startTextLabel.frame = CGRectIntegral(self.startTextLabel.frame);

    //CGRect startTextLabel = self.startTextLabel.frame;
    //startTextLabel.origin.x = startTextLabel.origin.x + [self.dotString size].width;
    //self.startTextLabel.frame = startTextLabel;

    //self.startTextLabel.frame = CGRectIntegral(self.bounds);
    self.radialGradientLayerText.frame = CGRectIntegral(self.bounds);
    // }

    CGFloat toPadding = 10;

    //[self.toLabel sizeToFit];

    CGRect toRect = self.toLabel.frame;
    toRect.origin.x = toPadding;
    toRect.origin.y = 0;
    toRect.size.width = self.bounds.size.width - toPadding;
    toRect.size.height = self.bounds.size.height;
    self.toLabel.frame = CGRectIntegral(toRect);

    CGFloat contentPadding = 16;

    CGRect contentFrame = self.bounds;
    contentFrame.origin.x = toPadding + toRect.size.width + contentPadding;
    contentFrame.size.width = self.bounds.size.width - contentFrame.origin.x;
    self.contentsView.frame = CGRectIntegral(contentFrame);

    [self bringSubviewToFront:self.toLabel];
    [self bringSubviewToFront:self.contentsView];
    [self bringSubviewToFront:self.progressView];
}

//- (CGSize)sizeThatFits:(CGSize)size {
//    CGSize newSize;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        newSize = CGSizeMake(self.frame.size.width, 36);
//    }
//    newSize = CGSizeMake(self.frame.size.width,30);
//    return newSize;
//}

//- (void)finishProgressBarAnimation {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        CGRect progressToolbarFrame = self.frame;
//        CGRect beforeFrame = CGRectMake(0, 0, progressToolbarFrame.size.width, progressToolbarFrame.size.height);
//        //CGRect startFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//        //CGRect midFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//        //startFrame.origin.x += 100;
//        beforeFrame.origin.x += beforeFrame.size.width;
//        //midFrame.origin.x += 300;
//        [self.progressView.layer removeAllAnimations];
//        [UIView animateWithDuration:1.0
//                              delay:0.0
//             usingSpringWithDamping:0.8
//              initialSpringVelocity:0.0
//                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
//                         animations:^{
//                             @strongify(self);
//                             self.progressView.frame = beforeFrame;
//                         } completion:nil];
//    });
//}

//- (void)setupProgressBarAnimated {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        [self.progressView.layer removeAllAnimations];
//        CGRect boundFrame = self.frame;
//        CGRect frame = CGRectMake(boundFrame.origin.x, 0, boundFrame.size.width, boundFrame.size.height);
//        self.progressView.frame = frame;
//        CGRect afterFrame = CGRectMake(0, 0, boundFrame.size.width, boundFrame.size.height);
//        [UIView animateWithDuration:0.25
//                              delay:0.0
//             usingSpringWithDamping:0.8
//              initialSpringVelocity:0.0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                                  @strongify(self);
//                                  self.progressView.frame = afterFrame;
//                              } completion:^(BOOL finished) {
//                                  if (finished) {
//                                      [self startProgressBarAnimated];
//                                  }
//                              }];
//    });
//}

- (void)startProgressBarAnimated {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.progressView.layer removeAllAnimations];
        CGRect boundFrame = self.frame;
        CGRect frame = CGRectMake(0, 0, boundFrame.size.width, boundFrame.size.height);
        self.progressView.frame = frame;
        CGRect afterFrame = CGRectMake(boundFrame.size.width, 0, boundFrame.size.width, boundFrame.size.height);
        CABasicAnimation *tweenAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        tweenAnimation.duration = 30;
        tweenAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        tweenAnimation.fromValue = [NSNumber numberWithFloat:frame.origin.x];
        tweenAnimation.toValue = [NSNumber numberWithFloat:afterFrame.origin.x];
        tweenAnimation.removedOnCompletion = NO;
        tweenAnimation.fillMode = kCAFillModeForwards;
        [self.progressView.layer addAnimation:tweenAnimation forKey:@"animateLayer"];
        //        [UIView animateWithDuration:30
        //                              delay:0.0
        //                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionOverrideInheritedOptions
        //                         animations:^{
        //                             @strongify(self);
        //                             self.progressView.frame = afterFrame;
        //                         } completion:nil];
    });
}

- (void)finishProgressBarAnimated {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        //[self.progressView.layer removeAllAnimations];
        //[self.progressView.layer removeAllAnimations];
        CGRect boundFrame = self.bounds;
        //CGRect frame = CGRectMake(boundFrame.size.width, 0, boundFrame.size.width, boundFrame.size.height);
        //self.progressView.frame = frame;
        CGRect afterFrame = CGRectMake(boundFrame.size.width, 0, boundFrame.size.width, boundFrame.size.height);
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             @strongify(self);
                             self.progressView.frame = afterFrame;
                         } completion:nil];
    });
}

- (void)fillProgressBarAnimated {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        //self.startTextLabel.hidden = YES;
        //self.stopTextLabel.hidden = NO;
        [self.progressView.layer removeAllAnimations];
        CGRect boundFrame = self.bounds;
        CGRect frame = CGRectMake(boundFrame.size.width, 0, boundFrame.size.width, boundFrame.size.height);
        //self.progressView.contentView.frame = frame;
        self.progressView.frame = frame;
        CGRect afterFrame = CGRectMake(0, 0, boundFrame.size.width, boundFrame.size.height);
        //        CABasicAnimation *tweenAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        //        tweenAnimation.duration = 0.5;
        //        tweenAnimation.fromValue = [NSNumber numberWithFloat:frame.origin.x];
        //        tweenAnimation.toValue = [NSNumber numberWithFloat:afterFrame.origin.x];
        //        tweenAnimation.removedOnCompletion = YES;
        //        tweenAnimation.fillMode = kCAFillModeForwards;
        //        [self.progressView.layer addAnimation:tweenAnimation forKey:@"animateLayer"];
        //CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        //shapeLayer.frame = afterFrame;
        //shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        //self.progressView.layer.mask = shapeLayer;

        //[self.progressView setNeedsLayout];
        //[self.progressView layoutIfNeeded];
        //[self.progressView.layer setNeedsDisplay];
        //[self.progressView.layer displayIfNeeded];

        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionOverrideInheritedOptions
                         animations:^{
                             @strongify(self);
                             self.progressView.frame = afterFrame;
                             //self.progressView.layer.mask.frame = afterFrame;
                         } completion:^(BOOL finished){
                             if (finished) {
                                 @strongify(self);
                                 [self startProgressBarAnimated];
                             }
                         }];

    });
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
