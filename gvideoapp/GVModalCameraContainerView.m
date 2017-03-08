//
//  GVModalCameraContainerView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVModalCameraContainerView.h"
#import "GVSplitTableView.h"
#import "GVModalCameraScrollView.h"
#import "GVShortTapGestureRecognizer.h"
#import "GVNavigationToolbar.h"
#import "GVCellSlidePanGestureRecognizer.h"
#import "GVMasterTableViewCell.h"
#import "GVThreadBackgroundView.h"
#import "GVTintColorUtility.h"
#import "GVModalCameraContainerView.h"
#import <objc/runtime.h>

const CGFloat splitTableNavHeight = 63;
const CGFloat splitTablePaneHeight = 154;
const CGFloat navToolbarHeight = 50;


@interface GVModalCameraContainerView () <UIGestureRecognizerDelegate, UIScrollViewDelegate>


@property (nonatomic, strong) UILongPressGestureRecognizer *cameraTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *flipTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *libraryTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *flashTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *bottomTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *bottomLongPressGestureRecognizer;
//@property (nonatomic, strong) UILongPressGestureRecognizer *bottomDoubleTapGestureRecognizer;
//@property (nonatomic, strong) GVCellSlidePanGestureRecognizer *slidePanGestureRecognizer;
//@property (nonatomic, strong) CADisplayLink *displayLink;



@property (nonatomic, assign) CFTimeInterval currentTimeInterval;

@property (nonatomic, assign) CGPoint workingContentOffset;

@property (nonatomic, strong) UIView *snapshotView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;


@property (nonatomic, strong) GVNavigationToolbar *navigationToolbar;


@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, strong) UILabel *loadingThumbnailLabel;

@property (nonatomic, strong) UIColor *highlightedColor;

@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation GVModalCameraContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        _bgView = [[GVThreadBackgroundView alloc] initWithFrame:frame];
        [self addSubview:_bgView];

        _contentsContainer = [[UIView alloc] initWithFrame:frame];
        _contentsContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentsContainer.translatesAutoresizingMaskIntoConstraints = NO;
        _contentsContainer.layer.needsDisplayOnBoundsChange = NO;
        _contentsContainer.autoresizesSubviews = NO;
        //_contentsContainer.clipsToBounds = YES;
        //_contentsContainer.layer.anchorPoint = CGPointMake(0.5, 0);
        //_contentsContainer.layer.shouldRasterize = YES;
        _contentsContainer.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _contentsContainer.opaque = YES;
        _contentsContainer.layer.allowsEdgeAntialiasing = YES;
        _contentsContainer.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;
        //[self addSubview:_contentsContainer];


        _highlightedColor = [UIColor colorWithWhite:1.0 alpha:0.9];

        _topContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _topContainerView.autoresizesSubviews = NO;
        _topContainerView.clipsToBounds = YES;
        _topContainerView.opaque = YES;
        _topContainerView.layer.anchorPoint = CGPointMake(0.5, 0);
        _topContainerView.clearsContextBeforeDrawing = NO;
        //_topContainerView.layer.shouldRasterize = YES;
        _topContainerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _topContainerView.layer.needsDisplayOnBoundsChange = NO;
        _topContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _topContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_topContainerView];
        
        UIFont *loadingFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        
        NSDictionary *loadingAttributes = @{NSForegroundColorAttributeName: [GVTintColorUtility utilityPurpleColor],
                                            NSFontAttributeName: loadingFont};

        NSAttributedString *loadingString = [[NSAttributedString alloc] initWithString:@"Loading..." attributes:loadingAttributes];

        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _loadingLabel.layer.shouldRasterize = YES;
        _loadingLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //_loadingLabel.text = @"Loading...";
        _loadingLabel.layer.needsDisplayOnBoundsChange = NO;
        [_loadingLabel setAttributedText:loadingString];
        _loadingLabel.opaque = YES;
        _loadingLabel.backgroundColor = [UIColor whiteColor];

        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                     NSParagraphStyleAttributeName: paragraphStyle,
                                     NSBackgroundColorAttributeName: [UIColor whiteColor],
                                     NSFontAttributeName: font};
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"Appears to be empty." attributes:attributes];

        
        
        self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.emptyLabel setAttributedText:attrString];
        self.emptyLabel.layer.shouldRasterize = YES;
        self.emptyLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.emptyLabel.opaque = YES;
        

        NSAttributedString *loadingThumbnailString = [[NSAttributedString alloc] initWithString:@"Downloading Thumbnails..." attributes:loadingAttributes];
        
        _loadingThumbnailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _loadingThumbnailLabel.layer.shouldRasterize = YES;
        _loadingThumbnailLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _loadingThumbnailLabel.layer.needsDisplayOnBoundsChange = NO;
        [_loadingThumbnailLabel setAttributedText:loadingThumbnailString];
        _loadingThumbnailLabel.opaque = YES;
        

        CGRect fillRect = CGRectMake(0, 0, self.frame.size.width, [self contentOffsetForBottomView]);

        CGPathRef shapeLayerPath = CGPathCreateWithRect(fillRect, NULL);
        self.shapeLayerMask.path = shapeLayerPath;
#if DEBUG_CF_MEMORY
        CFBridgingRelease(shapeLayerPath);
#endif
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.opaque = YES;
        //shapeLayer.shouldRasterize = YES;
        [shapeLayer setNeedsDisplay];
        shapeLayer.needsDisplayOnBoundsChange = YES;
        shapeLayer.duration = 0.0;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
