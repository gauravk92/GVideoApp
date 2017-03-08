//
//  GVCameraButtonView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 8/16/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCameraButtonView.h"

@implementation GVCameraButtonView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGFloat radius = 100.0;
    CGRect frame = CGRectMake(-radius, -radius,
                              self.frame.size.width + radius,
                              self.frame.size.height + radius);
    
    if (CGRectContainsPoint(frame, point)) {
        return self;
    }
    return nil;
}




- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(CGRectMake(-100, -100, self.frame.size.width + 100, self.frame.size.height + 100), point))
    {
        return YES;
    }
    return NO;
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
