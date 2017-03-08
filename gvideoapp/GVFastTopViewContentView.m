//
//  GVFastTopViewContentView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/17/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVFastTopViewContentView.h"

@interface GVFastTopViewContentView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *snapshotView;

@end

@implementation GVFastTopViewContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = YES;
    }
    return self;
}

- (void)setupContentView:(UIView *)view {
    if (self.contentView) {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
    self.contentView = view;
    self.snapshotView = [self.contentView snapshotViewAfterScreenUpdates:YES];
    [self addSubview:self.snapshotView];
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];

    [self.contentView setNeedsDisplay];
    //[self.snapshotView setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //CALayer *layer = self.contentView.layer;
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextDrawLayerInRect(ctx, rect, layer);
    [self.snapshotView drawViewHierarchyInRect:rect afterScreenUpdates:YES];
}


@end
