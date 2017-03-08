//
//  RightLabelAppDelegate.m
//  RightLabel
//
//  Created by Dmitry Stadnik on 1/20/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import "RightLabelAppDelegate.h"
#import "RightLabelViewController.h"

@implementation RightLabelAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

@end
