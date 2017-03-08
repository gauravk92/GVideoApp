//
//  GVParseObjectUtility.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/4/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVParseObjectUtility.h"
#import "UIImage+RoundedCornerAdditions.h"
#import "UIImage+ResizeAdditions.h"
#import "NSNumber+HumanReadableFileSize.h"


NSString *const kGVParseCreatedAtKey = @"createdAt";
NSString *const kGVParseUpdatedAtKey = @"updatedAt";

NSString *const kGVThreadClassKey = @"Thread";
NSString *const kGVThreadLastActivityKey = @"activity";
NSString *const kGVThreadUsersKey = @"users";
NSString *const kGVThreadCreatorKey = @"creator";
NSString *const kGVThreadForcedTitleKey = @"forcedTitle";

NSString *const kGVActivityClassKey = @"Activity";
NSString *const kGVActivityVideoKey = @"video";
NSString *const kGVActivityThreadKey = @"thread";
NSString *const kGVActivityTypeKey = @"type";
NSString *const kGVActivityVideoThumbnailKey = @"videoThumbnailImage";
NSString *const kGVActivityUserKey = @"user";
NSString *const kGVActivitySendReactionsKey = @"reactions";
NSString *const kGVActivityReactionOriginalSendKey = @"reactionOriginalSend";
NSString *const kGVActivityTypeSendKey = @"send";
NSString *const kGVActivityTypeReactionKey = @"reaction";
NSString *const kGVActivityVideoFileSizeKey = @"videoFileSize";
NSString *const kGVActivityVideoDurationKey = @"videoDuration";
NSString *const kGVActivityReadKey = @"reads";
NSString *const kGVActivityForcedDisplayName = @"forcedDisplayName";
NSString *const kGVActivityForcedUnreadState = @"forcedUnreadState";
NSString *const kGVActivityForcedUnrecordState = @"forcedUnrecordState";

NSString *const kGVUserClassKey = @"User";
NSString *const kGVUserNameKey = @"username";
NSString *const kGVUserRealNameKey = @"realName";
NSString *const kGVUserCameraImageKey = @"cameraImage";

NSString *const kGVInstallationUserKey = @"user";

// push notification keys

NSString *const kGVPushNotificationTypeKey = @"t";
NSString *const kGVPushNotificationThreadIdKey = @"tid";

@implementation GVParseObjectUtility


+ (PFObject*)createNewThreadWithCreator:(PFUser *)user {
    @autoreleasepool {
        PFObject *thread = [PFObject objectWithClassName:kGVThreadClassKey];
        [thread setObject:[PFUser currentUser] forKey:kGVThreadCreatorKey];
        [thread addObject:[PFUser currentUser] forKey:kGVThreadUsersKey];

        PFACL *shareACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [shareACL setPublicReadAccess:YES];
        [shareACL setPublicWriteAccess:YES];
        thread.ACL = shareACL;

        return thread;
    }
}

+ (NSArray*)createNewActivitySendWithUser:(PFUser*)user thread:(PFObject*)thread videoPathAndImage:(NSString*)videoPath {
    @autoreleasepool {

        NSError *attributesError;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:&attributesError];

        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];

        PFObject *act = [PFObject objectWithClassName:kGVActivityClassKey];
        [act setObject:[PFUser currentUser] forKey:kGVActivityUserKey];
        [act setObject:thread forKey:kGVActivityThreadKey];
        [act setObject:kGVActivityTypeSendKey forKey:kGVActivityTypeKey];
        NSString *fileSize = [fileSizeNumber humanReadableFileSize];
        if (fileSize) {
            [act setObject:fileSize forKey:kGVActivityVideoFileSizeKey];
        }

        PFACL *shareACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [shareACL setPublicReadAccess:YES];
        [shareACL setPublicWriteAccess:YES];
        act.ACL = shareACL;

        PFFile *video = [PFFile fileWithName:@"movie.mov" data:[[NSFileManager defaultManager] contentsAtPath:videoPath] contentType:@"quicktime/mov"];
        //video.ACL = shareACL;

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:videoPath] options:nil];
        AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 60);
        CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
        NSLog(@"err==%@, imageRef==%@", err, imgRef);
        NSLog(@"affine transform %@", NSStringFromCGAffineTransform([asset preferredTransform]));

        CFStringRef durationRef = CMTimeCopyDescription(NULL, asset.duration);
        NSString *durationString = (__bridge_transfer NSString*)durationRef;

        [act setObject:durationString forKey:kGVActivityVideoDurationKey];
        NSLog(@"video duration %@", durationString);

        UIImage *videoThumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];

        UIImage *resizedImage = [videoThumbnailImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];

        //    UIImageOrientation fixedOrientation;
        //    switch (thumbOrientation) {
        //        case UIInterfaceOrientationPortrait:
        //            fixedOrientation = UIImageOrientationLeft;
        //            break;
        //        case UIInterfaceOrientationPortraitUpsideDown:
        //            fixedOrientation = UIImageOrientationRight;
        //            break;
        //        case UIInterfaceOrientationLandscapeLeft:
        //            fixedOrientation = UIImageOrientationDown;
        //            break;
        //        case UIInterfaceOrientationLandscapeRight:
        //            fixedOrientation = UIImageOrientationUp;
        //            break;
        //
        //        default:
        //            break;
        //    }

        //UIImage *rotatedImage = [UIImage imageWithCGImage:[resizedImage CGImage] scale:1.0 orientation:UIImageOrientation];
        //UIImage *thumbnailImage = [resizedImage thumbnailImage:200.0f transparentBorder:0.0f cornerRadius:0 interpolationQuality:kCGInterpolationDefault];

        NSData *resizedImageData = UIImageJPEGRepresentation(resizedImage, 1.0);
        //NSData *imageData = UIImagePNGRepresentation(thumbnailImage);
        PFFile *videoThumbnail = [PFFile fileWithName:@"videoThumb.jpg" data:resizedImageData];
        [act setObject:video forKey:kGVActivityVideoKey];
        [act setObject:videoThumbnail forKey:kGVActivityVideoThumbnailKey];
        if (resizedImage) {
            return @[act, resizedImage, video, videoPath];
        }
        return @[act, [NSNull null], video, videoPath];
    }
}

