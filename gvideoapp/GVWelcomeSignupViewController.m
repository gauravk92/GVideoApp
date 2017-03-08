//
//  GVWelcomeSignupViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/1/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//


#import "GVWelcomeSignupViewController.h"
#import "GVLoginView.h"
#import "UIColor+Image.h"
#import "GVAppDelegate.h"
#import <Social/SLRequest.h>
#import "GVTwitterAuthUtility.h"
#import <MessageUI/MessageUI.h>
#import "GVWelcomeImageView.h"
#import "GVTutorialLabel.h"

#import "GVAccountsListViewController.h"
#import "GVTintColorUtility.h"
#import "MBProgressHUD.h"

@interface GVWelcomeSignupViewController () <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSString *accessTokenString;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) UIButton *twitterButton;
@property (nonatomic, strong) UIButton *twitterButton1;
@property (nonatomic, strong) NSBlockOperation *loginHandler;
@property (nonatomic, weak) UIImageView *bgView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIScrollView *pagesScrollView;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UIButton *emailButton;

@property (nonatomic, strong) UIButton *signupEmailButton;

@property (nonatomic, strong) UILabel *verifyTokenLabel;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) UILabel *verifyLinkLabel;

@property (nonatomic, strong) GVWelcomeImageView *welcomeImageView1;
@property (nonatomic, strong) GVTutorialLabel *welcomeTutorial11;
@property (nonatomic, strong) GVTutorialLabel *welcomeTutorial12;


@property (nonatomic, strong) GVWelcomeImageView *welcomeImageView2;
@property (nonatomic, strong) GVTutorialLabel *welcomeTutorial21;
@property (nonatomic, strong) GVTutorialLabel *welcomeTutorial22;

@property (nonatomic, strong) GVWelcomeImageView *welcomeImageView3;
@property (nonatomic, strong) GVTutorialLabel *welcomeTutorial31;
@property (nonatomic, strong) GVTutorialLabel *welcomeTutorial32;

@property (nonatomic, strong) GVWelcomeImageView *welcomeImageView4;
@property (nonatomic, strong) GVTutorialLabel *welcomeTutorial41;
@property (nonatomic, strong) GVTutorialLabel *welcomeTutorial42;

@end

@implementation GVWelcomeSignupViewController

- (BOOL)shouldAutorotate {
    return NO;
}

//- (void)loadView {
//    self.view = [[GVLoginView alloc] initWithFrame:CGRectZero];
//}

//- (NSString *)loadAccessToken {
//    return self.accessTokenString;
//}

//- (void)storeAccessToken:(NSString *)accessToken {
//    NSLog(@" accessToken: %@", accessToken);
//    NSString *username = [[FHSTwitterEngine sharedEngine] authenticatedUsername];
//    NSString *twitterID = [[FHSTwitterEngine sharedEngine] authenticatedID];
//    [PFCloud callFunctionInBackground:@"verifyTwitterAuth"
//                       withParameters:@{@"username": username,
//                                        @"twitterID": twitterID}
//                                block:^(NSString *result, NSError *error) {
//                                    if (!error) {
//                                        // result is @"Hello world!"
//                                        [PFUser becomeInBackground:result block:^(PFUser *user, NSError *error) {
//                                            if (!error) {
//                                                [[NSNotificationCenter defaultCenter] postNotificationName:GVLoggedInNotification object:nil];
//                                            } else {
//                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occured" message:@"Sorry there was an error..." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                                                [alert show];
//                                            }
//                                        }];
//                                    } else {
//                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occured" message:@"Sorry there was an error..." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                                        [alert show];
//                                    }
//                                }];
//
//    self.accessTokenString = accessToken;
//}


#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.operationQueue = [NSOperationQueue new];
    self.operationQueue.maxConcurrentOperationCount = 1;
    
    UIImage *logoImage = nil;
    UIImage *backgroundImage = nil;
    CGFloat buttonYMargin = 0;
    CGFloat swipeYMargin = 0;
    CGFloat deviceMultiplier = 0;
    UIImage *image0 = nil;
    UIImage *image1 = nil;
    UIImage *image2 = nil;
    UIImage *image3 = nil;
    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-landscape-ipad.png"]];
        //self.view.contentMode = UIViewContentModeCenter;
//        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-landscape-ipad"]];
//        bgView.contentMode = UIViewContentModeScaleAspectFill;
//        self.bgView = bgView;
//        [self.view addSubview:bgView];
        backgroundImage = [UIImage imageNamed:@"Default-landscape-ipad@2x.png"];
    } else {
        if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
            // for the iPhone 5
            backgroundImage = [UIImage imageNamed:@"SplashBackground~iphone@2x.png"];
            logoImage = [UIImage imageNamed:@"SplashLogo~iphone"];
            buttonYMargin = 352;
            swipeYMargin = 67;
            image0 = [UIImage imageNamed:@"tutorial0.png"];
            image1 = [UIImage imageNamed:@"tutorial1.png"];
            image2 = [UIImage imageNamed:@"tutorial2.png"];
            image3 = [UIImage imageNamed:@"tutorial3.png"];
            //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SplashBackground~iphone"]];
        } else {
            backgroundImage = [UIImage imageNamed:@"SplashBackground@2x.png"];
            logoImage = [UIImage imageNamed:@"SplashLogo.png"];
            buttonYMargin = 315;
            swipeYMargin = 38;
            image0 = [UIImage imageNamed:@"tutorial0-3.5.png"];
            image1 = [UIImage imageNamed:@"tutorial1-3.5.png"];
            image2 = [UIImage imageNamed:@"tutorial2-3.5.png"];
            image3 = [UIImage imageNamed:@"tutorial3-3.5.png"];
            deviceMultiplier = 1;
            //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SplashBackground"]];
        }
    }
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:backgroundImage];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bgView.translatesAutoresizingMaskIntoConstraints = NO;
    bgView.frame = self.view.bounds;
    bgView.contentMode = UIViewContentModeScaleAspectFill;
    bgView.layer.shouldRasterize = YES;
    bgView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    bgView.layer.contentsScale = [UIScreen mainScreen].scale;
    [self.view addSubview:bgView];
    
    self.pagesScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.pagesScrollView.pagingEnabled = YES;
    self.pagesScrollView.showsHorizontalScrollIndicator = NO;
    self.pagesScrollView.delegate = self;
    self.pagesScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 6, self.view.bounds.size.height);
    //self.pagesScrollView.showsHorizontalScrollIndicator = NO;
    //self.pagesScrollView.showsVerticalScrollIndicator = NO;
    //self.pagesScrollView.
    [self.view addSubview:self.pagesScrollView];
