//
//  GVCache.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCache.h"
#import "GVParseObjectUtility.h"

@interface GVCache ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation GVCache

#pragma mark - Initialization

+ (GVCache*)sharedCache {
    static dispatch_once_t pred;
    static GVCache *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[GVCache alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PAPCache

- (void)clear {
    [self.cache removeAllObjects];
}

#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forThread:(PFObject*)thread {
    NSString *key = [self keyForThread:thread];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forActivity:(PFObject *)activity {
    NSString *key = [self keyForActivity:activity];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSDictionary*)attributesForThread:(PFObject*)thread {
    NSString *key = [self keyForThread:thread];
    return [self.cache objectForKey:key];
}

- (NSDictionary*)attributesForActivity:(PFObject*)activity {
    NSString *key = [self keyForActivity:activity];
    return [self.cache objectForKey:key];
}

- (NSDictionary*)attributesForUser:(PFUser*)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSString *)keyForThread:(PFObject *)thread {
    return [NSString stringWithFormat:@"thread_%@", [thread objectId]];
}

- (NSString *)keyForActivity:(PFObject *)activity {
    return [NSString stringWithFormat:@"activity_%@", [activity objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

- (void)setAttributesForUser:(PFUser*)user username:(NSString*)username {

    NSDictionary *attributes = @{kGVUserNameKey: username};
    [self setAttributes:attributes forUser:user];
}


- (void)setAttributesForThread:(PFObject *)thread {
    NSArray *users = [thread objectForKey:kGVThreadUsersKey];
    NSMutableArray *usersCache = [NSMutableArray arrayWithCapacity:1];
    for (PFUser *user in users) {
        [usersCache addObject:[user objectId]];
    }

    NSDictionary *attributes = @{kGVParseCreatedAtKey: [thread createdAt],
                                 kGVParseUpdatedAtKey: [thread updatedAt],
                                 kGVThreadUsersKey: usersCache};

    [self setAttributes:attributes forThread:thread];
}

- (void)setAttributesForThreads:(NSArray*)threads {
    for (PFObject *thread in threads) {
        [self setAttributesForThread:thread];
    }
}

- (UIImageView*)imageViewForAttributesUrl:(NSString*)url {
    return [self.cache objectForKey:url];
}

- (void)setAttributesForImageView:(UIImageView*)imageView url:(NSString*)url {
    [self.cache setObject:imageView forKey:url];
}

- (UIImage*)imageForSectionIndexPath:(NSIndexPath*)indexPath {
    if (indexPath) {
        return [self.cache objectForKey:@{@"sectionIndexPath":indexPath}];
    }
    return nil;
}

- (void)setAttributesForMasterSectionImage:(UIImage*)image forSectionIndexPath:(NSIndexPath*)indexPath {
    if (image && indexPath) {
        [self.cache setObject:image forKey:@{@"sectionIndexPath":indexPath}];
    }
}

//- (void)updateAttributesForActivity:(PFObject*)activity  {
//    NSArray *reactions = [activity objectForKey:kGVActivitySendReactionsKey];
//    NSDate *updatedAt = [activity updatedAt];
//    NSMutableDictionary *activityUpdates = [[NSMutableDictionary alloc] initWithDictionary:cachedActivity];
//    if (!reactions) {
//        reactions = [NSNull null];
//    }
//    [activityUpdates setObject:reactions forKey:kGVActivitySendReactionsKey];
//    [activityUpdates setObject:updatedAt forKey:kGVParseUpdatedAtKey];
//}

- (void)setAttributesForActivities:(NSArray *)activities {
    for (PFObject *activity in activities) {
        [self setAttributesForActivity:activity];
    }
}

- (void)setAttributesForActivity:(PFObject *)activity {

    
    
    PFObject *thread = [activity objectForKey:kGVActivityThreadKey];
    id threadData = [NSNull null];
    if (thread) {
        threadData = [thread objectId];
    }

    PFUser *user = [activity objectForKey:kGVActivityUserKey];
    id userData = [NSNull null];
    if (user) {
        userData = [user objectId];
    }

    PFFile *video = [activity objectForKey:kGVActivityVideoKey];
    id videoURL = [NSNull null];
    if (video) {
        videoURL = [video url];
    }

    PFFile *videoThumbnail = [activity objectForKey:kGVActivityVideoThumbnailKey];
    id videoThumbnailURL = [NSNull null];
    if (videoThumbnail) {
        videoThumbnailURL = [videoThumbnail url];
    }

    NSString *activityType = [activity objectForKey:kGVActivityTypeKey];
    id activityTypeData = [NSNull null];
    if (activityType) {
        activityTypeData = activityType;
    }

    NSMutableArray *sendReactionsData = [NSMutableArray arrayWithCapacity:0];
    NSArray *sendReactions = [activity objectForKey:kGVActivitySendReactionsKey];
    for (PFUser *user in sendReactions) {
        NSString *userId = [NSNull null];
        if (user) {
            [sendReactionsData addObject:[user objectId]];
        }
    }
    
    id createdAtDate = [NSNull null];
    NSDate *createAt = [activity createdAt];
    if (createAt) {
        createdAtDate = createAt;
    }
    
    NSDate *updatedAt = [activity updatedAt];
    id updatedDate = [NSNull null];
    if (updatedAt) {
        updatedDate = updatedAt;
    }


    NSDictionary *attributes = @{kGVParseCreatedAtKey: createdAtDate,
                                 kGVParseUpdatedAtKey: updatedDate,
                                 kGVActivityThreadKey: threadData,
                                 kGVActivityUserKey: userData,
                                 kGVActivityTypeKey: activityTypeData,
                                 kGVActivityVideoKey: videoURL,
                                 kGVActivityVideoThumbnailKey: videoThumbnailURL,
                                 kGVActivitySendReactionsKey: sendReactionsData
                                 };
    [self setAttributes:attributes forActivity:activity];
}

- (void)setAttributesForActivity:(PFObject*)activity user:(PFUser*)user video:(NSString*)video thumbPicture:(UIImage*)thumbPic thread:(PFObject*)thread type:(NSString*)type reactions:(NSArray*)reactions original:(PFObject*)originalActivity {

    NSMutableArray *reactionCache = [NSMutableArray arrayWithCapacity:1];
    for (PFObject *reaction in reactions) {
        [reactionCache addObject:[reaction objectId]];
    }

    NSString *originalActivityId = [originalActivity objectId];
    if (!originalActivityId) {
        originalActivityId = [NSNull null];
    }

    NSDictionary *attributes = @{kGVActivityUserKey: [user objectId],
                                 kGVParseCreatedAtKey: [activity createdAt],
                                 kGVParseUpdatedAtKey: [activity updatedAt],
                                 kGVActivityVideoKey: video,
                                 kGVActivityVideoThumbnailKey: thumbPic,
                                 kGVActivityThreadKey: [thread objectId],
                                 kGVActivityTypeKey: type,
                                 kGVActivitySendReactionsKey: reactionCache,
                                 kGVActivityReactionOriginalSendKey: originalActivityId};
    [self setAttributes:attributes forActivity:activity];
}

@end
