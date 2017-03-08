//
//  GVShareActivityProvider.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/12/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVShareActivityProvider.h"

@implementation GVShareActivityProvider

- (id)item {
    NSString *msg = @"Gvideo lets us see your reaction to this video I made! Check it out!";
    if (self.activityType == UIActivityTypePostToTwitter) {
        return [msg stringByAppendingString:@" #gvidreacting"];
    }
    
    return msg;
}

@end
