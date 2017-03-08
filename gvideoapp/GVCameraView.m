//
//  GVCameraView.m
//  gfitapp
//
//  Created by Gaurav Khanna on 12/21/13.
//  Copyright (c) 2013 Gaurav Khanna. All rights reserved.
//

#import "GVCameraView.h"
#import "GVRadialGradientLayer.h"
#import "GVOverlayRadialGradientLayer.h"
#import "GVSmoothRadialGradientLayer.h"
#import "GVModalCameraView.h"
#import "GVShiningRadialGradientLayer.h"

@interface GVCameraView ()

@property (nonatomic, assign) BOOL laidOutCamera;




@property (nonatomic, assign) BOOL showingHelpText;

@end

@implementation GVCameraView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.needsDisplayOnBoundsChange = NO;
        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = YES;

        //self.tapCaptureView = [[UIView alloc] initWithFrame:CGRectZero];
        //[self addSubview:self.tapCaptureView];









//        GVSmoothRadialGradientLayer *radialGradientLayer = [GVSmoothRadialGradientLayer layer];
//        self.radialGradientLayer = radialGradientLayer;
//        radialGradientLayer.colors = @[
//                                       (id)[UIColor whiteColor].CGColor,
//                                       (id)[UIColor clearColor].CGColor
//                                       ];
//        radialGradientLayer.shouldRasterize = YES;
//        radialGradientLayer.rasterizationScale = [UIScreen mainScreen].scale;
//        radialGradientLayer.toRadius = @200;
        //self.radialGradientLayer.opacity = 0.0;
        //radialGradientLayer.locations = @[@0, @0.3, @0.5, @1];
        //radialGradientLayer.gradientOrigin = CGPointMake(160, 134);
        //radialGradientLayer.gradientRadius = 245;

        //radialGradientLayer.frame = self.view.layer.bounds;
        //[self.layer addSublayer:radialGradientLayer];

//        double delayInSeconds = 3.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//
//            [CATransaction begin];
//            [CATransaction setAnimationDuration:2];
//
//            radialGradientLayer.colors = @[
//                                           (id)UIColorFromRGB(0xFA9333).CGColor,
//                                           (id)UIColorFromRGB(0xFED64D).CGColor,
//                                           (id)UIColorFromRGB(0xFEE57F).CGColor,
//                                           (id)UIColorFromRGB(0xFFFECF).CGColor,
//                                           ];
//            radialGradientLayer.gradientOrigin = CGPointMake(160, 334);
//            radialGradientLayer.gradientRadius = 120;
//            
//            [CATransaction commit];
//            
//        });

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.laidOutCamera) {
            [self layoutOrientation];
        } else if (self.previewLayer) {
            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

            switch (orientation) {
                case UIDeviceOrientationUnknown:

                    break;
                case UIDeviceOrientationPortrait: {
                    //if (self.lastOrientation != UIInterfaceOrientationPortrait) {
                    //[self.cameraNavigationOverlayView animateOrientationChange];
                    //self.lastOrientation = UIInterfaceOrientationPortrait;
                    self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                    //self.tapCaptureView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                    //self.frame = self.overlayBounds;//CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                    //self.bounds = self.overlayBounds;
                    //CGRect mainScreen = [UIScreen mainScreen].bounds;
                    //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                    //self.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                    //            self.layer. frame = CGRectMake(0, 0, self.layer.frame.size.height, self.layer.frame.size.width);
                    //self.previewLayer.frame = CGRectMake(self.layer.frame.origin.y, self.layer.frame.origin.x, self.layer.frame.size.height, self.layer.frame.size.width);

                    //}
                    self.layer.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.width, self.layer.frame.size.height);
                    break;
                }
                case UIDeviceOrientationPortraitUpsideDown: {
                    //if (self.lastOrientation != UIInterfaceOrientationPortraitUpsideDown) {
                    //[self.cameraNavigationOverlayView animateOrientationChange];
                    //  self.lastOrientation = UIInterfaceOrientationPortraitUpsideDown;
                    self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
                    //self.tapCaptureView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
                    //self.frame = self.overlayBounds;//CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                    //self.bounds = self.overlayBounds;
                    //CGRect mainScreen = [UIScreen mainScreen].bounds;
                    //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                    //self.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                    //                self.layer .frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.height, self.layer.frame.size.width);
                    //self.previewLayer.frame = CGRectMake(0, 0, self.layer.frame.size.width, self.layer.frame.size.height);
                    //self.previewLayer.frame = CGRectMake(self.layer.frame.origin.y, self.layer.frame.origin.x, self.layer.frame.size.height, self.layer.frame.size.width);
                    //}
                    self.layer.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.width, self.layer.frame.size.height);
                    break;
                }
                case UIDeviceOrientationLandscapeLeft: {
                    //if (self.lastOrientation != UIInterfaceOrientationLandscapeLeft) {
                    //[self.cameraNavigationOverlayView animateOrientationChange];
                    //  self.lastOrientation = UIInterfaceOrientationLandscapeLeft;
                    self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
                    //self.tapCaptureView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
                    //self.previewLayer.frame = self.previewLayer.bounds;
                    //self.frame = self.overlayBounds;
                    //self.bounds = self.overlayBounds;
                    //self.previewLayer.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
                    //CGRect mainScreen = [UIScreen mainScreen].bounds;
                    //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.height, mainScreen.size.width);
                    // }
                    //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                    self.layer.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.height, self.layer.frame.size.width);
                    //self.previewLayer.frame = CGRectMake(self.layer.frame.origin.x, self.bounds.origin.y, self.layer.bounds.size.width, self.layer.bounds.size.height);
                    //self.previewLayer.frame = CGRectMake(0, 0, 1024, 768);

                    break;
                }
                case UIDeviceOrientationLandscapeRight: {
                    //if (self.lastOrientation != UIInterfaceOrientationLandscapeRight) {
                    //[self.cameraNavigationOverlayView animateOrientationChange];
                    //   self.lastOrientation = UIInterfaceOrientationLandscapeRight;
                    self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
                    //self.tapCaptureView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
                    //self.frame = self.overlayBounds;
                    //self.bounds = self.overlayBounds;
                    //self.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
                    //}
                    //CGRect mainScreen = [UIScreen mainScreen].bounds;
                    //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                    //self.frame = CGRectMake(0, 0, mainScreen.size.height, mainScreen.size.width);
                    //self.previewLayer.frame = CGRectMake(0, 0, self.layer.frame.size.height, self.layer.frame.size.width);
                    //self.previewLayer.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.width, self.layer.frame.size.height);
                    //self.layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                    self.layer.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.height, self.layer.frame.size.width);
                    break;
                }
                case UIDeviceOrientationFaceUp:
                    
                    break;
                case UIDeviceOrientationFaceDown:
                    
                    break;
                default:
                    break;
            }
            self.previewLayer.frame = self.layer.bounds;
            self.laidOutCamera = YES;
        }
        //self.previewLayer.frame = self.layer.frame;
        //self.tapCaptureView.transform = CGAffineTransformScale(self.previewLayer.transform, 1, 1);
        //self.layer.frame = self.frame;
    } else {
        self.previewLayer.frame = self.layer.frame;

    }

}

