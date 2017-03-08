//
//  GVCache.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GVCache : NSObject

+ (GVCache*)sharedCache;

- (void)setAttributesForThreads:(NSArray*)threads;
- (void)setAttributesForThread:(PFObject *)thread;
- (void)setAttributesForUser:(PFUser*)user;
- (void)setAttributesForActivity:(PFObject*)activity;
- (void)setAttributesForActivities:(NSArray *)activities;
- (void)setAttributesForImageView:(UIImageView*)imageView url:(NSString*)url;

- (UIImageView*)imageViewForAttributesUrl:(NSString*)url;

- (NSString *)keyForUser:(PFUser *)user;
- (NSString *)keyForActivity:(PFObject *)activity;
- (NSString *)keyForThread:(PFObject *)thread;
- (NSDictionary*)attributesForUser:(PFUser*)user;
- (NSDictionary*)attributesForActivity:(PFObject*)activity;
- (NSDictionary*)attributesForThread:(PFObject*)thread;
- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user;
- (void)setAttributes:(NSDictionary *)attributes forActivity:(PFObject *)activity;
- (void)setAttributes:(NSDictionary *)attributes forThread:(PFObject*)thread;

- (void)clear;

- (UIImage*)imageForSectionIndexPath:(NSIndexPath*)indexPath;
- (void)setAttributesForMasterSectionImage:(UIImage*)image forSectionIndexPath:(NSIndexPath*)indexPath;

@end
