//
//  GVReactionPopoverView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/20/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVReactionPopoverView.h"

@implementation GVReactionPopoverView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowOpacity = 0.0;
        self.hidden = YES;
    }
    return self;
}

/* The arrow offset represents how far from the center of the view the center of the arrow should appear. For `UIPopoverArrowDirectionUp` and `UIPopoverArrowDirectionDown`, this is a left-to-right offset; negative is to the left. For `UIPopoverArrowDirectionLeft` and `UIPopoverArrowDirectionRight`, this is a top-to-bottom offset; negative to toward the top.

 This method is called inside an animation block managed by the `UIPopoverController`.
 */
//@property (nonatomic, readwrite) CGFloat arrowOffset;

- (CGFloat)arrowOffset {
    return 0.0;
}

- (void)setArrowOffset:(CGFloat)arrowOffset {
    
}

/* `arrowDirection` manages which direction the popover arrow is pointing. You may be required to change the direction of the arrow while the popover is still visible on-screen.
 */
//@property (nonatomic, readwrite) UIPopoverArrowDirection arrowDirection;

- (UIPopoverArrowDirection)arrowDirection {
    return UIPopoverArrowDirectionAny;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection {

}

/* These methods must be overridden and the values they return may not be changed during use of the `UIPopoverBackgroundView`. `arrowHeight` represents the height of the arrow in points from its base to its tip. `arrowBase` represents the the length of the base of the arrow's triangle in points. `contentViewInset` describes the distance between each edge of the background view and the corresponding edge of its content view (i.e. if it were strictly a rectangle). `arrowHeight` and `arrowBase` are also used for the drawing of the standard popover shadow.
 */
+ (CGFloat)arrowHeight {
    return 0.0;
}
+ (CGFloat)arrowBase {
    return 0.0;
}
+ (UIEdgeInsets)contentViewInsets {
    return UIEdgeInsetsZero;
}

/* This method may be overridden to prevent the drawing of the content inset and drop shadow inside the popover. The default implementation of this method returns YES.
 */
+ (BOOL)wantsDefaultContentAppearance {
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
