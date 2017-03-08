//
//  GVTwitterAuthUtility.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/4/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVTwitterAuthUtility.h"
#import <Social/Social.h>
#import "XQueryComponents.h"
#import "GVAppDelegate.h"
#import "GVParseObjectUtility.h"
#import "UIImage+RoundedCornerAdditions.h"
#import "UIImage+ResizeAdditions.h"
#import "GVDiskCache.h"

NSString * const GVTwitterAuthConsumerKey = @"Mg2OxY6eByUqgHxDjS2xGU0oP";

NSString * const GVTwitterReverseAuthTargetKey = @"x_reverse_auth_target";
NSString * const GVTwitterReverseAuthTokenKey = @"x_reverse_auth_parameters";


NSString * const GVTwitterReverseAuthPathKey = @"http://gvideoapp.com/auth/twitter/reverse";
NSString * const GVTwitterAccessTokenPathKey = @"https://api.twitter.com/oauth/access_token";
NSString * const GVTwitterProfileLookupPathKey = @"https://api.twitter.com/1.1/users/lookup.json";
NSString * const GVTwitterUserShowPathKey = @"https://api.twitter.com/1.1/users/show.json";

NSString * const GVTwitterUsernameTargetKey = @"screen_name";
NSString * const GVTwitterUserRealNameKey = @"name";
NSString * const GVTwitterProfileImageKey = @"profile_image_url";
NSString * const GVTwitterProfileBannerKey = @"profile_banner_url";

@interface GVTwitterAuthUtility ()

@property (nonatomic, strong) NSBlockOperation *blockOperation;
@property (nonatomic, strong) NSMutableDictionary *keyedOperations;
@property (nonatomic, strong) NSMutableDictionary *keyedResponses;

@end

@implementation GVTwitterAuthUtility

+ (GVTwitterAuthUtility *)sharedInstance {
    static dispatch_once_t pred;
    static GVTwitterAuthUtility *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[GVTwitterAuthUtility alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        @autoreleasepool {
            [self getNewReverseAuthTokens];
            self.keyedOperations = [NSMutableDictionary dictionaryWithCapacity:1];
            self.keyedResponses = [NSMutableDictionary dictionaryWithCapacity:1];
        }
    }
    return self;
}

- (void)getNewReverseAuthTokens {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:GVTwitterReverseAuthPathKey parameters:nil success:^(AFHTTPRequestOperation *operation, id responseData) {

        self.liveTokens = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

        if (self.blockOperation && !self.blockOperation.isExecuting) {
            [self.blockOperation start];
            self.blockOperation = nil;
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" getnewreverseauth failed %@", error);

        
        [GVTwitterAuthUtility showAlertErrorForTwitterAuthentication];
    }];
}

//+ (void)filterDuplicates:(void (^)(NSData *responseData)requestBlock {
//    
//}

+ (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

+ (void)openTwitterToGvideoapp {
    if ([GVTwitterAuthUtility userHasAccessToTwitter]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=gvideoapp"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.twitter.com/gvideoapp"]];
    }
}

