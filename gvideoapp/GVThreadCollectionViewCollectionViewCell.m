//
//  GVThreadCollectionViewCollectionViewCell.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/20/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVThreadCollectionViewCollectionViewCell.h"
#import "GVUnreadDotView.h"

@interface GVThreadCollectionViewCollectionViewCell ()

@property (nonatomic, strong) UIView *dotView;

@end

@implementation GVThreadCollectionViewCollectionViewCell 

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        @autoreleasepool {

//            self.detailToolbar = [[UIToolbar alloc] initWithFrame:frame];
//            self.detailToolbar.barStyle = UIBarStyleBlack;
//            self.detailToolbar.translucent = YES;
//            self.detailToolbar.delegate = self;
//            [self.detailToolbar setBarTintColor:[UIColor clearColor]];
//            self.detailToolbar.backgroundColor = [UIColor blackColor];
//


            //_dotView = [[GVUnreadDotView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
//            self.unreadItem = [[UIBarButtonItem alloc] initWithCustomView:dotView];
//
//            self.detailToolbar.items = @[self.unreadItem];

            //[self.contentView addSubview:_dotView];

        }
    }
    return self;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionAny;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.thumbnailImageView = nil;
}

- (void)removeAllSubImageViews {
    for (UIImageView *imageView in self.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

//    if (self.displaySendMessage) {
//
//        self.thumbnailImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, -1, 1);
//    } else {
//        self.thumbnailImageView.transform = CGAffineTransformIdentity;
//    }

    self.thumbnailImageView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    self.thumbnailImageView.center = self.contentView.center;

    CGFloat unreadSize = 5;
    CGFloat unreadPadding = 1;
    self.dotView.frame = CGRectMake(self.contentView.bounds.size.width - unreadSize + unreadPadding, -unreadPadding, unreadSize, unreadSize);
    [self bringSubviewToFront:self.dotView];
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
