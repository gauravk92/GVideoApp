//
//  GVMasterModelObject.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/15/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVMasterModelObject.h"
#import "GVParseObjectUtility.h"
#import "GVCache.h"
#import "NSDate+DaysBetween.h"
#import "GVVideoCameraViewController.h"
#import "GVTwitterAuthUtility.h"
#import "GVMasterModelObject.h"
#import "GVDiskCache.h"
#import "GVDelegateImageView.h"
#import "GVSettingsUtility.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/SDImageCache.h>
#import "GVTintColorUtility.h"
#import "UIImage+AspectSize.h"
#import "GVMasterViewController.h"
#import <sys/xattr.h>
#import "GVMasterTableViewCell.h"
#import "GVBlockOperation.h"
#import "UIImage+ResizeAdditions.h"
#import "UIImage+Extensions.h"


const CGFloat imageSize = 65;
const CGFloat imagePadding = 18;
const CGFloat imageYPadding = 62;
const CGFloat textXInset = 3.5;
const CGFloat badgeSize = 14;
const CGFloat badgeXPadding = 5;
const CGFloat scrollWidthXPadding = 100;
const CGFloat imageCircleXPadding = 8;

static NSDateFormatter *distantDateFormatter;
static NSDateFormatter *hourDateFormatter;

static inline CGFLOAT_TYPE cground(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}

#define LOAD_CACHING 1

// sends to app delegate
NSString *GVNewThreadSaveNotification = @"GVNewThreadSaveNotification";
NSString *GVNewThreadDidSaveNotification = @"GVNewThreadDidSaveNotification";
NSString *GVThreadPushAttemptNotification = @"GVThreadPushAttemptNotification";

// sends out
NSString *GVMasterModelObjectLoadingData = @"GVMasterModelObjectLoadingData";
NSString *GVMasterModelObjectLoadingThumbnails = @"GVMasterModelObjectLoadingThumbnails";
NSString *GVMasterModelObjectFinishedLoadingData = @"GVMasterModelObjectFinishedLoadingData";

// receives
NSString *GVRefreshDataNotification = @"GVRefreshDataNotification";
NSString *GVThreadSelectionNotification = @"GVThreadSelectionNotification";
NSString *GVReactionCameraVideoSaveNotification = @"GVReactionCameraVideoSaveNotification";
NSString *GVMasterViewControllerCellSelectNotification = @"GVMasterViewControllerCellSelectNotification";
NSString *GVMovieDidFinishPlayingNotification = @"GVMovieDidFinishPlayingNotification";


@interface GVMasterModelObject ()

@property (nonatomic, strong) NSArray *threads;
@property (nonatomic, strong) NSArray *activities;

@property (nonatomic, strong) NSMutableDictionary *modelThreads;
@property (nonatomic, strong) NSMutableDictionary *modelActivities;

@property (nonatomic, strong) NSMutableDictionary *sortedActivities;
@property (nonatomic, strong) NSMutableDictionary *sortedAssets;

@property (nonatomic, strong) NSMutableDictionary *threadActivities;
@property (nonatomic, strong) NSMutableDictionary *modelReactions;
@property (nonatomic, strong) NSMutableDictionary *sortedReactions;

@property (nonatomic, strong) NSMutableDictionary *uploadingThreads;
@property (nonatomic, strong) NSMutableDictionary *uploadingActivities;
//@property (nonatomic, strong) NSMutableDictionary *uploadingAssets;

@property (nonatomic, strong) NSOperationQueue *deleteOperations;

@property (nonatomic, strong) NSMutableDictionary *deletingThreads;

@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;


@property (nonatomic, strong) NSTimer *lazyCaching;

@property (nonatomic, strong) NSDate *lastUpdateDate;

@property (nonatomic, strong) NSURL *masterCacheDirectory;

@property (nonatomic, strong) UIImage *tapToSendButtonHighlightImage;
@property (nonatomic, strong) CALayer *tapToSendButtonHighlightImageView;

@property (nonatomic, assign) BOOL loadedDataCompletely;

@property (nonatomic, strong) NSMutableDictionary *downloadOperations;

@end

@implementation GVMasterModelObject

- (void)writeVideoToCameraRoll:(NSURL*)outputFileURL {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                    completionBlock:^(NSURL *assetURL, NSError *error) {
                                        if (error) {

                                        }
                                    }];
    }
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(refreshDataNotification:) name:GVRefreshDataNotification object:nil];
        [nc addObserver:self selector:@selector(threadSelectionNotification:) name:GVThreadSelectionNotification object:nil];
        [nc addObserver:self selector:@selector(videoSendNotification:) name:GVVideoCameraViewControllerSendVideoNotification object:nil];
        [nc addObserver:self selector:@selector(reactionCameraVideoSaveNotification:) name:GVReactionCameraVideoSaveNotification object:nil];
        [nc addObserver:self selector:@selector(masterCellSelectNotification:) name:GVMasterViewControllerCellSelectNotification object:nil];
        [nc addObserver:self selector:@selector(masterCellTouchNotification:) name:GVMasterViewControllerCellTouchNotification object:nil];
        [nc addObserver:self selector:@selector(movieDidFinishPlayingNotification:) name:GVMovieDidFinishPlayingNotification object:nil];
        [nc addObserver:self selector:@selector(successfullyInstalledNotification:) name:GVModelHasSuccessfullyInstalledDevice object:nil];
        [nc addObserver:self selector:@selector(masterLongPressNotification:) name:GVMasterTableViewCellLongPressNotification object:nil];
        [nc addObserver:self selector:@selector(masterSaveMovieRequestNotification:) name:GVMasterTableViewCellSaveMovieRequestNotification object:nil];
        [nc addObserver:self selector:@selector(masterEditDataNotification:) name:GVMasterTableViewCellEditDataNotification object:nil];
        //self.lazyCaching = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(lazilyCache:) userInfo:nil repeats:YES];
        self.downloadOperations = [NSMutableDictionary dictionaryWithCapacity:1];
        self.deleteOperations = [NSOperationQueue new];
        self.deleteOperations.maxConcurrentOperationCount = 1;
        
        self.loadedDataCompletely = NO;

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *cachedPath = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
        NSURL *masterCachePath = [cachedPath URLByAppendingPathComponent:@"masterTableView"];
        self.masterCacheDirectory = masterCachePath;
        if (![fileManager fileExistsAtPath:[masterCachePath absoluteString]]) {
            [fileManager createDirectoryAtURL:masterCachePath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    return self;
}

- (void)lazilyCache:(NSTimer*)timer {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"timer fired %@", self.lazyCaching);
        //[self cacheInternalModel];
    });
}

- (void)clearCaches {
    NSArray *keys = nil;
    @try {
        [self.downloadOperations allKeys];
    }
    @catch (NSException *exception) {
        DLogException(exception);
    }
    @finally {
        
    }
    if ([keys respondsToSelector:@selector(count)] && [keys count] > 0) {
        for (NSURL *opKey in keys) {
            NSOperation *op = [self.downloadOperations objectForKey:opKey];
            [op cancel];
        }
        [self.downloadOperations removeAllObjects];
    }
}

- (void)dealloc {
    [self clearCaches];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshDataNotification:(NSNotification*)notif {
    [self performQuery];
}

- (void)threadSelectionNotification:(NSNotification*)notif {
    NSIndexPath *indexPath = [[notif userInfo] objectForKey:@"indexPath"];
    PFObject *thread = [self masterViewControllerThreadAtIndexPath:indexPath];
    // push another push to app delegate...
    NSDictionary *info = @{@"threadId": [thread objectId]};
    //[[NSNotificationCenter defaultCenter] postNotificationName:<#(NSString *)#> object:<#(id)#>]
    [[NSNotificationCenter defaultCenter] postNotificationName:GVThreadPushAttemptNotification object:nil userInfo:info];
}

- (void)scrollMasterTableToSection:(NSUInteger)section {
    UITableView *tableView = [[self masterViewController] tableView];
    CGRect sectionRect = [tableView rectForSection:section];
    [tableView setContentOffset:CGPointMake(0, sectionRect.origin.y) animated:YES];
}

- (void)masterSaveMovieRequestNotification:(NSNotification*)notif {
    NSDictionary *userInfo = [notif userInfo];
    
    DLogObject(userInfo);
    
    NSString *activityId = userInfo[@"activityId"];
    
    PFObject *activity = nil;
    for (PFObject *act in self.activities) {
        if ([[act objectId] isEqualToString:activityId]) {
            activity = act;
            continue;
        }
    }
    
    NSString *url = [self urlForActivity:activity];
    @weakify(self);
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    [op addExecutionBlock:^{
        @strongify(self);
        if (url && [url respondsToSelector:@selector(length)] && [url length] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GVSaveMovieNotification object:nil userInfo:@{@"contentURL":url}];
        }
    }];
    NSDictionary *info = @{@"op": op};
    [[NSNotificationCenter defaultCenter] postNotificationName:GVInternetRequestNotification object:nil userInfo:info];
    
}

- (void)masterEditDataNotification:(NSNotification*)notif {
    NSDictionary *userInfo = [notif userInfo];
    NSString *editDataKey = userInfo[@"editDataKey"];
    if ([editDataKey isEqualToString:@"imageRotate"]) {
        NSNumber *rotateKey = userInfo[@"rotateKey"];
        
        NSString *activityId = userInfo[@"activityId"];
        
        PFObject *activity = nil;
        for (PFObject *act in self.activities) {
            if ([[act objectId] isEqualToString:activityId]) {
                activity = act;
                continue;
            }
        }
        
        if (activity) {
            NSData *data = [[activity objectForKey:kGVActivityVideoThumbnailKey] getData];
            UIImage *image = [UIImage imageWithData:data];
            
            if (image) {
                // got the image, how much to rotate
                NSInteger rotateInt = [rotateKey integerValue];
                UIImage *newImage = nil;
                switch (rotateInt) {
                    case 1: {
                        // rotate 90
                        newImage = [image imageRotatedByDegrees:90];
                        
                        
                        
                        
                        break;
                    }
                    case 2: {
                        // rotate 180
                        newImage = [image imageRotatedByDegrees:180];
                        break;
                    }
                    case 3: {
                        // rotate 270;
                        newImage = [image imageRotatedByDegrees:270];
                        break;
                    }
                    default:
                        break;
                }
                
                if (newImage) {
                    NSData *resizedImageData = UIImageJPEGRepresentation(newImage, 1.0);
                    //NSData *imageData = UIImagePNGRepresentation(thumbnailImage);
                    PFFile *videoThumbnail = [PFFile fileWithName:@"videoThumb.jpg" data:resizedImageData];
                    
                    [activity setObject:videoThumbnail forKey:kGVActivityVideoThumbnailKey];
                    
                    [activity save];
                }
            }
        }
        
    } else if ([editDataKey isEqualToString:@"imageURLClipboard"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadSaveNotification object:nil];
        
        UIImage *image = [[UIPasteboard generalPasteboard] image];
        
        if (image) {
            NSString *activityId = userInfo[@"activityId"];
            
            PFObject *activity = nil;
            for (PFObject *act in self.activities) {
                if ([[act objectId] isEqualToString:activityId]) {
                    activity = act;
                    continue;
                }
            }
            
            if (activity) {
                
                UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1000.0f, 1000.0f) interpolationQuality:kCGInterpolationHigh];
                
                NSData *resizedImageData = UIImageJPEGRepresentation(resizedImage, 1.0);
                //NSData *imageData = UIImagePNGRepresentation(thumbnailImage);
                PFFile *videoThumbnail = [PFFile fileWithName:@"videoThumb.jpg" data:resizedImageData];
                
                [activity setObject:videoThumbnail forKey:kGVActivityVideoThumbnailKey];
                
                [activity save];
                
                
                
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadDidSaveNotification object:nil];
    } else if ([editDataKey isEqualToString:@"imageURL"]) {
        // let's grab the image if it exists...
        NSString *contentURL = userInfo[@"textFieldText"];
        if (contentURL && [contentURL respondsToSelector:@selector(length)] && [contentURL length] > 0) {
            [[UIPasteboard generalPasteboard] setString:contentURL];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadSaveNotification object:nil];
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:contentURL]]];
            
            if (image) {
                NSString *activityId = userInfo[@"activityId"];
                
                PFObject *activity = nil;
                for (PFObject *act in self.activities) {
                    if ([[act objectId] isEqualToString:activityId]) {
                        activity = act;
                        continue;
                    }
                }
                
                if (activity) {
                
                    UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1000.0f, 1000.0f) interpolationQuality:kCGInterpolationHigh];
                    
                    NSData *resizedImageData = UIImageJPEGRepresentation(resizedImage, 1.0);
                    //NSData *imageData = UIImagePNGRepresentation(thumbnailImage);
                    PFFile *videoThumbnail = [PFFile fileWithName:@"videoThumb.jpg" data:resizedImageData];
                    
                    [activity setObject:videoThumbnail forKey:kGVActivityVideoThumbnailKey];
                    
                    [activity save];
                    
                    
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadDidSaveNotification object:nil];
        }
    } else if ([editDataKey isEqualToString:@"displayName"]) {
        NSString *activityId = userInfo[@"activityId"];
        
        PFObject *activity = nil;
        for (PFObject *act in self.activities) {
            if ([[act objectId] isEqualToString:activityId]) {
                activity = act;
                continue;
            }
        }
        NSString *titleText = userInfo[@"textFieldText"];
        if (activity && titleText && [titleText respondsToSelector:@selector(length)] && [titleText length] > 0) {
            [activity setObject:titleText forKey:kGVActivityForcedDisplayName];
            [activity save];
        }
    } else if ([editDataKey isEqualToString:@"markUnrecord"]) {
        NSString *activityId = userInfo[@"activityId"];
        
        PFObject *activity = nil;
        for (PFObject *act in self.activities) {
            if ([[act objectId] isEqualToString:activityId]) {
                activity = act;
                continue;
            }
        }
        NSNumber *titleText = userInfo[@"recordStateKey"];
        if (activity && titleText) {
            [activity setObject:titleText forKey:kGVActivityForcedUnrecordState];
            [activity save];
        }
    } else if ([editDataKey isEqualToString:@"markUnread"]) {
        NSString *activityId = userInfo[@"activityId"];
        
        PFObject *activity = nil;
        for (PFObject *act in self.activities) {
            if ([[act objectId] isEqualToString:activityId]) {
                activity = act;
                continue;
            }
        }
        NSNumber *titleText = userInfo[@"unreadStateKey"];
        if (activity && titleText) {
            [activity setObject:titleText forKey:kGVActivityForcedUnreadState];
            [activity save];
        }
    } else if ([editDataKey isEqualToString:@"threadTitle"]) {
        NSString *threadId = userInfo[@"threadId"];
        NSString *titleText = userInfo[@"textFieldText"];
        
        if (threadId && [threadId respondsToSelector:@selector(length)] && [threadId length] > 0 && titleText && [titleText respondsToSelector:@selector(length)] && [titleText length] > 0) {
            
            PFObject *thread = nil;
            for (PFObject *t in self.threads) {
                if ([[t objectId] isEqualToString:threadId]) {
                    thread = t;
                    continue;
                }
            }
            
            if (thread) {
                [thread setObject:titleText forKey:kGVThreadForcedTitleKey];
                [thread save];
                
            }
            
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GVClearCacheNotification object:nil];
}

- (void)masterCellTouchNotification:(NSNotification*)notif {
    NSDictionary *userInfo = [notif userInfo];
    
    NSValue *pointValue = userInfo[@"scrollViewPoint"];
    if (pointValue) {
        CGPoint scrollTapPoint = [pointValue CGPointValue];
        
        CGRect tapToSendRect = CGRectMake(imageCircleXPadding, imageYPadding, imageSize, imageSize*2); // @hack *2
        
        if (CGRectContainsPoint(tapToSendRect, scrollTapPoint)) {
            // successfully detected a tap, let's try to place the uiimage right there...
            
            UIScrollView *scrollView = userInfo[@"scrollView"];
            id selfObject = userInfo[@"self"];
            if (selfObject && [selfObject respondsToSelector:@selector(setHighlightLayer:)]) {
                [selfObject performSelector:@selector(setHighlightLayer:) withObject:self.tapToSendButtonHighlightImageView];
            }
    //        if (!scrollView) {
    //            return;
    //        }
            
            CGRect tapRect = CGRectMake(imageCircleXPadding-0.5, GVMasterTableViewCellRowHeight - imageYPadding - imageSize-0.53, imageSize+1, imageSize+1);
            
            // boom got the damn scrollview too
            
            //if (self.tapToSendButtonHighlightImageView.superview != scrollView) {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                if (self.tapToSendButtonHighlightImageView.superlayer) {
                    [self.tapToSendButtonHighlightImageView removeFromSuperlayer];
                }
                if (self.tapToSendButtonHighlightImageView) {
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:0.05];
                    self.tapToSendButtonHighlightImageView.opacity = 0.95;
                    
                    self.tapToSendButtonHighlightImageView.frame = CGRectIntegral(tapRect);
                    [scrollView.layer addSublayer:self.tapToSendButtonHighlightImageView];
                    [CATransaction commit];
                }
                //[scrollView bringSubviewToFront:self.tapToSendButtonHighlightImageView];
            //}
            });

            
            
            
            
        }
        
    }
}


- (void)movieDidFinishPlayingNotification:(NSNotification*)notif {
    PFObject *activity = nil;
    NSString *activityId = [notif userInfo][@"activityId"];
    for (PFObject *act in self.activities) {
        if ([[act objectId] isEqualToString:activityId]) {
            activity = act;
        }
    }
    BOOL showingUnread = [self threadShouldShowUnreadWithActivity:activity];
    if (showingUnread) {
        // here we can send out a notification to mark and save the activity as read
        @autoreleasepool {
            @weakify(self);
            NSBlockOperation *op = [[NSBlockOperation alloc] init];
            [op addExecutionBlock:^{
                @strongify(self);
                [self modelDidFinishPlayingVideo:activity];
            }];
            NSDictionary *info = @{@"op": op, @"noError": [NSNumber numberWithBool:YES]};
            [[NSNotificationCenter defaultCenter] postNotificationName:GVInternetRequestNotification object:nil userInfo:info];
        }
    }
}

//
//- (void)masterHandleScrollCellTapToSendNotification:(NSDictionary*)info block:(NSBlockOperation*)block {
//    
//}

- (void)masterLongPressNotification:(NSNotification*)notif {
    NSDictionary *userInfo = [notif userInfo];
    
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [TestFlight passCheckpoint:@"Select Item Action"];
        @strongify(self);
        
        
        
        CGPoint scrollTapPoint = [userInfo[@"scrollViewPoint"] CGPointValue];
        NSIndexPath *indexPath = userInfo[@"sectionIndexPath"];
        
        
        NSDictionary *activityData = [self masterViewControllerDataAtIndexPath:indexPath];
        
        NSDictionary *activities = activityData[@"sorted_data"];
        
        CGRect tapToSendRect = CGRectMake(0, imageYPadding, imageSize, imageSize*2); // @hack *2
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
        if ([notif userInfo]) {
            [dict addEntriesFromDictionary:[notif userInfo]];
        }
        
        if (CGRectContainsPoint(tapToSendRect, scrollTapPoint)) {
            // tap to send
            
            PFObject *thread = [self masterViewControllerThreadAtIndexPath:indexPath];
            if (thread) {
                //DAssertNonNil([thread objectId]);
                //                if ([thread objectId]) {
                //                    NSDictionary *info = @{@"threadId": [thread objectId]};
                //                }
                
                
                //NSArray *headerInfo = [self masterSendingHeaderInfo:indexPath];
                
                //DAssertNonNil(headerInfo);
                
                //åDAssertNonNil([thread objectId]);
                
                //[dict setObject:headerInfo forKey:@"headerInfo"];
                if (thread && [thread respondsToSelector:@selector(objectId)]) {
                    [dict setObject:[thread objectId] forKey:@"threadId"];
                }
                id obj = [self masterViewControllerDataAtIndexPath:indexPath];
                if (obj) {
                    [dict setObject:obj forKey:@"indexPath"];
                }
                DLogObject(dict);
                // this is a tap on the tap to send...should bring up thread edit menu
                [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellLongPressReceiveNotification object:nil userInfo:dict];
                //[[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerPullUpNotification object:nil userInfo:dict];
//                //@weakify(self);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    @strongify(self);
//                    [self scrollMasterTableToSection:indexPath.section];
//                    //[[[self masterViewController] tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//                });
                
            }
            return;
        }
        
        for (NSUInteger i = 0;i<[activities count];i++) {
            NSDictionary *data = [activities objectForKey:[NSIndexPath indexPathForRow:i inSection:0]];
            CGPoint imagePoint = [data[@"point"] CGPointValue];
            CGRect imageRect = CGRectMake(imagePoint.x, imageYPadding, imageSize, imageSize*2); // @hack *2
            
            if (CGRectContainsPoint(imageRect, scrollTapPoint)) {
                // found it
                DLogObject(data);
                NSString *activityId = data[@"activityId"];
                NSString *key = data[@"key"];
                if ([key isEqualToString:@"loadMore"]) {
                    NSLog(@"so amazing");
                    // do nothing on tap to hold for load more
                    //[self performLoadMore:activityData[@"threadId"]];
                } else {
                    PFObject *activity = nil;
                    for (PFObject *act in self.activities) {
                        if ([[act objectId] isEqualToString:activityId]) {
                            activity = act;
                            continue;
                        }
                    }
                    
                    if (activity) {
                        PFObject *thread = [activity objectForKey:kGVActivityThreadKey];
                        NSString *threadId = nil;
                        if (thread) {
                            threadId = [thread objectId];
                        }
                        
                        NSArray *results = [self threadShouldRecordReactionWithActivity:activity];
                        BOOL shouldRecord = [[results objectAtIndex:0] boolValue];
                        NSString *url = [results objectAtIndex:1];
                        if (threadId && activityId && url && !shouldRecord) {
                            [dict setObject:[NSValue valueWithCGRect:imageRect] forKey:@"imageRect"];
                            CGRect targetRect = CGRectMake(imagePoint.x, imageYPadding, imageSize, imageSize);
                            [dict setObject:[NSValue valueWithCGRect:targetRect] forKey:@"targetRect"];
                            [dict setObject:threadId forKey:@"threadId"];
                            [dict setObject:activityId forKey:@"activityId"];
                            // @TODO check reachability
                            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellLongPressActivityReceiveNotification object:nil userInfo:dict];
                            //[self startRecordingReaction:url indexPath:indexPath];
                            // should bring up menu to download video instead and send coordinates for menu
                        }
//                            NSDictionary *dict = @{@"URL": url, @"threadId": threadId, @"activityId": activityId, @"shouldRecord": [NSNumber numberWithBool:YES]};
//                            [[NSNotificationCenter defaultCenter] postNotificationName:GVReactionVideoNotification object:nil userInfo:dict];
//                        } else {
//                            // just play the damn video
//                            if (threadId && activityId && url) {
//                                NSDictionary *dict = @{@"URL": url, @"threadId": threadId, @"activityId": activityId, @"shouldRecord": [NSNumber numberWithBool:NO]};
//                                [[NSNotificationCenter defaultCenter] postNotificationName:GVReactionVideoNotification object:nil userInfo:dict];
//                                //[[NSNotificationCenter defaultCenter] postNotificationName:GVPlayMovieNotification object:nil userInfo:dict];
//                            }
//                        }
                    }
                    //                PFFile *video = [activity objectForKey:kGVActivityVideoKey];
                    //                if (video && ![video isKindOfClass:[NSNull class]]) {
                    //                    NSString *videoURL = [video url];
                    //                    if (videoURL && [videoURL length] > 0) {
                    //                        [[NSNotificationCenter defaultCenter] postNotificationName:GVPlayMovieNotification object:nil userInfo:@{@"URL": videoURL}];
                    //                    }
                    //                }
                }
            }
        }
        
        
        //        NSArray *data = [self threadViewControllerDataAtIndexPath:indexPath thread:threadId];
        //        PFObject *activity;
        //        if ([data count] > 0) {
        //            activity = data[0];
        //        }
        
        //        PFObject *activity;
        //        for (PFObject *act in self.activities) {
        //            if ([[act objectId] isEqualToString:activityId]) {
        //                activity = act;
        //            }
        //        }
        
        
    });

    
}