//
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        //shapeLayer.fillRule = kCAFill

        self.shapeLayerMask = shapeLayer;
        _topContainerView.layer.mask = shapeLayer;
        //[self.layer addSublayer:shapeLayer];

        _scrollView = [[GVModalCameraScrollView alloc] initWithFrame:frame];
        [self addSubview:_scrollView];

        //self.layer.shouldRasterize = YES;
        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;

        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.autoresizesSubviews = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        //_scrollView.layer.shouldRasterize = YES;
        _scrollView.panGestureRecognizer.cancelsTouchesInView = NO;
        _scrollView.exclusiveTouch = NO;
        _scrollView.layer.allowsEdgeAntialiasing = YES;
        _scrollView.layer.allowsGroupOpacity = YES;
        _scrollView.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;
        _scrollView.autoresizesSubviews = NO;
        _scrollView.delaysContentTouches = YES;
        //_scrollView.layer.shouldRasterize = YES;
        //_scrollView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        //_scrollView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _scrollView.panGestureRecognizer.delaysTouchesBegan = YES;
        _scrollView.layer.needsDisplayOnBoundsChange = NO;
        //_scrollView.clearsContextBeforeDrawing = NO;
        //_scrollView.opaque = YES;


        
        //_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkFired:)];
        //[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        //_displayLink.paused = YES;


        self.cameraTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleCameraTap:)];
        self.cameraTapGestureRecognizer.cancelsTouchesInView = NO;
        self.cameraTapGestureRecognizer.delaysTouchesBegan = YES;
        self.cameraTapGestureRecognizer.delaysTouchesEnded = YES;
        self.cameraTapGestureRecognizer.minimumPressDuration = 0.001;
        self.cameraTapGestureRecognizer.numberOfTapsRequired = 0;
        self.cameraTapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.cameraTapGestureRecognizer];

        self.flipTapGestureRecognizer = [[GVShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFlipTap:)];
        self.flipTapGestureRecognizer.cancelsTouchesInView = NO;
        self.flipTapGestureRecognizer.delaysTouchesBegan = YES;
        self.flipTapGestureRecognizer.delaysTouchesEnded = YES;
        self.flipTapGestureRecognizer.minimumPressDuration = 0.001;
        self.flipTapGestureRecognizer.numberOfTapsRequired = 0;
        self.flipTapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.flipTapGestureRecognizer];

        self.libraryTapGestureRecognizer = [[GVShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLibraryTap:)];
        self.libraryTapGestureRecognizer.cancelsTouchesInView = NO;
        self.libraryTapGestureRecognizer.delaysTouchesBegan = YES;
        self.libraryTapGestureRecognizer.delaysTouchesEnded = YES;
        self.libraryTapGestureRecognizer.minimumPressDuration = 0.001;
        self.libraryTapGestureRecognizer.numberOfTapsRequired = 0;
        self.libraryTapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.libraryTapGestureRecognizer];

        self.flashTapGestureRecognizer = [[GVShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFlashTap:)];
        self.flashTapGestureRecognizer.cancelsTouchesInView = NO;
        self.flashTapGestureRecognizer.delaysTouchesBegan = YES;
        self.flashTapGestureRecognizer.delaysTouchesEnded = YES;
        self.flashTapGestureRecognizer.minimumPressDuration = 0.001;
        self.flashTapGestureRecognizer.numberOfTapsRequired = 0;
        self.flashTapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.flashTapGestureRecognizer];




        self.bottomTapGestureRecognizer = [[GVShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBottomTap:)];
        self.bottomTapGestureRecognizer.cancelsTouchesInView = NO;
        self.bottomTapGestureRecognizer.delaysTouchesBegan = YES;
        self.bottomTapGestureRecognizer.delaysTouchesEnded = YES;
        self.bottomTapGestureRecognizer.minimumPressDuration = 0.001;
        self.bottomTapGestureRecognizer.allowableMovement = 20;
        self.bottomTapGestureRecognizer.delegate = self;
        self.bottomTapGestureRecognizer.numberOfTapsRequired = 0;
        [self addGestureRecognizer:self.bottomTapGestureRecognizer];

        self.bottomLongPressGestureRecognizer = [[GVShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        
        self.bottomLongPressGestureRecognizer.cancelsTouchesInView = NO;
        self.bottomLongPressGestureRecognizer.delaysTouchesBegan = YES;
        self.bottomLongPressGestureRecognizer.delaysTouchesEnded = YES;
        self.bottomLongPressGestureRecognizer.minimumPressDuration = 0.5;
        self.bottomLongPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.bottomLongPressGestureRecognizer];

//        self.bottomDoubleTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//        self.bottomDoubleTapGestureRecognizer.cancelsTouchesInView = NO;
//        self.bottomDoubleTapGestureRecognizer.delaysTouchesBegan = YES;
//        self.bottomDoubleTapGestureRecognizer.delaysTouchesEnded = YES;
//        self.bottomDoubleTapGestureRecognizer.numberOfTapsRequired = 1;
//        self.bottomDoubleTapGestureRecognizer.minimumPressDuration = 0.01;
//        self.bottomDoubleTapGestureRecognizer.delegate = self;

//
//        self.slidePanGestureRecognizer = [[GVCellSlidePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSlidingPan:)];
//        self.slidePanGestureRecognizer.delegate = self;
//        [self addGestureRecognizer:self.slidePanGestureRecognizer];


        [self.cameraTapGestureRecognizer requireGestureRecognizerToFail:_scrollView.panGestureRecognizer];
        [self.flipTapGestureRecognizer requireGestureRecognizerToFail:_scrollView.panGestureRecognizer];
        [self.libraryTapGestureRecognizer requireGestureRecognizerToFail:_scrollView.panGestureRecognizer];
        [self.flashTapGestureRecognizer requireGestureRecognizerToFail:_scrollView.panGestureRecognizer];
        [self.bottomTapGestureRecognizer requireGestureRecognizerToFail:_scrollView.panGestureRecognizer];
        [self.bottomTapGestureRecognizer requireGestureRecognizerToFail:self.bottomLongPressGestureRecognizer];

//        NSArray *arr = _scrollView.gestureRecognizers;
//        for (UIGestureRecognizer *scrollGC in arr) {
//            [scrollGC requireGestureRecognizerToFail:self.bottomTapGestureRecognizer];
//        }
        //[self.slidePanGestureRecognizer requireGestureRecognizerToFail:_scrollView.panGestureRecognizer];

        //[_scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.bottomTapGestureRecognizer];

//        [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.cameraTapGestureRecognizer];
//        [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.flipTapGestureRecognizer];
//        [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.libraryTapGestureRecognizer];
//        [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.flashTapGestureRecognizer];
//        [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.bottomTapGestureRecognizer];

        //self.fastView = [[GVFastTopViewContentView alloc] initWithFrame:CGRectZero];
        //[_scrollView addSubview:self.fastView];
    }
    return self;
}

