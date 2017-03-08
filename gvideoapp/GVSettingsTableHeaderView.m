//
//  GVSettingsTableHeaderView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/17/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSettingsTableHeaderView.h"


@interface GVSettingsTableHeaderView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation GVSettingsTableHeaderView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
        //self.contentView.layer.shouldRasterize = YES;
        //self.contentView.hidden = YES;
        //self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];

        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        self.gradientLayer.startPoint = CGPointMake(0.0f, -3.0f);
        self.gradientLayer.endPoint = CGPointMake(0.0, 0.8f);
        //self.collectionView.layer.mask = l;
        self.layer.mask = self.gradientLayer;


        self.stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        //self.stringLabel.alpha = 1.0;
        self.stringLabel.layer.shouldRasterize = YES;
        self.stringLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.stringLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        self.stringLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.stringLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.stringLabel];

        //self.stringLabel.layer.mask = self.gradientLayer;

    }
    return self;
}

- (void)setupString:(NSString*)string {
    self.stringLabel.text = string;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.gradientLayer.frame = self.bounds;

    CGFloat leftPadding = 6;
    CGRect stringRect = self.bounds;
    stringRect.origin.x = leftPadding;
    stringRect.size.width = self.bounds.size.width - leftPadding;

    self.stringLabel.frame = stringRect;
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
