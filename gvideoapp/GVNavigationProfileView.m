//
//  GVNavigationProfileView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/11/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVNavigationProfileView.h"
#import "GVTwitterAuthUtility.h"
#import "GVNavigationProfileContentView.h"

NSString *const GVNavigationProfileViewSettingsTapNotification = @"GVNavigationProfileViewSettingsTapNotification";

@interface GVNavigationProfileView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) GVNavigationProfileContentView *contentView;

@end

@implementation GVNavigationProfileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationProfileTap:)];
        self.tapGestureRecognizer.delegate = self;
        self.tapGestureRecognizer.minimumPressDuration = 0.01;
        [self addGestureRecognizer:self.tapGestureRecognizer];

        self.contentView = [[GVNavigationProfileContentView alloc] initWithFrame:frame];
        [self addSubview:self.contentView];

    }
    return self;
}

//- (void)handleNavigationProfileTap:(UILongPressGestureRecognizer*)gc {
//    if (gc.state == UIGestureRecognizerStateEnded) {
//        // detect a settings tap
//        [[NSNotificationCenter defaultCenter] postNotificationName:GVNavigationProfileViewSettingsTapNotification object:nil];
//    }
//}

- (void)setNeedsLayout {
    [super setNeedsLayout];

    [self.contentView setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat centerWidth = (self.bounds.size.width / 2);
    //CGFloat centerHeight = (self.bounds.size.height / 2);

    CGFloat spacingBetweenImageAndUsername = 10;
    //CGFloat centerPadding = 20;
    CGFloat profilePicHeight = 33;

    self.contentView.profilePicView.layer.cornerRadius = profilePicHeight / 2;

    [self.contentView.usernameLabel sizeToFit];

    self.contentView.profilePicView.frame = CGRectIntegral(CGRectMake(0, self.bounds.size.height/2 - profilePicHeight/2, profilePicHeight, profilePicHeight));

    CGRect usernameRect = self.contentView.usernameLabel.frame;
    usernameRect.origin.x = spacingBetweenImageAndUsername + self.contentView.profilePicView.frame.size.width;
    usernameRect.origin.y = self.bounds.size.height / 2 - usernameRect.size.height / 2;
    self.contentView.usernameLabel.frame = CGRectIntegral(usernameRect);

    CGRect contentRect = self.contentView.frame;
    contentRect.size.width = self.contentView.profilePicView.frame.size.width + spacingBetweenImageAndUsername + self.contentView.usernameLabel.frame.size.width;
    contentRect.origin.x = centerWidth - (contentRect.size.width /2);
    self.contentView.frame = CGRectIntegral(contentRect);

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
