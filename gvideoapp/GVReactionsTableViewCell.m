//
//  GVReactionsTableViewCell.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/3/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVReactionsTableViewCell.h"
#import "MBProgressHUD.h"
#import "GVUnreadDotView.h"
#import "GVReactionsThumbnailView.h"


@interface GVReactionsTableViewCell ()

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) NSDictionary *normalUsernameAttributes;
@property (nonatomic, strong) NSDictionary *highlightUsernameAttributes;

@property (nonatomic, strong) NSDictionary *normalTimeAttributes;
@property (nonatomic, strong) NSDictionary *highlightTimeAttributes;

@property (nonatomic, strong) UILabel *highlightUsernameLabel;
@property (nonatomic, strong) UILabel *highlightTimeLabel;

@property (nonatomic, strong) GVUnreadDotView *recordDotView;

@property (nonatomic, strong) GVReactionsThumbnailView *thumbnailImageView;

@end

@implementation GVReactionsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.354 green:0.000 blue:0.401 alpha:1.000];

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handleLongPressGesture:)];
        [recognizer setMinimumPressDuration:0.4f];
        [self addGestureRecognizer:recognizer];

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = NSTextAlignmentLeft;

        UIColor *titleNormalColor = [UIColor colorWithRed:0.056 green:0.108 blue:0.340 alpha:1.000];
        //UIColor *purpleColor = [UIColor colorWithRed:0.024 green:0.022 blue:0.153 alpha:1.000];
        //UIColor *lightPurpleColor = [UIColor colorWithRed:0.050 green:0.042 blue:0.340 alpha:1.000];
        UIColor *titleNormalBackgroundColor = [UIColor whiteColor];
        //UIColor *titleNormalBackgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
        UIColor *highlightTitleColor = [UIColor whiteColor];
        UIColor *highlightTitleBgColor = [UIColor clearColor];
        //UIColor *highlightColor = self.selectedBackgroundView.backgroundColor;
        UIFont *titleNormalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
        UIFont *timeFont = [UIFont systemFontOfSize:14.0];
        UIColor *timeColor = [UIColor colorWithRed:0.814 green:0.821 blue:0.854 alpha:1.000];

        self.backgroundColor = titleNormalBackgroundColor;

        //self.backgroundView = [[GVMasterTableViewCellGradientView alloc] initWithFrame:self.backgroundView.bounds];

        self.normalUsernameAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                         NSForegroundColorAttributeName: titleNormalColor,
                                         NSBackgroundColorAttributeName: titleNormalBackgroundColor,
                                         NSFontAttributeName: titleNormalFont};

        self.normalTimeAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                         NSForegroundColorAttributeName: titleNormalColor,
                                         NSBackgroundColorAttributeName: titleNormalBackgroundColor,
                                         NSFontAttributeName: timeFont};

        self.highlightUsernameAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                         NSForegroundColorAttributeName: highlightTitleColor,
                                         NSBackgroundColorAttributeName: highlightTitleBgColor,
                                         NSFontAttributeName: titleNormalFont};

        self.highlightTimeAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                         NSForegroundColorAttributeName: highlightTitleColor,
                                         NSBackgroundColorAttributeName: highlightTitleBgColor,
                                         NSFontAttributeName: timeFont};
        

        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
        self.textLabel.opaque = YES;
        self.detailTextLabel.opaque = YES;

        self.highlightUsernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.highlightUsernameLabel.hidden = YES;
        [self.contentView addSubview:self.highlightUsernameLabel];
        self.highlightTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.highlightTimeLabel.hidden = YES;
        [self.contentView addSubview:self.highlightTimeLabel];



        self.thumbnailImageView = [[GVReactionsThumbnailView alloc] initWithFrame:CGRectZero];
        self.thumbnailImageView.clipsToBounds = NO;
        [self.contentView addSubview:self.thumbnailImageView];

    }
    return self;
}

- (void)setUsernameString:(NSString*)text {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:self.normalUsernameAttributes];
    NSAttributedString *highString = [[NSAttributedString alloc] initWithString:text attributes:self.highlightUsernameAttributes];
    [self.textLabel setAttributedText:attrString];
    [self.highlightUsernameLabel setAttributedText:highString];

}

- (void)setTimeString:(NSString*)text {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:self.normalTimeAttributes];
    NSAttributedString *highString = [[NSAttributedString alloc] initWithString:text attributes:self.highlightTimeAttributes];
    [self.detailTextLabel setAttributedText:attrString];
    [self.highlightTimeLabel setAttributedText:highString];
}

//
//- (void)awakeFromNib
//{
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

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
    return NO;
}

- (void)removeAllSubImageViews {
    for (UIImageView *imageView in self.thumbnailImageView.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
}

- (BOOL)getIsSelected {
    return (self.selectedBackgroundView.superview != nil);
}

- (void)setWaitingLabelAttributedStrings:(BOOL)selected {
    self.textLabel.hidden = selected;
    self.detailTextLabel.hidden = selected;
    self.highlightUsernameLabel.hidden = !selected;
    self.highlightTimeLabel.hidden = !selected;
}

- (void)setThumbImageView:(UIImageView*)imageView {
    self.thumbnailImageView.imageView = imageView;
    [self.thumbnailImageView addSubview:imageView];
    imageView.layer.cornerRadius = 1;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self.recordDotView setNeedsLayout];
}


- (void)layoutSubviews {
    [super layoutSubviews];

    [self.recordDotView layoutIfNeeded];

    CGFloat contentPadding = 10;

    [self setWaitingLabelAttributedStrings:[self getIsSelected]];

    CGFloat thumbHeight = self.frame.size.height - (contentPadding*2);
    //self.thumbImageView.layer.cornerRadius = thumbHeight / 2;
    self.thumbnailImageView.clipsToBounds = NO;
    self.thumbnailImageView.frame = CGRectIntegral(CGRectMake(contentPadding, contentPadding, thumbHeight, thumbHeight));

    CGFloat textPadding = 8;

    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.x += thumbHeight + contentPadding + textPadding;
    self.textLabel.frame = CGRectIntegral(textFrame);
    self.highlightUsernameLabel.frame = CGRectIntegral(textFrame);

    CGRect detailFrame = self.detailTextLabel.frame;
    detailFrame.origin.x += thumbHeight + contentPadding + textPadding;
    self.detailTextLabel.frame = CGRectIntegral(detailFrame);
    self.highlightTimeLabel.frame = CGRectIntegral(detailFrame);
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

#pragma mark - Gestures

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;

    UIMenuController *menu = [UIMenuController sharedMenuController];
    //UIMenuItem *inviteMenu = [[UIMenuItem alloc] initWithTitle:@"Invite" action:@selector(inviteAction:)];
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Save to Camera Roll" action:@selector(saveAction:)];
    [[UIMenuController sharedMenuController] setMenuItems:@[menuItem]];
    CGRect targetRect = [self convertRect:self.thumbnailImageView.frame
                                 fromView:self.contentView];

    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];

    self.thumbnailImageView.alpha = 0.6;
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
    self.thumbnailImageView.alpha = 1;

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
