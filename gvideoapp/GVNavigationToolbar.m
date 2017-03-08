//
//  GVNavigationToolbar.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/10/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVNavigationToolbar.h"
#import "GVTintColorUtility.h"
#import "GVRadialGradientLayer.h"
#import "GVTwitterAuthUtility.h"
#import "GVNavigationProfileView.h"
#import "GVNavigationButtonView.h"
#import "GVMasterViewController.h"
#import "UIImage+AspectSize.h"
#import "GVComposeViewController.h"
#import "GVAppDelegate.h"
#import <Social/Social.h>

@interface GVNavigationToolbar () <UIGestureRecognizerDelegate>

//@property (nonatomic, strong) CAGradientLayer *gradientLayer;

#if SOME_GRADIENT_LAYERS
@property (nonatomic, strong) GVRadialGradientLayer *radialGradientLayer;
@property (nonatomic, strong) CAGradientLayer *textGradientLayer;
#endif
//@property (nonatomic, strong) GVNavigationProfileView *profileView;

//@property (nonatomic, strong) UIImageView *addButton;

@property (nonatomic, assign) CGRect firstItemRect;
@property (nonatomic, assign) BOOL firstItemHighlight;
@property (nonatomic, assign) CGRect secondItemRect;
@property (nonatomic, assign) BOOL secondItemHighlight;
@property (nonatomic, assign) CGRect thirdItemRect;
@property (nonatomic, assign) BOOL thirdItemHighlight;

#if SHOWING_PROFILE_PICTURE_AND_USERNAME
@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, strong) CAShapeLayer *profilePicMask;

@property (nonatomic, strong) NSDictionary *labelAttributes;

#endif

@end

@implementation GVNavigationToolbar

- (BOOL)isCustomClickableScrollViewObject {
    return YES;
}

- (void)handleTap:(NSValue*)point {
    CGPoint viewPoint = [point CGPointValue];
    //CGPoint addPoint = [self convertPoint:viewPoint toView:self.addButton];
    [self handleTapFail:point];
    
    if (!CGRectContainsPoint(self.bounds, viewPoint)) {
        return;
    }
    
    if (viewPoint.x < self.bounds.size.width/3) {
        //self.firstItemHighlight = NO;
        //[self setNeedsDisplayInRect:self.firstItemRect];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerPullUpNotification object:nil];
    } else if (viewPoint.x < (self.bounds.size.width/3)*2) {
        //self.secondItemHighlight = NO;
        //[self setNeedsDisplayInRect:self.secondItemRect];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVThreadInviteNotification object:nil];
//        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
//        {
//            SLComposeViewController *fbPost = [GVComposeViewController
//                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
//
//            [fbPost setInitialText:@"Gvideo lets me see your reaction! Pretty cool. "];
//
//            [fbPost addImage:[UIImage imageNamed:@"shareImage.png"]];
//
//            [self.window.rootViewController presentViewController:fbPost animated:YES completion:nil];
//
//            [fbPost setCompletionHandler:^(SLComposeViewControllerResult result) {
//
//
//                switch (result) {
//                    case SLComposeViewControllerResultCancelled:
//                        NSLog(@"Post Canceled");
//                        break;
//                    case SLComposeViewControllerResultDone:
//                        NSLog(@"Post Sucessful");
//                        break;
//
//                    default:
//                        break;
//                }
//                
//                [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
//                
//            }];
//        }
    } else {
        //self.thirdItemHighlight = NO;
        //[self setNeedsDisplayInRect:self.thirdItemRect];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVNavigationProfileViewSettingsTapNotification object:nil];
    }
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        //self.backgroundColor = [UIColor colorWithHue:0.751 saturation:0.777 brightness:0.529 alpha:0.8]
        //self.backgroundColor = [UIColor colorWithRed:0.037 green:0.047 blue:0.141 alpha:0.990];

        //self.profileView = [[GVNavigationProfileView alloc] initWithFrame:frame];
        //[self addSubview:self.profileView];
        //[self.profileView setNeedsDisplay];

//        self.gradientLayer = [CAGradientLayer layer];
//
//        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
//        self.gradientLayer.startPoint = CGPointMake(0.0f, -50.0f);
//        self.gradientLayer.endPoint = CGPointMake(0.0, 0.8f);
//        [self.gradientLayer setNeedsDisplay];
        //self.collectionView.layer.mask = l;
        //self.layer.mask = self.gradientLayer;

#if SOME_GRADIENT_LAYERS
        self.radialGradientLayer = [GVRadialGradientLayer layer];
        [self.radialGradientLayer setNeedsDisplay];
        self.radialGradientLayer.shouldRasterize = YES;
        self.radialGradientLayer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.radialGradientLayer.colorValues = @[(id)[UIColor clearColor].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.8]];
        self.radialGradientLayer.toRadius = [NSNumber numberWithFloat:210];
        self.radialGradientLayer.contentsOriginPoint = [NSValue valueWithCGPoint:CGPointMake(0.5, 1)];
        self.radialGradientLayer.contentsOffset = [NSValue valueWithCGPoint:CGPointMake(0, 125)];
        //self.layer.mask = self.radialGradientLayer;

        self.textGradientLayer = [CAGradientLayer layer];
        self.textGradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        self.textGradientLayer.startPoint = CGPointMake(0.0, -1.6f);
        self.textGradientLayer.endPoint = CGPointMake(0.0, 0.6f);
        [self.textGradientLayer setNeedsDisplay];
        //self.settingsLabel.layer.mask = self.textGradientLayer;