- (void)masterCellSelectNotification:(NSNotification*)notif {
    NSDictionary *userInfo = [notif userInfo];
    //NSIndexPath *indexPath = [userInfo objectForKey:@"indexPath"];
    //NSIndexPath *sectionIndexPath = [userInfo objectForKey:@"sectionIndexPath"];
    //NSString *activityId = [userInfo objectForKey:@"activityId"];
    //NSString *threadId = [userInfo objectForKey:@"threadId"];
    //PFObject *thread = [self masterViewControllerThreadAtIndexPath:sectionIndexPath];
    // push another push to app delegate...
    //NSDictionary *info = @{@"threadId": [thread objectId]};
    //NSString *threadId = [thread objectId];
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [TestFlight passCheckpoint:@"Select Item Action"];
        @strongify(self);



        CGPoint scrollTapPoint = [userInfo[@"scrollViewPoint"] CGPointValue];
        NSIndexPath *indexPath = userInfo[@"sectionIndexPath"];


        NSDictionary *activityData = [self masterViewControllerDataAtIndexPath:indexPath];

        NSDictionary *activities = activityData[@"sorted_data"];

        CGRect tapToSendRect = CGRectMake(0, imageYPadding, imageSize, imageSize*2); // @hack *2

        if (CGRectContainsPoint(tapToSendRect, scrollTapPoint)) {
            // tap to send

            PFObject *thread = [self masterViewControllerThreadAtIndexPath:indexPath];
            if (thread) {
                //DAssertNonNil([thread objectId]);
//                if ([thread objectId]) {
//                    NSDictionary *info = @{@"threadId": [thread objectId]};
//                }
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
                if ([notif userInfo]) {
                    [dict addEntriesFromDictionary:[notif userInfo]];
                }
            
                //NSArray *headerInfo = [self masterSendingHeaderInfo:indexPath];
                
                //DAssertNonNil(headerInfo);
                
                //åDAssertNonNil([thread objectId]);
                
                //[dict setObject:headerInfo forKey:@"headerInfo"];
                if (thread && [thread respondsToSelector:@selector(objectId)]) {
                    [dict setObject:[thread objectId] forKey:@"threadId"];
                }
                id obj = [self masterViewControllerDataAtIndexPath:indexPath];
                if (obj) {
                    [dict setObject:obj forKey:@"indexPath"];
                }
                DLogObject(dict);
                [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerPullUpNotification object:nil userInfo:dict];
                //@weakify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self scrollMasterTableToSection:indexPath.section];
                    //[[[self masterViewController] tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                });

            }
            return;
        }

        for (NSUInteger i = 0;i<[activities count];i++) {
            NSDictionary *data = [activities objectForKey:[NSIndexPath indexPathForRow:i inSection:0]];
            CGPoint imagePoint = [data[@"point"] CGPointValue];
            CGRect imageRect = CGRectMake(imagePoint.x, imageYPadding, imageSize, imageSize*2); // @hack *2

            if (CGRectContainsPoint(imageRect, scrollTapPoint)) {
                // found it
                DLogObject(data);
                NSString *activityId = data[@"activityId"];
                NSString *key = data[@"key"];
                if ([key isEqualToString:@"loadMore"]) {
                    NSLog(@"so amazing");
                    [self performLoadMore:activityData[@"threadId"]];
                } else {
                    PFObject *activity = nil;
                    for (PFObject *act in self.activities) {
                        if ([[act objectId] isEqualToString:activityId]) {
                            activity = act;
                            continue;
                        }
                    }

                    if (activity) {
                        PFObject *thread = [activity objectForKey:kGVActivityThreadKey];
                        NSString *threadId = nil;
                        if (thread) {
                            threadId = [thread objectId];
                        }

                        NSArray *results = [self threadShouldRecordReactionWithActivity:activity];
                        BOOL shouldRecord = [[results objectAtIndex:0] boolValue];
                        NSString *url = [results objectAtIndex:1];
                        if (shouldRecord && threadId && activityId && url) {
                            // @TODO check reachability
                            //[self startRecordingReaction:url indexPath:indexPath];
                            NSDictionary *dict = @{@"URL": url, @"threadId": threadId, @"activityId": activityId, @"shouldRecord": [NSNumber numberWithBool:YES]};
                            [[NSNotificationCenter defaultCenter] postNotificationName:GVReactionVideoNotification object:nil userInfo:dict];
                        } else {
                            // just play the damn video
                            if (threadId && activityId && url) {
                                NSDictionary *dict = @{@"URL": url, @"threadId": threadId, @"activityId": activityId, @"shouldRecord": [NSNumber numberWithBool:NO]};
                                [[NSNotificationCenter defaultCenter] postNotificationName:GVReactionVideoNotification object:nil userInfo:dict];
                                //[[NSNotificationCenter defaultCenter] postNotificationName:GVPlayMovieNotification object:nil userInfo:dict];
                            }
                        }
                    }
    //                PFFile *video = [activity objectForKey:kGVActivityVideoKey];
    //                if (video && ![video isKindOfClass:[NSNull class]]) {
    //                    NSString *videoURL = [video url];
    //                    if (videoURL && [videoURL length] > 0) {
    //                        [[NSNotificationCenter defaultCenter] postNotificationName:GVPlayMovieNotification object:nil userInfo:@{@"URL": videoURL}];
    //                    }
    //                }
                }
            }
        }


//        NSArray *data = [self threadViewControllerDataAtIndexPath:indexPath thread:threadId];
//        PFObject *activity;
//        if ([data count] > 0) {
//            activity = data[0];
//        }

//        PFObject *activity;
//        for (PFObject *act in self.activities) {
//            if ([[act objectId] isEqualToString:activityId]) {
//                activity = act;
//            }
//        }


    });
}

- (void)notifyMasterViewController {
    //@weakify(self);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    @strongify(self);
        if ([self.masterViewController respondsToSelector:@selector(objectsDidLoad:)]) {
            [self.masterViewController performSelector:@selector(objectsDidLoad:) withObject:nil];
        }
    //});

}

- (void)notifyThreadViewController {
    if ([self.threadViewController respondsToSelector:@selector(refreshData:)]) {
        if (self.threadViewController.threadId) {
            [self threadViewControllerDataAtIndexPath:nil thread:self.threadViewController.threadId];
            [self.threadViewController performSelector:@selector(refreshData:) withObject:nil];
        }
    }
}

- (void)notifyControllersToLoadCompleteData {
    
    self.loadedDataCompletely = YES;
    
    //if ([self.threads count] > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterModelObjectFinishedLoadingData object:nil];
    //}
    
    [self notifyMasterViewController];
    
    //[self notifyThreadViewController];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        for (NSUInteger i = 0;i<[self masterViewControllerRowCount];i++) {
            @autoreleasepool {
                [self masterViewControllerDataAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
            }
        }
    });
}

- (void)loadControllersData:(NSArray*)twitterLoadPics {
    NSMutableArray *loadingTracker = [NSMutableArray arrayWithCapacity:1];
    
    // here we need to async load all the images tracking till they're done, store in the uiimageview
    // store it absolutestring as the key
    @weakify(self);
    for (NSUInteger i = 0;i<[twitterLoadPics count];i++) {
        NSURL *stringkey = [twitterLoadPics objectAtIndex:i];
        [[SDWebImageManager sharedManager] downloadImageWithURL:stringkey options:SDWebImageRetryFailed
                                                  progress:nil
                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                     //if (finished) {
                                                         
                                                         //NSBlockOperation *blockOperation = [NSBlockOperation new];
                                                         //[blockOperation addExecutionBlock:^{
                                                         [loadingTracker addObject:[NSNull null]];
                                                         
                                                         if ([loadingTracker count] == [twitterLoadPics count]) {
                                                             // all the images are loaded
                                                             @strongify(self);
                                                             [self notifyControllersToLoadCompleteData];
                                                         }
                                                         //}];
                                                         //[blockOperationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
                                                     //} else {
                                                     //    DLog(@"error loading thumbnail %@", error);
                                                     //}
                                                 }];
    }
}

#define DELAY_LOADING_TILL_THUMBNAILS 0

- (void)notifyControllersToLoadData {

#if DELAY_LOADING_TILL_THUMBNAILS
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        
        
        
        UITableView *tableView = [[self masterViewController] tableView];
        
        //if (!([[tableView visibleCells] count] > 0)) {
            // nothing is loaded, show the activity indicator
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterModelObjectLoadingThumbnails object:nil];
        //}
        
        // this should just check through everything and load all data into cache before even continuing...
        // twitter api's are gonna get hit a lot...
        NSMutableArray *twitterLoad = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *twitterLoadPics = [NSMutableArray arrayWithCapacity:1];
        for (NSUInteger i = 0;i<[self.threads count];i++) {
            PFObject *thread = [self.threads objectAtIndex:i];
            //NSArray *userObjects
            NSArray *threadUsers = [thread objectForKey:kGVThreadUsersKey];
            for (NSUInteger x = 0;x<[threadUsers count];x++) {
                PFUser *threadUser = [threadUsers objectAtIndex:x];
                if (!threadUser || [threadUser isKindOfClass:[NSNull class]]) {
                    continue;
                }
                NSDictionary *userObjects = [[GVDiskCache diskCache] cachedAttributesForUsername:[threadUser username]];
                BOOL userExists = (userObjects && ![userObjects isKindOfClass:[NSNull class]]);
                if (userExists) {
                    NSURL* profilePic = [userObjects objectForKey:kGVDiskCacheUserProfilePic];
                    BOOL containsPic = [[SDImageCache sharedImageCache] diskImageExistsWithKey:[profilePic absoluteString]];
                    if (profilePic && !containsPic) {
                        if (![twitterLoadPics containsObject:profilePic]) {
                            [twitterLoadPics addObject:profilePic];
                        }
                    }
                } else {
                    NSString *username = [threadUser username];
                    if (username && ![twitterLoad containsObject:username]) {
                        [twitterLoad addObject:username];
                    }
                }
            }
        }


        if ([twitterLoad count] > 0 || [twitterLoadPics count] > 0) {

            //NSOperationQueue *blockOperationQueue = [NSOperationQueue new];
            //blockOperationQueue.maxConcurrentOperationCount = 1;
            /**
             *   We're gonna have to async load the data, and then return to notifying table view
             *   all is loaded...
             */
            self.loadedDataCompletely = NO;
            if ([twitterLoad count] > 0) {
                NSString *usernameRequestString = [self requestConcatenateStringObjects:twitterLoad];
                // here we'll submit a lookup for all the users at once...
                
                [GVTwitterAuthUtility shouldGetProfileDetailsForUsers:usernameRequestString completionBlock:^(NSDictionary *data) {
                    @weakify(self);
                    
                    for (NSString *usernameKey in twitterLoad) {
                        if (!usernameKey || [usernameKey isKindOfClass:[NSNull class]]) {
                            continue;
                        }
                        NSDictionary *userObjects = [[GVDiskCache diskCache] cachedAttributesForUsername:usernameKey];
                        NSURL *profilePic = [userObjects objectForKey:kGVDiskCacheUserProfilePic];
                        BOOL containsPic = [[SDImageCache sharedImageCache] diskImageExistsWithKey:[profilePic absoluteString]];
                        if (profilePic && !containsPic) {
                            if (![twitterLoadPics containsObject:profilePic]) {
                                [twitterLoadPics addObject:profilePic];
                            }
                        }
                        
                    }
                    
                    [self loadControllersData:twitterLoadPics];
                }];
                 
               //  ^(NSDictionary *data) {
               //     // now we have to get all the images and wait till they're done
               //     //[loadImageOperation start];
               // }];
            } else {
                [self loadControllersData:twitterLoadPics];
                //[loadImageOperation start];
            }
            
        } else {
            //self.loadedDataCompletely = YES;
            //if (self.loadedDataCompletely) {
                [self notifyControllersToLoadCompleteData];
            //}
        }
    });
#else 
    
    [self notifyControllersToLoadCompleteData];
    
#endif
}

- (void)performLoadMore:(NSString*)threadId {
    // this should go through an internet request block
    PFObject *threadObject = nil;
    for (PFObject *aThread in self.threads) {
        if ([[aThread objectId] isEqualToString:threadId]) {
            threadObject = aThread;
            continue;
        }
    }
    
    PFQuery *query = [GVParseObjectUtility queryForActivitiesOfThread:threadObject];
    
    query.limit = 1000;
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    query.maxCacheAge = 60 * 60 * 24 * 7;
    // let's try to load a fuck ton at once, don't want too many requests... fuck it for images
    //query.cachePolicy;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // wtf to do with this shit
        
        // coallesce into activities, mark cell as dirty and updateRow
        NSMutableArray *activities = [NSMutableArray arrayWithArray:self.activities];
        NSMutableArray *diffActs = [NSMutableArray arrayWithCapacity:1];
        for (PFObject *newActivity in objects) {
            NSString *newActivityId = [newActivity objectId];
            
            BOOL toInsertNewActivity = YES;
            for (PFObject *activity in activities) {
                if ([[activity objectId] isEqualToString:newActivityId]) {
                    toInsertNewActivity = NO;
                }
            }
            
            if (toInsertNewActivity) {
                [diffActs addObject:newActivity];
            }
        }
        
        [activities addObjectsFromArray:diffActs];
        self.activities = [NSArray arrayWithArray:activities];
        
        NSIndexPath *threadIndexPath = [NSIndexPath indexPathForRow:0 inSection:[self.threads indexOfObject:threadObject]];
        
        [self masterViewControllerMarkCellAsDirtyAtIndexPath:threadIndexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self masterViewController] updateRowAtIndexPath:threadIndexPath];
        });
    }];
}

- (void)performQueryReceived {
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if (![PFUser currentUser]) {
                return;
            }

            //DLogMainThread();

            if (self.isLoading || self.isSaving) {
                // set a fail safe timer now
                
                // tell it to activate in 10 seconds, the first download of thumbnails could take longer though, maybe we should activate it then, fuckkking complexity
                
                // ok
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    //if ([self.masterViewController respondsToSelector:@selector(refreshControl)]) {
//                    //    UIRefreshControl *rc = [self.masterViewController performSelector:@selector(refreshControl)];
//                    //    [rc performSelector:@selector(endRefreshing)];
//                    //}
//                    
//                });
                return;
            }

            self.loading = YES;
            
            //self.loadedDataCompletely = NO;

            UITableView *tableView = [self.masterViewController tableView];

            if (!([self.threads count] > 0 && [[tableView visibleCells] count] > 0)) {
                // nothing is loaded, show the activity indicator
                [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterModelObjectLoadingData object:nil];
            }

            PFQuery *model = [GVParseObjectUtility netQueryForUserUpdate:[PFUser currentUser]];

            model.limit = 1000;
            model.cachePolicy = kPFCachePolicyCacheThenNetwork;
            model.maxCacheAge = 60 * 60 * 24 * 7;


            NSDate *lastUpdated = [GVSettingsUtility lastUpdatedDate];
            NSDate *currentDate = [NSDate date];
            if (lastUpdated && [self.threads count] > 0 && [[tableView visibleCells] count] > 0) {
                [model whereKey:kGVParseUpdatedAtKey greaterThan:lastUpdated];
            }

            [model findObjectsInBackgroundWithBlock:^(NSArray *latestActivities, NSError *error) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    self.loading = YES;
                    
                    
                    if (!self.tapToSendButtonHighlightImage) {
                        [self generateTapToSendButtonHighlightImage];
                    }
                    
                    if (!([[tableView visibleCells] count] > 0)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterModelObjectLoadingData object:nil];
                    }
                    
                    
                    NSMutableArray *updatingTableCells = [NSMutableArray arrayWithCapacity:0];

                    NSArray *filteredLatestActivities = latestActivities;

                    // always remember this will get run twice
                    // always getting just the latest activities, this needs to load this data coming in

                    //PFQuery *activities = [GVParseObjectUtility queryForActivitiesOfThread:<#(PFObject *)#>]
                    //PFQuery *netQuery = [GVParseObjectUtility queryForThreadsOfUser:[PFUser currentUser]];

                        //self.lastUpdateDate = [NSDate date];

                    // here we want to remove the activities that are more than 25, they won't be loaded most likely and hog memory...
                    // we already have all the thread objects, we need to go through each one and find the last 25 activities,
                    // all the while adding them to a new array to get rid of many of the objects in the past...
                    // we create references from activities to threads -> activities

                    NSMutableArray *threads = [NSMutableArray arrayWithCapacity:1];
                    NSMutableArray *threadsIds = [NSMutableArray arrayWithCapacity:1];
                    NSMutableDictionary *activityUpdatingChanges = [NSMutableDictionary dictionaryWithCapacity:1];
                    NSMutableArray *willChangeLatestActivities = [NSMutableArray arrayWithCapacity:1];
                    for (PFObject *activity in latestActivities) {
                        @autoreleasepool {
                            PFObject *activityThread = [activity objectForKey:kGVActivityThreadKey];
                            NSString *threadId = [activityThread objectId];
                            if (activityThread && threadId && activity && ![threadsIds containsObject:threadId]) {
                                [threads addObject:activityThread];
                                [threadsIds addObject:threadId];
                                [activityUpdatingChanges setValue:@(0) forKey:threadId];
                                [willChangeLatestActivities addObject:activity];
                                continue;
                            }
                            NSNumber *num = [activityUpdatingChanges objectForKey:threadId];
                            int numInt = [num intValue];
                            int newNumInt = numInt+1;
                            if (newNumInt > 25) {
                                continue;
                            }
                            [activityUpdatingChanges setObject:[NSNumber numberWithInt:newNumInt] forKey:threadId];
                            if (activity) {
                                [willChangeLatestActivities addObject:activity];
                            }
                        }
                    }

                    filteredLatestActivities = [NSArray arrayWithArray:willChangeLatestActivities];



                    // sort the threads
                    NSArray *sortedThreads = [threads sortedArrayWithOptions:NSSortStable usingComparator:^(id obj1, id obj2) {
                        return [[obj2 updatedAt] compare:[obj1 updatedAt]];
                    }];

                    BOOL testingTableView = NO;
                    
                    // detect if visible already, must animate changes
                    if ([[tableView visibleCells] count] > 0) {
                        // we've already loaded some data, so to coallesce things, we need to animate it
                        // we could do this every time...

                        if (!testingTableView) {
                            [tableView beginUpdates];
                        }


                        NSMutableArray *existingThreads = [NSMutableArray arrayWithArray:self.threads];
                        NSMutableArray *existingThreadIds = [NSMutableArray arrayWithCapacity:1];
                        NSMutableArray *updatedThreadIds = [NSMutableArray arrayWithCapacity:1];
                        NSMutableArray *updatedThreads = [NSMutableArray arrayWithArray:threads];
                        //[updatedThreads addObjectsFromArray:self.threads];

                        for (PFObject *thread in threads) {
                            [updatedThreadIds addObject:[thread objectId]];
                        }

                        for (PFObject *thread in self.threads) {
                            [existingThreadIds addObject:[thread objectId]];
                        }

                        for (PFObject *updatedThread in threads) {
                            NSString *threadObjectId = [updatedThread objectId];
                            if ([existingThreadIds containsObject:threadObjectId]) {
                                // here it already exists...we need to move it
                                PFObject *existingThread;
                                for (PFObject *aThread in self.threads) {
                                    if ([[aThread objectId] isEqualToString:threadObjectId]) {
                                        existingThread = aThread;
                                        continue;
                                    }
                                }
                                NSUInteger newRow = [updatedThreads indexOfObject:updatedThread];
                                NSUInteger oldRow = [self.threads indexOfObject:existingThread];
                                if (newRow == oldRow && [[updatedThread updatedAt] compare:[existingThread updatedAt]] == NSOrderedSame) {
                                    
                                    DLogNSUInteger(newRow);
                                    DLogNSUInteger(oldRow);
                                    //[updatingTableCells addObject:[NSIndexPath indexPathForRow:0 inSection:oldRow]];
                                    //if (![updatingTableCells containsObject:[NSIndexPath indexPathForRow:0 inSection:newRow]]) {
                                    //    [updatingTableCells addObject:[NSIndexPath indexPathForRow:0 inSection:newRow]];
                                        //[tableView reloadSections:[NSIndexSet indexSetWithIndex:newRow] withRowAnimation:UITableViewRowAnimationAutomatic];
                                    //}
                                    
                                    
                                    //
                                    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:newRow]];
                                    
#if DEBUG_BLACK_VIEW
                                    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                                    blackView.backgroundColor = [UIColor blackColor];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [cell addSubview:blackView];
                                        
                                        
                                        
                                        //[cell setNeedsDisplay];
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            [blackView removeFromSuperview];
                                        });
                                    });