+ (void)showAlertErrorForTwitterAuthentication {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Auth Failed" message:@"There was an error with Gvideo connecting to Twitter. Please try again." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

+ (void)makeRequest:(NSURL*)url toAccount:(NSString*)username block:(void (^)(NSData *responseData))requestBlock {

    if ([PFUser currentUser]) {
        if (!username || [username length] < 1) {
            return;
        }
    }

    NSString *currentKey = [[url absoluteString] stringByAppendingString:username];
    //NSMutableDictionary *reqs = [GVTwitterAuthUtility sharedInstance].keyedOperations;

    [GVTwitterAuthUtility sharedInstance].blockOperation = [NSBlockOperation blockOperationWithBlock:^{

//        if (![PFUser currentUser]) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In" message:@"You must be logged into twitter to make requests" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
//            return ;
//        }




        SLRequestMethod method = SLRequestMethodGET;
        BOOL authenticating = [[url absoluteString] isEqualToString:GVTwitterAccessTokenPathKey];
        NSMutableDictionary *step2Params = [[NSMutableDictionary alloc] init];
        if (authenticating) {
            [step2Params setValue:GVTwitterAuthConsumerKey forKey:GVTwitterReverseAuthTargetKey];
            method = SLRequestMethodPOST;
        } else {
            [step2Params setValue:username forKey:GVTwitterUsernameTargetKey];
        }
        [step2Params setValue:[GVTwitterAuthUtility sharedInstance].liveTokens forKey:GVTwitterReverseAuthTokenKey];

        SLRequest *stepTwoRequest =
        [SLRequest requestForServiceType:SLServiceTypeTwitter
                           requestMethod:method
                                     URL:url
                              parameters:step2Params];
        
        NSString *userScreenName = username;
        if ([PFUser currentUser]) {
            userScreenName = [[PFUser currentUser] username];
        }

        ACAccountStore *acctStore = [[ACAccountStore alloc] init];
        for (ACAccount *acct in acctStore.accounts) {
            if ([acct.username isEqualToString:userScreenName]) {
                [stepTwoRequest setAccount:acct];
            }
        }
        NSLog(@"twitter url request: %@ username:%@", url, username);
        //NSURLRequest urlRequest = [stepTwoRequest preparedURLRequest];
        // execute the request
        //[AFHTTPRequestOperationManager manager]
        //[NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse, NSData* data, NSError* connectionError) {

        NSMutableDictionary *currentReqs = [GVTwitterAuthUtility sharedInstance].keyedOperations;
        for (NSString *enumkey in currentReqs) {
            if ([enumkey isEqualToString:currentKey]) {

                NSMutableArray *arr = [currentReqs objectForKey:enumkey];

                NSBlockOperation *dupeBlockOp = [NSBlockOperation blockOperationWithBlock:^{

                    NSData *gotResponseData;
                    NSMutableDictionary *responses = [GVTwitterAuthUtility sharedInstance].keyedResponses;
                    for (NSString *respKeyFilter in responses) {
                        if ([respKeyFilter isEqualToString:currentKey]) {
                            gotResponseData = [responses objectForKey:respKeyFilter];
                        }
                    }
                    if (gotResponseData) {
                        requestBlock(gotResponseData);
                    }
                }];


                if (!arr && !([arr count] > 0)) {
                    arr = [NSMutableArray arrayWithCapacity:1];
                }
                [arr addObject:dupeBlockOp];

                return;
            }
        }


        [stepTwoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error && urlResponse.statusCode == 200) {



                requestBlock(responseData);

                NSMutableDictionary *responses = [GVTwitterAuthUtility sharedInstance].keyedResponses;

                [responses setObject:responseData forKey:currentKey];

                // flush any duplicates now with the response data serialized through the keyed respones

                NSMutableDictionary *runReqs = [GVTwitterAuthUtility sharedInstance].keyedOperations;
                for (NSString* runkey in runReqs) {
                    if ([runkey isEqualToString:currentKey]) {
                        NSMutableArray *dupeOps = [runReqs objectForKey:currentKey];
                        if ([dupeOps count] > 0) {
                            for (NSBlockOperation *dupeOp in dupeOps) {
                                if ([dupeOp respondsToSelector:@selector(start)]) {
                                    NSOperation *aDupeOp = (NSOperation*)dupeOp;
                                    [aDupeOp start];
                                }
                            }
                            [runReqs removeObjectForKey:runkey];
                        }
                    }
                }

                [GVTwitterAuthUtility sharedInstance].blockOperation = nil;
            } else {
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSLog(@"twitter auth failed %@; %@", error, responseStr);
                [[GVTwitterAuthUtility sharedInstance] getNewReverseAuthTokens];
            }
            //}];
        }];
    }];
    if (![GVTwitterAuthUtility sharedInstance].liveTokens) {
        [[GVTwitterAuthUtility sharedInstance] getNewReverseAuthTokens];
    } else {

        [[[GVTwitterAuthUtility sharedInstance] blockOperation] start];
        //[GVTwitterAuthUtility sharedInstance].blockOperation = nil;
    }
}