#endif
        //self.addButton = [[GVNavigationButtonView alloc] initWithImage:];
        //[self addSubview:self.addButton];

        self.backgroundColor = [UIColor colorWithRed:0.000 green:0.001 blue:0.137 alpha:0.900];

        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;


#if SHOWING_PROFILE_PICTURE_AND_USERNAME
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;

        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];

        self.labelAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.95],
                                 NSFontAttributeName: font};

        NSString *username = [[PFUser currentUser] username];

        if (username) {

        }

        NSAttributedString *settingsString = [[NSAttributedString alloc] initWithString:username attributes:self.labelAttributes];

        self.usernameLabel = [[UILabel alloc] initWithFrame:frame];
        [self.usernameLabel setAttributedText:settingsString];
        self.usernameLabel.layer.shouldRasterize = YES;
        self.usernameLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self addSubview:self.usernameLabel];
        //[self addSubview:self.settingsLabel];

        self.profilePicView = [[UIImageView alloc] initWithFrame:frame];
        self.profilePicView.contentMode = UIViewContentModeScaleAspectFill;
        self.profilePicView.layer.allowsGroupOpacity = NO;
        self.profilePicView.layer.shouldRasterize = YES;
        //self.profilePicView.layer.contentsScale = [UIScreen mainScreen].scale;
        self.profilePicView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.profilePicView.clipsToBounds = YES;
        [self addSubview:self.profilePicView];

        self.profilePicMask = [CAShapeLayer layer];

        //self.profilePicMask.needsDisplayOnBoundsChange = NO;
        self.profilePicMask.opaque = YES;
        //self.profilePicMask.fillColor = [UIColor whiteColor].CGColor;
        self.profilePicMask.backgroundColor = [UIColor whiteColor].CGColor;
        self.profilePicView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.profilePicMask.contentsScale = [UIScreen mainScreen].scale;
        [self.profilePicMask setNeedsDisplay];
        self.profilePicView.layer.mask = self.profilePicMask;

