//
//  GVCameraOverlayView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/22/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCameraOverlayView.h"
#import "GVCameraProgressView.h"
#import "GVTintColorUtility.h"
#import "UIColor+Image.h"

@interface GVCameraOverlayView () <UIToolbarDelegate>

@property (nonatomic, strong) UIToolbar *infoToolbar;

@end

@implementation GVCameraOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code

        

        self.tapCaptureView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.tapCaptureView];

        self.progressToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        self.progressToolbar.barStyle = UIBarStyleDefault;
        self.progressToolbar.translucent = YES;
        self.progressToolbar.hidden = YES;
        [self addSubview:self.progressToolbar];



        self.progressView = [[GVCameraProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        //self.progressView.hidden = YES;
        self.progressView.progress = 1.0;


        self.clippedProgressView = [[GVCameraProgressClippedView alloc] initWithFrame:CGRectZero];
        [self.clippedProgressView addSubview:self.progressView];
        self.clippedProgressView.cameraProgressView = self.progressView;
        self.clippedProgressView.hidden = YES;
        [self addSubview:self.clippedProgressView];

        self.toolbar = [[UIToolbar alloc] initWithFrame:frame];
        //self.toolbar.translatesAutoresizingMaskIntoConstraints = YES;
        //self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.toolbar.barStyle = UIBarStyleBlack;
        self.toolbar.translucent = YES;
        self.toolbar.tintColor = [GVTintColorUtility utilityTintColor];

        self.infoToolbar = [[UIToolbar alloc] initWithFrame:frame];
        //self.infoToolbar.translatesAutoresizingMaskIntoConstraints = YES;
        //self.infoToolbar.auto
        self.infoToolbar.delegate = self;
        self.infoToolbar.barStyle = UIBarStyleDefault;
        self.infoToolbar.translucent = YES;
        self.infoToolbar.tintColor = [UIColor whiteColor];
        self.infoToolbar.barTintColor = [UIColor clearColor];
        self.infoToolbar.backgroundColor = [UIColor clearColor];
        [self.infoToolbar setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        self.infoToolbar.alpha = 0;
        self.infoToolbar.userInteractionEnabled = NO;


        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        fixedSpace.width = 10;

        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_081_refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(flipAction:)];
        flipButton.title = @"Rear";

        UIBarButtonItem *libraryButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_318_more_items"] style:UIBarButtonItemStylePlain target:self action:@selector(libraryAction:)];
        libraryButton.title = @"Library";
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_192_circle_remove"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];

        UIBarButtonItem *flashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_205_electricity"] style:UIBarButtonItemStylePlain target:self action:@selector(flashAction:)];

        UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_195_circle_info"] style:UIBarButtonItemStylePlain target:self action:@selector(infoAction:)];


        self.progressToolbar.items = @[flexSpace, fixedSpace, flexSpace];
        self.toolbar.items = @[fixedSpace, flipButton, flexSpace, libraryButton, flexSpace, infoButton, flexSpace, flashButton, flexSpace, cancelButton, fixedSpace];
        self.toolbar.delegate = self;
        [self addSubview:self.toolbar];


        UIBarButtonItem *flashTitle = [[UIBarButtonItem alloc] initWithTitle:@"Flash" style:UIBarButtonItemStylePlain target:nil action:NULL];
        UIBarButtonItem *cancelTitle = [[UIBarButtonItem alloc] initWithTitle:@"Exit" style:UIBarButtonItemStylePlain target:nil action:NULL];
        UIBarButtonItem *libraryTitle = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:nil action:NULL];
        UIBarButtonItem *flipTitle = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStylePlain target:nil action:NULL];
        UIBarButtonItem *infoTitle = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_195_circle_info"] style:UIBarButtonItemStylePlain target:nil action:NULL];
        infoTitle.customView.hidden = YES;
        UIBarButtonItem *infoSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        infoSpace.width = 31;
        UIBarButtonItem *titleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        titleSpace.width = 6;

        self.infoToolbar.items = @[titleSpace, flipTitle, flexSpace, libraryTitle, flexSpace, infoSpace, flexSpace, flashTitle, flexSpace, cancelTitle, titleSpace];
        [self addSubview:self.infoToolbar];

    }
    return self;
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    if (bar == self.toolbar) {
        return UIBarPositionTop;
    }
    return UIBarPositionTopAttached;
}