//+ (PFObject*)createNewActivitySendWithUser:(PFUser*)user thread:(PFObject*)thread videoPath:(NSString*)videoPath {
//    @autoreleasepool {
//        PFObject *act = [PFObject objectWithClassName:kGVActivityClassKey];
//        [act setObject:[PFUser currentUser] forKey:kGVActivityUserKey];
//        [act setObject:thread forKey:kGVActivityThreadKey];
//        [act setObject:kGVActivityTypeSendKey forKey:kGVActivityTypeKey];
//
//        PFACL *shareACL = [PFACL ACLWithUser:[PFUser currentUser]];
//        [shareACL setPublicReadAccess:YES];
//        [shareACL setPublicWriteAccess:YES];
//        act.ACL = shareACL;
//
//        NSString *fileSize =
//        [act setObject:<#(id)#> forKey:<#(NSString *)#>]
//
//        PFFile *video = [PFFile fileWithName:@"movie.mov" data:[[NSFileManager defaultManager] contentsAtPath:videoPath] contentType:@"quicktime/mov"];
//        //video.ACL = shareACL;
//
//        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:videoPath] options:nil];
//        AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//        NSError *err = NULL;
//        CMTime time = CMTimeMake(1, 60);
//        CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
//        NSLog(@"err==%@, imageRef==%@", err, imgRef);
//        NSLog(@"affine transform %@", NSStringFromCGAffineTransform([asset preferredTransform]));
//
//        UIImage *videoThumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
//
//        UIImage *resizedImage = [videoThumbnailImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(800.0f, 800.0f) interpolationQuality:kCGInterpolationHigh];
//
//    //    UIImageOrientation fixedOrientation;
//    //    switch (thumbOrientation) {
//    //        case UIInterfaceOrientationPortrait:
//    //            fixedOrientation = UIImageOrientationLeft;
//    //            break;
//    //        case UIInterfaceOrientationPortraitUpsideDown:
//    //            fixedOrientation = UIImageOrientationRight;
//    //            break;
//    //        case UIInterfaceOrientationLandscapeLeft:
//    //            fixedOrientation = UIImageOrientationDown;
//    //            break;
//    //        case UIInterfaceOrientationLandscapeRight:
//    //            fixedOrientation = UIImageOrientationUp;
//    //            break;
//    //
//    //        default:
//    //            break;
//    //    }
//
//        //UIImage *rotatedImage = [UIImage imageWithCGImage:[resizedImage CGImage] scale:1.0 orientation:UIImageOrientation];
//        //UIImage *thumbnailImage = [resizedImage thumbnailImage:200.0f transparentBorder:0.0f cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
//
//
//        NSData *resizedImageData = UIImageJPEGRepresentation(resizedImage, 1.0);
//        //NSData *imageData = UIImagePNGRepresentation(thumbnailImage);
//        PFFile *videoThumbnail = [PFFile fileWithName:@"videoThumb.jpg" data:resizedImageData];
//        [act setObject:video forKey:kGVActivityVideoKey];
//        [act setObject:videoThumbnail forKey:kGVActivityVideoThumbnailKey];
//        return act;
//    }
//}

+ (PFObject*)createNewActivityReactionWithUser:(PFUser*)user thread:(PFObject*)thread videoPath:(NSString*)videoPath activity:(PFObject*)activity {
    NSArray *results = [GVParseObjectUtility createNewActivitySendWithUser:user thread:thread videoPathAndImage:videoPath];

    PFObject *act;
    if ([results count] > 0) {
        act = results[0];
    }

    [act setObject:kGVActivityTypeReactionKey forKey:kGVActivityTypeKey];
    [act setObject:activity forKey:kGVActivityReactionOriginalSendKey];

    return act;
}