- (void)handleSlidingPan:(GVCellSlidePanGestureRecognizer*)gc {
    CGPoint translation = [gc translationInView:gc.view];
    CGPoint location = [gc locationInView:gc.view];
    switch (gc.state) {
        case UIGestureRecognizerStatePossible:
            //
            break;
        case UIGestureRecognizerStateBegan:
            DLogFunctionLine();
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint convertPoint = [gc.view convertPoint:location toView:self.bottomViewController.view];
            if ([self.bottomViewController.view pointInside:convertPoint withEvent:nil]) {
                //UIView *view = [self.bottomViewController.view hitTest:convertPoint withEvent:nil];

                NSArray *visibleCells = self.scrollView.childTableView.visibleCells;
                for (GVMasterTableViewCell *cell in visibleCells) {
                    CGPoint aConvertPoint = [self.bottomViewController.view convertPoint:convertPoint toView:cell];
                    if ([cell pointInside:aConvertPoint withEvent:nil]) {
                        // found the cell?
                        //DLogObject(cell);
                        //DLogFunctionLine();
                        
                        CATiledLayer *cellTiledLayer = [[cell shellView] layer];
                        CGRect rect = [cellTiledLayer frame];
                        rect.origin.x = translation.x;
                        cellTiledLayer.frame = rect;
                    }
//
                }
//                if ([view pointInside:aConvertPoint withEvent:nil]) {
//
//                }
            }

            //DLogObject(gc.view);
            //DLogFunctionLine();
            break;
        }
        case UIGestureRecognizerStateEnded:

            break;
        case UIGestureRecognizerStateCancelled:

            break;
        case UIGestureRecognizerStateFailed:

            break;

        default:
            break;
    }
}

- (void)handleFlipTap:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        self.topViewController.flipButtonView.tintColor = [GVTintColorUtility utilityTintColor];
        [self.topViewController forwardFlipTapAction:gc];
    }
}

- (void)handleLibraryTap:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        self.topViewController.libraryButtonView.tintColor = [GVTintColorUtility utilityTintColor];
        [self.topViewController forwardLibraryTapAction:gc];
    }
}

- (void)handleFlashTap:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        self.topViewController.flashButtonView.tintColor = [GVTintColorUtility utilityTintColor];
        [self.topViewController forwardFlashTapAction:gc];
    }
}

- (void)handleCameraTap:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        NSLog(@" detected tap successfully...");
        if (self.scrollView.contentOffset.y > 0) {
            [self.scrollView setContentOffset:CGPointZero animated:YES];
        }
        [self.topViewController forwardCameraTapAction:gc];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)gc {
    CGPoint locationInView = [gc locationInView:gc.view];

    //DLogUIGestureRecognizerState(gc.state);

    CGPoint locationInBottomView = [gc.view convertPoint:locationInView toView:self.bottomContainerView];
    BOOL tapInBottomView = [self.bottomContainerView pointInside:locationInBottomView withEvent:nil];
    if (gc.state == UIGestureRecognizerStateBegan
        && tapInBottomView) {
        [self tapInBottomView:locationInView selector:@selector(handleLongPress:) fromView:gc.view handleTap:YES];
    }
}

- (void)handleGestureRecognizer:(GVShortTapGestureRecognizer*)gc tapFail:(NSValue*)pointValue {
    if (gc == self.bottomTapGestureRecognizer || gc == self.bottomLongPressGestureRecognizer) {
        CGPoint locationInView = [pointValue CGPointValue];
        //CGPoint locationOnScreen = [gestureRecognizer.view.window convertPoint:locationInView fromView:gestureRecognizer.view];
        //DLogUIGestureRecognizerState(gc.state);
        
        CGPoint locationInBottomView = [gc.view convertPoint:locationInView toView:self.bottomContainerView];
        BOOL tapInBottomView = [self.bottomContainerView pointInside:locationInBottomView withEvent:nil];
        //if (gc.state == UIGestureRecognizerStateFailed) {
        if (gc.state == UIGestureRecognizerStateFailed || gc.state == UIGestureRecognizerStateCancelled) {
            [self tapInBottomView:locationInView selector:@selector(handleTapFail:) fromView:gc.view handleTap:YES];
        

        }
    }
    self.topViewController.flipButtonView.tintColor = [GVTintColorUtility utilityTintColor];
    self.topViewController.flashButtonView.tintColor = [GVTintColorUtility utilityTintColor];
    self.topViewController.libraryButtonView.tintColor = [GVTintColorUtility utilityTintColor];
        // [self tapInBottomView:<#(CGPoint)#> selector:<#(SEL)#> fromView:<#(UIView *)#> handleTap:<#(BOOL)#>]
    //}
}

- (void)handleBottomTap:(GVShortTapGestureRecognizer*)gc {
    CGPoint locationInView = [gc locationInView:gc.view];
    //CGPoint locationOnScreen = [gestureRecognizer.view.window convertPoint:locationInView fromView:gestureRecognizer.view];
    //DLogUIGestureRecognizerState(gc.state);
    CGPoint locationInBottomView = [gc.view convertPoint:locationInView toView:self.bottomContainerView];
    BOOL tapInBottomView = [self.bottomContainerView pointInside:locationInBottomView withEvent:nil];
    if (gc.state == UIGestureRecognizerStateEnded
        && tapInBottomView) {
        [self tapInBottomView:locationInView selector:@selector(handleTap:) fromView:gc.view handleTap:YES];
    }
}

