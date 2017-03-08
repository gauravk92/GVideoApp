//
//  GVCameraMediaViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/22/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GVCameraMediaPickerControllerProtocol <NSObject>

- (void)willAttemptToSaveVideo;
- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo;

@end

@interface GVCameraMediaViewController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic, weak) id<GVCameraMediaPickerControllerProtocol> cameraMediaPickerDelegate;

@end
