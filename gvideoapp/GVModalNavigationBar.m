//
//  GVModalNavigationBar.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVModalNavigationBar.h"

@interface GVModalNavigationBar ()

@end

@implementation GVModalNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        _glassView = [[LFGlassView alloc] initWithFrame:frame];
//        _glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _glassView.translatesAutoresizingMaskIntoConstraints = NO;
//        [_glassView setBackgroundColor:[UIColor colorWithRed:0.003 green:0.014 blue:0.184 alpha:1.0]];
//        [self insertSubview:_glassView atIndex:0];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        newSize = CGSizeMake(self.frame.size.width, 60);
    }
    newSize = CGSizeMake(self.frame.size.width,60);
    return newSize;
}

- (void)sizeToFit {
    [super sizeToFit];

    NSLog(@" size to fit");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
