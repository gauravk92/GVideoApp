//
//  GVThreadTableViewCell.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/2/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVThreadTableViewCell.h"
#import "GVThreadCollectionViewCollectionViewCell.h"
#import "GVParseObjectUtility.h"
#import "MBProgressHUD.h"
#import "GVRecordDotView.h"
#import "GVTwitterAuthUtility.h"


#define FOOTER_SPACING 1

#if FOOTER_SPACING
CGFloat const GVThreadTableViewCellBottomMargin = 0;
#else
CGFloat const GVThreadTableViewCellBottomMargin = 30;
#endif

NSString *const GVThreadTableViewCellCollectionViewCellIdentifier = @"GVThreadTableViewCellCollectionViewCellIdentifier";
NSString *const GVThreadTableViewCellTableViewCellIdentifier = @"GVThreadTableViewCellCollectionViewCellIdentifier";

@interface GVThreadTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *userImageFiles;
@property (nonatomic, strong) UILabel *reactionsLabel;
@property (nonatomic, strong) UIView *bottomBorderView;
//@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIBarButtonItem *usernameItem;
@property (nonatomic, strong) UIBarButtonItem *timeItem;
@property (nonatomic, strong) UIBarButtonItem *flexItem;
@property (nonatomic, strong) UIBarButtonItem *lengthItem;
@property (nonatomic, strong) UIBarButtonItem *recordItem;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UITableViewCell *tableViewCell;
@property (nonatomic, strong) UIBarButtonItem *leftSpaceItem;
@property (nonatomic, strong) CAGradientLayer *gradientMaskLayer;


@end

@implementation GVThreadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.selectedBackgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        //self.contentView.layer.shouldRasterize = YES;
        //self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;

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
        self.collectionView.scrollsToTop = NO;
        self.collectionView.scrollEnabled = NO;
        [self.contentView addSubview:self.collectionView];



//        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        [self.timeLabel setTextColor:[UIColor lightGrayColor]];
//        [self.contentView addSubview:self.timeLabel];
//        self.timeLabel.layer.shouldRasterize = YES;
//        self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
//        self.timeLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        self.timeLabel.hidden = YES;

        self.bottomBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bottomBorderView.backgroundColor = [UIColor lightGrayColor];
        self.bottomBorderView.alpha = 0.8;
        self.bottomBorderView.layer.shouldRasterize = YES;
        self.bottomBorderView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:self.bottomBorderView];

        UIFont *usernameFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        UIFont *timeFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = NSTextAlignmentLeft;

        NSDictionary *usernameDict = @{NSParagraphStyleAttributeName: paragraphStyle,
                                       NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSBackgroundColorAttributeName: [UIColor clearColor],
                                       NSFontAttributeName: usernameFont};

        NSDictionary *timeDict = @{NSParagraphStyleAttributeName: paragraphStyle,
                                   NSFontAttributeName: timeFont};

        self.reactionsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.reactionsLabel setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.reactionsLabel];
        self.reactionsLabel.layer.shouldRasterize = YES;
        self.reactionsLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.reactionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        //[self.reactionsLabel setText:@"Reactions"];

        self.usernameItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        self.usernameItem.enabled = NO;
        [self.usernameItem setTitleTextAttributes:usernameDict forState:UIControlStateNormal];

        self.timeItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        [self.timeItem setTitleTextAttributes:timeDict forState:UIControlStateNormal];
        self.timeItem.enabled = NO;

        self.lengthItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        [self.lengthItem setTitleTextAttributes:timeDict forState:UIControlStateNormal];
        self.lengthItem.enabled = NO;

        self.leftSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        self.leftSpaceItem.width = 0;
        self.leftSpaceItem.enabled = YES;

        GVRecordDotView *dotView = [[GVRecordDotView alloc] initWithFrame:CGRectMake(0, 0, 13, 13)];
        self.recordItem = [[UIBarButtonItem alloc] initWithCustomView:dotView];

        self.flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

        //self.contentView.layer.borderColor = [UIColor colorWithRed:0.885 green:0.877 blue:0.937 alpha:1.000].CGColor;
        //self.contentView.layer.borderWidth = 1;

        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reactionsTap:)];
        self.tapGestureRecognizer.delegate = self;
        self.tapGestureRecognizer.enabled = YES;

