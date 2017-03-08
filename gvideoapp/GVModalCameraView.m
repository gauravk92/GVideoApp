//
//  GVModalCameraView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/6/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVModalCameraView.h"
#import "GVProgressNavigationBar.h"
#import "GVShiningRadialGradientLayer.h"
#import "GVOverlayRadialGradientLayer.h"
#import "GVTintColorUtility.h"
#import "GVParseObjectUtility.h"

#import "GVModalCameraVideoController.h"


CGFloat const GVModalCameraViewProgressBarHeight = 40;
CGFloat const GVModalCameraViewToolbarHeight = 100;

@interface GVModalCameraView () <UIToolbarDelegate>


@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) GVProgressView *progressNavBar;

@property (nonatomic, strong) GVShiningRadialGradientLayer *radialGradientLayerText;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, assign) BOOL showingHelpText;

@property (nonatomic, strong) GVOverlayRadialGradientLayer *radialGradientLayer;

@property (nonatomic, strong) CAGradientLayer *toolbarGradientLayer;


@end

@implementation GVModalCameraView

//+ (Class)layerClass {
//    return [CATransformLayer class];
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.clipsToBounds = YES;
        //self.autoresizesSubviews = NO;

        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.borderWidth = 0.5;
        //self.layer.shouldRasterize = YES;
        self.layer.needsDisplayOnBoundsChange = NO;
        self.layer.edgeAntialiasingMask = kCALayerTopEdge | kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge;
        self.layer.allowsEdgeAntialiasing = YES;
        //self.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge;
        //self.layer.allowsEdgeAntialiasing = YES;

        self.progressNavBar = [[GVProgressView alloc] initWithFrame:CGRectZero];
        self.progressNavBar.layer.shouldRasterize = YES;
        self.progressNavBar.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.progressNavBar.layer.needsDisplayOnBoundsChange = NO;
        //self.progressNavBar.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge;
        self.progressNavBar.layer.allowsEdgeAntialiasing = YES;


        UIColor *tintColor = [UIColor colorWithRed:0.000 green:0.886 blue:1.000 alpha:0.7];
        

        self.toolbar = [GVCameraToolbarLayer layer];
        self.toolbar.fillColor = [UIColor colorWithRed:0.000 green:0.001 blue:0.137 alpha:0.900].CGColor;
        self.toolbar.backgroundColor = [UIColor colorWithRed:0.000 green:0.001 blue:0.137 alpha:0.900].CGColor;
        self.toolbar.shouldRasterize = YES;
        self.toolbar.rasterizationScale = [UIScreen mainScreen].scale;
        self.toolbar.contentsScale = [UIScreen mainScreen].scale;

        self.toolbarGradientLayer = [CAGradientLayer layer];
        self.toolbarGradientLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor];
        self.toolbarGradientLayer.shouldRasterize = YES;
        self.toolbarGradientLayer.rasterizationScale = [UIScreen mainScreen].scale;
        self.toolbarGradientLayer.contentsScale = [UIScreen mainScreen].scale;
        self.toolbar.mask = self.toolbarGradientLayer;

        self.flipButton = [[GVButtonImageView alloc] initWithImage:[UIImage imageNamed:@"lineicons_flip_full"]];
        //[self.flipButton setImage:[UIImage imageNamed:@"glyphicons_081_refresh"]];
        //[self.flipButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
        //[self.flipButton setImageEdgeInsets:UIEdgeInsetsZero];
        //self.flipButton.enabled = YES;
        self.flipButton.autoresizesSubviews = NO;
        self.flipButton.layer.shouldRasterize = YES;
        self.flipButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.flipButton.layer.needsDisplayOnBoundsChange = NO;
        self.flipButton.tintColor = tintColor;

        //[self addSubview:self.flipButton];


        self.libraryButton = [[GVButtonImageView alloc] initWithImage:[UIImage imageNamed:@"lineicons_albums_full"]];
        self.libraryButton.layer.needsDisplayOnBoundsChange = NO;
        //[self.flipButton setImage:[UIImage imageNamed:@"glyphicons_081_refresh"]];
        //[self.flipButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
        //[self.flipButton setImageEdgeInsets:UIEdgeInsetsZero];
        //self.flipButton.enabled = YES;
        self.libraryButton.layer.shouldRasterize = YES;
        self.libraryButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.libraryButton.autoresizesSubviews = NO;
        CGAffineTransform libraryTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
        libraryTransform = CGAffineTransformScale(libraryTransform, -1, 1);
        //self.libraryButton.transform = libraryTransform;
        self.libraryButton.tintColor = tintColor;

        //[self addSubview:self.libraryButton];

        self.flashButton = [[GVButtonImageView alloc] initWithImage:[UIImage imageNamed:@"lineicons_flash_full"]];
        //[self.flipButton setImage:[UIImage imageNamed:@"glyphicons_081_refresh"]];
        //[self.flipButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
        //[self.flipButton setImageEdgeInsets:UIEdgeInsetsZero];
        //self.flipButton.enabled = YES;
        self.flashButton.autoresizesSubviews = NO;
        self.flashButton.layer.shouldRasterize = YES;
        self.flashButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.flashButton.layer.needsDisplayOnBoundsChange = NO;
        self.flashButton.tintColor = tintColor;

        //[self addSubview:self.flashButton];

        //self.progressNavBar.backgroundColor = [UIColor whiteColor];
        //self.progressNavBar.alpha = 0.8;
        //self.progressNavBar.layoutWithoutNavigationController = YES;
        //self.toolbar = [[GVCameraToolbar alloc] initWithFrame:CGRectZero];
        //self.toolbar.layer.needsDisplayOnBoundsChange = NO;
        //self.toolbar.layer.shouldRasterize = YES;
        //self.toolbar.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.toolbar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.95];
        //self.toolbar.tintColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        //self.toolbar.barStyle = UIBarStyleBlack;
        //self.toolbar.delegate = self;
        //self.toolbar.translucent = YES;
        //self.toolbar.alpha = 0.8;
        //self.toolbar.alpha = 0.8;
        //self.toolbar.barTintColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        //self.toolbar.layer.shouldRasterize = NO;
        //self.toolbar.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.toolbar.tintColor = [UIColor whiteColor];

