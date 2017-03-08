//
//  GVMasterTableViewCell.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVMasterTableViewCell.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "GVMasterModelObject.h"
#import <SDWebImage/SDImageCache.h>
#import "GVAppDelegate.h"
#import "RSTimingFunction.h"

#define TILE_ENTIRE_CELL 0
const CGFloat TESTING_UI = 1;

const CGFloat GVMasterTableViewCellRowHeight = 200;

NSString *const GVMasterSectionHeaderViewCellIdentifier = @"GVMasterSectionHeaderViewCellIdentifier";
NSString *const GVMasterSectionHeaderViewTapToSendNotification = @"GVMasterSectionHeaderViewTapToSendNotification";
NSString *const GVMasterSectionHeaderSelectNotification = @"GVMasterSectionHeaderSelectNotification";
NSString *const GVMasterTableViewCellCollectionTouchNotification = @"GVMasterTableViewCellCollectionTouchNotification";
NSString *const GVMasterTableViewCellLongPressNotification = @"GVMasterTableViewCellLongPressNotification";
NSString *const GVMasterTableViewCellLongPressReceiveNotification = @"GVMasterTableViewCellLongPressReceiveNotification";
NSString *const GVMasterTableViewCellLongPressActivityReceiveNotification = @"GVMasterTableViewCellLongPressActivityReceiveNotification";
NSString *const GVMasterTableViewCellSaveMovieRequestNotification = @"GVMasterTableViewCellSaveMovieRequestNotification";
NSString *const GVMasterTableViewCellEditDataNotification = @"GVMasterTableViewCellEditDataNotification";

static inline CGFLOAT_TYPE cground(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}
//#if MASTER_TABLE_VIEW_CONTENT_VIEW

@interface GVMasterViewShellContentLayer : CALayer

@property (nonatomic, weak) UIView *displayDelegate;

@property (nonatomic, copy) NSString *userStringText;



@end

@implementation GVMasterViewShellContentLayer

//- (void)displayLayer:(CALayer *)layer {
//
//}

//- (void)drawInContext:(CGContextRef)context {
//
//    CGRect clippingRect = self.bounds;
//    CGContextClipToRect(context, clippingRect);
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillRect(context, clippingRect);
//    CGFloat contextHeight = clippingRect.size.height;
//    CGContextTranslateCTM(context, 0.0f, contextHeight);
//    CGContextScaleCTM(context, 1.0f, -1.0f);
//
//
//
//    //        CGRect scrollOffsetFrame = CGRectMake(self.scrollView.contentOffset.x, 0, self.frame.size.width, self.scrollView.frame.size.height);
//    //        if (!CGRectIntersectsRect(scrollOffsetFrame, clippingRect)) {
//    //            return;
//    //        }
//
//    UIFont *titleNormalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0];
//    UIColor *titleNormalColor = [UIColor colorWithWhite:0.2 alpha:1.0];
//
//
//
//
//    CFStringRef string = (__bridge_retained CFStringRef)self.userStringText;
//    CTFontRef font = CTFontCreateWithName((CFStringRef)[titleNormalFont fontName], [titleNormalFont pointSize], NULL);
//    // Initialize the string, font, and context
//
//    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName};
//    CFTypeRef values[] = { font, titleNormalColor.CGColor};
//
//    CFDictionaryRef attributes =
//    CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
//                       (const void**)&values, sizeof(keys) / sizeof(keys[0]),
//                       &kCFTypeDictionaryKeyCallBacks,
//                       &kCFTypeDictionaryValueCallBacks);
//
//    CFAttributedStringRef attrString =
//    CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
//
//    CFBridgingRelease(attributes);
//
//    CTLineRef line = CTLineCreateWithAttributedString(attrString);
//    CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
//    CGFloat lineHeight = 0;
//    if (lineBounds.size.height > 0) {
//        lineHeight = lineBounds.size.height;
//    }
//
//    // Set text position and draw the line into the graphics context
//    CGContextSetTextPosition(context, 10.0, cground(contextHeight - lineHeight));
//
//    //    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
//    //        DLogObject(self.sectionIndexPath);
//    //        return;
//    //    }
//    
//    CTLineDraw(line, context);
//
//
//
//
//    CFBridgingRelease(line);
//    CFBridgingRelease(string);
//}

@end

@interface GVMasterShellTiledLayer : CATiledLayer



@end


@implementation GVMasterShellTiledLayer

//- (instancetype)initWithLayer:(id)layer {
//    self = [super initWithLayer:layer];
//    if (self) {
//        self.backgroundColor = [UIColor whiteColor].CGColor;
//    }
//    return self;
//}

//+(CFTimeInterval)fadeDuration
//{
//    return 2.0;     // Normally it’s 0.25
//}

//-(void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)ctx
//{
//    CGRect dirtyRect = CGContextGetClipBoundingBox(ctx);
//    // draw!
//
//    [[UIColor redColor] setFill];
//    CGContextFillRect(ctx, dirtyRect);
//
//}

@end


@interface GVMasterTableViewCellShellView : UIView

@property (nonatomic, weak) UIView *displayDelegate;

//- (GVMasterShellTiledLayer*)layer;

@end


@implementation GVMasterTableViewCellShellView

+ (Class)layerClass {
    return [GVMasterShellTiledLayer class];
}

//- (void)didMoveToWindow {
//    self.contentScaleFactor = 1.0;
//}

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        //self.layer.tileSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
//    }
//    return self;
//}

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.backgroundColor = [UIColor whiteColor];
//        self.opaque = YES;
//    }
//    return self;
//}

//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
//    DLogFunctionLine();
//    //[self.displayDelegate performSelector:@selector(drawContentRect:) withObject:[NSValue valueWithCGRect:rect]];
//}

//- (void)setNeedsDisplay {
//    [super setNeedsDisplay];
//}
//

- (void)drawRect:(CGRect)rect {
    //[CATransaction begin];
    //[CATransaction setAnimationDuration:0.0];
    //if ([self superview].layer.needsLayout) {
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
     [self.displayDelegate performSelector:@selector(drawContentRect:) withObject:[NSValue valueWithCGRect:rect]];
    //});
    //}
    //[CATransaction commit];
}

@end
//#endif

NSString *const GVMasterTableViewCellCollectionView = @"GVMasterTableViewCellCollectionView";


#import "GVMasterTableViewCell.h"
#import "GVMasterTableViewCellGradientView.h"
#import "UIColor+Image.h"
#import "GVParseObjectUtility.h"
#import "GVMasterTableViewCollectionViewCell.h"
#import "GVCache.h"
#import "UIView+Snapshot.h"

@interface GVMasterTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate>


@property (nonatomic, strong) GVMasterTableViewCellShellView *shellView;


@property (nonatomic, assign) BOOL shouldShowUnread;
@property (nonatomic, strong) UIColor *titleNormalColor;
@property (nonatomic, strong) UIFont *titleNormalFont;
@property (nonatomic, copy) NSDictionary *userTextAttributes;
//@property (nonatomic, copy) NSDictionary *userHighlightAttributes;

@property (nonatomic, copy) NSDictionary *timeTextAttributes;
//@property (nonatomic, copy) NSDictionary *timeHighlightAttributes;

@property (nonatomic, copy) UIColor *normalBackgroundColor;
@property (nonatomic, copy) UIColor *oddBackgroundColor;

@property (nonatomic, strong) CATextLayer *usernameTextLayer;


@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) CAShapeLayer *overlayLayer;

//@property (nonatomic, strong) iCarousel *collectionCarousel;

@property (nonatomic, strong) RSTimingFunction *timingFunction;


@property (nonatomic, strong) GVMasterViewShellContentLayer *shellContentLayer;

//@property (nonatomic, strong, readwrite) UIImageView *imageView;

@property (nonatomic, assign) CGFloat gradientWidth;

@property (nonatomic, strong) NSOperationQueue *scrollOperationQueue;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, weak) UIAlertView *deleteAlertView;
@property (nonatomic, weak) UIAlertView *editImageURLAlertView;
@property (nonatomic, weak) UIAlertView *editDisplayNameAlertView;
@property (nonatomic, weak) UIAlertView *editRotateAlertView;
@property (nonatomic, weak) UIAlertView *editActionSheet;
@property (nonatomic, weak) UIAlertView *editThreadActionSheet;
@property (nonatomic, weak) UIAlertView *editThreadTitleAlertView;
@property (nonatomic, weak) UIAlertView *editUnrecordAlertView;
@property (nonatomic, weak) UIAlertView *editUnreadAlertView;

@end

@implementation GVMasterTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLongPress:) name:GVMasterTableViewCellLongPressReceiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveActivityLongPress:) name:GVMasterTableViewCellLongPressActivityReceiveNotification object:nil];

        self.layer.opaque = YES;
        self.layer.backgroundColor = [UIColor whiteColor].CGColor;
        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.needsToDraw = YES;
        self.autoresizesSubviews = NO;
        self.layer.needsDisplayOnBoundsChange = NO;
        self.layer.drawsAsynchronously = YES;
        [self.backgroundView removeFromSuperview];
        [self.textLabel removeFromSuperview];
        [self.imageView removeFromSuperview];
        [self.accessoryView removeFromSuperview];
        [self.contentView removeFromSuperview];

        for (UIView *subview in self.subviews) {
            subview.autoresizesSubviews = NO;
//            if (![subview isMemberOfClass:[UIScrollView class]]) {
//                [subview removeFromSuperview];
//            }
        }

//        
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//        paragraphStyle.alignment = NSTextAlignmentLeft;
//
        _titleNormalColor = [UIColor colorWithWhite:0.2 alpha:1.0];//[UIColor colorWithRed:0.056 green:0.108 blue:0.340 alpha:1.000];
//                                                                           //UIColor *purpleColor = [UIColor colorWithRed:0.024 green:0.022 blue:0.153 alpha:1.000];
//                                                                           //UIColor *lightPurpleColor = [UIColor colorWithRed:0.050 green:0.042 blue:0.340 alpha:1.000];
//        UIColor *titleNormalBackgroundColor = [UIColor clearColor];
//
//        //UIColor *titleNormalBackgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];
//        UIColor *highlightTitleColor = [UIColor whiteColor];
//        UIColor *highlightTitleBgColor = [UIColor clearColor];
//        //UIColor *highlightColor = self.selectedBackgroundView.backgroundColor;
        _titleNormalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0];
//        UIFont *timeFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
//        UIColor *timeColor = [UIColor colorWithRed:0.814 green:0.821 blue:0.854 alpha:1.000];
//
//        UIColor *sendColor = [UIColor colorWithWhite:0.6 alpha:1.0];
//        UIFont *sendFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];

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


