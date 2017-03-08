//
//  GVMasterSectionHeaderView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/9/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#define TESTING_SECTION_HEADER_CONTENT_VIEW 1
#define TESTING_WAITING_LABEL0 0

#import "GVMasterSectionHeaderView.h"



@implementation GVMasterSectionHeaderShellView

- (void)drawRect:(CGRect)rect {
    //if ([self superview].layer.needsLayout) {
    //   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[self superview] performSelector:@selector(drawContentRect:) withObject:[NSValue valueWithCGRect:rect]];
    //  });
    //}
}

@end


@interface GVMasterSectionHeaderView ()
#if TESTING_WAITING_LABEL0
@property (nonatomic, strong) UILabel *waitingLabel0;
@property (nonatomic, strong) CAGradientLayer *waitingLabel0MaskGradient;
@property (nonatomic, strong) CAShapeLayer *waitingLabel0Mask;
@property (nonatomic, strong) CAShapeLayer *waitingLabel0MaskShape1;
@property (nonatomic, strong) CAShapeLayer *waitingLabel0MaskShape2;
@property (nonatomic, strong) NSAttributedString *waitingLabel1String;
@property (nonatomic, strong) NSAttributedString *waitingLabel2String;
@property (nonatomic, strong) NSAttributedString *waitingLabel3String;
#else
@property (nonatomic, strong) UILabel *waitingLabel1;
@property (nonatomic, strong) CAGradientLayer *waitingLabel1Mask;
@property (nonatomic, strong) UILabel *waitingLabel2;
@property (nonatomic, strong) CAShapeLayer *waitingLabel2Mask;
@property (nonatomic, strong) UILabel *waitingLabel3;
@property (nonatomic, strong) CAShapeLayer *waitingLabel3Mask;
#endif
@property (nonatomic, strong) UITableViewCell *tableViewCell;
@property (nonatomic, copy) NSDictionary *userTextAttributes;
//@property (nonatomic, copy) NSDictionary *userHighlightAttributes;

@property (nonatomic, copy) NSDictionary *timeTextAttributes;
//@property (nonatomic, copy) NSDictionary *timeHighlightAttributes;


@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAGradientLayer *contentGradientLayer;

@property (nonatomic, strong) UIImageView *thumbImageView;

#if TESTING_SECTION_HEADER_CONTENT_VIEW
@property (nonatomic, strong) UIView *mainContentView;

#endif
@end

@implementation GVMasterSectionHeaderView

- (BOOL)isCustomClickableScrollViewObject {
    return YES;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.contentView.backgroundColor = [UIColor blackColor];
        self.userInteractionEnabled = YES;

//        for (UIView *view in self.contentView.subviews) {
//            [view removeFromSuperview];
//        }
//
//        for (UIView *view in self.backgroundView.subviews) {
//            [view removeFromSuperview];
//        }
//
//        for (UIView *view in self.subviews) {
//            [view removeFromSuperview];
//        }

        //self.hidden = YES;
#if TESTING_PERF
        self.hidden = YES;
#endif
        self.exclusiveTouch = YES;
        //self.contentView.opaque = YES;
        //self.opaque = YES;
        //self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.contentView.exclusiveTouch = NO;
        self.contentView.userInteractionEnabled = NO;
        //self.contentView.layer.contentsScale = [UIScreen mainScreen].scale;
        self.contentView.layer.shouldRasterize = YES;
        self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.backgroundView.userInteractionEnabled = NO;
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
#if TESTING_SECTION_HEADER_CONTENT_VIEW
        [self.backgroundView removeFromSuperview];
        //[self.contentView removeFromSuperview];
        self.backgroundView = nil;
        self.tintColor = [UIColor whiteColor];
        //self.backgroundColor = [UIColor whiteColor];
        
        //self.contentView = nil;
#else
        self.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
#endif
        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;

        //self.contentView.backgroundColor = [UIColor clearColor];
        //self.contentView.layer.shouldRasterize = YES;
        //self.contentView.hidden = YES;
        //self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;

        //self.backgroundView = nil;
        //self.backgroundColor = [UIColor clearColor];

        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.shouldRasterize = YES;
        _gradientLayer.rasterizationScale = [UIScreen mainScreen].scale;
        _gradientLayer.contentsScale = [UIScreen mainScreen].scale;
        _gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        _gradientLayer.startPoint = CGPointMake(0.0f, -1.6f);
        _gradientLayer.endPoint = CGPointMake(0.0, 0.8f);
        //self.contentView.layer.mask = _gradientLayer;
#if TESTING_SECTION_HEADER_CONTENT_VIEW
        _mainContentView = [[UIView alloc] initWithFrame:CGRectZero];
        //_mainContentView.layer.contentsScale = [UIScreen mainScreen].scale;
        _mainContentView.layer.shouldRasterize = YES;
        _mainContentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _mainContentView.translatesAutoresizingMaskIntoConstraints = NO;
        _mainContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _mainContentView.opaque = YES;
        _mainContentView.backgroundColor = [UIColor whiteColor];


        _shellView = [[GVMasterSectionHeaderShellView alloc] initWithFrame:CGRectZero];
        _shellView.translatesAutoresizingMaskIntoConstraints = NO;
        _shellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _shellView.opaque = YES;
        //_shellView.layer.contentsScale = [UIScreen mainScreen].scale;
        _shellView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_shellView];
        _shellView.layer.mask = _gradientLayer;

        _contentGradientLayer = [CAGradientLayer layer];
        _contentGradientLayer.shouldRasterize = YES;
        _contentGradientLayer.rasterizationScale = [UIScreen mainScreen].scale;
        _contentGradientLayer.contentsScale = [UIScreen mainScreen].scale;
        _contentGradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        _contentGradientLayer.startPoint = CGPointMake(0.0f, -1.6f);
        _contentGradientLayer.endPoint = CGPointMake(0.0, 0.8f);
        _mainContentView.layer.mask = _contentGradientLayer;