//        self.gradientLayer = [CAGradientLayer layer];
//        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
//        self.gradientLayer.startPoint = CGPointMake(0.0f, -3.0f);
//        self.gradientLayer.endPoint = CGPointMake(0.0, 1.2f);
//        //self.collectionView.layer.mask = l;
//        self.toolbar.layer.mask = self.gradientLayer;

        self.cameraContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.cameraContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.cameraContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.cameraContainerView];

//
//        self.tapCaptureView = [[UIView alloc] initWithFrame:CGRectZero];
//        [self addSubview:self.tapCaptureView];


        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;

        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0];

        NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSBackgroundColorAttributeName: [UIColor clearColor],
                                     NSFontAttributeName: font};

        NSAttributedString *startString = [[NSAttributedString alloc] initWithString:@"Tap To Start Recording" attributes:attributes];


        self.textLabel = [[UILabel alloc] initWithFrame:frame];
        [self.textLabel setAttributedText:startString];
        self.textLabel.layer.shouldRasterize = YES;
        self.textLabel.layer.needsDisplayOnBoundsChange = NO;
        self.textLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;

        self.textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.textLabel.layer.shadowOpacity = 1;
        self.textLabel.layer.shadowOffset = CGSizeMake(0, 1);
        //self.textLabel.layer.shadowRadius = 1;


