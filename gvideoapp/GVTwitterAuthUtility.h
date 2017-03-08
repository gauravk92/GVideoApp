//
//  GVTwitterAuthUtility.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/4/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const GVTwitterAuthConsumerKey;
//extern NSString * const GVTwitterAuthConsumerSecret;


@interface GVTwitterAuthUtility : NSObject

@property (nonatomic, copy) NSString *liveTokens;
+ (BOOL)userHasAccessToTwitter;
+ (void)openTwitterToGvideoapp;
+ (void)shouldLoginAccountWithAccount:(ACAccount*)account;
+ (void)shouldGetProfileImageForAnyUser:(NSString*)username block:(void (^)(NSURL *imageURL, NSURL *bannerURL, NSString *realname))requestBlock;
+ (void)shouldGetProfileImageForCurrentUserBlock:(void (^)(NSURL *imageURL, NSURL *bannerURL, NSString *realName))requestBlock;
+ (void)shouldGetProfileDetailsForUsers:(NSString*)usernames completionBlock:(void (^)(NSDictionary *returnedData))completionBlock;
+ (GVTwitterAuthUtility *)sharedInstance;
- (void)getNewReverseAuthTokens;

@end