#else

#endif
        //self.layer.mask = _gradientLayer;
        //self.glassView = [[LFGlassView alloc] initWithFrame:CGRectZero];
        //self.glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.glassView.translatesAutoresizingMaskIntoConstraints = NO;
        //[self.contentView addSubview:self.glassView];


        _tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GVMasterSectionHeaderViewCellIdentifier];
        //self.tableViewCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.tableViewCell.translatesAutoresizingMaskIntoConstraints = NO;
        _tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _tableViewCell.backgroundColor = [UIColor clearColor];
        //self.tableViewCell.accessoryView.alpha = 0.7;
        _tableViewCell.backgroundView = nil;
        _tableViewCell.contentView.frame = CGRectZero;
        _tableViewCell.userInteractionEnabled = NO;
        _tableViewCell.contentView.hidden = YES;
        _tableViewCell.contentView.exclusiveTouch = NO;
        _tableViewCell.accessoryView.exclusiveTouch = NO;
        _tableViewCell.contentView.userInteractionEnabled = NO;
        _tableViewCell.accessoryView.userInteractionEnabled = NO;
        _tableViewCell.alpha = 0.6;
        //_tableViewCell.hidden = YES;

        NSArray *subviews = _tableViewCell.subviews;
        for (UIView *subview in subviews) {
            if ([subview respondsToSelector:@selector(setScrollEnabled:)]) {
                UIScrollView *scrollView = (UIScrollView *)subview;
                [scrollView setScrollEnabled:NO];
                [scrollView setUserInteractionEnabled:NO];
                [scrollView setCanCancelContentTouches:NO];
                [scrollView setExclusiveTouch:NO];
            }
        }
        //self.tableViewCell.editingStyle = UITableViewCellEditingStyleNone;
#if TESTING_SECTION_HEADER_CONTENT_VIEW
        //[_mainContentView addSubview:_tableViewCell];
#else
        [self.contentView addSubview:_tableViewCell];
#endif




        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = NSTextAlignmentLeft;

        UIColor *titleNormalColor = [UIColor colorWithWhite:0.2 alpha:1.0];//[UIColor colorWithRed:0.056 green:0.108 blue:0.340 alpha:1.000];
                                                                           //UIColor *purpleColor = [UIColor colorWithRed:0.024 green:0.022 blue:0.153 alpha:1.000];
                                                                           //UIColor *lightPurpleColor = [UIColor colorWithRed:0.050 green:0.042 blue:0.340 alpha:1.000];
        UIColor *titleNormalBackgroundColor = [UIColor clearColor];

        //UIColor *titleNormalBackgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
        UIColor *highlightTitleColor = [UIColor whiteColor];
        UIColor *highlightTitleBgColor = [UIColor clearColor];
        //UIColor *highlightColor = self.selectedBackgroundView.backgroundColor;
        UIFont *titleNormalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        UIFont *timeFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        UIColor *timeColor = [UIColor colorWithRed:0.814 green:0.821 blue:0.854 alpha:1.000];

        UIColor *sendColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        UIFont *sendFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];

        //self.backgroundColor = titleNormalBackgroundColor;
        //self.normalBackgroundColor = titleNormalBackgroundColor;
        //self.oddBackgroundColor = [UIColor blackColor];
        //self.backgroundView = [[GVMasterTableViewCellGradientView alloc] initWithFrame:self.backgroundView.bounds];

//        self.userHighlightAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
//                                         NSForegroundColorAttributeName: highlightTitleColor,
//                                         NSBackgroundColorAttributeName: highlightTitleBgColor,
//                                         NSFontAttributeName: titleNormalFont};
//
//        self.timeHighlightAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
//                                         NSForegroundColorAttributeName: highlightTitleColor,
//                                         NSBackgroundColorAttributeName: highlightTitleBgColor,
//                                         NSFontAttributeName: timeFont};

        _userTextAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                    NSForegroundColorAttributeName: titleNormalColor,
                                    NSBackgroundColorAttributeName: titleNormalBackgroundColor,
                                    NSFontAttributeName: titleNormalFont};

        _timeTextAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                    NSForegroundColorAttributeName: timeColor,
                                    NSBackgroundColorAttributeName: titleNormalBackgroundColor,
                                    NSFontAttributeName: timeFont};

        NSDictionary *sendAttribute = @{NSParagraphStyleAttributeName: paragraphStyle,
                                    NSForegroundColorAttributeName: sendColor,
                                    NSBackgroundColorAttributeName: titleNormalBackgroundColor,
                                    NSFontAttributeName: timeFont};

//        NSDictionary *sendAttributeHigh = @{NSParagraphStyleAttributeName: paragraphStyle,
//                                         NSForegroundColorAttributeName: highlightTitleColor,
//                                         NSBackgroundColorAttributeName: highlightTitleBgColor,
//                                         NSFontAttributeName: sendFont};


        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        //_timeLabel.opaque = YES;
        //_timeLabel.alpha = 0.0;
        _timeLabel.userInteractionEnabled = NO;
        _timeLabel.layer.shouldRasterize = YES;
        _timeLabel.layer.contentsScale = [UIScreen mainScreen].scale;
        _timeLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _timeLabel.backgroundColor = titleNormalBackgroundColor;
