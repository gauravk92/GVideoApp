//
//  GVSettingsView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/17/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSettingsView.h"

@interface GVSettingsView ()


@property (nonatomic, weak) UIViewController *tableViewController;

@end

@implementation GVSettingsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.needsDisplayOnBoundsChange = NO;
        // Initialization code
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.opaque = YES;
        imageView.layer.needsDisplayOnBoundsChange = NO;
        imageView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        imageView.clipsToBounds = YES;
        self.imageView = imageView;
        [self addSubview:imageView];

        self.profilePicView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.profilePicView.contentMode = UIViewContentModeScaleAspectFill;
        self.profilePicView.backgroundColor = [UIColor clearColor];
        self.profilePicView.clipsToBounds = YES;
        self.profilePicView.layer.needsDisplayOnBoundsChange = NO;
        [self addSubview:self.profilePicView];

        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        self.usernameLabel.font = [UIFont boldSystemFontOfSize:16.0];
        self.usernameLabel.textColor = [UIColor whiteColor];
        self.usernameLabel.textAlignment = NSTextAlignmentCenter;
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        self.usernameLabel.shadowColor = [UIColor darkGrayColor];
        self.usernameLabel.shadowOffset = CGSizeMake(0, 1);
        self.usernameLabel.layer.shouldRasterize = YES;
        self.usernameLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.usernameLabel.text = @"";
        self.usernameLabel.layer.needsDisplayOnBoundsChange = NO;
        [self addSubview:self.usernameLabel];

        self.realNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        self.realNameLabel.font = [UIFont boldSystemFontOfSize:24.0];
        self.realNameLabel.textColor = [UIColor whiteColor];
        self.realNameLabel.textAlignment = NSTextAlignmentCenter;
        self.realNameLabel.backgroundColor = [UIColor clearColor];
        self.realNameLabel.shadowColor = [UIColor darkGrayColor];
        self.realNameLabel.shadowOffset = CGSizeMake(0, 1);
        self.realNameLabel.text = @"";
        self.realNameLabel.layer.needsDisplayOnBoundsChange = NO;
        self.realNameLabel.layer.shouldRasterize = YES;
        self.realNameLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self addSubview:self.realNameLabel];
    }
    return self;
}

- (void)setupSettingsTableViewController:(UIViewController *)tableVC {
    if (self.tableViewController) {
        [self.tableViewController.view removeFromSuperview];
        self.tableViewController = nil;
    }

    self.tableViewController = tableVC;
    [self addSubview:self.tableViewController.view];
}

- (void)setupProfilePicLoaded {
    self.profilePicView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profilePicView.layer.borderWidth = 3;
}

- (void)layoutSubviews {
    [super layoutSubviews];


    CGFloat picHeight = 100;

    self.profilePicView.frame = CGRectMake(0, 0, picHeight, picHeight);
    self.profilePicView.layer.cornerRadius = picHeight /2;

    [self.usernameLabel sizeToFit];
    [self.realNameLabel sizeToFit];

    self.tableViewController.view.frame = self.bounds;

    CGFloat widthPadding = 150;

    self.imageView.frame = CGRectMake(-(widthPadding/2), 0, self.bounds.size.width + widthPadding, 280);


    CGFloat yPaddingRealName = 168;
    CGFloat yPaddingUsername = 193;
    CGFloat yPaddingProfilePic = 70;

    CGRect profileRect = self.profilePicView.frame;
    profileRect.origin.x = self.bounds.size.width/2 - profileRect.size.width/2;
    profileRect.origin.y = yPaddingProfilePic;
    self.profilePicView.frame = profileRect;

    CGRect usernameRect = self.usernameLabel.frame;
    usernameRect.origin.x = 0;
    usernameRect.origin.y = yPaddingUsername;
    usernameRect.size.width = self.bounds.size.width;
    self.usernameLabel.frame = usernameRect;

    CGRect realNameRect = self.realNameLabel.frame;
    realNameRect.origin.x = 0;
    realNameRect.origin.y = yPaddingRealName;
    realNameRect.size.width = self.bounds.size.width;
    self.realNameLabel.frame = realNameRect;

    [self bringSubviewToFront:self.profilePicView];
    [self bringSubviewToFront:self.usernameLabel];
    [self bringSubviewToFront:self.realNameLabel];
    [self bringSubviewToFront:self.tableViewController.view];
}



- (void)didMoveToWindow {
    if ([self.settingsDelegateProtocol respondsToSelector:@selector(viewDidMoveToWindow)]) {
        [self.settingsDelegateProtocol performSelector:@selector(viewDidMoveToWindow)];
    }
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
