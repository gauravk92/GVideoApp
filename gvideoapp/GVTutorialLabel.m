//
//  GVTutorialLabel.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/24/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVTutorialLabel.h"

@implementation GVTutorialLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTextColor:[UIColor whiteColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        self.numberOfLines = 0;
        self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 0;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        self.layer.cornerRadius = 20.0;
        self.alpha = 0.0;
        self.clipsToBounds = YES;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    }
    return self;
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