//        UIFont *labelFont = [UIFont fontWithName:@"Helvetica" size:32.0];
//        NSString *labelText = @"Foo";
//        CGSize viewSize = [labelText sizeWithFont:labelFont];
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(viewSize.width, viewSize.height), NO, 0.0);
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetFillColorWithColor(context, textColor.CGColor);
//        CGContextSetShadowWithColor(context, CGSizeZero, shadowRadius, shadowColor.CGColor);
//        [labelText drawInRect:CGRectMake(0.0, 0.0, viewSize.width, viewSize.height) withFont:labelFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
//        UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
//        [imageArray addObject:theImage];
//        UIGraphicsEndImageContext();

        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        fixedSpace.width = 25;

        // UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        //UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_081_refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(flipAction:)];
        //flipButton.title = @"Rear";

        UIBarButtonItem *libraryButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_318_more_items"] style:UIBarButtonItemStylePlain target:self action:@selector(libraryAction:)];
        libraryButton.title = @"Library";
        //   UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_192_circle_remove"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];

        //    UIBarButtonItem *flashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_205_electricity"] style:UIBarButtonItemStylePlain target:self action:@selector(flashAction:)];



        //UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_195_circle_info"] style:UIBarButtonItemStylePlain target:self action:@selector(infoAction:)];


        //[self.toolbar setItems:@[fixedSpace, flipButton, flexSpace, libraryButton, flexSpace, flashButton, fixedSpace] animated:NO];

        if (TESTING_ACCOUNT) {
            PFFile *file = [[PFUser currentUser] objectForKey:kGVUserCameraImageKey];
            if (file && ![file isKindOfClass:[NSNull class]]) {
                UIImage *image = [UIImage imageWithData:[file getData]];
                if (image) {
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                    imageView.frame = self.bounds;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    imageView.translatesAutoresizingMaskIntoConstraints = NO;
                    [self addSubview:imageView];
                }
            }
        }
        
        [self addSubview:self.progressNavBar];

        [self addSubview:self.textLabel];
        [self.layer addSublayer:self.toolbar];
        [self.toolbar addSublayer:self.flashButton.layer];
        [self.toolbar addSublayer:self.libraryButton.layer];
        [self.toolbar addSublayer:self.flipButton.layer];
        //    [self.layer addSublayer:self.flashButton.layer];

        //  [self.layer addSublayer:self.libraryButton.layer];
        //  [self.layer addSublayer:self.flipButton.layer];
        //self.radialGradientLayer = [[GVOverlayRadialGradientLayer alloc] init];

//        self.radialGradientLayer.contentLayer.toRadius = [NSNumber numberWithFloat:50];
//        self.radialGradientLayer.contentLayer.colors = @[(id)[UIColor colorWithWhite:1.0 alpha:0.2].CGColor, (id)[UIColor clearColor].CGColor];
//        self.radialGradientLayer.contentLayer.contentsOffset = [NSValue valueWithCGPoint:CGPointMake(0, 50)];
//        self.radialGradientLayer.overlayLayer.opacity = 1;
        //self.backgroundColor = [UIColor whiteColor];
        //self.layer.mask = self.radialGradientLayer;
        //[self setNeedsDisplay];
    }
    return self;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionBottom;
}


- (UIView*)flipButtonView {
    return self.flipButton;
}
- (UIView*)libraryButtonView {
    return self.libraryButton;
}
- (UIView*)flashButtonView {
    return self.flashButton;
}

