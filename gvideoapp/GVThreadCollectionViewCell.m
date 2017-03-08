//
//  GVThreadCollectionViewCell.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/1/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVThreadCollectionViewCell.h"
#import "GVThreadCollectionViewCollectionViewCell.h"
#import "GVParseObjectUtility.h"
#import "GVTwitterAuthUtility.h"

NSString *const GVThreadCollectionViewCollectionViewCellIdentifier = @"GVThreadCollectionViewCollectionViewCellIdentifier";

@interface GVThreadCollectionViewCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *userImageFiles;
@property (nonatomic, strong) UILabel *reactionsLabel;
@property (nonatomic, strong) UIView *bottomBorderView;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIBarButtonItem *usernameItem;
@property (nonatomic, strong) UIBarButtonItem *timeItem;
@property (nonatomic, strong) UIBarButtonItem *flexItem;


@end

@implementation GVThreadCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        // Initialization code
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.thumbnailView = [[GVCircleThumbnailInnerShadowView alloc] initWithFrame:CGRectMake(0, 0, 145, 145)];
        } else {
            self.thumbnailView = [[GVCircleThumbnailInnerShadowView alloc] initWithFrame:CGRectZero];
        }
        [self.contentView addSubview:self.thumbnailView];

        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handleLongPressGesture:)];
        [recognizer setMinimumPressDuration:0.4f];
        [self addGestureRecognizer:recognizer];

        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.sectionInset = UIEdgeInsetsZero;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(40, 40);
        flowLayout.minimumLineSpacing = 4;
        flowLayout.minimumInteritemSpacing = 0;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.layer.shouldRasterize = YES;
        self.collectionView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:self.collectionView];

        self.reactionsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.reactionsLabel setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.reactionsLabel];
        self.reactionsLabel.layer.shouldRasterize = YES;
        self.reactionsLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //[self.reactionsLabel setText:@"Reactions"];

        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.timeLabel setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.timeLabel];
        self.timeLabel.layer.shouldRasterize = YES;
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.timeLabel.hidden = YES;

        self.bottomBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bottomBorderView.backgroundColor = [UIColor lightGrayColor];
        self.bottomBorderView.alpha = 0.8;
        self.bottomBorderView.layer.shouldRasterize = YES;
        self.bottomBorderView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:self.bottomBorderView];

        UIFont *usernameFont = [UIFont boldSystemFontOfSize:18.0];
        UIFont *timeFont = [UIFont systemFontOfSize:12.0];

        NSDictionary *usernameDict = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSBackgroundColorAttributeName: [UIColor clearColor],
                                       NSFontAttributeName: usernameFont};

        //NSDictionary *timeDict = @{NSFontAttributeName: timeFont};

        self.usernameItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        self.usernameItem.enabled = NO;
        [self.usernameItem setTitleTextAttributes:usernameDict forState:UIControlStateNormal];
        
        self.timeItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        //[self.timeItem setTitleTextAttributes:timeDict forState:UIControlStateNormal];
        self.timeItem.enabled = NO;

        self.flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

        //self.contentView.layer.borderColor = [UIColor colorWithRed:0.885 green:0.877 blue:0.937 alpha:1.000].CGColor;
        //self.contentView.layer.borderWidth = 1;

        [self.collectionView registerClass:[GVThreadCollectionViewCollectionViewCell class] forCellWithReuseIdentifier:GVThreadCollectionViewCollectionViewCellIdentifier];
        
    }
    return self;
}

- (void)setTimeLabelString:(NSString*)timeLabel {
    self.timeLabel.text = timeLabel;
    self.timeItem.title = timeLabel;
    self.thumbnailView.detailToolbar.items = @[self.usernameItem, self.flexItem, self.timeItem];
}

- (void)addActivities:(NSArray*)activities {
    self.userImageFiles = activities;
    NSNumber *count = [NSNumber numberWithUnsignedInteger:[activities count]];
    if ([count isEqualToNumber:[NSNumber numberWithInt:1]]) {
        [self.reactionsLabel setText:@"1 Reaction"];
    } else {
        [self.reactionsLabel setText:[NSString stringWithFormat:@"%@ Reactions", count]];
    }

    [self.collectionView reloadData];
    //[self setNeedsLayout];
    //[self layoutIfNeeded];
}