//        self.atapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reactionsTap:)];
//        self.atapGestureRecognizer.delegate = self;
//        self.atapGestureRecognizer.enabled = YES;

        self.tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GVThreadTableViewCellTableViewCellIdentifier];
        self.tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.tableViewCell.backgroundColor = [UIColor clearColor];
        self.tableViewCell.backgroundView = nil;
        self.tableViewCell.exclusiveTouch = YES;
        self.tableViewCell.userInteractionEnabled = YES;
        [self.contentView addSubview:self.tableViewCell];
        //[self.tableViewCell.accessoryView addGestureRecognizer:self.atapGestureRecognizer];
        [self.tableViewCell.contentView addGestureRecognizer:self.tapGestureRecognizer];

        [self.collectionView registerClass:[GVThreadCollectionViewCollectionViewCell class] forCellWithReuseIdentifier:GVThreadTableViewCellCollectionViewCellIdentifier];


        self.gradientMaskLayer = [CAGradientLayer layer];

        self.showRecord = YES;

    }
    return self;
}

- (void)setInstanceItems {
    if ([self.lengthItem.title length] > 0) {
        if (self.showRecord) {
            self.thumbnailView.detailToolbar.items = @[self.recordItem, self.usernameItem, self.flexItem, self.timeItem, self.lengthItem];
        } else {
            self.thumbnailView.detailToolbar.items = @[self.leftSpaceItem, self.usernameItem, self.flexItem, self.timeItem, self.lengthItem];
        }
    } else {
        if (self.showRecord) {
            self.thumbnailView.detailToolbar.items = @[self.recordItem, self.usernameItem, self.flexItem, self.timeItem];
        } else {
            self.thumbnailView.detailToolbar.items = @[self.leftSpaceItem, self.usernameItem, self.flexItem, self.timeItem];
        }
    }
}

- (void)setTimeLabelString:(NSString*)timeLabel {
    //self.timeLabel.text = timeLabel;
    self.timeItem.title = timeLabel;
    [self setInstanceItems];
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
}


- (void)reactionsTap:(UIGestureRecognizer*)gc {
    NSLog(@"reacitons tap");
    //PFObject *reaction = [self.userImageFiles objectAtIndex:0];
    NSDictionary *info;
//    if ([self.userImageFiles respondsToSelector:@selector(count)] && [self.userImageFiles count] == 1) {
//        NSString *url = (NSString*)[[reaction objectForKey:kGVActivityVideoKey] url];
//        info = @{@"url": url};
//    } else {
        info = @{@"indexPath": self.cellIndexPath};
    //}
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GVThreadCollectionViewCellSelectIdentifier" object:nil userInfo:info];
}

- (void)setSendUsernameText:(NSString*)text {
    self.usernameItem.title = text;
    [self setInstanceItems];
}

- (void)setVideoLengthText:(NSString*)text {
    self.lengthItem.title = text;
    [self setInstanceItems];
}


- (void)prepareForReuse {
    [super prepareForReuse];
    self.userImageFiles = nil;
    [self.reactionsLabel setText:nil];
    [self.collectionView reloadData];
    //[self setSendUsernameText:nil];
    //[self setTimeLabelString:nil];
    //self.showRecord = NO;
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

    CGFloat detailHeight = 70;
    CGFloat detailPadding = 4.5;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        detailPadding = 14;
    }

    self.thumbnailView.frame = CGRectMake(detailPadding, 0, self.contentView.frame.size.width - (detailPadding*2), self.contentView.frame.size.height - detailHeight - GVThreadTableViewCellBottomMargin);


    [self.reactionsLabel sizeToFit];
    self.reactionsLabel.frame = CGRectMake(30, self.contentView.frame.size.height - detailHeight + ((detailHeight / 2) - (self.reactionsLabel.frame.size.height / 2)) - GVThreadTableViewCellBottomMargin, self.reactionsLabel.frame.size.width, self.reactionsLabel.frame.size.height);

    CGFloat collectionPadding = 158;
    self.collectionView.frame = CGRectMake(collectionPadding, self.contentView.frame.size.height - detailHeight - GVThreadTableViewCellBottomMargin, self.contentView.frame.size.width - collectionPadding, detailHeight);

    CGFloat borderPadding = 25;
    CGFloat borderHeight = 1;
    self.bottomBorderView.frame = CGRectMake(borderPadding, self.contentView.frame.size.height - borderHeight - GVThreadTableViewCellBottomMargin, self.contentView.frame.size.width - borderPadding, borderHeight);
