//
//  GVSettingsTableViewCell.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/27/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVSettingsTableViewCell : UITableViewCell

//@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UISwitch *uiSwitch;
@property (nonatomic, assign) SEL actionSel;
@property (nonatomic, strong) NSDictionary *customTextAttributes;
@property (nonatomic, strong) UIButton *secondButton;
@property (nonatomic, strong) UIButton *thirdButton;
@end
