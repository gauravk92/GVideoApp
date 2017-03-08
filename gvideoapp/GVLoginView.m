//
//  GVLoginView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/1/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVLoginView.h"

@interface GVLoginView ()

@property (nonatomic, strong, readwrite) UIButton *twitterButton;

@end

@implementation GVLoginView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIButton *twitterBtn = [[UIButton alloc] initWithFrame:self.twitterButton.frame];
        UIImage *logoImg = [self.twitterButton imageForState:UIControlStateNormal];
        UIImage *highImg = [self.twitterButton imageForState:UIControlStateHighlighted];
        //[twitterBtn setImage:logoImg forState:UIControlStateNormal];
        //[twitterBtn setImage:highImg forState:UIControlStateHighlighted];
        //[twitterBtn addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpOutside];
        //self.twitterButton = twitterBtn;
    }
    return self;
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
