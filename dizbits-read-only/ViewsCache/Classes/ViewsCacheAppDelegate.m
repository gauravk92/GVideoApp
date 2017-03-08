//
//  ViewsCacheAppDelegate.m
//  ViewsCache
//
//  Created by Dmitry Stadnik on 1/21/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import "ViewsCacheAppDelegate.h"
#import "ViewsCacheViewController.h"
#import "ViewsCache.h"

@implementation ViewsCacheAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[ViewsCache sharedCache] clear];
}

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