//        _userTextAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
//                                kCTForegroundColorAttributeName: (id)_titleNormalColor.CGColor,
//                                NSBackgroundColorAttributeName: titleNormalBackgroundColor.CGColor,
//
//        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)[_titleNormalFont fontName], (CGFloat)[_titleNormalFont pointSize], NULL);
//
//        CTTextAlignment alignment = kCTLeftTextAlignment;
//
//        CTParagraphStyleSetting alignmentSetting;
//        alignmentSetting.spec = kCTParagraphStyleSpecifierAlignment;
//        alignmentSetting.valueSize = sizeof(CTTextAlignment);
//        alignmentSetting.value = &alignment;
//
//        CTParagraphStyleSetting settings[1] = {alignmentSetting};
//
//        CFIndex settingsCount = 1;
//        CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(settings, settingsCount);
//
////                                NSFontAttributeName: _titleNormalFont};
//        _userTextAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
//                                NSBackgroundColorAttributeName: [UIColor whiteColor],
//                                (__bridge_transfer id)kCTParagraphStyleAttributeName: (__bridge_transfer id)paragraphRef,
//                                (__bridge_transfer id)kCTForegroundColorAttributeName: (id)_titleNormalColor.CGColor,
//                                (__bridge_transfer id)kCTFontAttributeName: (__bridge_transfer id)fontRef};
//
//        _timeTextAttributes = @{NSParagraphStyleAttributeName: paragraphStyle,
//                                NSForegroundColorAttributeName: timeColor,
//                                NSBackgroundColorAttributeName: titleNormalBackgroundColor,
//                                NSFontAttributeName: timeFont};
//
////        NSDictionary *sendAttribute = @{NSParagraphStyleAttributeName: paragraphStyle,
////                                        NSForegroundColorAttributeName: sendColor,
////                                        NSBackgroundColorAttributeName: titleNormalBackgroundColor,
////                                        NSFontAttributeName: timeFont};
//
//
//        CFBridgingRelease(fontRef);
//        CFBridgingRelease(paragraphRef);

        // @autoreleasepool {
            // Initialization code
            //self.hidden = YES;

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
#if MASTER_TABLE_VIEW_CONTENT_VIEW

        self.clearsContextBeforeDrawing = NO;
        self.autoresizesSubviews = NO;


        self.layer.needsDisplayOnBoundsChange = NO;

        // self.layer.needsDisplayOnBoundsChange = NO;

        self.userInteractionEnabled = YES;
        
            self.backgroundView = nil;
        //self.textLabel = nil;
        //  self.imageView = nil;
            self.accessoryView = nil;
        self.contentView.layer.contentsScale = [UIScreen mainScreen].scale;

        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GVMasterTableViewCellRowHeight)];
        _scrollView.delegate = self;
        _scrollView.opaque = NO;
        //_scrollView.layer.opaque = YES;
        _scrollView.contentMode = UIViewContentModeRedraw;
        _scrollView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        //_scrollView.layer.shouldRasterize = YES;
        [self setupScrollViewTileSize];
        _scrollView.layer.drawsAsynchronously = YES;
        //_scrollView.pagingEnabled = YES;
        _scrollView.directionalLockEnabled = YES;
        
        for (NSLayoutConstraint *c in _scrollView.constraints) {
            [_scrollView removeConstraint:c];
        }
        //_scrollView.showsHorizontalScrollIndicator = YES;
        //_scrollView.showsVerticalScrollIndicator = NO;

        //_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //_scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        //_scrollView.layer.needsDisplayOnBoundsChange = NO;
        _scrollView.autoresizesSubviews = NO;
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:_scrollView];

        _mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GVMasterTableViewCellRowHeight)];
        _mainImageView.layer.drawsAsynchronously = YES;
        _mainImageView.backgroundColor = [UIColor whiteColor];
        //_mainImageView.contentMode = UIViewContentModeRedraw;
        [_scrollView addSubview:_mainImageView];
//
//        _cellImageView = [CALayer layer];
//        _cellImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GVMasterTableViewCellRowHeight);
//        _cellImageView.opaque = YES;
//        _cellImageView.backgroundColor = [UIColor whiteColor].CGColor;
//        //_cellImageView.drawsAsynchronously = YES;
//        _cellImageView.needsDisplayOnBoundsChange = YES;
//        //_cellImageView.shouldRasterize = YES;
//        //_cellImageView.rasterizationScale = [UIScreen mainScreen].scale;
//        //[_scrollView.layer addSublayer:_cellImageView];

        _shellView = [[GVMasterTableViewCellShellView alloc] initWithFrame:CGRectZero];
        //_shellView.layer.delegate = _shellView;
        _shellView.contentMode = UIViewContentModeRedraw;
        _shellView.opaque = YES;
        
        [self setupScrollViewTileSize];

        CALayer *l = (CALayer* _Nonnull)_shellView.layer;
        
        //DLogCGSize(_shellView.layer.tileSize);
        l.drawsAsynchronously = YES;
        //_shellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //_shellView.translatesAutoresizingMaskIntoConstraints = NO;
        //_shellView.layer.needsDisplayOnBoundsChange = NO;
        l.contentsScale = [UIScreen mainScreen].scale;
        //_shellView.layer.fillColor = [UIColor whiteColor].CGColor;
        //_shellView.layer.shouldRasterize = YES;
        //_shellView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _shellView.displayDelegate = self;
        l.contentsScale = [UIScreen mainScreen].scale;
        _shellView.autoresizesSubviews = NO;
        _shellView.clearsContextBeforeDrawing = NO;
        l.needsDisplayOnBoundsChange = NO;
        _shellView.backgroundColor = [UIColor whiteColor];
        l.backgroundColor = [UIColor whiteColor].CGColor;
        _shellView.translatesAutoresizingMaskIntoConstraints = NO;
        //_shellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrollView addSubview:_shellView];

        //[_scrollView addSubview:_mainImageView];
        
        _scrollOperationQueue = [NSOperationQueue new];
        _scrollOperationQueue.maxConcurrentOperationCount = 1;


        //_shellView.layer.tileSize = CGSizeMake(128, 180);


//        //_shellContentLayer = [GVMasterViewShellContentLayer layer];
//        _shellContentLayer.opaque = YES;
//        _shellContentLayer.drawsAsynchronously = YES;
//
//        _shellContentLayer.contentsScale = [UIScreen mainScreen].scale;
//        //_shellContentLayer.shouldRasterize = YES;
//        //_shellContentLayer.rasterizationScale = [UIScreen mainScreen].scale;
//        //_shellContentLayer.fillColor = [UIColor whiteColor].CGColor;
//        //_shellContentLayer.backgroundColor = [UIColor whiteColor].CGColor;
//        _shellContentLayer.needsDisplayOnBoundsChange = NO;
//        //[_scrollView.layer addSublayer:_shellContentLayer];

//        _usernameTextLayer = [CATextLayer layer];
//        _usernameTextLayer.needsDisplayOnBoundsChange = NO;
//        //_usernameTextLayer.opaque = YES;
//        //_usernameTextLayer.backgroundColor = [UIColor whiteColor].CGColor;
//        _usernameTextLayer.string = @"Waiting on recipients...";
//        _usernameTextLayer.shouldRasterize = YES;
//        _usernameTextLayer.drawsAsynchronously = YES;
//        _usernameTextLayer.rasterizationScale = [UIScreen mainScreen].scale;
//        _usernameTextLayer.contentsScale = [UIScreen mainScreen].scale;
//        //[_scrollView.layer addSublayer:_usernameTextLayer];
//
//
//            _mainContentView = [[UIView alloc] initWithFrame:CGRectZero];
//        //_mainContentView.layer.shouldRasterize = YES;
//        //_mainContentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        _mainContentView.clearsContextBeforeDrawing = NO;
//        _mainContentView.layer.drawsAsynchronously = YES;
//        _mainContentView.layer.contentsScale = [UIScreen mainScreen].scale;
//        //_mainContentView.backgroundColor = [UIColor whiteColor];
//            _mainContentView.translatesAutoresizingMaskIntoConstraints = NO;
//            _mainContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        //_mainContentView.opaque = YES;


#else
            self.textLabel.hidden = YES;
            self.autoresizesSubviews = NO;
            self.contentView.autoresizesSubviews = NO;
            self.backgroundView.autoresizesSubviews = NO;

            //self.exclusiveTouch = NO;
            //self.userInteractionEnabled = NO;
            //self.contentView.exclusiveTouch = NO;
            //  self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //  self.contentView.layer.shouldRasterize = YES;
        //self.contentView.layer.contentsScale = [UIScreen mainScreen].scale;
        //  self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;

            //self.contentView.clipsToBounds = YES;
            //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.643 green:0.600 blue:0.929 alpha:1.000]; //[UIColor colorWithRed:0.354 green:0.000 blue:0.401 alpha:1.000];
                                                                                                                           //self.backgroundView = [[GVMasterTableViewCellGradientView alloc] initWithFrame:self.backgroundView.bounds];
                                                                                                                           //self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.000 green:0.988 blue:1.000 alpha:1.000];


            //    UIImage *barImage = [UIColor imageWithColor:[UIColor colorWithRed:0.000 green:0.138 blue:0.392 alpha:1.000]];
            //    barImage = [barImage resizableImageWithCapInsets:UIEdgeInsetsZero];
            //    //[self.imageView setImage:[UIColor imageWithColor:[UIColor purpleColor]]];
            //    [self.imageView setImage:barImage];
            //    self.imageView.layer.shouldRasterize = YES;
            //    self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
            self.imageView.hidden = YES;
            //self.accessoryView.hidden = YES;
            //self.imageView.frame = CGRectMake(0, 0, 3, 100);
            //self.contentView.exclusiveTouch = YES;
#endif

//        _collectionCarousel = [[iCarousel alloc] initWithFrame:CGRectZero];
//        _collectionCarousel.perspective = .002;
//        //_collectionCarousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        //_collectionCarousel.translatesAutoresizingMaskIntoConstraints = NO;
//        _collectionCarousel.type = iCarouselTypeCylinder;
//        _collectionCarousel.delegate = self;
//        _collectionCarousel.dataSource = self;
//        [_collectionCarousel setNeedsDisplay];
        //[_mainContentView addSubview:self.collectionCarousel];


//            _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
//            _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//            _collectionViewFlowLayout.itemSize = CGSizeMake(95, 95);
//            _collectionViewFlowLayout.minimumLineSpacing = 0.0;
//
//            _collectionViewFlowLayout.sectionInset = UIEdgeInsetsZero;
//            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewFlowLayout];
//        //_collectionView.clipsToBounds = YES;
//           _collectionView.opaque = YES;
//        _collectionView.layer.backgroundColor = [UIColor whiteColor].CGColor;
//        _collectionView.layer.shouldRasterize = YES;
//        _collectionView.layer.contentsScale = [UIScreen mainScreen].scale;
//        _collectionView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        //_collectionView.layer.opaque = YES;
//            _collectionView.scrollEnabled = NO;
//            _collectionView.delegate = self;
//#if TESTING_PERF
//            _collectionView.hidden = YES;
//#endif
//            _collectionView.autoresizesSubviews = NO;
//            //_collectionView.exclusiveTouch = NO;
//            _collectionView.panGestureRecognizer.enabled = NO;
//            _collectionView.pinchGestureRecognizer.enabled = NO;
//            _collectionView.contentMode = UIViewContentModeLeft;
//            _collectionView.allowsSelection = YES;
//            //_collectionView.userInteractionEnabled = NO;
//            _collectionView.dataSource = self;
//        //_collectionView.backgroundColor = [UIColor clearColor];
//            //_collectionView.layer.shouldRasterize = YES;
//            //_collectionView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//            _collectionView.scrollsToTop = NO;
#if MASTER_TABLE_VIEW_CONTENT_VIEW
        //[_scrollView addSubview:_collectionView];