//        self.profileTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleProfileTap:)];
//        self.profileTapGestureRecognizer.minimumPressDuration = 0.01;
//        self.profileTapGestureRecognizer.numberOfTapsRequired = 0;
//        self.profileTapGestureRecognizer.cancelsTouchesInView = YES;
//        self.profileTapGestureRecognizer.delegate = self;
//
//        self.addTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddTap:)];
//        self.addTapGestureRecognizer.minimumPressDuration = 0.01;
//        self.addTapGestureRecognizer.numberOfTapsRequired = 0;
//        self.addTapGestureRecognizer.cancelsTouchesInView = YES;
//        self.addTapGestureRecognizer.delegate = self;
//
//        [self.addButton addGestureRecognizer:self.addTapGestureRecognizer];
//        [self addGestureRecognizer:self.profileTapGestureRecognizer];


        @weakify(self);
        [GVTwitterAuthUtility shouldGetProfileImageForCurrentUserBlock:^(NSURL *imageURL, NSURL *bannerURL, NSString *realName) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @strongify(self);
                [self.profilePicView setImageWithURL:imageURL];

                if (realName) {

                    //DLogMainThread();
                    NSArray *firstName = [realName componentsSeparatedByString:@" "];

                    NSAttributedString *text = [[NSAttributedString alloc] initWithString:realName attributes:self.labelAttributes];
                    [self.usernameLabel setAttributedText:text];

                    [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
                     //[self layoutIfNeeded];
                    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
                    //[self.profilePicMask setNeedsDisplay];
                    //[self setNeedsDisplay];
                    //[self.layer displayIfNeeded];
                    //[self layoutIfNeeded];
                    //[self.profilePicMask setNeedsDisplay];
                    //[self.profilePicView setNeedsDisplay];
                    //[self setNeedsDisplay];
                    //[self.layer displayIfNeeded];
                    //[self.superview setNeedsLayout];
                    //[self.superview layoutIfNeeded];
                    //[self.superview setNeedsDisplay];
                    //[self.profilePicView setNeedsDisplay];
                }

                //if (image) {
                //[self.profileImageView setImage:image];
                //self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;

                //[self.bannerImageView setImage:banner];
                //self.bannerImageView.contentMode = UIViewContentModeScaleAspectFill;

                //[self.activityIndicatorView stopAnimating];
                //self.activityIndicatorView.hidden = YES;
                //}
            });
        }];
#endif

    }
    return self;
}
//
//- (void)setNeedsLayout {
//    [super setNeedsLayout];
//    //[self.profileView setNeedsLayout];
//}

//- (void)setNeedsDisplay {
//    [super setNeedsDisplay];
//
//    [self.profilePicView setNeedsDisplay];
//    [self.profilePicMask setNeedsDisplay];
//}

//- (void)handleTap:(NSValue*)point {
//    //if (gc.state == UIGestureRecognizerStateEnded) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:GVNavigationProfileViewSettingsTapNotification object:nil];
//    //}
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#if NAV_LAYOUT_SUBVIEWS
- (void)layoutSubviews {

    CGFloat settingsPadding = 5;

    //self.profileView.frame = CGRectIntegral(self.bounds);


    CGFloat picWidth = 33;
    CGFloat picPadding = 11;

    //self.profilePicView.frame = CGRectIntegral(self.bounds);

    [self.usernameLabel sizeToFit];

    CGFloat profileWidth = picWidth + picPadding + self.usernameLabel.frame.size.width;

    CGRect profilePicFrame = self.bounds;
    profilePicFrame.origin.x = CGRectGetMidX(self.bounds) - (profileWidth/2);
    profilePicFrame.origin.y = CGRectGetMidY(self.bounds) - (picWidth/2);
    profilePicFrame.size.width = picWidth;
    profilePicFrame.size.height = picWidth;
    self.profilePicView.frame = CGRectIntegral(profilePicFrame);

    CGRect usernameRect = self.usernameLabel.frame;
    usernameRect.origin.x = profilePicFrame.origin.x + profilePicFrame.size.width + picPadding;
    usernameRect.origin.y = CGRectGetMidY(self.bounds) - (usernameRect.size.height/2);
    self.usernameLabel.frame = CGRectIntegral(usernameRect);


    //self.settingsLabel.frame = CGRectMake(settingsPadding, 0, self.bounds.size.width / 2 - settingsPadding, self.bounds.size.height - 2);
    self.textGradientLayer.frame = CGRectIntegral(self.bounds);

    //self.gradientLayer.frame = self.bounds;
    self.radialGradientLayer.frame = CGRectIntegral(self.bounds);

    self.addButton.frame = CGRectMake(0, 0, 40, self.bounds.size.height);

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectIntegral(self.profilePicView.bounds) cornerRadius:self.profilePicView.frame.size.width/2];
    [bezierPath setFlatness:0.0];

    //self.profilePicMask.frame = CGRectMake(0, 0, self.profilePicView.frame.size.width, self.profilePicView.frame.size.height);
    self.profilePicMask.path = bezierPath.CGPath;

    //[self.profilePicMask setNeedsDisplay];
}
#endif

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect clippingBounds = CGContextGetClipBoundingBox(context);

    //CGContextSetFillColorWithColor(context, .CGColor);
    //CGContextFillRect(context, clippingBounds);

    CGContextSetAllowsAntialiasing(context, YES);

    CGContextSetFillColorWithColor(context, [GVTintColorUtility utilityTintColor].CGColor);
    
    

    CGSize iconSize = CGSizeMake(25, 25);
    CGSize imageSize = CGSizeMake(iconSize.width, iconSize.height);
    CGFloat imageAlpha = 0.8;
    UIColor *highlightColor = [GVTintColorUtility utilityTintColor];

