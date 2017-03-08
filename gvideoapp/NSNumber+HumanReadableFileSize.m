//
//  NSNumber+HumanReadableFileSize.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/20/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "NSNumber+HumanReadableFileSize.h"

@implementation NSNumber (HumanReadableFileSize)

- (NSString*)humanReadableFileSize {
    //    NSError *attributesError;
    //    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:&attributesError];
    //
    //    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    //

    // format fileSize to MB
    unsigned long long int fileSize = 0;
    fileSize += [self intValue];
    return [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
}

@end