#else
        //[self.contentView addSubview:_collectionView];
#endif
        //[self addSubview:_mainContentView];
            
//            CAGradientLayer *l = [CAGradientLayer layer];
//            l.frame = _collectionView.bounds;
//
//            l.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
//            l.startPoint = CGPointMake(0.3f, 0.5f);
//            l.endPoint = CGPointMake(1.0, 0.5f);
//            //_collectionView.layer.mask = l;

//        NSArray *arr = _collectionView.subviews;
//        for (UIView *subview in arr) {
//            subview.layer.contentsScale = [UIScreen mainScreen].scale;
//            subview.layer.shouldRasterize = YES;
//            subview.layer.rasterizationScale = [UIScreen mainScreen].scale;
//            for (CALayer *sublayer in subview.layer.sublayers) {
//                sublayer.contentsScale = [UIScreen mainScreen].scale;
//                sublayer.shouldRasterize = YES;
//                sublayer.rasterizationScale = [UIScreen mainScreen].scale;
//            }
//            for (UIView *view in subview.subviews) {
//                view.layer.contentsScale = [UIScreen mainScreen].scale;
//                view.layer.shouldRasterize = YES;
//                view.layer.rasterizationScale = [UIScreen mainScreen].scale;
//                for (CALayer *subsublayer in view) {
//                    subsublayer.contentsScale = [UIScreen mainScreen].scale;
//                    subsublayer.shouldRasterize = YES;
//                    subsublayer.rasterizationScale = [UIScreen mainScreen].scale;
//                }
//            }
//        }
//
        //    [_collectionView registerClass:[GVMasterTableViewCollectionViewCell class] forCellWithReuseIdentifier:GVMasterTableViewCellCollectionView];

        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;

        
        self.overlayLayer = [CAShapeLayer layer];
        self.overlayLayer.fillColor = [UIColor whiteColor].CGColor;
        self.overlayLayer.opaque = YES;
        self.overlayLayer.backgroundColor = [UIColor whiteColor].CGColor;
        self.overlayLayer.opacity = 0;
        self.overlayLayer.shouldRasterize = YES;
        
        self.gradientWidth = 0.17;
        
        self.gradientLayerMask = [CAGradientLayer layer];
        self.gradientLayerMask.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:self.gradientWidth], [NSNumber numberWithFloat:1-self.gradientWidth], [NSNumber numberWithFloat:1.0]];
        self.gradientLayerMask.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor];
        self.gradientLayerMask.startPoint = CGPointMake(-(self.gradientWidth), 0.5);
        self.gradientLayerMask.endPoint = CGPointMake(1.0 + self.gradientWidth, 0.5);
        //self.gradientLayerMask.shouldRasterize = YES;
        //self.gradientLayerMask.rasterizationScale = [UIScreen mainScreen].scale;
        self.gradientLayerMask.contentsScale = [UIScreen mainScreen].scale;
        self.gradientLayerMask.needsDisplayOnBoundsChange = NO;
        self.gradientLayerMask.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GVMasterTableViewCellRowHeight);
        //self.gradientLayerMask.duration = 0.0;
        [self.gradientLayerMask setNeedsDisplay];
        //[self.overlayLayer addSublayer:self.gradientLayerMask];
        //[self.gradientLayerMask addSublayer:self.overlayLayer];
        //self.overlayLayer.frame = self.gradientLayerMask.frame;
        
        self.overlayLayer.path = [UIBezierPath bezierPathWithRect:self.gradientLayerMask.frame].CGPath;
        [self.overlayLayer setNeedsDisplay];
        self.overlayLayer.needsDisplayOnBoundsChange = NO;
        //self.layer.mask = self.gradientLayerMask;

        //self.scrollView.layer.mask = self.gradientLayerMask;

        self.timingFunction = [RSTimingFunction timingFunctionWithControlPoint1:CGPointMake(.18, .03) controlPoint2:CGPointMake(1, -0.08)];
        //self.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.73 :0 :.88 :.91];
        
        //[self setNeedsDisplay];
        
        //[self scrollViewDidScroll:self.scrollView];
        //}
    }
    return self;
}

- (void)setupScrollViewTileSize {
    CATiledLayer *tileLayer = (CATiledLayer*)self.shellView.layer;
    tileLayer.tileSize = CGSizeMake((imageSize * [UIScreen mainScreen].scale) + ((imagePadding)*[UIScreen mainScreen].scale), GVMasterTableViewCellRowHeight * [UIScreen mainScreen].scale);
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.scrollView) {
//
//        NSBlockOperation *blockOperation = [NSBlockOperation new];
//        @weakify(blockOperation);
//        @weakify(self);
//        
//        
//        [blockOperation addExecutionBlock:^{
//            @strongify(self);
//
//            if ([blockOperation_weak_ isCancelled]) {
//                return ;
//            }
//            
//            [self.scrollOperationQueue cancelAllOperations];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @strongify(self);
//                CGFloat scrollPadding = 45;
//                CGFloat gradientEdge = self.gradientWidth;
//                CGFloat contentOffset = scrollView.contentOffset.x;
//                CGFloat contentSize = scrollView.contentSize.width;
//                
//                CGFloat boundSize = self.scrollView.frame.size.width;
//
//                CGFloat rightPercent = 0;
//                CGFloat rightSideSensor = contentSize - scrollPadding;
//                CGFloat rightSideValue = 0;
//                CGFloat rightEdge = contentOffset + boundSize;
//                
//                CGFloat leftPercent = 0;
//                CGFloat leftSideSensor = scrollPadding;
//                CGFloat leftSideValue = 0;
//                CGFloat leftEdge = contentOffset;
//                
//                [CATransaction begin];
//                [CATransaction setAnimationDuration:0.25];
//                
//                // there are four possible states
//                // shows no gradients at all, contentSize <= screen width
//                // shows both gradients, contentOffset > 0,  contentOffset < contentSize - screen width
//                // shows left gradient, contentOffset > contentSize - screen width
//
//                // fallback:shows right gradient, contentOffset < screen width, contentSize > screen width
//
//                if (contentSize <= boundSize) {
//                    self.gradientLayerMask.startPoint = CGPointMake(0.0 - gradientEdge, 0.5);
//                    self.gradientLayerMask.endPoint = CGPointMake(1.0 + gradientEdge, 0.5);
//                } else if (contentOffset > 0 && contentOffset < contentSize - boundSize) {
//                    self.gradientLayerMask.startPoint = CGPointMake(0.0, 0.5);
//                    self.gradientLayerMask.endPoint = CGPointMake(1.0, 0.5);
//                } else if (contentOffset >= contentSize - boundSize) {
//                    self.gradientLayerMask.startPoint = CGPointMake(0.0, 0.5);
//                    self.gradientLayerMask.endPoint = CGPointMake(1.0 + gradientEdge, 0.5);
//                } else {
//                    self.gradientLayerMask.startPoint = CGPointMake(0.0 - gradientEdge, 0.5);
//                    self.gradientLayerMask.endPoint = CGPointMake(1.0, 0.5);
//                }
//                
//                [CATransaction commit];
////                if (rightEdge > rightSideSensor) {
////                    if (contentSize <= boundSize) {
////                        self.gradientLayerMask.startPoint = CGPointMake(0.0 - gradientEdge, 0.5);
////                        self.gradientLayerMask.endPoint = CGPointMake(1.0 + gradientEdge, 0.5);
////                    } else {
////                    rightSideValue = rightEdge - rightSideSensor;
////                    rightPercent = rightSideValue / scrollPadding;
////                    DLogCGFloat(rightPercent);
////                    
////                    if (rightPercent > 1) {
////                        rightPercent = 1;
////                    }
////                    if (rightPercent < 0) {
////                        rightPercent = 0;
////                    }
////                    
////                    //rightPercent = [self.timingFunction valueForX:rightPercent];
////                    self.gradientLayerMask.startPoint = CGPointMake((0.0 - gradientEdge) + rightPercent*gradientEdge, 0.5);
////                    self.gradientLayerMask.endPoint = CGPointMake(1.0 + rightPercent*gradientEdge, 0.5);
////                    }
////                } else if (contentOffset > 0) {
////                    if (contentSize <= boundSize) {
////                        self.gradientLayerMask.startPoint = CGPointMake(0.0 - gradientEdge, 0.5);
////                        self.gradientLayerMask.endPoint = CGPointMake(1.0 + gradientEdge, 0.5);
////                    } else {
////                        DLogCGFloat(contentOffset);
////                        leftSideValue = contentOffset;
////                        leftPercent = leftSideValue / scrollPadding;
////                        
////                        leftPercent = 1 - leftPercent;
////                        if (leftPercent > 1) {
////                            leftPercent = 1;
////                        }
////                        if (leftPercent < 0) {
////                            leftPercent = 0;
////                        }
////                        
////                        self.gradientLayerMask.endPoint = CGPointMake((1.0 + gradientEdge) - leftPercent*gradientEdge, 0.5);
////                        self.gradientLayerMask.startPoint = CGPointMake(0.0 - leftPercent*gradientEdge, 0.5);
////                    }
////                } else {
////                    
////                        self.gradientLayerMask.startPoint = CGPointMake(0.0 - gradientEdge, 0.5);
////                        self.gradientLayerMask.endPoint = CGPointMake(1.0, 0.5);
////                    
////                }
//                
//    //        if (contentSize > boundSize) {
//    //            
//    //            
//    //            CGFloat lastPane = contentSize - ;
//    //            CGFloat diff = contentOffset;
//    //            //DLogCGFloat(contentOffset);
//    //            if (diff < 0) {
//    //                diff = 0;
//    //            }
//    //            CGFloat percent = diff/boundSize;
//    //            
//    //            DLogCGFloat(percent);
//    //
//    //            CGFloat finalValue = percent;
//    //            if (finalValue < 0) {
//    //                finalValue = 0;
//    //                
//    //            }
//    //            if (finalValue > 1) {
//    //                finalValue = 1;
//    //            }
//    //            
//    //            //CGFloat curvedPoint = [self.timingFunction valueForX:percent];
//    //            
//    //            //self.overlayLayer.opacity = finalValue;
//    //            //DLogCGRect(self.overlayLayer.frame);
//    //            
//    //            //[CATransaction begin];
//    //            //[CATransaction setDisableActions:YES];
//    //            //[CATransaction setAnimationDuration:0.0];
//    //            
//    //            self.gradientLayerMask.endPoint = CGPointMake(1.0 + percent, 0.5);
//    //            
//    //            //[CATransaction commit];
//    //            //self.overlayLayer.opacity = finalValue;
//    //            //[self setNeedsDisplay];
//    //            //[self.overlayLayer setNeedsDisplay];
//    //            //[self.layer.mask setNeedsDisplay];
//    //            //self.layer.mask.opacity = diff/boundSize;
//    //            //self.gradientLayerMask.colors = @[(id)[UIColor colorWithWhite:1.0 alpha:finalValue].CGColor, (id)[UIColor clearColor].CGColor];
//    //            //[self.gradientLayerMask setNeedsDisplay];
//    //            return;
//    //        }
//    //        
//    //        
//    //        //[CATransaction begin];
//    //        //[CATransaction setDisableActions:YES];
//    //        //[CATransaction setAnimationDuration:0.0];
//    //        
//    //        self.gradientLayerMask.duration = 0.0;
//    //        
//    //        self.gradientLayerMask.endPoint = CGPointMake(1.0, 0.5);
//    //        
//            //[CATransaction commit];
//            //self.overlayLayer.opacity = 0;
//            //self.overlayLayer.opacity = 0;
//            //[self setNeedsDisplay];
//            //[self.overlayLayer setNeedsDisplay];
//            //[self.layer.mask setNeedsDisplay];
//            //self.gradientLayerMask.colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor];
//            //[self.gradientLayerMask setNeedsDisplay];
//            //self.layer.mask.opacity = 0;
//            });
//                
//        }];
//        [self.scrollOperationQueue addOperations:@[blockOperation_weak_] waitUntilFinished:NO];
//    }
//}

- (void)setUserTextString:(NSString*)string {

    NSString *newString = nil;
    if ([string respondsToSelector:@selector(length)] && [string length] > 0) {
        newString = string;

    } else {
        newString = @"Waiting On Recipients...";
    }
    self.userString = newString;
    self.shellContentLayer.userStringText = newString;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:newString attributes:self.userTextAttributes];
    [self.usernameTextLayer setString:attrString];
    CGSize size = [attrString size];
    self.usernameTextLayer.frame = CGRectIntegral(CGRectMake(3.5, 0, size.width, size.height));
    [self performSelectorOnMainThread:@selector(setNeedsDisplayInNSValueRect:) withObject:[NSValue valueWithCGRect:CGRectMake(0, 0, self.scrollView.frame.size.width, size.height)] waitUntilDone:NO modes:@[NSRunLoopCommonModes]];

    //[self.shellContentLayer setNeedsDisplayInRect:CGRectMake(0, 0, self.scrollView.frame.size.width, self.titleNormalFont.pointSize*2)];
}
- (void)setTimeLabelString:(NSString*)string {
    self.timeString = string;
}