#endif
                                    //if ([cell respondsToSelector:@selector(updateContentsDisplayWithRect:)]) {
                                    //    [cell performSelector:@selector(updateContentsDisplayWithRect:) withObject:nil];
                                    //}
                                } else if (newRow != oldRow || [[updatedThread updatedAt] compare:[existingThread updatedAt]] != NSOrderedSame) {
                                    if (!testingTableView) {
                                        DLogNSUInteger(newRow);
                                        DLogNSUInteger(oldRow);
                                        //[tableView moveSection:oldRow toSection:newRow];
                                        
                                        if (![updatingTableCells containsObject:[NSIndexPath indexPathForRow:0 inSection:newRow]]) {
                                            [updatingTableCells addObject:[NSIndexPath indexPathForRow:0 inSection:newRow]];
                                            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newRow] withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }
                                        NSUInteger oldRowAdj = oldRow;
                                        if (![updatingTableCells containsObject:[NSIndexPath indexPathForRow:0 inSection:oldRowAdj]]) {
                                                [updatingTableCells addObject:[NSIndexPath indexPathForRow:0 inSection:oldRowAdj]];
                                                [tableView reloadSections:[NSIndexSet indexSetWithIndex:oldRowAdj] withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }
//                                        oldRowAdj = oldRow + 1;
//                                        if (![updatingTableCells containsObject:[NSIndexPath indexPathForRow:0 inSection:oldRowAdj]]) {
//                                            [updatingTableCells addObject:[NSIndexPath indexPathForRow:0 inSection:oldRowAdj]];
//                                            [tableView reloadSections:[NSIndexSet indexSetWithIndex:oldRowAdj] withRowAnimation:UITableViewRowAnimationAutomatic];
//                                        }
//                                        oldRowAdj = oldRow - 1;
//                                        if (![updatingTableCells containsObject:[NSIndexPath indexPathForRow:0 inSection:oldRowAdj]]) {
//                                            [updatingTableCells addObject:[NSIndexPath indexPathForRow:0 inSection:oldRowAdj]];
//                                            [tableView reloadSections:[NSIndexSet indexSetWithIndex:oldRowAdj] withRowAnimation:UITableViewRowAnimationAutomatic];
//                                        }
                                    }
                                    //[updatingTableCells addObject:[NSIndexPath indexPathForRow:0 inSection:oldRow]];
                                    //[tableView reloadSections:[NSIndexSet indexSetWithIndex:oldRow] withRowAnimation:UITableViewRowAnimationNone];
                                    
                                }
                                
                                DLogNSUInteger(newRow);
                                DLogNSUInteger(oldRow);
                                
                                //[existingThreads removeObject:thread];
                                //[existingThreadIds addObject:threadObjectId];
                                //[tableView reloadSections:[NSIndexSet indexSetWithIndex:newRow] withRowAnimation:UITableViewRowAnimationNone];
                                [existingThreads removeObject:existingThread];
                                
                                
                            } else {
                                if (!testingTableView) {
                                    [tableView insertSections:[NSIndexSet indexSetWithIndex:[updatedThreads indexOfObject:updatedThread]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                }
                                    //[tableView insert]
                                // it might have been deleted, it's not in the
                                // it might have been deleted too
                                // who know's how this got here... we'll insert it
                                // we should just check the updatedAt and add it top the top..
                                //[[self.masterViewController tableView] insertSections:<#(NSIndexSet *)#> withRowAnimation:UITableViewRowAnimationAutomatic]

                                //[tableView insertSections:[updatedThreads indexOfObject:thread] withRowAnimation:UITableViewRowAnimationAutomatic];

                            }
                        }
                        NSUInteger newlyAddedThreadCount = [existingThreads count];
                        [updatedThreads addObjectsFromArray:existingThreads];
            //            for (PFObject *thread in existingThreads) {
            //                if (![updatedThreads containsObject:thread]) {
            //                    [updatedThreads addObject:thread];
            //                }
            //            }
                        
                        // right here we can detect deletions to threads and update tableView
                        
                        

                        self.threads = [NSArray arrayWithArray:updatedThreads];

                        NSMutableArray *existingActivities = [NSMutableArray arrayWithArray:self.activities];
                        NSMutableArray *existingActivityIds = [NSMutableArray arrayWithCapacity:1];
                        NSMutableArray *updatedActivityIds = [NSMutableArray arrayWithCapacity:1];
                        NSMutableArray *updatedActivities = [NSMutableArray arrayWithArray:filteredLatestActivities];

                        for (PFObject *updatedActivity in filteredLatestActivities) {
                            NSString *objectId = [updatedActivity objectId];
                            if (objectId) {
                                [updatedActivityIds addObject:[updatedActivity objectId]];
                            }
                        }

                        for (PFObject *existingActivity in self.activities) {
                            NSString *objectId = [existingActivity objectId];
                            if (objectId) {
                                [existingActivityIds addObject:[existingActivity objectId]];
                            }
                        }

                        for (PFObject *updatedActivity in filteredLatestActivities) {
                            NSString *updatedActivityId = [updatedActivity objectId];
                            if ([existingActivityIds containsObject:updatedActivityId]) {
                                // we need to remove it from existingActivities
                                PFObject *existingActivity;
                                for (PFObject *aActivity in existingActivities) {
                                    if ([[aActivity objectId] isEqualToString:updatedActivityId]) {
                                        existingActivity = aActivity;
                                        continue;
                                    }
                                }

                                [existingActivities removeObject:existingActivity];
                            } else {

                            }
                        }
                        
                        
                        // this is expensive since most of this is the same and we don't need to do anything but we're still forcefully reloading all data after everything has "loaded"
                        // need to be smart about this
                        // the sortedActivities and sortedAssets need to be cleared for that thread objectId, that's all
                        // if there is a thread change, safely reset everything?
//                        if (newlyAddedThreadCount > 0) {
//                            // need to resetinternalmodel no matter what
//                            // if theres a new thread can we just handle this shit properly..
//                            //[self resetInternalModel];
//                        } else {
//                            // most of the time we won't be adding/removing threads
//                            // but just an activity through here...
//                            
//                            // what we'll do is remove the sortedactivities for that thread
//                            // and the sortedassets, forcing a regeneration
//                            // this is akin to marking cells dirty
//                            
//                            for (PFObject *newActivity in existingActivities) {
//                                PFObject *newActivityThread = [newActivity objectForKey:kGVActivityThreadKey];
//                                NSString *newActivityThreadId = [newActivityThread objectId];
//                                [self.sortedActivities removeObjectForKey:newActivityThreadId];
//                                [self.sortedAssets removeObjectForKey:newActivityThreadId];
//                            }
//                            
//                            // and we don't have to reset internal model
//                            
//                        }
                        
                        
                        [updatedActivities addObjectsFromArray:existingActivities];
                        self.activities = [NSArray arrayWithArray:updatedActivities];

                        
                        
                        
                        
                        
                        // cleanup
                        [existingThreads removeAllObjects];
                        [updatedThreads removeAllObjects];
                        [existingThreadIds removeAllObjects];
                        [updatedThreadIds removeAllObjects];
                        [existingActivities removeAllObjects];
                        [updatedActivities removeAllObjects];
                        [updatedActivityIds removeAllObjects];
                        [existingActivityIds removeAllObjects];


                        //self.lastUpdateDate = currentDate;
                        [GVSettingsUtility setLastUpdatedDate:currentDate];
                        self.loading = NO;

                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (!testingTableView) {
                                @try {
                                    [[self.masterViewController tableView] endUpdates];
                                }
                                @catch (NSException *exception) {
//                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                                        DLogException(exception);
//                                    });
                                    DLogException(exception);
                                    [[self.masterViewController tableView] reloadData];
                                }
                                @finally {
                                    
                                }
                                
                            }
                        });
                        
                        //[self masterViewControllerMarkAllCellsAsDirty];
                        
                        // go through updating the cells
                        
                        NSUInteger numOfSections = [tableView numberOfSections];
                        NSMutableArray *existingTableCells = [NSMutableArray arrayWithCapacity:1];
                        for (NSUInteger y = 0;y<numOfSections;y++) {
                            [existingTableCells addObject:[NSIndexPath indexPathForRow:0 inSection:y]];
                        }
                        
                        DLogNSUInteger(numOfSections);
                        DLogObject(updatingTableCells);
                        for (NSIndexPath *indexPath in updatingTableCells) {
                            NSIndexPath *cellIndexPath = indexPath;
//                            if (indexPath.section > numOfSections) {
//                                cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section - (numOfSections - 1)];
//                            } else if (indexPath.section < 0) {
//                                cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section + (numOfSections - 1)];
//                            }
                            DLogNSInteger(indexPath.section);
                            UITableViewCell *cell = [tableView cellForRowAtIndexPath:cellIndexPath];
                            
                            NSDictionary *results = [self masterViewControllerDataAtIndexPath:cellIndexPath];
                            
                            NSURL *mainImageUrl = results[@"main_image_url"];
                            NSString *mainImageString = [mainImageUrl path];
                            
                            //[self masterViewControllerMarkCellAsDirtyAtIndexPath:indexPath];
                            
                            [self masterViewControllerMarkCellAsDirtyAtIndexPath:cellIndexPath];
                            if ([existingTableCells containsObject:cellIndexPath]) {
                                [existingTableCells removeObject:cellIndexPath];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                
                                [self.masterViewController updateRowAtIndexPath:cellIndexPath];
                                //DLogObject(indexPath);
                                //cell
                                //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            });
                            
                        }
                        
                        for (NSIndexPath *indexPath in existingTableCells) {
                            [self.masterViewController updateRowModelAtIndexPath:indexPath];
                        }
                        
                        if ([self.threads count] > 0) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerEndEmptyLabelNotification object:nil];
                        } else {
                            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerSetupEmptyLabelNotification object:nil];
                        }

                        return;
                    }

                    //[[self.masterViewController tableView] beginUpdates];

                    // just load the data
                    self.threads = sortedThreads;
                    // cleanup
                    [threads removeAllObjects];
                    [threadsIds removeAllObjects];


                    self.activities = filteredLatestActivities;



                    [self resetInternalModel];
                    [GVSettingsUtility setLastUpdatedDate:currentDate];
                    //self.lastUpdateDate = currentDate;
                    //if ([self.threads count] > 0) {
                    //if (self.loadedDataCompletely) {
                        [self notifyControllersToLoadData];
                    //}
                    //[[self.masterViewController tableView] endUpdates];
                    self.loading = NO;


    //        if ([latestActivities count] > 0) {
    //            // this is guaranteed latest activities..
    //            // maybe new items...
    //            NSLog(@"received new items: %@", block);
    //        } else if (lastUpdated && [[[self.masterViewController tableView] visibleCells] count] > 0) {
    //            //self.loading = NO;// need to load everything...
    //            //return ;
    //            [self resetInternalModel];
    //            //                    NSArray *visiblePaths = [[self.masterViewController tableView] indexPathsForVisibleRows];
    //            //                    for (NSIndexPath *path in visiblePaths) {
    //            //                        [self masterViewControllerDataAtIndexPath:path];
    //            //                    }
    //            //[self masterViewControllerDataAtIndexPath:nil];
    //            [GVSettingsUtility setLastUpdatedDate:[NSDate date]];
    //
    //            [self notifyControllersToLoadData];
    //            self.loading = NO;
    //        }


            });


    //#if !LOAD_CACHING
    //        PFQuery *query = [GVParseObjectUtility queryForThreadsOfUser:[PFUser currentUser]];
    //
    //        query.limit = 10000;
    //        query.cachePolicy = kPFCachePolicyCacheOnly;
    //        query.maxCacheAge = 60 * 60 * 24 * 7;
    //
    //        if (lastUpdated && [self.threads count] > 0) {
    //            [query whereKey:kGVParseUpdatedAtKey greaterThan:lastUpdated];
    //        }
    //
    //        //    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
    //        //        [query setCachePolicy:kPFCachePolicyCacheOnly];
    //        //    }
    //
    //        self.loading = YES;
    //
    //        //    if (_paginationEnabled) {
    //        //        [query setLimit:_objectsPerPage];
    //        //        //fetching the next page of objects
    //        //        if (!_isRefreshing) {
    //        //            [query setSkip:self.objects.count];
    //        //        }
    //        //    }
    //        if ([self.masterViewController respondsToSelector:@selector(objectsWillLoad)]) {
    //            [self.masterViewController performSelector:@selector(objectsWillLoad)];
    //        }
    //
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //            if (!([self.threads count] > 0)) {
    //                // maybe there are cached data
    //                //NSArray *cachedThreads = [[GVDiskCache diskCache] cachedThreads];
    //                //NSArray *cachedActivities = [[GVDiskCache diskCache] cachedActivities];
    //                //if ([cachedThreads count] > 0) {
    //                    //self.threads = cachedThreads;
    //                    //self.activities = cachedActivities;
    //                    //[self resetInternalModel];
    //                    //[self loadCachedInternalModel];
    //                    //[self notifyControllersToLoadData];
    //                //}
    //            }
    //
    //            @weakify(self);
    //            [query findObjectsInBackgroundWithBlock:^(NSArray *threads, NSError *error) {
    //                //@strongify(self);
    //                // received all the threads
    //                // now need to collect all the activities that will load the images and usernames
    //                // so we want like the last 10-25 of the activities of each thread that we just got
    //                // so we will add a constraint to the activities query, that says it's thread must equal this...
    //
    //
    //                // this will get run twice...shit
    //
    //                // here we need to go through all threads
    //                // get the last updatedAt, and see if we need to pull the activities
    //                // we'll set the updated at in memory when we push the thread controller
    //                // right now if there is another refresh, we'll still hold onto the
    //                // updatedAt (that means) you haven't seen it yet, this will persist using userdefaults
    //                // if the updatedAt is the same as the our thread (token) that gets saved into settings
    //                // then it should be unread...
    //
    //
    //                // here we can detect that we're going to get a cached hit somehow..
    //
    //                //[[GVCache sharedCache] setAttributesForThreads:threads];
    //
    //                // this only needs to actually be run if the threads have changed
    //                PFQuery *query = [GVParseObjectUtility queryForActivitiesOfThreads:threads];
    //                query.cachePolicy = kPFCachePolicyCacheOnly;
    //                query.limit = 10000;
    //                query.maxCacheAge = 60 * 60 * 24 * 7; // one week
    //                [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
    //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //                        @strongify(self);
    //
    //                        UITableView *tableView = [self.masterViewController tableView];
    //
    //                        // check to see if we need to update the rows
    //                        if (lastUpdated && [threads count] > 0 && [self.threads count] > 0 && [[tableView visibleCells] count] > 0) {
    //                            // we got new items...
    //                            // need to coalesce
    //                            // if there were new activities on the thread, the thread has been updated
    //                            // so we need to go through and add everything...
    //
    //                            // so first we'll get the possible changes...
    //
    //
    //                            [[self.masterViewController tableView] beginUpdates];
    //
    //
    //                            NSMutableArray *existingThreads = [NSMutableArray arrayWithArray:self.threads];
    //                            NSMutableArray *updatedThreads = [NSMutableArray arrayWithCapacity:[self.threads count]];
    //                            [updatedThreads addObjectsFromArray:existingThreads];
    //
    //
    //
    //                            for (PFObject *thread in existingThreads) {
    //                                if ([updatedThreads containsObject:thread]) {
    //                                    // here it already exists...we need to move it
    //                                    [tableView moveSection:[existingThreads indexOfObject:thread] toSection:[updatedThreads indexOfObject:thread]];
    //                                    //[existingThreads removeObject:thread];
    //                                } else {
    //                                    // it might have been deleted, it's not in the
    //                                    // it might have been deleted too
    //                                    // who know's how this got here... we'll insert it
    //                                    // we should just check the updatedAt and add it top the top..
    //                                    //[[self.masterViewController tableView] insertSections:<#(NSIndexSet *)#> withRowAnimation:UITableViewRowAnimationAutomatic]
    //                                    //[tableView insertSections:[updatedThreads indexOfObject:thread] withRowAnimation:UITableViewRowAnimationAutomatic];
    //
    //                                }
    //                            }
    //                            for (PFObject *thread in existingThreads) {
    //                                if (![updatedThreads containsObject:thread]) {
    //                                    [updatedThreads addObject:thread];
    //                                }
    //                            }
    //
    //                            self.threads = [NSArray arrayWithArray:updatedThreads];
    //                            self.activities = activities;
    //
    //                            // cleanup?
    //                            [existingThreads removeAllObjects];
    //                            [updatedThreads removeAllObjects];
    //
    //                            [self resetInternalModel];
    //                            [GVSettingsUtility setLastUpdatedDate:[NSDate date]];
    //                            self.loading = NO;
    //
    //                            [[self.masterViewController tableView] endUpdates];
    //
    //
    //
    //                            return;
    //
    //                            // we'lve already loaded data and it doesn't seem we need to load any new data
    //                        } else if (lastUpdated && [self.threads count] > 0) {
    //                            // no new items...return we don't have to do anything
    //                            [GVSettingsUtility setLastUpdatedDate:[NSDate date]];
    //                            self.loading = NO;
    //                            return;
    //                        }
    //
    //                        // if all else fails, we just load everything
    //                        self.threads = threads;
    //                        //[[GVDiskCache diskCache] cacheThreads:self.threads];
    //
    //                        self.activities = activities;
    //                        //[[GVDiskCache diskCache] cacheActivities:self.activities];
    //                        //[[GVCache sharedCache] setAttributesForActivities:activities];
    //                        //            if (self.modelData) {
    //                        //                [self.modelData removeAllObjects];
    //                        //            } else {
    //                        //                self.modelData = [NSMutableDictionary dictionaryWithCapacity:[threads count]];
    //                        //            }
    //                        //            if (self.modelAssets) {
    //                        //                [self.modelAssets removeAllObjects];
    //                        //            } else {
    //                        //                self.modelAssets = [NSMutableDictionary dictionaryWithCapacity:2];
    //                        //            }
    //
    //                        //            if (self.modelLabels) {
    //                        //                [self.modelLabels removeAllObjects];
    //                        //            } else {
    //                        //                self.modelLabels = [NSMutableDictionary dictionaryWithCapacity:10];
    //                        //            }
    //
    //                        // if this actually get's run twice then we can still just parse and check for any changes...
    //                        // and coalesce...
    //
    //
    //
    //                        [self resetInternalModel];
    //    //                    NSArray *visiblePaths = [[self.masterViewController tableView] indexPathsForVisibleRows];
    //    //                    for (NSIndexPath *path in visiblePaths) {
    //    //                        [self masterViewControllerDataAtIndexPath:path];
    //    //                    }
    //                        //[self masterViewControllerDataAtIndexPath:nil];
    //                        [GVSettingsUtility setLastUpdatedDate:[NSDate date]];
    //
    //                        [self notifyControllersToLoadData];
    //                        self.loading = NO;
    //                    });
    //                }];
    //
    //
    //                // here we should serialize and cache all these thread activites as best we can
    //
    //
    //                //        @strongify(self);
    //                //        self.loading = NO;
    //                //        if (error) {
    //                //            self.objects = [NSArray new];
    //                //        } else {
    //                //            if (usersArr && [usersArr respondsToSelector:@selector(count)] && [usersArr count] > 0) {
    //                //                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[usersArr count]];
    //                //                for (PFUser *user in usersArr) {
    //                //                    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
    //                //                        continue;
    //                //                    }
    //                //
    //                //                    NSDictionary *cachedUser = [[GVCache sharedCache] attributesForUser:user];
    //                //                    if (cachedUser) {
    //                //                        [arr addObject:cachedUser[kGVUserNameKey]];
    //                //                    } else {
    //                //                        [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    //                //                            if (!error) {
    //                //                                NSString *userName = [object objectForKey:kGVUserNameKey];
    //                //                                [arr addObject:userName];
    //                //                                [[GVCache sharedCache] setAttributesForUser:object username:userName];
    //                //                            } else {
    //                //                                NSLog(@"error fetching user %@", error);
    //                //
    //                //                            }
    //                //                        }];
    //                //                    }
    //                //                }
    //                //
    //                //                NSString *usersString = @"";
    //                //                if ([arr count] == 0) {
    //                //                    if ([arr count] > 0) {
    //                //                        usersString = [arr objectAtIndex:0];
    //                //                    } else {
    //                //                        cell.shouldStartAnimatingWaitingDots = YES;
    //                //                    }
    //                //                } else {
    //                //                    usersString = [arr componentsJoinedByString:@", "];
    //                //                }
    //                //                cell.usersLabel.text = usersString;
    //                //            } else {
    //                //                cell.shouldStartAnimatingWaitingDots = YES;
    //                //            }
    //                //            if (_paginationEnabled && !_isRefreshing) {
    //                //                //add a new page of objects
    //                //                NSMutableArray *mutableObjects = [NSMutableArray arrayWithArray:self.objects];
    //                //                [mutableObjects addObjectsFromArray:objects];
    //                //                self.objects = [NSArray arrayWithArray:mutableObjects];
    //                //            }
    //                //            else {
    //                //NSLog(@" received objects %@", objects);
    //                //}
    //                //}
    //                
    //            }];
    //        });
    //#endif
            }];
        });
    }
}

- (void)performQuery {
    @autoreleasepool {
    @weakify(self);
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    [op addExecutionBlock:^{
        @strongify(self);
        [self performQueryReceived];
    }];
    NSDictionary *info = @{@"op": op, @"noError": [NSNumber numberWithBool:YES]};
    [[NSNotificationCenter defaultCenter] postNotificationName:GVInternetRequestNotification object:nil userInfo:info];
    }
}

- (void)masterViewControllerMarkAllCellsAsDirty {
    for (NSUInteger i = 0;i<[self.threads count];i++) {
        PFObject *thread = [self.threads objectAtIndex:i];
        if (thread) {
            NSString *threadId = [thread objectId];
            if (threadId) {
                [self.modelActivities removeObjectForKey:threadId];
                [self.sortedActivities removeObjectForKey:threadId];
                [self.sortedAssets removeObjectForKey:threadId];
                
            }
        }
    }
}

- (void)masterViewControllerMarkCellAsDirtyAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath) {
        PFObject *thread = [self.threads objectAtIndex:indexPath.section];
        if (thread) {
        NSString *threadId = [thread objectId];
            if (threadId) {
                [self.modelActivities removeObjectForKey:threadId];
                [self.sortedActivities removeObjectForKey:threadId];
                [self.sortedAssets removeObjectForKey:threadId];
        
            }
        }
    }
}
//
//- (void)loadCachedInternalModel {
//    GVDiskCache *diskCache = [GVDiskCache diskCache];
//
//    //self.modelThreads = [diskCache cachedObjectForKey:@"model_threads"];
//    //self.modelActivities = [diskCache cachedObjectForKey:@"model_activities"];
//    //self.sortedActivities = [diskCache cachedObjectForKey:@"sorted_activities"];
//    //self.sortedAssets = [diskCache cachedObjectForKey:@"sorted_assets"];
//    //self.threadActivities = [diskCache cachedObjectForKey:@"thread_activities"];
//    //self.modelReactions = [diskCache cachedObjectForKey:@"model_reactions"];
//    //self.sortedReactions = [diskCache cachedObjectForKey:@"sorted_reactions"];
//}
//
//- (void)cacheInternalModel {
//    GVDiskCache *diskCache = [GVDiskCache diskCache];
//    if ([self.modelThreads count] > 0) {
//        [diskCache cacheObject:self.modelThreads forKey:@"model_threads"];
//    }
//    if ([self.modelActivities count] > 0) {
//        [diskCache cacheObject:self.modelActivities forKey:@"model_activities"];
//    }
//    if ([self.sortedActivities count] > 0) {
//        [diskCache cacheObject:self.sortedActivities forKey:@"sorted_activities"];
//    }
//    if ([self.sortedAssets count] > 0) {
//        [diskCache cacheObject:self.sortedAssets forKey:@"sorted_assets"];
//    }
//    if ([self.threadActivities count] > 0) {
//        [diskCache cacheObject:self.threadActivities forKey:@"thread_activities"];
//    }
//    if ([self.modelReactions count] > 0) {
//        [diskCache cacheObject:self.modelReactions forKey:@"model_reactions"];
//    }
//    if ([self.sortedReactions count] > 0) {
//        [diskCache cacheObject:self.sortedReactions forKey:@"sorted_reactions"];
//    }
//}