#if TESTING_SECTION_HEADER_CONTENT_VIEW
        [_mainContentView addSubview:_timeLabel];
#else
        [self.contentView addSubview:_timeLabel];
#endif

//        self.timeLabelHigh = [[UILabel alloc] initWithFrame:CGRectZero];
//        //self.timeLabelHigh.opaque = YES;
//        self.timeLabelHigh.userInteractionEnabled = NO;
//        self.timeLabelHigh.layer.shouldRasterize = YES;
//        self.timeLabelHigh.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        self.timeLabelHigh.hidden = YES;
//        //self.timeLabelHigh.backgroundColor = highlightColor;
//        [self.contentView addSubview:self.timeLabelHigh];


        _usersLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        //_usersLabel.opaque = YES;
        //_usersLabel.layer.contentsScale = [UIScreen mainScreen].scale;
        _usersLabel.userInteractionEnabled = NO;
        _usersLabel.backgroundColor = titleNormalBackgroundColor;
        _usersLabel.layer.shouldRasterize = YES;
        _usersLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
#if TESTING_SECTION_HEADER_CONTENT_VIEW
        [_mainContentView addSubview:_usersLabel];
#else
        [self.contentView addSubview:_usersLabel];
#endif



//        _usersLabelMask = [CAGradientLayer layer];
//        _usersLabelMask.contentsScale = [UIScreen mainScreen].scale;
//        _usersLabelMask.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
//        _usersLabelMask.startPoint = CGPointMake(0.0, -1.6f);
//        _usersLabelMask.endPoint = CGPointMake(0.0, 0.4f);
//        _usersLabelMask.shouldRasterize = YES;
//        _usersLabelMask.rasterizationScale = [UIScreen mainScreen].scale;
        //_usersLabelMask.duration = 0.0;
        //_usersLabel.layer.mask = _usersLabelMask;


//        self.usersLabelHigh = [[UILabel alloc] initWithFrame:CGRectZero];
//        //self.usersLabelHigh.opaque = YES;
//        self.usersLabelHigh.userInteractionEnabled = NO;
//        self.usersLabelHigh.layer.shouldRasterize = YES;
//        self.usersLabelHigh.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        self.usersLabelHigh.hidden = YES;
//        //self.usersLabelHigh.layer.duration = 0.0;
//        //self.usersLabelHigh.backgroundColor = highlightColor;
//        [self.contentView addSubview:self.usersLabelHigh];

//        self.usersLabelHighMask = [CAGradientLayer layer];
//        self.usersLabelHighMask.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
//        self.usersLabelHighMask.startPoint = CGPointMake(0.0, -1.6f);
//        self.usersLabelHighMask.endPoint = CGPointMake(0.0, 0.6f);
//        //self.usersLabelHighMask.duration = 0.0;
//        self.usersLabelHigh.layer.mask = self.usersLabelHighMask;

#if TESTING_WAITING_LABEL0
        _waitingLabel0 = [[UILabel alloc] initWithFrame:CGRectZero];
        _waitingLabel0.userInteractionEnabled = NO;
        _waitingLabel0.layer.shouldRasterize = YES;
        _waitingLabel0.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_waitingLabel0];



        _waitingLabel0MaskGradient = [CAGradientLayer layer];
        _waitingLabel0MaskGradient.contentsScale = [UIScreen mainScreen].scale;
        _waitingLabel0MaskGradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        _waitingLabel0MaskGradient.startPoint = CGPointMake(0.0, -1.6f);
        _waitingLabel0MaskGradient.endPoint = CGPointMake(0.0, 0.6f);
        //_waitingLabel0.layer.mask = _waitingLabel1Mask;

        _waitingLabel0MaskShape1 = [CAShapeLayer layer];
        _waitingLabel0MaskShape1.fillColor = [UIColor whiteColor].CGColor;
        _waitingLabel0MaskShape1.backgroundColor = [UIColor whiteColor].CGColor;
        _waitingLabel0MaskShape2 = [CAShapeLayer layer];
        _waitingLabel0MaskShape2.fillColor = [UIColor whiteColor].CGColor;
        _waitingLabel0MaskShape2.backgroundColor = [UIColor whiteColor].CGColor;


        _waitingLabel0Mask = [CAShapeLayer layer];
        [_waitingLabel0Mask addSublayer:_waitingLabel0MaskShape1];
        [_waitingLabel0Mask addSublayer:_waitingLabel0MaskShape2];
        [_waitingLabel0Mask addSublayer:_waitingLabel0MaskGradient];

        _waitingLabel0.layer.mask = _waitingLabel0Mask;

        NSString *waitingText1 = @"Waiting on recipients.";
        NSString *waitingText2 = @"Waiting on recipients..";
        NSString *waitingText3 = @"Waiting on recipients...";
        _waitingLabel1String = [[NSAttributedString alloc] initWithString:waitingText1 attributes:self.userTextAttributes];
        _waitingLabel2String = [[NSAttributedString alloc] initWithString:waitingText2 attributes:self.userTextAttributes];
        _waitingLabel3String = [[NSAttributedString alloc] initWithString:waitingText3 attributes:self.userTextAttributes];
        [_waitingLabel0 setAttributedText:_waitingLabel3String];

