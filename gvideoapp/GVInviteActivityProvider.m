//
//  GVInviteActivityProvider.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/12/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVInviteActivityProvider.h"

@implementation GVInviteActivityProvider

- (id)item {
    NSString *msg = @"Gvideo lets you see your friends reactions! Check it out!";
    if (self.activityType == UIActivityTypePostToTwitter) {
        return [msg stringByAppendingString:@" #gvidreacting"];
    }
    
    return msg;
}

@end