- (void)setupInitialState {
    CGFloat progressHeight = GVModalCameraViewProgressBarHeight;

    //[self.textLabel.layer setNeedsLayout];
    //[self.textLabel.layer layoutIfNeeded];
    //[self.textLabel.layer setNeedsDisplay];
    //[self.textLabel.layer displayIfNeeded];
    self.progressNavBar.frame = CGRectIntegral(CGRectMake(-1, -1, self.bounds.size.width+2, progressHeight+1));

    self.radialGradientLayerText = [GVShiningRadialGradientLayer layer];
    self.radialGradientLayerText.toRadius = @200;
    self.radialGradientLayerText.colorValues = @[(id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor];
    [self.radialGradientLayerText setNeedsDisplay];
    //self.radialGradientLayerText.contentsDrawRectFrame = [NSValue valueWithCGRect:self.bounds];
    self.radialGradientLayerText.contentsOffset = [NSValue valueWithCGPoint:CGPointMake(0, -25)];
    //self.radialGradientLayerText.needsDisplayOnBoundsChange = YES;
    self.radialGradientLayerText.shouldRasterize = YES;
    self.radialGradientLayerText.rasterizationScale = [UIScreen mainScreen].scale;

    self.radialGradientLayerText.opacity = 1.0;

    //self.textLabel.layer.mask = self.radialGradientLayerText;

    [self.textLabel sizeToFit];
    [self.radialGradientLayerText setupInitialState];
    [self.radialGradientLayerText setNeedsDisplay];


    CGFloat toolbarHeight = GVModalCameraViewToolbarHeight;

    self.toolbar.frame = CGRectIntegral(CGRectMake(0, self.bounds.size.height - toolbarHeight, self.bounds.size.width, toolbarHeight));
    self.toolbarGradientLayer.frame = CGRectIntegral(CGRectMake(0, 0, self.toolbar.frame.size.width, self.toolbar.frame.size.height));
    [self.toolbar setNeedsDisplay];

    self.gradientLayer.frame = CGRectIntegral(self.toolbar.bounds);


    CGFloat toolbarInset = 30.0;
    CGFloat toolbarButtonHeight = GVModalCameraViewToolbarHeight;
    CGFloat toolbarY = 5;
    CGFloat buttonWidth = self.bounds.size.width / 3;

    self.flipButton.frame = CGRectIntegral(CGRectMake(0, toolbarY, buttonWidth, toolbarButtonHeight));

    self.libraryButton.frame = CGRectIntegral(CGRectMake(buttonWidth, toolbarY, buttonWidth, toolbarButtonHeight));
    //self.libraryButton.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    //self.libraryButton.frame = CGRectIntegral(self.libraryButton.frame);

    CGRect flashButtonRect = self.flipButton.bounds;
    flashButtonRect.origin.x = buttonWidth*2;
    flashButtonRect.origin.y = toolbarY;
    flashButtonRect.size.width = buttonWidth;
    flashButtonRect.size.height = toolbarButtonHeight;
    self.flashButton.frame = CGRectIntegral(flashButtonRect);

    //self.tapCaptureView.frame = CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - toolbarHeight));

    CGRect animatingRect = self.bounds;
    animatingRect.size.width = self.bounds.size.width * 2;
    self.radialGradientLayerText.frame = CGRectIntegral(animatingRect);

    CGRect radialContentRect = self.bounds;
    radialContentRect.origin.x = - (self.bounds.size.width);
    //[self.textLabel sizeToFit];
    CGRect innerTapRect = CGRectMake(0, GVModalCameraViewProgressBarHeight + self.textLabel.frame.size.height*2 - 20, self.bounds.size.width, self.bounds.size.height - GVModalCameraViewProgressBarHeight - GVModalCameraViewToolbarHeight);
    self.textLabel.center = CGPointMake(CGRectGetMidX(innerTapRect), CGRectGetMidY(innerTapRect));


    self.radialGradientLayerText.contentsDrawRectFrame = [NSValue valueWithCGRect:CGRectIntegral(innerTapRect)];
    self.radialGradientLayerText.contentsOffset = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    //self.textLabel.center = self.center;
    //self.radialGradientLayerText.contentsDrawRectFrame = [NSValue valueWithCGRect:CGRectIntegral(radialContentRect)];
    //self.textLabel.frame = innerTapRect;
    //self.textLabel.center = CGPointMake(<#CGFloat x#>, <#CGFloat y#>)

    self.radialGradientLayer.overlayLayer.frame = self.bounds;

    [self.radialGradientLayerText setNeedsLayout];
    [self.radialGradientLayerText layoutIfNeeded];

#if TESTING_PERF
    self.progressNavBar.hidden = YES;
    self.toolbar.hidden = YES;
    self.tapCaptureView.hidden = YES;
#endif

    //[self bringSubviewToFront:self.progressNavBar];
    //[self bringSubviewToFront:self.toolbar];
    //[self bringSubviewToFront:self.textLabel];
    //[self bringSubviewToFront:self.tapCaptureView];
    //[self bringSubviewToFront:self.tapCaptureView];

    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self animateInHelpText];
    });

}