#else
        _waitingLabel3 = [[UILabel alloc] initWithFrame:CGRectZero];
        //_waitingLabel3.opaque = YES;
        _waitingLabel3.userInteractionEnabled = NO;
        //_waitingLabel3.layer.duration = 0.0;
        _waitingLabel3.layer.contentsScale = [UIScreen mainScreen].scale;
        _waitingLabel3.layer.shouldRasterize = YES;
        _waitingLabel3.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        _waitingLabel3.backgroundColor = titleNormalBackgroundColor;
        //#if TESTING_SECTION_HEADER_CONTENT_VIEW
        //#else
        //[self.contentView addSubview:_waitingLabel3];
        //#endif
        _waitingLabel3.alpha = 0;

        _waitingLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
        //_waitingLabel2.opaque = YES;
        _waitingLabel2.userInteractionEnabled = NO;
        _waitingLabel2.layer.shouldRasterize = YES;
        _waitingLabel2.layer.contentsScale = [UIScreen mainScreen].scale;
        //_waitingLabel2.layer.duration = 0.0;
        _waitingLabel2.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _waitingLabel2.backgroundColor = titleNormalBackgroundColor;
        //#if TESTING_SECTION_HEADER_CONTENT_VIEW
        //#else
        //[self.contentView addSubview:_waitingLabel2];
        //#endif
        _waitingLabel2.alpha = 0;

        _waitingLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
        //_waitingLabel1.opaque = YES;
        _waitingLabel1.userInteractionEnabled = NO;
        _waitingLabel1.layer.contentsScale = [UIScreen mainScreen].scale;
        _waitingLabel1.layer.allowsEdgeAntialiasing = YES;
        _waitingLabel1.layer.shouldRasterize = YES;
        _waitingLabel1.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _waitingLabel1.backgroundColor = titleNormalBackgroundColor;
        //#if TESTING_SECTION_HEADER_CONTENT_VIEW
        //#else
        //[self.contentView addSubview:_waitingLabel1];
        //#endif
        _waitingLabel1.alpha = 0;


//        self.waitingLabel3High = [[UILabel alloc] initWithFrame:CGRectZero];
//        //self.waitingLabel3High.opaque = YES;
//        self.waitingLabel3High.userInteractionEnabled = NO;
//        self.waitingLabel3High.layer.shouldRasterize = YES;
//        self.waitingLabel3High.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        //self.waitingLabel3High.backgroundColor = highlightColor;
//        [self.contentView addSubview:self.waitingLabel3High];
//        self.waitingLabel3High.alpha = 0;
//
//        self.waitingLabel2High = [[UILabel alloc] initWithFrame:CGRectZero];
//        //self.waitingLabel2High.opaque = YES;
//        self.waitingLabel2High.userInteractionEnabled = NO;
//        self.waitingLabel2High.layer.shouldRasterize = YES;
//        self.waitingLabel2High.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        //_waitingLabel1High.backgroundColor = highlightColor;
//        [self.contentView addSubview:self.waitingLabel2High];
//        self.waitingLabel2High.alpha = 0;
//
//        _waitingLabel1High = [[UILabel alloc] initWithFrame:CGRectZero];
//        //_waitingLabel1High.opaque = YES;
//        _waitingLabel1High.userInteractionEnabled = NO;
//        _waitingLabel1High.layer.shouldRasterize = YES;
//        _waitingLabel1High.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        //_waitingLabel1High.backgroundColor = highlightColor;
//        [self.contentView addSubview:_waitingLabel1High];
//        _waitingLabel1High.alpha = 0;


//        _waitingLabel1Mask = [CAGradientLayer layer];
//        _waitingLabel1Mask.contentsScale = [UIScreen mainScreen].scale;
//        _waitingLabel1Mask.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
//        _waitingLabel1Mask.startPoint = CGPointMake(0.0, -1.6f);
//        _waitingLabel1Mask.endPoint = CGPointMake(0.0, 0.6f);
//        _waitingLabel1.layer.mask = _waitingLabel1Mask;


        _waitingLabel2Mask = [CAShapeLayer layer];
        _waitingLabel2Mask.contentsScale = [UIScreen mainScreen].scale;
        _waitingLabel2Mask.fillColor = [UIColor blackColor].CGColor;
        _waitingLabel2.layer.mask = _waitingLabel2Mask;

//        _waitingLabel2HighMask = [CAShapeLayer layer];
//        _waitingLabel2HighMask.fillColor = [UIColor blackColor].CGColor;
//        _waitingLabel2High.layer.mask = _waitingLabel2HighMask;

        _waitingLabel3Mask = [CAShapeLayer layer];
        _waitingLabel3Mask.contentsScale = [UIScreen mainScreen].scale;
        _waitingLabel3Mask.fillColor = [UIColor blackColor].CGColor;
        _waitingLabel3.layer.mask = _waitingLabel3Mask;

//        self.waitingLabel3HighMask = [CAShapeLayer layer];
//        self.waitingLabel3HighMask.fillColor = [UIColor blackColor].CGColor;
//        self.waitingLabel3High.layer.mask = self.waitingLabel3HighMask;

        NSString *waitingText1 = @"Waiting on recipients.";
        NSString *waitingText2 = @"Waiting on recipients..";
        NSString *waitingText3 = @"Waiting on recipients...";
        NSAttributedString *waitingString1 = [[NSAttributedString alloc] initWithString:waitingText1 attributes:self.userTextAttributes];
        NSAttributedString *waitingString2 = [[NSAttributedString alloc] initWithString:waitingText2 attributes:self.userTextAttributes];
        NSAttributedString *waitingString3 = [[NSAttributedString alloc] initWithString:waitingText3 attributes:self.userTextAttributes];
