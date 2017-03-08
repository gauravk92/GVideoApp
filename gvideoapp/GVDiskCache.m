//
//  GVDiskCache.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/11/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVDiskCache.h"

NSString *const kGVDiskCacheUserProfilePic = @"profilePic";
NSString *const kGVDiskCacheUserBannerPic = @"bannerPic";
NSString *const kGVDiskCacheRealNameKey = @"realName";

NSString *const kGVHTTPProtocolKey = @"http://";
NSString *const kGVTwitterUsernameKey = @"http://twitter_username_";

@interface GVDiskCache ()

@end

@implementation GVDiskCache

+ (GVDiskCache*)diskCache {
    static dispatch_once_t pred;
    static GVDiskCache *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[GVDiskCache alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        NSURL *cachePath = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
                                                                      inDomains:NSUserDomainMask] firstObject];

        NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024*10   // 4MB mem cache
                                                             diskCapacity:1024*1024*40 // 40MB disk cache
                                                                 diskPath:[cachePath absoluteString]];
        [NSURLCache setSharedURLCache:urlCache];
    }
    return self;
}

- (id<NSCoding>)attributesForKey:(NSString*)key {
    NSURL *URL = [[NSURL alloc] initWithString:key];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];

    id<NSCoding> myDictionary;

    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (urlResponse) {
        NSData *data = [urlResponse data];
        myDictionary = (id<NSCoding>)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    return myDictionary;
}

- (void)setAttributes:(id<NSCoding>)dict forKey:(NSString*)key {
    NSURL *URL = [[NSURL alloc] initWithString:key];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];

    NSURLResponse *data = [[NSURLResponse alloc] initWithURL:URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];

    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dict];

    NSCachedURLResponse *response = [[NSCachedURLResponse alloc] initWithResponse:data data:myData userInfo:nil storagePolicy:NSURLCacheStorageAllowed];

    [[NSURLCache sharedURLCache] storeCachedResponse:response forRequest:request];
}

- (id<NSCoding>)cachedObjectForKey:(NSString*)key {
    return [self attributesForKey:[kGVHTTPProtocolKey stringByAppendingString:key]];
}
- (void)cacheObject:(id<NSCoding>)obj forKey:(NSString*)key {
    [self setAttributes:obj forKey:[kGVHTTPProtocolKey stringByAppendingString:key]];
}

- (void)clear {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (BOOL)containsAttributesForUsername:(NSString*)username {
    if (username) {
        NSURL *url = [[NSURL alloc] initWithString:[kGVTwitterUsernameKey stringByAppendingString:username]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        if (cachedResponse) {
            return YES;
        }
    }
    return NO;
}

- (NSDictionary*)cachedAttributesForUsername:(NSString*)username {
    if (username) {
        NSString *requestString = [kGVTwitterUsernameKey stringByAppendingString:username];
        return (NSDictionary*)[self attributesForKey:requestString];
    }
    return nil;
}



//- (NSArray*)cachedActivities {
//    return [self attributesForKey:@"http://root_activities"];
//}
//
//- (NSArray*)cachedThreads {
//    return [self attributesForKey:@"http://root_threads"];
//}
//
//- (void)cacheActivities:(NSArray *)acts {
//    [self setAttributes:acts forKey:@"http://root_activities"];
//}
//
//- (void)cacheThreads:(NSArray *)threads {
//    [self setAttributes:threads forKey:@"http://root_threads"];
//}

- (void)cacheAttributesForUsername:(NSString*)username profilePic:(NSURL*)url bannerPic:(NSURL*)bannerUrl realName:(NSString*)realName {

    NSString *requestString = [kGVTwitterUsernameKey stringByAppendingString:username];

    NSDictionary *dict = @{kGVDiskCacheUserProfilePic: (url ? url : [NSNull null]),
                    kGVDiskCacheUserBannerPic: (bannerUrl ? bannerUrl : [NSNull null]),
                           kGVDiskCacheRealNameKey: (realName ? realName : [NSNull null])};

    [self setAttributes:dict forKey:requestString];

}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    NSCachedURLResponse *memOnlyCachedResponse =
    [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response
                                             data:cachedResponse.data
                                         userInfo:cachedResponse.userInfo
                                    storagePolicy:NSURLCacheStorageNotAllowed];
    DLogObject(cachedResponse);
    return memOnlyCachedResponse;
}

@end
