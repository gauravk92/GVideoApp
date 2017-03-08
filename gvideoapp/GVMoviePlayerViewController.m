//
//  GVMoviePlayerViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/15/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVMoviePlayerViewController.h"
#import "GVPlayPauseButton.h"
#import "GVTintColorUtility.h"

@interface GVMoviePlayerViewController ()

@property (nonatomic, strong) UIView *toolbarBackdrop;

@property (nonatomic, strong) CAShapeLayer *viewMask;
@property (nonatomic, strong) CAShapeLayer *viewMaskMask;

@property (nonatomic, strong) CAGradientLayer *toolbarMask;

@property (nonatomic, strong) UIImageView *cameraButton;

@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) UIColor *normalColor;

@property (nonatomic, strong) UIView *playPauseButton;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UILongPressGestureRecognizer *playPauseTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *cancelTapGestureRecognizer;

@end

@implementation GVMoviePlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.toolbarBackdrop = [[UIView alloc] initWithFrame:CGRectZero];
    self.toolbarBackdrop.backgroundColor = [GVTintColorUtility utilityToolbarColor];
    [self.view addSubview:self.toolbarBackdrop];
    
    self.normalColor = [GVTintColorUtility utilityBlueColor];
    self.highlightColor = [UIColor whiteColor];
    
    self.view.tintColor = self.normalColor;
    
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    maskLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor];
    maskLayer.shouldRasterize = YES;
    maskLayer.startPoint = CGPointMake(0.5, 0);
    maskLayer.endPoint = CGPointMake(0.5, 1);
    maskLayer.rasterizationScale = [UIScreen mainScreen].scale;
    self.toolbarMask = maskLayer;
    self.toolbarBackdrop.layer.mask = maskLayer;
    
    self.viewMask = [CAShapeLayer layer];
    self.viewMask.fillColor = [UIColor whiteColor].CGColor;
    self.viewMask.backgroundColor = [UIColor whiteColor].CGColor;
    self.view.layer.mask = self.viewMask;
    
    self.viewMaskMask = [CAShapeLayer layer];
    self.viewMaskMask.fillColor = [UIColor clearColor].CGColor;
    self.viewMaskMask.backgroundColor = [UIColor clearColor].CGColor;
    //self.viewMask.mask = self.viewMaskMask;
    
    self.playPauseButton = [[GVPlayPauseButton alloc] initWithFrame:CGRectZero];
    [self.toolbarBackdrop addSubview:self.playPauseButton];
    
    UIImage *camImage = [[UIImage imageNamed:@"glyphicons_207_remove_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cameraButton = [[UIImageView alloc] initWithImage:camImage];
    [self.toolbarBackdrop addSubview:self.cameraButton];
    
    UIImage *image = [[UIImage imageNamed:@"lineicons_play_full"]  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.playImageView = [[UIImageView alloc] initWithImage:image];
    [self.playPauseButton addSubview:self.playImageView];
    
    self.playPauseTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePlayPauseTap:)];
    self.playPauseTapGestureRecognizer.delegate = self;
    self.playPauseTapGestureRecognizer.minimumPressDuration = 0.01;
    self.playPauseTapGestureRecognizer.numberOfTapsRequired = 0;
    [self.playPauseButton addGestureRecognizer:self.playPauseTapGestureRecognizer];
    
    self.cancelTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTap:)];
    self.cancelTapGestureRecognizer.delegate = self;
    self.cancelTapGestureRecognizer.minimumPressDuration = 0.01;
    self.cancelTapGestureRecognizer.numberOfTapsRequired = 0;
    [self.toolbarBackdrop addGestureRecognizer:self.cancelTapGestureRecognizer];
}

- (void)handlePlayPauseTap:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        self.playPauseButton.layer.borderColor = self.normalColor.CGColor;
        self.playImageView.tintColor = self.normalColor;
        return;
    }
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
        if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
            [self.moviePlayer pause];
            self.playImageView.image = [[UIImage imageNamed:@"lineicons_play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            [self.moviePlayer play];
            self.playImageView.image = [[UIImage imageNamed:@"lineicons_play_full"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3];
        self.playImageView.tintColor = self.normalColor;
        self.playPauseButton.layer.borderColor = self.normalColor.CGColor;
    [CATransaction commit];
}

- (void)handleCancelTap:(UILongPressGestureRecognizer*)gc {
    CGPoint location = [gc locationInView:gc.view];
    if (location.x < self.view.frame.size.width*.3) {
        if (gc.state == UIGestureRecognizerStateBegan) {
            self.cameraButton.tintColor = self.highlightColor;
            return;
        }
        if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
        
            [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            
        }
        self.cameraButton.tintColor = self.normalColor;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat toolbarHeight = 120;
    
    CGFloat cameraPadding = 30;
    
    CGFloat buttonSize = 67;
    CGFloat buttonPadding = 20;
    
    self.toolbarBackdrop.frame = CGRectMake(0, self.view.frame.size.height - toolbarHeight, self.view.frame.size.width, toolbarHeight);
    
    self.toolbarMask.frame = self.toolbarBackdrop.bounds;
    
    self.playPauseButton.frame = CGRectIntegral(CGRectMake(self.view.frame.size.width/2 - buttonSize/2, self.toolbarBackdrop.frame.size.height - buttonPadding - buttonSize, buttonSize, buttonSize));
    
    self.playImageView.frame = CGRectIntegral(CGRectMake(self.playPauseButton.frame.size.width/2 - self.playImageView.image.size.width/2+2.5, self.playPauseButton.frame.size.height/2 - self.playImageView.image.size.height/2, self.playImageView.image.size.width, self.playImageView.image.size.height));
    //self.playImageView.center = self.playPauseButton.center;
    self.cameraButton.frame = CGRectIntegral(CGRectMake(cameraPadding, self.toolbarBackdrop.frame.size.height/2 - self.cameraButton.image.size.height/2 + 9, self.cameraButton.image.size.width, self.cameraButton.image.size.height));
    
    self.viewMaskMask.frame = CGRectMake(cameraPadding, self.view.frame.size.height - cameraPadding, 40, 40);
    
    self.viewMask.frame = self.view.bounds;
// 
//    [self.toolbarBackdrop setNeedsDisplay];
//    [self.playPauseButton setNeedsDisplay];
//    [self.cameraButton setNeedsDisplay];
//    [self.playImageView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