//        NSAttributedString *waitingString1High = [[NSAttributedString alloc] initWithString:waitingText1 attributes:self.userHighlightAttributes];
//        NSAttributedString *waitingString2High = [[NSAttributedString alloc] initWithString:waitingText2 attributes:self.userHighlightAttributes];
//        NSAttributedString *waitingString3High = [[NSAttributedString alloc] initWithString:waitingText3 attributes:self.userHighlightAttributes];

        [_waitingLabel1 setAttributedText:waitingString1];
        [_waitingLabel2 setAttributedText:waitingString2];
        [_waitingLabel3 setAttributedText:waitingString3];
        
        //[self.contentView addSubview:_waitingLabel1];
        //[self.contentView addSubview:_waitingLabel2];
        //[self.contentView addSubview:self.waitingLabel3];

//        [_waitingLabel1High setAttributedText:waitingString1High];
//        [self.waitingLabel2High setAttributedText:waitingString2High];
//        [self.waitingLabel3High setAttributedText:waitingString3High];
#endif
        [self setWaitingLabelAttributedStrings:NO];

        NSString *sendStringText = @"Tap to send";

        NSAttributedString *sendString = [[NSAttributedString alloc] initWithString:sendStringText attributes:sendAttribute];

        //NSAttributedString *sendHighlight = [[NSAttributedString alloc] initWithString:sendStringText attributes:sendAttributeHigh];

        _sendLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_sendLabel setAttributedText:sendString];
        _sendLabel.layer.contentsScale = [UIScreen mainScreen].scale;
        _sendLabel.layer.shouldRasterize = YES;
        _sendLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
#if TESTING_SECTION_HEADER_CONTENT_VIEW
        [_mainContentView addSubview:_sendLabel];
#else
        [self.contentView addSubview:_sendLabel];
#endif


//        _sendLabelHigh = [[UILabel alloc] initWithFrame:CGRectZero];
//        [self.sendLabelHigh setAttributedText:sendHighlight];
//        self.sendLabelHigh.layer.shouldRasterize = YES;
//        self.sendLabelHigh.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        [self.contentView addSubview:self.sendLabelHigh];
//        self.sendLabelHigh.hidden = YES;


//        self.tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//        self.tapGestureRecognizer.minimumPressDuration = 0.01;
//        [self.contentView addGestureRecognizer:self.tapGestureRecognizer];

        _thumbImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glyphicons_180_facetime_video"]];
        _thumbImageView.alpha = 0.5;
        _thumbImageView.layer.contentsScale = [UIScreen mainScreen].scale;
        _thumbImageView.frame = CGRectZero;
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
        _thumbImageView.layer.shouldRasterize = YES;
        _thumbImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
#if TESTING_SECTION_HEADER_CONTENT_VIEW
        //[_mainContentView addSubview:_thumbImageView];
#else
        [self.contentView addSubview:_thumbImageView];
#endif




    }
    return self;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
#if TESTING_SECTION_HEADER_CONTENT_VIEW

    //for (UIView *view in self.subviews) {
    //    [view removeFromSuperview];
    //}
    if (![self.mainContentView superview]) {

        [self addSubview:self.mainContentView];
        //UIView *snapshotView = [self.mainContentView snapshotViewAfterScreenUpdates:YES];
        //[self.mainContentView removeFromSuperview];
        //[self addSubview:snapshotView];
    }
    [self.shellView setNeedsDisplay];
#endif
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self;
}

- (void)handleTapGesture:(UIGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gc locationInView:gc.view];
        NSDictionary *info = @{@"indexPath": self.indexPath};
        if (point.x < self.bounds.size.width * .7) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterSectionHeaderViewTapToSendNotification object:nil userInfo:info];
        } else {
            // go to history view
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterSectionHeaderSelectNotification object:nil userInfo:info];
        }
    }
}

- (void)handleTap:(NSValue*)point {

    NSDictionary *info = @{@"indexPath": self.indexPath};
    CGPoint cPoint = [point CGPointValue];
    if (cPoint.x < self.bounds.size.width * .7) {
        // tap to send
        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterSectionHeaderViewTapToSendNotification object:nil userInfo:info];
        //DLogFunctionLine();
    } else {
        // go to history view
        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterSectionHeaderSelectNotification object:nil userInfo:info];
    }
    //}
}

- (void)setUserTextString:(NSString*)string {

    //NSAttributedString *highlight = [[NSAttributedString alloc] initWithString:string attributes:self.userHighlightAttributes];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:string attributes:self.userTextAttributes];
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        //[CATransaction begin];
        //[CATransaction setAnimationDuration:0.0];

        DLogMainThread();

        self.userString = string;
        [self.usersLabel setAttributedText:title];
        //[self.usersLabelHigh setAttributedText:highlight];
#if TESTING_SECTION_HEADER_CONTENT_VIEW
        [self setNeedsLayout];
        [self layoutIfNeeded];
        [self setNeedsDisplay];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self setNeedsDisplay];
        });
        //[self.usersLabel sizeToFit];

        //[self setupSubviews];
        //[self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.0 inModes:@[NSRunLoopCommonModes]];
        //DLogObject(self.userString);
        //DLogCGRect(self.usersLabel.frame);

        //[CATransaction commit];
        //[self.layer displayIfNeeded];
        //[self.shellView setNeedsDisplay];
#else
        [self setupSubviews];
#endif
    });
}

//- (void)didMoveToWindow {
//    
//}

- (void)setTimeLabelString:(NSString*)string {
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:string attributes:self.timeTextAttributes];
    //NSAttributedString *highlight = [[NSAttributedString alloc] initWithString:string attributes:self.timeHighlightAttributes];
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
            self.timeString = string;
        [self.timeLabel setAttributedText:title];
        //[self.timeLabelHigh setAttributedText:highlight];
