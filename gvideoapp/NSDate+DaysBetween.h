//
//  NSDate+DaysBetween.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/11/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DaysBetween)

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (NSInteger)hoursBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (__autoreleasing NSDateComponents*)componentsBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

@end
