//
//  GVAppDelegate.m
//  GVVideoEditorScreenshot
//
//  Created by Gaurav Khanna on 7/25/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "GVAppDelegate.h"

@interface GVAppDelegate () <UINavigationControllerDelegate, UIVideoEditorControllerDelegate>

@property UIVideoEditorController *videoEditorController;

@end

@implementation GVAppDelegate

- (void)attemptToChangeVideoEditorToSendButton:(UINavigationController*)navigationController {
    UINavigationBar *navBar = [navigationController navigationBar];
    NSArray *items = [navBar items];
    if ([items count] > 0) {
        UINavigationItem *item = [items objectAtIndex:0];
        if (item) {
            NSArray *rightItems = [item rightBarButtonItems];
            if ([rightItems count] > 0) {
                UIBarButtonItem *buttonItem = [rightItems objectAtIndex:0];
                if (buttonItem) {
                    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:[buttonItem target] action:[buttonItem action]];
                    //[buttonItem setTitle:@"Send"];
                    [item setRightBarButtonItems:@[sendButton] animated:NO];
                }
            }
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"5256034302_f67b637427_o" ofType:@"mov"];
    
    if ([UIVideoEditorController canEditVideoAtPath:moviePath]) {
        UIVideoEditorController *videoEditor = [[UIVideoEditorController alloc] init];
        videoEditor.videoPath = moviePath;
        //videoEditor.videoMaximumDuration = VIDEO_MAXIMUM_DURATION;
        videoEditor.videoQuality = UIImagePickerControllerQualityTypeHigh;
        videoEditor.delegate = self;
        //[self finishProgressBarAnimation];
        self.videoEditorController = videoEditor;
        
        
            self.window.rootViewController = videoEditor;
        [self attemptToChangeVideoEditorToSendButton:videoEditor];
            //[self presentViewController:videoEditor animated:YES completion:nil];
        
    } else {
        NSLog(@" can't do that..let's just go skip..");
       
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self attemptToChangeVideoEditorToSendButton:self.videoEditorController];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
