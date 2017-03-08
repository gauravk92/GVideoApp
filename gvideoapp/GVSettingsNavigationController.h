//
//  GVSettingsNavigationController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/14/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVReuseableViewSnapshot.h"


@interface GVSettingsNavigationController : UINavigationController <GVReuseableViewSnapshot>

@property (nonatomic, strong) UIView *reusabelViewSnapshot;

@end

