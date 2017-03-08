//
//  GVSettingsView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/17/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GVSettingsViewDelegateProtocol <NSObject>

- (void)viewDidMoveToWindow;

@end

@interface GVSettingsView : UIView

@property (nonatomic, strong) UIImageView *profilePicView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *realNameLabel;

@property (nonatomic, weak) id<GVSettingsViewDelegateProtocol>settingsDelegateProtocol;

- (void)setupSettingsTableViewController:(UIViewController*)tableVC;
- (void)setupProfilePicLoaded;

@end
