//
//  GVMasterTableCollectionCellImageView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVMasterTableCollectionCellImageView.h"

@implementation GVMasterTableCollectionCellImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        //self.clipsToBounds = YES;
        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
        //self.imageView.layer.shouldRasterize = YES;
        //self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;


    }
    return self;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];

    //if (self.displayDelegate) {
    //    [self.displayDelegate setNeedsDisplay];
    //}
}

- (void)setNeedsLayout {
    [super setNeedsLayout];

    [self.imageView setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.frame = CGRectIntegral(self.bounds);
    //self.layer.cornerRadius = 1;
    //CGFloat cornerRadius = self.frame.size.width / 2;
    //self.layer.cornerRadius = cornerRadius;

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
