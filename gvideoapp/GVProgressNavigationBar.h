//
//  GVProgressNavigationBar.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/31/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVProgressNavigationBar : UINavigationBar

@property (nonatomic, assign) BOOL layoutWithoutNavigationController;

- (void)startProgressBarAnimated;
- (void)fillProgressBarAnimated;
- (void)finishProgressBarAnimated;

@end
