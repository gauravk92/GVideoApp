//
//  GVSettingsTableFooterView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/17/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSettingsTableFooterView.h"

@interface GVSettingsTableFooterView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation GVSettingsTableFooterView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.0];
        //self.contentView.layer.shouldRasterize = YES;
        //self.contentView.hidden = YES;
        //self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];

        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        self.gradientLayer.startPoint = CGPointMake(0.0f, -3.0f);
        self.gradientLayer.endPoint = CGPointMake(0.0, 0.8f);
        //self.collectionView.layer.mask = l;
        //self.layer.mask = self.gradientLayer;

        self.stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.stringLabel.textAlignment = NSTextAlignmentCenter;
        self.stringLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.stringLabel.numberOfLines = 0;
        self.stringLabel.layer.shouldRasterize = YES;
        self.stringLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.stringLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
        self.stringLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.stringLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.stringLabel];

        self.stringLabel.layer.mask = self.gradientLayer;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.gradientLayer.frame = self.bounds;

    //CGFloat stringPadding = 10;
    self.stringLabel.frame = self.bounds;
    //CGRect stringRect = self.bounds;
    //stringRect.origin.x = stringPadding;
    //stringRect.size.width = self.bounds.size.width - stringPadding;
    //self.stringLabel.frame = stringRect;
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