- (void)generateTapToSendButtonHighlightImage {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize), YES, [UIScreen mainScreen].scale);

    //CGContextRef context = UIGraphicsGetCurrentContext();
    
        
        //CGContextSetAllowsAntialiasing(context, YES);
        
        
    [[UIColor whiteColor] setFill];
    
    UIBezierPath *fillRect = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imageSize+1, imageSize+1)];
    [fillRect setFlatness:1.0];
    [fillRect fill];
    
        //[[GVTintColorUtility utilityT] set];
        CGRect circleRect = CGRectIntegral(CGRectMake(0, 0, imageSize, imageSize));
        
        
        //CGContextSaveGState(context);
        //{
        
        //    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 5, [UIColor colorWithWhite:0.7 alpha:1.0].CGColor);
        
        
        UIBezierPath *bezierDashPath = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleRect.size.width/2];
    
        [[GVTintColorUtility utilityToolbarColor] setFill];
    //[[GVTintColorUtility utilityLightBlueColor] setStroke];
    [bezierDashPath setFlatness:0.0];
    
    [bezierDashPath fill];
    
    [[GVTintColorUtility utilityTintColor] setFill];
    
    
        CGFloat dashes[] = {6, 2};
        //[bezierDashPath setLineDash:dashes count:2 phase:0];
        
    //    [bezierDashPath fill];
    //[bezierDashPath stroke];
        //[bezierDashPath stroke];
        // }
        //CGContextRestoreGState(context);
        
        //CGContextSaveGState(context);
        //{
            
            //[[UIColor whiteColor] set];
    [[UIColor whiteColor] setFill];
    
    
    //DLogUIColor([GVTintColorUtility utilityBlueColor]);
            //DLogUIColor([[[self masterViewController] tableView] tintColor]);
            //DLogObject([[[self masterViewController] tableView] tintColor]);
            //[[GVTintColorUtility utilityTintColor] set];
            
            //CGContextSetShadowWithColor(context, CGSizeMake(0, 0.5), 0.5, [UIColor colorWithWhite:0.9 alpha:0.5].CGColor);
            
            UIImage *faceTimeImage = [[UIImage imageNamed:@"lineicons_video"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            
            
            [faceTimeImage drawAtPoint:CGPointMake(cground(CGRectGetMidX(circleRect) - faceTimeImage.size.width/2 + 1.5),cground( CGRectGetMidY(circleRect) - faceTimeImage.size.height/2+1))];
            
        //}
        //CGContextRestoreGState(context);
        
        self.tapToSendButtonHighlightImage = UIGraphicsGetImageFromCurrentImageContext();
        
        if (!self.tapToSendButtonHighlightImageView) {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.tapToSendButtonHighlightImageView = [CALayer layer];
            self.tapToSendButtonHighlightImageView.contents = (id)self.tapToSendButtonHighlightImage.CGImage;
            self.tapToSendButtonHighlightImageView.backgroundColor = [UIColor whiteColor].CGColor;
            self.tapToSendButtonHighlightImageView.needsDisplayOnBoundsChange = NO;
            self.tapToSendButtonHighlightImageView.opaque = YES;
            self.tapToSendButtonHighlightImageView.zPosition = 10000;
                //self.tapToSendButtonHighlightImageView.duration = 0.35;
            });
        }
        
    //}
    //CGContextRestoreGState(context);
    
    UIGraphicsEndImageContext();
}

- (void)resetInternalModel {
    @autoreleasepool {
    if (self.modelThreads) {
        [self.modelThreads removeAllObjects];
        self.modelThreads = [NSMutableDictionary dictionaryWithCapacity:10];
    } else {
        self.modelThreads = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (self.modelActivities) {
        [self.modelActivities removeAllObjects];
        self.modelActivities = [NSMutableDictionary dictionaryWithCapacity:10];
    } else {
        self.modelActivities = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (self.sortedActivities ) {
        [self.sortedActivities removeAllObjects];
        self.sortedActivities = [NSMutableDictionary dictionaryWithCapacity:10];
    } else {
        self.sortedActivities = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (self.sortedAssets) {
        [self.sortedAssets removeAllObjects];
        self.sortedAssets = [NSMutableDictionary dictionaryWithCapacity:10];
    } else {
        self.sortedAssets = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (self.threadActivities) {
        [self.threadActivities removeAllObjects];
        self.threadActivities = [NSMutableDictionary dictionaryWithCapacity:10];
    } else {
        self.threadActivities = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (self.modelReactions) {
        [self.modelReactions removeAllObjects];
        self.modelReactions = [NSMutableDictionary dictionaryWithCapacity:10];
    } else {
        self.modelReactions = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (self.sortedReactions) {
        [self.sortedReactions removeAllObjects];
        self.sortedReactions = [NSMutableDictionary dictionaryWithCapacity:10];
    } else {
        self.sortedReactions = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    }
}

- (void)makeDictionaryWithThreadsToActivites {
    @autoreleasepool {
        //DLogMainThread();
        for (NSUInteger i = 0;i<[self.activities count];i++) {
            @autoreleasepool {
                PFObject *activity = [self.activities objectAtIndex:i];
                PFObject *activityThread = [activity objectForKey:kGVActivityThreadKey];
                NSString *activityThreadId = [activityThread objectId];

                NSMutableDictionary *modelActivity = [self.modelActivities objectForKey:activityThreadId];
                if (!modelActivity && ![modelActivity isKindOfClass:[NSMutableDictionary class]]) {
                    modelActivity = [NSMutableDictionary dictionaryWithCapacity:4];
                }
                if (activity && [activity respondsToSelector:@selector(objectId)]) {
                    NSString *objectId = [activity objectId];
                    if (objectId && [objectId respondsToSelector:@selector(length)] && [objectId length] > 0 && [modelActivity respondsToSelector:@selector(setObject:forKey:)]) {
                        [modelActivity setObject:activity forKey:objectId];
                        [self.modelActivities setObject:modelActivity forKey:activityThreadId];
                    }
                }
            }
        }
    }
}

- (void)sortActivitiesOfThread:(NSString*)threadId {
    @autoreleasepool {
        // DLogMainThread();
    NSMutableDictionary *threadActivities = [self.modelActivities objectForKey:threadId];
    NSArray *activities = [threadActivities allValues];
    NSArray *threadActivitiesSorted = [activities sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj2 createdAt] compare:[obj1 createdAt]];
    }];
    if (threadActivitiesSorted) {
        [self.sortedActivities setObject:threadActivitiesSorted forKey:threadId];
    }
    // else {
    //    [self.sortedActivities setObject:[NSArray array] forKey:threadId];
    //}
    }
}

- (void)masterViewControllerSectionLabelWithUsernames:(NSArray*)sortedUsers completionBlock:(void (^)(NSString *labelString))completionBlock {
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([sortedUsers count] > 0) {
                NSMutableArray *usernameArr = [NSMutableArray arrayWithCapacity:1];
                NSMutableArray *tracker = [NSMutableArray arrayWithCapacity:1];

                for (int i = 0;i < [sortedUsers count];i++) {
                    [usernameArr addObject:[NSNull null]];
                }

                @weakify(self);
                [sortedUsers enumerateObjectsUsingBlock:^(NSString *username, NSUInteger idx, BOOL *stop) {
                    [GVTwitterAuthUtility shouldGetProfileImageForAnyUser:username block:^(NSURL *imageURL, NSURL *bannerURL, NSString *realName) {
                        [usernameArr replaceObjectAtIndex:idx withObject:realName];
                        [tracker addObject:[NSNull null]];
                        if ([tracker count] == [sortedUsers count]) {
                            @strongify(self);
                            // we got all of them, run the completion
                            NSString *newLabel = [self concatenateStringObjects:usernameArr];
                            completionBlock(newLabel);
                        }
                    }];
                }];
            }
        });
    }
}



+ (void)drawProfileImage:(UIImage*)image atPoint:(CGPoint)originPoint context:(CGContextRef)context username:(NSString*)realname createdAt:(NSDate*)createdDate currentDate:(NSDate*)currentDate shouldRecord:(BOOL)shouldRecord showUnread:(BOOL)showUnread key:(NSString *)key {

    CGFloat imageX = originPoint.x;

    CGSize aspectSize = [UIImage aspectSize:CGSizeMake(imageSize, imageSize) image:image];
    if (isnan(aspectSize.width)) {
        aspectSize.width = imageSize;
    }
    if (isnan(aspectSize.height)) {
        aspectSize.height = imageSize;
    }
    //CGSize aspectSize = CGSizeMake(0, 0);
    //            if (aspectSize.width > 0) {
    //                aspectSize.width = dirtyAspectSize.width;
    //            }
    //            if (aspectSize.height > 0) {
    //                aspectSize.height = dirtyAspectSize.height;
    //            }


    CGFloat aspectAdj = ((imageSize - aspectSize.width)/2);
    CGFloat aspectAdjY = (imageSize - aspectSize.height)/2;
    CGFloat imageY = originPoint.y;
    CGRect imageRect = CGRectIntegral(CGRectMake(imageX + aspectAdj, imageY + aspectAdjY, aspectSize.width, aspectSize.height));

    //            maskedImageView.image = profImage;
    //            maskedImageView.frame = imageRect;




#if REFLECTION
    // draw reflection first
    CGContextSaveGState(context);
    {



        CGContextTranslateCTM(context, 0.0f, contextHeight);
        CGContextScaleCTM(context, 1.0f, -1.0f);

        CGRect cropRect = CGRectIntegral(CGRectMake(imageX, contextHeight - imageYPadding, imageSize, imageSize));
        UIBezierPath *bezierCirclePath = [UIBezierPath bezierPathWithRoundedRect:cropRect cornerRadius:imageSize/2];
        [bezierCirclePath setFlatness:0.0];

        //[bezierCirclePath addClip];
        //[bezierCirclePath stroke];

        //CGAffineTransform t = CGAffineTransformTranslate(CGAffineTransformIdentity, imageX, 0 );
        //[bezierCirclePath moveToPoint:CGPointMake(imageRect.origin.x, 0)];
        //[bezierCirclePath applyTransform:t];

        [bezierCirclePath addClip];


        //CGContextClipToMask(context, cropRect, <#CGImageRef mask#>)




        //                CGContextClipToDrawing(context, cropRect, ^(CGContextRef maskContext, CGRect rect){
        //                    UIGraphicsPushContext(maskContext);
        //
        //
        //
        //
        //                    //[[UIColor whiteColor] setFill];
        //                    //CGContextFillRect(maskContext, rect);
        //
        //                    //[[UIColor blackColor] setFill];
        //                    //[@"Clear" drawInRect:rect withFont:[UIFont boldSystemFontOfSize:20.0]];
        //
        //                    UIGraphicsPopContext();
        //                });

        CGContextClipToMask(context, cropRect, mask);

        CGRect flippedImageRect = CGRectIntegral(CGRectMake(imageRect.origin.x, contextHeight - (imageY - aspectAdjY), imageRect.size.width, imageRect.size.height));
        //            [maskedImageView.layer renderInContext:context];
        CGContextDrawImage(context, flippedImageRect, profImage.CGImage);


        //CGContextDrawImage(context, cropRect, gradientImage);




        //CGContextDrawImage(context, CGRectMake(imageX, 0, imageSize, imageSize), gradientImage.CGImage);


        //  [bezierCirclePath stroke];
        //             [bezierCirclePath stroke];

    }
    CGContextRestoreGState(context);
#endif
    
    
    CGRect cropRect = CGRectIntegral(CGRectMake(imageX, imageY, imageSize, imageSize));
    

    CGFloat badgeYPadding = imageSize/2 + 8.5;
    CGRect badgeRect = CGRectMake(imageX + imageSize - badgeSize + badgeXPadding, imageY + imageSize - badgeSize - badgeYPadding, badgeSize, badgeSize);
    
#if DRAW_BADGE_TAIL_PIN
    CGFloat badgeSize = 22;
    CGFloat badgeHeight = 15;
    CGFloat badgeYPadding = 12;
    CGRect badgeRect = CGRectMake(imageX + imageSize - badgeSize, imageY + imageSize - badgeSize - badgeHeight - badgeYPadding, badgeSize, badgeHeight);
    

    CGContextSaveGState(context);
    {
        
        [[UIColor darkGrayColor] set];
        
        CGFloat widthMaxSize = 5;
        CGFloat heightMaxDip = 5;
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        
        
        
        
        
        CGPoint startPoint = CGPointMake(badgeRect.origin.x + badgeSize, badgeRect.origin.y);
        
        [bezierPath moveToPoint:startPoint];
        [bezierPath addLineToPoint:CGPointMake(startPoint.x, badgeRect.origin.y - heightMaxDip)];
        [bezierPath addLineToPoint:CGPointMake(badgeRect.origin.x + badgeSize - widthMaxSize, badgeRect.origin.y)];
        [bezierPath addLineToPoint:startPoint];
        
        
        [bezierPath fill];
    }
    CGContextRestoreGState(context);
#endif
    
    
    if ([key isEqualToString:@"loadMore"]) {
        // draw profile image
        
        CGContextSaveGState(context);
        {
            CFStringRef string = (CFStringRef)@"LOAD MORE";
            CTFontRef font = CTFontCreateWithName((CFStringRef)@"HelveticaNeue-Light", 15.0, NULL);
            // Initialize the string, font, and context
            
            CTTextAlignment alignment = kCTCenterTextAlignment;
            
            CTParagraphStyleSetting alignmentSetting;
            alignmentSetting.spec = kCTParagraphStyleSpecifierAlignment;
            alignmentSetting.valueSize = sizeof(CTTextAlignment);
            alignmentSetting.value = &alignment;
            
            CTParagraphStyleSetting settings[1] = {alignmentSetting};
            
            CFIndex settingCount = 1;
            CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(settings, settingCount);
            
            
            
            CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName, kCTParagraphStyleAttributeName};
            CFTypeRef values[] = { font, [GVTintColorUtility utilityTintColor].CGColor, paragraphRef};
            
            CFDictionaryRef attributes =
            CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                               (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
            
            CFAttributedStringRef attrString =
            CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)string, attributes);
            
            
            
            CTLineRef line = CTLineCreateWithAttributedString(attrString);
            //CTLineRef line = CTLineCreateTruncatedLine(lineDraw, width, kCTLineTruncationEnd, NULL);
            CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
            CGFloat lineHeight = 0;
            if (lineBounds.size.height > 0) {
                lineHeight = lineBounds.size.height;
            }
            
            //NSDictionary *userAttrs = @{NSFontAttributeName: titleNormalFont, NSForegroundColorAttributeName: (id)titleNormalColor};
            //NSAttributedString *usersLabelAttrString = [[NSAttributedString alloc] initWithString:string attributes:userAttrs];
            
            CGFloat textXInset = originPoint.x + (imagePadding/4);
            
            // Set text position and draw the line into the graphics context
            //CGContextSetTextPosition(context, textXInset, originPoint.y - lineHeight);
            
            //    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
            //        DLogObject(self.sectionIndexPath);
            //        return;
            //    }
            
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
            
            CGRect frameRect = CGRectIntegral(CGRectMake(cropRect.origin.x,cropRect.origin.y - lineHeight +3, cropRect.size.width+0.5, cropRect.size.height));
            
            // Create the Core Text frame using our current view rect bounds.
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:frameRect];
            //[[UIColor darkGrayColor] setStroke];
            //[path stroke];
            CTFrameRef frame =  CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), [path CGPath], NULL);
            CTFrameDraw(frame, context);
            
            //CTLineDraw(line, context);
            
            
#if DEBUG_CF_MEMORY
            CFBridgingRelease(attributes);
            CFBridgingRelease(frame);
            CFBridgingRelease(framesetter);
            CFBridgingRelease(line);
            CFBridgingRelease(paragraphRef);
            //CFBridgingRelease(lineDraw);
            CFBridgingRelease(attrString);
            CFBridgingRelease(font);
#endif
            
        }
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
        {
            
            UIBezierPath *bezierCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(cropRect.origin.x, cropRect.origin.y-1, cropRect.size.width, cropRect.size.height) cornerRadius:cropRect.size.width/2];
            [bezierCirclePath setFlatness:0.0];
            [[GVTintColorUtility utilityTintColor] setStroke];
            // [bezierCirclePath addClip];
            
            
            
             bezierCirclePath.lineWidth = 2;
            //CGAffineTransform t = CGAffineTransformTranslate(CGAffineTransformIdentity, imageX, 0 );
            //[bezierCirclePath moveToPoint:CGPointMake(imageRect.origin.x, 0)];
            //[bezierCirclePath applyTransform:t];
            
            //[bezierCirclePath addClip];
            [bezierCirclePath stroke];
            //            [maskedImageView.layer renderInContext:context];
            //CGContextDrawImage(context, imageRect, image);
            //[image drawInRect:imageRect];
            
            //  [bezierCirclePath stroke];
            //             [bezierCirclePath stroke];
            
        }
        CGContextRestoreGState(context);
    } else if (image && [image isKindOfClass:[UIImage class]]) {
        // draw profile image
        CGContextSaveGState(context);
        {

            UIBezierPath *bezierCirclePath = [UIBezierPath bezierPathWithRoundedRect:cropRect cornerRadius:cropRect.size.width/2];
            [bezierCirclePath setFlatness:0.0];

            // [bezierCirclePath addClip];

            //CGAffineTransform t = CGAffineTransformTranslate(CGAffineTransformIdentity, imageX, 0 );
            //[bezierCirclePath moveToPoint:CGPointMake(imageRect.origin.x, 0)];
            //[bezierCirclePath applyTransform:t];

            [bezierCirclePath addClip];

            //            [maskedImageView.layer renderInContext:context];
            //CGContextDrawImage(context, imageRect, image);
            [image drawInRect:imageRect];
            
            //  [bezierCirclePath stroke];
            //             [bezierCirclePath stroke];

        }
        CGContextRestoreGState(context);
    }
    if (showUnread) {
        CGContextSaveGState(context);
        {
            
            CGRect unreadRect = CGRectMake(imageX, 14, badgeRect.size.width, badgeRect.size.height);
            CGFloat strokeWidth = 2.0;
            CGRect strokeRect = CGRectInset(badgeRect, -(strokeWidth), -(strokeWidth));
            
            UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:CGRectIntegral(strokeRect) cornerRadius:strokeRect.size.width/2];
            [strokePath setFlatness:0.0];
            [[UIColor colorWithWhite:1.0 alpha:1.0] setFill];
            [strokePath fill];
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectIntegral(badgeRect) cornerRadius:badgeRect.size.width/2];
            [bezierPath setFlatness:0.0];
            
            
            //[[UIColor colorWithWhite:0.98 alpha:1.000] setStroke];
            //[bezierPath setLineWidth:4.5];
            //if (shouldRecord) {
            //    [[UIColor colorWithRed:0.983 green:0.399 blue:0.295 alpha:1.000] setFill];
            [[GVTintColorUtility utilityBlueColor] setFill];
            
            //}
            //else {
            //    [[GVTintColorUtility utilityBlueColor] setFill];
            //}
            //[[UIColor colorWithRed:0.972 green:0.161 blue:0.225 alpha:1.000] setFill];
            //[bezierPath stroke];
            [bezierPath fill];
        }
        CGContextRestoreGState(context);
    }
    
    if (shouldRecord) {
        CGContextSaveGState(context);
        {
            

            CGFloat strokeWidth = 2.0;
            CGRect strokeRect = CGRectInset(badgeRect, -(strokeWidth), -(strokeWidth));
            
            UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:CGRectIntegral(strokeRect) cornerRadius:strokeRect.size.width/2];
            [strokePath setFlatness:0.0];
            [[UIColor colorWithWhite:1.0 alpha:1.0] setFill];
            [strokePath fill];
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectIntegral(badgeRect) cornerRadius:badgeRect.size.width/2];
            [bezierPath setFlatness:0.0];

            
            //[[UIColor colorWithWhite:0.98 alpha:1.000] setStroke];
            //[bezierPath setLineWidth:4.5];
            //if (shouldRecord) {
            [[GVTintColorUtility utilityLightRedColor] setFill];
            //}
            //else {
            //    [[GVTintColorUtility utilityBlueColor] setFill];
            //}
                //[[UIColor colorWithRed:0.972 green:0.161 blue:0.225 alpha:1.000] setFill];
            //[bezierPath stroke];
            [bezierPath fill];
        }
        CGContextRestoreGState(context);
    }
    
    
    UIFont *titleNormalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    UIColor *titleNormalColor = [UIColor colorWithWhite:0.3 alpha:1.0];


    //CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    //CGContextFillRect(context, rowSize);
    //CGFloat contextHeight = rowSize.size.height;
    //CGContextTranslateCTM(context, 0.0f, contextHeight);
    //CGContextScaleCTM(context, 1.0f, -1.0f);

    NSString *string = nil;
    if ([realname respondsToSelector:@selector(length)] && [realname length] > 0) {
        string = realname;
    } else {
        string = @"";
    }


    [GVMasterModelObject drawText:string createdDate:createdDate currentDate:currentDate atPoint:CGPointMake(cground( imageX - (imagePadding/3)), cropRect.origin.y - 4) WithFont:titleNormalFont color:titleNormalColor context:context];


    



}


+ (void)drawText:(NSString*)string createdDate:(NSDate*)createdDate currentDate:(NSDate*)currentDate atPoint:(CGPoint)originPoint WithFont:(UIFont*)titleNormalFont color:(UIColor*)titleNormalColor context:(CGContextRef)context {
    CGContextSaveGState(context);
    {

        CTFontRef font = CTFontCreateWithName((CFStringRef)[titleNormalFont fontName], [titleNormalFont pointSize]-2, NULL);
        // Initialize the string, font, and context
        
        CGFloat padding = 3;
        
        CGFloat widthCalc = imageSize + imagePadding;
        double width = 0;
#if CGFLOAT_IS_DOUBLE
        width = widthCalc;
#else
        width = [[NSNumber numberWithFloat:widthCalc] doubleValue];
#endif
        
        
        CGContextClipToRect(context, CGRectMake(originPoint.x, 0, widthCalc, GVMasterTableViewCellRowHeight));
        
        if (string) {
            CTTextAlignment alignment = kCTCenterTextAlignment;
            
            CTParagraphStyleSetting alignmentSetting;
            alignmentSetting.spec = kCTParagraphStyleSpecifierAlignment;
            alignmentSetting.valueSize = sizeof(CTTextAlignment);
            alignmentSetting.value = &alignment;
            
            CTParagraphStyleSetting settings[1] = {alignmentSetting};
            
            CFIndex settingCount = 1;
            CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(settings, settingCount);



            CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName, kCTParagraphStyleAttributeName};
            CFTypeRef values[] = { font, titleNormalColor.CGColor, paragraphRef};

            CFDictionaryRef attributes =
            CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                               (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);

            CFAttributedStringRef attrString =
            CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)string, attributes);



            CTLineRef line = CTLineCreateWithAttributedString(attrString);
            //CTLineRef line = CTLineCreateTruncatedLine(lineDraw, width, kCTLineTruncationEnd, NULL);
            CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
            CGFloat lineHeight = 0;
            if (lineBounds.size.height > 0) {
                lineHeight = lineBounds.size.height;
            }

            //NSDictionary *userAttrs = @{NSFontAttributeName: titleNormalFont, NSForegroundColorAttributeName: (id)titleNormalColor};
            //NSAttributedString *usersLabelAttrString = [[NSAttributedString alloc] initWithString:string attributes:userAttrs];

            CGFloat textXInset = originPoint.x + (imagePadding/4);

            // Set text position and draw the line into the graphics context
            //CGContextSetTextPosition(context, textXInset, originPoint.y - lineHeight);

            //    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
            //        DLogObject(self.sectionIndexPath);
            //        return;
            //    }
            
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
            
            CGRect frameRect = CGRectIntegral(CGRectMake(originPoint.x, originPoint.y - lineHeight - padding, imageSize + imagePadding/2 + 4, lineHeight));
            
            // Create the Core Text frame using our current view rect bounds.
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:frameRect];
            //[[UIColor darkGrayColor] setStroke];
            //[path stroke];
            CTFrameRef frame =  CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), [path CGPath], NULL);
            CTFrameDraw(frame, context);
            
            //CTLineDraw(line, context);


