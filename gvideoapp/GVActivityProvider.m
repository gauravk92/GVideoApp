//
//  GVActivityProvider.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/12/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVActivityProvider.h"

@implementation GVActivityProvider

- (id)item {
    
    if (self.activityType == UIActivityTypePostToTwitter) {
        return @"#gvidreacting";
    }
    
    return @"";
}

@end