- (void)flipAction:(id)sender {

    if ([self.pickerDelegate respondsToSelector:@selector(flipCamera:)]) {
        [self.pickerDelegate performSelector:@selector(flipCamera:) withObject:self];
    }
}

- (void)libraryAction:(id)sender {
    if ([self.pickerDelegate respondsToSelector:@selector(libraryAction:)]) {
        [self.pickerDelegate performSelector:@selector(libraryAction:) withObject:sender];
    }
}

- (void)cancelAction:(id)sender {

    if ([self.pickerDelegate respondsToSelector:@selector(cancelAction:)]) {
        [self.pickerDelegate performSelector:@selector(cancelAction:) withObject:self];
    }
}

- (void)flashAction:(id)sender {
    if ([self.pickerDelegate respondsToSelector:@selector(flashAction:)]) {
        [self.pickerDelegate performSelector:@selector(flashAction:) withObject:sender];
    }
}

- (void)infoAction:(id)sender {
    CGFloat toAlpha = (self.infoToolbar.alpha > 0.5) ? 0.0 : 0.8;
    @weakify(self);
    [UIView animateWithDuration:0.6
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         @strongify(self);
                         self.infoToolbar.alpha = toAlpha;
                     } completion:nil];
}

- (void)setNeedsLayout {
    [super setNeedsLayout];

}

- (void)layoutToolbar {
    for (UIView *subview in self.toolbar.subviews) {
        if ([subview isKindOfClass:[UIBarButtonItem class]]) {
            UIBarButtonItem *button = (UIBarButtonItem*)subview;
            UIView *customView = [button customView];
            [customView setNeedsLayout];
            [customView layoutIfNeeded];
        }
    }
    [self.toolbar setNeedsLayout];
}

- (void)layoutOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

        switch (orientation) {
            case UIDeviceOrientationUnknown:

                break;
            case UIDeviceOrientationPortrait: {
                //if (self.lastOrientation != UIInterfaceOrientationPortrait) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                //self.lastOrientation = UIInterfaceOrientationPortrait;
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.frame = self.overlayBounds;//CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                //self.bounds = self.overlayBounds;
                CGRect mainScreen = [UIScreen mainScreen].bounds;
                self.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                //}
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown: {
                //if (self.lastOrientation != UIInterfaceOrientationPortraitUpsideDown) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                //  self.lastOrientation = UIInterfaceOrientationPortraitUpsideDown;
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.frame = self.overlayBounds;//CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                //self.bounds = self.overlayBounds;
                CGRect mainScreen = [UIScreen mainScreen].bounds;
                self.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                //}
                break;
            }
            case UIDeviceOrientationLandscapeLeft: {
                //if (self.lastOrientation != UIInterfaceOrientationLandscapeLeft) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                //  self.lastOrientation = UIInterfaceOrientationLandscapeLeft;
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.frame = self.overlayBounds;
                //self.bounds = self.overlayBounds;
                //self.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
                CGRect mainScreen = [UIScreen mainScreen].bounds;
                self.frame = CGRectMake(0, 0, mainScreen.size.height, mainScreen.size.width);
                // }
                break;
            }
            case UIDeviceOrientationLandscapeRight: {
                //if (self.lastOrientation != UIInterfaceOrientationLandscapeRight) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                //   self.lastOrientation = UIInterfaceOrientationLandscapeRight;
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.frame = self.overlayBounds;
                //self.bounds = self.overlayBounds;
                //self.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
                //}
                CGRect mainScreen = [UIScreen mainScreen].bounds;
                self.frame = CGRectMake(0, 0, mainScreen.size.height, mainScreen.size.width);
                break;
            }
            case UIDeviceOrientationFaceUp:

                break;
            case UIDeviceOrientationFaceDown:

                break;
            default:
                break;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    //self.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);


    CGFloat progressBarHeight = 36;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        progressBarHeight = 30;
    }


    self.progressToolbar.frame = CGRectMake(0, 0, self.frame.size.width, progressBarHeight);
    self.clippedProgressView.frame = self.progressToolbar.frame;

    CGFloat toolbarHeight = 100;

    self.toolbar.frame = CGRectMake(0, self.frame.size.height - toolbarHeight, self.frame.size.width, toolbarHeight);

    CGFloat infoToolbarHeight = 25;

    self.infoToolbar.frame = CGRectMake(0, self.frame.size.height - infoToolbarHeight, self.frame.size.width, infoToolbarHeight);

    self.tapCaptureView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - toolbarHeight);
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