#if DEBUG_CF_MEMORY
        CFBridgingRelease(attributes);
        CFBridgingRelease(frame);
        CFBridgingRelease(line);
            CFBridgingRelease(framesetter);
        //CFBridgingRelease(lineDraw);
        CFBridgingRelease(attrString);
        CFBridgingRelease(font);
//            CFBridgingRelease(paragraphRef);
#endif

            
        if (createdDate && currentDate) {
            
            NSString *timeLabel = nil;
            NSDateFormatterStyle dateStyle = NSDateFormatterNoStyle;
            NSDateFormatterStyle timeStyle = NSDateFormatterShortStyle;

    //        NSDateComponents *component = [NSDate componentsBetweenDate:createdDate andDate:currentDate];
    //        if ([component day] > 0) {
    //            timeLabel = [NSDateFormatter dateFormatFromTemplate:@"hMMM" options:0 locale:[NSLocale currentLocale]];
    //        } else {
            if ([NSDate daysBetweenDate:createdDate andDate:currentDate] > 0) {
                dateStyle = NSDateFormatterMediumStyle;
                timeStyle = NSDateFormatterNoStyle;

    //            if (!distantDateFormatter) {
    //                NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"dMMM" options:0
    //                                                                          locale:[NSLocale currentLocale]];
    //                distantDateFormatter = [[NSDateFormatter alloc] init];
    //                [distantDateFormatter setDateFormat:formatString];
    //            }
    //            //timeLabel = [NSDate hourBetweenDate:createdDate andDate:currentDate];
    //
    //            timeLabel = [distantDateFormatter stringFromDate:createdDate];
                timeLabel = [NSDateFormatter localizedStringFromDate:createdDate dateStyle:dateStyle timeStyle:timeStyle];
            } else {

    //            NSTimeInterval timeSinceDate = [currentDate timeIntervalSinceDate:createdDate];
    //
    //            NSUInteger hoursSinceDate = (NSUInteger)(timeSinceDate / (60.0 * 60.0));
    //
    //
    //            switch(hoursSinceDate)
    //            {
    //                default: {
    //                    timeLabel = [NSString stringWithFormat:@"%d hours ago", hoursSinceDate];
    //                }
    //                case 1: {
    //                    timeLabel = @"1 hour ago";
    //                }
    //                case 0: {
    //                    NSUInteger minutesSinceDate = (NSUInteger)(timeSinceDate / 60.0);
    //                    timeLabel = [NSString stringWithFormat:@"%d minutes ago", minutesSinceDate];
    //                    /* etc, etc */
    //                    break;
    //                }
    //            }
    //            if (!hourDateFormatter) {
    //                NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"h" options:0 locale:[NSLocale currentLocale]];
    //
    //                hourDateFormatter = [[NSDateFormatter alloc] init];
    //                [hourDateFormatter setDateFormat:formatString];
    //            }
    //
    ////        } else {
    //            timeLabel = [hourDateFormatter stringFromDate:createdDate];

                //DEBUGGGINGG
                timeLabel = [NSDateFormatter localizedStringFromDate:createdDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        }

//        if ([timeLabel length] > 0) {
//        }
            
//            CTTextAlignment alignment = kCTCenterTextAlignment;
//            
//            CTParagraphStyleSetting alignmentSetting;
//            alignmentSetting.spec = kCTParagraphStyleSpecifierAlignment;
//            alignmentSetting.valueSize = sizeof(CTTextAlignment);
//            alignmentSetting.value = &alignment;
//            
//            CTParagraphStyleSetting settings[1] = {alignmentSetting};
//            
//            CFIndex settingCount = 1;
//            CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(settings, settingCount);

            CTFontRef dfont = CTFontCreateWithName((CFStringRef)[titleNormalFont fontName], [titleNormalFont pointSize]-2, NULL);
            UIColor *dColor = [UIColor colorWithWhite:0.7 alpha:1];
            
            
            CFStringRef dkeys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName, kCTParagraphStyleAttributeName};
            CFTypeRef dvalues[] = { dfont, dColor.CGColor, paragraphRef};

            CFDictionaryRef dattributes =
            CFDictionaryCreate(kCFAllocatorDefault, (const void**)&dkeys,
                               (const void**)&dvalues, sizeof(dkeys) / sizeof(dkeys[0]),
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);

            CFAttributedStringRef dattrString =
            CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)timeLabel, dattributes);


    //        double dwidth = 0;
    //#if CGFLOAT_IS_DOUBLE
    //        dwidth = imageSize;
    //#else
    //        dwidth = [[NSNumber numberWithFloat:imageSize] doubleValue];
    //#endif

            CTLineRef dline = CTLineCreateWithAttributedString(dattrString);
            //CTLineRef dline = CTLineCreateTruncatedLine(dlineDraw, width, kCTLineTruncationEnd, NULL);
            CGRect dlineBounds = CTLineGetBoundsWithOptions(dline, 0);
            CGFloat dlineHeight = 0;
            if (dlineBounds.size.height > 0) {
                dlineHeight = dlineBounds.size.height;
            }

            //NSDictionary *userAttrs = @{NSFontAttributeName: titleNormalFont, NSForegroundColorAttributeName: (id)titleNormalColor};
            //NSAttributedString *usersLabelAttrString = [[NSAttributedString alloc] initWithString:string attributes:userAttrs];

            // Set text position and draw the line into the graphics context
            //CGContextSetTextPosition(context, textXInset, originPoint.y - lineHeight - dlineHeight);

            //    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
            //        DLogObject(self.sectionIndexPath);
            //        return;
            //    }
            
            //CTLineDraw(dline, context);
            
            CTFramesetterRef dframesetter = CTFramesetterCreateWithAttributedString(dattrString);
            
            CGRect dframeRect = CGRectIntegral(CGRectMake(frameRect.origin.x, originPoint.y - lineHeight - dlineHeight - padding, frameRect.size.width, dlineHeight));
            
            // Create the Core Text frame using our current view rect bounds.
            UIBezierPath *dpath = [UIBezierPath bezierPathWithRect:dframeRect];
            CTFrameRef dframe =  CTFramesetterCreateFrame(dframesetter, CFRangeMake(0, 0), [dpath CGPath], NULL);
            CTFrameDraw(dframe, context);
            
            
            
            
        
#if DEBUG_CF_MEMORY
        CFBridgingRelease(dattributes);
        CFBridgingRelease(dline);
        CFBridgingRelease(dattrString);
            CFBridgingRelease(dframesetter);
        CFBridgingRelease(dfont);
        CFBridgingRelease(dframe);
        //CFBridgingRelease(dlineDraw);
        CFBridgingRelease(paragraphRef);
#endif
        }
        }
        

    }
    
    CGContextRestoreGState(context);
}

+ (CGRect)drawTitleText:(NSString*)titleText atOrigin:(CGPoint)originPoint context:(CGContextRef)context {

    CGRect maskingRect = CGRectZero;



    CGContextSaveGState(context);
    {

        UIFont *titleNormalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0];
        UIColor *titleNormalColor = [UIColor colorWithWhite:0.3 alpha:1.0];

        CTFontRef font = CTFontCreateWithName((CFStringRef)[titleNormalFont fontName], [titleNormalFont pointSize], NULL);
        // Initialize the string, font, and context

        CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName};
        CFTypeRef values[] = { font, titleNormalColor.CGColor};

        CFDictionaryRef attributes =
        CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                           (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                           &kCFTypeDictionaryKeyCallBacks,
                           &kCFTypeDictionaryValueCallBacks);

        CFAttributedStringRef attrString =
        CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)titleText, attributes);
#if DEBUG_CF_MEMORY
        CFBridgingRelease(attributes);
#endif
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
        CGFloat lineHeight = 0;
        if (lineBounds.size.height > 0) {
            lineHeight = lineBounds.size.height;
        }


        CGFloat textYPosition = cground(originPoint.y - lineHeight);
        // Set text position and draw the line into the graphics context
        CGContextSetTextPosition(context, textXInset + originPoint.x, textYPosition );

        //    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
        //        DLogObject(self.sectionIndexPath);
        //        return;
        //    }


        CGFloat maskHeight = textYPosition + lineHeight + textYPosition + titleNormalFont.descender;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(lineBounds.size.width, maskHeight ), YES, [UIScreen mainScreen].scale);

        CGContextRef newContext = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(context, YES);

        //Set color of current context
        [[UIColor blackColor] set];

        NSArray* gradientColors = @[(id)[UIColor clearColor].CGColor,
                                    (id)[UIColor whiteColor].CGColor];

        CGFloat gradientLocations[] = {0.0, 1.0};
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (CFArrayRef)gradientColors, gradientLocations);

        CGFloat percentReflect = 0.4;


        CGContextDrawLinearGradient(newContext, gradient, CGPointMake(0, maskHeight - (maskHeight * percentReflect)), CGPointMake(0, maskHeight), kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);


        CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
        UIGraphicsEndImageContext();
        
        maskingRect = CGRectMake(originPoint.x, textYPosition- 10, lineBounds.size.width + textXInset, maskHeight + textYPosition);

        CGContextClipToMask(context, CGRectIntegral(maskingRect), mask);




        CTLineDraw(line, context);

#if DEBUG_CF_MEMORY
        //CGGradientRelease(gradient);
        CFBridgingRelease(gradient);

        CFBridgingRelease(font);
        CFBridgingRelease(attrString);


        CFBridgingRelease(line);

        CFBridgingRelease(mask);
#endif

    }
    CGContextRestoreGState(context);
    return maskingRect;
}


- (void)makeDictionaryOfThreadAssetsWithThread:(PFObject*)thread {
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSMutableDictionary *modelAsset = [NSMutableDictionary dictionaryWithCapacity:5];

        NSDate *threadUpdatedAt = [thread updatedAt];
        NSString *threadId = [thread objectId];

        NSURL *cachedImageURL = [self.masterCacheDirectory URLByAppendingPathComponent:[threadId stringByAppendingString:@".png"]];
        NSString *filePath = [cachedImageURL path];


//        NSError *aFindFileError = nil;
//        if ([fileManager fileExistsAtPath:filePath]) {
//            NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:&aFindFileError];
//            if ([threadUpdatedAt compare:attributes[NSFileModificationDate]] == 0) {
//                [modelAsset setObject:cachedImageURL forKey:@"main_image_url"];
//                return;
//            }
//        }


        //DLogMainThread();

        NSDate *currentDate = [NSDate date];
        
        
//        for (NSOperation *op in self.downloadOperations) {
//            [op cancel];
//        }


    // get the image urls into another nsmutablearray
    NSArray *sortedActivities = [self.sortedActivities objectForKey:threadId];



    if (!sortedActivities) {
        [self.sortedAssets setObject:modelAsset forKey:threadId];
        return;
    }

    NSUInteger sortedActivityCount = [sortedActivities count];

    NSMutableArray *sortedImageUrls = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *sortedImageViews = [NSMutableArray arrayWithCapacity:1];

    NSMutableArray *sortedUsers = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *imageViews = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *imageFinishedTracker = [NSMutableDictionary dictionaryWithCapacity:5];
    NSString *usersLabelString = @"";


    for (id someObj in sortedActivities) {
        [sortedImageUrls addObject:[NSNull null]];
        [sortedImageViews addObject:[NSNull null]];
    }



    NSString *currentUserId = [[PFUser currentUser] objectId];
    NSInteger __block count = 0;
    [sortedActivities enumerateObjectsWithOptions:0 usingBlock:^(PFObject *activity, NSUInteger index, BOOL *stop) {
        @autoreleasepool {
            if (count > 24) {
                *stop = YES;
            }
            // video thumbnail url
            //PFFile *videoThumb = [activity objectForKey:kGVActivityVideoThumbnailKey];
            PFFile *video = [activity objectForKey:kGVActivityVideoKey];
            NSString *videoUrl = [video url];

            PFUser *actUser = [activity objectForKey:kGVActivityUserKey];
            NSString *username = [actUser username];
            NSString *videoThumbUrl = username;
            if (videoThumbUrl) {
            //[sortedImageUrls insertObject:videoThumbUrl atIndex:count];
                [sortedImageUrls replaceObjectAtIndex:index withObject:videoThumbUrl];
            }

            BOOL showActivityUnread = YES;
            NSArray *activityUserIds = [activity objectForKey:kGVActivitySendReactionsKey];
            for (NSString *aUserId in activityUserIds) {
                if (aUserId && [aUserId respondsToSelector:@selector(length)] && [aUserId performSelector:@selector(length)] > 0) {
                    // got a user objectId
                    // all we have to do is see if our object id is there already
                    if ([aUserId isEqualToString:[[PFUser currentUser] objectId]]) {
                        showActivityUnread = NO;
                    }
                }
            }

            NSString *durationString = [activity objectForKey:kGVActivityVideoDurationKey];
            NSString *duration = [self trimVideoDurationString:durationString];
            NSIndexPath *imgIndexPath = [NSIndexPath indexPathForItem:count inSection:0];

            NSDictionary *info = @{@"activityId":[activity objectId], @"threadId":threadId, @"duration": duration, @"showActivityUnread": [NSNumber numberWithBool:showActivityUnread]};
            //[sortedImageViews replaceObjectAtIndex:index withObject:info];
            //[imageViews setObject:info forKey:imgIndexPath];

//            //@weakify(imageFinishedTracker);
//            //@weakify(imgIndexPath);
//            void (^completionBlock)(UIImageView*) = ^(UIImageView *aImageView) {
//                //@weakify(aImageView);
//                //DLogMainThread();
//                //NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
//                //[blockOperation addExecutionBlock:^{
//                    [imageFinishedTracker setObject:[NSNull null] forKey:imgIndexPath];
//
//                    // NSArray *cell = [[self.masterViewController tableView] cellForRowAtIndexPath:[self master];
//                    //for (UITableViewCell *cell in [[self.masterViewController tableView] visibleCells]) {
//                    //id displayDelegate = [aImageView performSelector:@selector(displayDelegate)];
//                    //if (displayDelegate) {
//#if CRAZY
//                    UITableView *tv = [self.masterViewController tableView];
//                    NSArray *visibleIndexPaths = [tv indexPathsForVisibleRows];
//                    NSIndexPath *threadPath = [NSIndexPath indexPathForRow:0 inSection:[self.threads indexOfObject:thread]];
//                    if ([visibleIndexPaths containsObject:threadPath]) {
//                        UITableViewCell *cell = [tv cellForRowAtIndexPath:threadPath];
//                        [cell setNeedsDisplay];
//                        //[cell setNeedsDisplayInRect:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)]
//                    }
//#endif
//
////                    UIView *view = aImageView;
////                    while ([NSStringFromClass([view class]) hasSuffix:@"ShellView"]) {
////                        view = [view superview];
////                    }
////                    [view setNeedsDisplay];
////                    [[view superview] setNeedsDisplay];
//
//                    //[displayDelegate performSelector:@selector(updateContentsDisplayWithRect:) withObject:[NSValue valueWithCGRect:aImageView.frame]];
//
//                    //    return;
//                    //}
//
//             //   }];
//            //[blockOperation start];
//
//
//                NSDictionary *info = @{@"activityId":[activity objectId], @"threadId":threadId, @"imageView": aImageView, @"duration": duration, @"showActivityUnread": [NSNumber numberWithBool:showActivityUnread]};
//                [sortedImageViews replaceObjectAtIndex:index withObject:info];
//                [imageViews setObject:info forKey:imgIndexPath];
//            };

//
//            // video thumbnail image views
//            UIImageView *imageView = [[GVCache sharedCache] imageViewForAttributesUrl:videoThumbUrl];
//            if (imageView) {
//                //[sortedImageViews insertObject:imageView atIndex:count];
//                //[sortedImageViews replaceObjectAtIndex:index withObject:imageView];
//                //[imageViews setObject:imageView forKey:[NSIndexPath indexPathForItem:count inSection:0]];
//                //completionBlock(imageView);
//                UIImageView *imageViewNew = [[UIImageView alloc] initWithImage:imageView.image];
//
//                completionBlock(imageViewNew);
//            } else {
//                UIImageView *imageView = [[UIImageView alloc] init];
//                //imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
//                //imageView.layer.shouldRasterize = YES;
//                //imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//                //imageView.layer.opaque = YES;
//                //imageView.contentMode = UIViewContentModeScaleAspectFill;
//                //imageView.layer.backgroundColor = [UIColor whiteColor].CGColor;
//                //imageView.layer.borderColor = [UIColor colorWithWhite:0.996 alpha:1.000].CGColor;
//                //imageView.layer.borderWidth = 0.0;
//                //imageView.opaque = YES;
//                //imageView.backgroundColor = [UIColor whiteColor];
//                @weakify(imageView);
//                //NSString *username = [[PFUser currentUser] objectForKey:@"username"];
//                //self.usernameLabel.text = username;
//                @weakify(self);
//
//                [[GVCache sharedCache] setAttributesForImageView:imageView url:videoThumbUrl];
//                [GVTwitterAuthUtility shouldGetProfileImageForAnyUser:username block:^(NSURL *imageURL, NSURL *bannerURL, NSString *realName) {
//                    //DLogMainThread();
//                    //dispatch_async(dispatch_get_main_queue(), ^{
//                    // @strongify(self);
//                    [imageView setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                        // dispatch_async(dispatch_get_main_queue(), ^{
//                            //@strongify(self);
//                            UIImageView *imageViewW = imageView_weak_;
//                            //GVDelegateImageView *imageViewW = imageView_weak_;
//                            //imageViewW.contentMode = UIViewContentModeScaleAspectFill;
//                            //imageViewW.alpha = 1;
//                            //CGAffineTransform imageViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//                            //imageViewTransform = CGAffineTransformRotate(imageViewTransform, DEGREES_TO_RADIANS(0));
//
//                            //CGAffineTransform initialViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//                            //imageViewW.transform = CGAffineTransformRotate(initialViewTransform, DEGREES_TO_RADIANS(-90));
//                            //imageViewW.layer.cornerRadius = 20;
//                            //imageViewW.clipsToBounds = NO;
//                            //imageViewW.layer.opaque = YES;
//                            //imageViewW.layer.backgroundColor = [UIColor whiteColor].CGColor;
//                            //imageViewW.opaque = YES;
//                            //imageViewW.backgroundColor = [UIColor whiteColor];
//                            //if (cacheType == SDImageCacheTypeNone || cacheType == SDImageCacheTypeDisk || cacheType == SDImageCacheTypeMemory) {
//
//
//                            //UITableView *tv = [self.masterViewController tableView];
//                            //NSArray *visibleIndexPaths = [tv indexPathsForVisibleRows];
//                            //NSIndexPath *threadPath = [NSIndexPath indexPathForRow:0 inSection:[self.threads indexOfObject:thread]];
//                            //if ([visibleIndexPaths containsObject:threadPath]) {
//                            //    UITableViewCell *cell = [tv cellForRowAtIndexPath:threadPath];
//                                //[cell setNeedsDisplayInRect:cell.bounds];
//                                //[cell setNeedsDisplayInRect:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)]
//                                //}
//
////                            if (cacheType == SDImageCacheTypeNone) {
////                                
////                                imageViewW.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
////                                [UIView animateWithDuration:0.6
////                                                      delay:0.0
////                                     usingSpringWithDamping:0.6
////                                      initialSpringVelocity:0.0
////                                                    options:UIViewAnimationOptionBeginFromCurrentState
////                                                 animations:^{
////                                                     imageViewW.transform = imageViewTransform;
////                                                 } completion:^(BOOL finished) {
////                                                     if (finished) {
////                                                         //if (imageViewW.displayDelegate) {
////                                                         //  CGRect rect = [imageViewW.displayDelegate convertRect:imageViewW.frame fromView:imageViewW];
////                                                             //[imageViewW.displayDelegate setNeedsDisplayInRect:rect];
////                                                             [blockOperation start];
////                                                         //}
////                                                     }
////                                                 }];
////                            } else {
////                                //imageViewW.transform = imageViewTransform;
////                                //if (imageViewW.displayDelegate) {
////                                //  CGRect rect = [imageViewW.displayDelegate convertRect:imageViewW.superview.bounds fromView:imageViewW.superview];
////                                    //[imageViewW.displayDelegate setNeedsDisplay];
////                                    //[blockOperation start];
////                                //}
//
////                            }
////@weakify(imageView)
//
//
//
//                            //completionBlock(imageViewW);
//
////                            NSDictionary *info = @{@"activityId":[activity objectId], @"threadId":threadId, @"imageView": aImageView, @"duration": duration, @"showActivityUnread": [NSNumber numberWithBool:showActivityUnread]};
////                            [sortedImageViews replaceObjectAtIndex:index withObject:info];
////                            [imageViews setObject:info forKey:imgIndexPath];
//
//                        //});
//                    }];
//                }];
//
//

            //                completionBlock(imageView);

            //         }


            // users label name and unread indicator
            NSString *type = [activity objectForKey:kGVActivityTypeKey];
            PFUser *activityUser = [activity objectForKey:kGVActivityUserKey];
            if (![[activityUser objectId] isEqualToString:currentUserId]) {
                // it's not us so lets add the user to the username label
                NSString *username = [activityUser username];
                if (![sortedUsers containsObject:username]) {
                    if (username) {
                        [sortedUsers addObject:username];
                    }
                }
                // we check to see if this is necessary,
                // it's not if we already found an unread reaction
//                NSNumber *showUnreadNum = [modelAsset objectForKey:@"showUnread"];
//                if (![showUnreadNum boolValue]) {
//                    if ([type isEqualToString:kGVActivityTypeSendKey]) {
//                        // it's a send activity not by us
//                        // lets check the users to see if we are in it already
//                        NSArray *reactionUsers = [activity objectForKey:kGVActivitySendReactionsKey];
//                        NSMutableArray *reactionUserIds = [NSMutableArray arrayWithCapacity:[reactionUsers count]];
//                        for (PFUser *reactionUser in reactionUsers) {
//                            //if (![[reactionUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
//                                // we have not already submitted a reaction...
//                                // we should show unread and we can actually return..
//                                //showUnreadNum = [NSNumber numberWithBool:YES];
//                                //continue;
//                                //}
//                            if (reactionUser && ![reactionUser isKindOfClass:[NSNull class]]) {
//                                NSString *userId = [reactionUser objectId];
//                                [reactionUserIds addObject:userId];
//                            }
//                        }
//                        // current user does not have a reaction, and it's a send
//                        // mark as unread
//                        if (![reactionUserIds containsObject:currentUserId]) {
//                            [modelAsset setObject:[NSNumber numberWithBool:YES] forKey:@"showUnread"];
//                        }
//                    }
//                }
            }
            count++;
        }
    }];

    NSArray *arrUsers = [thread objectForKey:kGVThreadUsersKey];
        NSMutableArray *userTracker = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *finalUsers = [NSMutableArray arrayWithCapacity:1];
    for (PFUser *user in arrUsers) {
        if (user && ![user isKindOfClass:[NSNull class]]) {
            NSString *name = [user username];
            if (![userTracker containsObject:name]) {
                NSDictionary *realName = [[GVDiskCache diskCache] cachedAttributesForUsername:name];
                if (realName && ![realName isKindOfClass:[NSNull class]] && [realName objectForKey:kGVDiskCacheRealNameKey]) {
                    [finalUsers addObject:[realName objectForKey:kGVDiskCacheRealNameKey]];
                    [userTracker addObject:name];
                } else {
                    [userTracker addObject:name];
                    [finalUsers addObject:name];
                }
            }
        }
    }

        //if ([finalUsers count] > 0) {
        // yay we have another users activity
        usersLabelString = [self concatenateStringObjects:finalUsers];
        //}

        CGImageRef gradientImage = nil;

        //        CGContextSaveGState(context);
        //        {



        // draw reflection gradient once

        //UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize), YES, [UIScreen mainScreen].scale);

//        CGContextRef maskContext = UIGraphicsGetCurrentContext();
//        //UIGraphicsPushContext(maskContext);
//
//
//        CGColorSpaceRelease(colorSpace);
//        CGGradientRelease(gradient);
//        gradientImage = CGBitmapContextCreateImage(maskContext);

        //UIGraphicsPopContext();
        //UIGraphicsEndImageContext();

        //        }
        //        CGContextRestoreGState(context);



        // start drawing whole table cell image

        CGRect rowSize = [UIScreen mainScreen].bounds;
        rowSize.size.height = [[self.masterViewController tableView] rowHeight];
        UIGraphicsBeginImageContextWithOptions(rowSize.size, YES, [UIScreen mainScreen].scale);

        CGContextRef context = UIGraphicsGetCurrentContext();


        CGContextSetAllowsAntialiasing(context, YES);
        //CGContextSetAllowsFontSmoothing(context, YES);
        //CGContextSetAllowsFontSubpixelPositioning(context, NO);
        //CGContextSetAllowsFontSubpixelQuantization(context, YES);

        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, rowSize);
        CGFloat contextHeight = rowSize.size.height;
        CGContextTranslateCTM(context, 0.0f, contextHeight);
        CGContextScaleCTM(context, 1.0f, -1.0f);

        NSString *string = nil;
        if ([usersLabelString length] > 0) {
            string = usersLabelString;
        } else {
            string = @"Appears Empty...";
        }

        NSString *forcedTitle = [thread objectForKey:kGVThreadForcedTitleKey];
        if (forcedTitle && [forcedTitle respondsToSelector:@selector(length)] && [forcedTitle length] > 0) {
            string = forcedTitle;
        }
        
        CGRect titleRect = [GVMasterModelObject drawTitleText:string atOrigin:CGPointMake(0, rowSize.size.height) context:context];

        //CFBridgingRelease(string);

