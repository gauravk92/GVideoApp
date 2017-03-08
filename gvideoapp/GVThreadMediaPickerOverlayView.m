//
//  GVThreadMediaPickerOverlayView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/8/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVThreadMediaPickerOverlayView.h"

@interface GVThreadMediaPickerOverlayView ()

@property (nonatomic, strong) UIButton *libraryButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *retakeButton;

@end

@implementation GVThreadMediaPickerOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        @autoreleasepool {
            [self setup_overlayView];
        }
    }
    return self;
}

- (void)setup_overlayView {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentRight;

    NSString *title = NSLocalizedString(@"Library", @"Library");
    UIColor *titleNormalColor = [UIColor whiteColor];
    UIColor *titleNormalBackgroundColor = [UIColor clearColor];
    NSDictionary *normalDict = @{NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: titleNormalColor,
                                 NSBackgroundColorAttributeName: titleNormalBackgroundColor};
    NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:title attributes:normalDict];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [button setTitleEdgeInsets:UIEdgeInsetsZero];
    [button setAttributedTitle:titleString forState:UIControlStateNormal];
    self.libraryButton = button;
    [button addTarget:self action:@selector(showLibrary:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];

    UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.captureButton = captureButton;

    [self.captureButton addTarget:self action:@selector(captureButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:captureButton];

    UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.retakeButton = retakeButton;
    [self.retakeButton addTarget:self action:@selector(retakeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:retakeButton];
    self.retakeButton.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = self.bounds.size.width;
    static CGFloat buttonHeight = 73;
    //static CGFloat buttonPadding = 40;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGFloat libraryWidth = (width / 2) - 50;

        CGRect buttonFrame = CGRectMake(CGRectGetWidth(self.bounds) - libraryWidth - 18, CGRectGetHeight(self.bounds) - buttonHeight, libraryWidth, buttonHeight);
        CGRect libraryFrame = CGRectMake(CGRectGetWidth(self.bounds) - libraryWidth - 18, CGRectGetHeight(self.bounds) - buttonHeight - buttonHeight, libraryWidth, buttonHeight);
        self.libraryButton.frame = libraryFrame;

        CGRect captureFrame = CGRectMake((width / 2) - 40, CGRectGetHeight(self.bounds) - buttonHeight, 80, buttonHeight);
        self.captureButton.frame = captureFrame;


        CGRect retakeFrame = CGRectMake(0, CGRectGetHeight(self.bounds) - buttonHeight, (width / 2) - 50, buttonHeight);
        self.retakeButton.frame = buttonFrame;

    } else {
        CGFloat libraryWidth = (width / 2) - 50;

        CGRect buttonFrame = CGRectMake(CGRectGetWidth(self.bounds) - libraryWidth - 18, CGRectGetHeight(self.bounds) - buttonHeight, libraryWidth, buttonHeight);
        self.libraryButton.frame = buttonFrame;

        CGRect captureFrame = CGRectMake((width / 2) - 40, CGRectGetHeight(self.bounds) - buttonHeight, 80, buttonHeight);
        self.captureButton.frame = captureFrame;


        CGRect retakeFrame = CGRectMake(0, CGRectGetHeight(self.bounds) - buttonHeight, (width / 2) - 50, buttonHeight);
        self.retakeButton.frame = retakeFrame;
    }
//    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
//
//    CGFloat landscapeWidth = 274;
//    CGFloat landscapeHeight = 43;
//
//    switch (deviceOrientation) {
//        case UIDeviceOrientationUnknown:
//
//            break;
//        case UIDeviceOrientationPortrait:
//            NSLog(@"media picker portrait orientation change");
//            self.libraryPickerNavBar.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
//            self.libraryPickerNavBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), landscapeHeight);
//            break;
//        case UIDeviceOrientationPortraitUpsideDown:
//            self.libraryPickerNavBar.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
//            self.libraryPickerNavBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), landscapeHeight);
//            break;
//        case UIDeviceOrientationLandscapeLeft:
//            NSLog(@" media picker landscape left orientation change");
//            self.libraryPickerNavBar.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
//
//            // x and y are swapped here
//            self.libraryPickerNavBar.frame = CGRectMake(CGRectGetWidth(self.bounds) - landscapeHeight , (self.bounds.size.height / 2) - (landscapeWidth / 2), landscapeHeight, landscapeWidth);
//            break;
//        case UIDeviceOrientationLandscapeRight:
//            NSLog(@"media picker landscape right orientation change");
//            self.libraryPickerNavBar.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
//
//            // x and y are swapped here
//            self.libraryPickerNavBar.frame = CGRectMake(0, (self.bounds.size.height / 2) - (landscapeWidth / 2), landscapeHeight, landscapeWidth);
//            break;
//        case UIDeviceOrientationFaceUp:
//
//            break;
//        case UIDeviceOrientationFaceDown:
//            
//            break;
//            
//        default:
//            break;
//    }
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *superHitTest = [super hitTest:point withEvent:event];
    if ([superHitTest isEqual:self.libraryButton]) {
        return self.libraryButton;
    }
    if ([superHitTest isEqual:self.captureButton]) {
        return self.captureButton;
    }
    if ([superHitTest isEqual:self.retakeButton]) {
        return self.retakeButton;
    }
    return nil;
}

//- (void)animateOrientationChange {
//    self.libraryPickerNavBar.alpha = 0.0;
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
//    @weakify(self);
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        self_weak_.libraryPickerNavBar.alpha = 1;
//    } completion:nil];
//}

- (void)captureButton:(id)sender {
    if (self.chooseExistingDelegate && [self.chooseExistingDelegate respondsToSelector:@selector(chooseCaptureButton:)]) {
        [self.chooseExistingDelegate performSelector:@selector(chooseCaptureButton:) withObject:self];
    }
}

- (void)showLibrary:(id)sender {
    if (self.chooseExistingDelegate && [self.chooseExistingDelegate respondsToSelector:@selector(chooseExistingButton:)]) {
        [self.chooseExistingDelegate performSelector:@selector(chooseExistingButton:) withObject:self];
    }
}

- (void)retakeButton:(id)sender {
    if (self.chooseExistingDelegate && [self.chooseExistingDelegate respondsToSelector:@selector(chooseRetakeButton:)]) {
        [self.chooseExistingDelegate performSelector:@selector(chooseRetakeButton:) withObject:self];
    }
}

- (BOOL)libraryButtonHidden {
    return self.libraryButton.hidden;
}

- (void)hideLibraryButton {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        self_weak_.libraryButton.hidden = YES;
    });
}

- (void)showLibraryButton {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.libraryButton.hidden = NO;
        self.captureButton.hidden = NO;
        self.retakeButton.hidden = YES;
    });
}

- (void)showRetakeButton {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.captureButton.hidden = YES;
        self.retakeButton.hidden = NO;
    });
}

- (void)hideRetakeButton {
    self.retakeButton.hidden = YES;
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