#if TESTING_SECTION_HEADER_CONTENT_VIEW
        [self setNeedsLayout];
        [self layoutIfNeeded];
        //[self setupSubviews];
        [self setNeedsDisplay];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self setNeedsDisplay];
        });
#else
        [self setupSubviews];
#endif
    });
}


- (void)setWaitingLabelAttributedStrings:(BOOL)selected {
    if ([self.userString respondsToSelector:@selector(length)] && [self.userString length] > 0) {
#if TESTING_WAITING_LABEL0
        self.waitingLabel0Mask.opacity = 1.0;
        self.waitingLabel0Mask.fillColor = [UIColor blackColor].CGColor;
        self.waitingLabel0Mask.backgroundColor = [UIColor blackColor].CGColor;
        self.waitingLabel0.alpha = 0.0;
#else
        self.waitingLabel1.hidden = YES;
        //[self.waitingLabel1 removeFromSuperview];
        self.waitingLabel2.hidden = YES;
        //[self.waitingLabel2 removeFromSuperview];
        self.waitingLabel3.hidden = YES;
        //[self.waitingLabel3 removeFromSuperview];
#endif
//        if (![self.usersLabel superview]) {
//            [self addSubview:self.usersLabel];
//        }
        self.usersLabel.alpha = 1.0;
        //self.usersLabel.alpha = 0.0;
        //self.timeLabel.alpha = 1.0;
//        self.waitingLabel1High.hidden = YES;
//        self.waitingLabel2High.hidden = YES;
//        self.waitingLabel3High.hidden = YES;
//        self.usersLabelHigh.hidden = !selected;
//        self.timeLabelHigh.hidden = !selected;
//self.sendLabel.hidden = selected;
//        self.sendLabelHigh.hidden = !selected;

    } else {
#if TESTING_WAITING_LABEL0
        self.waitingLabel0Mask.opacity = 1.0;
        self.waitingLabel0Mask.fillColor = [UIColor clearColor].CGColor;
        self.waitingLabel0Mask.backgroundColor = [UIColor clearColor].CGColor;
        self.waitingLabel0.alpha = 1.0;
#else
        self.waitingLabel1.hidden = selected;
        //if (![self.waitingLabel1 superview]) {
        //    [self.contentView addSubview:self.waitingLabel1];
        //}
        self.waitingLabel2.hidden = selected;
        //if (![self.waitingLabel2 superview]) {
        //    [self.contentView addSubview:self.waitingLabel2];
        //}
        self.waitingLabel3.hidden = selected;
        //if (![self.waitingLabel3 superview] ) {
        //    [self.contentView addSubview:self.waitingLabel3];
        //}
#endif
        //[self.usersLabel removeFromSuperview];
        self.usersLabel.alpha = 0.0;
        //self.usersLabel.alpha = 0.0;
        //self.timeLabel.alpha = 1.0;
//        self.waitingLabel1High.hidden = !selected;
//        self.waitingLabel2High.hidden = !selected;
//        self.waitingLabel3High.hidden = !selected;
//        self.usersLabelHigh.hidden = !selected;
//        self.timeLabelHigh.hidden = !selected;
        //self.sendLabel.hidden = selected;
//        self.sendLabelHigh.hidden = !selected;
    }

    //    self.waitingLabel1.hidden = selected;
    //    self.waitingLabel2.hidden = selected;
    //    self.waitingLabel3.hidden = selected;
    //    self.usersLabel.hidden = selected;
    //    self.timeLabel.hidden = selected;
    //    self.waitingLabel1High.hidden = !selected;
    //    self.waitingLabel2High.hidden = !selected;
    //    self.waitingLabel3High.hidden = !selected;
    //    self.usersLabelHigh.hidden = !selected;
    //    self.timeLabelHigh.hidden = !selected;
    //    if (selected) {
    //        //[self.waitingLabel2 setAttributedText:self.waitingString2High];
    //        //[self.waitingLabel3 setAttributedText:self.waitingString3High];
    //        //[self.waitingLabel1 setAttributedText:self.waitingString1High];
    //    } else {
    //        //[self.waitingLabel2 setAttributedText:self.waitingString2];
    //        //[self.waitingLabel3 setAttributedText:self.waitingString3];
    //        //[self.waitingLabel1 setAttributedText:self.waitingString1];
    //    }
    //self.timeLabel.alpha = 1.0;
    //self.sendLabel.alpha = 1.0;
}


//- (BOOL)getIsSelected {
//    return (self.superview != nil);
//}