//    if (_accountStore == nil) {
//        self.accountStore = [[ACAccountStore alloc] init];
//        if (_accounts == nil) {
//            ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//            [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
//                if(granted) {
//                    self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
//                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        [self.tableView reloadData];
//                    });
//                }
//            }];
//        }
//    }
//
//
//    //  Assume that we stored the result of Step 1 into a var 'resultOfStep1'
//    NSString *S = resultOfStep1;
//    NSDictionary *step2Params = [[NSMutableDictionary alloc] init];
//    [step2Params setValue:@"JP3PyvG67rXRsnayOJOcQ"
//                   forKey:@"x_reverse_auth_target"];
//
//    [step2Params setValue:S forKey:@"x_reverse_auth_parameters"];
//
//    NSURL *url2 =
//    [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
//
//    SLRequest *stepTwoRequest =
//    [SLRequest requestForServiceType:SLServiceTypeTwitter
//                       requestMethod:SLRequestMethodPOST
//                                 URL:url2
//                          parameters:step2Params];
//
//    self.accountStore = [[ACAccountStore alloc] init];
//    ACAccountType *FBaccountType= [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
//    NSString *key = @"987654"; //put your own key from FB here
//    NSDictionary *dictFB = //use the ACAccountStore ACFacebookPermissionsKey to help create your dictionary of permsission you'd like to request, such as the users email, writing on the wall, etc.
//    [self.accountStore requestAccessToAccountsWithType:FBaccountType options:dictFB completion: ^(BOOL granted, NSError *e) {
//        if (granted) {
//            NSArray *accounts = [self.accountStore accountsWithAccountType:FBaccountType];
//            //it will always be the last object with SSO
//            self.facebookAccount = [accounts lastObject];
//        } else {
//            //Fail gracefully...
//            NSLog(@"error getting permission %@",e);
//        } 
//    }];
    
    CGRect contentImageRect = CGRectInset(self.pagesScrollView.bounds, 40, 40);
    contentImageRect.size.height = 250;
    
    
    GVWelcomeImageView *contentImage1 = [[GVWelcomeImageView alloc] initWithImage:image0];
    self.welcomeImageView1 = contentImage1;
    CGRect contentImageRect1 = contentImage1.frame;
    contentImageRect1.origin.x += self.pagesScrollView.frame.size.width;
    [contentImage1 setFrameAndShadowPath:contentImageRect1];
    [contentImage1 setFirstBubble:CGRectMake(0.5, 128, 80.25, 80.25) secondBubble:CGRectMake(26.5, self.pagesScrollView.frame.size.height - 50 , 52, 52)]; // 502
    [self.pagesScrollView addSubview:contentImage1];
    
    CGFloat titleHelperWidth1 = 250;
    CGRect contentTitleRect1 = CGRectMake(self.pagesScrollView.frame.size.width/2 - titleHelperWidth1/2 + 20, 225, titleHelperWidth1, 90);
    contentTitleRect1.origin.x += self.pagesScrollView.frame.size.width;
    GVTutorialLabel *contentTitle1 = [[GVTutorialLabel alloc] initWithFrame:CGRectIntegral(contentTitleRect1)];
    self.welcomeTutorial11 = contentTitle1;
    [contentTitle1 setText:@"Tap the camera button to the left of the thread to send to its recipients."];
    //[self.pagesScrollView addSubview:contentTitle1];
    
    CGFloat titleHelperWidth12 = 265;
    CGRect contentTitleRect11 = CGRectMake(self.pagesScrollView.frame.size.width/2 - titleHelperWidth12/2, self.pagesScrollView.frame.size.height - 93, titleHelperWidth12, 90);
    contentTitleRect11.origin.x += self.pagesScrollView.frame.size.width;
    GVTutorialLabel *contentTitle11 = [[GVTutorialLabel alloc] initWithFrame:CGRectIntegral(contentTitleRect11)];
    self.welcomeTutorial12 = contentTitle11;
    [contentTitle11 setText:@"Tap the camera button in the bottom toolbar to create a new thread."];
    //[self.pagesScrollView addSubview:contentTitle11];
    //  Tap the camera button in the bottom toolbar to create a new thread.
    //  Choose either front facing or back facing camera by clicking on the left icon of the screen.  Tap on the preview area to start recording.
    
    
    
    GVWelcomeImageView *contentImage2 = [[GVWelcomeImageView alloc] initWithImage:image1];
    self.welcomeImageView2 = contentImage2;
    CGRect contentImageRect2 = contentImage2.frame;
    self.welcomeImageView2.highOpacity = 0.8;
    contentImageRect2.origin.x += self.pagesScrollView.frame.size.width *2;
    [contentImage2 setFrameAndShadowPath:CGRectIntegral(contentImageRect2)];
    [contentImage2 setFirstBubbleRounding:NO secondBubbleRounding:YES];
    CGFloat contentImage2SidePadding = 20;
    [contentImage2 setFirstBubble:CGRectMake(contentImage2SidePadding, 175 + (deviceMultiplier*-45), self.welcomeImageView2.bounds.size.width - contentImage2SidePadding*2, 100) secondBubble:CGRectMake(20, self.pagesScrollView.frame.size.height - 232, 65, 65)]; //y1:175, y2:336
    [self.pagesScrollView addSubview:contentImage2];
    
    CGFloat titleHelperWidth2 = 203;
    CGRect contentTitleRect2 = CGRectMake(self.pagesScrollView.frame.size.width/2 - titleHelperWidth2/2 + 54, 267 + (deviceMultiplier*-60), titleHelperWidth2, 92);
    contentTitleRect2.origin.x += self.pagesScrollView.frame.size.width *2;
    GVTutorialLabel *contentTitle2 = [[GVTutorialLabel alloc] initWithFrame:CGRectIntegral(contentTitleRect2)];
    self.welcomeTutorial21 = contentTitle2;
    [contentTitle2 setText:@"Select the front or back camera by tapping the 'flip' icon on the left."];
    //[self.pagesScrollView addSubview:contentTitle1];
    
    CGFloat titleHelperWidth22 = 270;
    CGRect contentTitleRect22 = CGRectMake(self.pagesScrollView.frame.size.width/2 - titleHelperWidth22/2, self.pagesScrollView.frame.size.height - 118, titleHelperWidth22, 100); //450
    contentTitleRect22.origin.x += self.pagesScrollView.frame.size.width * 2;
    GVTutorialLabel *contentTitle22 = [[GVTutorialLabel alloc] initWithFrame:CGRectIntegral(contentTitleRect22)];
    self.welcomeTutorial22 = contentTitle22;
    [contentTitle22 setText:@"Tap anywhere in the preview area to start recording."];
    // When finished, tap on the screen again. You will be given a chance to review your video and edit your video. Then tap “Send” at the top right of the page and share it by your preferred sending outlet (i.e. Messages, Mail, Twitter).
    
    
    
    GVWelcomeImageView *contentImage3 = [[GVWelcomeImageView alloc] initWithImage:image2];
    self.welcomeImageView3 = contentImage3;
    CGRect contentImageRect3 = contentImage3.frame;
    contentImageRect3.origin.x += self.pagesScrollView.frame.size.width * 3;
    [contentImage3 setFrameAndShadowPath:CGRectIntegral(contentImageRect3)];
    CGFloat contentImage3Bubble1Width = 65;
    CGFloat contentImage3Bubble2Width = 65;
    [contentImage3 setFirstBubble:CGRectMake(self.pagesScrollView.frame.size.width - contentImage3Bubble1Width + 4, 11, contentImage3Bubble1Width, contentImage3Bubble1Width) secondBubble:CGRectMake(contentImage3.bounds.size.width/2 - contentImage3Bubble2Width/2 - 3, contentImage3.bounds.size.height - contentImage3Bubble2Width + 11, contentImage3Bubble2Width, contentImage3Bubble2Width)];
    [self.pagesScrollView addSubview:contentImage3];
    
    CGFloat titleHelperWidth3 = 203;
    CGRect contentTitleRect3 = CGRectMake(self.pagesScrollView.frame.size.width/2 - titleHelperWidth1/2 + 20, 125, titleHelperWidth1, 90);
    contentTitleRect3.origin.x += self.pagesScrollView.frame.size.width *3;
    GVTutorialLabel *contentTitle3 = [[GVTutorialLabel alloc] initWithFrame:CGRectIntegral(contentTitleRect3)];
    self.welcomeTutorial31 = contentTitle3;
    [contentTitle3 setText:@"After reviewing your message press the 'Send' button"];
    
    CGFloat titleHelperWidth32 = 270;
    CGRect contentTitleRect32 = CGRectMake(self.pagesScrollView.frame.size.width/2 - titleHelperWidth12/2, self.pagesScrollView.frame.size.height - 93, titleHelperWidth12, 90); //450
    contentTitleRect32.origin.x += self.pagesScrollView.frame.size.width * 3;
    GVTutorialLabel *contentTitle32 = [[GVTutorialLabel alloc] initWithFrame:CGRectIntegral(contentTitleRect32)];
    self.welcomeTutorial32 = contentTitle32;
    [contentTitle32 setText:@"Press play to preview your video message, drag the handles in the editing toolbar to trim."];
    //[self.pagesScrollView addSubview:contentTitle3];
    // New videos received will appear in the thumbnails section with a red circle and the users Twitter profile picture. Tap on the new thumbnail to watch and your reaction will be recorded. New reactions received will appear with a blue circle.
   
    
    
    GVWelcomeImageView *contentImage4 = [[GVWelcomeImageView alloc] initWithImage:image3];
    self.welcomeImageView4 = contentImage4;
    CGRect contentImageRect4 = contentImage4.frame;
    contentImageRect4.origin.x += self.pagesScrollView.frame.size.width * 4;
    [contentImage4 setFrameAndShadowPath:CGRectIntegral(contentImageRect4)];
    CGFloat contentImage4Width = 80.25;
    [contentImage4 addThirdRegion:CGRectMake(138, 77, 176, 49) fourthRegion:CGRectMake(27, 215, 265, 49)];
    [contentImage4 setFirstBubble:CGRectMake(self.pagesScrollView.frame.size.width - contentImage4Width + 6, 132.7, contentImage4Width, contentImage4Width) secondBubble:CGRectMake(0.5, 333, contentImage4Width, contentImage4Width)];
    [self.pagesScrollView addSubview:contentImage4];
    

    CGFloat titleHelperWidth4 = 222;
    CGRect contentTitleRect4 = CGRectMake(2, 127 + (deviceMultiplier*-7), titleHelperWidth4, 75); // y3.5in -> 120
    contentTitleRect4.origin.x += self.pagesScrollView.frame.size.width *4;
    GVTutorialLabel *contentTitle4 = [[GVTutorialLabel alloc] initWithFrame:CGRectIntegral(contentTitleRect4)];
    self.welcomeTutorial41 = contentTitle4;
    [contentTitle4 setText:@"Tap and hold a video thumbnail to save the video to the Camera Roll."];
    
    CGFloat titleHelperWidth42 = 290;
    CGRect contentTitleRect42 = CGRectMake(self.pagesScrollView.frame.size.width/2 - titleHelperWidth42/2, self.pagesScrollView.frame.size.height - 175 - 27 + (deviceMultiplier*77), titleHelperWidth42, 120); //450
    contentTitleRect42.origin.x += self.pagesScrollView.frame.size.width * 4;
    GVTutorialLabel *contentTitle42 = [[GVTutorialLabel alloc] initWithFrame:CGRectIntegral(contentTitleRect42)];
    self.welcomeTutorial42 = contentTitle42;
    [contentTitle42 setText:@"Tap and hold the camera button on the left of the thread to invite members via your preferred outlet (Messages, Mail, Twitter, etc.) or to leave the thread."];
    
    
    

    NSString *text = NSLocalizedString(@"SHARE A VIDEO. SEE THEIR REACTION!", @"SHARE A VIDEO. SEE THEIR REACTION!");

    CGSize textSize = [text boundingRectWithSize:CGSizeMake(255.0f, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin // wordwrap?
                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]}
                                         context:nil].size;

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake( ([UIScreen mainScreen].bounds.size.width - textSize.width)/2.0f, 370.0f, textSize.width, textSize.height)];
    [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]];
    [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [textLabel setNumberOfLines:0];
    [textLabel setText:text];
    [textLabel setTextColor:[UIColor colorWithRed:214.0f/255.0f green:206.0f/255.0f blue:191.0f/255.0f alpha:1.0f]];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setTextAlignment:NSTextAlignmentCenter];

    // {37, 221}, {245, 44}
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage];
    self.logoImageView = logoView;
    [self.pagesScrollView addSubview:logoView];
    
    UIImageView *lastPageLogoView = [[UIImageView alloc] initWithImage:logoImage];
    CGRect rect = lastPageLogoView.frame;
    rect.origin.x = self.pagesScrollView.frame.size.width * 5;
    lastPageLogoView.frame = CGRectIntegral(rect);
    [self.pagesScrollView addSubview:lastPageLogoView];
    
    

    UIImage *btnImage = [UIColor imageWithColor:[UIColor colorWithRed:0.227 green:0.675 blue:0.863 alpha:1.000]];

    self.twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.twitterButton.frame = CGRectMake(37, buttonYMargin, 245, 44);
    [self.twitterButton setImage:[UIImage imageNamed:@"Twitter-Icon"] forState:UIControlStateNormal];
    [self.twitterButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.twitterButton setTitle:@"Sign in with Twitter" forState:UIControlStateNormal];
    self.twitterButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    self.twitterButton.layer.cornerRadius = 1;
    self.twitterButton.clipsToBounds = YES;
    self.twitterButton.layer.shouldRasterize = YES;
    self.twitterButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    //self.twitterButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.pagesScrollView addSubview:self.twitterButton];
    [self.twitterButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableParagraphStyle *emailParagraph = [NSMutableParagraphStyle new];
    emailParagraph.alignment = NSTextAlignmentCenter;
    NSDictionary *emailattrs = @{NSParagraphStyleAttributeName: emailParagraph,
                            NSForegroundColorAttributeName: [GVTintColorUtility utilityTintColor],
                            NSBackgroundColorAttributeName: [UIColor clearColor]};
    UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    emailButton.showsTouchWhenHighlighted = YES;
    NSAttributedString *emailText = [[NSAttributedString alloc] initWithString:@"Sign up with Email" attributes:emailattrs];
    self.signupEmailButton = emailButton;
    [emailButton setAttributedTitle:emailText forState:UIControlStateNormal];
    [self.pagesScrollView addSubview:emailButton];
    [emailButton addTarget:self action:@selector(emailButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    emailButton.layer.shouldRasterize = YES;
    emailButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [emailButton sizeToFit];
    
    CGRect signinRect = emailButton.frame;
    signinRect.origin.x = self.pagesScrollView.frame.size.width/2 - emailButton.frame.size.width/2;
    signinRect.origin.y = self.twitterButton.frame.origin.y + self.twitterButton.frame.size.height + 25 + (deviceMultiplier*-18);
    emailButton.frame = signinRect;
    
    NSMutableParagraphStyle *supportParagraph = [NSMutableParagraphStyle new];
    supportParagraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attrs = @{NSParagraphStyleAttributeName: supportParagraph,
                            NSForegroundColorAttributeName: [GVTintColorUtility utilityTintColor],
                            NSBackgroundColorAttributeName: [UIColor clearColor]};
    NSAttributedString *supportText = nil;
    UIButton *supportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    supportButton.showsTouchWhenHighlighted = YES;
    if ([MFMailComposeViewController canSendMail]) {
        supportText = [[NSAttributedString alloc] initWithString:@"Support" attributes:attrs];
        [supportButton addTarget:self action:@selector(supportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        supportText = [[NSAttributedString alloc] initWithString:@"@gvideoapp" attributes:attrs];
        [supportButton addTarget:self action:@selector(twitterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    [supportButton setAttributedTitle:supportText forState:UIControlStateNormal];
    [self.pagesScrollView addSubview:supportButton];
    supportButton.layer.shouldRasterize = YES;
    supportButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [supportButton sizeToFit];
    
    
    CGRect supportRect = supportButton.frame;
    supportRect.origin.x = self.pagesScrollView.frame.size.width / 2 - supportRect.size.width/2;
    supportRect.origin.y = self.pagesScrollView.frame.size.height - supportRect.size.height - 15 + (deviceMultiplier*10);
    supportButton.frame = CGRectIntegral(supportRect);
    
    self.twitterButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect lastButtonRect = self.twitterButton.frame;
    lastButtonRect.origin.x += self.pagesScrollView.frame.size.width * 5;
    self.twitterButton1.frame = CGRectIntegral(lastButtonRect);
    
    
    [self.twitterButton1 setImage:[self.twitterButton imageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.twitterButton1 setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.twitterButton1 setTitle:[self.twitterButton titleForState:UIControlStateNormal] forState:UIControlStateNormal];
    self.twitterButton1.imageEdgeInsets = self.twitterButton.imageEdgeInsets;
    self.twitterButton1.layer.cornerRadius = self.twitterButton.layer.cornerRadius;
    self.twitterButton1.clipsToBounds = self.twitterButton.clipsToBounds;
    self.twitterButton1.layer.shouldRasterize = self.twitterButton.layer.shouldRasterize;
    self.twitterButton1.layer.rasterizationScale = self.twitterButton.layer.rasterizationScale;
    //self.twitterButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.pagesScrollView addSubview:self.twitterButton1];
    [self.twitterButton1 addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *seeMoreInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect moreInfoRect = self.twitterButton.frame;
    moreInfoRect.origin.x += 6;
    moreInfoRect.origin.y += self.twitterButton.frame.size.height + swipeYMargin;
    seeMoreInfo.layer.shouldRasterize = YES;
    seeMoreInfo.layer.rasterizationScale = [UIScreen mainScreen].scale;
    seeMoreInfo.frame = moreInfoRect;
    
    UIImage *arrowImage = [[UIImage imageNamed:@"lineicons_left-arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [seeMoreInfo setImage:arrowImage forState:UIControlStateNormal];
    seeMoreInfo.tintColor = [UIColor whiteColor];
    
    seeMoreInfo.imageEdgeInsets = UIEdgeInsetsMake(0, -27, 0, 0);
    
    [seeMoreInfo setBackgroundImage:[UIColor imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [seeMoreInfo setTitle:@"Learn More" forState:UIControlStateNormal];
    [self.pagesScrollView addSubview:seeMoreInfo];
    
    //[seeMoreInfo addTarget:self action:@selector(seeMoreInfoTap:) forControlEvents:UIControlEventTouchUpInside];

    
    UILongPressGestureRecognizer *seeMoreTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(seeMoreInfoTap:)];
    //seeMoreTap.delegate = self;
    seeMoreTap.delaysTouchesBegan = YES;
    seeMoreTap.minimumPressDuration = 0.01;
    [seeMoreInfo addGestureRecognizer:seeMoreTap];
    
    for (UIGestureRecognizer *gc in self.pagesScrollView.gestureRecognizers) {
        [seeMoreTap requireGestureRecognizerToFail:gc];
    }
    
//    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    [self.view addSubview:self.activityIndicatorView];
//    self.activityIndicatorView.center = self.view.center;
//    CGRect activityFrame = self.activityIndicatorView.frame;
//    activityFrame.origin.y = 380;
//    self.activityIndicatorView.frame = activityFrame;
//    self.activityIndicatorView.hidden = YES;

    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInNotification:) name:GVLoggedInNotification object:nil];
    
    //NSLog(@"%@", NSStringFromCGRect(self.logInView.twitterButton.frame));


//    [self.logInView setLogo:nil];
//    [self.logInView addSubview:textLabel];
//
//    self.fields = PFLogInFieldsUsernameAndPassword;
//    self.logInView.usernameField.placeholder = @"Enter your email";
//
//    //self.logInView.twitterButton = twitterBtn;
//
//    //CGRect twitterButtonFrame = self.logInView.twitterButton.frame;
//    //twitterButtonFrame.origin.y = 350;
//    //self.logInView.twitterButton.frame = twitterButtonFrame;
//    //[self.view setNeedsLayout];
//    //[self.view layoutIfNeeded];
//
//    for (id obj in [self.logInView.twitterButton allTargets]) {
//        NSLog(@" obj %@", obj);
//        [self.logInView.twitterButton removeTarget:obj action:NULL forControlEvents:UIControlEventAllEvents];
//    }
//
//    NSLog(@"actions %@", [self.logInView.twitterButton allTargets]);
//
//    [self.logInView.twitterButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    //[[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:@"pDDlfMALlx69h4AXeewd8IzJz" andSecret:@"zO53DnDvHyaMSvMzgI3k0AMPnPW4CnU1MCpZ5vbEzFQQBsWutR"];
    //[[FHSTwitterEngine sharedEngine] setDelegate:self];
}
//
//- (void)dealloc {
//   // [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

//- (void)loggedInNotification:(NSNotification*)notif {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
//            PFObject *installation = [PFInstallation currentInstallation];
//            [installation setObject:[PFUser currentUser] forKey:@"user"];
//            [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                if (!error) {
//                    NSLog(@" successfully saved installation");
//                } else {
//                    NSLog(@" failure saving installation, %@", error);
//                }
//            }];
//        }];
//    });
//}

- (void)fadeInLoginScreen {
    UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
    [emailField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:26.0]];
    [emailField setPlaceholder:@"your@email.com"];
    [emailField setBorderStyle:UITextBorderStyleLine];
    [emailField setTextAlignment:NSTextAlignmentCenter];
    emailField.backgroundColor = [UIColor whiteColor];
    self.emailTextField = emailField;
    CGRect emailFieldRect = emailField.frame;
    emailFieldRect.origin.x = self.pagesScrollView.frame.size.width/2 - emailFieldRect.size.width/2;
    emailFieldRect.origin.y = 76;
    self.emailTextField.frame = emailFieldRect;
    self.emailTextField = emailField;
    [self.pagesScrollView addSubview:emailField];
    
    UIButton *verifyEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    verifyEmail.frame = CGRectMake(self.pagesScrollView.frame.size.width/2 - emailFieldRect.size.width/2, 150, 280, 48);
    self.emailButton = verifyEmail;
    [verifyEmail setTitle:@"Verify Email" forState:UIControlStateNormal];
    [verifyEmail setBackgroundColor:[UIColor colorWithRed:0.200 green:0.365 blue:0.945 alpha:1.000]];
    verifyEmail.layer.cornerRadius = 1;
    verifyEmail.clipsToBounds = YES;
    [verifyEmail addTarget:self action:@selector(verifyEmail:) forControlEvents:UIControlEventTouchUpInside];
    [self.pagesScrollView addSubview:verifyEmail];
    
    
}

- (void)verifyEmail:(id)sender {
    NSString *text = [self.emailTextField.text lowercaseString];
    if (text.length > 0) {
        self.emailButton.alpha = 0.6;
        //self.emailButton.backgroundColor = [GVTintColorUtility utilityTintColor];
        [self.emailTextField resignFirstResponder];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        NSError *logInError;
        
        // attempt to authenticate by signing up first
        PFUser *newUser = [PFUser user];
        newUser.username = text;
        newUser.email = text;
        newUser.password = @"234234234234234";
        
        NSError *signUpError;
        [newUser signUp:&signUpError];
        if (!signUpError) {
            
            [hud hide:YES];
            
            NSLog(@"success at creating new user");
            [[NSNotificationCenter defaultCenter] postNotificationName:GVLoggedInNotification object:nil];
            
        } else if (signUpError.code == kPFErrorUsernameTaken) {
            self.email = text;
            NSDictionary *d = @{@"email":self.email};
            [PFCloud callFunctionInBackground:@"verifyEmail" withParameters:d block:^(id object, NSError *error) {
                if (!error) {

                    [hud hide:YES];
                    // now to update UI
                    if ([PFUser currentUser]) {
                        //sign up successful, email will hopefully be sent..
                    }
                    self.emailTextField.text = @"";
                    self.emailTextField.placeholder = @"12345";
                    [self.emailTextField becomeFirstResponder];
                    self.emailButton.alpha = 1;
                    for (id target in [self.emailButton allTargets]) {
                        [self.emailButton removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
                    }
                    [self.emailButton addTarget:self action:@selector(verifyToken:) forControlEvents:UIControlEventTouchUpInside];
                    [self.emailButton setTitle:@"Verify Token" forState:UIControlStateNormal];
                    if (!self.verifyLinkLabel) {
                        self.verifyLinkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                        [self.verifyLinkLabel setText:@"Or just tap the link in the Email."];
                        [self.verifyLinkLabel setTextColor:[UIColor whiteColor]];
                        [self.verifyLinkLabel sizeToFit];
                        
                        CGRect verifyLinkRect = self.verifyLinkLabel.frame;
                        verifyLinkRect.origin.x = self.pagesScrollView.frame.size.width/2 - verifyLinkRect.size.width/2;
                        verifyLinkRect.origin.y = self.emailButton.frame.origin.y + self.emailButton.frame.size.height + 15;
                        self.verifyLinkLabel.frame = verifyLinkRect;
                        self.verifyLinkLabel.alpha = 0;
                        [self.pagesScrollView addSubview:self.verifyLinkLabel];
                    
                        @weakify(self);
                        [UIView animateWithDuration:1.5 animations:^{
                            self_weak_.verifyLinkLabel.alpha = 1;
                        }];
                    }
                    
                    if (!self.verifyTokenLabel) {
                        self.verifyTokenLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                        [self.verifyTokenLabel  setText:@"Verify your Authentication Token"];
                        [self.verifyTokenLabel setTextColor:[UIColor whiteColor]];
                        [self.verifyTokenLabel sizeToFit];
                        
                        CGRect verifyTokenRect = self.verifyTokenLabel.frame;
                        verifyTokenRect.origin.x = self.pagesScrollView.frame.size.width/2 - verifyTokenRect.size.width/2;
                        verifyTokenRect.origin.y = self.emailTextField.frame.origin.y - verifyTokenRect.size.height - 15;
                        self.verifyTokenLabel.frame = verifyTokenRect;
                        
                        self.verifyTokenLabel.alpha = 0;
                        [self.pagesScrollView addSubview:self.verifyTokenLabel];
                        
                        @weakify(self);
                        [UIView animateWithDuration:1.5 animations:^{
                            self_weak_.verifyTokenLabel.alpha = 1;
                        }];
                    }
                    
                    
                } else {
                    NSLog(@"failure trying to login %@", logInError);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"There was an unknown error with logging in. Please try again or contact us for support." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                    [alert show];
                    self.emailButton.alpha = 1;
                    [hud hide:YES];
                    return;
                }
            }];
            // attempt to authenticate by logging in
            //PFUser *newUser = [PFUser logInWithUsername:twitter_screen_name password:twitter_oauth_token error:&logInError];
            
        } else {
            NSLog(@"parse error:%@ %@", signUpError, [NSNumber numberWithInteger:kPFErrorTimeout]);
            [hud hide:YES];
            self.emailButton.alpha = 1;
        }
    }
}

- (void)verifyToken:(id)sender {
    NSString *text = self.emailTextField.text;
    if (text && text.length == 5) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        self.emailButton.alpha = 0.6;
        NSDictionary *dict = @{@"email":self.email, @"token": self.emailTextField.text};
        [PFCloud callFunctionInBackground:@"verifyAuthToken" withParameters:dict block:^(id object, NSError *error) {
            if (!error) {
                [PFUser becomeInBackground:object block:^(PFUser *user, NSError *error) {
                    if ([PFUser currentUser]) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:GVLoggedInNotification object:nil];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Token Authentication Failure" message:@"There was an error authenticating your token, please try again or contact us for support." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                        [alert show];
                    }
                    [hud hide:YES];
                }];
            } else {
                [hud hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Token Authentication Failure" message:@"There was an error authenticating your token, please try again or contact us for support." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                self.emailButton.alpha = 1;
                [alert show];
            }
        }];
    }
}

- (void)fadeInLabel:(GVTutorialLabel*)label andLabel:(GVTutorialLabel*)label1 {
    if (!label.superview || !label1.superview) {
        if (label && !label.superview) {
            [self.pagesScrollView addSubview:label];
        }
        BOOL animateLabel = NO;
        if (label.alpha < 0.5) {
            animateLabel = YES;
        }
        if (label1 && !label1.superview) {
            [self.pagesScrollView addSubview:label1];
        }
        BOOL animateLabel1 = NO;
        if (label1.alpha < 0.5) {
            animateLabel1 = YES;
        }
        if (animateLabel || animateLabel1) {
            [UIView animateWithDuration:0.25 delay:0.3 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedCurve | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionOverrideInheritedOptions animations:^{
                label.alpha = 1;
            } completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateWithDuration:0.25 delay:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        label1.alpha = 1;
                    } completion:nil];
                }
            }];
        }
    }
}

- (void)fadeOutLabel:(GVTutorialLabel*)label andLabel:(GVTutorialLabel*)label1 {
    if ((label && label.superview) || (label1 && label1.superview)) {
        BOOL animateLabel = NO;
        if (label.alpha > 0.5) {
            animateLabel = YES;
        }
        BOOL animateLabel1 = NO;
        if (label1.alpha > 0.5) {
            animateLabel1 = YES;
        }
        if (animateLabel || animateLabel1) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionOverrideInheritedCurve animations:^{
                label.alpha = 0.0;
                label1.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [label removeFromSuperview];
                    [label1 removeFromSuperview];
                }
            }];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffset = scrollView.contentOffset.x;
    CGFloat bounds = scrollView.bounds.size.width;
    // trigger mask animations
    
    if (contentOffset > bounds-1 && contentOffset < bounds *2-2) {
        [self.welcomeImageView1 animateMaskFadeIn];
        [self.emailTextField resignFirstResponder];
        [self fadeInLabel:self.welcomeTutorial11 andLabel:self.welcomeTutorial12];
        
        [self.welcomeImageView2 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial21 andLabel:self.welcomeTutorial22];
        
        [self.welcomeImageView3 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial31 andLabel:self.welcomeTutorial32];
        
        [self.welcomeImageView4 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial41 andLabel:self.welcomeTutorial42];
    } else if (contentOffset > bounds *2-1 && contentOffset < bounds *3-2) {
        [self.welcomeImageView1 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial11 andLabel:self.welcomeTutorial12];
        
        [self.welcomeImageView2 animateMaskFadeIn];
        [self fadeInLabel:self.welcomeTutorial21 andLabel:self.welcomeTutorial22];
        
        [self.welcomeImageView3 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial31 andLabel:self.welcomeTutorial32];
        
        [self.welcomeImageView4 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial41 andLabel:self.welcomeTutorial42];
    } else if (contentOffset > bounds *3-1 && contentOffset < bounds *4-2) {
        [self.welcomeImageView1 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial11 andLabel:self.welcomeTutorial12];
        
        [self.welcomeImageView2 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial21 andLabel:self.welcomeTutorial22];
        
        [self.welcomeImageView3 animateMaskFadeIn];
        [self fadeInLabel:self.welcomeTutorial31 andLabel:self.welcomeTutorial32];
        
        [self.welcomeImageView4 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial41 andLabel:self.welcomeTutorial42];
    } else if (contentOffset > bounds *4-1 && contentOffset < bounds *5-2) {
        [self.welcomeImageView1 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial11 andLabel:self.welcomeTutorial12];
        
        [self.welcomeImageView2 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial21 andLabel:self.welcomeTutorial22];
        
        [self.welcomeImageView3 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial31 andLabel:self.welcomeTutorial32];
        
        [self.welcomeImageView4 animateMaskFadeIn];
        [self fadeInLabel:self.welcomeTutorial41 andLabel:self.welcomeTutorial42];
    } else {
        [self.welcomeImageView1 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial11 andLabel:self.welcomeTutorial12];
        
        [self.welcomeImageView2 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial21 andLabel:self.welcomeTutorial22];
        
        [self.welcomeImageView3 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial31 andLabel:self.welcomeTutorial32];
        
        [self.welcomeImageView4 animateMaskFadeOut];
        [self fadeOutLabel:self.welcomeTutorial41 andLabel:self.welcomeTutorial42];
    }
}

- (void)emailButtonTap:(id)sender {
    @weakify(self);
    if (!self.emailButton.superview) {
        [self fadeInLoginScreen];
        self.emailButton.alpha = 0.0;
        self.emailTextField.alpha = 0.0;
    }
    [UIView animateWithDuration:1.0 animations:^{
        @strongify(self);
        self.logoImageView.alpha = 0;
        self.emailTextField.alpha = 1;
        self.emailButton.alpha = 1;
        self.signupEmailButton.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            @strongify(self);
            [self.emailTextField becomeFirstResponder];
        }
    }];
}

- (void)seeMoreInfoTap:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.duration = 0.75;
        
        CGFloat offsetValue = 160;
        NSUInteger steps = 100;
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:1];
        CGFloat value = 0;
        float e = 2.71;
        for (NSUInteger t = 0; t <= steps; t++) {
            value = (offsetValue*2) * pow(e, -0.055*t) * cos(0.08*t) + offsetValue;
    #if CGFLOAT_IS_DOUBLE
            [values addObject:[NSNumber numberWithDouble:value]];
    #else
            [values addObject:[NSNumber numberWithFloat:value]];
    #endif
        }
        animation.values = values;
        
        NSNumber *offsetValueNum = nil;
    #if CGFLOAT_IS_DOUBLE
        offsetValueNum = [NSNumber numberWithDouble:offsetValue];
    #else
        offsetValueNum = [NSNumber numberWithFloat:offsetValue];
    #endif
        
        [self.pagesScrollView.layer setValue:offsetValueNum forKeyPath:animation.keyPath];
        [self.pagesScrollView.layer addAnimation:animation forKey:nil];
        
        //[self.pagesScrollView setContentOffset:CGPointMake(50, 0) animated:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    if ([PFUser currentUser]) {
//        @weakify(self);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self_weak_ dismissViewControllerAnimated:NO completion:nil];
//        });
//    }
}