- (void)setupScrollContent:(CGSize)size {
    CGSize contentSize = CGRectIntegral(CGRectMake(0, 0, size.width, size.height)).size;
    DLogCGSize(contentSize);
    DLogMainThread();
    self.scrollView.contentSize = contentSize;
    self.mainImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GVMasterTableViewCellRowHeight);
    self.scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, GVMasterTableViewCellRowHeight);
#if TILE_ENTIRE_CELL
    self.shellView.frame = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
#else
    self.shellView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, size.width, size.height);
#endif
    //self.shellView.frame =CGRectIntegral( CGRectMake([UIScreen mainScreen].bounds.size.width, 0, size.width - [UIScreen mainScreen].bounds.size.width, GVMasterTableViewCellRowHeight) );
    //[self.scrollView setNeedsUpdateConstraints];
    //[self setNeedsUpdateConstraints];
//    for (UIView *view in self.subviews) {
//        [view setNeedsUpdateConstraints];
//    }
//    [self performSelectorOnMainThread:@selector(scrollViewDidScroll:) withObject:self.scrollView waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
    //DLogCGRect(self.shellView.frame);
}

- (void)handleTapFail:(NSValue*)point {
    CGPoint value = [point CGPointValue];
    
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.35];
        self.highlightLayer.opacity = 0.0;
        [CATransaction commit];
    });
    
    //DLogCGPoint(value);
}

- (void)handleTap:(NSValue*)point {

    CGPoint scrollViewPoint = [self convertPoint:[point CGPointValue] toView:self.scrollView];

    NSValue *scrollPoint = [NSValue valueWithCGPoint:scrollViewPoint];
    if (self.sectionIndexPath != nil && scrollPoint != nil) {
        NSDictionary *dict = @{@"sectionIndexPath": self.sectionIndexPath, @"scrollViewPoint": scrollPoint};

        [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellCollectionSelectNotification object:nil userInfo:dict];
    }
    
        //
//    for (GVMasterTableViewCollectionViewCell *cell in self.collectionView.visibleCells) {
//        //cell = (GVMasterTableViewCollectionViewCell*)
//
//
//
//    //GVMasterTableViewCollectionViewCell *hitTest = (GVMasterTableViewCollectionViewCell*)[self.collectionView hitTest:[point CGPointValue] withEvent:nil];
//
//        //  CGPoint cPoint = [self convertPoint:[point CGPointValue] toView:hitTest];
//    //CGPoint cPoint1 = [self.window convertPoint:cPoint toView:cell];
//    // if ([hitTest pointInside:cPoint withEvent:nil]) {
//            // found it...?
//
//    CGPoint hitPoint = [point CGPointValue];
//
//    BOOL hit = CGRectContainsPoint(cell.frame, hitPoint);
//    if (hit) {
//            DLogObject(@" FOUND IT");
//            NSDictionary *dict = @{@"indexPath":[self.collectionView indexPathForCell:cell], @"sectionIndexPath": self.sectionIndexPath, @"activityId": cell.activityId, @"threadId": cell.threadId};
//            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellCollectionSelectNotification object:nil userInfo:dict];
//    }
//    }
    //}


    //DLogObject(point);
}

- (void)updateDisplayInRect:(CGRect)imageRect {
    if ([NSThread isMainThread]) {
        [self.scrollView setNeedsDisplayInRect:imageRect];
        [self.shellView setNeedsDisplayInRect:imageRect];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setNeedsDisplayInRect:imageRect];
            [self.shellView setNeedsDisplayInRect:imageRect];
        });
    }
}

- (void)postScrollPointNotification:(NSValue*)point name:(NSString*)name userInfo:(NSDictionary*)userInfo {
    if (point) {
        CGPoint scrollViewPoint = [self convertPoint:[point CGPointValue] toView:self.scrollView];
        
        if (userInfo) {
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
        } else {
            if (self.scrollView && self.sectionIndexPath && self) {
                NSDictionary *dict = @{@"scrollView": self.scrollView, @"sectionIndexPath": self.sectionIndexPath, @"scrollViewPoint": [NSValue valueWithCGPoint:scrollViewPoint], @"self": self};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:dict];
            }
        }
    }
}

- (void)handleTouchDown:(NSValue*)point {
    [self postScrollPointNotification:point name:GVMasterTableViewCellCollectionTouchNotification userInfo:nil];
}



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
    if (action == @selector(deleteAction:)) {
        return YES;
    }
    if (action == @selector(saveAction:)) {
        return YES;
    }
    if (action == @selector(editAction:)) {
        return YES;
    }
    if (action == @selector(editThreadAction:)) {
        return YES;
    }
    return (action == @selector(inviteAction:));
}

- (void)deleteAction:(id)sender {
    
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Leave Thread Confirmation" message:@"Would you like to leave this thread?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave", nil];
    [deleteAlert show];
    self.deleteAlertView = deleteAlert;
    [self resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView == self.deleteAlertView) {
        // confirm deletion of thread
            if (self.sectionIndexPath && self.threadId) {
                NSDictionary *info = @{@"sectionIndexPath": self.sectionIndexPath, @"threadId": self.threadId};
                [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterViewControllerDeleteThreadRequestNotification object:nil userInfo:info];
            }
        }
        if (alertView == self.editDisplayNameAlertView) {
            
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
            if (!dict) {
                dict = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            [dict setObject:textField.text forKey:@"textFieldText"];
            [dict setObject:@"displayName" forKey:@"editDataKey"];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellEditDataNotification object:nil userInfo:dict];
            
            DLogObject(self.userInfo);
        }
        if (alertView == self.editThreadTitleAlertView) {
            
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
            if (!dict) {
                dict = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            [dict setObject:textField.text forKey:@"textFieldText"];
            [dict setObject:@"threadTitle" forKey:@"editDataKey"];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellEditDataNotification object:nil userInfo:dict];
            
            DLogObject(self.userInfo);
        }
    }
    if (alertView == self.editActionSheet) {
        switch (buttonIndex) {
            case 1: {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Image URL" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Use Clipboard", @"Use URL", nil];
                [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [alertView show];
                self.editImageURLAlertView = alertView;
                break;
            }
            case 2: {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rotate Thumbnail" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rotate 90deg", @"Rotate 180deg", @"Rotate 270deg", nil];
                [alertView show];
                self.editRotateAlertView = alertView;
                break;
            }
            case 3: {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Display Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change Name", nil];
                [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [alertView show];
                self.editDisplayNameAlertView = alertView;
                break;
            }
            case 4: {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Select Unrecorded State" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove Red Dot", @"Show Red Dot", nil];
                [alertView show];
                self.editUnrecordAlertView = alertView;
                break;
            }
            case 5: {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Select Unread State" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove Blue Dot", @"Show Blue Dot", nil];
                [alertView show];
                self.editUnreadAlertView = alertView;
                break;
            }
            default:
                break;
        }
        DLogNSInteger(buttonIndex);
    }
    if (alertView == self.editUnrecordAlertView) {
        if (buttonIndex > 0) {
            
            NSNumber *recordState = [NSNumber numberWithInteger:buttonIndex];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
            if (!dict) {
                dict = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            
            [dict setObject:@"markUnrecord" forKey:@"editDataKey"];
            [dict setObject:recordState forKey:@"recordStateKey"];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellEditDataNotification object:nil userInfo:dict];
        }
    }
    if (alertView == self.editUnreadAlertView) {
        if (buttonIndex > 0) {
            NSNumber *readState = [NSNumber numberWithInteger:buttonIndex];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
            if (!dict) {
                dict = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            
            [dict setObject:@"markUnread" forKey:@"editDataKey"];
            [dict setObject:readState forKey:@"unreadStateKey"];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellEditDataNotification object:nil userInfo:dict];
        }
    }
    if (alertView == self.editRotateAlertView) {
        if (buttonIndex > 0) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
            if (!dict) {
                dict = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            
            [dict setObject:@"imageRotate" forKey:@"editDataKey"];
            [dict setObject:[NSNumber numberWithInteger:buttonIndex] forKey:@"rotateKey"];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellEditDataNotification object:nil userInfo:dict];
        }
    }
    if (alertView == self.editThreadActionSheet) {
        if (buttonIndex == 1 && self.sectionIndexPath && self.threadId) {
            NSDictionary *info = @{@"sectionIndexPath": self.sectionIndexPath, @"threadId": self.threadId};
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:info];
            if (!dict) {
                dict = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            
            [dict setObject:@"threadTitle" forKey:@"editDataKey"];
            [dict setObject:[alertView textFieldAtIndex:0].text forKey:@"textFieldText"];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellEditDataNotification object:nil userInfo:dict];
        }