- (void)setNeedsLayout {
    [super setNeedsLayout];

    //[self.scrollView setNeedsLayout];
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    self.displayLink.paused = YES;
//    self.currentTimeInterval = CACurrentMediaTime();
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    if (self.layer.speed == 0.0) {
//        self.displayLink.paused = NO;
//    } else {
//        self.displayLink.paused = YES;
//    }
//}
//
//- (void)displayLinkFired:(CADisplayLink*)sender {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        CALayer *textLabelLayer = self.topViewController.view.cameraViewController.view.textLabel.layer;
//        CFTimeInterval cTime = [textLabelLayer convertTime:self.currentTimeInterval toLayer:nil];
//        textLabelLayer.timeOffset = cTime;
//        self.currentTimeInterval = CACurrentMediaTime();
//
//        //if (self.layer.speed == 0) {
//
//        //}
//    });
//}



- (UIView*)cameraHitTestViewWithPoint:(NSValue*)value withEvent:(UIEvent*)event {
    CGPoint valuePoint = [value CGPointValue];
    UIView *cameraView = [self.topViewController.view hitTest:valuePoint withEvent:event];
    return cameraView;
}

- (void)setupTopViewController:(UIViewController*)topVC {
    self.topViewController = topVC;
    topVC.view.layer.borderColor = [UIColor clearColor].CGColor;
    topVC.view.layer.borderWidth = 1;
    topVC.view.layer.backgroundColor = [UIColor blackColor].CGColor;
    topVC.view.layer.opaque = YES;
    //topVC.view.layer.shouldRasterize = YES;
    //topVC.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    //topVC.view.layer.needsDisplayOnBoundsChange = NO;

    CGRect bounds = self.frame;
//#if FAKE_EXTERNAL_DISPLAY
//    CGFloat width = 350;
//    bounds.size.width = 350;
//    bounds.origin.x = self.bounds.size.width/2 - width/2;
//#else
    bounds.origin.y = 0;
//#endif
    bounds.size.height = self.frame.size.height - splitTablePaneHeight;
    self.topViewController.view.frame =  CGRectIntegral(CGRectInset(bounds, -1, -1));
    self.topContainerView.frame = CGRectIntegral(bounds);
    self.topContainerView.autoresizesSubviews = NO;
#if !FAKE_EXTERNAL_DISPLAY
    CGPathRef shapePath = CGPathCreateWithRect(CGRectMake(0, 0, self.frame.size.width, [self contentOffsetForBottomView]), NULL);
    self.shapeLayerMask.path = shapePath;
#if DEBUG_CF_MEMORY
    CFBridgingRelease(shapePath);
#endif
#endif

    //self.topContainerView.layer.needsDisplayOnBoundsChange = NO;
//    topVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    topVC.view.translatesAutoresizingMaskIntoConstraints = NO;
//topVC.view.layer.mask = self.shapeLayerMask;
    self.topContainerView.layer.allowsEdgeAntialiasing = YES;
    self.topContainerView.layer.edgeAntialiasingMask = kCALayerTopEdge | kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge;
#if !FAKE_EXTERNAL_DISPLAY
    self.topContainerView.layer.mask = self.shapeLayerMask;
#endif
    [self.topContainerView addSubview:topVC.view];
}

- (void)setupLoadingState {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self.indicatorView.superview) {
            [self.indicatorView removeFromSuperview];
            self.indicatorView = nil;
        }
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.indicatorView.opaque = YES;
        self.indicatorView.alpha = 0.0;
        self.indicatorView.backgroundColor = [UIColor whiteColor];
        self.indicatorView.color = [GVTintColorUtility utilityPurpleColor];
        [self.masterViewController.view addSubview:self.indicatorView];
        [self.masterViewController.view addSubview:self.loadingLabel];
        [self.loadingLabel sizeToFit];
        [self.loadingLabel setNeedsDisplay];
        self.loadingLabel.backgroundColor = [UIColor whiteColor];
        self.indicatorView.alpha = 0.0;
        //self.bottomContainerView.layer.zPosition = 10000;
        //self.indicatorView.layer.zPosition = 10000;
        //[self.bottomContainerView bringSubviewToFront:self.indicatorView];
        //[self.bottomContainerView bringSubviewToFront:self.loadingLabel];
        [self applyCurrentPercentageOffsetToTopViewWithoutDispatch];
        
        
        
        [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionCurveLinear animations:^{
            @strongify(self);
            self.indicatorView.alpha = 1.0;
            self.loadingLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self.indicatorView startAnimating];
        }];

        self.loading = YES;
    });
}

- (void)setupEmptyLabel {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (!self.emptyLabel.superview) {

            [self.masterViewController.view addSubview:self.emptyLabel];
            

        }
        
        [self.emptyLabel sizeToFit];
        [self.emptyLabel setNeedsDisplay];
        
        self.emptyLabel.alpha = 0;
        
        [self applyCurrentPercentageOffsetToTopViewWithoutDispatch];
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            @strongify(self);
            self.emptyLabel.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                
            }
        }];
    });
}

- (void)endEmptyLabel {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self.emptyLabel.superview) {
            
            self.emptyLabel.alpha = 1;
            
            [self endLoadingState];
            
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                @strongify(self);
                self.emptyLabel.alpha = 0;
            } completion:^(BOOL finished) {
                if (finished) {
                    @strongify(self);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @strongify(self);
                        [self.emptyLabel removeFromSuperview];
                    });
                }
            }];
          
        }
    });
}

- (void)setupLoadingThumbnailState {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self endEmptyLabel];
    
        if (self.loadingThumbnailLabel.superview) {
            [self.loadingThumbnailLabel removeFromSuperview];
            //self.loadingThumbnailLabel = nil;
        }
        
        if (self.loadingLabel.superview) {
            [self.loadingLabel removeFromSuperview];
        }
            
        self.loading = YES;
        
        BOOL animateIndicator = NO;
        
        if (!self.indicatorView.superview) {
            animateIndicator = YES;
            [self.masterViewController.view addSubview:self.indicatorView];
        }
        [self.masterViewController.view addSubview:self.loadingThumbnailLabel];
        self.loadingThumbnailLabel.opaque = YES;
        [self.loadingThumbnailLabel sizeToFit];
        [self.loadingThumbnailLabel setNeedsDisplay];
        

        
        self.loadingThumbnailLabel.alpha = 0.0;
        
        [self applyCurrentPercentageOffsetToTopViewWithoutDispatch];
        
        if (self.indicatorView.alpha == 0 || animateIndicator) {
            animateIndicator = YES;
        }
        
        if (animateIndicator) {
            self.indicatorView.alpha = 0;
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            if (animateIndicator) {
                self.indicatorView.alpha = 1;
            }
            self.loadingThumbnailLabel.alpha = 1.0;
        }];
    });
}

- (void)endLoadingThumbnailState {
//    if (self.loading && self.loadingThumbnailLabel) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            
            [UIView animateWithDuration:0.25 animations:^{
                @strongify(self);
                self.indicatorView.alpha = 0.0;
                self.loadingLabel.alpha = 0.0;
                self.loadingThumbnailLabel.alpha = 0.0;
                
            } completion:^(BOOL finished) {
                if (finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loadingThumbnailLabel removeFromSuperview];
                        [self.indicatorView removeFromSuperview];
                        [self.loadingLabel removeFromSuperview];
                        //self.loadingThumbnailLabel = nil;
                        //self.loadingLabel = nil;
                        self.indicatorView = nil;
                    });
                }
            }];
        });
//    }
}

- (void)endLoadingState {
   // if (self.loading && self.indicatorView) {
    self.loading = NO;
    [self endLoadingThumbnailState];
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                @strongify(self);
                self.indicatorView.alpha = 0.0;
                self.loadingLabel.alpha = 0.0;
                self.loadingThumbnailLabel.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                        [self.loadingThumbnailLabel removeFromSuperview];
                        [self.indicatorView removeFromSuperview];
                        [self.loadingLabel removeFromSuperview];
                        self.indicatorView = nil;
                        self.loading = NO;
                    });
                }
            }];
        });
    //}
}

