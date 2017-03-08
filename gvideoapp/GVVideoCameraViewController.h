//
//  GVVideoCameraViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/31/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVProgressNavigationBar.h"

extern NSString * const GVVideoCameraViewControllerFillProgressBarAnimation;
extern NSString * const GVVideoCameraViewControllerFinishProgressBarAnimation;
extern NSString * const GVVideoCameraViewControllerFlipCameraDeviceAnimation;
extern NSString * const GVVideoCameraViewControllerFinishSavingVideo;
extern NSString * const GVVideoCameraViewControllerSendVideoNotification;

@interface GVVideoCameraViewController : UINavigationController

@property (nonatomic, copy) NSString *threadId;

@end