//        switch (buttonIndex) {
//            case 0: {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Thread Title" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change Title", nil];
//                [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
//                [alertView show];
//                self.editThreadTitleAlertView = alertView;
//                break;
//            }
//            default:
//                break;
//        }
    }
    if (alertView == self.editImageURLAlertView) {
        if (buttonIndex == 1) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
            if (!dict) {
                dict = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            
            [dict setObject:@"imageURLClipboard" forKey:@"editDataKey"];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellEditDataNotification object:nil userInfo:dict];
            
        } else if (buttonIndex == 2) {
        // get the url from the alertview...
        // get the image...
        // set the image as thumbnail of the activity, probably best to shoot to model
            // save the activity...jesus
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
            if (!dict) {
                dict = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            [dict setObject:textField.text forKey:@"textFieldText"];
            [dict setObject:@"imageURL" forKey:@"editDataKey"];
            [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellEditDataNotification object:nil userInfo:dict];
            //[textField resignFirstResponder];
            //DLogObject(text);
        }
    }
    //[alertView resignFirstResponder];
}


- (void)saveAction:(id)sender {
//    @weakify(self);
//    NSBlockOperation *op = [[NSBlockOperation alloc] init];
//    [op addExecutionBlock:^{
//        @strongify(self);
//        
//        NSDictionary *saveInfo = @{@"contentURL": self.contentURL};
//        [[NSNotificationCenter defaultCenter] postNotificationName:GVSaveMovieNotification object:nil userInfo:saveInfo];
//        [self saveRequested];
//    }];
//    NSDictionary *info = @{@"op": op};
//    [[NSNotificationCenter defaultCenter] postNotificationName:GVInternetRequestNotification object:nil userInfo:info];
    NSValue *targetRect = self.userInfo[@"scrollViewPoint"];
    [self postScrollPointNotification:targetRect name:GVMasterTableViewCellSaveMovieRequestNotification userInfo:self.userInfo];
    self.userInfo = nil;
}