- (void)setupBottomViewController:(UIViewController*)bottomVC {
    self.bottomViewController = bottomVC;
    //[self.fastView setupContentView:self.bottomViewController.view];
    //bottomVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //bottomVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    //bottomVC.view.layer.shouldRasterize = YES;
    //bottomVC.view.layer.needsDisplayOnBoundsChange = NO;
    //bottomVC.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    //[self.scrollView addSubview:self.fastView];
    //[self addSubview:self.bottomViewController.view];
    self.bottomContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomContainerView.layer.needsDisplayOnBoundsChange = NO;
    self.bottomContainerView.opaque = YES;
    self.bottomContainerView.layer.allowsGroupOpacity = YES;
    self.bottomContainerView.layer.allowsEdgeAntialiasing = YES;
    self.bottomContainerView.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;
    self.bottomContainerView.backgroundColor = [UIColor whiteColor];
    self.bottomContainerView.autoresizesSubviews = NO;
    //self.bottomContainerView.layer.shouldRasterize = YES;
    //self.bottomContainerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.bottomContainerView.clearsContextBeforeDrawing = NO;
    [self.scrollView addSubview:self.bottomContainerView];

    bottomVC.view.layer.allowsEdgeAntialiasing = YES;
    bottomVC.view.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;
    bottomVC.view.layer.allowsGroupOpacity = YES;

    [self.bottomContainerView addSubview:bottomVC.view];

    [self setupLoadingState];

    self.navigationToolbar = [[GVNavigationToolbar alloc] initWithFrame:CGRectZero];
    self.navigationToolbar.layer.shouldRasterize = YES;
    self.navigationToolbar.autoresizesSubviews = NO;
    self.navigationToolbar.layer.allowsGroupOpacity = YES;
    self.navigationToolbar.layer.allowsEdgeAntialiasing = YES;
    self.navigationToolbar.layer.edgeAntialiasingMask = kCALayerTopEdge | kCALayerRightEdge | kCALayerLeftEdge | kCALayerBottomEdge;
    self.navigationToolbar.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.navigationToolbar.layer.needsDisplayOnBoundsChange = NO;
    [self.bottomContainerView addSubview:self.navigationToolbar];
   
}
//
//- (void)setupSplitViewController:(UIViewController *)splitVC {
//    self.splitViewController = splitVC;
//    splitVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    splitVC.view.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addSubview:splitVC.view];
//}

- (CGRect)layoutOrientationBounds {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGRect bounds = self.bounds;
    bounds.origin.y = 0;
    bounds.origin.x = 0;


    switch (orientation) {
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortrait: {
            //self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(0));
            //self.previewLayer.frame = CGRectMake(self.layer.frame.origin.y, self.layer.frame.origin.x, self.layer.frame.size.height, self.layer.frame.size.width);
            bounds.size.width = self.frame.size.width;
            bounds.size.height = self.frame.size.height - splitTableNavHeight - splitTablePaneHeight;
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            //self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(180));
            //self.previewLayer.frame = CGRectMake(self.layer.frame.origin.y, self.layer.frame.origin.x, self.layer.frame.size.height, self.layer.frame.size.width);
            bounds.size.width = self.frame.size.width;
            bounds.size.height = self.frame.size.height - splitTableNavHeight - splitTablePaneHeight;
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            //self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(-90));
            //self.previewLayer.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.width, self.layer.frame.size.height);
            bounds.size.width = self.frame.size.height;
            bounds.size.height = self.frame.size.width - splitTableNavHeight - splitTablePaneHeight;

            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            //self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
            //self.previewLayer.frame = CGRectMake(self.layer.frame.origin.x, self.layer.frame.origin.y, self.layer.frame.size.width, self.layer.frame.size.height);
            bounds.size.width = self.frame.size.height;
            bounds.size.height = self.frame.size.width - splitTableNavHeight - splitTablePaneHeight;
            break;
        }
        case UIDeviceOrientationFaceUp:

            break;
        case UIDeviceOrientationFaceDown:

            break;
        default:
            break;
    }
    return bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topContainerView.layer.allowsEdgeAntialiasing = YES;
    self.topContainerView.layer.edgeAntialiasingMask = kCALayerTopEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerLeftEdge;

//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//
//
//
//        self.topViewController.view.frame = self.bounds;//[self layoutOrientationBounds];
//    } else {
//        CGRect bounds = self.frame;
//        bounds.origin.y = 0;
//        bounds.size.height = self.frame.size.height - splitTablePaneHeight;
//        self.topViewController.view.frame = bounds;
//        //self.splitTableViewController.view.frame = self.view.frame;
//
//    }

    
    CGRect bounds = self.frame;
    CGFloat scrollHeight = 900;
#if FAKE_EXTERNAL_DISPLAY
    bounds.size.width = 800;
    bounds.origin.x = self.bounds.size.width/2 - bounds.size.width/2;
    bounds.origin.y = 25;
    bounds.size.height = 800;
#else
    bounds.origin.y = 0;
    bounds.size.height = self.frame.size.height - splitTablePaneHeight;
#endif
 
    
#if FAKE_EXTERNAL_DISPLAY
    self.bgView.frame = self.bounds;
    
    
    
    [self.scrollView setContentSize:CGSizeMake(self.frame.size.width, (self.frame.size.height*2) -[GVModalCameraContainerView heightOfNavHeader]  - splitTablePaneHeight )];
    //if (self.bottomViewController.view.layer.needsLayout) {
    self.bottomContainerView.frame = CGRectMake(self.bounds.size.width/2 - bounds.size.width/2, bounds.size.height + bounds.origin.y, bounds.size.width, scrollHeight);
    self.bottomViewController.view.frame = self.bottomContainerView.bounds;
    //}
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    
#endif
    
    
    self.topViewController.view.frame = bounds;

    self.topContainerView.frame = CGRectMake(0, 0, self.frame.size.width, [self heightOfTopView]);
    //[self bringSubviewToFront:self.bottomViewController.view];
    //self.scrollView.frame = self.frame;
    //self.scrollView.bounds = self.bounds;
    //[self.scrollView setNeedsLayout];
    //[self.scrollView layoutIfNeeded];


 
    //[self bringSubviewToFront:self.scrollView];
    
    self.topViewController.view.layer.zPosition = -1000000;
    self.bgView.layer.zPosition = -100000000;
    self.contentsContainer.layer.zPosition = -10000;

    //self.shapeLayerMask.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0);


    self.shapeLayerMask.frame = self.topContainerView.frame;



    self.navigationToolbar.frame = CGRectMake(0, self.bottomContainerView.bounds.size.height - navToolbarHeight, self.bottomContainerView.bounds.size.width, navToolbarHeight);

    //self.topViewController.view.frame = self.bounds;
    //self.splitViewController.view.frame = self.bounds;
//    if (self.showFullscreen) {
//        CGRect bounds = self.frame;
//        bounds.origin.y = self.topViewController.view.frame.size.height;
//        self.bottomViewController.view.frame = bounds;
//    } else {
//        self.bottomViewController.view.frame = self.frame;
//    }

    //[self.bottomViewController.view setNeedsLayout];
    //[self.bottomViewController.view layoutIfNeeded];
    //[self.scrollView setNeedsLayout];
    //[self.scrollView layoutIfNeeded];
}