//
//    FAKIcon *groupIcon = [FAKFontAwesome groupIconWithSize:iconSize.width];
//    UIImage *groupImage =[[groupIcon imageWithSize:imageSize] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [groupImage drawInRect:CGRectIntegral(CGRectMake(0, clippingBounds.size.height/2 - iconSize.height/2, iconSize.width, iconSize.height)) blendMode:kCGBlendModeNormal alpha:iconAlpha];
//
//
//    FAKIcon *retweetIcon = [FAKFontAwesome retweetIconWithSize:iconSize.width];
//    UIImage *retweetImage = [[retweetIcon imageWithSize:imageSize] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [retweetImage drawInRect:CGRectIntegral(CGRectMake(clippingBounds.size.width/2 - retweetImage.size.width/2, clippingBounds.size.height/2 - retweetImage.size.height/2, retweetImage.size.width, retweetImage.size.height)) blendMode:kCGBlendModeNormal alpha:iconAlpha];
//
//
//    FAKIcon *ellipseIcon = [FAKFontAwesome ellipsisHIconWithSize:iconSize.width];
//    UIImage *ellipseImage = [[ellipseIcon imageWithSize:imageSize] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [ellipseImage drawInRect:CGRectIntegral(CGRectMake((((clippingBounds.size.width/3)*2) + (((clippingBounds.size.width/3)/2) - (ellipseImage.size.width/2))), clippingBounds.size.height/2 - ellipseImage.size.height/2, ellipseImage.size.width, ellipseImage.size.height)) blendMode:kCGBlendModeNormal alpha:iconAlpha];

    UIImage *addButton = [[UIImage imageNamed:@"lineicons_video"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.firstItemRect = CGRectIntegral(CGRectMake((self.frame.size.width/3)/2 - addButton.size.width/2, self.frame.size.height/2 - addButton.size.height/2, addButton.size.width, addButton.size.height));
    
    if (CGRectContainsRect(clippingBounds, self.firstItemRect)) {
        
        CGContextSaveGState(context);
        {
            if (self.firstItemHighlight) {
                
                CGContextSetFillColorWithColor(context, highlightColor.CGColor);
                
                
            } else {
            
            
                [addButton drawInRect:self.firstItemRect blendMode:kCGBlendModeNormal alpha:imageAlpha];
            
            }
            
            if (self.firstItemHighlight) {
                UIImage *tButtonFull = [[UIImage imageNamed:@"lineicons_video_full"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                
                CGRect tButtonFullR = CGRectIntegral(CGRectMake((self.frame.size.width/3)/2 - tButtonFull.size.width/2, self.frame.size.height/2 - tButtonFull.size.height/2, tButtonFull.size.width, tButtonFull.size.height));
                
                
                [tButtonFull drawInRect:tButtonFullR blendMode:kCGBlendModeNormal alpha:1.0];
            }
        

        }
        CGContextRestoreGState(context);
    }




    UIImage *tButton = [[UIImage imageNamed:@"lineicons_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    CGSize tButtonSize = tButton.size;//[UIImage aspectSize:CGSizeMake(addButton.size.width, addButton.size.height) image:tButton.CGImage];

    self.secondItemRect = CGRectIntegral(CGRectMake(self.frame.size.width/2 - tButtonSize.width/2, self.frame.size.height/2 - tButtonSize.height/2, tButtonSize.width, tButtonSize.height));
    
    if (CGRectContainsRect(clippingBounds, self.secondItemRect)) {
        CGContextSaveGState(context);
        {
            if (self.secondItemHighlight) {
                
                CGContextSetFillColorWithColor(context, highlightColor.CGColor);
            
            } else {
            
            
                [tButton drawInRect:self.secondItemRect blendMode:kCGBlendModeNormal alpha:imageAlpha];
            
            }
            if (self.secondItemHighlight) {
                
                UIImage *tButtonFull = [[UIImage imageNamed:@"lineicons_chat_full"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                
                CGRect tButtonFullR = CGRectIntegral(CGRectMake(self.frame.size.width/2 - tButtonFull.size.width/2, self.frame.size.height/2 - tButtonFull.size.height/2, tButtonFull.size.width, tButtonFull.size.height));
                

                
                
                
                [tButtonFull drawInRect:tButtonFullR blendMode:kCGBlendModeNormal alpha:1.0];
            }
            

        
        }
        CGContextRestoreGState(context);
    }



    UIImage *mButton = [[UIImage imageNamed:@"lineicons_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.thirdItemRect = CGRectIntegral(CGRectMake(((self.frame.size.width/3)*2) + ((self.frame.size.width/3)/2 - mButton.size.width/2), self.frame.size.height/2 - mButton.size.height/2, mButton.size.width, mButton.size.height));
    
    if (CGRectContainsRect(clippingBounds, self.thirdItemRect)) {
        CGContextSaveGState(context);
        {
            if (self.thirdItemHighlight) {
                
                CGContextSetFillColorWithColor(context, highlightColor.CGColor);
            } else {
            
            
                [mButton drawInRect:self.thirdItemRect blendMode:kCGBlendModeNormal alpha:imageAlpha];
            
            }
            if (self.thirdItemHighlight) {
                UIImage *tButtonFull = [[UIImage imageNamed:@"lineicons_more_full"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                
                CGRect tButtonFullR = CGRectIntegral(CGRectMake(((self.frame.size.width/3)*2) + ((self.frame.size.width/3)/2) - tButtonFull.size.width/2, self.frame.size.height/2 - tButtonFull.size.height/2, tButtonFull.size.width, tButtonFull.size.height));
                
                
                
                
                
                [tButtonFull drawInRect:tButtonFullR blendMode:kCGBlendModeNormal alpha:1.0];
            }
            


    
        }
        CGContextRestoreGState(context);
    }
    //UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil];


}

- (void)handleTouchDown:(NSValue*)pointValue {
    CGPoint point = [pointValue CGPointValue];
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return;
    }
    
    if (point.x < self.bounds.size.width/3) {
        self.firstItemHighlight = YES;
        [self setNeedsDisplayInRect:self.firstItemRect];
    } else if (point.x < (self.bounds.size.width/3)*2) {
        self.secondItemHighlight = YES;
        [self setNeedsDisplayInRect:self.secondItemRect];
    } else {
        self.thirdItemHighlight = YES;
        [self setNeedsDisplayInRect:self.thirdItemRect];
    }
}

- (void)handleTapFail:(NSValue *)viewPoint {
    CGPoint point = [viewPoint CGPointValue];
    
//    if (!CGRectContainsPoint(self.bounds, point)) {
//        return;
//    }
    
    if (self.firstItemHighlight) {
        self.firstItemHighlight = NO;
        [self setNeedsDisplayInRect:self.firstItemRect];
    }
    if (self.secondItemHighlight) {
        self.secondItemHighlight = NO;
        [self setNeedsDisplayInRect:self.secondItemRect];
    }
    if (self.thirdItemHighlight) {
        self.thirdItemHighlight = NO;
        [self setNeedsDisplayInRect:self.thirdItemRect];
    }

}

//- (void)showBackButton {
//    self.addButton.imageView.image = [[UIImage imageNamed:@"glyphicons_224_chevron-left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self;
}

@end