#if REFLECTION
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize), YES, [UIScreen mainScreen].scale);

        CGContextRef newContext = UIGraphicsGetCurrentContext();


        //Set color of current context
        [[UIColor blackColor] set];

        NSArray* gradientColors = [NSArray arrayWithObjects:
                                   (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,  
                                   (id)[UIColor colorWithWhite:1.0 alpha:0.15].CGColor,
                                   (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, nil];
        CGFloat gradientLocations[] = {0.0, 0.92, 1.0};
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (CFArrayRef)gradientColors, gradientLocations);

        CGFloat percentReflect = 0.4;




        //// General Declarations

        //// Gradient Declarations
        NSArray* gradientRColors = [NSArray arrayWithObjects:
                                   (id)[UIColor clearColor].CGColor,
                                   (id)[UIColor whiteColor].CGColor, nil];
        CGFloat gradientRLocations[] = {0, 1};
        CGGradientRef gradientR = CGGradientCreateWithColors(NULL, (CFArrayRef)gradientRColors, gradientRLocations);


        //// Rectangle Drawing
        //    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(39.5, 20.5, 73, 90)];
        //    CGContextSaveGState(context);
        //    [rectanglePath addClip];
        //    CGContextDrawRadialGradient(context, gradient,
        //                                CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) - 64), 0,
        //                                CGPointMake(CGRectGetMidX(self.frame), 64), 300,
        //                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

        //    CGContextDrawRadialGradient(context, gradient,
        //                                CGPointMake(CGRectGetMaxX(self.frame) + 20, CGRectGetMidY(self.frame) + 64), 0,
        //                                CGPointMake(CGRectGetMidX(self.frame) + 20, CGRectGetMidY(self.frame) + 64), 300,
        //                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        //


        //CGContextDrawRadialGradient(newContext, gradientR, \
                                    CGPointMake(imageSize/2, imageSize*.25), 0, \
                                    CGPointMake(imageSize, imageSize*.25), 300, \
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

                CGContextDrawLinearGradient(newContext, gradient, CGPointMake(0, imageSize - ( imageSize * percentReflect) ), CGPointMake(0, imageSize), kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);

        //Draw ellipse &lt;- I know we’re drawing a circle, but a circle is just a special ellipse.
        //CGRect ellipseRect = CGRectMake(110.0f, 200.0f, 100.0f, 100.0f);
        //CGContextFillEllipseInRect(newContext, ellipseRect);

        CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
        UIGraphicsEndImageContext();

        CGGradientRelease(gradient);
        CGGradientRelease(gradientR);

#endif
        //        UIImage *gradientImage = nil;

//        CGContextSaveGState(context);
//        {
//            UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize), YES, [UIScreen mainScreen].scale);
//
//            CGContextRef drawContext = UIGraphicsGetCurrentContext();
//
//            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//
//            NSArray* gradientColors = [NSArray arrayWithObjects:
//                                       (id)[UIColor clearColor].CGColor,
//                                       (id)[UIColor whiteColor].CGColor, nil];
//            CGFloat gradientLocations[] = {0, 1};
//            CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
//
//
//            CGContextDrawLinearGradient(drawContext, gradient, CGPointMake(0.5, 0), CGPointMake(0.5, 1), kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
//
//
//            gradientImage = UIGraphicsGetImageFromCurrentImageContext();
//
//            // CGImageRef maskedTextImage = CGImageCreateWithMask(threadImage.CGImage, <#CGImageRef mask#>)
//            
//            
//            UIGraphicsEndImageContext();
//
//        }
//        CGContextRestoreGState(context);
//        CAShapeLayer *circleShapeLayer = [CAShapeLayer layer];
//        circleShapeLayer.path = bezierCirclePath.CGPath;
//        circleShapeLayer.frame = cropRect;
//        circleShapeLayer.needsDisplayOnBoundsChange = NO;
//        circleShapeLayer.shouldRasterize = YES;
//        circleShapeLayer.rasterizationScale = [UIScreen mainScreen].scale;
//        circleShapeLayer.contentsScale = [UIScreen mainScreen].scale;

//        UIImageView *maskedImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        maskedImageView.contentMode = UIViewContentModeScaleAspectFill;
//        maskedImageView.layer.mask = circleShapeLayer;

        CGFloat tapToSendX = 5;
        CGFloat tapToSendXAndPadding = (tapToSendX + imageSize + imagePadding);

        // tap to send dash
        CGContextSaveGState(context);
        {


            CGRect circleRect = CGRectIntegral(CGRectMake(imageCircleXPadding, imageYPadding, imageSize, imageSize));


            //CGContextSaveGState(context);
            //{

                //    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 5, [UIColor colorWithWhite:0.7 alpha:1.0].CGColor);


            UIBezierPath *bezierDashPath = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleRect.size.width/2];
            bezierDashPath.lineWidth = 1.5;
            [[GVTintColorUtility utilityBlueColor] set];
            [bezierDashPath setFlatness:0.0];
            CGFloat dashes[] = {6, 2};
            //[bezierDashPath setLineDash:dashes count:2 phase:0];

            [bezierDashPath stroke];

                // }
                //CGContextRestoreGState(context);

             CGContextSaveGState(context);
            {
                
                [[GVTintColorUtility utilityBlueColor] set];
                //DLogUIColor([GVTintColorUtility utilityBlueColor]);
                //DLogUIColor([[[self masterViewController] tableView] tintColor]);
                //DLogObject([[[self masterViewController] tableView] tintColor]);
                //[[GVTintColorUtility utilityTintColor] set];

            CGContextSetShadowWithColor(context, CGSizeMake(0, 0.5), 0.5, [UIColor colorWithWhite:0.9 alpha:0.5].CGColor);

            UIImage *faceTimeImage = [[UIImage imageNamed:@"lineicons_video"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];



            [faceTimeImage drawAtPoint:CGPointMake(cground(CGRectGetMidX(circleRect) - faceTimeImage.size.width/2 + 1.5),cground( CGRectGetMidY(circleRect) - faceTimeImage.size.height/2 - 1))];

            }
            CGContextRestoreGState(context);
            
            UIFont *tapNormalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
            UIColor *tapNormalColor = [GVTintColorUtility utilityBlueColor];
            NSString *tapToSend = @"tap to send";
            CGFloat lineHeight = 0;
            
            CGContextSaveGState(context);
            {

                

                //CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                //CGContextFillRect(context, rowSize);
                //CGFloat contextHeight = rowSize.size.height;
                //CGContextTranslateCTM(context, 0.0f, contextHeight);
                //CGContextScaleCTM(context, 1.0f, -1.0f);

                CFStringRef string = (__bridge CFStringRef)tapToSend;
                CTFontRef font = CTFontCreateWithName((CFStringRef)[tapNormalFont fontName], [tapNormalFont pointSize], NULL);
                // Initialize the string, font, and context

                CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName};
                CFTypeRef values[] = { font, tapNormalColor.CGColor};

                CFDictionaryRef attributes =
                CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                                   (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                                   &kCFTypeDictionaryKeyCallBacks,
                                   &kCFTypeDictionaryValueCallBacks);

                CFAttributedStringRef attrString =
                CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);



                CTLineRef line = CTLineCreateWithAttributedString(attrString);
                CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
                
                if (lineBounds.size.height > 0) {
                    lineHeight = lineBounds.size.height;
                }

                CGFloat tapPaddingY = -4;//-5;
                CGFloat tapPaddingX = 5;

                // Set text position and draw the line into the graphics context
                CGContextSetTextPosition(context, cground(circleRect.origin.x + tapPaddingX), cground(circleRect.origin.y - lineHeight + tapPaddingY)-0.5);

                //    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
                //        DLogObject(self.sectionIndexPath);
                //        return;
                //    }
                [[[[self masterViewController] tableView] tintColor] set];
                
                CTLineDraw(line, context);
    #if DEBUG_CF_MEMORY
                CFBridgingRelease(attrString);
                CFBridgingRelease(line);

                CFBridgingRelease(attributes);
    #endif
                
            }
            CGContextRestoreGState(context);
            
            NSString *holdToEdit = @"hold to edit";
            UIColor *holdToEditColor = [GVTintColorUtility utilityTintColor];
            
            CFStringRef hstring = (__bridge CFStringRef)holdToEdit;
            CTFontRef hfont = CTFontCreateWithName((CFStringRef)[tapNormalFont fontName], [tapNormalFont pointSize]-0.5, NULL);
            // Initialize the string, font, and context
            
            CFStringRef hkeys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName};
            CFTypeRef hvalues[] = { hfont, holdToEditColor.CGColor};
            
            CFDictionaryRef hattributes =
            CFDictionaryCreate(kCFAllocatorDefault, (const void**)&hkeys,
                               (const void**)&hvalues, sizeof(hkeys) / sizeof(hkeys[0]),
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
            
            CFAttributedStringRef hattrString =
            CFAttributedStringCreate(kCFAllocatorDefault, hstring, hattributes);
            
            
            
            CTLineRef hline = CTLineCreateWithAttributedString(hattrString);
            CGRect hlineBounds = CTLineGetBoundsWithOptions(hline, 0);
            CGFloat hlineHeight = 0;
            if (hlineBounds.size.height > 0) {
                hlineHeight = hlineBounds.size.height;
            }
            
            CGFloat htapPaddingY = -3;
            CGFloat htapPaddingX = 6.0;
            
            // Set text position and draw the line into the graphics context
            CGContextSetTextPosition(context, cground(circleRect.origin.x + htapPaddingX)+0.7, cground(circleRect.origin.y - lineHeight - hlineHeight + htapPaddingY)-0.5);
            
            //    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
            //        DLogObject(self.sectionIndexPath);
            //        return;
            //    }
            
            CTLineDraw(hline, context);
#if DEBUG_CF_MEMORY
            CFBridgingRelease(hattrString);
            CFBridgingRelease(hline);
            
            CFBridgingRelease(hattributes);
#endif

//            //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//
//            NSArray* gradientColors = [NSArray arrayWithObjects:
//                                       (id)[UIColor whiteColor].CGColor,
//                                       (id)[UIColor blackColor].CGColor, nil];
//            CGFloat gradientLocations[] = {0, 1};
//            CGGradientRef gradient = CGGradientCreateWithColors(NULL, (CFArrayRef)gradientColors, gradientLocations);
//
//
//            CGContextDrawLinearGradient(context, gradient, CGPointMake(0.5, 0), CGPointMake(0.5, 1), kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);

            //CGContextDrawImage(context, circleRect, mask);
            //CGContextDrawImage(context, circleRect, faceTimeImage.CGImage);
        }
        CGContextRestoreGState(context);

        CGFloat imagesInFirstPic = 4;

        NSMutableArray *sortedProfilePics = [NSMutableArray arrayWithCapacity:1];



        NSMutableDictionary *sortedImageData = [NSMutableDictionary dictionaryWithCapacity:1];

        NSUInteger activityIterCount = [sortedActivities count];
        if (activityIterCount > 25) {
            activityIterCount += 1;
        }
        for (NSUInteger i = 0;i<activityIterCount;i++) {

            PFObject *activity = nil;
            if (i < [sortedActivities count]) {
                activity = [sortedActivities objectAtIndex:i];
            }
            PFUser *activityUser = [activity objectForKey:kGVActivityUserKey];

            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            CGFloat imageX = (tapToSendXAndPadding) + ( (imageSize + imagePadding) * i);
            NSValue *imageRectValue = [NSValue valueWithCGRect:CGRectMake(imageX, 0, 0, 0)];
            
            if (activityUser) {
                NSDictionary *cachedInfo = [[GVDiskCache diskCache] cachedAttributesForUsername:[activityUser username]];
                NSURL *usernameURL = nil;
                UIImage *profImage = nil;
                BOOL delayedLoading = YES;
                NSString *threadId = [[activity objectForKey:kGVActivityThreadKey] objectId];
                NSArray *threadShouldRecord = [self threadShouldRecordReactionWithActivity:activity];
                NSNumber *shouldRecordNum = nil;
                BOOL shouldRecord = NO;
                if ([threadShouldRecord count] > 0) {
                    shouldRecordNum = [threadShouldRecord objectAtIndex:0];
                    if ([shouldRecordNum respondsToSelector:@selector(boolValue)]) {
                        shouldRecord = [shouldRecordNum boolValue];
                    }
                }
                
                
                BOOL shouldShowUnread = [self threadShouldShowUnreadWithActivity:activity];
                NSNumber *showUnreadNum = [NSNumber numberWithBool:shouldShowUnread];
                
            
                
                
                if (!shouldRecord) {
                    // we can show the video thumbnail instead
                    PFFile *videoThumbnail = [activity objectForKey:kGVActivityVideoThumbnailKey];
                    usernameURL = [NSURL URLWithString:[videoThumbnail url]];
                    NSString *usernameString = [usernameURL absoluteString];
                    if (i < imagesInFirstPic) {
                        profImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:usernameString];
                    }
                    if (usernameURL && ![[SDImageCache sharedImageCache] diskImageExistsWithKey:usernameString]) {
                        CGFloat userImageOffset = imageX;
                        
                        NSOperation *op = [[SDWebImageManager sharedManager] downloadImageWithURL:usernameURL options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                if (image != nil) {
                                    // we got the image now, lets try to fade it in on top of the profile picture
                                    // try to fade out the profile picture in place of this
                                    
                                    // we have to mark cell as dirty... the fade should happen independent of results
                                    // the view added to the cell will contain the different states so it will fade out on it's own
                                    // the image will be updated in the background with the new data, so
                                    // animations don't interfere, it would be pretty much impossible if the cell is getting redrawn each time for an animation to get cancelled or otherwise interfered with
                                    // lets focus on the animation first
                                    

                                    CGRect imageRect = CGRectIntegral(CGRectMake(userImageOffset, GVMasterTableViewCellRowHeight - imageYPadding -imageSize, imageSize, imageSize));
                                        
                                        
                                        
                                    CGRect imageRectFromValue = [imageRectValue CGRectValue];
                                    imageRect.origin.x = imageRectFromValue.origin.x;
                                    DLogCGRect(imageRect);
                                    UIImageView *contentView = [[UIImageView alloc] initWithImage:profImage];
                                    contentView.backgroundColor = [UIColor whiteColor];
                                    contentView.autoresizesSubviews = NO;
                                    contentView.clipsToBounds = YES;
                                    contentView.layer.cornerRadius = imageSize/2;
                                    contentView.opaque = NO;
                                    contentView.contentMode = UIViewContentModeScaleAspectFill;
                                    contentView.layer.shouldRasterize = YES;
                                    contentView.layer.needsDisplayOnBoundsChange = NO;
                                    contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
                                    
                                    UIView *bgView = [[UIView alloc] initWithFrame:imageRect];
                                    bgView.backgroundColor = [UIColor whiteColor];
                                    bgView.autoresizesSubviews = NO;
                                    bgView.clipsToBounds = YES;
                                    bgView.layer.cornerRadius = imageSize/2;
                                    bgView.opaque = NO;
                                    bgView.contentMode = UIViewContentModeScaleAspectFill;
                                    bgView.layer.shouldRasterize = YES;
                                    bgView.layer.needsDisplayOnBoundsChange = NO;
                                    bgView.layer.rasterizationScale = [UIScreen mainScreen].scale;
                                    
                                    //[bgView setImage:[UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationRightMirrored]];
                                    
                                    NSURL *profileURL = [cachedInfo objectForKey:kGVDiskCacheUserProfilePic];
                                    UIImage *profileImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[profileURL absoluteString]];
                                    
                                    
                                    NSArray *visibleCells = [[[self masterViewController] tableView] visibleCells];
                                    
                                    for (NSUInteger c=0;c<[visibleCells count];c++) {
                                        GVMasterTableViewCell *cell = (GVMasterTableViewCell*)[visibleCells objectAtIndex:c];
                                        
                                        NSIndexPath *threadIndexPath = [NSIndexPath indexPathForRow:0 inSection:[self.threads indexOfObject:thread]];
                                        if ([cell.sectionIndexPath isEqual:threadIndexPath]) {
                                            UIScrollView *scrollView = cell.scrollView;
                                        
                                            [self masterViewControllerMarkCellAsDirtyAtIndexPath:threadIndexPath];
                                            [[self masterViewController] updateRowAtIndexPath:threadIndexPath];
                                            //[cell updateDisplayInRect:imageRect];
//                                            NSBlockOperation *blockOperation = [NSBlockOperation new];
//                                            GVBlockOperation *blockOpHolder = [GVBlockOperation new];
                                            
                                            
                                            
//                                            [blockOperation addExecutionBlock:^{
//                                                dispatch_async(dispatch_get_main_queue(), ^{
//                                                    [contentView setImage:profileImage];
//                                                    contentView.layer.frame = imageRect;
//                                                    bgView.layer.frame = imageRect;
//                                                    [contentView setNeedsDisplay];
//                                                    //[scrollView addSubview:bgView];
//                                                    [scrollView addSubview:contentView];
//                                                    //[scrollView bringSubviewToFront:contentView];
//                                                    [UIView animateWithDuration:5.0 animations:^{
//                                                        contentView.alpha = 0.0;
//                                                    } completion:^(BOOL finished) {
//                                                        if (finished) {
//                                                            [bgView removeFromSuperview];
//                                                            [contentView removeFromSuperview];
//                                                        }
//                                                    }];
//                                                });
//                                            }];
                                            
                                            //blockOpHolder.operation = blockOperation;
                                            //[blockOpHolder addToMainQueue];
                                            //});
                                        }
                                        
                                    }
                                
                                
                                    
                                    DLogObject(image);
                                }
                                NSArray *downloadKeys = [self.downloadOperations allKeys];
                                if (op && downloadKeys && [downloadKeys containsObject:usernameURL]) {
                                    [self.downloadOperations removeObjectForKey:usernameURL];
                                }
                            });
                        }];
                        if (!self.downloadOperations) {
                            self.downloadOperations = [NSMutableDictionary dictionaryWithCapacity:1];
                        }
                        NSArray *dlKeys = [self.downloadOperations allKeys];
                        if (op && dlKeys && ![dlKeys containsObject:usernameURL]) {
                            [self.downloadOperations setObject:op forKey:usernameURL];
                            delayedLoading = YES;
                        } else {
                            [op cancel];
                            op = nil;
                            delayedLoading = YES;
                        }
                    } else {
                        if (profImage != nil) {
                            profImage = [UIImage imageWithCGImage:profImage.CGImage scale:1.0 orientation:UIImageOrientationRightMirrored];
                            delayedLoading = NO; // we can stop the loading of the profile image
                        }
                    }
                    
                }
                if (delayedLoading || profImage == nil) {
                    // this should be run even if it's not being delayed loading
                    // could be a different user
                    usernameURL = [cachedInfo objectForKey:kGVDiskCacheUserProfilePic];
                    UIImage *imageRef = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[usernameURL absoluteString]];
                    profImage = [UIImage imageWithCGImage:imageRef.CGImage scale:1.0 orientation:UIImageOrientationDownMirrored];
                    
                }
                

                
                id url_obj = [usernameURL absoluteString];
                if (url_obj == nil) {
                    url_obj = [NSNull null];
                }
                
                id point_obj = [NSValue valueWithCGPoint:CGPointMake(imageX, 0)];
                if (point_obj == nil) {
                    point_obj = [NSNull null];
                }
                NSString *forceName = [activity objectForKey:kGVActivityForcedDisplayName];
                
                id name_obj = cachedInfo[kGVDiskCacheRealNameKey];
                
                if (forceName && [forceName respondsToSelector:@selector(length)] && [forceName length] > 0) {
                    name_obj = forceName;
                }
                
                if (name_obj == nil) {
                    name_obj = [NSNull null];
                }
                
                id activity_obj = [activity objectId];
                if (activity_obj == nil) {
                    activity_obj = [NSNull null];
                }
                
                id date_obj = [activity createdAt];
                if (date_obj == nil) {
                    date_obj = [NSNull null];
                }
                
                id shouldRecord_obj = shouldRecordNum;
                
                NSNumber *forceRecord = [activity objectForKey:kGVActivityForcedUnrecordState];
                NSInteger recordInteger = [forceRecord integerValue];
                if (recordInteger > 0) {
                    if (recordInteger > 1) {
                        // show
                        shouldRecord = YES;
                    } else {
                        shouldRecord = NO;
                    }
                    
                    shouldRecord_obj = [NSNumber numberWithBool:shouldRecord];
                }
                
                if (shouldRecordNum == nil) {
                    shouldRecord_obj = [NSNull null];
                }
                
                id imageOrientation_obj = [NSNumber numberWithInteger:profImage.imageOrientation];
                if (imageOrientation_obj == nil) {
                    imageOrientation_obj = [NSNull null];
                }
                
                id showUnread_obj = showUnreadNum;
                
                NSNumber *forceUnreadState = [activity objectForKey:kGVActivityForcedUnreadState];
                NSInteger unreadInteger = [forceUnreadState integerValue];
                if (unreadInteger > 0) {
                    if (unreadInteger > 1) {
                        shouldShowUnread = YES;
                    } else {
                        shouldShowUnread = NO;
                    }
                    showUnread_obj = [NSNumber numberWithBool:shouldShowUnread];
                }
                
                if (showUnreadNum == nil) {
                    showUnread_obj = [NSNull null];
                }
                
                NSDictionary *dataObject = @{@"url": url_obj,
                                             @"point": point_obj,
                                             @"name": name_obj,
                                             @"activityId": activity_obj,
                                             @"date": date_obj,
                                             @"should_record": shouldRecord_obj,
                                             @"imageOrientation": imageOrientation_obj,
                                             @"show_unread": showUnread_obj
                                             
                                             };
                
            
                [sortedImageData setObject:dataObject forKey:indexPath];

                if (i < imagesInFirstPic) {


                    [GVMasterModelObject drawProfileImage:profImage atPoint:CGPointMake(imageX, imageYPadding) context:context username:name_obj createdAt:date_obj currentDate:currentDate shouldRecord:shouldRecord showUnread:shouldShowUnread key:nil];


                }

            
        
                point_obj = [NSValue valueWithCGPoint:CGPointMake(imageX+imageSize+ imagePadding, 0)];
                if (point_obj == nil) {
                    point_obj = [NSNull null];
                }
                
                dataObject = nil;
                if (i > 24) {
                    dataObject = @{@"key":@"loadMore",
                                   @"point": point_obj
                                   };
                    [sortedImageData setObject:dataObject forKey:[NSIndexPath indexPathForItem:indexPath.row+1 inSection:0]];
                }
            }
        
    }
        UIImage *threadImage = UIGraphicsGetImageFromCurrentImageContext();


        UIGraphicsEndImageContext();
