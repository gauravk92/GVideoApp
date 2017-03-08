//
//  GVMainScrollViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 8/15/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVMainScrollViewController.h"
#import "GVFullCameraViewController.h"
#import "GVMainContentViewController.h"

@interface GVMainScrollViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) GVFullCameraViewController *cameraViewController;
@property (nonatomic, strong) GVMainContentViewController *contentViewController;

@end

@implementation GVMainScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];


    
    self.cameraViewController = [[GVFullCameraViewController alloc] initWithNibName:nil bundle:nil];

    [self.scrollView addSubview:self.cameraViewController.view];
    
    [self addChildViewController:self.cameraViewController];
    [self.cameraViewController didMoveToParentViewController:self];


    self.contentViewController = [[GVMainContentViewController alloc] initWithNibName:nil bundle:nil];

    [self.scrollView addSubview:self.contentViewController.view];
    
    [self addChildViewController:self.contentViewController];
    [self.contentViewController didMoveToParentViewController:self];

}


- (void)viewWillAppear:(BOOL)animated {
    
    CGRect frame = self.view.frame;
    
    self.scrollView.frame = frame;
    
    
    CGSize doubleSize = self.view.frame.size;
    doubleSize.width += doubleSize.width;
    self.scrollView.contentSize = doubleSize;
    
    self.cameraViewController.view.frame = self.view.frame;
    
    self.contentViewController.view.frame = CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height);
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
