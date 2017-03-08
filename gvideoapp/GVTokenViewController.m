//
//  GVTokenViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/26/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVTokenViewController.h"
#import "GVAppDelegate.h"

@interface GVTokenViewController ()

@end

@implementation GVTokenViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if ([self.tokenTextField canBecomeFirstResponder]) {
            [self.tokenTextField becomeFirstResponder];
        }
    });
    self.loginButton.backgroundColor = [UIColor colorWithRed:0.000 green:0.809 blue:0.251 alpha:1.000];

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInNotification:) name:GVLoggedInNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)loggedInNotification:(NSNotification*)notif {
//    [self dismissViewControllerAnimated:YES completion:nil];
//    //[self dismissViewControllerAnimated:YES completion:nil];
//    //[self dismissViewControllerAnimated:YES completion:nil];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButtonTouchDown:(id)sender {
    // button highlight state
    self.loginButton.backgroundColor = [UIColor colorWithRed:0.000 green:0.581 blue:0.308 alpha:1.000];
}

- (IBAction)loginButtonPress:(id)sender {
    // reset button color
    self.loginButton.backgroundColor = [UIColor colorWithRed:0.000 green:0.809 blue:0.251 alpha:1.000];

    [PFCloud callFunctionInBackground:@"verifyToken"
                       withParameters:@{@"email":self.emailAddress,
                                        @"token":self.tokenTextField.text}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        // result is @"Hello world!"
                                        NSLog(@"%@", result);
                                        [PFUser becomeInBackground:result block:^(PFUser *user, NSError *error) {
                                            if (!error) {
                                                [[NSNotificationCenter defaultCenter] postNotificationName:GVLoggedInNotification object:nil];
                                            }
                                        }];
                                    } else {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occured" message:@"Sorry there was an error..." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                        [alert show];
                                    }
                                }];
}

- (IBAction)cancelButtonPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