- (void)animateInHelpText {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{

        @strongify(self);

        self.showingHelpText = YES;

        CABasicAnimation *previewMaskAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        previewMaskAnim.duration = 0.3;
        previewMaskAnim.fromValue = [NSNumber numberWithFloat:1.0];
        previewMaskAnim.toValue = [NSNumber numberWithFloat:0.0];
        previewMaskAnim.fillMode = kCAFillModeForwards;
        previewMaskAnim.removedOnCompletion = NO;


        [self.radialGradientLayer.overlayLayer removeAllAnimations];
        [self.radialGradientLayer.overlayLayer addAnimation:previewMaskAnim forKey:nil];

        [self.radialGradientLayerText animateShineNow];
        //        CABasicAnimation *textMaskAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        //        textMaskAnim.duration = 0.3;
        //        textMaskAnim.fromValue = [NSNumber numberWithFloat:0.0];
        //        textMaskAnim.toValue = [NSNumber numberWithFloat:1.0];
        //        textMaskAnim.fillMode = kCAFillModeForwards;
        //        textMaskAnim.removedOnCompletion = NO;
        //        [self.textLabel.layer.mask removeAllAnimations];
        //        [self.textLabel.layer.mask addAnimation:textMaskAnim forKey:nil];


    });
}

//- (void)animateOutHelpText {
//    @weakify(self);
//    //    if (!self.showingHelpText) {
//    //        return;
//    //    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//
//        self.showingHelpText = NO;
//        self.textLabel.hidden = YES;
//
//        CABasicAnimation *previewMaskAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        previewMaskAnim.duration = 0.3;
//        previewMaskAnim.fromValue = [NSNumber numberWithFloat:0.0];
//        previewMaskAnim.toValue = [NSNumber numberWithFloat:1.0];
//        previewMaskAnim.fillMode = kCAFillModeForwards;
//        previewMaskAnim.removedOnCompletion = NO;
//
//        [self.radialGradientLayer.overlayLayer removeAllAnimations];
//        [self.radialGradientLayer.overlayLayer addAnimation:previewMaskAnim forKey:nil];
//        //
//        //        CABasicAnimation *textMaskAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        //        textMaskAnim.duration = 0.3;
//        //        textMaskAnim.fromValue = [NSNumber numberWithFloat:1.0];
//        //        textMaskAnim.toValue = [NSNumber numberWithFloat:0.0];
//        //        textMaskAnim.fillMode = kCAFillModeForwards;
//        //        textMaskAnim.removedOnCompletion = NO;
//        //        [self.textLabel.layer.mask removeAllAnimations];
//        //        [self.textLabel.layer.mask addAnimation:textMaskAnim forKey:nil];
//
//        //        CATransform3D fromTransform = CATransform3DIdentity;
//        //        fromTransform = CATransform3DTranslate(fromTransform, 0, self.tapCaptureView.frame.size.height / 2, 0);
//        //
//        //        CATransform3D toTransform = CATransform3DIdentity;
//        //
//        //        CABasicAnimation *textMaskSlide = [CABasicAnimation animationWithKeyPath:@"transform"];
//        //        textMaskSlide.fromValue = [NSValue valueWithCATransform3D:toTransform];
//        //        textMaskSlide.toValue = [NSValue valueWithCATransform3D:fromTransform];
//        //        textMaskSlide.duration = 0.15;
//        //        textMaskSlide.fillMode = kCAFillModeForwards;
//        //        textMaskSlide.timingFunction = [CAMediaTimingFunction functionWithName:@"easeOut"];
//        //        textMaskSlide.removedOnCompletion = NO;
//        //        [self.textLabel.layer removeAllAnimations];
//        //        [self.textLabel.layer addAnimation:textMaskSlide forKey:nil];
//    });
//}

