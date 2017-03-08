//
//  GVSettingsUtility.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/4/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSettingsUtility.h"

NSString *const GVSettingsSaveNewCapturesKey = @"GVSettingsSaveNewCapturesKey";
NSString *const GVSettingsSelfieModeKey = @"GVSettingsSelfieModeKey";
NSString *const GVSettingsThreadsReceivedKey = @"GVSettingsThreadsReceivedKey";
NSString *const GVSettingsLastUpdatedKey = @"GVSettingsLastUpdatedKey";

@implementation GVSettingsUtility

+ (NSDate*)lastUpdatedDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:GVSettingsLastUpdatedKey];
}

+ (void)setLastUpdatedDate:(NSDate*)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:GVSettingsLastUpdatedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setShouldSaveNewCaptures:(BOOL)save {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:save] forKey:GVSettingsSaveNewCapturesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setSelfieMode:(BOOL)save {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:save] forKey:GVSettingsSelfieModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)selfieMode {
    NSNumber *num = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:GVSettingsSelfieModeKey];
    if (num && [num respondsToSelector:@selector(boolValue)]) {
        return [num boolValue];
    }
    return NO;
}

+ (BOOL)shouldSaveNewCaptures {
    NSNumber *num = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:GVSettingsSaveNewCapturesKey];
    if (num && [num respondsToSelector:@selector(boolValue)]) {
        return  [num boolValue];
    }
    return NO;
}

+ (void)clearThreadsReceived {
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:GVSettingsThreadsReceivedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray*)threadsReceivedWithoutLogin {
    return [[NSUserDefaults standardUserDefaults] objectForKey:GVSettingsThreadsReceivedKey];
}

+ (void)addThreadReceivedWithoutLogin:(NSString *)objectId {
    NSMutableArray *threads = [NSMutableArray arrayWithArray:[self threadsReceivedWithoutLogin]];
    [threads addObject:objectId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:threads] forKey:GVSettingsThreadsReceivedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