+ (PFQuery*)queryForThreadsOfUser:(PFUser*)user {
    PFQuery *query = [PFQuery queryWithClassName:kGVThreadClassKey];
    [query whereKey:kGVThreadUsersKey containedIn:@[user]];
    
    [query includeKey:kGVParseCreatedAtKey];
    [query includeKey:kGVParseUpdatedAtKey];
    [query includeKey:kGVThreadUsersKey];
    [query includeKey:kGVThreadCreatorKey];
    [query includeKey:kGVThreadLastActivityKey];
    [query orderByDescending:kGVParseUpdatedAtKey];
    
    return query;
}

+ (PFQuery*)queryForActivitiesOfThread:(PFObject*)thread {
    PFQuery *query = [PFQuery queryWithClassName:kGVActivityClassKey];
    [query whereKey:kGVActivityThreadKey equalTo:thread];

    [query includeKey:kGVParseCreatedAtKey];
    [query includeKey:kGVParseUpdatedAtKey];
    [query includeKey:kGVActivityUserKey];
    [query includeKey:kGVActivityReactionOriginalSendKey];
    [query includeKey:kGVActivitySendReactionsKey];
    [query includeKey:kGVActivityReadKey];
    [query orderByDescending:kGVParseUpdatedAtKey];
    return query;
}

+ (NSString*)dotNotation:(NSString*)prop1 dot:(NSString*)prop2 {
    return [NSString stringWithFormat:@"%@.%@", prop1, prop2];
}

+ (PFQuery *)netQueryForUserUpdate:(PFUser*)user {
    PFQuery *query = [PFQuery queryWithClassName:kGVThreadClassKey];
    [query whereKey:kGVThreadUsersKey containedIn:@[user]];

    PFQuery *validUserQuery = [PFUser query];
    //[validUserQuery whereKeyExists:kGVUserNameKey];

    //[query includeKey:kGVParseCreatedAtKey];
    //[query includeKey:kGVParseUpdatedAtKey];
    //[query includeKey:kGVThreadUsersKey];
    //[query includeKey:kGVThreadCreatorKey];
    //[query includeKey:kGVThreadLastActivityKey];
    //[query orderByDescending:kGVParseUpdatedAtKey];

    PFQuery *acts = [PFQuery queryWithClassName:kGVActivityClassKey];
    [acts whereKey:kGVActivityThreadKey matchesQuery:query];

    [acts includeKey:kGVParseCreatedAtKey];
    [acts includeKey:kGVParseUpdatedAtKey];
    [acts includeKey:kGVActivityUserKey];
    [acts includeKey:kGVActivityReactionOriginalSendKey];
    [acts includeKey:kGVActivitySendReactionsKey];
    [acts includeKey:kGVActivityThreadKey];
    //[acts includeKey:kGVActivityForcedDisplayName];
    
    //[acts whereKeyExists:kGVActivityUserKey];
    //[acts whereKey:kGVActivityUserKey containedIn:<#(NSArray *)#>:validUserQuery];

    [acts includeKey:[GVParseObjectUtility dotNotation:kGVActivityThreadKey dot:kGVThreadCreatorKey]];
    [acts includeKey:[GVParseObjectUtility dotNotation:kGVActivityThreadKey dot:kGVThreadLastActivityKey]];
    [acts includeKey:[GVParseObjectUtility dotNotation:kGVActivityThreadKey dot:kGVThreadUsersKey]];
    [acts includeKey:[GVParseObjectUtility dotNotation:kGVActivityThreadKey dot:kGVParseCreatedAtKey]];
    [acts includeKey:[GVParseObjectUtility dotNotation:kGVActivityThreadKey dot:kGVParseUpdatedAtKey]];
    [acts orderByDescending:kGVParseUpdatedAtKey];

    return acts;
}

+ (PFQuery *)queryForActivitiesOfThreads:(NSArray *)threads {
    PFQuery *query = [PFQuery queryWithClassName:kGVActivityClassKey];
    [query whereKey:kGVActivityThreadKey containedIn:threads];

    [query includeKey:kGVActivityUserKey];
    //[query includeKey:kGVActivityVideoKey];
    //[query includeKey:kGVActivityVideoThumbnailKey];
    [query includeKey:kGVActivitySendReactionsKey];
    [query includeKey:kGVActivityReactionOriginalSendKey];
    [query includeKey:kGVActivityReadKey];
    //[query includeKey:kGVActivityForcedDisplayName];
    [query orderByDescending:kGVParseCreatedAtKey];
    return query;
}

+ (void)setCameraImageForCurrentUser:(UIImage*)image {
    PFUser *currentUser = [PFUser currentUser];
    PFFile *cameraImageFile = [NSNull null];
    if (image == nil) {
        [currentUser setObject:cameraImageFile forKey:kGVUserCameraImageKey];
    } else {
        cameraImageFile = [PFFile fileWithName:@"cameraimage.jpg" data:UIImageJPEGRepresentation(image, 1.0)];
        [currentUser setObject:cameraImageFile forKey:kGVUserCameraImageKey];
        [currentUser save];
    }
}

@end
