//
//  GVProgressView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/1/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVProgressBarView.h"
#import "GVTintColorUtility.h"

@interface GVProgressBarView ()

@property (nonatomic, strong) UILabel *progressTextLabel;
@property (nonatomic, strong) CAGradientLayer *barGradientLayer;
@property (nonatomic, strong) CAGradientLayer *textGradientLayer;

@end

@implementation GVProgressBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;

        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];

        NSString *stopText = @"Tap to stop recording";

        NSDictionary *progressAttr = @{NSParagraphStyleAttributeName: paragraphStyle,
                                       NSFontAttributeName: font,
                                       NSForegroundColorAttributeName: [UIColor whiteColor]};

        self.progressTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        NSAttributedString *stopAttrString = [[NSAttributedString alloc] initWithString:stopText attributes:progressAttr];

        self.contentView = [[UIView alloc] initWithFrame:CGRectZero];

        self.contentView.backgroundColor = [GVTintColorUtility utilityRedColor]; //[self tintColor];


        [self.progressTextLabel setAttributedText:stopAttrString];
        self.progressTextLabel.layer.shouldRasterize = YES;
        self.progressTextLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.progressTextLabel.layer.needsDisplayOnBoundsChange = NO;
        self.progressTextLabel.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.progressTextLabel];
        [self addSubview:self.contentView];


        self.barGradientLayer = [CAGradientLayer layer];
        self.barGradientLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor];
        self.barGradientLayer.startPoint = CGPointMake(0.0, -1.0f);
        self.barGradientLayer.endPoint = CGPointMake(0, 0.6f);
        self.barGradientLayer.needsDisplayOnBoundsChange = NO;

        self.textGradientLayer = [CAGradientLayer layer];
        self.textGradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        self.textGradientLayer.startPoint = CGPointMake(0.0, -0.6f);
        self.textGradientLayer.endPoint = CGPointMake(0.0, 0.6f);
        self.textGradientLayer.needsDisplayOnBoundsChange = NO;
        self.progressTextLabel.layer.mask = self.textGradientLayer;

        // self.layer.mask = self.barGradientLayer;

    }
    return self;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];

    //[self.contentView setNeedsLayout];
    //[self.barGradientLayer setNeedsLayout];
    //[self.progressTextLabel setNeedsLayout];
    //[self.textGradientLayer setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.barGradientLayer.frame = CGRectIntegral(self.bounds);

    self.contentView.frame = CGRectIntegral(self.bounds);
    self.progressTextLabel.frame = CGRectIntegral(self.contentView.bounds);
    self.textGradientLayer.frame = CGRectIntegral(self.contentView.bounds);
    //self.progressTextLabel.frame = CGRectMake(0, 15, self.contentView.bounds.size.width, self.contentView.bounds.size.height - 20);

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
