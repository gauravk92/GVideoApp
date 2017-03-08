//
//  GVProgressView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/9/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const GVProgressViewUpdateContentsNotification;

@interface GVProgressView : UIView
- (void)startProgressBarAnimated;
- (void)fillProgressBarAnimated;
- (void)finishProgressBarAnimated;

@end
