//
//  GVSignupViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/26/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSignupViewController.h"
#import "GVTokenViewController.h"
#import <SHEmailValidator/SHEmailValidator.h>
#import "GVAppDelegate.h"

@interface GVSignupViewController ()

@end

@implementation GVSignupViewController

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInNotification:) name:GVLoggedInNotification object:nil];
}

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if ([self.emailTextField canBecomeFirstResponder]) {
            [self.emailTextField becomeFirstResponder];
        }
    });

}

- (void)loggedInNotification:(NSNotification*)notif {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)verifyButtonTouch:(id)sender {
    // button highlight state
    self.verifyButton.backgroundColor = [UIColor colorWithRed:0.200 green:0.209 blue:0.708 alpha:1.000];
}

- (IBAction)verifyButtonPress:(id)sender {
    // button reset regular color
    self.verifyButton.backgroundColor = [UIColor colorWithRed:0.200 green:0.365 blue:0.945 alpha:1.000];

    if ([self.emailTextField respondsToSelector:@selector(validateInput)]) {
        [self.emailTextField performSelector:@selector(validateInput)];
    }

    NSError *emailValidationError = nil;
    [[SHEmailValidator validator] validateSyntaxOfEmailAddress:self.emailTextField.text withError:&emailValidationError];

    if (emailValidationError) {
        // An error occurred
        switch (emailValidationError.code) {
            case SHBlankAddressError:
                // Input was empty
                break;
            case SHInvalidSyntaxError:
                // Syntax completely wrong (probably missing @ or .)
                break;
            case SHInvalidUsernameError:
                // Local portion of the email address is empty or contains invalid characters
                break;
            case SHInvalidDomainError:
                // Domain portion of the email address is empty or contains invalid characters
                break;
            case SHInvalidTLDError:
                // TLD portion of the email address is empty, contains invalid characters, or is under 2 characters long
                break;
        }
    } else {
        // Basic email syntax is correct

        GVTokenViewController *tokenVC = [[GVTokenViewController alloc] initWithNibName:nil bundle:nil];
        tokenVC.emailAddress = self.emailTextField.text;
        //UINavigationController *promptNav = [[UINavigationController alloc] initWithRootViewController:tokenVC];

        [self presentViewController:tokenVC animated:YES completion:nil];

//        PFUser *newUser = [PFUser user];
//        newUser.email = self.emailTextField.text;
//        newUser.username = self.emailTextField.text;
//        NSStringuid = [[NSUUID UUID] UUIDString];
//        newUser.password = uuid;
//
//        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                // signed up but haven't verified email...
//
//            } else {
//                // maybe logging in
//                // check the error code
//                if (error.code == kPFErrorUserEmailTaken) {
//                    
//                }
//            }
//        }];

        [PFCloud callFunctionInBackground:@"verifyEmail"
                           withParameters:@{@"email":self.emailTextField.text}
                                    block:^(NSString *result, NSError *error) {
                                        if (!error) {
                                            // result is @"Hello world!"
                                        } else {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occured" message:@"There was an error verifying your email address..." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                            [alert show];
                                        }
                                    }];


    }
}

@end
