//
//  GVDotToolbar.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVDotToolbar.h"
#import "GVRecordDotView.h"
#import "UIColor+Image.h"

@interface GVDotToolbar () <UIToolbarDelegate>

@property (nonatomic, strong) GVRecordDotView *dotView;
@property (nonatomic, strong) UIBarButtonItem *buttonItem;

@end

@implementation GVDotToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.barStyle = UIBarStyleDefault;
        self.backgroundColor = [UIColor clearColor];
        self.barTintColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        self.translucent = YES;
        self.alpha = 0.8;
        self.tintColor = [UIColor whiteColor];
        self.userInteractionEnabled = NO;
        self.delegate = self;
        //self.clipsToBounds = YES;
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        self.layer.shadowOpacity = 0.0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0.0;

        [self setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]]
                      forToolbarPosition:UIToolbarPositionAny
                              barMetrics:UIBarMetricsDefault];
        [self setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]]
                      forToolbarPosition:UIToolbarPositionAny
                              barMetrics:UIBarMetricsLandscapePhone];
        [self setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]]
                      forToolbarPosition:UIToolbarPositionAny
                              barMetrics:UIBarMetricsLandscapePhonePrompt];
        [self setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]]
                      forToolbarPosition:UIToolbarPositionAny
                              barMetrics:UIBarMetricsDefaultPrompt];


        self.dotView = [[GVRecordDotView alloc] initWithFrame:frame];
        self.buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.dotView];

        self.items = @[self.buttonItem];

    }
    return self;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTop;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.dotView.layer.position = CGPointMake(0, 0);
    self.dotView.frame = CGRectIntegral(self.bounds);
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