//- (void)flipAction:(id)sender {
//    //if (!self.recording) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:GVCameraFlipActionNotification object:nil];
//    //}
//}
//
//- (void)libraryAction:(id)sender {
//    //if (!self.recording) {
//        NSDictionary *info = @{@"sender": sender};
//        [[NSNotificationCenter defaultCenter] postNotificationName:GVCameraLibraryActionNotification object:nil userInfo:info];
//    //}
//}
//
//- (void)cancelAction:(id)sender {
//    [[NSNotificationCenter defaultCenter] postNotificationName:GVCameraCancelActionNotification object:nil];
//}
//
//- (void)flashAction:(id)sender {
//    [[NSNotificationCenter defaultCenter] postNotificationName:GVCameraViewControllerFlashActionNotification object:nil];
//}

- (void)finishProgressBarAnimated:(id)sender {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [UIView animateWithDuration:0.3 animations:^{
            @strongify(self);
            self.flipButton.contentImageView.alpha = 1;
            self.libraryButton.contentImageView.alpha = 1;
            self.textLabel.alpha = 1;
        }];
        [self.progressNavBar finishProgressBarAnimated];
    });
}

- (void)fillProgressBarAnimated:(id)sender {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [UIView animateWithDuration:0.3 animations:^{
            @strongify(self);
            self.flipButton.contentImageView.alpha = GVModalCameraDisabledButtonAlpha;
            self.libraryButton.contentImageView.alpha = GVModalCameraDisabledButtonAlpha;
            self.textLabel.alpha = 0.0;
        }];

        [self.progressNavBar fillProgressBarAnimated];
    });
}

- (void)layoutRasterizationScales {
    CGFloat rasScale = [UIScreen mainScreen].scale;
//    for (CALayer *layer in self.toolbar.layer.sublayers) {
//        if (layer.shouldRasterize) {
//            layer.rasterizationScale = rasScale;
//        }
//    }
    for (CALayer *layer in self.progressNavBar.layer.sublayers) {
        if (layer.shouldRasterize) {
            layer.rasterizationScale = rasScale;
        }
    }
}

- (void)setNeedsLayout {
    [super setNeedsLayout];

    //[self.progressNavBar setNeedsLayout];
    //[self.toolbar setNeedsLayout];
    //[self.cameraContainerView setNeedsLayout];
    //[self.cameraViewController.view setNeedsLayout];
    //[self.textLabel setNeedsLayout];
    //[self.radialGradientLayerText setNeedsLayout];
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    //[self.radialGradientLayerText setNeedsDisplay];
    //[self.radialGradientLayerText setNeedsDisplay];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    //self.toolbar.zPosition = 1;




}

- (void)setupCameraViewController:(GVCameraViewController*)cameraVC {
    self.cameraViewController = cameraVC;
    cameraVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cameraVC.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self.cameraContainerView addSubview:cameraVC.view];
    [self.cameraContainerView bringSubviewToFront:cameraVC.view];

    cameraVC.view.frame = CGRectIntegral(self.bounds);
    cameraVC.view.clipsToBounds = YES;
    cameraVC.view.layer.allowsEdgeAntialiasing = YES;
    cameraVC.view.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerTopEdge | kCALayerRightEdge | kCALayerLeftEdge;

    [self.cameraContainerView setNeedsLayout];
    [cameraVC.view setNeedsLayout];
    [self.cameraContainerView layoutIfNeeded];
    [self.cameraViewController.view layoutIfNeeded];
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *superHitView = [super hitTest:point withEvent:event];
    DLogObject(superHitView);
    return superHitView;
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
