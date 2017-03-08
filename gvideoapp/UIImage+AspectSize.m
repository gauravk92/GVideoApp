//
//  UIImage+AspectSize.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/3/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "UIImage+AspectSize.h"

@implementation UIImage (AspectSize)

+ (CGSize)aspectSize:(CGSize)finalImageSize image:(UIImage*)sourceImageRef {
    //CGSize finalImageSize = CGSizeMake(300,300);
    //CGImageRef sourceImageRef = yourImage.CGImage;
    
    CGFloat width = sourceImageRef.size.width;
    CGFloat height = sourceImageRef.size.height;

    CGFloat horizontalRatio = finalImageSize.width / width;
    CGFloat verticalRatio = finalImageSize.height / height;
    CGFloat ratio = MAX(horizontalRatio, verticalRatio); //AspectFill
    CGSize aspectFillSize = CGSizeMake(width * ratio, height * ratio);

    return aspectFillSize;

    //    CGContextRef context = CGBitmapContextCreate(NULL,
    //                                                 finalImageSize.width,
    //                                                 finalImageSize.height,
    //                                                 CGImageGetBitsPerComponent(sourceImageRef),
    //                                                 0,
    //                                                 CGImageGetColorSpace(sourceImageRef),
    //                                                 CGImageGetBitmapInfo(sourceImageRef));
    //
    //    //Draw our image centered vertically and horizontally in our context.
    //    CGContextDrawImage(context,
    //                       CGRectMake((finalImageSize.width-aspectFillSize.width)/2,
    //                                  (finalImageSize.height-aspectFillSize.height)/2,
    //                                  aspectFillSize.width,
    //                                  aspectFillSize.height),
    //                       sourceImageRef);
    //
    //    //Start cleaning up..
    //    CGImageRelease(sourceImageRef);
    //
    //    CGImageRef finalImageRef = CGBitmapContextCreateImage(context);
    //    UIImage *finalImage = [UIImage imageWithCGImage:finalImageRef];
    //
    //    CGContextRelease(context);
    //    CGImageRelease(finalImageRef);
    //    return finalImage
}

@end