//- (void)layoutThumbnailView {
//    if (self.thumbnailView.superview != self) {
//        [self.thumbnailView removeFromSuperview];
//        [self addSubview:self.thumbnailView];
//    }
//}

//- (CGSize)intrinsicContentSize
//{
//    CGSize size = [self.label intrinsicContentSize];
//
//    if (CGSizeEqualToSize(_extraMargins, CGSizeZero))
//    {
//        // quick and dirty: get extra margins from constraints
//        for (NSLayoutConstraint *constraint in self.constraints)
//        {
//            if (constraint.firstAttribute == NSLayoutAttributeBottom || constraint.firstAttribute == NSLayoutAttributeTop)
//            {
//                // vertical spacer
//                _extraMargins.height += [constraint constant];
//            }
//            else if (constraint.firstAttribute == NSLayoutAttributeLeading || constraint.firstAttribute == NSLayoutAttributeTrailing)
//            {
//                // horizontal spacer
//                _extraMargins.width += [constraint constant];
//            }
//        }
//    }
//
//    // add to intrinsic content size of label
//    size.width += _extraMargins.width;
//    size.height += _extraMargins.height;
//    
//    return size;
//}

- (void)setSendUsernameText:(NSString*)text {
    self.usernameItem.title = text;
    [self.thumbnailView.detailToolbar setItems:@[self.usernameItem, self.flexItem, self.timeItem] animated:NO];
}

- (void)prepareForReuse {
    [super prepareForReuse];
//    [self.thumbnailView removeFromSuperview];
//    self.thumbnailView = nil;
//    self.displaySentMessage = NO;
    self.userImageFiles = nil;
    [self.reactionsLabel setText:nil];
    [self.collectionView reloadData];
    [self.timeLabel setText:nil];
    [self setSendUsernameText:nil];
    self.threadId = nil;

}

