//
//  GVFullCameraViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 8/15/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVFullCameraViewController.h"
#import "GVFrontCameraViewController.h"
#import "GVCameraViewController.h"

@interface GVFullCameraViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) GVCameraViewController *frontCameraViewController;
@property (nonatomic, strong) GVCameraViewController *backCameraViewController;

@property (nonatomic, strong) UIImageView *cameraTapButton;
@property (nonatomic, strong) UILongPressGestureRecognizer *cameraTapGestureRecognizer;

@property (nonatomic, strong) UIView *contentTapButton;
@property (nonatomic, strong) UILongPressGestureRecognizer *contentTapGestureRecognizer;

@property (nonatomic, strong) UIImageView *flashTapButton;
@property (nonatomic, strong) UILongPressGestureRecognizer *flashTapGestureRecognizer;

@property (nonatomic, strong) UIImageView *contactTapButton;
@property (nonatomic, strong) UILongPressGestureRecognizer *contactTapGestureRecognizer;

@property (nonatomic, strong) UIImageView *flipTapButton;
@property (nonatomic, strong) UILongPressGestureRecognizer *flipTapGestureRecognizer;

@end

@implementation GVFullCameraViewController

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
    
    self.frontCameraViewController = [[GVFrontCameraViewController alloc] initWithNibName:nil bundle:nil];
    self.frontCameraViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.frontCameraViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.frontCameraViewController.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.frontCameraViewController.view];
    
    [self addChildViewController:self.frontCameraViewController];
    [self.frontCameraViewController didMoveToParentViewController:self];
    
    self.cameraTapButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_button"]];
    self.cameraTapButton.userInteractionEnabled = YES;
    [self.view addSubview:self.cameraTapButton];
    
    self.cameraTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cameraTapGesture:)];
    self.cameraTapGestureRecognizer.minimumPressDuration = 0.01f;
    self.cameraTapGestureRecognizer.delegate = self;
    [self.cameraTapButton addGestureRecognizer:self.cameraTapGestureRecognizer];
    
    self.contentTapButton = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentTapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.contentTapButton.layer.borderWidth = 2.5;
    self.contentTapButton.userInteractionEnabled = YES;
    self.contentTapButton.layer.cornerRadius = 3.5;
    [self.view.layer addSublayer:self.contentTapButton.layer];
    
    self.contentTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapGesture:)];
    self.contentTapGestureRecognizer.minimumPressDuration = 0.01f;
    self.contentTapGestureRecognizer.delegate = self;
    [self.contentTapButton addGestureRecognizer:self.contentTapGestureRecognizer];
    
    self.flashTapButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flash-cancel"]];
    self.flashTapButton.userInteractionEnabled = YES;
    [self.view addSubview:self.flashTapButton];
    
    self.flashTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(flashTapGesture:)];
    self.flashTapGestureRecognizer.minimumPressDuration = 0.01;
    self.flashTapGestureRecognizer.delegate = self;
    [self.flashTapButton addGestureRecognizer:self.flashTapGestureRecognizer];
    
    self.contactTapButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add-user"]];
    self.contactTapButton.userInteractionEnabled = YES;
    [self.view addSubview:self.contactTapButton];
    
    self.contactTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(contactTapGesture:)];
    self.contactTapGestureRecognizer.minimumPressDuration = 0.01f;
    self.contactTapGestureRecognizer.delegate = self;
    [self.contactTapButton addGestureRecognizer:self.contactTapGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (void)contactTapGesture:(UILongPressGestureRecognizer*)gc {
    switch (gc.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            break;
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

- (void)flashTapGesture:(UILongPressGestureRecognizer*)gc {
    switch (gc.state) {
        case UIGestureRecognizerStatePossible:
            
            break;
        case UIGestureRecognizerStateBegan:
            self.flashTapButton.image = [UIImage imageNamed:@"flash"];
            break;
        case UIGestureRecognizerStateChanged:
            break;
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

- (void)cameraTapGesture:(UILongPressGestureRecognizer*)gc {
    switch (gc.state) {
        case UIGestureRecognizerStatePossible:
            
            break;
        case UIGestureRecognizerStateBegan:
            self.cameraTapButton.alpha = 0.5;
            break;
        case UIGestureRecognizerStateChanged:
            
            break;
        case UIGestureRecognizerStateEnded:
            self.cameraTapButton.alpha = 1.0;
            break;
        case UIGestureRecognizerStateCancelled:
            self.cameraTapButton.alpha = 1.0;
            break;
        case UIGestureRecognizerStateFailed:
            self.cameraTapButton.alpha = 1.0;
            break;
        default:
            break;
    }
}

- (void)contentTapGesture:(UILongPressGestureRecognizer*)gc {
    switch (gc.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan: {
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
            anim.toValue = [NSNumber numberWithFloat:5.0f];
            anim.removedOnCompletion = NO;
            
            [self.contentTapButton.layer addAnimation:anim forKey:nil];
            
            CABasicAnimation *size = [CABasicAnimation animationWithKeyPath:@"bounds"];
            size.duration = 0.2f;
            size.toValue = [NSValue valueWithCGRect:CGRectMake(10, self.view.frame.size.height - 14, 30, 30)];
            size.removedOnCompletion = NO;
            [self.contentTapButton.layer addAnimation:size forKey:nil];
            
            break;
        }
        case UIGestureRecognizerStateChanged:
            break;
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

- (void)viewWillLayoutSubviews {
    
    CGRect frame = self.view.frame;
    CGSize btnSize = self.cameraTapButton.image.size;
    CGFloat btnBottomPadding = 12;
    
    self.cameraTapButton.frame = CGRectIntegral(CGRectMake(frame.size.width/2 - btnSize.width/2, frame.size.height - btnSize.height - btnBottomPadding, btnSize.width, btnSize.height));
    
    CGFloat contentSize = 22.5;
    CGFloat contentBottomPadding = 4;
    
    self.contentTapButton.frame = CGRectIntegral(CGRectMake(btnBottomPadding + contentBottomPadding, frame.size.height - contentSize - btnBottomPadding - contentBottomPadding, contentSize, contentSize));
    
    CGFloat flashTopPadding = 14;
    self.flashTapButton.frame = CGRectIntegral(CGRectMake(flashTopPadding, flashTopPadding, self.flashTapButton.image.size.width, self.flashTapButton.image.size.height));
    
    CGFloat contactRightPadding = 12;
    
    self.contactTapButton.frame = CGRectIntegral(CGRectMake(frame.size.width - self.contactTapButton.image.size.width - contactRightPadding, frame.size.height - self.contactTapButton.image.size.height - btnBottomPadding, self.contactTapButton.image.size.width, self.contactTapButton.image.size.height));
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    self.frontCameraViewController.view.frame = self.view.frame;
    
    [self.frontCameraViewController startRunningCaptureSession];


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