- (void)layoutSubviews {
    [super layoutSubviews];

    //[CATransaction begin];
    //[CATransaction setAnimationDuration:0.0];

    self.tintColor = [UIColor colorWithWhite:1.0 alpha:0.95];


    self.gradientLayer.frame = CGRectIntegral(self.bounds);
    self.contentGradientLayer.frame = CGRectIntegral(self.bounds);
    //    if (self.backgroundView) {
    //
    //        while (0) {
    //
    //        }
    //    }



    CGFloat tableViewAccessoryPadding = 21;
    CGFloat tableViewAccessoryLeftOffset = 9;

    CGRect tableViewRect = self.bounds;
    tableViewRect.origin.x = tableViewAccessoryLeftOffset;
    tableViewRect.origin.y = tableViewAccessoryPadding;
    tableViewRect.size.height = 20;

    self.tableViewCell.frame = CGRectIntegral(tableViewRect);
    //self.tableViewCell.contentView.frame = self.tableViewCell.bounds;
    self.tableViewCell.accessoryView.frame = CGRectIntegral(self.tableViewCell.accessoryView.bounds);


    [self setWaitingLabelAttributedStrings:FALSE];

    //self.glassView.frame = self.bounds;

    [self.usersLabel sizeToFit];
    [self.timeLabel sizeToFit];


    CGPoint offsetLabels = CGPointMake(3.5, 0);
    CGFloat paddingBetweenUserAndTimeLabel = 5;

#if TESTING_WAITING_LABEL0
    [self.waitingLabel0 sizeToFit];

    CGRect waitingLabel0Offset = self.waitingLabel0.frame;
    waitingLabel0Offset.origin = offsetLabels;
    self.waitingLabel0.frame = CGRectIntegral(waitingLabel0Offset);

    self.waitingLabel0MaskGradient.frame = CGRectIntegral(self.waitingLabel0.bounds);

    CGSize waitingLabel1Size = [self.waitingLabel1String size];
    CGSize waitingLabel2Size = [self.waitingLabel2String size];

    CGRect waitingLabel0Bounds = self.waitingLabel0.bounds;

    CGFloat waitingLabel1Diff = waitingLabel0Bounds.size.width - waitingLabel1Size.width;
    CGRect waitingLabel0Mask1Rect = waitingLabel0Bounds;
    waitingLabel0Mask1Rect.origin.x = waitingLabel0Bounds.size.width - waitingLabel1Diff;
    waitingLabel0Mask1Rect.size.width = waitingLabel1Diff;
    self.waitingLabel0MaskShape1.frame = CGRectIntegral(waitingLabel0Mask1Rect);

    CGFloat waitingLabel2Diff = waitingLabel0Bounds.size.width - waitingLabel2Size.width;
    CGRect waitingLabel0Mask2Rect = waitingLabel0Bounds;
    waitingLabel0Mask2Rect.origin.x = waitingLabel0Bounds.size.width - waitingLabel2Diff;
    waitingLabel0Mask2Rect.size.width = waitingLabel2Diff;
    self.waitingLabel0MaskShape2.frame = CGRectIntegral(waitingLabel0Mask2Rect);

    self.waitingLabel0Mask.frame = CGRectIntegral(self.waitingLabel0.bounds);
#else
    [self.waitingLabel1 sizeToFit];
    [self.waitingLabel2 sizeToFit];
    [self.waitingLabel3 sizeToFit];


    CGRect waitingLabel1Offset = self.waitingLabel1.frame;
    waitingLabel1Offset.origin = offsetLabels;
    self.waitingLabel1.frame = CGRectIntegral(waitingLabel1Offset);
    //self.waitingLabel1High.frame = CGRectIntegral(waitingLabel1Offset);

    CGRect waitingLabel2Offset = self.waitingLabel2.frame;
    waitingLabel2Offset.origin = offsetLabels;
    self.waitingLabel2.frame = CGRectIntegral(waitingLabel2Offset);
    //self.waitingLabel2High.frame = CGRectIntegral(waitingLabel2Offset);

    CGRect waitingLabel3Offset = self.waitingLabel3.frame;
    waitingLabel3Offset.origin = offsetLabels;
    self.waitingLabel3.frame = CGRectIntegral(waitingLabel3Offset);
    //self.waitingLabel3High.frame = CGRectIntegral(waitingLabel3Offset);

    self.waitingLabel1Mask.frame = CGRectIntegral(self.waitingLabel1.bounds);
    //self.waitingLabel1HighMask.frame = CGRectIntegral(self.waitingLabel1.bounds);

    self.usersLabelMask.frame = CGRectIntegral(self.usersLabel.bounds);
    //self.usersLabelHighMask.frame = CGRectIntegral(self.usersLabel.bounds);


    self.waitingLabel2Mask.frame = CGRectIntegral(self.waitingLabel2.bounds);
    CGRect shapeMaskRect = CGRectMake(waitingLabel1Offset.size.width, 0, waitingLabel2Offset.size.width - waitingLabel1Offset.size.width, waitingLabel1Offset.size.height);
    self.waitingLabel2Mask.path = CGPathCreateWithRect(CGRectIntegral(shapeMaskRect), NULL);


    //self.waitingLabel2HighMask.frame = CGRectIntegral(self.waitingLabel2.bounds);
    //self.waitingLabel2HighMask.path = CGPathCreateWithRect(CGRectIntegral(shapeMaskRect), NULL);


    self.waitingLabel3Mask.frame = CGRectIntegral(self.waitingLabel3.bounds);
    CGRect shapeRect = CGRectMake(waitingLabel2Offset.size.width, 0, waitingLabel3Offset.size.width - waitingLabel2Offset.size.width, waitingLabel1Offset.size.height);
    self.waitingLabel3Mask.path = CGPathCreateWithRect(CGRectIntegral(shapeRect), NULL);

    //self.waitingLabel3HighMask.frame = CGRectIntegral(self.waitingLabel3.bounds);
    //self.waitingLabel3HighMask.path = CGPathCreateWithRect(CGRectIntegral(shapeRect), NULL);
#endif
    CGRect timeRect = self.timeLabel.frame;
    timeRect.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(timeRect) - offsetLabels.x -1;
    timeRect.origin.y = offsetLabels.y + 4;
    self.timeLabel.frame = CGRectIntegral(timeRect);
    //self.timeLabelHigh.frame = CGRectIntegral(timeRect);

    CGRect userLabelR = self.usersLabel.frame;
    userLabelR.size.width = CGRectGetWidth(self.bounds) - CGRectGetWidth(timeRect) - paddingBetweenUserAndTimeLabel;
    userLabelR.origin.x = offsetLabels.x;
    userLabelR.origin.y = offsetLabels.y;
    self.usersLabel.frame = CGRectIntegral(userLabelR);
    //self.usersLabelHigh.frame = CGRectIntegral(userLabelR);

    [self.mainContentView bringSubviewToFront:self.usersLabel];
#if TESTING_WAITING_LABEL0
    [self.contentView bringSubviewToFront:self.waitingLabel0];
#else
    [self.contentView bringSubviewToFront:self.waitingLabel3];
    [self.contentView bringSubviewToFront:self.waitingLabel2];
    [self.contentView bringSubviewToFront:self.waitingLabel1];
#endif
    //[self.contentView bringSubviewToFront:self.usersLabel];

    [self.sendLabel sizeToFit];

    CGFloat thumbImageSize = 11;
    CGFloat tapToSendY = self.bounds.size.height - self.sendLabel.frame.size.height - 4;

    self.thumbImageView.frame = CGRectIntegral(CGRectMake(offsetLabels.x, tapToSendY + (thumbImageSize/2) - 3, thumbImageSize, thumbImageSize));

    CGRect sendLabelRect = self.sendLabel.bounds;
    sendLabelRect.origin.x = offsetLabels.x+0.5 + self.thumbImageView.frame.size.width + offsetLabels.x;
    sendLabelRect.origin.y = tapToSendY-1;
    self.sendLabel.frame = CGRectIntegral(sendLabelRect);
    //self.sendLabelHigh.frame = CGRectIntegral(sendLabelRect);
    
    //[CATransaction commit];
}

