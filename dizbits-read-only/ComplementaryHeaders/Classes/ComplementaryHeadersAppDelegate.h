//
//  ComplementaryHeadersAppDelegate.h
//  ComplementaryHeaders
//
//  Created by Dmitry Stadnik on 1/22/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComplementaryHeadersViewController;

@interface ComplementaryHeadersAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ComplementaryHeadersViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ComplementaryHeadersViewController *viewController;

@end

