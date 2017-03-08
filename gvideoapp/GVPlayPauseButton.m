//
//  GVPlayPauseButton.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/15/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVPlayPauseButton.h"

@implementation GVPlayPauseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 2;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        //self.layer.shadowOffset = CGSizeMake(0, -1);
        //self.layer.shadowOpacity = 1;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
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