- (void)scrollBottomViewFullScreen:(BOOL)animated {
    [self.scrollView setContentOffset:CGPointMake(0, [self contentOffsetForBottomView]) animated:animated];
}

- (void)scrollToBottomView:(BOOL)animated {
    [self.scrollView setContentOffset:CGPointZero animated:animated];
}

- (void)swapToSnapshot {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        if (!self.snapshotView) {
//            CGRect snapFrame = self.bottomViewController.view.frame;
//
//            self.snapshotView = [self.bottomViewController.view snapshotViewAfterScreenUpdates:NO];
//            [self.scrollView addSubview:self.snapshotView];
//            self.snapshotView.frame = snapFrame;
//            [self.bottomViewController.view removeFromSuperview];
//        }
//    });
}

- (void)swapToRegularBottomView {
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//        if (self.snapshotView) {
//            CGRect snapFrame = self.snapshotView.frame;
//            [self.scrollView addSubview:self.bottomViewController.view];
//            [self.snapshotView removeFromSuperview];
//            self.bottomViewController.view.frame = snapFrame;
//            self.snapshotView = nil;
//        }
//    });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self swapToSnapshot];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self swapToRegularBottomView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self swapToRegularBottomView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self swapToRegularBottomView];
}

static const float m34multiplier = -1000;

#define STAYS_BACK_FLAT 1

- (CATransform3D)backAnimationTransformForPercent:(CGFloat)percent {
#if STAYS_BACK_FLAT
    if (percent > .5) {
        // first half of animation...
        CGFloat halfedDuration = percent - .5;
        CGFloat halfedPercent = halfedDuration / .5;

        CGFloat initialValueScale = 1;
        CGFloat finalValueScale = .9;
        CGFloat currentValueScale = ((initialValueScale - finalValueScale) * halfedPercent) + finalValueScale;


        CGFloat initialRotationAngle = 0.0f;
        CGFloat finalRotationAngle = 15.0f;

        CGFloat currentRotationAngle = (finalRotationAngle * (1-halfedPercent));

        CATransform3D t1 = CATransform3DIdentity;
        t1.m34 = 1.0 / m34multiplier;
        t1 = CATransform3DScale(t1, currentValueScale, currentValueScale, 1);
        t1 = CATransform3DRotate(t1, currentRotationAngle * M_PI/180.0f, 1, 0, 0);
        return t1;
    } else if (percent > 0) {
        // second half of animation
        // by how much...

        CGFloat halfedPercent = percent / .5;

        CGFloat initialValueScale = .9;
        CGFloat finalValueScale = .85;
        CGFloat currentValueScale = ((initialValueScale - finalValueScale) * halfedPercent) + finalValueScale;


        //CGFloat initialValueTranslate = 0.0;
        CGFloat finalValueTranslate = 20.0;
        CGFloat currentValueTranslate = (finalValueTranslate * (1-halfedPercent));

        CGFloat initialValueRotation = 15.0f;
        //CGFloat finalValueRotation = 0.0f;
        CGFloat currentRotationAngle = halfedPercent * initialValueRotation;

        CATransform3D t2 = CATransform3DIdentity;
        t2.m34 = 1.0 / m34multiplier;
        t2 = CATransform3DTranslate(t2, 0.0, -(currentValueTranslate), 0.0);
        t2 = CATransform3DScale(t2, currentValueScale, currentValueScale, 1);
        t2 = CATransform3DRotate(t2, currentRotationAngle * M_PI/180.0f, 1, 0, 0);
        return t2;
    }
#else 
    if (percent > 0 && percent < 1) {
        CGFloat initialValueScale = 1;
        CGFloat finalValueScale = .75;
        CGFloat currentValueScale = ((initialValueScale - finalValueScale) * percent) + finalValueScale;


        CGFloat finalValueTranslate = 65.0;
        CGFloat currentValueTranslate = (finalValueTranslate * (1-percent));

        CGFloat initialValueRotation = 0.0f;
        CGFloat finalValueRotation = -60.0f;

        CGFloat currentRotationAngle = ((1-percent) * (finalValueRotation + initialValueRotation)) + initialValueRotation;


        CATransform3D t2 = CATransform3DIdentity;
        t2.m34 = 1.0 / m34multiplier;
        t2 = CATransform3DTranslate(t2, 0.0, -(currentValueTranslate), 0.0);
        t2 = CATransform3DScale(t2, currentValueScale, currentValueScale, 1);
        t2 = CATransform3DRotate(t2, currentRotationAngle * M_PI/180.0f, 1, 0, 0);
        return t2;
    }
#endif
    return CATransform3DIdentity;
}

- (CGFloat)opacityTransformationValueForPercent:(CGFloat)percent {
    CGFloat initialValue = 1.0;
    CGFloat finalValue = 0.7;
    return finalValue + ((initialValue - finalValue)*percent);
}

+ (CGFloat)heightOfNavHeader {
    return splitTableNavHeight;
}

- (CGFloat)heightOfTopView {
    CGFloat viewContentOffset = [self contentOffsetForBottomView];
    CGFloat newHeight = viewContentOffset - self.scrollView.contentOffset.y;
    //DLogCGPoint(contentOffset);
    if (newHeight < 0) {
        //NSLog(@"it's 0 jim");
        newHeight = 0;
    }
    return newHeight;
}

- (CGFloat)contentOffsetForBottomView {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return ([self layoutOrientationBounds].size.height - splitTablePaneHeight);
    } else {
        return (self.frame.size.height - splitTablePaneHeight);
    }
}

