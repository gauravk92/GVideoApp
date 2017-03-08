//
//  GVBlockOperation.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/15/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GVBlockOperation : NSObject

@property (nonatomic, strong) NSOperation *operation;

- (void)addToMainQueue;

@end
