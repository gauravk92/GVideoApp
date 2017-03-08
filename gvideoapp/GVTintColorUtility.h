//
//  GVTintColorUtility.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GVTintColorUtility : NSObject

+ (UIColor *)utilityRedColor;
+ (UIColor *)utilityLightRedColor;
+ (UIColor *)utilityTintColor;
+ (UIColor*)utilityPurpleColor;
+ (UIColor *)utilityLightPurpleColor;
+ (UIColor *)utilityBlueColor;
+ (UIColor *)utilityLightBlueColor;
+ (UIColor *)utilityDarkPurpleColor;
+ (UIColor *)utilityToolbarColor;

+ (void)applyNavigationBarTintColor:(UINavigationBar*)navigationBar;

@end