- (void)applyCurrentPercentageOffsetToTopViewWithoutDispatch {
    CGFloat viewContentOffset = [self contentOffsetForBottomView];
    CGFloat newHeight = [self heightOfTopView];
    CGFloat percent = newHeight / viewContentOffset;
    CGFloat newAlpha = [self opacityTransformationValueForPercent:percent];
    self.topViewController.view.alpha = newAlpha;
    
    CATransform3D newTransform = [self backAnimationTransformForPercent:percent];
    self.topViewController.view.layer.transform = newTransform;
    self.topControllerTransform = newTransform;
    
    //[CATransaction commit];
    
    //self.shapeLayerMask.transform = CATransform3DScale(CATransform3DIdentity, 1, (1-percent), 1);
    //[self.shapeLayerMask needsDisplay];
    
    CGFloat newOffset = viewContentOffset - newHeight;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.0];
    [CATransaction setDisableActions:YES];
    
    //self.topContainerView.layer.allowsEdgeAntialiasing = YES;
    // self.topContainerView.layer.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;
    
    //self.shapeLayerMask.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -(newOffset), 0);
    
    CGFloat indicPadding = 15;
    
    //[CATransaction commit];
    //CGRect loadingRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    //self.indicatorView.center = CGPointMake(CGRectGetMidX(loadingRect), CGRectGetMidY(loadingRect));
    self.indicatorView.frame = CGRectIntegral(CGRectMake(0, indicPadding, self.frame.size.width, self.frame.size.height - newHeight));
    
    CGPoint indicatorCenter = self.indicatorView.center;
    
    self.loadingLabel.center = CGPointMake(indicatorCenter.x + 3, indicatorCenter.y + 25 );
    self.loadingThumbnailLabel.center = self.loadingLabel.center;
    
    CGFloat emptyPadding = 10;
    
    self.emptyLabel.frame = CGRectIntegral(CGRectMake(0, indicPadding + emptyPadding, self.frame.size.width, self.frame.size.height - newHeight));
    
    [CATransaction commit];

}

- (void)applyCurrentPercentageOffsetToTopView {

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        //[CATransaction begin];
        //[CATransaction setAnimationDuration:0.25];
        
        [self applyCurrentPercentageOffsetToTopViewWithoutDispatch];
 
    //self.topContainerView.frame = CGRectMake(0, 0, self.bounds.size.width, newHeight);
    //CAShapeLayer *shapeLayer = self.topContainerView.layer.mask;
    //shapeLayer.path = CGPathCreateWithRect(CGRectMake(0, 0, self.frame.size.width, newHeight), NULL);
    //self.shapeLayerMask.path = CGPathCreateWithRect(CGRectMake(0, 0, self.frame.size.width, newHeight+5), NULL);
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self applyCurrentPercentageOffsetToTopView];

    @weakify(self);
    if (scrollView.contentOffset.y < 60) {
        if (!self.showFullscreen) {
            //self.showFullscreen = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);

                //self.view.layoutCameraFullscreen = YES;
                if ([self.delegate respondsToSelector:@selector(goToFullscreen)]) {
                    [self.delegate performSelector:@selector(goToFullscreen)];
                }
            });

        } else {

        }
    } else {
        if (self.showFullscreen) {
            //self.showFullscreen = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);

                if ([self.delegate respondsToSelector:@selector(endFullscreen)]) {
                    [self.delegate performSelector:@selector(endFullscreen)];
                }
            });
        } else {
        }
    }

    return;
//    @weakify(self);
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
//    CGFloat viewContentOffset = [self contentOffsetForBottomView];
//    CGFloat newHeight = viewContentOffset - scrollView.contentOffset.y;
//    //DLogCGPoint(contentOffset);
//    if (newHeight < 0) {
//        //NSLog(@"it's 0 jim");
//        newHeight = 0;
//    }
//
//    CGFloat percent = newHeight / viewContentOffset;
//    CGFloat newAlpha = [self opacityTransformationValueForPercent:percent];
//    self.topViewController.view.alpha = newAlpha;
//
//    CATransform3D newTransform = [self backAnimationTransformForPercent:percent];
//    self.topViewController.view.layer.transform = newTransform;
//
//    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//    //   self.topContainerView.frame = CGRectMake(0, 0, self.frame.size.width, newHeight);
//    // });
//
////    if (scrollView.contentOffset.y < self.frame.size.height - splitTablePaneHeight) {
////
////    } else {
////        // we've scrolled all the way, so this isn't going to work anymore
////        self.workingContentOffset = [scrollView.panGestureRecognizer locationInView:scrollView];
//////
////    }
//
//
//    if (scrollView.contentOffset.y < 60) {
//        if (!self.showFullscreen) {
//            //self.showFullscreen = YES;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @strongify(self);
//
//                //self.view.layoutCameraFullscreen = YES;
//                if ([self.delegate respondsToSelector:@selector(goToFullscreen)]) {
//                    [self.delegate performSelector:@selector(goToFullscreen)];
//                }
//            });
//
//        } else {
//
//        }
//    } else {
//        if (self.showFullscreen) {
//            //self.showFullscreen = NO;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                @strongify(self);
//
//                if ([self.delegate respondsToSelector:@selector(endFullscreen)]) {
//                    [self.delegate performSelector:@selector(endFullscreen)];
//                }
//            });
//        } else {
//        }
//    }
//    });
////    if ([self.delegate respondsToSelector:@selector(tellContentOffset:)]) {
////        [self.delegate tellContentOffset:self.scrollView.contentOffset];
////    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.cameraTapGestureRecognizer ||
        gestureRecognizer == self.flipTapGestureRecognizer ||
        gestureRecognizer == self.libraryTapGestureRecognizer ||
        gestureRecognizer == self.flashTapGestureRecognizer) {
        return NO;
    }

    return YES;
}