- (void)supportButtonPressed:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        @weakify(self);
        NSBlockOperation *blockOperation = [NSBlockOperation new];
        @weakify(blockOperation);
        
        [blockOperation addExecutionBlock:^{
            
            if ([blockOperation_weak_ isCancelled]) {
                return ;
            }
            
            [self.operationQueue cancelAllOperations];
            self.operationQueue = nil;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                @strongify(self);
                MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
                [compose setToRecipients:@[@"gvideoapp@gmail.com"]];
                //[compose setSubject:@"Support Message"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self presentViewController:compose animated:YES completion:^{
                        @strongify(self);
                        compose.mailComposeDelegate = self;
                        self.operationQueue = [NSOperationQueue new];
                        self.operationQueue.maxConcurrentOperationCount = 1;
                    }];
                });
            });
        }];
        [self.operationQueue addOperations:@[blockOperation_weak_] waitUntilFinished:YES];
    }
}

- (void)twitterButtonPressed:(id)sender {
    [GVTwitterAuthUtility openTwitterToGvideoapp];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (self.presentedViewController) {
        
        @weakify(self);
        NSBlockOperation *blockOperation = [NSBlockOperation new];
        @weakify(blockOperation);
        
        [blockOperation addExecutionBlock:^{
            
            if ([blockOperation_weak_ isCancelled]) {
                return ;
            }
            
            [self.operationQueue cancelAllOperations];
            self.operationQueue = nil;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                @strongify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self dismissViewControllerAnimated:YES completion:^{
                        @strongify(self);
                        self.operationQueue = [NSOperationQueue new];
                        self.operationQueue.maxConcurrentOperationCount = 1;
                    }];
                });
            });
        }];
        [self.operationQueue addOperations:@[blockOperation_weak_] waitUntilFinished:YES];
    }
}

