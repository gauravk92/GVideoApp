//
//  GVThreadMediaPickerController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GVThreadMediaPickerControllerProtocol <NSObject>

- (void)willAttemptToSaveVideo;
- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo;

@end

@interface GVThreadMediaPickerController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic, strong) UIPanGestureRecognizer *swipeGestureRecognizer;
@property (nonatomic, assign) CGPoint animateVelocity;

@property (nonatomic, weak) id<GVThreadMediaPickerControllerProtocol> threadMediaPickerDelegate;


@end