- (BOOL)tapInBottomView:(CGPoint)locationInView selector:(SEL)selector fromView:(UIView*)fromView handleTap:(BOOL)handleOp {
    CGPoint containerViewPoint = [self.bottomContainerView convertPoint:locationInView fromView:fromView];
    UIView *hitTest = [self.bottomContainerView hitTest:containerViewPoint withEvent:nil];
    //NSArray *bottomViewSubviews = self.bottomViewController.view.subviews;
    CGPoint hitPoint = [fromView convertPoint:locationInView toView:hitTest];
    //[self distributedRecursiveViewHitTest:self.bottomViewController.view point:hitPoint detectedView:];

    DLogSEL(selector);

    if (hitTest
        && [hitTest pointInside:hitPoint withEvent:nil]) {
        if ([hitTest respondsToSelector:selector]) {
            if (handleOp) {
                [hitTest performSelector:selector withObject:[NSValue valueWithCGPoint:hitPoint]];
            } else if (sel_isEqual(selector, @selector(handleTap:))) {
                if ([hitTest respondsToSelector:@selector(handleTouchDown:)]) {
                    [hitTest performSelector:@selector(handleTouchDown:) withObject:[NSValue valueWithCGPoint:hitPoint]];
                }
            }
            return YES;
        }
        return NO;
    } else {

        BOOL retValue = NO;

        NSArray *cells = [self.masterViewController.tableView visibleCells];
        for (NSUInteger i = 0;i < [cells count];i++) {
            UITableViewCell *cell = [cells objectAtIndex:i];
            CGPoint cPoint = [fromView convertPoint:locationInView toView:cell];
            if ([cell pointInside:cPoint withEvent:nil]) {
                //return NO; // OVERRIDING!!!!!!!
                UIView* hitCellView = [cell hitTest:cPoint withEvent:nil];
                //if ([hitCellView conformsToProtocol:@protocol(GVCustomClickableScrollViewObject)]) {
                if ([cell respondsToSelector:selector]) {
                    if (handleOp) {
                        [cell performSelector:selector withObject:[NSValue valueWithCGPoint:cPoint]];
                    } else if (sel_isEqual(selector, @selector(handleTap:))) {
                        if ([cell respondsToSelector:@selector(handleTouchDown:)]) {
                            [cell performSelector:@selector(handleTouchDown:) withObject:[NSValue valueWithCGPoint:cPoint]];
                        }
                    }
                    retValue = YES;
                    return retValue;

                }
                //}
            }

        }

        return retValue;
    }
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    CGPoint locationInView = [touch locationInView:touch.window];
    //CGPoint locationOnScreen = [gestureRecognizer.view.window convertPoint:locationInView fromView:gestureRecognizer.view];


    CGPoint locationInBottomView = [touch.window convertPoint:locationInView toView:self.bottomViewController.view];
    BOOL tapInBottomView = [self.bottomViewController.view pointInside:locationInBottomView withEvent:nil];
    if (gestureRecognizer == self.cameraTapGestureRecognizer) {
        CGPoint locationInTopView = [touch.window convertPoint:locationInView toView:self.topViewController.view];
        //BOOL pointInsideTopView = [self.topViewController.view pointInside:locationInTopView withEvent:nil];
        BOOL pointInsideToolbar = (locationInTopView.y > self.topContainerView.frame.size.height - GVModalCameraViewToolbarHeight);
        BOOL pointInsideNavBar = (locationInTopView.y < GVModalCameraViewProgressBarHeight);
        if (!pointInsideToolbar && !tapInBottomView) { // && !pointInsideNavBar) {
            return YES;
        }
        return NO;
    }
    if (gestureRecognizer == self.flipTapGestureRecognizer) {
        CGPoint locationInTopView = [touch.window convertPoint:locationInView toView:self.topViewController.flipButtonView];
        if ([self.topViewController.flipButtonView pointInside:locationInTopView withEvent:nil] && !tapInBottomView) {
            if (self.topViewController.flipButtonView.alpha > 0.5) {
                self.topViewController.flipButtonView.tintColor = [UIColor whiteColor];
            }
                //[self.topViewController.flipButtonView tintColorDidChange];
            //[self.topViewController.flipButtonView setNeedsDisplay];
            return YES;
        }
        return NO;
    }
    if (gestureRecognizer == self.libraryTapGestureRecognizer) {
        CGPoint locationInTopView = [touch.window convertPoint:locationInView toView:self.topViewController.libraryButtonView];
        if ([self.topViewController.libraryButtonView pointInside:locationInTopView withEvent:nil] && !tapInBottomView) {
            if (self.topViewController.libraryButtonView.alpha > 0.5) {
                self.topViewController.libraryButtonView.tintColor = [UIColor whiteColor];
            }
            return YES;
                
        }
        return NO;
    }
    if (gestureRecognizer == self.flashTapGestureRecognizer) {
        CGPoint locationInTopView = [touch.window convertPoint:locationInView toView:self.topViewController.flashButtonView];
        if ([self.topViewController.flashButtonView pointInside:locationInTopView withEvent:nil] && !tapInBottomView) {
            if (self.topViewController.flashButtonView.alpha > 0.5) {
                self.topViewController.flashButtonView.tintColor = [UIColor whiteColor];
            }
            return YES;
        }
        return NO;
    }
//    if (gestureRecognizer == self.slidePanGestureRecognizer) {
//        if (tapInBottomView) {
//            return YES;
//        }
//    }
    if (gestureRecognizer == self.bottomTapGestureRecognizer) {
        if (tapInBottomView) {
            return [self tapInBottomView:locationInView selector:@selector(handleTap:) fromView:gestureRecognizer.view handleTap:NO];
        }
        return NO;
    }
    if (gestureRecognizer == self.bottomLongPressGestureRecognizer) {
        if (tapInBottomView) {
            return [self tapInBottomView:locationInView selector:@selector(handleLongPress:) fromView:gestureRecognizer.view handleTap:NO];
        }
        return NO;
    }
    return YES;
}
//
//- (void)distributedRecursiveViewHitTest:(UIView*)hitTestView point:(CGPoint)point {
//    CGPoint hitPoint = [touch.window convertPoint:locationInView toView:self.bottomViewController.view];
//    UIView *hitTest = [self distributedRecursiveViewHitTest:self.bottomViewController.view point:hitPoint];
//
//    if (!hitTest) {
//        NSMutableDictionary *dict = self.masterViewController.visibleSectionHeaderViews;
//        for (NSIndexPath *key in dict) {
//            UITableViewHeaderFooterView *sectionView = [dict objectForKey:key];
//            if ([sectionView isKindOfClass:[UITableViewHeaderFooterView class]]) {
//                CGPoint cPoint = [touch.window convertPoint:locationInView toView:sectionView];
//                //CGFloat sectionOrigin = sectionView.frame.origin.y;
//                if ([sectionView pointInside:cPoint withEvent:nil]) {
//                    if ([sectionView conformsToProtocol:@protocol(GVCustomClickableScrollViewObject)]) {
//                        UIView <GVCustomClickableScrollViewObject> *obj = (UIView <GVCustomClickableScrollViewObject>*)hitTest;
//                        if ([sectionView respondsToSelector:@selector(handleTap:)]) {
//
//                            return;
//}

//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (gestureRecognizer == self.cameraTapGestureRecognizer && otherGestureRecognizer == self.scrollView.panGestureRecognizer) {
//        return YES;
//    }
//    return NO;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (gestureRecognizer == self.scrollView.panGestureRecognizer && otherGestureRecognizer == self.cameraTapGestureRecognizer) {
//        return YES;
//    }
//    return NO;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