- (void)loginButtonPressed:(id)sender {

    @weakify(self);
    
    GVAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    BOOL reachable = NO;
    
    if ([delegate respondsToSelector:@selector(isParseReachable)]) {
        reachable = [delegate performSelector:@selector(isParseReachable)];
    }
    
    if ([GVTwitterAuthUtility userHasAccessToTwitter] && reachable) {

//    GVTwitterSigninViewController *vc = [[GVTwitterSigninViewController alloc] initWithNibName:nil bundle:nil];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self_weak_ presentViewController:vc animated:YES completion:nil];
//    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    });

    // You *MUST* keep the ACAccountStore alive for as long as you need an
    // ACAccount instance. See WWDC 2011 Session 124 for more info.
    self.accountStore = [[ACAccountStore alloc] init];

    //  We only want to receive Twitter accounts
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];


    self.twitterButton.enabled = NO;
    self.twitterButton1.enabled = self.twitterButton.enabled;
    //self.activityIndicatorView.hidden = NO;
    //[self.activityIndicatorView startAnimating];
    

    //  Obtain the user's permission to access the store
    [self.accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        @strongify(self);
        self.twitterButton.enabled = YES;
        self.twitterButton1.enabled = self.twitterButton.enabled;
        //self.activityIndicatorView.hidden = YES;
        //[self.activityIndicatorView stopAnimating];
         if (!granted) {
             // handle this scenario gracefully
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter OAuth Failed" message:@"Please allow Gvideo Twitter access through \"Privacy\" Settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alertView show];
             });
         } else {
             [TestFlight passCheckpoint:@"Granted Twitter Permission"];
             // obtain all the local account instances
             self.accounts = [self.accountStore accountsWithAccountType:twitterType];
             if ([self.accounts count] > 1) {
                 GVAccountsListViewController *acctViewController = [[GVAccountsListViewController alloc] initWithStyle:UITableViewStyleGrouped];
                 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:acctViewController];
                 //[GVTintColorUtility applyNavigationBarTintColor:navigationController.navigationBar];
                 @weakify(acctViewController);
                 acctViewController.selectedCompletionBlock = [NSBlockOperation blockOperationWithBlock:^{
                     @strongify(self);
                     [acctViewController.progressHUD hide:YES];
                     acctViewController.progressHUD = nil;
                     [TestFlight passCheckpoint:@"Logged In With Selected Account"];
                     int selectedIndex = [acctViewController_weak_.tableSelectedIndex intValue];
                     [GVTwitterAuthUtility shouldLoginAccountWithAccount:[self.accounts objectAtIndex:selectedIndex]];
                     //[self dismissViewControllerAnimated:YES completion:nil];
                 }];

//                 if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//                     acctViewController.preferredContentSize = CGSizeMake(320, 480);
//                     acctViewController.edgesForExtendedLayout = UIRectEdgeNone;
//                     acctViewController.modalPresentationStyle = UIModalPresentationPageSheet;
//                     acctViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//                 }
                 [self presentViewController:navigationController animated:YES completion:^{
                     dispatch_async(dispatch_get_main_queue(), ^{
                         @strongify(self);
                         [self.progressHUD hide:YES];
                         self.progressHUD = nil;
                     });
                 }];
             } else if ([self.accounts count] == 1) {
                 [TestFlight passCheckpoint:@"Logged In"];
                 [GVTwitterAuthUtility shouldLoginAccountWithAccount:[self.accounts objectAtIndex:0]];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     @strongify(self);
                     [self.progressHUD hide:YES];
                     self.progressHUD = nil;
                 });
             } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     @strongify(self);
                     [self.progressHUD hide:YES];
                     self.progressHUD = nil;
                 });
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Twitter Account" message:@"A twitter account was not found, please try again with an authenticated twitter account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 [alertView show];
             }

         }
    }];

    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (reachable) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Account not found" message:@"You must signin with a valid Twitter account in Settings.app if you would like to use Gvideo with Twitter, alternatively, signin with Email" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"You are not currently connected to the internet or Twitter is unreachable. Please try again when you have an internet connection." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                [alert show];
            }
        });
    }

    //  Assume that we stored the result of Step 1 into a var 'resultOfStep1'



//    [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
//        NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
//    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    //CGRect fbButtonFrame = self.logInView.twitterButton.frame;
    //fbButtonFrame.origin.y = 310;

    //NSLog(@"%@", NSStringFromCGRect(self.logInView.twitterButton.frame));

    //self.logInView.facebookButton.frame = fbButtonFrame;
    //self.logInView.twitterButton.frame = fbButtonFrame;

    //CGPoint center self.twitterButton.center
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGPoint viewCenter = self.view.center;
        viewCenter.x += 4;
        //self.activityIndicatorView.center = viewCenter;
        self.bgView.frame = self.view.bounds;
        CGFloat width = 245;
        CGFloat topPadding = 100;
        self.twitterButton.frame = CGRectIntegral(CGRectMake((self.view.bounds.size.width / 2) - (width / 2), self.view.bounds.size.height - topPadding, width, 44));
        
        CGRect lastPageTwitterRect = self.twitterButton.frame;
        lastPageTwitterRect.origin.x += self.pagesScrollView.frame.size.width * 4;
        self.twitterButton1.frame = CGRectIntegral(lastPageTwitterRect);
    }
    
    [self.pagesScrollView setNeedsLayout];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}


//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
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