- (void)editAction:(id)sender {
    // let's bring up an action sheet too
    UIAlertView *actionSheet =  [[UIAlertView alloc] initWithTitle:@"Edit Data" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change Thumbnail", @"Rotate Thumbnail", @"Change Display Name", @"Mark Unrecorded", @"Mark Unread", nil];
    [actionSheet show];
    self.editActionSheet = actionSheet;
}


- (void)editThreadAction:(id)sender {
    // let's bring up an action sheet?
    
    UIAlertView *actionSheet =  [[UIAlertView alloc] initWithTitle:@"Edit Thread Title" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change Thread Title", nil];
    [actionSheet setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [actionSheet show];
    self.editThreadActionSheet = actionSheet;
}

- (void)inviteAction:(id)sender
{
    if (self.threadId) {
            [self resignFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:GVThreadInviteNotification object:nil userInfo:@{@"threadId": self.threadId}];
        //NSString *path = [NSString stringWithFormat:@"http://gvideoapp.com/thread/%@", self.threadId];
        //NSURL *threadURL = [NSURL URLWithString:path];
        //[[UIPasteboard generalPasteboard] setString:path];
        //[self resignFirstResponder];
        //[[NSNotificationCenter defaultCenter] postNotificationName:GVNewThreadDidSaveNotification object:nil userInfo:@{@"threadURL": threadURL}];
    }
}

- (void)activateActivityMenuActionAtTargetRect:(CGRect)targetRect userInfo:(NSDictionary*)userInfo {
    if (![self becomeFirstResponder]) {
        self.userInfo = nil;
        return;
    }
    
    self.userInfo = userInfo;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *inviteMenu = [[UIMenuItem alloc] initWithTitle:@"Save to Camera Roll" action:@selector(saveAction:)];
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Edit Data" action:@selector(editAction:)];
    if ((TESTING_ACCOUNT) && TESTING_UI) {
        [[UIMenuController sharedMenuController] setMenuItems:@[inviteMenu, menuItem]];
    } else {
        [[UIMenuController sharedMenuController] setMenuItems:@[inviteMenu]];
    }
    //CGRect targetRect = [self convertRect:self.frame
    //                             fromView:self.superview];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    //self.thumbnailView.alpha = 0.6;
    //self.bubbleView.bubbleImageView.highlighted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}

- (void)activateThreadMenuAction {
    if (![self becomeFirstResponder]) {
        return;
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *inviteMenu = [[UIMenuItem alloc] initWithTitle:@"Invite to Thread" action:@selector(inviteAction:)];
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Leave Thread" action:@selector(deleteAction:)];
    UIMenuItem *editItem = [[UIMenuItem alloc] initWithTitle:@"Edit Thread" action:@selector(editThreadAction:)];
    if ((TESTING_ACCOUNT) && TESTING_UI) {
        [[UIMenuController sharedMenuController] setMenuItems:@[editItem, inviteMenu, menuItem]];
    } else {
        [[UIMenuController sharedMenuController] setMenuItems:@[inviteMenu, menuItem]];
    }
        CGRect targetRect = [self convertRect:self.frame
                                 fromView:self.superview];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    //self.thumbnailView.alpha = 0.6;
    //self.bubbleView.bubbleImageView.highlighted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}

- (void)receiveActivityLongPress:(NSNotification*)notif {
    NSDictionary *userInfo = [notif userInfo];
    
    UIScrollView *scrollView = userInfo[@"scrollView"];
    if (scrollView == self.scrollView) {
        
        CGRect targetRect = [userInfo[@"targetRect"] CGRectValue];
        [self activateActivityMenuActionAtTargetRect:targetRect userInfo:userInfo];
    }
}

- (void)receiveLongPress:(NSNotification*)notif {
    NSDictionary *userInfo = [notif userInfo];
    
    UIScrollView *scrollView = userInfo[@"scrollView"];
    if (scrollView == self.scrollView) {
        // we need to do the action
        [self activateThreadMenuAction];
    }
    
}

- (void)handleLongPress:(NSValue*)point {

    [self postScrollPointNotification:point name:GVMasterTableViewCellLongPressNotification userInfo:nil];

    //DLogObject(point);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
    //self.bubbleView.bubbleImageView.highlighted = NO;
    //self.thumbnailView.alpha = 1;
    //self.userInfo = nil;

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

//- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
//    return 85;
//}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.scrollView;
//    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
//        CGPoint cPoint = [self convertPoint:point toView:cell];
//        if ([cell pointInside:cPoint withEvent:nil]) {
//            // found the cell apparently.
//            DLogObject(cell);
//            return cell;
//        }
//    }
//    return self;

}

#if MASTER_TABLE_VIEW_CONTENT_VIEW
//- (void)setNeedsDisplay {
//    [super setNeedsDisplay];
//
//    DLogObject(self);
//    //for (UIView *view in self.subviews) {
//    //    [view removeFromSuperview];
//    //}
////    if (![self.mainContentView superview]) {
////        [self addSubview:self.mainContentView];
////    }
//    //[self.shellView setNeedsDisplay];
//}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];

//    if (![self.mainContentView superview]) {
//        [self addSubview:self.mainContentView];
//    }

    //[self.shellView setNeedsDisplay];
    //[self.shellContentLayer setNeedsDisplay];

    //[self.scrollView setNeedsDisplay];
    //[self.shellView setNeedsDisplay];
    //[self.usernameTextLayer setNeedsDisplay];


}

- (void)setNeedsDisplayInNSValueRect:(NSValue*)rect {
    //  [self setNeedsDisplayInRect:[rect CGRectValue]];
}

- (void)setNeedsDisplayInRect:(CGRect)rect {
    //DLogMainThread();
//    if (![NSThread isMainThread]) {
//        //[self performSelectorOnMainThread:<#(SEL)#> withObject:<#(id)#> waitUntilDone:<#(BOOL)#>]
//        return;
//    }
//    rect = CGRectIntegral(rect);
    //[super setNeedsDisplayInRect:rect];

    // [self.shellView setNeedsDisplayInRect:rect];
    //[self.scrollView setNeedsDisplayInRect:rect];
    //[self.shellContentLayer setNeedsDisplayInRect:rect];
    //[self.usernameTextLayer setNeedsDisplay];
    //[self.usernameTextLayer setNeedsDisplayInRect:rect];

}



- (void)updateContentsDisplayWithRect:(CGRect)rect {
    DLogObject(self);

    //@weakify(self);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    @strongify(self);
        //[self.shellView setNeedsDisplay];
        //[self.scrollView setNeedsDisplay];
    [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
    [self performSelectorOnMainThread:@selector(layoutIfNeeded) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
        //[self setNeedsDisplay];
        //[self.layer displayIfNeeded];
        //});
    //[super setNeedsDisplay];
}

- (void)drawContentRect:(CGRect)rect {
    //[self setupSubviews];
    //if (self.layer.needsLayout) {


    //[

    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//    NSBlockOperation *blockOperation = [NSBlockOperation new];
//    @weakify(self);
//    @weakify(blockOperation);
//
//
//    //DLogMainThread();
//    //DLogObject([NSValue valueWithCGRect:rect]);
//
//    //[blockOperation addExecutionBlock:^{
//    // @strongify(self);
//    //if ([[self.displayTableView visibleCells] containsObject:self]) {
//
//        //[self setNeedsLayout];
//
//        //[self layoutIfNeeded];
//
//    //if (self.layer.needsDisplay) {
//
//        //return;
//        //NSLog(@"needsLayout%@", [NSNumber numberWithBool:self.layer.needsDisplay]);
//        CGRect bounds = CGRectIntegral(rect);
//        UIView *view = self.mainContentView;
//
//        CGSize imageSize = bounds.size;
//
//    //    UIImageView *cachedImage = [[GVCache sharedCache] imageForSectionIndexPath:self.sectionIndexPath];
//    //
//    //    if (cachedImage) {
//    //        //[[cachedImage layer] renderInContext:<#(CGContextRef)#>
//    //        return;
//    //    }
//
//
//
//        //UIGraphicsBeginImageContextWithOptions(imageSize, YES, [UIScreen mainScreen].scale);
//
       CGContextRef context = UIGraphicsGetCurrentContext();
//
//    //[[UIColor whiteColor] setFill];
//
////        if ([blockOperation_weak_ isCancelled]) {
////            //    return;
////        }
//
//
//        //return;
//        //}
//
//    //CGContextScaleCTM(context, 1, -1);
//
//
       CGRect clippingRect = CGContextGetClipBoundingBox(context);
    //DLogCGRect(clippingRect);
//
//    CGFloat contextHeight = clippingRect.size.height;
//    //CGContextTranslateCTM(context, 0.0f, contextHeight);
//    //CGContextScaleCTM(context, 1.0f, -1.0f);
//
//
//
//        CGRect scrollOffsetFrame = CGRectMake(self.scrollView.contentOffset.x, 0, self.frame.size.width, self.scrollView.frame.size.height);
//        if (!CGRectIntersectsRect(scrollOffsetFrame, clippingRect)) {
//            return;
//        }



//    CFStringRef string = (__bridge_retained CFStringRef)self.userString;
//    CTFontRef font = CTFontCreateWithName((CFStringRef)[self.titleNormalFont fontName], [self.titleNormalFont pointSize], NULL);
//    // Initialize the string, font, and context
//
//    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
//    CFTypeRef values[] = { font, self.titleNormalColor.CGColor };
//
//    CFDictionaryRef attributes =
//    CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
//                       (const void**)&values, sizeof(keys) / sizeof(keys[0]),
//                       &kCFTypeDictionaryKeyCallBacks,
//                       &kCFTypeDictionaryValueCallBacks);
//
//    CFAttributedStringRef attrString =
//    CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
//
//    CFBridgingRelease(attributes);
//
//    CTLineRef line = CTLineCreateWithAttributedString(attrString);
//    CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
//    CGFloat lineHeight = 0;
//    if (lineBounds.size.height > 0) {
//        lineHeight = lineBounds.size.height;
//    }
//
//    // Set text position and draw the line into the graphics context
//    CGContextSetTextPosition(context, 10.0, cground(contextHeight - lineHeight));
//
////    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
////        DLogObject(self.sectionIndexPath);
////        return;
////    }
//
//    CTLineDraw(line, context);
//    CFBridgingRelease(line);
//    CFBridgingRelease(string);
//    if ([self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
//
//    }

    
    if (self.titleTextString) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            //@strongify(self);
        // -renderInContext: renders in the coordinate space of the layer,
        // so we must first apply the layer's geometry to the graphics context
        CGContextSaveGState(context);
        {
            // Center the context around the view's anchor point
            //  CGContextTranslateCTM(context, [view center].x, [view center].y);
            // Apply the view's transform about the anchor point
            //CGContextConcatCTM(context, [view transform]);
        //CGContextScaleCTM(context, 1, 1);
            // Offset by the portion of the bounds left of and above the anchor point
            //CGContextTranslateCTM(context,
            //                   -[view bounds].size.width * [[view layer] anchorPoint].x,
            //                   -[view bounds].size.height * [[view layer] anchorPoint].y);

            // Render the layer hierarchy to the current context



            CGContextTranslateCTM(context, 0.0f, clippingRect.size.height);
            CGContextScaleCTM(context, 1.0f, -1.0f);


        NSAttributedString *sizeString = [[NSAttributedString alloc] initWithString:self.titleTextString attributes:@{NSFontAttributeName: self.titleNormalFont, NSForegroundColorAttributeName: self.titleNormalColor}];

        CGSize textSize = [sizeString size];

        CGFloat textXInset = 0;
        if (CGFLOAT_IS_DOUBLE) {
            textXInset = [self.textXInset doubleValue];
        } else {
            textXInset = [self.textXInset floatValue];
        }

        if (textSize.width > [UIScreen mainScreen].bounds.size.width) {

            CGRect textAreaRect = CGRectMake(0, 0, textXInset + textSize.width + [UIScreen mainScreen].bounds.size.width, textSize.height);



            if (CGRectIntersectsRect(clippingRect, textAreaRect)) {
                // we have to draw

                [GVMasterModelObject drawTitleText:self.titleTextString atOrigin:CGPointMake((-([UIScreen mainScreen].bounds.size.width)), clippingRect.size.height) context:context];

    //            UIFont *titleNormalFont = self.attributes[NSFontAttributeName];
    //            UIColor *titleNormalColor = self.attributes[NSForegroundColorAttributeName];
    //
    //
    //            CTFontRef font = CTFontCreateWithName((CFStringRef)[titleNormalFont fontName], [titleNormalFont pointSize], NULL);
    //            // Initialize the string, font, and context
    //
    //            CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName};
    //            CFTypeRef values[] = { font, titleNormalColor.CGColor};
    //
    //            CFDictionaryRef attributes =
    //            CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
    //                               (const void**)&values, sizeof(keys) / sizeof(keys[0]),
    //                               &kCFTypeDictionaryKeyCallBacks,
    //                               &kCFTypeDictionaryValueCallBacks);
    //
    //            CFAttributedStringRef attrString =
    //            CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef) self.titleTextString, attributes);
    //
    //            CFBridgingRelease(attributes);
    //
    //            CTLineRef line = CTLineCreateWithAttributedString(attrString);
    //            CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
    //            CGFloat lineHeight = 0;
    //            if (lineBounds.size.height > 0) {
    //                lineHeight = lineBounds.size.height;
    //            }
    //
    //            //CGFloat overhangOfTile =
    //
    //            //NSAttributedString *usersLabelAttrString = [[NSAttributedString alloc] initWithString:usersLabelString attributes:@{NSFontAttributeName: titleNormalFont, NSForegroundColorAttributeName: (id)titleNormalColor}];
    //
    //            //CGFloat textXInset = 3.5;
    //
    //            // Set text position and draw the line into the graphics context
    //            CGContextSetTextPosition(context, -([UIScreen mainScreen].bounds.size.width + clippingRect.origin.x - textXInset), cground(clippingRect.size.height - lineHeight));
    //
    //            //    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
    //            //        DLogObject(self.sectionIndexPath);
    //            //        return;
    //            //    }
    //            
    //            CTLineDraw(line, context);


            }

        }

        }
        CGContextRestoreGState(context);
    }
    CGContextSaveGState(context);
    {

        CGContextTranslateCTM(context, 0.0f, GVMasterTableViewCellRowHeight);
        CGContextScaleCTM(context, 1.0f, -1.0f);

        //DLogCGRect(clippingRect);
        //  CGContextTranslateCTM(context, 0.0f, - (clippingRect.origin.y));
        //CGContextScaleCTM(context, 1.0f, -1.0f);

    //NSUInteger scrollWidth = [self.scrollWidth unsignedIntegerValue];
        
//        NSUInteger threshold = 26;
//        if ([self.userImageFiles count] > threshold) {
//            threshold += 1;
//        }
        
    for (NSUInteger i = 0;i<[self.userImageFiles count];i++) {
        NSDictionary *data = [self.userImageFiles objectForKey:[NSIndexPath indexPathForItem:i inSection:0]];

        CGPoint imageOrigin = [data[@"point"] CGPointValue];

        CGSize imageSize = [self.imageSize CGSizeValue];

        CGFloat tileYpadding = imageYPadding;

        CGRect imageRect = CGRectMake(imageOrigin.x - [UIScreen mainScreen].bounds.size.width, imageYPadding, imageSize.width + badgeSize - badgeXPadding, GVMasterTableViewCellRowHeight);

//        if (i > 20) {
//            DLogNSUInteger(i);
//        }

        if (CGRectIntersectsRect(imageRect, clippingRect) && imageRect.origin.x < [self.scrollWidth unsignedIntegerValue] ) {
            // we have to draw this bitch

            NSString *usernameString = data[@"name"];
            NSDate *date = data[@"date"];
            NSString *usernameURLString = data[@"url"];
            
            NSString *key = data[@"key"];
            
            NSNumber *shouldRecordNum = data[@"should_record"];
            NSNumber *imageOrientNum = data[@"imageOrientation"];
            UIImageOrientation imageOrientation = UIImageOrientationRightMirrored;
            if (imageOrientNum && [imageOrientNum respondsToSelector:@selector(integerValue)]) {
                imageOrientation = [imageOrientNum integerValue];
            }
            BOOL shouldRecord = NO;
            if (shouldRecordNum && [shouldRecordNum respondsToSelector:@selector(boolValue)]) {
                shouldRecord = [shouldRecordNum boolValue];
            }
            UIImage *profImage = nil;
            if (usernameURLString && ![usernameURLString isKindOfClass:[NSNull class]]) {
                profImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:usernameURLString];
            }
            if (profImage && ![profImage isKindOfClass:[NSNull class]]) {
                profImage = [UIImage imageWithCGImage:profImage.CGImage scale:1.0 orientation:imageOrientation];
            }
            BOOL showUnread = NO;
            NSNumber *showUnreadNum = data[@"show_unread"];
            if (showUnreadNum && [showUnreadNum respondsToSelector:@selector(boolValue)]) {
                showUnread = [showUnreadNum boolValue];
            }
            //DLogCGRect(imageRect);
            

            [GVMasterModelObject drawProfileImage:profImage atPoint:CGPointMake(imageRect.origin.x, imageYPadding) context:context username:usernameString createdAt:date currentDate:[NSDate date] shouldRecord:shouldRecord showUnread:showUnread key:key];
        }
        
    }

    }
    CGContextRestoreGState(context);

    // CGContextRestoreGState(<#CGContextRef c#>)
//
//    CGFloat tapXPadding = 0;
//    CGFloat imageSize = 0;
//    CGFloat imagePadding = 0;
//    if (CGFLOAT_IS_DOUBLE) {
//        tapXPadding = [self.tapPadding doubleValue];
//        imageSize = [self.imageSize doubleValue];
//        imagePadding = [self.imagePadding doubleValue];
//    } else {
//        tapXPadding = [self.tapPadding floatValue];
//        imageSize = [self.imageSize floatValue];
//        imagePadding = [self.imagePadding floatValue];
//    }
//
//    CGRect originalRect = CGRectMake(clippingRect.origin.x + [UIScreen mainScreen].bounds.size.width, clippingRect.origin.y, clippingRect.size.width, clippingRect.size.height);
//
//
//    CGFloat containerRange = originalRect.origin.x + clippingRect.size.width;
//
//     for (NSUInteger i = 0;i<[self.sortedProfilePics count];i++) {
////      if (i > imagesInFirstPic) {
////          continue;
////      }
//
//
//
//        //PFObject *activity = [sortedActivities objectAtIndex:i];
//        //PFUser *activityUser = [activity objectForKey:kGVActivityUserKey];
//        //NSDictionary *cachedInfo = [[GVDiskCache diskCache] cachedAttributesForUsername:[activityUser username]];
//        //NSURL *usernameURL = [cachedInfo objectForKey:kGVDiskCacheUserProfilePic];
//        UIImage *profImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[usernameURL absoluteString]];
//
//        CGFloat imageX = (tapToSendXAndPadding) + ( (imageSize + imagePadding) * i);
//        CGSize aspectSize = [self aspectSize:CGSizeMake(imageSize, imageSize) image:profImage.CGImage];
//        if (isnan(aspectSize.width)) {
//            aspectSize.width = imageSize;
//        }
//        if (isnan(aspectSize.height)) {
//            aspectSize.height = imageSize;
//        }
//        //CGSize aspectSize = CGSizeMake(0, 0);
//        //            if (aspectSize.width > 0) {
//        //                aspectSize.width = dirtyAspectSize.width;
//        //            }
//        //            if (aspectSize.height > 0) {
//        //                aspectSize.height = dirtyAspectSize.height;
//        //            }
//
//
//        CGFloat aspectAdj = ((imageSize - aspectSize.width)/2);
//        CGFloat aspectAdjY = (imageSize - aspectSize.height)/2;
//        CGFloat imageY = imageYPadding;
//        CGRect imageRect = CGRectIntegral(CGRectMake(imageX + aspectAdj, imageY + aspectAdjY, aspectSize.width, aspectSize.height));
//
//        //            maskedImageView.image = profImage;
//        //            maskedImageView.frame = imageRect;
//
//#if REFLECTION
//        // draw reflection first
//        CGContextSaveGState(context);
//        {
//
//
//
//            CGContextTranslateCTM(context, 0.0f, contextHeight);
//            CGContextScaleCTM(context, 1.0f, -1.0f);
//
//            CGRect cropRect = CGRectIntegral(CGRectMake(imageX, contextHeight - imageYPadding, imageSize, imageSize));
//            UIBezierPath *bezierCirclePath = [UIBezierPath bezierPathWithRoundedRect:cropRect cornerRadius:imageSize/2];
//            [bezierCirclePath setFlatness:0.0];
//
//            //[bezierCirclePath addClip];
//            //[bezierCirclePath stroke];
//
//            //CGAffineTransform t = CGAffineTransformTranslate(CGAffineTransformIdentity, imageX, 0 );
//            //[bezierCirclePath moveToPoint:CGPointMake(imageRect.origin.x, 0)];
//            //[bezierCirclePath applyTransform:t];
//
//            [bezierCirclePath addClip];
//
//
//            //CGContextClipToMask(context, cropRect, <#CGImageRef mask#>)
//
//
//
//
//            //                CGContextClipToDrawing(context, cropRect, ^(CGContextRef maskContext, CGRect rect){
//            //                    UIGraphicsPushContext(maskContext);
//            //
//            //
//            //
//            //
//            //                    //[[UIColor whiteColor] setFill];
//            //                    //CGContextFillRect(maskContext, rect);
//            //
//            //                    //[[UIColor blackColor] setFill];
//            //                    //[@"Clear" drawInRect:rect withFont:[UIFont boldSystemFontOfSize:20.0]];
//            //
//            //                    UIGraphicsPopContext();
//            //                });
//
//            CGContextClipToMask(context, cropRect, mask);
//
//            CGRect flippedImageRect = CGRectIntegral(CGRectMake(imageRect.origin.x, contextHeight - (imageY - aspectAdjY), imageRect.size.width, imageRect.size.height));
//            //            [maskedImageView.layer renderInContext:context];
//            CGContextDrawImage(context, flippedImageRect, profImage.CGImage);
//
//
//            //CGContextDrawImage(context, cropRect, gradientImage);
//
//
//
//
//            //CGContextDrawImage(context, CGRectMake(imageX, 0, imageSize, imageSize), gradientImage.CGImage);
//
//
//            //  [bezierCirclePath stroke];
//            //             [bezierCirclePath stroke];
//
//        }
//        CGContextRestoreGState(context);
//#endif
//
//        // draw profile image
//        CGContextSaveGState(context);
//        {
//            CGRect cropRect = CGRectIntegral(CGRectMake(imageX, imageY, imageSize, imageSize));
//            UIBezierPath *bezierCirclePath = [UIBezierPath bezierPathWithRoundedRect:cropRect cornerRadius:imageSize/2];
//            [bezierCirclePath setFlatness:0.0];
//
//            // [bezierCirclePath addClip];
//
//            //CGAffineTransform t = CGAffineTransformTranslate(CGAffineTransformIdentity, imageX, 0 );
//            //[bezierCirclePath moveToPoint:CGPointMake(imageRect.origin.x, 0)];
//            //[bezierCirclePath applyTransform:t];
//
//            [bezierCirclePath addClip];
//            
//            //            [maskedImageView.layer renderInContext:context];
//            CGContextDrawImage(context, imageRect, profImage.CGImage);
//            //  [bezierCirclePath stroke];
//            //             [bezierCirclePath stroke];
//            
//        }
//        CGContextRestoreGState(context);
//        
//        
//        
//        
//        
//    }

    // [[UIColor redColor] setFill];
    //   CGContextFillRect(context, clippingRect);
        //CGContextFillRect(context, CGRectMake(self.scrollView.contentOffset.x, 0, self.bounds.size.width, self.shellView.bounds.size.height));

        //[[UIColor redColor] setFill];
        //CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        //CGContextFillRect(context, CGRectMake(self.scrollView.contentOffset.x, 0, 256, 256));
        //CGContextFillRect(context, clippingRect);



        //DLogCGRect(clippingRect);
        //CGContextFillRect(context, CGRectMake(self.scrollView.contentOffset.x, 0, self.bounds.size.width, self.shellView.bounds.size.height));


        //  [[view layer] renderInContext:context];


        // Restore the context
        //   CGContextRestoreGState(context);
        //}
        //UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

        //UIImageView *initImage = [[UIImageView alloc] initWithImage:image];

        //[[GVCache sharedCache] setAttributesForMasterSectionImage:initImage forSectionIndexPath:self.sectionIndexPath];

        //UIGraphicsEndImageContext();

        //[snapshot drawViewHierarchyInRect:rect afterScreenUpdates:NO];
        //UIView *snapshot = [self.mainContentView snapshotViewAfterScreenUpdates:YES];
        //[self.mainContentView drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
        //[self.mainContentView removeFromSuperview];
        //[self.mainContentView.layer drawInContext:ctx];
        // }
        //});

        //}];
    //[self.operationQueue addOperations:@[blockOperation] waitUntilFinished:YES];
    // [self.mainContentView removeFromSuperview];
        //}
        //});
}

#endif

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if ([gestureRecognizer.view isDescendantOfView:self]) {
//        return YES;
//    }
//    return NO;
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//
//}
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}


//#pragma mark -
//#pragma mark iCarousel methods
//
//- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
//{
//    //return the total number of items in the carousel
//    return [self.userImageFiles count];
//}
//
//- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
//{
//    UILabel *label = nil;
//
//    //create new view if no view is available for recycling
//    if (view == nil)
//    {
//        //don't do anything specific to the index within
//        //this `if (view == nil) {...}` statement because the view will be
//        //recycled and used with other index values later
//        //{
//        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 83, 83)];
//
//
//        //view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 84.0f, 84.0f)];
//
//        view.layer.contentsScale = [UIScreen mainScreen].scale;
//        view.layer.shouldRasterize = YES;
//        view.layer.allowsEdgeAntialiasing = YES;
//        view.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;
//        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        //view.layer.borderColor = [UIColor whiteColor].CGColor;
//        //view.layer.borderWidth = 1;
//
//
//
////        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.frame.size.width/2];
////        [bezierPath setFlatness:0.0];
////        shapeLayerMask.path = bezierPath.CGPath;
////        view.layer.mask = shapeLayerMask;
//        //view.backgroundColor = [UIColor redColor];
//        //((UIImageView *)view).image = [self.userImageFiles ;
//        //view.contentMode = UIViewContentModeCenter;
//
//        label = [[UILabel alloc] initWithFrame:view.bounds];
//        label.backgroundColor = [UIColor clearColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [label.font fontWithSize:50];
//        label.tag = 1;
//        //[view addSubview:label];
//        //}
//
//
//    }
//    else
//    {
//        //get a reference to the label in the recycled view
//        //label = (UILabel *)[view viewWithTag:1];
//    }
//
////    id obj = [self.userImageFiles objectForKey:[NSIndexPath indexPathForItem:<#(NSInteger)#> inSection:<#(NSInteger)#>]];
////    if (obj && [obj respondsToSelector:@selector(objectForKey:)]) {
////
////        UIImageView *imageView = obj[@"imageView"];
////        for (UIView *subview in view.subviews) {
////            [subview removeFromSuperview];
////        }
////        [view   addSubview:imageView];
////        imageView.frame = CGRectIntegral(view.frame);
////        //((UI.image = [obj[@"imageView"] image];
////        CAShapeLayer *shapeLayerMask = [CAShapeLayer layer];
////
////        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:imageView.frame cornerRadius:imageView.frame.size.width/2];
////        [bezierPath setFlatness:0.0];
////        shapeLayerMask.path = bezierPath.CGPath;
////        imageView.layer.mask = shapeLayerMask;
////
////        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
////        view.translatesAutoresizingMaskIntoConstraints = NO;
////        view.clipsToBounds = YES;
////        view.contentMode = UIViewContentModeScaleAspectFill;
////    }
//
//    //set item label
//    //remember to always set any properties of your carousel item
//    //views outside of the `if (view == nil) {...}` check otherwise
//    //you'll get weird issues with carousel item content appearing
//    //in the wrong place in the carousel
//    //label.text = [_items[index] stringValue];
//
//    return view;
//}
//
//- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
//{
//    if (option == iCarouselOptionShowBackfaces) {
//        return 0.0f;
//    }
//
//    if (option == iCarouselOptionSpacing)
//    {
//        return value * 1.1f;
//    }
//    return value;
//}

- (void)addActivities:(NSArray *)activities {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
    self.userImageFiles = activities;
        //[self.collectionView reloadData];
    //[self.collectionCarousel reloadData];
//    for (NSDictionary *info in self.userImageFiles) {
//        if (info && [info respondsToSelector:@selector(objectForKey:)]) {
//            UIImageView *imageView = info[@"imageView"];
//            if (imageView && [imageView respondsToSelector:@selector(setDisplayDelegate:)]) {
//                [imageView performSelector:@selector(setDisplayDelegate:) withObject:self];
//            }
//        }
//    }

        //DLogMainThread();
        //DLogFunctionLine();


    //[self setNeedsLayout];
    //[self layoutIfNeeded];
    //[super setNeedsLayout];
    //[super layoutIfNeeded];
    //[super setNeedsDisplay];
    //[self.shellView setNeedsDisplay];
    //[self.collectionCarousel scrollToItemAtIndex:0 animated:NO];
    //[self setNeedsDisplay];
//    for (NSDictionary *info in self.userImageFiles) {
//        UIImageView *img = info[@"imageView"];
//        if (img && [img respondsToSelector:@selector(setDisplayDelegate:)]) {
//            [img performSelector:@selector(setDisplayDelegate:) withObject:self];
//        }
//    }
//[self setNeedsDisplay];

    //[self.shellView setNeedsDisplayInRect:self.scrollView.frame];
    //[self setNeedsDisplay];
    //[self.shellView.layer setNeedsDisplay];
    //[self.shellView.layer displayIfNeeded];
    //[self.layer displayIfNeeded];
    //[super setNeedsLayout];
    //[super setNeedsDisplay];

        [CATransaction begin];
        [CATransaction setAnimationDuration:0.0];
        [CATransaction setDisableActions:YES];

        //self.scrollView.contentSize = CGSizeMake(self.collectionViewFlowLayout.itemSize.width * [self.userImageFiles count], self.bounds.size.height);

    //[self setNeedsLayout];
    //[self layoutIfNeeded];
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
            //[self layoutIfNeeded];
            [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
            //[self.shellView performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.0];
            //[self.scrollView performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.0];
            //[self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.0];

            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            CGFloat collectionViewHeight = self.collectionViewFlowLayout.itemSize.width;
//self.scrollView.frame = CGRectIntegral(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));

            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [CATransaction begin];
                [CATransaction setAnimationDuration:0.0];
                [CATransaction setDisableActions:YES];
            self.shellView.layer.frame = CGRectIntegral(CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height));
                self.shellContentLayer.frame = CGRectIntegral(self.scrollView.frame);
                //dispatch_async(dispatch_get_main_queue(), ^{
                    [self.shellView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
                [self.shellContentLayer performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];

                [CATransaction commit];
                //});
            });
            //})

            //});
        });

    [CATransaction commit];
    //});
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.0];
//    });
}

- (BOOL)getIsSelected {
    return (self.selectedBackgroundView.superview != nil);
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    //NSLog(@"contentOffset: %@", [NSValue valueWithCGPoint:scrollView.contentOffset]);
//    //NSLog(@"self tiled layer %@", NSStringFromCGRect(self.shellView.layer.bounds));
//    //NSLog(@"self tiled layer frame %@", NSStringFromCGRect(self.shellView.layer.frame));
//
//
//    //[self setNeedsLayout];
//    //[self layoutIfNeeded];
//    //[self.shellView setNeedsDisplay];
//    //[self updateContentsDisplayWithRect:CGRectMake(scrollView.contentOffset.x, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
//
//
//    //[self.shellView setNeedsDisplayInRect:CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.frame.size.width, scrollView.frame.size.height)];
//
//    return;
//    if (scrollView != self.collectionView) {
//        @weakify(self);
//        //NSLog(@"contentOffset %@", NSStringFromCGPoint(scrollView.contentOffset));
//        CGFloat rightSidePadding = 82.0;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @strongify(self);
////            if (scrollView.contentOffset.x > rightSidePadding + 10) {
////                CGFloat additionalSpace = (scrollView.contentOffset.x - rightSidePadding);
////                self.collectionView.contentOffset = CGPointMake( additionalSpace - 10, 0);
////                CGRect frame = self.collectionView.frame;
////                frame.size.width = CGRectGetWidth(scrollView.frame) + additionalSpace - 10;
////                self.collectionView.frame = frame;
////            } else if (scrollView.contentOffset.x > rightSidePadding) {
////                CGFloat additionalSpace = (scrollView.contentOffset.x - rightSidePadding);
////                self.collectionView.contentOffset = CGPointMake( additionalSpace - 10, 0);
////
////                CGRect frame = self.collectionView.frame;
////                frame.size.width = CGRectGetWidth(scrollView.frame) + additionalSpace - 10;
////                self.collectionView.frame = frame;
////            } else {
////                //CGFloat additionalSpace = (scrollView.contentOffset.x - rightSidePadding);
////                self.collectionView.contentOffset = CGPointMake(0, 0);
////
////                CGRect frame = self.collectionView.frame;
////                frame.size.width = CGRectGetWidth(scrollView.frame) - 10;
////                self.collectionView.frame = frame;
////            }
//            if (scrollView.contentOffset.x > rightSidePadding) {
//                CGFloat additionalSpace = (scrollView.contentOffset.x - rightSidePadding);
//                self.collectionView.contentOffset = CGPointMake( additionalSpace, 0);
//
//                CGRect frame = self.collectionView.frame;
//                frame.size.width = CGRectGetWidth(scrollView.frame) + additionalSpace;
//                self.collectionView.frame = frame;
//            } else {
//                //CGFloat additionalSpace = (scrollView.contentOffset.x - rightSidePadding);
//                self.collectionView.contentOffset = CGPointMake(0, 0);
//
//                CGRect frame = self.collectionView.frame;
//                frame.size.width = CGRectGetWidth(scrollView.frame);
//                self.collectionView.frame = frame;
//            }
//
//        });
//    }
//}

- (void)setNeedsLayout {
    //[super setNeedsLayout];

    //[self.collectionViewFlowLayout invalidateLayout];
    //[self.collectionCarousel setNeedsLayout];
    //[self updateContentsDisplayWithRect:CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.frame.size.width, self.shellView.frame.size.height)];
    [self.scrollView setNeedsLayout];
    [self.shellView setNeedsLayout];
    //[self.scrollView performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
    //[self.shellView performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
}

- (void)layoutSubviews {
    //[super layoutSubviews];
////    if (![[[self displayTableView] visibleCells] containsObject:self]) {
////        return;
////    }
//
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:0.0];
//    [CATransaction setDisableActions:YES];
//
//    self.cellImageView.frame = self.bounds;
//
//    //self.contentView.frame = CGRectIntegral(self.bounds);
//
//    CGFloat collectionViewHeight = self.bounds.size.height;
//    //CGRect baseRect = CGRectMake(0, self.bounds.size.height/2 - collectionViewHeight/2, self.bounds.size.width , collectionViewHeight);
//
//    //[self.scrollView layoutIfNeeded];
//
//#if MASTER_TABLE_VIEW_CONTENT_VIEW
//    self.scrollView.frame = CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
//    self.scrollView.contentSize = CGSizeMake(self.collectionViewFlowLayout.itemSize.width * [self.userImageFiles count], self.bounds.size.height);
//    //self.shellView.frame = CGRectIntegral(CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height));
//    //
//
//
//
//    //self.shellView.frame = CGRectIntegral(CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height));
//    //self.collectionView.frame = CGRectIntegral(self.shellView.bounds);
//
//    //self.shellView.frame = CGRectIntegral(CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height));
//    //self.collectionView.frame = CGRectIntegral(self.shellView.frame);
//
//    //self.collectionView.contentOffset = self.scrollView.contentOffset;
//    //[self updateContentsDisplayWithRect:self.shellView.frame];
//    //self.collectionCarousel.frame = CGRectIntegral(CGRectMake(0, baseRect.origin.y, self.bounds.size.width, baseRect.size.height));
//    //self.mainContentView.frame = CGRectIntegral(self.shellView.bounds);
//#else
//
//    //CGFloat collectionViewPadding = 18;
//    //self.collectionView.frame = baseRect;
//#endif
//
//    [CATransaction commit];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    //DLogMainThread();
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //[CATransaction begin];
    //[CATransaction setAnimationDuration:0.0];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.0];
    self.needsToDraw = YES;
    self.userImageFiles = nil;
    self.userInfo = nil;
    self.shellView.layer.contents = nil;
    [self.shellView setNeedsDisplay];
    [self.scrollView setNeedsDisplay];
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    self.mainImageView.image = nil;
    [self setupScrollViewTileSize];
    [self.scrollView.layer.mask setNeedsDisplay];
    [self.scrollView setContentOffset:CGPointZero];
    //self.gradientLayerMask.startPoint = CGPointMake(0.0 - self.gradientWidth, 0.5);
    //self.gradientLayerMask.endPoint = CGPointMake(1.0 + self.gradientWidth, 0.5);
    self.gradientLayerMask.startPoint = CGPointMake(-(self.gradientWidth), 0.5);
    self.gradientLayerMask.endPoint = CGPointMake(1.0 + self.gradientWidth, 0.5);
    [CATransaction commit];
    //[self.scrollView.layer.mask setNeedsDisplay];
    //self.mainImageView.layer.contents = nil;
    //[self.scrollView setNeedsDisplay];
    //self.shellContentLayer.contents = nil;
    //[CATransaction commit];
    //CATiledLayer *tiledLayer = (CATiledLayer*)self.shellView.layer;
    //CGSize aTileSize = tiledLayer.tileSize;
    //CGSize aTileChange = CGSizeMake(aTileSize.width+1, aTileSize.width+1);
    //tiledLayer.tileSize = aTileChange;
    //tiledLayer.tileSize = aTileSize;
    //[self addActivities:[NSArray array]];
    //self.shellView.layer.delegate = nil;
    //[self setNeedsLayout];
    //[self setNeedsDisplay];
    //[self layoutIfNeeded];
    //[self.shellView.layer setNeedsDisplay];
    //[self.shellView setNeedsDisplay];
    //[super setNeedsDisplay];
    //[self.shellView.layer displayIfNeeded];
    //[self.operationQueue cancelAllOperations];
    //[self updateContentsDisplayWithRect:self.bounds];
    //});
    
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return [self.userImageFiles count];
//}
//
//- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    GVMasterTableViewCollectionViewCell *cell = (GVMasterTableViewCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:GVMasterTableViewCellCollectionView forIndexPath:indexPath];
//
//    //DLogMainThread();
//    [cell removeAllSubImageViews];
//
//
//    NSDictionary *info = [self.userImageFiles objectAtIndex:indexPath.item];
//    cell.activityId = info[@"activityId"];
//    cell.threadId = info[@"threadId"];
//    
//    UIImageView *imageView = info[@"imageView"];
//
//    //DLogObject(indexPath);
//    cell.collectionIndexPath = indexPath;
//    cell.sectionIndexPath = self.sectionIndexPath;
//#if MASTER_TABLE_VIEW_CONTENT_VIEW
//    cell.displayDelegate = self;
//#endif
//
//    NSString *duration = info[@"duration"];
//    if (duration) {
//        [cell setDurationString:duration];
//    }
//    NSNumber *unread = info[@"showsActivityUnread"];
//    if (unread) {
//        cell.showsUnread = [unread boolValue];
//    }
//
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//
//
//    if (imageView) {
//        [cell setImageView:imageView];
//
//    }
//    //[self setNeedsDisplay];
//
//    return cell;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    GVMasterTableViewCollectionViewCell *cell = (GVMasterTableViewCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    NSDictionary *dict = @{@"indexPath":indexPath, @"sectionIndexPath": self.sectionIndexPath, @"activityId": cell.activityId, @"threadId": cell.threadId};
//    [[NSNotificationCenter defaultCenter] postNotificationName:GVMasterTableViewCellCollectionSelectNotification object:nil userInfo:dict];
//}
//

@end
