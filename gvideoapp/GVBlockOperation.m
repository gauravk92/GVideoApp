//
//  GVBlockOperation.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/15/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVBlockOperation.h"

@implementation GVBlockOperation

- (void)addToMainQueue {
    [self performSelectorOnMainThread:@selector(startOperation) withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
}

- (void)startOperation {
    if (!self.operation.isExecuting) {
        [self.operation start];
    }
}

@end
