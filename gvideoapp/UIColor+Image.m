//
//  UIColor+Image.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/1/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "UIColor+Image.h"

@implementation UIColor (Image)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