+ (void)shouldLoginAccountWithAccount:(ACAccount*)account {

    NSURL *url = [NSURL URLWithString:GVTwitterAccessTokenPathKey];
    [GVTwitterAuthUtility makeRequest:url toAccount:account.username block:^(NSData *responseData) {
        // serialize response data
        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [responseStr dictionaryFromQueryComponents];

        // get our values needed
        NSString *twitter_screen_name = responseDict[@"screen_name"][0];
        NSString *twitter_user_id = responseDict[@"user_id"][0];
        NSString *twitter_oauth_token = responseDict[@"oauth_token"][0];
        //NSString *twitter_oauth_secret = responseDict[@"oauth_token_secret"][0];

        NSError *logInError;

        // attempt to authenticate by signing up first
        PFUser *newUser = [PFUser user];
        newUser.username = twitter_screen_name;
        newUser.password = twitter_oauth_token;
        [newUser setObject:twitter_user_id forKey:@"twitter_user_id"];

        NSError *signUpError;
        [newUser signUp:&signUpError];
        if (!signUpError) {

            NSLog(@"success at creating new user");
            [[NSNotificationCenter defaultCenter] postNotificationName:GVLoggedInNotification object:nil];

        } else if (signUpError.code == kPFErrorUsernameTaken) {

            NSDictionary *d = @{@"username":twitter_screen_name};
            [PFCloud callFunctionInBackground:@"verifyToken" withParameters:d block:^(id object, NSError *error) {
                if (!error) {
                    [PFUser becomeInBackground:object block:^(PFUser *newUser, NSError *error) {
                        if ([PFUser currentUser]) {

                            NSLog(@"success at logging in");
                            [[NSNotificationCenter defaultCenter] postNotificationName:GVLoggedInNotification object:nil];
                            return;

                        } else {

                            NSLog(@"failure trying to login %@", logInError);
                            [GVTwitterAuthUtility showAlertErrorForTwitterAuthentication];
                            return;
                        }
                    }];
                } else {
                    NSLog(@"failure trying to login %@", logInError);
                    [GVTwitterAuthUtility showAlertErrorForTwitterAuthentication];
                    return;
                }
            }];
            // attempt to authenticate by logging in
                    //PFUser *newUser = [PFUser logInWithUsername:twitter_screen_name password:twitter_oauth_token error:&logInError];

        } else {
            NSLog(@"parse error:%@ %@", signUpError, [NSNumber numberWithInteger:kPFErrorTimeout]);
            [GVTwitterAuthUtility showAlertErrorForTwitterAuthentication];
        }
    }];

}

+ (NSString*)stripTwitterImageURLtoOriginal:(NSString*)profileImageUrl {
    NSString *profileOriginalUrl;
    if ([profileImageUrl hasSuffix:@"_normal.png"]) {
        NSString *profileTrimmedUrl = [profileImageUrl stringByReplacingOccurrencesOfString:@"_normal.png" withString:@""];
        profileOriginalUrl = [NSString stringWithFormat:@"%@%@", profileTrimmedUrl, @".png"];
    } else if ([profileImageUrl hasSuffix:@"_normal.jpg"]) {
        NSString *profileTrimmedUrl = [profileImageUrl stringByReplacingOccurrencesOfString:@"_normal.jpg" withString:@""];
        profileOriginalUrl = [NSString stringWithFormat:@"%@%@", profileTrimmedUrl, @".jpg"];
    } else if ([profileImageUrl hasSuffix:@"_normal.jpeg"]) {
        NSString *profileTrimmedUrl = [profileImageUrl stringByReplacingOccurrencesOfString:@"_normal.jpeg" withString:@""];
        profileOriginalUrl = [NSString stringWithFormat:@"%@%@", profileTrimmedUrl, @".jpeg"];
    } else if ([profileImageUrl hasSuffix:@"_normal.gif"]) {
        NSString *profileTrimmedUrl = [profileImageUrl stringByReplacingOccurrencesOfString:@"_normal.gif" withString:@""];
        profileOriginalUrl = [NSString stringWithFormat:@"%@%@", profileTrimmedUrl, @".gif"];
    } else {
        profileOriginalUrl = profileImageUrl;
    }
    return profileOriginalUrl;
}

