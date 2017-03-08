//
//  GVThreadDetailNavigationController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/25/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVThreadDetailNavigationController.h"

@interface GVThreadDetailNavigationController ()

@end

@implementation GVThreadDetailNavigationController

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

//- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
//    //@weakify(self);
//    //dispatch_async(dispatch_get_main_queue(), ^{
//    //  @strongify(self);
//    //[[[self.splitController viewControllers][1] navigationItem] setLeftBarButtonItem:barButtonItem animated:YES];
//    [[self.viewControllers[0] navigationItem] setLeftBarButtonItem:barButtonItem animated:YES];
//    //});
//}
//
//- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
//    //@weakify(self);
//    //dispatch_async(dispatch_get_main_queue(), ^{
//    //    @strongify(self);
//    [[self.viewControllers[0] navigationItem] setLeftBarButtonItem:nil animated:YES];
//    //});
//}

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
