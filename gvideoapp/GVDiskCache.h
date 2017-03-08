//
//  GVDiskCache.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/11/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

// user attributes
extern NSString *const kGVDiskCacheUserProfilePic;
extern NSString *const kGVDiskCacheUserBannerPic;
extern NSString *const kGVDiskCacheRealNameKey;

@interface GVDiskCache : NSObject

+ (GVDiskCache*)diskCache;

- (void)clear;

- (id<NSCoding>)cachedObjectForKey:(NSString*)key;
- (void)cacheObject:(id<NSCoding>)obj forKey:(NSString*)key;

//- (NSArray*)cachedThreads;
//- (NSArray*)cachedActivities;
//
//- (void)cacheThreads:(NSArray*)threads;
//- (void)cacheActivities:(NSArray*)array;

// user attributes
- (BOOL)containsAttributesForUsername:(NSString*)username;
- (NSDictionary*)cachedAttributesForUsername:(NSString*)username;
- (void)cacheAttributesForUsername:(NSString*)username profilePic:(NSURL*)url bannerPic:(NSURL*)bannerUrl realName:(NSString*)realName;

@end