+ (void)shouldGetProfileImageForAnyUser:(NSString*)username block:(void (^)(NSURL *imageURL, NSURL *bannerURL, NSString *realname))requestBlock {

    NSURL *url = [NSURL URLWithString:GVTwitterUserShowPathKey];

    //NSString *userProfileURL;
    //NSString *bannerProfileURL;

    NSDictionary *data = [[GVDiskCache diskCache] cachedAttributesForUsername:username];

    if (data) {
        // return the data
        id profileURL = data[kGVDiskCacheUserProfilePic];
        id bannerURL = data[kGVDiskCacheUserBannerPic];
        id realName = data[kGVDiskCacheRealNameKey];
        requestBlock(profileURL, bannerURL, realName);
    } else {
        // gotta load it

        [GVTwitterAuthUtility makeRequest:url toAccount:username block:^(NSData *responseData) {
            // response data serialization
            NSError *serializeError;
            NSDictionary *user = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&serializeError];

            if (serializeError) {
                //[GVTwitterAuthUtility showAlertErrorForTwitterAuthentication];
            } else {
                // get our values
                //NSLog(@"user object: %@", user);

                NSString *profileImageUrl = [user objectForKey:GVTwitterProfileImageKey];
                NSString *profileOriginalUrl = [GVTwitterAuthUtility stripTwitterImageURLtoOriginal:profileImageUrl];


                NSString *profileBannerUrl = [user objectForKey:GVTwitterProfileBannerKey];
                NSString *profileBannerImageUrl = [GVTwitterAuthUtility stripTwitterImageURLtoOriginal:profileBannerUrl];
                NSString *realname = [user objectForKey:GVTwitterUserRealNameKey];
                // make a nsurlconnectionrequest to get the image data
                //NSData *imageData = [NSData dataWithContentsOfURL:];

                // get the uiimage
                //UIImage *image = [UIImage imageWithData:imageData];

                //NSData *bannerData = [NSData dataWithContentsOfURL:];

                //UIImage *banner = [UIImage imageWithData:bannerData];

                // need to save it here...
                NSURL *profileURL = [NSURL URLWithString:profileOriginalUrl];
                NSURL *bannerURL = [NSURL URLWithString:profileBannerImageUrl];
                [[GVDiskCache diskCache] cacheAttributesForUsername:username profilePic:profileURL bannerPic:bannerURL realName:realname];
                requestBlock(profileURL, bannerURL, realname);
            }
        }];
    }
}

+ (void)shouldGetProfileDetailsForUsers:(NSString*)usernames completionBlock:(void (^)(NSDictionary *returnedData))completionBlock {
    NSURL *url = [NSURL URLWithString:GVTwitterProfileLookupPathKey];
    [GVTwitterAuthUtility makeRequest:url toAccount:usernames block:^(NSData *responseData) {
        // response data serialization
        NSError *serializeError;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&serializeError];

        if (serializeError) {
            //[GVTwitterAuthUtility showAlertErrorForTwitterAuthentication];
        } else {
            // get our values
            //NSLog(@"user object: %@", user);
            for (NSDictionary *user in data) {
                NSString *username = [user objectForKey:GVTwitterUsernameTargetKey];
                NSString *profileImageUrl = [user objectForKey:GVTwitterProfileImageKey];
                NSString *profileOriginalUrl = [GVTwitterAuthUtility stripTwitterImageURLtoOriginal:profileImageUrl];


                NSString *profileBannerUrl = [user objectForKey:GVTwitterProfileBannerKey];
                NSString *profileBannerImageUrl = [GVTwitterAuthUtility stripTwitterImageURLtoOriginal:profileBannerUrl];
                NSString *realname = [user objectForKey:GVTwitterUserRealNameKey];
            // make a nsurlconnectionrequest to get the image data
            //NSData *imageData = [NSData dataWithContentsOfURL:];

            // get the uiimage
            //UIImage *image = [UIImage imageWithData:imageData];

            //NSData *bannerData = [NSData dataWithContentsOfURL:];

            //UIImage *banner = [UIImage imageWithData:bannerData];

            // need to save it here...
                NSURL *profileURL = [NSURL URLWithString:profileOriginalUrl];
                NSURL *bannerURL = [NSURL URLWithString:profileBannerImageUrl];
                [[GVDiskCache diskCache] cacheAttributesForUsername:username profilePic:profileURL bannerPic:bannerURL realName:realname];
            }
            completionBlock(data);
        }
    }];
}

