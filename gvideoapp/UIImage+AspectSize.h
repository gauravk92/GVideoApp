//
//  UIImage+AspectSize.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/3/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AspectSize)

+ (CGSize)aspectSize:(CGSize)finalImageSize image:(UIImage*)sourceImageRef;

@end
