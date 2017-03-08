//
//  main.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/26/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GVAppDelegate.h"

#define DEBUG_EXCEPTION 1

int main(int argc, char * argv[])
{
    @autoreleasepool {
#if DEBUG_EXCEPTION
        @try {
#endif
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([GVAppDelegate class]));
#if DEBUG_EXCEPTION
        }
        @catch (NSException *exception) {
            DLogException(exception);
        }
        @finally {
            
        }
#endif
    }
}