+ (void)shouldGetProfileImageForCurrentUserBlock:(void (^)(NSURL *imageURL, NSURL *bannerURL, NSString *realName))requestBlock {

    PFUser *currentUser = [[PFUser currentUser] username];
    NSString *username = currentUser;

    NSURL *url = [NSURL URLWithString:GVTwitterProfileLookupPathKey];

    //NSString *userProfileURL;
    //NSString *bannerProfileURL;

    NSDictionary *data = [[GVDiskCache diskCache] cachedAttributesForUsername:username];

   if (data) {
       // return the data
       id profileURL = data[kGVDiskCacheUserProfilePic];
       id bannerURL = data[kGVDiskCacheUserBannerPic];
       id realName = data[kGVDiskCacheRealNameKey];
       requestBlock(profileURL, bannerURL, realName);
   } else {
       // gotta load it

       [GVTwitterAuthUtility makeRequest:url toAccount:username block:^(NSData *responseData) {
           // response data serialization
           NSError *serializeError;
           NSArray *user = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&serializeError];

           if (serializeError) {
               //[GVTwitterAuthUtility showAlertErrorForTwitterAuthentication];
           } else {
               // get our values
               NSString *profileImageUrl = [user[0] objectForKey:GVTwitterProfileImageKey];
               NSString *profileOriginalUrl = [GVTwitterAuthUtility stripTwitterImageURLtoOriginal:profileImageUrl];

               NSString *profileBannerUrl = [user[0] objectForKey:GVTwitterProfileBannerKey];
               NSString *profileBannerImageUrl = [GVTwitterAuthUtility stripTwitterImageURLtoOriginal:profileBannerUrl];

               // make a nsurlconnectionrequest to get the image data
               //NSData *imageData = [NSData dataWithContentsOfURL:];
               NSString *realName = [user[0] objectForKey:GVTwitterUserRealNameKey];
               // get the uiimage
               //UIImage *image = [UIImage imageWithData:imageData];
               
               //NSData *bannerData = [NSData dataWithContentsOfURL:];
               
               //UIImage *banner = [UIImage imageWithData:bannerData];

               // need to save it here...
               NSURL *profileURL = [NSURL URLWithString:profileOriginalUrl];
               NSURL *bannerURL = [NSURL URLWithString:profileBannerImageUrl];
               [[GVDiskCache diskCache] cacheAttributesForUsername:username profilePic:profileURL bannerPic:bannerURL realName:realName];
               requestBlock(profileURL, bannerURL, realName);
           }
       }];
   }
}

//+ (void)shouldGetProfileBannerForUser:(NSString*)user block:(void (^)(UIImage *image))requestBlock {
//    NSURL *url = [NSURL URLWithString:GVTwitterProfileLookupPathKey];
//    [GVTwitterAuthUtility makeRequest:url toAccount:user block:^(NSData *responseData) {
//        // response data serialization
//        NSError *serializeError;
//        NSArray *user = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&serializeError];
//
//        if (serializeError) {
//            //[GVTwitterAuthUtility showAlertErrorForTwitterAuthentication];
//        } else {
//            // get our values
//            NSString *profileImageUrl = [user[0] objectForKey:@"profile_banner"];
//            NSString *profileOriginalUrl = [NSString stringWithFormat:@"%@%@", profileImageUrl, @"/mobile_retina"];
//
//            // make a nsurlconnectionrequest to get the image data
//            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profileOriginalUrl]];
//
//            // get the uiimage
//            UIImage *image = [UIImage imageWithData:imageData];
//
//            requestBlock(image);
//        }
//    }];
//}

@end
