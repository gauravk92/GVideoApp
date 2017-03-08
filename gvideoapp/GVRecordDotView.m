//
//  GVRecordDotView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVRecordDotView.h"

@interface GVRecordDotView ()

@end

@implementation GVRecordDotView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        //self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        //self.colorView.backgroundColor = [UIColor redColor];
        //[self addSubview:self.colorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    //CGFloat cRadius = round(self.bounds.size.width / 2);
    self.layer.cornerRadius = self.bounds.size.width / 2;
    
    self.clipsToBounds = YES;
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