- (void)didSetPreviewLayer:(CALayer*)previewLayer {
    if (self.previewLayer) {
        [self.previewLayer removeFromSuperlayer];
        self.previewLayer = nil;
    }
    self.previewLayer = (AVCaptureVideoPreviewLayer*)previewLayer;
    //self.previewLayer.allowsEdgeAntialiasing = YES;
    //self.previewLayer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge | kCALayerBottomEdge;
    [self.layer addSublayer:previewLayer];
    //self.previewLayer.bounds = ;
    self.previewLayer.allowsEdgeAntialiasing = YES;
    self.previewLayer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerTopEdge | kCALayerRightEdge | kCALayerLeftEdge;
    self.previewLayer.frame = CGRectIntegral(self.layer.frame);
    //self.previewLayer.bounds = [UIScreen mainScreen].bounds;
    //self.previewLayer.frame = [UIScreen mainScreen].bounds;
    //self.previewLayer.shouldRasterize = YES;
    //self.previewLayer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self.previewLayer setNeedsLayout];
    [self.tapCaptureView setNeedsLayout];
    
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
                //self.tapCaptureView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
                //self.frame = self.overlayBounds;//CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                //self.bounds = self.overlayBounds;
                //CGRect mainScreen = [UIScreen mainScreen].bounds;
                //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                //self.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                //            self.layer. frame = CGRectMake(0, 0, self.layer.frame.size.height, self.layer.frame.size.width);
                self.previewLayer.frame = CGRectMake(self.layer.frame.origin.y, self.layer.frame.origin.x, self.layer.frame.size.height, self.layer.frame.size.width);

                //}
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown: {
                //if (self.lastOrientation != UIInterfaceOrientationPortraitUpsideDown) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                //  self.lastOrientation = UIInterfaceOrientationPortraitUpsideDown;
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
                //self.tapCaptureView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
                //self.frame = self.overlayBounds;//CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                //self.bounds = self.overlayBounds;
                //CGRect mainScreen = [UIScreen mainScreen].bounds;
                //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                //self.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                //                self.layer .frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.height, self.layer.frame.size.width);
                //self.previewLayer.frame = CGRectMake(0, 0, self.layer.frame.size.width, self.layer.frame.size.height);
                self.previewLayer.frame = CGRectMake(self.layer.frame.origin.y, self.layer.frame.origin.x, self.layer.frame.size.height, self.layer.frame.size.width);
                //}
                break;
            }
            case UIDeviceOrientationLandscapeLeft: {
                //if (self.lastOrientation != UIInterfaceOrientationLandscapeLeft) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                //  self.lastOrientation = UIInterfaceOrientationLandscapeLeft;
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
                //self.tapCaptureView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
                //self.previewLayer.frame = self.previewLayer.bounds;
                //self.frame = self.overlayBounds;
                //self.bounds = self.overlayBounds;
                //self.previewLayer.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
                //CGRect mainScreen = [UIScreen mainScreen].bounds;
                //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.height, mainScreen.size.width);
                // }
                //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                //self.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.height, self.layer.frame.size.width);
                //self.previewLayer.frame = CGRectMake(self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.width, self.layer.bounds.size.height);
                self.previewLayer.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.width, self.layer.frame.size.height);

                break;
            }
            case UIDeviceOrientationLandscapeRight: {
                //if (self.lastOrientation != UIInterfaceOrientationLandscapeRight) {
                //[self.cameraNavigationOverlayView animateOrientationChange];
                //   self.lastOrientation = UIInterfaceOrientationLandscapeRight;
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
                //self.tapCaptureView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
                //self.frame = self.overlayBounds;
                //self.bounds = self.overlayBounds;
                //self.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
                //}
                //CGRect mainScreen = [UIScreen mainScreen].bounds;
                //self.previewLayer.frame = CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height);
                //self.frame = CGRectMake(0, 0, mainScreen.size.height, mainScreen.size.width);
                //self.previewLayer.frame = CGRectMake(0, 0, self.layer.frame.size.height, self.layer.frame.size.width);
                self.previewLayer.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.width, self.layer.frame.size.height);
                //self.layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
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
    //CGRect mainScreen = [UIScreen mainScreen].bounds;
    //self.previewLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}