#if SDWEBIMAGE_CACHING
        [[SDImageCache sharedImageCache] storeImage:threadImage forKey:[cachedImageURL absoluteString]];
        // we want to store the thread updatedAt in the disk cache
        // so we don't have to do this again, basically in the disk cache
        // we store the updated at, check it at the beginning
        // if the image is found we can pass it the image key and avoid
        // redoing that work
        // @todo
        
        
#else
        
        NSData *imageData = UIImagePNGRepresentation(threadImage);


        NSError *error = nil;
        if (![fileManager removeItemAtPath:[cachedImageURL path] error:&error]) {
            NSLog(@"fail removing cached image tile %@", error);
        }
        [imageData writeToURL:cachedImageURL atomically:NO];
//    if (![modelAsset objectForKey:@"showUnread"]) {
//        [modelAsset setObject:[NSNumber numberWithBool:NO] forKey:@"showUnread"];
//    }

        NSString *filePathString = [cachedImageURL path];
        if ([fileManager fileExistsAtPath:filePathString]) {
            //NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];

            NSDictionary* attr = @{NSFileModificationDate: [thread updatedAt]};

            NSError *aModificationError = nil;
            
            BOOL success = [fileManager setAttributes:attr ofItemAtPath:filePathString error:&aModificationError];
            if (!success) {
                NSLog(@"saving mod date error: %@", error);             }
        }
#endif
        //[modelAsset setObject:threadImage forKey:@"main_image"];
        if (cachedImageURL) {
            [modelAsset setObject:cachedImageURL forKey:@"main_image_url"];
        }
        [modelAsset setObject:[NSValue valueWithCGSize:CGSizeMake(imageSize, imageSize)] forKey:@"image_size"];
        //[modelAsset setObject:[NSNumber numberWithUnsignedInteger:sortedActivityCount] forKey:@"image_count"];
        NSUInteger scrollWidth = (sortedActivityCount * (imageSize + imagePadding)) + (imagePadding + imageSize);
        if ([sortedImageData count] > 25) {
            scrollWidth += (imagePadding + imageSize);
            
            //NSDictionary *dict = @{@"key":@"loadMore"};
            //[sortedImageData setObject:dict forKey:[NSIndexPath indexPathForRow:0 inSection:27]];
        }
        
        
        if (scrollWidth < titleRect.size.width) {
#if CGFLOAT_IS_DOUBLE
            [modelAsset setObject:[NSNumber numberWithDouble:titleRect.size.width] forKey:@"scroll_width"];
#else
            [modelAsset setObject:[NSNumber numberWithFloat:titleRect.size.width] forKey:@"scroll_width"];
#endif
        } else {
        
            [modelAsset setObject:[NSNumber numberWithUnsignedInteger:scrollWidth] forKey:@"scroll_width"];

        }
        if (CGFLOAT_IS_DOUBLE) {
            [modelAsset setObject:[NSNumber numberWithDouble:textXInset] forKey:@"text_inset"];
            //[modelAsset setObject:[NSNumber numberWithDouble:imageSize] forKey:@"image_size"];
            //[modelAsset setObject:[NSNumber numberWithDouble:imagePadding] forKey:@"image_padding"];
            //[modelAsset setObject:[NSNumber numberWithDouble:tapToSendXAndPadding] forKey:@"tap_padding"];
        } else {
            [modelAsset setObject:[NSNumber numberWithFloat:textXInset] forKey:@"text_inset"];
            //[modelAsset setObject:[NSNumber numberWithFloat:imageSize] forKey:@"image_size"];
            //[modelAsset setObject:[NSNumber numberWithFloat:imagePadding] forKey:@"image_padding"];
            //[modelAsset setObject:[NSNumber numberWithFloat:tapToSendXAndPadding] forKey:@"tap_padding"];
        }
        if (string) {
            [modelAsset setObject:string forKey:@"user_string"];
        }
            //[modelAsset setObject:userAttrs forKey:@"attrs"];
        if (string) {
            [modelAsset setObject:string forKey:@"attr_string"];
        }
            //[modelAsset setObject:sortedProfilePics forKey:@"sorted_pics"];
        if (sortedImageData) {
            [modelAsset setObject:sortedImageData forKey:@"sorted_data"];
        }
        if (threadId) {
            [modelAsset setObject:threadId forKey:@"threadId"];
        }
            //[modelAsset setObject:sortedImageUrls forKey:@"sorted_urls"];
        //[modelAsset setObject:sortedUsers forKey:@"sorted_users"];
        //[modelAsset setObject:sortedImageViews forKey:@"activity_images"];
        //[modelAsset setObject:usersLabelString forKey:@"users_label"];
        //[modelAsset setObject:imageViews forKey:@"activity_image"];
        //[modelAsset setObject:threadId forKey:@"threadId"];
        //[modelAsset setObject:usersLabelString forKey:@"users_string"];
    [self.sortedAssets setObject:modelAsset forKey:threadId];
    }
}

- (NSString*)requestConcatenateStringObjects:(NSArray*)array {
    if ([array count] == 1) {
        return [array firstObject];
    } else {
        return [array componentsJoinedByString:@","];
    }
}

- (NSString*)concatenateStringObjects:(NSArray*)array {
    if ([array count] == 1) {
        return [array firstObject];
    } else {
        return [array componentsJoinedByString:@", "];
    }
}

- (NSString*)trimVideoDurationString:(NSString*)duration {
    NSString *lengthItem = duration;
    if ([lengthItem respondsToSelector:@selector(length)] && [lengthItem length] > 0) {
        NSArray *lengthString = [lengthItem componentsSeparatedByString:@"= "];
        if ([lengthString count] > 0) {
            NSArray *trimString = [[lengthString lastObject] componentsSeparatedByString:@"."];
            if ([trimString count] > 0) {
                return [[trimString firstObject] stringByAppendingString:@"s"];
            }
        }
    }
    return @"1s";
}

- (NSMutableArray*)sortedActivitiesOfThread:(NSString*)threadId {
    NSMutableArray *threadActivities = [self.modelActivities objectForKey:threadId];
    if (!threadActivities) {
        [self makeDictionaryWithThreadsToActivites];
    }
    threadActivities = [self.modelActivities objectForKey:threadId];

    NSMutableArray *sortedActivities = [self.sortedActivities objectForKey:threadId];
    if (threadActivities && !sortedActivities) {
        [self sortActivitiesOfThread:threadId];
    }
    return [self.sortedActivities objectForKey:threadId];
}

#pragma mark - Master View Controller

- (NSInteger)masterViewControllerRowCount {
    return [self.threads count];
}

- (PFObject*)masterViewControllerThreadAtIndexPath:(NSIndexPath*)indexPath {
    PFObject *thread = nil;
    if (indexPath.section < self.threads.count) {
        thread = [self.threads objectAtIndex:indexPath.section];
    }
    return thread;
}

- (void)masterViewControllerDeleteItemAtIndexPathRequested:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:GVDeleteWillDeleteThreadNotification object:nil];
    PFObject *thread = [self.threads objectAtIndex:indexPath.section];
    [thread removeObject:[PFUser currentUser] forKey:kGVThreadUsersKey];
    self.saving = YES;

    if (!self.deletingThreads) {
        self.deletingThreads = [NSMutableDictionary dictionaryWithCapacity:1];
    }

    [self.deletingThreads setObject:thread forKey:indexPath];
    NSMutableArray *threads = [NSMutableArray arrayWithArray:self.threads];
    [threads removeObjectAtIndex:indexPath.section];
    self.threads = [NSArray arrayWithArray:threads];


    @weakify(self);
    [thread saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        @strongify(self);
        self.saving = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:GVDeleteDidDeleteThreadNotification object:nil];
        if (succeded) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                @strongify(self);
//#if MANUAL_DELETE
                [self.deletingThreads removeObjectForKey:indexPath];
                //[self notifyMasterViewController];
                NSIndexSet *deleteSet = [NSIndexSet indexSetWithIndex:indexPath.section];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    UITableView *tableView = [[self masterViewController] tableView];
                    NSUInteger numOfSections = [tableView numberOfSections];
                    if (indexPath.section < numOfSections) {
                        GVMasterTableViewCell *cell = (GVMasterTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                        
                        if ([cell.threadId isEqualToString:[thread objectId]]) {
                            [tableView beginUpdates];
                            [tableView deleteSections:deleteSet withRowAnimation:UITableViewRowAnimationAutomatic];
                            [tableView endUpdates];
                            if (numOfSections < 2) {
                                [tableView reloadData];
                            }
                        }
                        //[self notifyMasterViewController];
//#else
                    }
                    NSString *threadId = [thread objectId];
                    if (threadId) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerPullUpNotification object:nil userInfo:@{@"threadId": threadId, @"clearSelection": [NSNumber numberWithBool:YES]}];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
//#endif
                });
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"there was an error removing you as the a user: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thread Deletion Error" message:@"There was an error deleting you from the thread. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];

            });
        }
    }];
}

- (void)masterViewControllerDeleteItemAtIndexPath:(NSIndexPath*)indexPath {
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    @weakify(blockOperation);
    @weakify(self);
    [blockOperation addExecutionBlock:^{
        
        if ([blockOperation_weak_ isCancelled]) {
            return;
        }
        
        @strongify(self);
        [self.deleteOperations cancelAllOperations];
        self.deleteOperations = nil;
        
        NSBlockOperation *op = [[NSBlockOperation alloc] init];
        [op addExecutionBlock:^{
            @strongify(self);
            [self masterViewControllerDeleteItemAtIndexPathRequested:indexPath];
        }];
        NSDictionary *info = @{@"op": op};
        [[NSNotificationCenter defaultCenter] postNotificationName:GVInternetRequestNotification object:nil userInfo:info];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            self.deleteOperations = [NSOperationQueue new];
            self.deleteOperations.maxConcurrentOperationCount = 1;
        });
    }];
    [self.deleteOperations addOperations:@[blockOperation] waitUntilFinished:YES];
}

- (BOOL)masterViewControllerContainsDataAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        PFObject *thread = [self masterViewControllerThreadAtIndexPath:indexPath];
        NSString *threadId = [thread objectId];
        
        NSArray *sortedKeys = nil;
        @try {
            sortedKeys = [self.sortedAssets allKeys];
        }
        @catch (NSException *exception) {
            //NSLog(@"exception raised must've been f'd %@", exception);
            DLogException(exception);
        }
        @finally {
            
        }
        
        if (threadId && ![threadId isKindOfClass:[NSNull class]] && [sortedKeys count] > 0 && [sortedKeys containsObject:threadId]) {
            return YES;
        }
    }
    return NO;
}

- (NSDictionary*)masterViewControllerDataAtIndexPath:(NSIndexPath*)indexPath {
    @autoreleasepool {
        DLogObject([DLog NSIndexPath:indexPath]);
        PFObject *thread = [self masterViewControllerThreadAtIndexPath:indexPath];
        NSString *threadId = [thread objectId];

        NSMutableArray *sortedActivities = [self.sortedActivities objectForKey:threadId];
        if (!sortedActivities) {
            [self sortedActivitiesOfThread:threadId];
        }
        sortedActivities = [self.sortedActivities objectForKey:threadId];

//        if ([sortedActivities count] > 0) {

            NSDictionary *threadAssets = [self.sortedAssets objectForKey:threadId];
            if (!threadAssets) {
                [self makeDictionaryOfThreadAssetsWithThread:thread];
            }

            threadAssets = [self.sortedAssets objectForKey:threadId];
            return threadAssets;
//        } else {
//            [self.sortedAssets setObject:[NSDictionary dictionary] forKey:threadId];
//            return [self.sortedAssets objectForKey:threadId];
//        }
    }

}

- (NSArray*)masterSendingHeaderInfo:(NSIndexPath*)indexPath {
    PFObject *thread = [self masterViewControllerThreadAtIndexPath:indexPath];
    NSString *threadId = [thread objectId];
    //NSMutableDictionary *modelAsset = [NSMutableDictionary dictionaryWithCapacity:5];

    NSArray *sortedActivities = [self.sortedActivities objectForKey:threadId];

    // need to go through and get unique names and user profile pics


    NSMutableArray *headerInfo = [NSMutableArray arrayWithCapacity:1];

    NSArray *threadObjectIds = [thread objectForKey:kGVThreadUsersKey];

    //for (NSString* object)

    NSUInteger userCount = [threadObjectIds count];

    [sortedActivities enumerateObjectsUsingBlock:^(PFObject *activity, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {


            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];

            PFUser *actUser = [activity objectForKey:kGVActivityUserKey];
            NSString *username = [actUser username];
            NSString *videoThumbUrl = username;

            BOOL existing = NO;
            for (NSDictionary *existingInfo in headerInfo) {
                NSString *aUsername = [existingInfo objectForKey:@"username"];
                if ([aUsername isEqualToString:username]) {
                    // already used
                    existing = YES;
                }
            }

            if (existing) {
                return;
            }

            if ([username isEqualToString:[[PFUser currentUser] username]]) {
                return;
            }

            if ([headerInfo count] > userCount) {
                *stop = YES;
            }

            UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            usernameLabel.text = username;


            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            imageView.layer.shouldRasterize = YES;
            imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            imageView.layer.opaque = YES;
            imageView.layer.backgroundColor = [UIColor whiteColor].CGColor;
            //imageView.layer.borderColor = [UIColor colorWithWhite:0.996 alpha:1.000].CGColor;
            imageView.layer.borderWidth = 0.0;
            imageView.opaque = YES;
            imageView.backgroundColor = [UIColor whiteColor];
            @weakify(imageView);
            //NSString *username = [[PFUser currentUser] objectForKey:@"username"];
            //self.usernameLabel.text = username;
            @weakify(self);
            //[[GVCache sharedCache] setAttributesForImageView:imageView url:videoThumbUrl];
            [GVTwitterAuthUtility shouldGetProfileImageForAnyUser:username block:^(NSURL *imageURL, NSURL *bannerURL, NSString *realName) {

                //dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                usernameLabel.text = realName;
                //[usernameLabel setNeedsLayout];
                //[usernameLabel layoutIfNeeded];
                [imageView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //@strongify(self);
                        UIImageView *imageViewW = imageView_weak_;
                        imageViewW.contentMode = UIViewContentModeScaleAspectFill;
                        imageViewW.alpha = 1;
                        CGAffineTransform imageViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                        imageViewTransform = CGAffineTransformRotate(imageViewTransform, DEGREES_TO_RADIANS(0));

                        //CGAffineTransform initialViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                        //imageViewW.transform = CGAffineTransformRotate(initialViewTransform, DEGREES_TO_RADIANS(-90));
                        //imageViewW.layer.cornerRadius = 20;
                        //imageViewW.clipsToBounds = NO;
                        imageViewW.layer.opaque = YES;
                        imageViewW.layer.backgroundColor = [UIColor whiteColor].CGColor;
                        imageViewW.opaque = YES;
                        imageViewW.backgroundColor = [UIColor whiteColor];
                        //if (cacheType == SDImageCacheTypeNone || cacheType == SDImageCacheTypeDisk || cacheType == SDImageCacheTypeMemory) {
                        if (cacheType == SDImageCacheTypeNone) {
                            [UIView animateWithDuration:0.6
                                                  delay:0.0
                                 usingSpringWithDamping:0.6
                                  initialSpringVelocity:0.0
                                                options:UIViewAnimationOptionBeginFromCurrentState
                                             animations:^{
                                                 imageViewW.transform = imageViewTransform;
                                             } completion:nil];
                        } else {
                            imageViewW.transform = imageViewTransform;
                        }
                    });
                }];
            }];

            if (username) {
                [dict setObject:username forKey:@"username"];
            } else {
                [dict setObject:@"Waiting on recipients..." forKey:@"username"];
            }
            [dict setObject:imageView forKey:@"imageView"];
            [dict setObject:usernameLabel forKey:@"usernameLabel"];

            [headerInfo addObject:dict];
        }

    }];
    return headerInfo;
}

#pragma mark - Thread View Controller

- (NSInteger)threadViewControllerRowCount:(NSString*)threadId {
    NSArray *threadKeys = nil;
    @try {
        threadKeys = [[self.threadActivities objectForKey:threadId] allKeys];
    }
    @catch (NSException *exception) {
        DLogException(exception);
    }
    @finally {
        
    }
    if ([threadKeys respondsToSelector:@selector(count)]) {
        return [threadKeys count];
    }
}

- (NSArray*)threadViewControllerDataAtIndexPath:(NSIndexPath*)indexPath thread:(NSString*)threadId {
    @autoreleasepool {

        NSDictionary *sortedActivities = [self.threadActivities objectForKey:threadId];
        if (!sortedActivities) {
            // sort all the data by sends -> reactions

            NSArray *activities = [self sortedActivitiesOfThread:threadId];
            NSMutableDictionary *threadActivity = [NSMutableDictionary dictionaryWithCapacity:1];

            NSInteger __block count = 0;
            @weakify(self);
            NSSortOptions sortOptions;
#if MAIL_STYLE
            sortOptions = 0;
#else
            sortOptions = NSEnumerationReverse;
#endif
            [activities enumerateObjectsWithOptions:sortOptions usingBlock:^(PFObject *activity, NSUInteger index, BOOL *stop) {
                @autoreleasepool {
                    @strongify(self);
                    //NSMutableDictionary *activityModel = [NSMutableDictionary dictionaryWithCapacity:1];
                    if ([[activity objectForKey:kGVActivityTypeKey] isEqualToString:kGVActivityTypeSendKey]) {
                        // let's start a branch for every one
                        //NSInteger sortedThreadIndex = [sortedActivities indexOfObject:activity];
                        //NSMutableArray *sortedThreadActivities = [NSMutableArray arrayWithCapacity:10];
                        //[sortedThreadActivities addObject:activity];
                        
                        [threadActivity setObject:activity forKey:[NSIndexPath indexPathForItem:count inSection:0]];
                        count++;
                    } else {
                        // we have to link it back somehow in order

                        //[threadActivity removeObjectAtIndex:index];
                        NSString *reactionOriginalActivityId = [[activity objectForKey:kGVActivityReactionOriginalSendKey] objectId];
                        NSMutableArray *reactionOriginals = [self.modelReactions objectForKey:reactionOriginalActivityId];
                        if (!reactionOriginals) {
                            reactionOriginals = [NSMutableArray arrayWithCapacity:1];
                        }
                        [reactionOriginals addObject:activity];
                        [self.modelReactions setObject:reactionOriginals forKey:reactionOriginalActivityId];
                    }
                    NSMutableArray *removeKeys = [NSMutableArray arrayWithCapacity:0];
                    [self.uploadingActivities enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
                        @autoreleasepool {
                            PFObject *uploadingActivity = [obj objectForKey:@"activity"];
                            if ([[activity objectId] isEqualToString:[uploadingActivity objectId]]) {
                                [removeKeys addObject:key];
                            }
                        }
                    }];
                    [self.uploadingActivities removeObjectsForKeys:removeKeys];
                }
            }];

            [self.threadActivities setObject:threadActivity forKey:threadId];
        }
        sortedActivities = [self.threadActivities objectForKey:threadId];
        if (!indexPath) {
            @weakify(self);
            // we're preloading and we should alert the thread vc if it loads early
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self);
                [self notifyThreadViewController];
            });
        }
        if (indexPath) {
            PFObject *sendActivity = [sortedActivities objectForKey:[NSIndexPath indexPathForItem:indexPath.section inSection:0]];

            NSArray *reactionsSorted = [self.sortedReactions objectForKey:[sendActivity objectId]];
            if (!reactionsSorted) {
                NSArray *reactions = [self.modelReactions objectForKey:[sendActivity objectId]];

                NSMutableDictionary *reactionAsset = [NSMutableDictionary dictionaryWithCapacity:1];

                NSDateFormatterStyle dateStyle = NSDateFormatterNoStyle;
                NSDateFormatterStyle timeStyle = NSDateFormatterShortStyle;
                NSDate *activityCreatedAt = [sendActivity createdAt];
                if ([NSDate daysBetweenDate:activityCreatedAt andDate:[NSDate date]] > 0) {
                    dateStyle = NSDateFormatterMediumStyle;
                    timeStyle = NSDateFormatterShortStyle;
                }

                NSString *timeLabel = [NSDateFormatter localizedStringFromDate:activityCreatedAt dateStyle:dateStyle timeStyle:timeStyle];
                [reactionAsset setObject:timeLabel forKey:@"activity_time"];

                if ([reactions count] > 0) {
                    reactionsSorted = [reactions sortedArrayUsingComparator:^(id obj1, id obj2) {
                        return [[obj1 createdAt] compare:[obj2 createdAt]];
                    }];
                    [reactionAsset setObject:reactionsSorted forKey:@"reactionsSorted"];
                }
                [self.sortedReactions setObject:reactionAsset forKey:[sendActivity objectId]];
            }
            reactionsSorted = [self.sortedReactions objectForKey:[sendActivity objectId]];
            if (reactionsSorted) {
                return @[sendActivity, reactionsSorted];
            } else {
                return @[sendActivity];
            }
        }
        return nil;
    }
}
- (void)threadViewControllerDidSelectItemAtIndexPath:(NSIndexPath*)indexPath thread:(NSString*)threadId {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [TestFlight passCheckpoint:@"Select Item Action"];
        @strongify(self);
        NSArray *data = [self threadViewControllerDataAtIndexPath:indexPath thread:threadId];
        PFObject *activity;
        if ([data count] > 0) {
            activity = data[0];
        }
        NSArray *results = [self threadReactionShouldRecordAtIndexPath:indexPath thread:threadId];
        BOOL shouldRecord = [[results objectAtIndex:0] boolValue];
        NSString *url = [results objectAtIndex:1];
        if (shouldRecord) {
            // @TODO check reachability
            //[self startRecordingReaction:url indexPath:indexPath];
            NSString *activityObjectId = [activity objectId];
            NSDictionary *dict = nil;
            if (activityObjectId) {
                dict = @{@"URL": url, @"threadId": threadId, @"activityId": [activity objectId]};
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GVReactionVideoNotification object:nil userInfo:dict];
        } else {
            // just play the damn video
            NSDictionary *dict = @{@"URL": url};
            [[NSNotificationCenter defaultCenter] postNotificationName:GVPlayMovieNotification object:nil userInfo:dict];
        }
    });
}

