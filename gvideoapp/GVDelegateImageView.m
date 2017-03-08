//
//  GVDelegateImageView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/18/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVDelegateImageView.h"

@implementation GVDelegateImageView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];

    if (self.displayDelegate) {
        [self.displayDelegate setNeedsDisplay];
    }
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
