//
//  GVSettingsTableViewCellButtonView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/9/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSettingsTableViewCellButtonView.h"

@implementation GVSettingsTableViewCellButtonView

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.mainButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.mainButton.center = self.center;
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