//- (void)finishProgressBarAnimation {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        CGRect progressToolbarFrame = self.cameraOverlayView.progressToolbar.frame;
//        CGRect beforeFrame = CGRectMake(0, 0, progressToolbarFrame.size.width, progressToolbarFrame.size.height);
//        //CGRect startFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//        //CGRect midFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//        //startFrame.origin.x += 100;
//        beforeFrame.origin.x += beforeFrame.size.width;
//        //midFrame.origin.x += 300;
//        [self.cameraOverlayView.clippedProgressView.layer removeAllAnimations];
//        [UIView animateWithDuration:1.0
//                              delay:0.0
//             usingSpringWithDamping:0.8
//              initialSpringVelocity:0.0
//                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
//                         animations:^{
//                             @strongify(self);
//                             self.cameraOverlayView.clippedProgressView.frame = beforeFrame;
//                         } completion:nil];
//    });
//}
//
//- (void)setupProgressBarAnimated:(BOOL)animated {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        [self.cameraOverlayView.clippedProgressView.layer removeAllAnimations];
//        CGRect boundFrame = self.cameraOverlayView.progressToolbar.frame;
//        CGRect frame = CGRectMake(boundFrame.origin.x, 0, boundFrame.size.width, boundFrame.size.height);
//        self.cameraOverlayView.clippedProgressView.frame = frame;
//    });
//}
//
//- (void)resetProgressBarAnimation {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        CGRect progressToolbarFrame = self.cameraOverlayView.progressToolbar.frame;
//        CGRect beforeFrame = CGRectMake(0, 0, progressToolbarFrame.size.width, progressToolbarFrame.size.height);
//        //self.customCameraOverlayView.clippedProgressView.frame = beforeFrame;
//        //CGRect startFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//        //CGRect midFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//        //startFrame.origin.x += 100;
//        //beforeFrame.origin.x += beforeFrame.size.width;
//        //midFrame.origin.x += 300;
//        [self.cameraOverlayView.clippedProgressView.layer removeAllAnimations];
//        [UIView animateWithDuration:0.5
//                              delay:0.0
//                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             @strongify(self);
//                             self.cameraOverlayView.clippedProgressView.frame = beforeFrame;
//                         } completion:nil];
//    });
//}
//
//- (void)startProgressBarAnimation {
//    @weakify(self);
//    CGRect beforeFrame = self.cameraOverlayView.clippedProgressView.frame;
//    CGRect startFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//    CGRect midFrame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y, beforeFrame.size.width, beforeFrame.size.height);
//    startFrame.origin.x += 100;
//    beforeFrame.origin.x += beforeFrame.size.width;
//    midFrame.origin.x += 300;
//    //[self.customCameraOverlayView.progressView setProgress:1.0f animated:YES];
//    [self.cameraOverlayView.clippedProgressView.layer removeAllAnimations];
//    [UIView animateKeyframesWithDuration:30 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction | UIViewKeyframeAnimationOptionBeginFromCurrentState | UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
//        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.006 animations:^{
//            @strongify(self);
//            self.cameraOverlayView.clippedProgressView.frame = startFrame;
//        }];
//        //                        [UIView addKeyframeWithRelativeStartTime:0.006 relativeDuration:0.3 animations:^{
//        //                            @strongify(self);
//        //                            self.customCameraOverlayView.clippedProgressView.frame = midFrame;
//        //                        }];
//        [UIView addKeyframeWithRelativeStartTime:0.006 relativeDuration:0.9 animations:^{
//            @strongify(self);
//            self.cameraOverlayView.clippedProgressView.frame = beforeFrame;
//        }];
//    } completion:^(BOOL finished) {
//        if (finished) {
//
//        }
//    }];
//}

@end