- (void)removeAllSubImageViews {
    for (UIImageView *imageView in self.thumbnailView.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];


    [self.thumbnailView arrangeSubviews];
    //self.contentView.frame = CGRectInset(self.contentView.bounds, 15, 0);
    //self.contentView.layer.position = CGPointMake(1, 1);
//    if (self.displaySentMessage) {
//        CGRect thumbFrame = self.thumbnailView.frame;
//        thumbFrame.origin.x = self.contentView.bounds.size.width - thumbFrame.size.width - 8;
//        self.thumbnailView.frame = thumbFrame;
//        self.collectionView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width - self.thumbnailView.frame.size.width - 8, 100);
//        self.collectionView.transform = CGAffineTransformScale(CGAffineTransformIdentity, -1, 1);
//
//    //self.thumbnailView.frame = self.contentView.bounds;
//    //self.contentView.layer.anchorPoint = CGPointMake(1, self.contentView.layer.anchorPoint.y);
//    } else {
//        CGRect thumbFrame = self.thumbnailView.frame;
//        thumbFrame.origin.x = 8;
//        self.thumbnailView.frame = thumbFrame;
//        self.collectionView.frame = CGRectMake(self.thumbnailView.frame.size.width+ 8 + 1, 0, self.contentView.bounds.size.width - self.thumbnailView.frame.size.width - 8, 100);
//
//        self.collectionView.transform = CGAffineTransformIdentity;
//
//    }

    CGFloat detailHeight = 70;
    CGFloat detailPadding = 4.5;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        detailPadding = 14;
    }

    self.thumbnailView.frame = CGRectMake(detailPadding, 0, self.contentView.frame.size.width - (detailPadding*2), self.contentView.frame.size.height - detailHeight);


    [self.reactionsLabel sizeToFit];
    self.reactionsLabel.frame = CGRectMake(30, self.contentView.frame.size.height - detailHeight + ((detailHeight / 2) - (self.reactionsLabel.frame.size.height / 2)), self.reactionsLabel.frame.size.width, self.reactionsLabel.frame.size.height);

    CGFloat collectionPadding = 158;
    self.collectionView.frame = CGRectMake(collectionPadding, self.contentView.frame.size.height - detailHeight, self.contentView.frame.size.width - collectionPadding, detailHeight);

    CGFloat borderPadding = 25;
    CGFloat borderHeight = 1;
    self.bottomBorderView.frame = CGRectMake(borderPadding, self.contentView.frame.size.height - borderHeight, self.contentView.frame.size.width - borderPadding, borderHeight);
    //self.thumbnailView.center = CGPointMake(self.thumbnailView.center.x, self.contentView.center.y);
    //self.collectionView.center = CGPointMake(self.collectionView.center.x, self.contentView.center.y+1);
    //self.thumbnailView.imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    //self.collectionView.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>);
    //self.contentView.frame = CGRectInset(self.contentView.frame, -1, 0);

    [self.timeLabel sizeToFit];

    CGRect timeFrame = self.timeLabel.frame;
    timeFrame.origin.y = self.contentView.frame.size.height - timeFrame.size.height;
    timeFrame.origin.x = self.contentView.frame.size.width - timeFrame.size.width - detailPadding;
    self.timeLabel.frame = timeFrame;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.userImageFiles count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GVThreadCollectionViewCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:GVThreadCollectionViewCollectionViewCellIdentifier forIndexPath:indexPath];

    //dispatch_async(dispatch_get_main_queue(), ^{

    [cell removeAllSubImageViews];
    //if (cell.thumbnailImageView) {
    //cell.thumbnailImageView.image = nil;
    //[cell.thumbnailImageView removeFromSuperview];
    //  }

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    PFObject *reaction = [self.userImageFiles objectAtIndex:indexPath.row];
    NSString *url = (NSString*)[[reaction objectForKey:kGVActivityVideoThumbnailKey] url];
    if ([url respondsToSelector:@selector(length)] && ([url length] > 0)) {
        PFUser *user = [reaction objectForKey:kGVActivityUserKey];
        if (user) {
            [GVTwitterAuthUtility shouldGetProfileImageForAnyUser:[user username] block:^(NSURL *imageURL, NSURL *bannerURL, NSString *realname) {
                [imageView setImageWithURL:[NSURL URLWithString:imageURL]];
            }];
        }
    }

    cell.displaySendMessage = self.displaySentMessage;

    cell.thumbnailImageView = imageView;
    cell.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;

    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
//    if (self.displaySentMessage) {
//        transform = CGAffineTransformScale(transform, -1, 1);
//        transform = CGAffineTransformRotate(transform, DEGREES_TO_RADIANS(180));
//    } else {
//
//    }

    cell.thumbnailImageView.transform = CGAffineTransformIdentity;
    cell.thumbnailImageView.layer.cornerRadius = 20;
    cell.thumbnailImageView.clipsToBounds = YES;
    //cell.imageView.frame = cell.contentView.frame;
    //cell.thumbnailImageView.frame = CGRectMake(0, 0, 40, 40);
    [cell addSubview:cell.thumbnailImageView];
    cell.thumbnailImageView.layer.opaque = YES;
    cell.thumbnailImageView.opaque = YES;

    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *reaction = [self.userImageFiles objectAtIndex:indexPath.row];
    NSString *url = (NSString*)[[reaction objectForKey:kGVActivityVideoKey] url];
    NSDictionary *info = @{@"url": url};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GVThreadCollectionViewCellSelectIdentifier" object:nil userInfo:info];
    
}

#pragma mark - Copying

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canResignFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)copy:(id)sender
{
    if (self.threadId) {
        [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"http://gvideoapp.com/t/%@", self.threadId]];
        [self resignFirstResponder];
    }
}

#pragma mark - Gestures

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;

    UIMenuController *menu = [UIMenuController sharedMenuController];
    CGRect targetRect = [self convertRect:self.thumbnailView.frame
                                 fromView:self.contentView];

    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];

    self.thumbnailView.alpha = 0.6;
    //self.bubbleView.bubbleImageView.highlighted = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
    //self.bubbleView.bubbleImageView.highlighted = NO;
    self.thumbnailView.alpha = 1;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}

@end