//- (void)layoutSubviews {
////
//
//}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.userString = @"";
    self.timeString = @"";
    //[self setNeedsLayout];
    //[self setNeedsDisplay];
    //[self setUserString:@""];
    //[self setTimeLabelString:@""];
    //[self setWaitingLabelAttributedStrings:YES];
    //[self setNeedsDisplay];
}

- (void)startAnimatingWaitingDots {


#if TESTING_WAITING_LABEL0

    CAAnimationGroup *animatingDotsGroup = [CAAnimationGroup animation];


    CABasicAnimation *animatingDot2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animatingDot2.fromValue = [NSNumber numberWithFloat:1.0];
    animatingDot2.toValue = [NSNumber numberWithFloat:0.0];
    animatingDot2.duration = 1.0;
    animatingDot2.repeatCount = 999999;
    animatingDot2.repeatDuration = 999999;
    animatingDot2.removedOnCompletion = NO;
    animatingDot2.autoreverses = YES;

    [self.waitingLabel0MaskShape1 addAnimation:animatingDot2 forKey:nil];


#else
    @weakify(self);
    //dispatch_async(dispatch_get_main_queue(), ^{
    self.usersLabel.alpha = 0.0;
    self.waitingLabel1.hidden = NO;
    self.waitingLabel2.hidden = NO;
    self.waitingLabel3.hidden = NO;
    self.waitingLabel1.alpha = 1;
    self.waitingLabel2.alpha = 1;
    self.waitingLabel3.alpha = 1;
    //self.waitingLabel1High.alpha = 1;
    //self.waitingLabel2High.alpha = 1;
    //self.waitingLabel3High.alpha = 1;
    //});
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateKeyframesWithDuration:3 delay:0.0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.33 animations:^{
                @strongify(self);
                self.waitingLabel1.alpha = 1;
                self.waitingLabel2.alpha = 0;
                self.waitingLabel3.alpha = 0;
                //self_weak_.waitingLabel1High.alpha = 1;
                //self_weak_.waitingLabel2High.alpha = 0;
                //self_weak_.waitingLabel3High.alpha = 0;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.33 relativeDuration:0.33 animations:^{
                @strongify(self);
                self.waitingLabel1.alpha = 1;
                self.waitingLabel2.alpha = 1;
                self.waitingLabel3.alpha = 0;
                //self_weak_.waitingLabel1High.alpha = 1;
                //self_weak_.waitingLabel2High.alpha = 1;
                //self_weak_.waitingLabel3High.alpha = 0;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.66 relativeDuration:0.34 animations:^{
                @strongify(self);
                self.waitingLabel1.alpha = 1;
                self.waitingLabel2.alpha = 1;
                self.waitingLabel3.alpha = 1;
                //self_weak_.waitingLabel1High.alpha = 1;
                //self_weak_.waitingLabel2High.alpha = 1;
                //self_weak_.waitingLabel3High.alpha = 1;
            }];
        } completion:nil];
    });
#endif
}
#if TESTING_SECTION_HEADER_CONTENT_VIEW
- (void)drawContentRect:(CGRect)rect {
    
    //[self setupSubviews];
    //if (self.shellView.layer.needsDisplay) {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    //return;
    CGRect bounds = CGRectIntegral(rect);

    CGContextRef context = UIGraphicsGetCurrentContext();

    UIView *view = self.mainContentView;
    //self.thumbImageView.layer.contentsScale = [UIScreen mainScreen].scale;
self.mainContentView.layer.contentsScale = [UIScreen mainScreen].scale;

    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Center the context around the view's anchor point
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    // Apply the view's transform about the anchor point
    CGContextConcatCTM(context, [view transform]);
    //CGContextScaleCTM(context, 2, 2);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context,
                          -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);

    // Render the layer hierarchy to the current context
    //[[view layer] renderInContext:context];

    // Restore the context
    CGContextRestoreGState(context);

    //[snapshot drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    //UIView *snapshot = [self.mainContentView snapshotViewAfterScreenUpdates:YES];
    //[self.mainContentView drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    //[self.mainContentView removeFromSuperview];
    //[self.mainContentView.layer drawInContext:ctx];
    //}
    [self.mainContentView removeFromSuperview];
}
#endif
@end
