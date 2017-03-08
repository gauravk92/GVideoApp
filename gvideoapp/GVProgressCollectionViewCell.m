//
//  GVProgressCollectionViewCell.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/16/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVProgressCollectionViewCell.h"
#import "UILabel+AutoShrink.h"

@interface GVProgressCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *usernameLabel;

@end

@implementation GVProgressCollectionViewCell

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (void)prepareForReuse {
    [super prepareForReuse];

    [self.imageView removeFromSuperview];
    self.imageView = nil;
    [self.usernameLabel removeFromSuperview];
    self.usernameLabel = nil;
}

- (void)setupImageView:(UIImageView*)imageView {
//    if (self.imageView) {
//        [self.imageView removeFromSuperview];
//    }
    [self addSubview:imageView];
    self.imageView = imageView;
    self.imageView.layer.shouldRasterize = YES;
    self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    self.imageView.layer.borderWidth = 1;
}

- (void)setupUsernameLabel:(UILabel*)usernameLabel {
//    if (self.usernameLabel) {
//        [self.usernameLabel removeFromSuperview];
//    }
    [self addSubview:usernameLabel];
    self.usernameLabel = usernameLabel;
    self.usernameLabel.alpha = 0.97;
    self.usernameLabel.adjustsFontSizeToFitWidth = YES;
    //self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.usernameLabel.textColor = [UIColor whiteColor];
    self.usernameLabel.minimumScaleFactor = 0.5;
    self.usernameLabel.layer.shouldRasterize = YES;
    self.usernameLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    self.usernameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.usernameLabel.numberOfLines = 4;

    //NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //[paragraphStyle]
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat imageViewSize = 28;

    self.imageView.frame = CGRectIntegral(CGRectMake(0, self.bounds.size.height/2 - imageViewSize/2, imageViewSize, imageViewSize));
    self.imageView.layer.cornerRadius = imageViewSize / 2;
    self.imageView.clipsToBounds = YES;

    //[self.usernameLabel sizeToFit];



    CGFloat usernamePadding = 8;

    CGRect usernameRect = self.usernameLabel.frame;
    usernameRect.origin.x = self.imageView.frame.size.width + usernamePadding;
    usernameRect.origin.y = 0;
    if (self.showsImage) {
        usernameRect.size.width = self.bounds.size.width - usernameRect.origin.x;
    } else {
        usernameRect.size.width = 0;
    }
    usernameRect.size.height = self.bounds.size.height;
    self.usernameLabel.frame = usernameRect;

    [self.usernameLabel adjustFontSizeToFit];
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
