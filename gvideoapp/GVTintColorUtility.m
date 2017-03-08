//
//  GVTintColorUtility.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVTintColorUtility.h"

@implementation GVTintColorUtility

+ (UIColor*)utilityTintColor {
    return [UIColor colorWithRed:0.000 green:0.886 blue:1.000 alpha:0.9];
}

+ (UIColor*)utilityPurpleColor {
    return [UIColor colorWithHue:0.583 saturation:1.000 brightness:0.502 alpha:1.000];
}

+ (void)applyNavigationBarTintColor:(UINavigationBar *)navigationBar {
    @autoreleasepool {
        NSShadow *shadow = [[NSShadow alloc] init];
        //shadow.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.750f];
        shadow.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);

        //navigationBar.translucent = YES;

        // currently using this color \/ june 8 11:49pm
        [navigationBar setBarTintColor:[UIColor colorWithRed:0.003 green:0.014 blue:0.184 alpha:1.0]];


        //[navigationBar setBarTintColor:[UIColor colorWithRed:0.023 green:0.014 blue:0.184 alpha:0.100]];
        //[navigationBar setBarTintColor:[UIColor colorWithRed:0.000 green:0.434 blue:1.000 alpha:1.000]];
        [navigationBar setTintColor:[GVTintColorUtility utilityTintColor]];
        if ([navigationBar respondsToSelector:@selector(setTitleTextAttributes:)]) {
            [navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSShadowAttributeName: shadow}];
        }
    }
}

+ (UIColor *)utilityLightRedColor {
    return [UIColor colorWithRed:0.983 green:0.399 blue:0.295 alpha:1.000];
}

+ (UIColor *)utilityRedColor
{
    return [UIColor colorWithRed:0.986 green:0.000 blue:0.090 alpha:1.000];
}


+ (UIColor *)utilityBlueColor
{
    return [UIColor colorWithRed:0.0 green:0.478431 blue:1.0 alpha:1.000];
}


+ (UIColor *)utilityLightBlueColor
{
    return [UIColor colorWithRed:0.000 green:0.000 blue:1.000 alpha:0.760];
}

+ (UIColor *)utilityDarkPurpleColor {
    return [UIColor colorWithRed:0.000 green:0.128 blue:0.471 alpha:1.000];
}


+ (UIColor *)utilityLightPurpleColor
{
    //[UIColor colorWithRed:0.000 green:0.000 blue:0.471 alpha:1.000];//
    return [UIColor colorWithRed:0.000 green:0.004 blue:0.590 alpha:1.000];//[UIColor colorWithRed:0.476 green:0.105 blue:0.687 alpha:1.000];
}

+ (UIColor *)utilityToolbarColor {
    return [UIColor colorWithRed:0.000 green:0.001 blue:0.256 alpha:0.880];
}

@end
