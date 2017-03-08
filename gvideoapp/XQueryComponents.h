//
//  XQueryComponents.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//
//  http://stackoverflow.com/questions/3997976/parse-nsurl-query-property

#import <Foundation/Foundation.h>

@interface NSString (XQueryComponents)
- (NSString *)stringByDecodingURLFormat;
- (NSString *)stringByEncodingURLFormat;
- (NSMutableDictionary *)dictionaryFromQueryComponents;
@end

@interface NSURL (XQueryComponents)
- (NSMutableDictionary *)queryComponents;
@end

@interface NSDictionary (XQueryComponents)
- (NSString *)stringFromQueryComponents;
@end