//    [self.timeLabel sizeToFit];
//
//    CGRect timeFrame = self.timeLabel.frame;
//    timeFrame.origin.y = self.contentView.frame.size.height - timeFrame.size.height - GVThreadTableViewCellBottomMargin;
//    timeFrame.origin.x = self.contentView.frame.size.width - timeFrame.size.width - detailPadding;
//    self.timeLabel.frame = timeFrame;

    self.tableViewCell.frame = CGRectMake(0, self.contentView.frame.size.height - detailHeight - GVThreadTableViewCellBottomMargin + borderHeight, self.contentView.frame.size.width, detailHeight);
    [self.contentView bringSubviewToFront:self.tableViewCell];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.userImageFiles count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GVThreadCollectionViewCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:GVThreadTableViewCellCollectionViewCellIdentifier forIndexPath:indexPath];

    [cell removeAllSubImageViews];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    PFObject *reaction = [self.userImageFiles objectAtIndex:indexPath.row];
    NSString *url = (NSString*)[[reaction objectForKey:kGVActivityVideoThumbnailKey] url];
    if ([url respondsToSelector:@selector(length)] && ([url length] > 0)) {
        PFUser *user = [reaction objectForKey:kGVActivityUserKey];
        if (user) {
            [GVTwitterAuthUtility shouldGetProfileImageForAnyUser:[user username] block:^(NSURL *imageURL, NSURL *bannerURL, NSString *realname) {
                [imageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageHighPriority];
            }];
        }
    }

    cell.displaySendMessage = self.displaySentMessage;

    cell.thumbnailImageView = imageView;
    cell.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;

    //CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
    //    if (self.displaySentMessage) {
    //        transform = CGAffineTransformScale(transform, -1, 1);
    //        transform = CGAffineTransformRotate(transform, DEGREES_TO_RADIANS(180));
    //    } else {
    //
    //    }

    //cell.thumbnailImageView.transform = transform;
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
    if (action == @selector(saveAction:)) {
        return YES;
    }
    return (action == @selector(inviteAction:));
}

- (void)saveAction:(id)sender {
    @weakify(self);
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    [op addExecutionBlock:^{
        @strongify(self);
        NSDictionary *saveInfo = @{@"contentURL": self.contentURL};
        [[NSNotificationCenter defaultCenter] postNotificationName:GVSaveMovieNotification object:nil userInfo:saveInfo];
        //[self saveRequested];
    }];
    NSDictionary *info = @{@"op": op};
    [[NSNotificationCenter defaultCenter] postNotificationName:GVInternetRequestNotification object:nil userInfo:info];
}

- (void)inviteAction:(id)sender
{
    if (self.threadId) {
        NSString *path = [NSString stringWithFormat:@"http://gvideoapp.com/t/%@", self.threadId];
        NSURL *threadURL = [NSURL URLWithString:path];
        [[UIPasteboard generalPasteboard] setString:path];
        [self resignFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadDidSaveNotification object:nil userInfo:@{@"threadURL": threadURL}];
    }
}

#pragma mark - Gestures

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;

    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *inviteMenu = [[UIMenuItem alloc] initWithTitle:@"Invite" action:@selector(inviteAction:)];
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Save to Camera Roll" action:@selector(saveAction:)];
    [[UIMenuController sharedMenuController] setMenuItems:@[inviteMenu, menuItem]];
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

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//    self.selectedBackgroundView = nil;
//}

@end