#pragma mark - Reactions View Controller

- (NSInteger)reactionsViewControllerRowCount:(NSString*)threadId threadIndexPath:(NSIndexPath*)indexPath {
    NSArray *threadResults = [self threadViewControllerDataAtIndexPath:indexPath thread:threadId];
    if ([threadResults count] > 1) {
        return [[threadResults objectAtIndex:1][@"reactionsSorted"] count];
    }
    return 0;
}

- (PFObject*)reactionsViewControllerDataAtIndexPath:(NSIndexPath*)indexPath thread:(NSString*)threadId threadIndexPath:(NSIndexPath*)threadIndexPath {
    NSLog(@"collection View index Path: %@", indexPath);
    NSArray *results = [self threadViewControllerDataAtIndexPath:threadIndexPath thread:threadId];
    NSArray *objects;
    if ([results count] > 1) {
        objects = [results objectAtIndex:1][@"reactionsSorted"];
        return [objects objectAtIndex:indexPath.row];
    }
    return nil;
}

#pragma mark - Uploading

- (void)videoSendNotification:(NSNotification*)notif {
    NSDictionary *dict = [notif userInfo];
    if (dict) {
        NSString *threadID = [dict objectForKey:@"threadId"];
        NSString *videoPath = dict[@"videoPath"];
        if (threadID) {
            [self threadViewControllerNewSend:videoPath thread:threadID];
        } else {
            [self masterViewControllerNewThreadWithVideoPath:videoPath];
        }
    }
}

- (void)successfullyInstalledNotification:(NSNotification*)notif {
    
    
    [GVTwitterAuthUtility shouldGetProfileImageForCurrentUserBlock:^(NSURL *url, NSURL *bannerURL, NSString *realName) {
        // let's hope we get it here
        PFUser *cUser = [PFUser currentUser];
        [cUser setObject:realName forKey:kGVUserRealNameKey];
        [cUser saveInBackground];
    }];
}

- (void)modelDidFinishPlayingVideo:(PFObject*)activity {
    self.saving = YES;
    
    @weakify(self);
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        @strongify(self);
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [activity addUniqueObjectsFromArray:@[[PFUser currentUser]] forKey:kGVActivityReadKey];
    
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.saving = YES;
        if (succeeded) {
            @strongify(self);
            self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
            // here we should refresh the interface manually...
            DLogObject(activity);
            [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
        } else {
            [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    @strongify(self);
                    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
                    // again here..all this error handling needs to be stronger
                    // and more reliable, 
                } else {
                    // try again later
                }
            }];
        }
    }];
}

- (void)masterViewControllerNewThreadWithVideoPathReceived:(NSString *)videoPath {
    @weakify(self);
    [[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadSaveNotification object:nil];
    self.saving = YES;

    PFObject *thread = [GVParseObjectUtility createNewThreadWithCreator:[PFUser currentUser]];

    //[self.uploadingThreads setObject:thread forKey:[thread objectId]];

    NSLog(@"new share objectId: %@", thread.objectId);


    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        @strongify(self);
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];


    [thread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSLog(@"thread objectId: %@", thread.objectId);
                @strongify(self);
                NSURL *threadURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://gvideoapp.com/t/%@", thread.objectId, nil]];

                [[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadDidSaveNotification object:nil userInfo:@{@"threadURL": threadURL}];

                //[[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];

                NSArray *results = [GVParseObjectUtility createNewActivitySendWithUser:[PFUser currentUser] thread:thread videoPathAndImage:videoPath];
                //NSArray *results = [GVParseObjectUtility createNewActivitySendWithUser:[PFUser currentUser] thread:thread videoPath:videoPath];

                PFObject *activity;
                if ([results count] > 0) {
                    activity = results[0];
                }

                [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    @strongify(self);
                    self.saving = NO;
                    if (succeeded) {
                        // refresh the master view controller here


                        NSMutableArray *threads = [NSMutableArray arrayWithArray:self.threads];
                        [threads insertObject:thread atIndex:0];
                        self.threads = [NSArray arrayWithArray:threads];

                        NSMutableArray *activities = [NSMutableArray arrayWithArray:self.activities];
                        [activities insertObject:activity atIndex:0];
                        self.activities = [NSArray arrayWithArray:activities];

                        //[self resetInternalModel];

                        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        //  @strongify(self);

                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            //[[self.masterViewController tableView] insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            NSIndexSet *sectionSet = [[NSIndexSet alloc] initWithIndex:0];
                            [[self.masterViewController tableView] insertSections:sectionSet withRowAnimation:UITableViewRowAnimationAutomatic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil userInfo:nil];
                        [self scrollMasterTableToSection:0];
                        //[[self.masterViewController tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

                        //});

                        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        //[[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
                        //});




                        NSLog(@"succcess saving the activity %@", activity);
                        //                                    [thread setObject:activity forKey:kGVThreadLastActivityKey];
                        //                                    [thread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        //                                        NSLog(@"success saving the thread lastactivitykey");
                        //                                        [[UIApplication sharedApplication] endBackgroundTask:self_weak_.fileUploadBackgroundTaskId];
                        //                                        [self_weak_.uploadingShares removeObject:thread];
                        //                                    }];
                    } else {
                        NSLog(@" there was an error saving the activity %@", error);
                        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
                    }
                }];

                //[MBProgressHUD hideHUDForView:self.view.superview animated:YES];
                //
                //                activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
                //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                //                        if (completed) {
                //                            NSLog(@"activity type: %@", activityType);
                //                            // if the link was sent we wanna start uploading and link the share back to the video
                //
                //
                //
                //                            //                            PFFile *video = [activity objectForKey:kGVActivityVideoKey];
                //                            //                            PFFile *videoThumbnail = [activity objectForKey:kGVActivityVideoThumbnailKey];
                //                            //                            //PFObject *activity = [thread objectForKey:kGVThreadLastActivityKey];
                //                            //
                //                            //
                //                            //                            NSParameterAssert(video != nil);
                //                            //                            NSParameterAssert(videoThumbnail != nil);
                //                            //
                //                            //
                //                            //
                //                            //                            [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //                            //                                if (succeeded) {
                //                            //                                    [videoThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //                            //                                        if (succeeded) {
                //                            //                                            [thread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //                            //                                                [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //                            //                                                    if (succeeded) {
                //                            //                                                        [[UIApplication sharedApplication] endBackgroundTask:self_weak_.fileUploadBackgroundTaskId];
                //                            //                                                        [self_weak_.uploadingShares removeObject:thread];
                //                            //                                                    }
                //                            //                                                }];
                //                            //                                            }];
                //                            //                                        } else {
                //                            //                                            [[UIApplication sharedApplication] endBackgroundTask:self_weak_.fileUploadBackgroundTaskId];
                //                            //                                        }
                //                            //                                    }];
                //                            //                                } else {
                //                            //                                    [[UIApplication sharedApplication] endBackgroundTask:self_weak_.fileUploadBackgroundTaskId];
                //                            //                                }
                //                            //                            }];
                //                        } else {
                //                            // delete the share
                //                            //[thread deleteEventually];
                //                        }
                //                    });
                //
                //                };
                //[self.videoBlockOperation addExecutionBlock:^{
                //[self.masterViewController didAttemptToSaveVideo];
                //}];
                
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self writeVideoToCameraRoll:[NSURL URLWithString:videoPath]];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Thread Error" message:@"There was an error saving the new thread. Try Again, your video has been saved in the Camera Roll." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
                [alertView show];
            });
        }
    }];
}


- (void)masterViewControllerNewThreadWithVideoPath:(NSString*)videoPath {
    @weakify(self);
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    [op addExecutionBlock:^{
        @strongify(self);
        [self masterViewControllerNewThreadWithVideoPathReceived:videoPath];
    }];
    NSBlockOperation *err = [NSBlockOperation new];
    [err addExecutionBlock:^{
        @strongify(self);
        [self writeVideoToCameraRoll:[NSURL URLWithString:videoPath]];
    }];
    NSDictionary *info = @{@"op": op, @"err": err};
    [[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadRequestNotification object:nil userInfo:info];
}

- (void)threadViewControllerNewSend:(NSString*)videoPath thread:(NSString*)threadId {
    //
    //        NSError *attributesError;
    //        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:&attributesError];
    //
    //        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];

    // format fileSize to MB
    //unsigned long long int fileSize = 0;
    //fileSize += [fileSizeNumber intValue];
    //NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];

    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self_weak_.progressHUD hide:YES];
//    });

    // now we have to add another bubble, animate it in with a spring
    // use the progress circle indicator with this activity save
    // when it's done we have to maintain state

    NSArray *results;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.activities count] inSection:0];

    PFObject *thread;
    for (PFObject *obj in self.threads) {
        if ([[obj objectId] isEqualToString:threadId]) {
            thread = obj;
            continue;
        }
    }

[[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadSaveNotification object:nil];

    results = [GVParseObjectUtility createNewActivitySendWithUser:[PFUser currentUser] thread:thread videoPathAndImage:videoPath];
    PFObject *activity = [results objectAtIndex:0];
    UIImage *thumbnail = [results objectAtIndex:1];
    PFFile *video = [results objectAtIndex:2];
//    if (!self.uploadingActivities) {
//        self.uploadingActivities = [NSMutableDictionary dictionaryWithCapacity:1];
//    }
//    NSDictionary *activityDict = @{@"activity":activity,
//                                   @"thumb":thumbnail};
//    [self.uploadingActivities setObject:activityDict forKey:indexPath];
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
//    } completion:^(BOOL finished) {
//        if (finished) {
//            [self setScrollViewOffsetToBottom];
//        }
//    }];

    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self_weak_.fileUploadBackgroundTaskId];
    }];

//    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//
//        } else {
//
//        }
//    } progressBlock:^(int percentDone) {
//
//    }];
#if !MAIL_STYLE
    if ([self.threadViewController respondsToSelector:@selector(setShouldScrollToBottomOffsetDelayed:)]) {
        [self.threadViewController setShouldScrollToBottomOffsetDelayed:YES];
    }
#endif

    self.saving = YES;
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.saving = NO;
        if (succeeded) {
            @strongify(self);
            NSLog(@"succcess saving the activity %@", activity);
            [[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadDidSaveNotification object:nil userInfo:nil];

            UITableView *tableView = [self.masterViewController tableView];


            self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;

            [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
            [self scrollMasterTableToSection:0];
            //[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];


            return;


            PFObject *thisThread = [activity objectForKey:kGVActivityThreadKey];
            NSMutableArray *newThreads = [NSMutableArray arrayWithArray:self.threads];
            NSMutableArray *newThreadIds = [NSMutableArray arrayWithCapacity:1];
            //NSMutableArray *oldThreadIds = [NSMutableArray arrayWithCapacity:[s]]


            NSInteger oldPath = [[NSNumber numberWithUnsignedInteger:[newThreads indexOfObject:thisThread]] integerValue];
            [newThreads removeObject:thisThread];
            [newThreads insertObject:thisThread atIndex:0];
            self.threads = [NSArray arrayWithArray:newThreads];

            NSMutableArray *newActs = [NSMutableArray arrayWithArray:self.activities];
            [newActs insertObject:activity atIndex:0];
            self.activities = [NSArray arrayWithArray:newActs];

            [self resetInternalModel];

            //dispatch_async(dispatch_get_main_queue(), ^{
            [tableView moveSection:oldPath toSection:0];
            [self scrollMasterTableToSection:0];
            //[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];


//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//[[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
//            });


//            self.shouldReloadUsingNetwork = YES;
//#if CPF_COLLECTION
//            [self performQuery];
//#else
//            //[self refreshData:nil];
//#endif
//            [self.uploadingActivities removeObjectForKey:indexPath];
//            if (!self.loadingActivities) {
//                self.loadingActivities = [NSMutableDictionary dictionaryWithCapacity:1];
//            }
//            [self.loadingActivities setObject:activityDict forKey:indexPath];
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
//
//            NSLog(@"activity detailItem %@", self.detailItem);


            //                [self.detailItem setObject:activity forKey:kGVThreadLastActivityKey];
            //
            //                [self.detailItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //                    if (!error) {



            //                    } else {
            //                        NSLog(@" error :%@", error);
            //                    }
            //}];
        } else {
            // we can recreate this by setting the video length to 45, and using a video that's
            // shorter than 45 seconds but larger in file size to create an error for a retry
            // use the push up video
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self writeVideoToCameraRoll:[NSURL URLWithString:videoPath]];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Thread Error" message:@"There was an error saving the new activity. Try Again, your video has been saved in the Camera Roll." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            });
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@" there was an error saving the activity %@", error);
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saving Activity Error" message:@"There was an error saving the latest activity. Sorry this doesn't happen often, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                [alertView show];
//            });
            //                [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //                    if (succeeded) {
            //
            //                    } else {
            //                        [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //                            if (succeeded) {
            //
            //                            } else {
            //                                [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //                                    if (succeeded) {
            //
            //                                    } else {
            //                                        NSLog(@" seriously wtf");
            //                                    }
            //                                }];
            //                            }
            //                        }];
            //                    }
            //                }];
        }
    }];
}

- (void)reactionCameraVideoSaveNotification:(NSNotification*)notif {
    NSDictionary *info = [notif userInfo];
    NSString *threadId = info[@"threadId"];
    NSString *activityId = info[@"activityId"];
    NSString *outputPath = info[@"outputPath"];

    // reactions are special... we can't just give an error
    // we have to save it and save metadata to restore to upload later
    // without asking user...
    // it would be best to save it somewhere and somehow load it into the dataset
    // until it is successfully uploaded
    // we can check on app startup and reachability i guess...
    // let's handle this with a lot of care
    PFObject *originalActivity;
    for (PFObject *act in self.activities) {
        if ([[act objectId] isEqualToString:activityId]) {
            originalActivity = act;
            continue;
        }
    }

    //
    //        NSError *attributesError;
    //        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:&attributesError];
    //
    //        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];

    // format fileSize to MB
    //unsigned long long int fileSize = 0;
    //fileSize += [fileSizeNumber intValue];
    //NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];

    //        @weakify(self);
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self_weak_.progressHUD hide:YES];
    //        });

    // now we have to add another bubble, animate it in with a spring
    // use the progress circle indicator with this activity save
    // when it's done we have to maintain state

    @weakify(self);
    NSArray *results;
    //NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.activities count] inSection:0];

    PFObject *thread;
    for (PFObject *obj in self.threads) {
        if ([[obj objectId] isEqualToString:threadId]) {
            thread = obj;
            continue;
        }
    }


//    NSArray *data = [self threadViewControllerDataAtIndexPath:indexPath thread:[thread objectId]];
//    PFObject *originalActivity;
//    if ([data count] > 0) {
//        originalActivity = [data objectAtIndex:0];
//    }


    results = [GVParseObjectUtility createNewActivitySendWithUser:[PFUser currentUser] thread:thread videoPathAndImage:outputPath];
    PFObject *activity = [results objectAtIndex:0];
    UIImage *thumbnail = [results objectAtIndex:1];
    NSString *videoPath = [results objectAtIndex:2];
    if (!self.uploadingActivities) {
        self.uploadingActivities = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    //
    [activity setObject:kGVActivityTypeReactionKey forKey:kGVActivityTypeKey];
    [activity setObject:originalActivity forKey:kGVActivityReactionOriginalSendKey];
    // where server side we update the original send... i guess
    // have to add the users to the reaction group

    NSDictionary *activityDict = @{@"activity":activity, @"thumb":thumbnail, @"path": videoPath};
    [self.uploadingActivities setObject:activityDict forKey:activityId];
    //    [self.collectionView performBatchUpdates:^{
    //        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    //    } completion:^(BOOL finished) {
    //        if (finished) {
    //            [self setScrollViewOffsetToBottom];
    //        }
    //    }];

    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self_weak_.fileUploadBackgroundTaskId];
    }];

    self.saving = YES;
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.saving = NO;
        if (succeeded) {
            NSLog(@"succcess saving the activity %@", activity);

            //            [self.uploadingActivities removeObjectForKey:indexPath];
            //            if (!self.loadingActivities) {
            //                self.loadingActivities = [NSMutableDictionary dictionaryWithCapacity:1];
            //            }
            //            [self.loadingActivities setObject:activityDict forKey:indexPath];



            [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
            [self scrollMasterTableToSection:0];
            //[[self.masterViewController tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

            self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;

        } else {

            NSLog(@" there was an error saving the activity %@", error);

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saving Activity Error" message:@"There was an error saving the latest activity. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];

            // FUCK we have to save the video...
            // and try again later... the fuck
            self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
            [[NSNotificationCenter defaultCenter] postNotificationName:GVRefreshDataNotification object:nil];
        }
    }];
}

//- (void)threadReactionWithVideoPath:(NSString*)reactionPath thread:(NSString*)threadId indexPath:(NSIndexPath *)indexPath {
//
//}

#pragma mark - Reaction Detection methods

- (NSString*)urlForActivity:(PFObject*)activity {
    PFFile *video = [activity objectForKey:kGVActivityVideoKey];
    NSString *url;
    if ([video respondsToSelector:@selector(url)]) {
        url = [video url];
    }
    if (![url respondsToSelector:@selector(length)] || !([url length] > 0)) {
        return @"";
    }
    return url;
}

- (BOOL)threadShouldShowUnreadWithActivity:(PFObject*)activity {
    NSParameterAssert(activity != nil);
    PFFile *video = [activity objectForKey:kGVActivityVideoKey];
    NSString *activityUserId = nil;
    NSString *url = [self urlForActivity:activity];
    PFUser *user = [activity objectForKey:kGVActivityUserKey];
    
    if (user) {
        activityUserId = [user objectId];
    }
    NSString *currentUserId = nil;
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        currentUserId = [currentUser objectId];
    }
    
    if (!url) {
        url = [NSNull null];
    }
    
    if (![activityUserId isEqualToString:currentUserId]) {
        if ([[activity objectForKey:kGVActivityTypeKey] isEqualToString:kGVActivityTypeReactionKey]) {
            NSArray *users = [activity objectForKey:kGVActivityReadKey];
            
            NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:1];
            for (PFUser *user in users) {
                if (user) {
                    [userIds addObject:[user objectId]];
                }
            }
            
            if (![userIds containsObject:currentUserId]) {
                return YES;
            }
        }
//        
//        NSArray *shouldRecordArr = [self threadShouldRecordReactionWithActivity:activity];
//        NSNumber *shouldRecordNum = nil;
//        if ([shouldRecordArr count] > 0) {
//            shouldRecordNum = [shouldRecordArr objectAtIndex:0];
//            if (![shouldRecordNum isKindOfClass:[NSNull class]]) {
//                return [shouldRecordNum boolValue];
//            }
//        }
        
    }
    return NO;
}

- (NSArray*)threadShouldRecordReactionWithActivity:(PFObject*)activity {
    PFFile *video = [activity objectForKey:kGVActivityVideoKey];
    NSString *activityUserId = [[activity objectForKey:kGVActivityUserKey] objectId];
    NSString *currentUserId = [[PFUser currentUser] objectId];
    NSString *url = [self urlForActivity:activity];
    DAssertNonNil(activity);
    
    if (!url) {
        url = [NSNull null];
    }
    
    if (![activityUserId isEqualToString:currentUserId]) {
        if ([[activity objectForKey:kGVActivityTypeKey] isEqualToString:kGVActivityTypeSendKey]) {
            NSArray *users = [activity objectForKey:kGVActivitySendReactionsKey];

            NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:1];
            for (PFUser *user in users) {
                if (user && [user respondsToSelector:@selector(objectId)]) {
                    [userIds addObject:[user objectId]];
                }
            }
            
            if (![userIds containsObject:currentUserId]) {
                return @[[NSNumber numberWithBool:YES], url];
            }
        }
    }
    return @[[NSNumber numberWithBool:NO], url];
}

- (NSArray*)threadReactionShouldRecordAtIndexPath:(NSIndexPath*)indexPath thread:(NSString*)threadId {
    NSArray *results = [self threadViewControllerDataAtIndexPath:indexPath thread:threadId];

    NSDictionary *uploadingAsset = [self.uploadingActivities objectForKey:indexPath];
    if (uploadingAsset) {
        NSArray *shouldRecord = [self threadShouldRecordReactionWithActivity:[uploadingAsset objectForKey:@"activity"]];
        if ([shouldRecord count] > 0) {
            return @[[NSNumber numberWithBool:NO], [uploadingAsset objectForKey:@"path"]];
        }
    }

    PFObject *activity;
    if ([results count] > 0) {
        activity = [results objectAtIndex:0];
        if (activity) {
            return [self threadShouldRecordReactionWithActivity:activity];
        } else {
            return nil;
        }
    }
    // is there a reaction by this user on this activity...if not create it and save
    return nil;
}

@end
