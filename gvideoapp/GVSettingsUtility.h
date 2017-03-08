//
//  GVSettingsUtility.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/4/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const GVSettingsSaveNewCapturesKey;
extern NSString *const GVSettingsSelfieModeKey;

@interface GVSettingsUtility : NSObject

+ (NSDate*)lastUpdatedDate;
+ (void)setLastUpdatedDate:(NSDate*)date;

+ (void)setShouldSaveNewCaptures:(BOOL)save;
+ (BOOL)shouldSaveNewCaptures;

+ (void)setSelfieMode:(BOOL)save;
+ (BOOL)selfieMode;

+ (void)clearThreadsReceived;
+ (NSArray*)threadsReceivedWithoutLogin;
+ (void)addThreadReceivedWithoutLogin:(NSString*)objectId;

@end
